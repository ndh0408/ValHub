import { afterEach, describe, expect, it, vi } from 'vitest';
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

  it('rolls back content and attachments when recording the retry result fails', async () => {
    e = setup();
    const a = await e.login('alice');
    const up = await e.req('POST', '/v1/media', { token: a.token, headers: { 'content-type': 'image/png' }, raw: PNG });
    const key = up.json.key;
    const save = vi.spyOn(e.repo, 'saveRequestKey').mockImplementationOnce(() => { throw new Error('disk failed'); });
    const options = { token: a.token, headers: { 'idempotency-key': 'atomic-1' }, body: { kind: 'text', body: 'hello', media: [key] } };
    expect((await e.req('POST', '/v1/posts', options)).status).toBe(500);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM posts').get()).toEqual({ n: 0 });
    expect(e.repo.getMedia(key)?.post_id).toBeNull();
    save.mockRestore();
    expect((await e.req('POST', '/v1/posts', options)).status).toBe(200);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM posts').get()).toEqual({ n: 1 });
  });

  it('commits a comment and its retry response atomically', async () => {
    e = setup();
    const a = await e.login('alice');
    const post = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'hello' } });
    const options = { token: a.token, headers: { 'idempotency-key': 'comment-1' }, body: { body: 'reply' } };
    const route = `/v1/posts/${post.json.id}/comments`;
    const save = vi.spyOn(e.repo, 'saveRequestKey').mockImplementationOnce(() => { throw new Error('disk failed'); });
    expect((await e.req('POST', route, options)).status).toBe(500);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM comments').get()).toEqual({ n: 0 });
    save.mockRestore();
    const first = await e.req('POST', route, options);
    expect(first.status).toBe(200);
    expect((await e.req('POST', route, options)).json.id).toBe(first.json.id);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM comments').get()).toEqual({ n: 1 });
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
