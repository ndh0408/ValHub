import { afterEach, describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';
import { JPEG, setup, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

async function uploadJpeg(token: string) {
  const up = await e.req('POST', '/v1/media', { token, raw: JPEG, headers: { 'content-type': 'image/jpeg' } });
  expect(up.status).toBe(200);
  return up.json as { key: string; url: string };
}

describe('CS-01: media is cacheable on devices but never at the CDN edge', () => {
  it('media 200 keeps the 1-year device cache and forbids the Cloudflare edge from storing it', async () => {
    e = setup();
    const { token } = await e.login();
    const { key } = await uploadJpeg(token);
    const res = await e.req('GET', `/v1/media/${key}`);
    expect(res.status).toBe(200);
    expect(res.headers.get('cache-control')).toBe('public, max-age=31536000, immutable');
    expect(res.headers.get('cloudflare-cdn-cache-control')).toBe('no-store');
  });

  it('a 304 revalidation repeats both headers', async () => {
    e = setup();
    const { token } = await e.login();
    const { key } = await uploadJpeg(token);
    const first = await e.req('GET', `/v1/media/${key}`);
    const etag = first.headers.get('etag')!;
    const res = await e.req('GET', `/v1/media/${key}`, { headers: { 'if-none-match': etag } });
    expect(res.status).toBe(304);
    expect(res.headers.get('cache-control')).toBe('public, max-age=31536000, immutable');
    expect(res.headers.get('cloudflare-cdn-cache-control')).toBe('no-store');
  });

  it('the edge lifetime is configurable (short max-age instead of no-store)', async () => {
    e = setup({ tuning: { mediaEdgeCacheSeconds: 60 } });
    const { token } = await e.login();
    const { key } = await uploadJpeg(token);
    const res = await e.req('GET', `/v1/media/${key}`);
    expect(res.headers.get('cloudflare-cdn-cache-control')).toBe('max-age=60');
    expect(res.headers.get('cache-control')).toContain('max-age=31536000');
  });

  it('MEDIA_EDGE_CACHE_SECONDS is read from the environment (default 0)', () => {
    const base = { SESSION_SECRET: 'x'.repeat(32), PEPPER: 'y'.repeat(32) };
    expect(loadConfig(base).mediaEdgeCacheSeconds).toBe(0);
    expect(loadConfig({ ...base, MEDIA_EDGE_CACHE_SECONDS: '30' }).mediaEdgeCacheSeconds).toBe(30);
    expect(() => loadConfig({ ...base, MEDIA_EDGE_CACHE_SECONDS: '-1' })).toThrow(/MEDIA_EDGE_CACHE_SECONDS/);
  });

  it('a missing, deleted or quarantined media file answers 404 with no-store (and no edge header)', async () => {
    e = setup();
    const { token } = await e.login();
    const missing = await e.req('GET', '/v1/media/u/' + 'a'.repeat(32) + '/' + 'b'.repeat(32) + '.jpg');
    expect(missing.status).toBe(404);
    expect(missing.headers.get('cache-control')).toBe('no-store');

    const { key } = await uploadJpeg(token);
    e.repo.setMediaQuarantined([key], e.clock.t);
    const hidden = await e.req('GET', `/v1/media/${key}`);
    expect(hidden.status).toBe(404);
    expect(hidden.headers.get('cache-control')).toBe('no-store');
    expect(hidden.headers.get('cloudflare-cdn-cache-control')).toBeNull();

    // A key that does not even look like a media key.
    const junk = await e.req('GET', '/v1/media/whatever.jpg');
    expect(junk.status).toBe(404);
    expect(junk.headers.get('cache-control')).toBe('no-store');
  });
});

describe('CS-01/CS-36: every error and every JSON answer is no-store', () => {
  it('covers 400, 401, 403, 404 and 429', async () => {
    e = setup();
    const a = await e.login('alice');
    const b = await e.login('bob');

    const unauth = await e.req('GET', '/v1/lfg/mine');
    expect(unauth.status).toBe(401);
    expect(unauth.headers.get('cache-control')).toBe('no-store');

    const badJson = await e.req('POST', '/v1/reports', { token: a.token, raw: '{nope', headers: { 'content-type': 'application/json' } });
    expect(badJson.status).toBe(400);
    expect(badJson.headers.get('cache-control')).toBe('no-store');

    const route = await e.req('GET', '/v1/nothing-here');
    expect(route.status).toBe(404);
    expect(route.headers.get('cache-control')).toBe('no-store');

    const post = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'hello there' } });
    expect(post.status).toBe(200);
    const forbidden = await e.req('DELETE', `/v1/posts/${post.json.id}`, { token: b.token });
    expect(forbidden.status).toBe(403);
    expect(forbidden.headers.get('cache-control')).toBe('no-store');

    let limited = forbidden;
    for (let i = 0; i < 40 && limited.status !== 429; i++) {
      limited = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: `again ${i}` } });
    }
    expect(limited.status).toBe(429);
    expect(limited.headers.get('cache-control')).toBe('no-store');
    expect(limited.headers.get('retry-after')).toMatch(/^\d+$/);
  });

  it('authenticated and anonymous JSON, 204 and healthz are no-store', async () => {
    e = setup();
    const a = await e.login('alice');
    for (const [method, path, token] of [
      ['GET', '/v1/me', a.token],
      ['GET', '/v1/posts', undefined],
      ['GET', '/v1/skins/top', undefined],
      ['GET', '/healthz', undefined],
      ['OPTIONS', '/v1/posts', undefined],
    ] as const) {
      const res = await e.req(method, path, { token });
      expect(res.headers.get('cache-control'), `${method} ${path}`).toBe('no-store');
    }
  });

  it('a 500 is no-store too', async () => {
    e = setup();
    e.repo.ping = () => {
      throw new Error('disk gone');
    };
    const res = await e.req('GET', '/healthz');
    expect(res.status).toBe(500);
    expect(res.headers.get('cache-control')).toBe('no-store');
  });
});
