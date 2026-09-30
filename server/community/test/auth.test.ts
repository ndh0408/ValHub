import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { hashUserId, signSession } from '../src/crypto.js';
import { parseUserinfo } from '../src/riot.js';
import { expectError, PEPPER, SECRET, setup, type Env } from './helpers.js';

const CARD = '9fb348bc-41a0-91ad-8a3e-818035c4e561';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

describe('POST /v1/auth/riot', () => {
  it('verifies the token with Riot and issues a 30-day session', async () => {
    const res = await e.req('POST', '/v1/auth/riot', {
      body: { accessToken: 'good-alice', region: 'ap', cardId: CARD.toUpperCase(), rankTier: 17 },
    });
    expect(res.status).toBe(200);
    expect(res.headers.get('content-type')).toBe('application/json; charset=utf-8');
    expect(e.riotTokens).toEqual(['good-alice']);

    const expectedId = hashUserId(PEPPER, 'puuid-alice');
    expect(expectedId).toMatch(/^[0-9a-f]{32}$/);
    expect(res.json.user).toEqual({
      id: expectedId,
      gameName: 'Player alice',
      tagLine: 'VN1',
      cardId: CARD,
      rankTier: 17,
      region: 'ap',
      country: null,
      language: null,
    });
    expect(res.json.expiresAt).toBe(new Date(e.clock.t + 30 * 86400_000).toISOString());
    expect(res.json.token.split('.')).toHaveLength(3);

    const me = await e.req('GET', '/v1/me', { token: res.json.token });
    expect(me.status).toBe(200);
    expect(me.json.id).toBe(expectedId);
  });

  it('never stores the raw PUUID or the Riot token', async () => {
    await e.login('alice');
    const dump = JSON.stringify(e.db.prepare('SELECT * FROM users').all());
    expect(dump).not.toContain('puuid-alice');
    expect(dump).not.toContain('good-alice');
  });

  it('refreshes the Riot ID and keeps card/rank when omitted', async () => {
    const first = await e.login('bob', { cardId: CARD, rankTier: 5 });
    const again = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-bob', region: 'eu' } });
    expect(again.status).toBe(200);
    expect(again.json.user).toMatchObject({ id: first.user.id, cardId: CARD, rankTier: 5, region: 'eu' });
    const cleared = await e.req('POST', '/v1/auth/riot', {
      body: { accessToken: 'good-bob', region: 'eu', cardId: null },
    });
    expect(cleared.json.user.cardId).toBeNull();
  });

  it('returns riot_rejected when Riot refuses the token', async () => {
    const res = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'expired', region: 'ap' } });
    expectError(res, 401, 'riot_rejected');
  });

  it('returns riot_unavailable (503) when Riot is unreachable', async () => {
    const res = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'down', region: 'ap' } });
    expectError(res, 503, 'riot_unavailable');
  });

  it.each([
    [{ region: 'ap' }],
    [{ accessToken: '', region: 'ap' }],
    [{ accessToken: 123, region: 'ap' }],
    [{ accessToken: 'good-x' }],
    [{ accessToken: 'good-x', region: 'vn' }],
    [{ accessToken: 'good-x', region: 'ap', rankTier: 28 }],
    [{ accessToken: 'good-x', region: 'ap', rankTier: 1.5 }],
    [{ accessToken: 'good-x', region: 'ap', rankTier: '5' }],
    [{ accessToken: 'good-x', region: 'ap', cardId: 'not-a-uuid' }],
  ])('rejects bad input %j without calling Riot', async (body) => {
    const res = await e.req('POST', '/v1/auth/riot', { body });
    expectError(res, 400, 'invalid_input');
    expect(e.riotTokens).toEqual([]);
  });

  it('rejects non-JSON and non-object bodies', async () => {
    expectError(await e.req('POST', '/v1/auth/riot', { body: '{oops' }), 400, 'invalid_input');
    expectError(await e.req('POST', '/v1/auth/riot', { body: '[1,2]' }), 400, 'invalid_input');
  });
});

describe('session tokens', () => {
  it('requires a token on /v1/me', async () => {
    expectError(await e.req('GET', '/v1/me'), 401, 'unauthorized');
    expectError(await e.req('GET', '/v1/me', { token: 'garbage' }), 401, 'unauthorized');
    expectError(
      await e.req('GET', '/v1/me', { headers: { authorization: 'Basic abc' } }),
      401,
      'unauthorized',
    );
  });

  it('rejects expired tokens', async () => {
    const { token } = await e.login('alice');
    e.clock.t += 29 * 86400_000;
    expect((await e.req('GET', '/v1/me', { token })).status).toBe(200);
    e.clock.t += 2 * 86400_000;
    expectError(await e.req('GET', '/v1/me', { token }), 401, 'unauthorized');
  });

  it('rejects tampered or foreign-signed tokens', async () => {
    const { token, user } = await e.login('alice');
    const [h, , s] = token.split('.');
    const forgedPayload = Buffer.from(
      JSON.stringify({ sub: 'f'.repeat(32), name: 'x', tag: 'y', iat: 1, exp: 9999999999 }),
    ).toString('base64url');
    expectError(await e.req('GET', '/v1/me', { token: `${h}.${forgedPayload}.${s}` }), 401, 'unauthorized');

    const now = Math.floor(e.clock.t / 1000);
    const other = signSession('another-secret-another-secret-12345', {
      sub: user.id,
      name: '',
      tag: '',
      iat: now,
      exp: now + 3600,
    });
    expectError(await e.req('GET', '/v1/me', { token: other }), 401, 'unauthorized');

    // A valid signature for a user that does not exist.
    const ghost = signSession(SECRET, { sub: 'a'.repeat(32), name: '', tag: '', iat: now, exp: now + 3600 });
    expectError(await e.req('GET', '/v1/me', { token: ghost }), 401, 'unauthorized');
  });
});

describe('PATCH /v1/me', () => {
  it('updates card, rank and region', async () => {
    const { token } = await e.login('alice', { rankTier: 3 });
    const res = await e.req('PATCH', '/v1/me', { token, body: { cardId: CARD, rankTier: 20, region: 'kr' } });
    expect(res.status).toBe(200);
    expect(res.json).toMatchObject({ cardId: CARD, rankTier: 20, region: 'kr' });
    const partial = await e.req('PATCH', '/v1/me', { token, body: { rankTier: null } });
    expect(partial.json).toMatchObject({ cardId: CARD, rankTier: null, region: 'kr' });
  });

  it('validates fields', async () => {
    const { token } = await e.login('alice');
    expectError(await e.req('PATCH', '/v1/me', { token, body: { region: 'mars' } }), 400, 'invalid_input');
    expectError(await e.req('PATCH', '/v1/me', { token, body: { region: null } }), 400, 'invalid_input');
    expectError(await e.req('PATCH', '/v1/me', { token, body: { rankTier: -1 } }), 400, 'invalid_input');
    expectError(await e.req('PATCH', '/v1/me', { body: { rankTier: 1 } }), 401, 'unauthorized');
  });
});

describe('parseUserinfo', () => {
  it('parses defensively', () => {
    expect(parseUserinfo('<html>cloudflare</html>')).toEqual({ ok: false });
    expect(parseUserinfo('null')).toEqual({ ok: false });
    expect(parseUserinfo('{"acct":{"game_name":"A"}}')).toEqual({ ok: false });
    expect(parseUserinfo('{"sub":"ABC-1","acct":null}')).toEqual({ ok: false, reason: 'unavailable' });
    expect(parseUserinfo('{"sub":"abc","acct":{"game_name":"KAYN","tag_line":"04082"}}')).toEqual({
      ok: true,
      puuid: 'abc',
      gameName: 'KAYN',
      tagLine: '04082',
      country: null,
    });
  });
});
