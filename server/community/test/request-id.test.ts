import { afterEach, describe, expect, it } from 'vitest';
import { setup, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

describe('request ids', () => {
  it('every response carries one, errors repeat it in the body and the access log records it', async () => {
    const logged: Array<{ route: string; requestId: string }> = [];
    e = setup({ logAccess: (entry) => logged.push(entry) });
    const ok = await e.req('GET', '/v1/skins/top');
    const id = ok.headers.get('x-request-id');
    expect(id).toMatch(/^[0-9a-f-]{36}$/);
    const missing = await e.req('GET', '/v1/no-such-route');
    expect(missing.status).toBe(404);
    const missingId = missing.headers.get('x-request-id');
    expect(missingId).not.toBe(id);
    expect(missing.json.error.requestId).toBe(missingId);
    expect(logged.map((l) => l.requestId)).toEqual([id, missingId]);
  });

  it("a client's own opaque id is kept; anything else is replaced", async () => {
    e = setup();
    const kept = await e.req('GET', '/v1/skins/top', { headers: { 'x-request-id': 'app-1f2e3d4c5b6a' } });
    expect(kept.headers.get('x-request-id')).toBe('app-1f2e3d4c5b6a');
    for (const bad of ['short', 'has space inside it', 'x'.repeat(80), '../../etc/passwd']) {
      const res = await e.req('GET', '/v1/skins/top', { headers: { 'x-request-id': bad } });
      expect(res.headers.get('x-request-id')).not.toBe(bad);
      expect(res.headers.get('x-request-id')).toMatch(/^[0-9a-f-]{36}$/);
    }
  });

  it('server errors log the id, never request details', async () => {
    e = setup();
    const { token } = await e.login();
    e.repo.topSkins = () => {
      throw new Error('boom');
    };
    const res = await e.req('GET', '/v1/skins/top', { token });
    expect(res.status).toBe(500);
    const id = res.headers.get('x-request-id')!;
    expect(res.json.error.requestId).toBe(id);
    expect(e.errors.some((m) => m.includes(`id=${id}`))).toBe(true);
    expect(e.errors.join('\n')).not.toContain(token);
  });
});
