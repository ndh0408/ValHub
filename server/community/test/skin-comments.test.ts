import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { StaticCatalog } from '../src/content.js';
import { expectError, setup, SKIN_A, SKIN_B, WEAPON_1, type Env } from './helpers.js';

let e: Env;
beforeEach(() => { e = setup({ established: true, ownership: async () => 'not_owned' }); });
afterEach(() => e.close());
const add = (token: string, body: unknown = 'Thảo luận về hiệu ứng', skin = SKIN_A,
  headers?: Record<string, string>) => e.req('POST', `/v1/skins/${skin}/comments`,
    { token, body: { body, rating: 5, userId: 'spoofed', owned: true }, headers });
const list = (skin = SKIN_A, query = '') => e.req('GET', `/v1/skins/${skin}/comments${query}`);

describe('plain skin discussion', () => {
  it('allows non-owners to comment, keeps public reading, never changes star aggregates', async () => {
    const a = await e.login('alice');
    const res = await add(a.token);
    expect(res.status).toBe(200);
    expect(res.json).toMatchObject({ skinUuid: SKIN_A, author: { id: a.user.id } });
    expect(res.json).not.toHaveProperty('rating');
    expect(res.json).not.toHaveProperty('postId');
    expect((await list()).json.items).toHaveLength(1);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json)
      .toMatchObject({ ratingAvg: null, ratingCount: 0, reviewCount: 0, votes: 0 });
    expect((await e.req('GET', '/v1/skins/top?scope=global&period=all&sort=rating')).json.items).toEqual([]);
    expect((await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: a.token,
      body: { weaponUuid: WEAPON_1, rating: 5 } })).status).toBe(403);
  });

  it('rejects unauthenticated writes and expired supplied read sessions', async () => {
    expectError(await add(''), 401, 'unauthorized');
    expectError(await e.req('GET', `/v1/skins/${SKIN_A}/comments`, { token: 'invalid' }), 401, 'unauthorized');
    expect((await list()).status).toBe(200);
  });

  it('enforces author identity for deletion; another user cannot delete', async () => {
    const [a, b] = await Promise.all([e.login('alice'), e.login('bob')]);
    const c = (await add(a.token)).json;
    expectError(await e.req('DELETE', `/v1/skin-comments/${c.id}`, { token: b.token }), 403, 'forbidden');
    expect((await list()).json.items[0].author.id).toBe(a.user.id);
    expect((await e.req('DELETE', `/v1/skin-comments/${c.id}`, { token: a.token })).status).toBe(204);
    expect((await list()).json.items).toEqual([]);
  });

  it('validates text, limit, cursor, identifiers and does not trust a requested language', async () => {
    const a = await e.login('alice');
    for (const body of ['', '   ', 42, 'x'.repeat(501)]) expect((await add(a.token, body)).status).toBe(400);
    expect((await add(a.token, '🙂'.repeat(500))).status).toBe(200);
    expect((await list(SKIN_A, '?cursor=invalid')).status).toBe(400);
    expect((await list('bad')).status).toBe(400);
    expect((await e.req('POST', `/v1/skins/${SKIN_A}/comments`, { token: a.token,
      body: { body: 'hello', language: 'made-up-language' } })).status).toBe(400);
    expect((await e.req('DELETE', '/v1/skin-comments/bad', { token: a.token })).status).toBe(400);
  });

  it('canonicalizes base/level aliases and rejects unknown catalog skins', async () => {
    e.close();
    e = setup({ content: new StaticCatalog({ skin: [SKIN_A, SKIN_B] },
      { [SKIN_B]: { skinUuid: SKIN_A, weaponUuid: WEAPON_1 } }) });
    const a = await e.login('alice');
    expect((await add(a.token, 'alias comment', SKIN_B)).json.skinUuid).toBe(SKIN_A);
    expect((await list()).json.items).toEqual((await list(SKIN_B)).json.items);
    expect((await list('99999999-9999-4999-8999-999999999999')).status).toBe(400);
  });

  it('uses stable bounded pagination with equal timestamps; isolates skins', async () => {
    const a = await e.login('alice');
    for (let i = 0; i < 7; i++) expect((await add(a.token, `comment ${i}`)).status).toBe(200);
    await add(a.token, 'other skin', SKIN_B);
    const ids: string[] = [];
    let cursor: string | null = null;
    do {
      const r = await list(SKIN_A, `?limit=2${cursor ? `&cursor=${cursor}` : ''}`);
      expect(r.json.items.length).toBeLessThanOrEqual(2);
      ids.push(...r.json.items.map((c: {id: string}) => c.id)); cursor = r.json.nextCursor;
    } while (cursor);
    expect(ids).toHaveLength(7); expect(new Set(ids).size).toBe(7);
    expect((await list(SKIN_B)).json.items).toHaveLength(1);
  });

  it('shares the existing 30/10-minute comment allowance with post comments', async () => {
    const a = await e.login('alice');
    const p = (await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'post' } })).json;
    for (let i = 0; i < 15; i++) {
      expect((await add(a.token, `skin ${i}`)).status).toBe(200);
      expect((await e.req('POST', `/v1/posts/${p.id}/comments`, { token: a.token, body: { body: `post ${i}` } })).status).toBe(200);
    }
    expect((await add(a.token)).status).toBe(429);
  });

  it('replays a durable idempotent create and rejects a conflicting body', async () => {
    const a = await e.login('alice');
    const headers = { 'idempotency-key': 'skin-comment-create-1' };
    const first = await add(a.token, 'one comment', SKIN_A, headers);
    const again = await add(a.token, 'one comment', SKIN_A, headers);
    expect(again.json).toEqual(first.json);
    expect(again.headers.get('idempotency-replayed')).toBe('true');
    expect((await add(a.token, 'different', SKIN_A, headers)).status).toBe(409);
    expect((await list()).json.items).toHaveLength(1);
  });

  it('rechecks session after async catalog validation; no late write after revocation', async () => {
    e.close();
    let release!: (v: boolean) => void;
    let entered!: () => void;
    const started = new Promise<void>((r) => { entered = r; });
    e = setup({ content: { isKnown: async () => { entered(); return new Promise<boolean>((r) => { release = r; }); } } });
    const a = await e.login('alice');
    const pending = add(a.token);
    await started; e.repo.bumpSessionEpoch(a.user.id); release(true);
    expect((await pending).status).toBe(401);
    expect(e.repo.listSkinComments({ skinUuid: SKIN_A, limit: 20 })).toEqual([]);
  });

  it('honors restrictions and bans on comments just as on post writes', async () => {
    const a = await e.login('alice');
    e.repo.addSanction({ userId: a.user.id, kind: 'restrict', until: null, reason: 'spam', now: e.clock.t });
    expect((await add(a.token)).status).toBe(403);
    expect((await list()).status).toBe(200);
  });

  it('exports own comments, erases them and reports, preserves other authors', async () => {
    const [a,b] = await Promise.all([e.login('alice'), e.login('bob')]);
    const c = (await add(a.token, 'own text')).json;
    await add(b.token, 'other text');
    await e.req('POST', '/v1/reports', { token: b.token,
      body: { targetType: 'skin_comment', targetId: c.id, reason: 'spam' } });
    const exported = (await e.req('GET', '/v1/me/export', { token: a.token })).json;
    expect(exported.skinComments).toEqual([expect.objectContaining({ id: c.id, skinUuid: SKIN_A, body: 'own text' })]);
    expect(JSON.stringify(exported)).not.toContain('other text');
    expect((await e.req('DELETE', '/v1/me', { token: a.token })).status).toBe(204);
    expect(e.repo.getSkinComment(c.id)).toBeNull();
    expect((await list()).json.items.map((c: {body:string}) => c.body)).toEqual(['other text']);
    expect(e.repo.reportedTargets({ limit: 20, now: e.clock.t, minReporterAgeMs: 0 })).toEqual([]);
  });

  it('supports report hiding, operator list/restore/delete without touching reviews', async () => {
    const a = await e.login('alice');
    const c = (await add(a.token)).json;
    const reporters = await Promise.all([e.login('b'), e.login('c'), e.login('d')]);
    for (const r of reporters) {
      await add(r.token, 'reporter activity', SKIN_B);
      expect((await e.req('POST', '/v1/reports', { token: r.token,
        body: { targetType: 'skin_comment', targetId: c.id, reason: 'spam' } })).status).toBe(204);
    }
    expect((await list()).json.items).toEqual([]);
    expect(e.repo.hiddenItems(20)).toEqual([expect.objectContaining({type:'skin_comment',id:c.id})]);
    expect(e.repo.restoreTarget('skin_comment',c.id)).toBe(true);
    expect((await list()).json.items).toHaveLength(1);
    e.repo.hideTarget('skin_comment',c.id);
    expect((await list()).json.items).toEqual([]);
    e.repo.deleteTarget('skin_comment',c.id);
    expect(e.repo.getSkinComment(c.id)).toBeNull();
  });

  it('applies existing CPU text filtering before storage', async () => {
    const a = await e.login('alice', { language: 'en' });
    const r = await add(a.token, 'shit happens http://bad.example/login hello');
    expect(r.status).toBe(200);
    expect(r.json.body).toBe('*** happens hello');
    expect(r.json.language).toBe('en');
  });

  it('uses the cursor index instead of an unbounded skin-comment scan', () => {
    const plan = e.db.prepare(`EXPLAIN QUERY PLAN SELECT * FROM skin_comments
      WHERE skin_uuid = ? AND hidden = 0 ORDER BY created_at, id LIMIT 21`).all(SKIN_A);
    expect(JSON.stringify(plan)).toContain('idx_skin_comments_skin');
    expect(JSON.stringify(plan)).not.toContain('SCAN skin_comments');
  });
});
