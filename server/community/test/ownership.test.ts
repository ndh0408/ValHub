import { afterEach, describe, expect, it, vi } from 'vitest';
import { createRiotOwnership } from '../src/riot-ownership.js';
import { setup, SKIN_A, SKIN_B, WEAPON_1, expectError, type Env } from './helpers.js';

let e: Env | undefined;
afterEach(() => { e?.close(); e = undefined; });
const body = {weaponUuid: WEAPON_1, rating: 5, body: 'nice'};
const path = `/v1/skins/${SKIN_A}/review`;

describe('server identity-bound owner-only reviews', () => {
  it('rejects a token belonging to another user before inventory lookup', async () => {
    const inventory = vi.fn(async () => 'owned' as const);
    e = setup({ownership: inventory});
    const alice = await e.login('alice');
    const res = await e.req('PUT', path, {token: alice.token, body: {...body, accessToken: 'good-bob', puuid: 'puuid-alice', owned: true}});
    expectError(res, 403, 'forbidden'); expect(inventory).not.toHaveBeenCalled();
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.ratingCount).toBe(0);
  });
  it('missing proof cannot be replaced by client ownership or PUUID', async () => {
    e = setup(); const a = await e.login('alice');
    expectError(await e.req('PUT', path, {token: a.token, omitOwnershipProof: true, body: {...body, owned: true, puuid: 'puuid-alice'}}), 400, 'invalid_input');
  });
  it.each(['not_owned', 'unavailable', 'rejected'] as const)('fails closed on %s', async (result) => {
    e = setup({ownership: async () => result}); const a = await e.login('alice');
    const res = await e.req('PUT', path, {token: a.token, body});
    expect(res.status).toBe(result === 'not_owned' ? 403 : result === 'rejected' ? 401 : 503);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.ratingCount).toBe(0);
  });
  it('an inventory outage during edit preserves the original review', async () => {
    let owned = true;
    e = setup({established: true, ownership: async () => owned ? 'owned' : 'unavailable'}); const a = await e.login('alice');
    expect((await e.req('PUT', path, {token: a.token, body})).status).toBe(200);
    owned = false;
    expect((await e.req('PUT', path, {token: a.token, body: {...body, rating: 1}})).status).toBe(503);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.ratingAvg).toBe(5);
    expect((await e.req('DELETE', path, {token: a.token})).status).toBe(204);
  });
  it('revalidates a revoked session after pending Riot verification', async () => {
    let release!: () => void; let entered!: () => void;
    const waiting = new Promise<void>(r => entered = r);
    const pending = new Promise<void>(r => release = r);
    e = setup({ownership: async () => { entered(); await pending; return 'owned'; }});
    const a = await e.login('alice');
    const write = e.req('PUT', path, {token: a.token, body});
    await waiting;
    expect((await e.req('POST', '/v1/auth/logout', {token: a.token, body: {}})).status).toBe(204);
    release();
    expectError(await write, 401, 'unauthorized');
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.ratingCount).toBe(0);
  });
});

describe('bounded Riot inventory adapter', () => {
  const level = '99999999-9999-4999-8999-999999999999';
  const type = 'e7c63390-eda7-46e0-bb7a-a6abdacd2433';
  const request = {accessToken: 'fixture-token', puuid: 'verified-subject', region: 'br', skinUuid: SKIN_A,
    resolveSkin: (id: string) => id === SKIN_A || id === level ? {skinUuid: SKIN_A, weaponUuid: WEAPON_1} : null};
  const json = (value: unknown) => new Response(JSON.stringify(value), {status: 200});
  it('queries a fixed shard host with the verified subject and canonicalizes levels', async () => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(json({entitlements_token:'ent'}))
      .mockResolvedValueOnce(json({Subject: request.puuid, ItemTypeID: type, Entitlements:[{TypeID:type, ItemID:level}]}));
    expect(await createRiotOwnership(fetcher)(request)).toBe('owned');
    expect(fetcher.mock.calls[1]![0]).toBe(`https://pd.na.a.pvp.net/store/v1/entitlements/verified-subject/${type}`);
    expect(fetcher.mock.calls[1]![1]?.redirect).toBe('manual');
  });
  it.each([
    '<html>blocked</html>',
    JSON.stringify({Subject:'other', Entitlements:[{ItemID:level}]}),
    JSON.stringify({Subject:42, Entitlements:[{ItemID:level}]}),
    JSON.stringify({ItemTypeID:'bad', Entitlements:[{ItemID:level}]}),
    JSON.stringify({Entitlements:'bad'}),
  ])('rejects malformed or mismatched payload %s', async (text) => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(json({entitlements_token:'ent'}))
      .mockResolvedValueOnce(new Response(text));
    expect(await createRiotOwnership(fetcher)(request)).toBe('unavailable');
  });
  it('unknown region or catalog sends no token anywhere', async () => {
    const fetcher = vi.fn<typeof fetch>(); const verify = createRiotOwnership(fetcher);
    expect(await verify({...request, region:'evil.test'})).toBe('unavailable');
    expect(await verify({...request, skinUuid:SKIN_B})).toBe('unavailable');
    expect(fetcher).not.toHaveBeenCalled();
  });
  it('oversized streamed inventory fails closed', async () => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(json({entitlements_token:'ent'}))
      .mockResolvedValueOnce(new Response(' '.repeat(2*1024*1024+1)));
    expect(await createRiotOwnership(fetcher)(request)).toBe('unavailable');
  });
  it('a valid empty inventory does not grant ownership', async () => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(json({entitlements_token:'ent'}))
      .mockResolvedValueOnce(json({ItemTypeID:type, Entitlements:[]}));
    expect(await createRiotOwnership(fetcher)(request)).toBe('not_owned');
  });
  it('redirects are never followed with a Riot credential', async () => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(new Response('',{status:302,headers:{location:'https://evil.test'}}));
    expect(await createRiotOwnership(fetcher)(request)).toBe('unavailable');
    expect(fetcher).toHaveBeenCalledTimes(1);
    expect(fetcher.mock.calls[0]![1]?.redirect).toBe('manual');
  });
  it('diagnostics contain only fixed operations/statuses, never secrets or inventory', async () => {
    const log = vi.fn();
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(json({entitlements_token:'secret-entitlement'}))
      .mockResolvedValueOnce(new Response('private response body', {status:403}));
    expect(await createRiotOwnership(fetcher, log)(request)).toBe('unavailable');
    expect(log.mock.calls).toEqual([[{operation:'entitlements',status:200}], [{operation:'inventory',status:403}]]);
    expect(JSON.stringify(log.mock.calls)).not.toMatch(/fixture-token|secret-entitlement|verified-subject|private response/);
  });
  it('a failed diagnostic sink cannot authorize or disrupt a valid ownership decision', async () => {
    const fetcher = vi.fn<typeof fetch>().mockResolvedValueOnce(json({entitlements_token:'ent'}))
      .mockResolvedValueOnce(json({Entitlements:[]}));
    expect(await createRiotOwnership(fetcher, () => { throw new Error('sink failed'); })(request)).toBe('not_owned');
  });
  it('network diagnostics never expose exception contents', async () => {
    const log = vi.fn(); const fetcher = vi.fn<typeof fetch>().mockRejectedValue(new Error('fixture-token'));
    expect(await createRiotOwnership(fetcher, log)(request)).toBe('unavailable');
    expect(log.mock.calls).toEqual([[{operation:'network'}]]);
  });
});
