import { afterEach, describe, expect, it } from 'vitest';
import { setup, PNG, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());
describe('Idempotency-Key (CS-21)', () => {
  it('coalesces concurrent creates, persists across requests and refuses a changed body', async () => {
    e = setup();
    const a = await e.login('alice');
    const options = { token: a.token, headers: { 'idempotency-key': 'retry-1' }, body: { kind: 'text', body: 'hello' } };
    const results = await Promise.all(Array.from({ length: 4 }, () => e.req('POST', '/v1/posts', options)));
    expect(results.map((r) => r.status)).toEqual([200, 200, 200, 200]);
    expect(new Set(results.map((r) => r.json.id)).size).toBe(1);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM posts').get()).toEqual({ n: 1 });
    expect((await e.req('POST', '/v1/posts', { ...options, body: { kind: 'text', body: 'changed' } })).status).toBe(409);
    expect((await e.req('POST', '/v1/posts', options)).headers.get('idempotency-replayed')).toBe('true');
    await e.req('DELETE', `/v1/posts/${results[0]!.json.id}`, { token: a.token });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM request_keys').get()).toEqual({ n: 0 });
  });

  it('isolates users and media retries; revoked sessions cannot replay successful requests', async () => {
    e = setup();
    const a = await e.login('alice');
    const b = await e.login('bob');
    const mediaOptions = { token: a.token, headers: { 'idempotency-key': 'same', 'content-type': 'image/png' }, raw: PNG };
    const first = await e.req('POST', '/v1/media', mediaOptions);
    const second = await e.req('POST', '/v1/media', mediaOptions);
    expect(first.status).toBe(200); expect(second.json.key).toBe(first.json.key);
    const other = await e.req('POST', '/v1/media', { ...mediaOptions, token: b.token });
    expect(other.json.key).not.toBe(first.json.key);
    await e.req('POST', '/v1/auth/logout', { token: a.token });
    expect((await e.req('POST', '/v1/media', mediaOptions)).status).toBe(401);
    e.clock.t += 86400_000;
    e.repo.cleanup(e.clock.t);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM request_keys').get()).toEqual({ n: 0 });
  });
});
