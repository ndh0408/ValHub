import { createHash } from 'node:crypto';
import type { Hono } from 'hono';
import type { Ctx } from './context.js';
import type { StoredResponse } from './db/repo.js';
import { reasonError } from './errors.js';

/** Optional on creates only. Retries authenticate again but replay a durable result for at most 24 hours. */
export function registerIdempotency(app: Hono, x: Ctx): void {
  const pending = new Map<string, { fingerprint: string; result: Promise<StoredResponse | null> }>();
  app.use('/v1/*', async (c, next) => {
    const route = c.req.path;
    const key = c.req.header('idempotency-key');
    if (!key || c.req.method !== 'POST' || !(route === '/v1/posts' || route === '/v1/media' || /^\/v1\/posts\/[^/]+\/comments$/.test(route))) return next();
    const user = x.user(c, true);
    if (!/^[\x21-\x7e]{1,128}$/.test(key)) throw reasonError('invalid_input', 'idempotency_key_invalid');
    const id = createHash('sha256').update(`${user.id}:${route}:${key}`).digest('hex');
    const max = route === '/v1/media' ? 2 * 1024 * 1024 : 64 * 1024;
    const reader = c.req.raw.clone().body?.getReader();
    const hash = createHash('sha256').update(c.req.header('content-type') ?? '');
    let size = 0;
    if (reader) for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      size += value.length;
      if (size > max) { void reader.cancel().catch(() => {}); throw reasonError('invalid_input', 'body_too_large'); }
      hash.update(value);
    }
    const fingerprint = hash.digest('hex');
    const replay = (row: StoredResponse) => {
      if (row.fingerprint !== fingerprint) throw reasonError('conflict', 'idempotency_conflict');
      c.res = new Response(row.body, { status: row.status, headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store', 'idempotency-replayed': 'true' } });
    };
    const saved = x.repo.getRequestKey(id, x.now());
    if (saved) return replay(saved);
    let running = pending.get(id);
    while (running) {
      if (running.fingerprint !== fingerprint) throw reasonError('conflict', 'idempotency_conflict');
      const row = await running.result;
      if (row) return replay(row);
      running = pending.get(id);
    }
    // Bound the wait map. Normal per-user/action rate limits still apply to first attempts.
    if (pending.size >= 1000) throw reasonError('server_busy', 'server_busy', {}, 2);
    let finish!: (row: StoredResponse | null) => void;
    pending.set(id, { fingerprint, result: new Promise((resolve) => { finish = resolve; }) });
    let result: StoredResponse | null = null;
    try {
      await next();
      if (c.res.ok) {
        result = { fingerprint, body: await c.res.clone().text(), status: c.res.status };
        x.repo.saveRequestKey({ ...result, id, userId: user.id, expiresAt: x.now() + 86400_000 });
      }
    } finally { pending.delete(id); finish(result); }
  });
}
