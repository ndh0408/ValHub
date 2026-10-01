import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { expectError, setup, SKIN_A, SKIN_B, SKIN_C, WEAPON_1, WEAPON_2, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup({ established: true });
});
afterEach(() => e.close());

const vote = (token: string, skin: string, weapon = WEAPON_1) =>
  e.req('PUT', `/v1/skins/${skin}/vote`, { token, body: { weaponUuid: weapon } });

describe('skin votes', () => {
  it('is idempotent per user and supports unvote', async () => {
    const a = await e.login('a');
    const b = await e.login('b');
    expect((await vote(a.token, SKIN_A)).json).toEqual({ skinUuid: SKIN_A, votes: 1, voted: true });
    expect((await vote(a.token, SKIN_A)).json).toEqual({ skinUuid: SKIN_A, votes: 1, voted: true });
    expect((await vote(b.token, SKIN_A.toUpperCase())).json).toEqual({ skinUuid: SKIN_A, votes: 2, voted: true });

    const un = await e.req('DELETE', `/v1/skins/${SKIN_A}/vote`, { token: a.token });
    expect(un.json).toEqual({ skinUuid: SKIN_A, votes: 1, voted: false });
    const un2 = await e.req('DELETE', `/v1/skins/${SKIN_A}/vote`, { token: a.token });
    expect(un2.json).toEqual({ skinUuid: SKIN_A, votes: 1, voted: false });
  });

  it('ranks top skins (all time / week / per weapon) with voted flag', async () => {
    const users = await Promise.all(['a', 'b', 'c'].map((n) => e.login(n)));
    const [a, b, c] = users as [(typeof users)[0], (typeof users)[0], (typeof users)[0]];
    // Old votes: SKIN_A x3.
    for (const u of users) await vote(u.token, SKIN_A);
    e.clock.t += 8 * 86400_000;
    // Recent: SKIN_B x2 (weapon 2), SKIN_C x1.
    await vote(a.token, SKIN_B, WEAPON_2);
    await vote(b.token, SKIN_B, WEAPON_2);
    await vote(c.token, SKIN_C);

    const all = await e.req('GET', '/v1/skins/top', { token: a.token });
    expect(all.status).toBe(200);
    expect(all.json.items).toEqual([
      { rank: 1, skinUuid: SKIN_A, weaponUuid: WEAPON_1, votes: 3, voted: true, ratingAvg: null, ratingCount: 0, reviewCount: 0 },
      { rank: 2, skinUuid: SKIN_B, weaponUuid: WEAPON_2, votes: 2, voted: true, ratingAvg: null, ratingCount: 0, reviewCount: 0 },
      { rank: 3, skinUuid: SKIN_C, weaponUuid: WEAPON_1, votes: 1, voted: false, ratingAvg: null, ratingCount: 0, reviewCount: 0 },
    ]);

    const week = await e.req('GET', '/v1/skins/top?period=week');
    expect(week.json.items.map((i: any) => [i.skinUuid, i.votes, i.voted])).toEqual([
      [SKIN_B, 2, false],
      [SKIN_C, 1, false],
    ]);

    const w1 = await e.req('GET', `/v1/skins/top?weapon=${WEAPON_1}&limit=1`);
    expect(w1.json.items).toEqual([{ rank: 1, skinUuid: SKIN_A, weaponUuid: WEAPON_1, votes: 3, voted: false, ratingAvg: null, ratingCount: 0, reviewCount: 0 }]);
  });

  it('pins a skin to the weapon of its first vote', async () => {
    const a = await e.login('a');
    const b = await e.login('b');
    await vote(a.token, SKIN_A, WEAPON_1);
    await vote(b.token, SKIN_A, WEAPON_2);
    const top = await e.req('GET', `/v1/skins/top?weapon=${WEAPON_1}`);
    expect(top.json.items).toEqual([expect.objectContaining({ skinUuid: SKIN_A, votes: 2 })]);
    expect((await e.req('GET', `/v1/skins/top?weapon=${WEAPON_2}`)).json.items).toEqual([]);
  });

  it('returns counts for a list of ids', async () => {
    const a = await e.login('a');
    const b = await e.login('b');
    await vote(a.token, SKIN_A);
    await vote(b.token, SKIN_A);
    await vote(b.token, SKIN_B);
    const res = await e.req('GET', `/v1/skins/votes?ids=${SKIN_B},${SKIN_A},${SKIN_C},${SKIN_A}`, {
      token: a.token,
    });
    expect(res.json.items).toEqual([
      { skinUuid: SKIN_B, votes: 1, voted: false, ratingAvg: null, ratingCount: 0 },
      { skinUuid: SKIN_A, votes: 2, voted: true, ratingAvg: null, ratingCount: 0 },
      { skinUuid: SKIN_C, votes: 0, voted: false, ratingAvg: null, ratingCount: 0 },
    ]);
    const anon = await e.req('GET', `/v1/skins/votes?ids=${SKIN_A}`);
    expect(anon.json.items).toEqual([{ skinUuid: SKIN_A, votes: 2, voted: false, ratingAvg: null, ratingCount: 0 }]);
  });

  it('validates input', async () => {
    const { token } = await e.login('a');
    expectError(await vote(token, 'nope'), 400, 'invalid_input');
    expectError(await vote(token, SKIN_A, 'nope'), 400, 'invalid_input');
    expectError(await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token, body: {} }), 400, 'invalid_input');
    expectError(await vote('', SKIN_A), 401, 'unauthorized');
    expectError(await e.req('GET', '/v1/skins/top?period=month'), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/skins/top?limit=101'), 400, 'invalid_input');
    expect((await e.req('GET', '/v1/skins/top?limit=100')).status).toBe(200);
    expectError(await e.req('GET', '/v1/skins/top?weapon=x'), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/skins/votes'), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/skins/votes?ids=abc'), 400, 'invalid_input');
    const many = Array.from({ length: 51 }, (_, i) => `00000000-0000-4000-8000-${String(i).padStart(12, '0')}`);
    expectError(await e.req('GET', `/v1/skins/votes?ids=${many.join(',')}`), 400, 'invalid_input');
    expect((await e.req('GET', `/v1/skins/votes?ids=${many.slice(0, 50).join(',')}`)).status).toBe(200);
    // Invalid token on an auth-optional endpoint is still rejected.
    expectError(await e.req('GET', '/v1/skins/top', { token: 'bad' }), 401, 'unauthorized');
  });

  it('rate limits votes to 120 per hour', async () => {
    const { token } = await e.login('a');
    for (let i = 0; i < 60; i++) {
      await vote(token, SKIN_A);
      await e.req('DELETE', `/v1/skins/${SKIN_A}/vote`, { token });
    }
    const res = await vote(token, SKIN_A);
    expectError(res, 429, 'rate_limited');
    expect(res.json.error.retryAfter).toBeGreaterThan(0);
  });
});
