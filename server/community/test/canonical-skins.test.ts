import { afterEach, describe, expect, it } from 'vitest';
import { StaticCatalog } from '../src/content.js';
import { sweep } from '../src/sweeper.js';
import { setup, SKIN_A, SKIN_B, WEAPON_1, WEAPON_2, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());
const mapping = { [SKIN_A]: { skinUuid: SKIN_A, weaponUuid: WEAPON_1 }, [SKIN_B]: { skinUuid: SKIN_A, weaponUuid: WEAPON_1 } };

describe('canonical skins (CS-05)', () => {
  it('one vote/review through base and alias, using the catalog weapon', async () => {
    e = setup({ content: new StaticCatalog({}, mapping) });
    const a = await e.login('alice');
    e.clock.t += 2 * 86400_000;
    for (const id of [SKIN_A, SKIN_B]) {
      expect((await e.req('PUT', `/v1/skins/${id}/vote`, { token: a.token, body: { weaponUuid: WEAPON_2 } })).status).toBe(200);
      expect((await e.req('PUT', `/v1/skins/${id}/review`, { token: a.token, body: { weaponUuid: WEAPON_2, rating: 5 } })).status).toBe(200);
    }
    expect(e.db.prepare('SELECT skin_uuid, weapon_uuid FROM skin_votes').all()).toEqual([{ skin_uuid: SKIN_A, weapon_uuid: WEAPON_1 }]);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM skin_reviews').get()).toEqual({ n: 1 });
    expect((await e.req('GET', `/v1/skins/${SKIN_B}/summary`)).json).toMatchObject({ skinUuid: SKIN_B, votes: 1, ratingCount: 1, weaponUuid: WEAPON_1 });
    await e.req('DELETE', `/v1/skins/${SKIN_B}/vote`, { token: a.token });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM skin_votes').get()).toEqual({ n: 0 });
  });

  it('merges old rows atomically, keeps first times, likes and moderation; replay uses saved mapping', async () => {
    e = setup();
    const a = await e.login('alice');
    const b = await e.login('bob');
    const t = e.clock.t;
    const reviews: string[] = [];
    for (const id of [SKIN_B, SKIN_A]) {
      await e.req('PUT', `/v1/skins/${id}/vote`, { token: a.token, body: { weaponUuid: WEAPON_2 } });
      const r = await e.req('PUT', `/v1/skins/${id}/review`, { token: a.token, body: { weaponUuid: WEAPON_2, rating: 4 } });
      reviews.push(r.json.id);
      await e.req('PUT', `/v1/reviews/${r.json.id}/like`, { token: b.token });
      e.clock.t += 1000;
    }
    e.repo.hideTarget('review', reviews[0]!);
    const catalog = new StaticCatalog({}, mapping);
    await sweep({ ...e.mediaDeps(), content: catalog });
    expect(e.db.prepare('SELECT created_at, weapon_uuid FROM skin_votes').all()).toEqual([{ created_at: t, weapon_uuid: WEAPON_1 }]);
    expect(e.db.prepare('SELECT id, created_at, hidden, hidden_reason, like_count FROM skin_reviews').all()).toEqual([
      { id: reviews[1], created_at: t, hidden: 1, hidden_reason: 'moderator', like_count: 1 },
    ]);
    expect(e.repo.canonicalizeSkins(() => null)).toMatchObject({ votesMerged: 0, reviewsMerged: 0 });
    e.repo.voteSkin(a.user.id, SKIN_B, WEAPON_2, e.clock.t, { country: null, region: 'ap' });
    expect(e.repo.canonicalizeSkins(() => null).votesMerged).toBe(1);
    // The original app has no catalog: persisted aliases must also protect new route writes,
    // not just a one-time startup migration/sweep.
    await e.req('PUT', `/v1/skins/${SKIN_B}/vote`, { token: a.token, body: { weaponUuid: WEAPON_2 } });
    await e.req('PUT', `/v1/skins/${SKIN_B}/review`, { token: a.token, body: { weaponUuid: WEAPON_2, rating: 3 } });
    expect(e.db.prepare('SELECT skin_uuid, weapon_uuid FROM skin_votes').all()).toEqual([{ skin_uuid: SKIN_A, weapon_uuid: WEAPON_1 }]);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM skin_reviews').get()).toEqual({ n: 1 });
  });
});
