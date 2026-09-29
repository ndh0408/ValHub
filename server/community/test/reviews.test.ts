import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { expectError, setup, SKIN_A, SKIN_B, SKIN_C, WEAPON_1, WEAPON_2, type Env } from './helpers.js';

const SKIN_D = '44444444-4444-4444-8444-444444444444';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const review = (token: string, skin: string, rating: unknown, body?: unknown, weapon = WEAPON_1) =>
  e.req('PUT', `/v1/skins/${skin}/review`, {
    token,
    body: { weaponUuid: weapon, rating, ...(body === undefined ? {} : { body }) },
  });

const users = (n: number) => Promise.all(Array.from({ length: n }, (_, i) => e.login(`u${i}`)));

const report = (token: string, id: string) =>
  e.req('POST', '/v1/reports', { token, body: { targetType: 'review', targetId: id, reason: 'spam' } });

describe('PUT /v1/skins/{skin}/review', () => {
  it('creates a review', async () => {
    const { token, user } = await e.login('alice');
    const res = await review(token, SKIN_A, 4, '  Đẹp, âm thanh hay  ');
    expect(res.status).toBe(200);
    expect(res.json).toEqual({
      id: expect.stringMatching(/^[0-9a-f-]{36}$/),
      skinUuid: SKIN_A,
      author: expect.objectContaining({ id: user.id }),
      rating: 4,
      body: 'Đẹp, âm thanh hay',
      likes: 0,
      liked: false,
      createdAt: new Date(e.clock.t).toISOString(),
      updatedAt: new Date(e.clock.t).toISOString(),
      mine: true,
    });
    const noBody = await review(token, SKIN_B, 5);
    expect(noBody.json.body).toBe('');
    expect((await review(token, SKIN_C, 3, null)).json.body).toBe('');
  });

  it('validates rating, body and uuids', async () => {
    const { token } = await e.login('alice');
    for (const rating of [0, 6, 2.5, '5', null, undefined, true]) {
      expectError(await review(token, SKIN_A, rating), 400, 'invalid_input');
    }
    expectError(await review(token, SKIN_A, 3, 'x'.repeat(501)), 400, 'invalid_input');
    expectError(await review(token, SKIN_A, 3, 42), 400, 'invalid_input');
    expect((await review(token, SKIN_A, 3, 'ể'.repeat(500))).status).toBe(200);
    expectError(await review(token, 'not-a-uuid', 3), 400, 'invalid_input');
    expectError(await review(token, SKIN_A, 3, 'x', 'bad'), 400, 'invalid_input');
    expectError(
      await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token, body: { rating: 3 } }),
      400,
      'invalid_input',
    );
    expectError(await review('', SKIN_A, 3), 401, 'unauthorized');
  });

  it('keeps one review per user per skin (replace keeps id, likes, createdAt)', async () => {
    const [a, b] = await users(2);
    const first = await review(a!.token, SKIN_A, 2, 'meh');
    await e.req('PUT', `/v1/reviews/${first.json.id}/like`, { token: b!.token });
    e.clock.t += 60_000;
    const second = await review(a!.token, SKIN_A, 5, 'thay đổi ý kiến');
    expect(second.json).toMatchObject({
      id: first.json.id,
      rating: 5,
      body: 'thay đổi ý kiến',
      likes: 1,
      createdAt: first.json.createdAt,
      updatedAt: new Date(e.clock.t).toISOString(),
    });
    const list = await e.req('GET', `/v1/skins/${SKIN_A}/reviews`);
    expect(list.json.items).toHaveLength(1);
    const summary = await e.req('GET', `/v1/skins/${SKIN_A}/summary`);
    expect(summary.json).toMatchObject({ ratingAvg: 5, ratingCount: 1, distribution: [0, 0, 0, 0, 1] });
  });

  it('rate limits reviews to 30 per hour', async () => {
    const { token } = await e.login('alice');
    for (let i = 0; i < 30; i++) expect((await review(token, SKIN_A, (i % 5) + 1)).status).toBe(200);
    const res = await review(token, SKIN_A, 5);
    expectError(res, 429, 'rate_limited');
    expect(res.headers.get('retry-after')).toBeTruthy();
  });
});

describe('summary', () => {
  it('reports average (1 decimal), distribution, review count and myReview', async () => {
    const [a, b, c] = await users(3);
    await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: a!.token, body: { weaponUuid: WEAPON_2 } });
    await review(a!.token, SKIN_A, 5, 'tuyệt');
    await review(b!.token, SKIN_A, 4, '');
    await review(c!.token, SKIN_A, 4, 'ổn');

    const anon = await e.req('GET', `/v1/skins/${SKIN_A}/summary`);
    expect(anon.status).toBe(200);
    expect(anon.json).toEqual({
      skinUuid: SKIN_A,
      weaponUuid: WEAPON_2, // pinned by the first vote
      votes: 1,
      voted: false,
      ratingAvg: 4.3,
      ratingCount: 3,
      distribution: [0, 0, 0, 2, 1],
      reviewCount: 2,
      myReview: null,
    });

    const mine = await e.req('GET', `/v1/skins/${SKIN_A}/summary`, { token: a!.token });
    expect(mine.json.voted).toBe(true);
    expect(mine.json.myReview).toMatchObject({ rating: 5, body: 'tuyệt', mine: true });

    const empty = await e.req('GET', `/v1/skins/${SKIN_B}/summary`, { token: a!.token });
    expect(empty.json).toEqual({
      skinUuid: SKIN_B,
      weaponUuid: null,
      votes: 0,
      voted: false,
      ratingAvg: null,
      ratingCount: 0,
      distribution: [0, 0, 0, 0, 0],
      reviewCount: 0,
      myReview: null,
    });
    expectError(await e.req('GET', '/v1/skins/nope/summary'), 400, 'invalid_input');
  });

  it('pins the weapon by the first review too (votes follow it)', async () => {
    const [a, b] = await users(2);
    await review(a!.token, SKIN_A, 4, 'x', WEAPON_2);
    await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: b!.token, body: { weaponUuid: WEAPON_1 } });
    await review(b!.token, SKIN_A, 4, 'x', WEAPON_1);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.weaponUuid).toBe(WEAPON_2);
    const top = await e.req('GET', `/v1/skins/top?weapon=${WEAPON_2}`);
    expect(top.json.items).toEqual([expect.objectContaining({ skinUuid: SKIN_A, votes: 1, ratingCount: 2 })]);
    expect((await e.req('GET', `/v1/skins/top?weapon=${WEAPON_1}`)).json.items).toEqual([]);
  });
});

describe('listing reviews', () => {
  it('sorts by new and by top (likes, then newest) with cursors', async () => {
    const us = await users(5);
    const ids: string[] = [];
    for (let i = 0; i < 4; i++) {
      e.clock.t += 1000;
      ids.push((await review(us[i]!.token, SKIN_A, 3, `r${i}`)).json.id);
    }
    // likes: r1 → 3, r3 → 1, r0 → 1, r2 → 0
    for (const u of [us[0], us[2], us[4]]) await e.req('PUT', `/v1/reviews/${ids[1]}/like`, { token: u!.token });
    await e.req('PUT', `/v1/reviews/${ids[3]}/like`, { token: us[4]!.token });
    await e.req('PUT', `/v1/reviews/${ids[0]}/like`, { token: us[4]!.token });

    const byNew = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=new`);
    expect(byNew.json.items.map((r: any) => r.body)).toEqual(['r3', 'r2', 'r1', 'r0']);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/reviews`)).json.items.map((r: any) => r.body)).toEqual([
      'r3',
      'r2',
      'r1',
      'r0',
    ]);

    const top1 = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=top&limit=2`, { token: us[4]!.token });
    expect(top1.json.items.map((r: any) => [r.body, r.likes, r.liked, r.mine])).toEqual([
      ['r1', 3, true, false],
      ['r3', 1, true, false],
    ]);
    const top2 = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=top&limit=2&cursor=${top1.json.nextCursor}`);
    expect(top2.json.items.map((r: any) => [r.body, r.likes])).toEqual([
      ['r0', 1],
      ['r2', 0],
    ]);
    expect(top2.json.nextCursor).toBeNull();

    const new1 = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=new&limit=3`, { token: us[0]!.token });
    expect(new1.json.items.map((r: any) => r.mine)).toEqual([false, false, false]);
    const new2 = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=new&limit=3&cursor=${new1.json.nextCursor}`, {
      token: us[0]!.token,
    });
    expect(new2.json.items.map((r: any) => [r.body, r.mine])).toEqual([['r0', true]]);

    // A cursor from one sort order is rejected by the other.
    expectError(
      await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=new&cursor=${top1.json.nextCursor}`),
      400,
      'invalid_input',
    );
    expectError(
      await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=top&cursor=${new1.json.nextCursor}`),
      400,
      'invalid_input',
    );
    expectError(await e.req('GET', `/v1/skins/${SKIN_A}/reviews?sort=best`), 400, 'invalid_input');
  });
});

describe('review likes', () => {
  it('likes / unlikes idempotently and forbids liking your own review', async () => {
    const [a, b, c] = await users(3);
    const id = (await review(a!.token, SKIN_A, 5, 'hay')).json.id;
    expectError(await e.req('PUT', `/v1/reviews/${id}/like`, { token: a!.token }), 403, 'forbidden');
    expectError(await e.req('DELETE', `/v1/reviews/${id}/like`, { token: a!.token }), 403, 'forbidden');
    expect((await e.req('PUT', `/v1/reviews/${id}/like`, { token: b!.token })).json).toEqual({ likes: 1, liked: true });
    expect((await e.req('PUT', `/v1/reviews/${id}/like`, { token: b!.token })).json).toEqual({ likes: 1, liked: true });
    expect((await e.req('PUT', `/v1/reviews/${id}/like`, { token: c!.token })).json).toEqual({ likes: 2, liked: true });
    expect((await e.req('DELETE', `/v1/reviews/${id}/like`, { token: b!.token })).json).toEqual({
      likes: 1,
      liked: false,
    });
    expect((await e.req('DELETE', `/v1/reviews/${id}/like`, { token: b!.token })).json).toEqual({
      likes: 1,
      liked: false,
    });
    expectError(
      await e.req('PUT', '/v1/reviews/00000000-0000-4000-8000-000000000000/like', { token: b!.token }),
      404,
      'not_found',
    );
    expectError(await e.req('PUT', `/v1/reviews/${id}/like`), 401, 'unauthorized');
  });

  it('shares the likes rate limit with post likes', async () => {
    const [a, b] = await users(2);
    const postId = (await e.req('POST', '/v1/posts', { token: a!.token, body: { kind: 'text', body: 'x' } })).json.id;
    const reviewId = (await review(a!.token, SKIN_A, 5)).json.id;
    for (let i = 0; i < 60; i++) await e.req('PUT', `/v1/posts/${postId}/like`, { token: b!.token });
    for (let i = 0; i < 60; i++) await e.req('PUT', `/v1/reviews/${reviewId}/like`, { token: b!.token });
    expectError(await e.req('PUT', `/v1/reviews/${reviewId}/like`, { token: b!.token }), 429, 'rate_limited');
  });
});

describe('deleting reviews', () => {
  it('only the author can delete', async () => {
    const [a, b] = await users(2);
    const id = (await review(a!.token, SKIN_A, 5, 'x')).json.id;
    await e.req('PUT', `/v1/reviews/${id}/like`, { token: b!.token });
    expectError(await e.req('DELETE', `/v1/reviews/${id}`, { token: b!.token }), 403, 'forbidden');
    expect((await e.req('DELETE', `/v1/reviews/${id}`, { token: a!.token })).status).toBe(204);
    expectError(await e.req('DELETE', `/v1/reviews/${id}`, { token: a!.token }), 404, 'not_found');
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM review_likes').get()).toEqual({ n: 0 });
  });

  it('DELETE /v1/skins/{skin}/review removes the caller’s review', async () => {
    const [a, b] = await users(2);
    await review(a!.token, SKIN_A, 5, 'x');
    await review(b!.token, SKIN_A, 1, 'y');
    expect((await e.req('DELETE', `/v1/skins/${SKIN_A}/review`, { token: a!.token })).status).toBe(204);
    expect((await e.req('DELETE', `/v1/skins/${SKIN_A}/review`, { token: a!.token })).status).toBe(204);
    const s = await e.req('GET', `/v1/skins/${SKIN_A}/summary`, { token: a!.token });
    expect(s.json).toMatchObject({ ratingAvg: 1, ratingCount: 1, myReview: null });
    expectError(await e.req('DELETE', `/v1/skins/${SKIN_A}/review`), 401, 'unauthorized');
  });
});

describe('review moderation', () => {
  it('hides a review after 3 distinct reports and excludes it from averages', async () => {
    const [author, r1, r2, r3, other] = await users(5);
    const id = (await review(author!.token, SKIN_A, 1, 'spam spam')).json.id;
    await review(other!.token, SKIN_A, 5, 'ok');
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json).toMatchObject({ ratingAvg: 3, ratingCount: 2 });

    expect((await report(r1!.token, id)).status).toBe(204);
    expect((await report(r1!.token, id)).status).toBe(204);
    expect((await report(r2!.token, id)).status).toBe(204);
    expect(e.db.prepare('SELECT report_count, hidden FROM skin_reviews WHERE id = ?').get(id)).toEqual({
      report_count: 2,
      hidden: 0,
    });
    expect((await report(r3!.token, id)).status).toBe(204);
    expect(e.db.prepare('SELECT report_count, hidden FROM skin_reviews WHERE id = ?').get(id)).toEqual({
      report_count: 3,
      hidden: 1,
    });

    const s = await e.req('GET', `/v1/skins/${SKIN_A}/summary`);
    expect(s.json).toMatchObject({ ratingAvg: 5, ratingCount: 1, distribution: [0, 0, 0, 0, 1], reviewCount: 1 });
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/reviews`)).json.items.map((r: any) => r.body)).toEqual(['ok']);
    expect((await e.req('GET', `/v1/skins/votes?ids=${SKIN_A}`)).json.items[0]).toMatchObject({
      ratingAvg: 5,
      ratingCount: 1,
    });
    expectError(await e.req('PUT', `/v1/reviews/${id}/like`, { token: r1!.token }), 404, 'not_found');

    // The author still sees (and can delete) the hidden review; editing does not un-hide it.
    const mine = await e.req('GET', `/v1/skins/${SKIN_A}/summary`, { token: author!.token });
    expect(mine.json.myReview).toMatchObject({ id, mine: true });
    await review(author!.token, SKIN_A, 2, 'edited');
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.ratingCount).toBe(1);
    expect((await e.req('DELETE', `/v1/reviews/${id}`, { token: author!.token })).status).toBe(204);
  });
});

describe('GET /v1/skins/top with reviews', () => {
  /**
   * B: 10 ratings (9×5 + 4) → raw 4.9; A: three 5s → raw 5.0; C: two 5s (below the 3-rating minimum);
   * D: five 1s. Global mean m = 79 / 20 = 3.95, C = 5:
   *   B = (19.75 + 49) / 15 ≈ 4.583,  A = (19.75 + 15) / 8 ≈ 4.344,  D = (19.75 + 5) / 10 = 2.475.
   */
  async function seedRatings() {
    const us = await users(10);
    for (let i = 0; i < 10; i++) await review(us[i]!.token, SKIN_B, i === 9 ? 4 : 5, i < 6 ? `b${i}` : '', WEAPON_2);
    for (let i = 0; i < 3; i++) await review(us[i]!.token, SKIN_A, 5, 'a');
    for (let i = 0; i < 2; i++) await review(us[i]!.token, SKIN_C, 5, 'c');
    for (let i = 3; i < 8; i++) await review(us[i]!.token, SKIN_D, 1, '');
    await e.req('PUT', `/v1/skins/${SKIN_D}/vote`, { token: us[0]!.token, body: { weaponUuid: WEAPON_1 } });
    return us;
  }

  it('sort=rating ranks by Bayesian average and requires 3 ratings', async () => {
    const us = await seedRatings();
    const res = await e.req('GET', '/v1/skins/top?sort=rating', { token: us[0]!.token });
    expect(res.status).toBe(200);
    expect(res.json.items).toEqual([
      {
        rank: 1,
        skinUuid: SKIN_B,
        weaponUuid: WEAPON_2,
        votes: 0,
        voted: false,
        ratingAvg: 4.9,
        ratingCount: 10,
        reviewCount: 6,
      },
      {
        rank: 2,
        skinUuid: SKIN_A,
        weaponUuid: WEAPON_1,
        votes: 0,
        voted: false,
        ratingAvg: 5,
        ratingCount: 3,
        reviewCount: 3,
      },
      {
        rank: 3,
        skinUuid: SKIN_D,
        weaponUuid: WEAPON_1,
        votes: 1,
        voted: true,
        ratingAvg: 1,
        ratingCount: 5,
        reviewCount: 0,
      },
    ]);
    const w = await e.req('GET', `/v1/skins/top?sort=rating&weapon=${WEAPON_1}&limit=1`);
    expect(w.json.items.map((i: any) => i.skinUuid)).toEqual([SKIN_A]);
  });

  it('sort=reviews ranks by written reviews, then ratings', async () => {
    await seedRatings();
    const res = await e.req('GET', '/v1/skins/top?sort=reviews');
    expect(res.json.items.map((i: any) => [i.skinUuid, i.reviewCount, i.ratingCount])).toEqual([
      [SKIN_B, 6, 10],
      [SKIN_A, 3, 3],
      [SKIN_C, 2, 2],
      [SKIN_D, 0, 5],
    ]);
  });

  it('sort=votes (default) includes rating fields', async () => {
    await seedRatings();
    const res = await e.req('GET', '/v1/skins/top');
    expect(res.json.items).toEqual([
      expect.objectContaining({ rank: 1, skinUuid: SKIN_D, votes: 1, ratingAvg: 1, ratingCount: 5, reviewCount: 0 }),
    ]);
    expectError(await e.req('GET', '/v1/skins/top?sort=likes'), 400, 'invalid_input');
  });

  it('period=week only counts votes and ratings from the last 7 days', async () => {
    const us = await users(4);
    // Old activity.
    for (let i = 0; i < 3; i++) {
      await review(us[i]!.token, SKIN_A, 5, 'old');
      await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: us[i]!.token, body: { weaponUuid: WEAPON_1 } });
    }
    await review(us[3]!.token, SKIN_B, 2, 'old');
    e.clock.t += 8 * 86400_000;
    // Recent activity.
    for (let i = 0; i < 3; i++) await review(us[i]!.token, SKIN_B, 4, i === 0 ? 'new' : '');
    await e.req('PUT', `/v1/skins/${SKIN_B}/vote`, { token: us[0]!.token, body: { weaponUuid: WEAPON_1 } });
    // Editing an old review counts as recent activity.
    await review(us[3]!.token, SKIN_B, 3, 'edited');

    const all = await e.req('GET', '/v1/skins/top?sort=rating');
    expect(all.json.items.map((i: any) => [i.skinUuid, i.ratingCount])).toEqual([
      [SKIN_A, 3],
      [SKIN_B, 4],
    ]);
    const week = await e.req('GET', '/v1/skins/top?sort=rating&period=week');
    expect(week.json.items).toEqual([
      expect.objectContaining({ skinUuid: SKIN_B, votes: 1, ratingCount: 4, ratingAvg: 3.8, reviewCount: 2 }),
    ]);
    const weekVotes = await e.req('GET', '/v1/skins/top?period=week');
    expect(weekVotes.json.items).toEqual([
      expect.objectContaining({ skinUuid: SKIN_B, votes: 1, ratingCount: 4, ratingAvg: 3.8 }),
    ]);
    const allVotes = await e.req('GET', '/v1/skins/top');
    expect(allVotes.json.items.map((i: any) => [i.skinUuid, i.votes, i.ratingAvg])).toEqual([
      [SKIN_A, 3, 5],
      [SKIN_B, 1, 3.8],
    ]);
  });
});
