import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { expectError, setup, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const post = (over: Record<string, unknown> = {}) => ({
  region: 'ap',
  mode: 'competitive',
  partyCode: 'AB12CD',
  slots: 2,
  note: '  cần 2 bạn duo, mic  ',
  ...over,
});

describe('LFG', () => {
  it('creates a post that expires after 30 minutes', async () => {
    const { token, user } = await e.login('alice', { rankTier: 12 });
    const res = await e.req('POST', '/v1/lfg', { token, body: post() });
    expect(res.status).toBe(200);
    expect(res.json).toMatchObject({
      id: expect.stringMatching(/^[0-9a-f-]{36}$/),
      author: { id: user.id, gameName: 'Player alice', rankTier: 12 },
      region: 'ap',
      mode: 'competitive',
      partyCode: 'AB12CD',
      slots: 2,
      rankTier: 12,
      note: 'cần 2 bạn duo, mic',
      createdAt: new Date(e.clock.t).toISOString(),
      expiresAt: new Date(e.clock.t + 30 * 60_000).toISOString(),
    });

    const list = await e.req('GET', '/v1/lfg?region=ap', { token });
    expect(list.json.items).toHaveLength(1);
    expect(list.json.nextCursor).toBeNull();

    e.clock.t += 30 * 60_000 + 1;
    const later = await e.req('GET', '/v1/lfg?region=ap', { token });
    expect(later.json.items).toEqual([]);
  });

  it('replaces the previous post of the same user', async () => {
    const { token } = await e.login('alice');
    const first = await e.req('POST', '/v1/lfg', { token, body: post() });
    e.clock.t += 1000;
    const second = await e.req('POST', '/v1/lfg', { token, body: post({ partyCode: 'ZZZZ99', rankTier: null }) });
    expect(second.json.rankTier).toBeNull();
    const list = await e.req('GET', '/v1/lfg', { token });
    expect(list.json.items.map((i: any) => i.id)).toEqual([second.json.id]);
    expect(list.json.items[0].id).not.toBe(first.json.id);
  });

  it('filters by region and mode, newest first, with cursor pagination', async () => {
    const users = await Promise.all(['a', 'b', 'c', 'd'].map((n) => e.login(n)));
    const specs = [
      { region: 'ap', mode: 'competitive' },
      { region: 'ap', mode: 'unrated' },
      { region: 'eu', mode: 'competitive' },
      { region: 'ap', mode: 'competitive' },
    ];
    for (let i = 0; i < users.length; i++) {
      e.clock.t += 1000;
      await e.req('POST', '/v1/lfg', { token: users[i]!.token, body: post(specs[i]) });
    }
    const t = users[0]!.token;
    const comp = await e.req('GET', '/v1/lfg?region=ap&mode=competitive', { token: t });
    expect(comp.json.items.map((i: any) => i.author.gameName)).toEqual(['Player d', 'Player a']);

    const p1 = await e.req('GET', '/v1/lfg?scope=global&limit=2', { token: t });
    expect(p1.json.items.map((i: any) => i.author.gameName)).toEqual(['Player d', 'Player c']);
    const p2 = await e.req('GET', `/v1/lfg?scope=global&limit=2&cursor=${p1.json.nextCursor}`, { token: t });
    expect(p2.json.items.map((i: any) => i.author.gameName)).toEqual(['Player b', 'Player a']);
    expect(p2.json.nextCursor).toBeNull();
  });

  it('validates input', async () => {
    const { token } = await e.login('alice');
    for (const bad of [
      post({ partyCode: 'ab12cd' }),
      post({ partyCode: 'AB12C' }),
      post({ partyCode: 'AB12CD7' }),
      post({ partyCode: 'AB-2CD' }),
      post({ slots: 0 }),
      post({ slots: 5 }),
      post({ mode: 'ranked' }),
      post({ region: 'vn' }),
      post({ note: 'x'.repeat(141) }),
      post({ rankTier: 99 }),
    ]) {
      expectError(await e.req('POST', '/v1/lfg', { token, body: bad }), 400, 'invalid_input');
    }
    expect((await e.req('POST', '/v1/lfg', { token, body: post({ note: 'é'.repeat(140) }) })).status).toBe(200);
    expectError(await e.req('GET', '/v1/lfg?mode=nope', { token }), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/lfg?limit=51', { token }), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/lfg?limit=0', { token }), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/lfg?cursor=!!', { token }), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/lfg?cursor=bm9wZQ', { token }), 400, 'invalid_input');
    expectError(await e.req('POST', '/v1/lfg', { body: post() }), 401, 'unauthorized');
  });

  it('only lets the author delete a post', async () => {
    const alice = await e.login('alice');
    const bob = await e.login('bob');
    const created = await e.req('POST', '/v1/lfg', { token: alice.token, body: post() });
    const id = created.json.id;
    expectError(await e.req('DELETE', `/v1/lfg/${id}`, { token: bob.token }), 403, 'forbidden');
    const del = await e.req('DELETE', `/v1/lfg/${id}`, { token: alice.token });
    expect(del.status).toBe(204);
    expect(del.bytes.length).toBe(0);
    expectError(await e.req('DELETE', `/v1/lfg/${id}`, { token: alice.token }), 404, 'not_found');
    expectError(await e.req('DELETE', '/v1/lfg/not-a-uuid', { token: alice.token }), 404, 'not_found');
  });

  it('rate limits to 6 posts per 10 minutes', async () => {
    const { token } = await e.login('alice');
    for (let i = 0; i < 6; i++) {
      expect((await e.req('POST', '/v1/lfg', { token, body: post() })).status).toBe(200);
    }
    const res = await e.req('POST', '/v1/lfg', { token, body: post() });
    expectError(res, 429, 'rate_limited');
    expect(Number(res.headers.get('retry-after'))).toBeGreaterThan(0);
  });
});
