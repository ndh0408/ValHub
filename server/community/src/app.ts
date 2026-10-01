import { Hono } from 'hono';
import { bodyLimit } from 'hono/body-limit';
import { Ctx, type AppDeps } from './context.js';
import { ApiError, errorBody, reasonError, notFound } from './errors.js';
import { registerAccount } from './routes/account.js';
import { registerAuth } from './routes/auth.js';
import { registerCommunities } from './routes/communities.js';
import { registerLfg } from './routes/lfg.js';
import { registerMedia } from './routes/media.js';
import { registerPosts } from './routes/posts.js';
import { registerPublicGuard } from './routes/public-guard.js';
import { registerReviews } from './routes/reviews.js';
import { registerSkins } from './routes/skins.js';
import { registerIdempotency } from './idempotency.js';

export type { AppDeps } from './context.js';

const MAX_JSON_BYTES = 64 * 1024;

const jsonBodyLimit = bodyLimit({
  maxSize: MAX_JSON_BYTES,
  onError: () => {
    throw reasonError('invalid_input', 'body_too_large');
  },
});

/** Builds the HTTP app. Everything external (DB, disk, Riot, clock) comes from `deps`. */
export function createApp(deps: AppDeps): Hono {
  return createAppWithCtx(deps).app;
}

/** Same as [createApp], also returning the shared context (the sweeper prunes its in-memory caches). */
export function createAppWithCtx(deps: AppDeps): { app: Hono; ctx: Ctx } {
  const x = new Ctx(deps);
  const logError = deps.logError ?? ((msg: string) => console.error(msg));
  const app = new Hono();

  // Every response that does not set its own Cache-Control (JSON, errors, 204s, healthz) is no-store:
  // authenticated JSON must never be shared by a cache, and Cloudflare caches by file extension, so an
  // error for a media path (404!) would otherwise be cached at the edge and outlive a later upload.
  app.use('*', async (c, next) => {
    const started = performance.now();
    await next();
    if (!c.req.path.startsWith('/healthz')) x.stats.recordHttp(c.res.status);
    if (!c.req.path.startsWith('/healthz')) deps.logAccess?.({
      method: c.req.method, route: c.req.routePath || 'unmatched', status: c.res.status,
      durationMs: Math.round(performance.now() - started),
    });
    if (!c.res.headers.has('cache-control')) c.res.headers.set('cache-control', 'no-store');
    if (c.res.status >= 400) x.stats.inc(`${c.res.status}:${c.req.routePath ?? 'unmatched'}`);
  });

  // Load shedding: while the event loop is lagging (sustained, see load.ts) answer 503 at once instead of
  // queueing more work behind it. Only the health check is exempt.
  app.use('*', async (c, next) => {
    const limit = x.tuning.loadShedLagMs;
    if (limit > 0 && c.req.path !== '/healthz' && x.loadLagMs() > limit) {
      x.stats.inc('shed');
      throw reasonError('server_busy', 'server_busy', {}, 2);
    }
    return next();
  });

  app.use('*', async (c, next) => {
    if (c.req.method === 'POST' && c.req.path === '/v1/media') return next();
    return jsonBodyLimit(c, next);
  });

  app.options('*', (c) =>
    c.body(null, 204, { allow: 'GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS' }),
  );

  app.get('/healthz', (c) => {
    let ok = false;
    try {
      ok = deps.repo.ping();
    } catch {
      ok = false;
    }
    return x.json(c, { ok }, ok ? 200 : (500 as 200));
  });

  app.get('/healthz/deep', async (c) => {
    const peer = (c.env as { incoming?: { socket?: { remoteAddress?: string } } } | undefined)?.incoming?.socket?.remoteAddress;
    if (!['127.0.0.1', '::1', '::ffff:127.0.0.1'].includes(peer ?? '') || c.req.header('cf-connecting-ip') || c.req.header('x-forwarded-for') || !deps.deepHealth) throw notFound();
    const metrics = await deps.deepHealth();
    const ok = metrics.writable === true && typeof metrics.freeBytes === 'number' && metrics.freeBytes >= 64 * 1024 * 1024 && deps.repo.ping();
    return x.json(c, { ...metrics, loopLagMs: x.loadLagMs(), http: x.stats.httpTotals(), ok }, ok ? 200 : (503 as 200));
  });

  registerPublicGuard(app, x);
  registerIdempotency(app, x);
  registerAuth(app, x);
  registerAccount(app, x);
  registerLfg(app, x);
  registerSkins(app, x);
  registerReviews(app, x);
  registerCommunities(app, x);
  registerPosts(app, x);
  registerMedia(app, x);

  app.notFound((c) => {
    const err = new ApiError('not_found', 'Không tìm thấy đường dẫn.');
    return c.body(JSON.stringify(errorBody(err)), 404, {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    });
  });

  app.onError((e, c) => {
    let err: ApiError;
    if (e instanceof ApiError) {
      err = e;
    } else {
      // Only the error name/message is logged — never headers, bodies or tokens.
      logError(`[${c.req.method} ${c.req.routePath}] ${e.name}`);
      err = reasonError('server_error', 'server_error');
    }
    const headers: Record<string, string> = {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    };
    if (err.retryAfter !== undefined) headers['retry-after'] = String(err.retryAfter);
    return c.body(JSON.stringify(errorBody(err)), err.status as 400, headers);
  });

  return { app, ctx: x };
}
