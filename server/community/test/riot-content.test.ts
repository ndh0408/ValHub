import { afterEach, describe, expect, it, vi } from 'vitest';
import { extractUuids, StaticCatalog, ValorantContentCatalog } from '../src/content.js';
import { classifyUserinfoResponse, fetchRiotUserinfo, parseRetryAfterSeconds } from '../src/riot.js';
import { expectError, setup, SKIN_A, SKIN_B, SKIN_C, WEAPON_1, WEAPON_2, type Env } from './helpers.js';

let e: Env | undefined;
afterEach(() => {
  e?.close();
  e = undefined;
  vi.unstubAllGlobals();
});

const GOOD = '{"sub":"abc","country":"vnm","acct":{"game_name":"KAYN","tag_line":"04082"}}';

describe('classifyUserinfoResponse', () => {
  it('200 with an identity is ok', () => {
    expect(classifyUserinfoResponse(200, GOOD)).toMatchObject({ ok: true, puuid: 'abc', gameName: 'KAYN', country: 'VN' });
  });

  it.each([
    ['400 JSON', 400, '{"error":"invalid_request"}'],
    ['401 JSON', 401, '{"error":"invalid_token"}'],
    ['401 empty', 401, ''],
    ['403 JSON', 403, '{"error":"forbidden"}'],
  ])('%s → rejected', (_n, status, body) => {
    expect(classifyUserinfoResponse(status, body)).toEqual({ ok: false, reason: 'rejected' });
  });

  it.each([
    ['429', 429, '{"error":"rate limited"}'],
    ['500', 500, ''],
    ['502 HTML', 502, '<html>Bad gateway</html>'],
    ['503', 503, 'Service Unavailable'],
    ['504', 504, ''],
    ['408', 408, ''],
    ['404', 404, ''],
    ['302', 302, ''],
    ['403 Cloudflare HTML', 403, '<!DOCTYPE html><html>Attention Required! | Cloudflare</html>'],
    ['401 HTML', 401, '  <html>login</html>'],
    ['200 HTML', 200, '<html>challenge</html>'],
    ['200 empty', 200, ''],
    ['200 JSON without sub', 200, '{"acct":{"game_name":"X"}}'],
    ['200 non-object', 200, '[]'],
  ])('%s → unavailable', (_n, status, body) => {
    expect(classifyUserinfoResponse(status, body)).toEqual({ ok: false, reason: 'unavailable' });
  });

  it('carries Retry-After (seconds, clamped)', () => {
    expect(classifyUserinfoResponse(429, '', '7')).toEqual({ ok: false, reason: 'unavailable', retryAfter: 7 });
    expect(classifyUserinfoResponse(503, '', '9999')).toEqual({ ok: false, reason: 'unavailable', retryAfter: 300 });
    expect(classifyUserinfoResponse(429, '', 'Wed, 21 Oct 2026 07:28:00 GMT')).toEqual({ ok: false, reason: 'unavailable' });
    expect(parseRetryAfterSeconds('0')).toBeUndefined();
    expect(parseRetryAfterSeconds('-3')).toBeUndefined();
    expect(parseRetryAfterSeconds('1.2')).toBe(2);
    expect(parseRetryAfterSeconds(null)).toBeUndefined();
  });
});

describe('fetchRiotUserinfo (network stubbed)', () => {
  const stub = (impl: () => Promise<Response>) => vi.stubGlobal('fetch', vi.fn(impl));

  it('maps every failure mode', async () => {
    stub(async () => new Response(GOOD, { status: 200 }));
    expect(await fetchRiotUserinfo('tok')).toMatchObject({ ok: true, puuid: 'abc' });
    stub(async () => new Response('{"error":"invalid_token"}', { status: 401 }));
    expect(await fetchRiotUserinfo('tok')).toEqual({ ok: false, reason: 'rejected' });
    stub(async () => new Response('', { status: 429, headers: { 'retry-after': '12' } }));
    expect(await fetchRiotUserinfo('tok')).toEqual({ ok: false, reason: 'unavailable', retryAfter: 12 });
    stub(async () => new Response('<html>', { status: 403 }));
    expect(await fetchRiotUserinfo('tok')).toEqual({ ok: false, reason: 'unavailable' });
    stub(async () => {
      throw new TypeError('fetch failed');
    });
    expect(await fetchRiotUserinfo('tok')).toEqual({ ok: false, reason: 'unavailable' });
    stub(async () => {
      throw new DOMException('The operation was aborted due to timeout', 'TimeoutError');
    });
    expect(await fetchRiotUserinfo('tok')).toEqual({ ok: false, reason: 'unavailable' });
  });

  it('sends the token only in the Authorization header', async () => {
    const f = vi.fn(async (..._a: unknown[]) => new Response(GOOD, { status: 200 }));
    vi.stubGlobal('fetch', f);
    await fetchRiotUserinfo('secret-token');
    const [url, init] = f.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://auth.riotgames.com/userinfo');
    expect(url).not.toContain('secret-token');
    expect((init.headers as Record<string, string>).Authorization).toBe('Bearer secret-token');
  });
});

describe('POST /v1/auth/riot error mapping', () => {
  it('Riot unavailable → 503 riot_unavailable (with Retry-After), Riot refusal → 401 riot_rejected', async () => {
    e = setup({ riot: async () => ({ ok: false, reason: 'unavailable', retryAfter: 30 }) });
    const res = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 't', region: 'ap' } });
    expectError(res, 503, 'riot_unavailable');
    expect(res.headers.get('retry-after')).toBe('30');
    expect(res.json.error.retryAfter).toBe(30);
    expect(res.json.error.message).toContain('Riot');
    e.close();

    e = setup({ riot: async () => ({ ok: false, reason: 'unavailable' }) });
    const noRetry = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 't', region: 'ap' } });
    expectError(noRetry, 503, 'riot_unavailable');
    expect(noRetry.headers.get('retry-after')).toBeNull();
    e.close();

    e = setup({ riot: async () => ({ ok: false, reason: 'rejected' }) });
    expectError(await e.req('POST', '/v1/auth/riot', { body: { accessToken: 't', region: 'ap' } }), 401, 'riot_rejected');
    e.close();

    // Stubs that predate `reason` (or throw) keep working: no reason = rejected, a throw = unavailable.
    e = setup({ riot: async () => ({ ok: false }) });
    expectError(await e.req('POST', '/v1/auth/riot', { body: { accessToken: 't', region: 'ap' } }), 401, 'riot_rejected');
    e.close();
    e = setup({ riot: async () => { throw new Error('boom'); } });
    expectError(await e.req('POST', '/v1/auth/riot', { body: { accessToken: 't', region: 'ap' } }), 503, 'riot_unavailable');
  });

  it('never stores a user when Riot is unavailable', async () => {
    e = setup({ riot: async () => ({ ok: false, reason: 'unavailable' }) });
    await e.req('POST', '/v1/auth/riot', { body: { accessToken: 't', region: 'ap' } });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM users').get()).toEqual({ n: 0 });
  });
});

describe('content catalog', () => {
  const U = (n: number) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
  const skins = { status: 200, data: [{ uuid: U(1), levels: [{ uuid: U(2) }, { uuid: U(3) }], chromas: [{ uuid: U(4) }] }, { uuid: U(5) }] };
  const weapons = { status: 200, data: [{ uuid: U(10) }] };
  const agents = { status: 200, data: [{ uuid: U(20) }] };

  function catalog(fetchImpl: (url: string) => Promise<Response>, extra: Record<string, unknown> = {}) {
    const clock = { t: 1_000_000 };
    const calls: string[] = [];
    const c = new ValorantContentCatalog({
      fetchFn: (async (url: string) => {
        calls.push(new URL(url).pathname + new URL(url).search);
        return fetchImpl(url);
      }) as typeof fetch,
      now: () => clock.t,
      ...extra,
    });
    return { c, clock, calls };
  }
  const ok = (body: unknown) => new Response(JSON.stringify(body), { status: 200 });
  const byUrl = (url: string) => (url.includes('/weapons/skins') ? ok(skins) : url.includes('/agents') ? ok(agents) : ok(weapons));

  it('extracts skin, level and chroma uuids defensively', () => {
    expect([...extractUuids(skins)].sort()).toEqual([U(1), U(2), U(3), U(4), U(5)]);
    expect(extractUuids({ data: [{ uuid: 'NOT-A-UUID', levels: [null, 5, { uuid: 7 }] }, null, 'x'] }).size).toBe(0);
    expect(extractUuids({ data: [{ uuid: U(1).toUpperCase() }] }).has(U(1))).toBe(true);
    for (const junk of [null, undefined, 'x', [], {}, { data: 'no' }]) expect(extractUuids(junk).size).toBe(0);
  });

  it('knows real ids, rejects made-up ones, per kind', async () => {
    const { c } = catalog(async (u) => byUrl(u));
    // Nothing loaded yet: everything is accepted, and the catalog loads in the background.
    expect(await c.isKnown('skin', U(99))).toBe(true);
    await c.warm();
    expect(await c.isKnown('skin', U(1))).toBe(true);
    expect(await c.isKnown('skin', U(3))).toBe(true); // level
    expect(await c.isKnown('skin', U(4))).toBe(true); // chroma
    expect(await c.isKnown('skin', U(1).toUpperCase())).toBe(true);
    expect(await c.isKnown('skin', U(99))).toBe(false);
    expect(await c.isKnown('weapon', U(10))).toBe(true);
    expect(await c.isKnown('weapon', U(1))).toBe(false); // a skin is not a weapon
    expect(await c.isKnown('agent', U(20))).toBe(true);
    expect(await c.isKnown('agent', U(21))).toBe(false);
  });

  it('accepts everything while it has nothing (outage at start), and backs off before retrying', async () => {
    let up = false;
    const { c, clock, calls } = catalog(async (u) => (up ? byUrl(u) : new Response('down', { status: 503 })));
    expect(await c.isKnown('skin', U(99))).toBe(true);
    expect(await c.isKnown('skin', U(98))).toBe(true);
    await c.warm(['skin']); // (the failed load)
    expect(calls).toHaveLength(1); // single-flight, then the backoff window
    expect(await c.isKnown('skin', U(97))).toBe(true);
    expect(calls).toHaveLength(1);
    up = true;
    clock.t += 6 * 60_000;
    await c.warm(['skin']); // recovered
    expect(await c.isKnown('skin', U(99))).toBe(false); // now it knows
    expect(await c.isKnown('skin', U(1))).toBe(true);
  });

  it('keeps using the stale cache during an outage after the 24 h TTL', async () => {
    let up = true;
    const { c, clock } = catalog(async (u) => (up ? byUrl(u) : new Response('down', { status: 500 })));
    await c.warm(['skin']);
    expect(await c.isKnown('skin', U(1))).toBe(true);
    up = false;
    clock.t += 25 * 60 * 60_000;
    expect(await c.isKnown('skin', U(1))).toBe(true);
    expect(await c.isKnown('skin', U(99))).toBe(false); // still validating with the stale set
  });

  it('refreshes after 24 h and picks up new content; an unknown id re-checks at most once per 10 minutes', async () => {
    let version = 1;
    const { c, clock, calls } = catalog(async (u) => {
      if (u.includes('/weapons/skins')) return ok(version === 1 ? skins : { data: [{ uuid: U(1) }, { uuid: U(50) }] });
      return byUrl(u);
    });
    await c.warm(['skin']);
    expect(await c.isKnown('skin', U(50))).toBe(false); // new content not there yet
    expect(calls.filter((x) => x.includes('/weapons/skins'))).toHaveLength(1);
    version = 2; // a skin released meanwhile
    expect(await c.isKnown('skin', U(50))).toBe(false); // within 10 min: no re-fetch
    expect(calls.filter((x) => x.includes('/weapons/skins'))).toHaveLength(1);
    clock.t += 11 * 60_000;
    expect(await c.isKnown('skin', U(50))).toBe(true); // unknown id triggered one re-fetch
    expect(calls.filter((x) => x.includes('/weapons/skins'))).toHaveLength(2);
    for (let i = 0; i < 5; i++) expect(await c.isKnown('skin', U(60 + i))).toBe(false);
    expect(calls.filter((x) => x.includes('/weapons/skins'))).toHaveLength(2); // no hammering valorant-api
  });

  it('single-flights concurrent refreshes and ignores empty / malformed responses', async () => {
    let n = 0;
    const { c } = catalog(async (u) => {
      n++;
      await new Promise((r) => setTimeout(r, 5));
      return byUrl(u);
    });
    await Promise.all(Array.from({ length: 10 }, () => c.isKnown('weapon', U(10))));
    expect(n).toBe(1);
    const empty = catalog(async () => ok({ status: 200, data: [] }));
    expect(await empty.c.isKnown('skin', U(99))).toBe(true); // empty catalog would reject everything: ignored
    const bad = catalog(async () => new Response('<html>', { status: 200 }));
    expect(await bad.c.isKnown('skin', U(99))).toBe(true);
    const thrower = catalog(async () => {
      throw new TypeError('fetch failed');
    });
    expect(await thrower.c.isKnown('agent', U(99))).toBe(true);
  });

  it('StaticCatalog (tests) validates configured kinds only', async () => {
    const c = new StaticCatalog({ skin: [SKIN_A.toUpperCase()] });
    expect(await c.isKnown('skin', SKIN_A)).toBe(true);
    expect(await c.isKnown('skin', SKIN_B)).toBe(false);
    expect(await c.isKnown('weapon', WEAPON_1)).toBe(true); // no set configured → not checked
  });
});

describe('skin / weapon / agent ids are validated against the catalog', () => {
  const AGENT = 'add6443a-41bd-e414-f6ad-e58d267f4e95';
  const catalog = new StaticCatalog({ skin: [SKIN_A, SKIN_B], weapon: [WEAPON_1], agent: [AGENT] });

  it('votes and reviews', async () => {
    e = setup({ content: catalog });
    const { token } = await e.login('alice');
    const vote = (skin: string, weapon = WEAPON_1) => e!.req('PUT', `/v1/skins/${skin}/vote`, { token, body: { weaponUuid: weapon } });
    expect((await vote(SKIN_A)).status).toBe(200);
    const bad = await vote(SKIN_C);
    expectError(bad, 400, 'invalid_input');
    expect(bad.json.error.message).toContain('skinUuid');
    expectError(await vote(SKIN_A, WEAPON_2), 400, 'invalid_input');
    const review = (skin: string, weapon = WEAPON_1) => e!.req('PUT', `/v1/skins/${skin}/review`, { token, body: { weaponUuid: weapon, rating: 4 } });
    expect((await review(SKIN_B)).status).toBe(200);
    expectError(await review(SKIN_C), 400, 'invalid_input');
    expectError(await review(SKIN_B, WEAPON_2), 400, 'invalid_input');
    // Nothing was written for the rejected ones; deleting / reading never needs the catalog.
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM skin_votes').get()).toEqual({ n: 1 });
    expect((await e.req('DELETE', `/v1/skins/${SKIN_C}/vote`, { token })).status).toBe(200);
    expect((await e.req('GET', `/v1/skins/${SKIN_C}/summary`)).status).toBe(200);
  });

  it('shared store / Night Market offers and LFG agents', async () => {
    e = setup({ content: catalog });
    const { token } = await e.login('alice');
    const store = (skin: string) => e!.req('POST', '/v1/posts', { token, body: { kind: 'store', payload: { date: '2026-09-01', offers: [{ skinUuid: skin, cost: 875 }] } } });
    expect((await store(SKIN_A)).status).toBe(200);
    const bad = await store(SKIN_C);
    expectError(bad, 400, 'invalid_input');
    expect(bad.json.error.message).toContain('offers[0].skinUuid');
    const lfg = (agents: string[]) => e!.req('POST', '/v1/lfg', { token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2, agents } });
    expect((await lfg([AGENT])).status).toBe(200);
    expectError(await lfg(['00000000-0000-4000-8000-000000000001']), 400, 'invalid_input');
    // A failing catalog never blocks users (fails open).
    e.close();
    e = setup({ content: { isKnown: async () => { throw new Error('boom'); } } });
    const again = await e.login('bob');
    expect((await e.req('PUT', `/v1/skins/${SKIN_C}/vote`, { token: again.token, body: { weaponUuid: WEAPON_2 } })).status).toBe(200);
  });

  it('without a catalog (default) every well-formed uuid is accepted', async () => {
    e = setup();
    const { token } = await e.login('alice');
    expect((await e.req('PUT', `/v1/skins/${SKIN_C}/vote`, { token, body: { weaponUuid: WEAPON_2 } })).status).toBe(200);
  });
});
