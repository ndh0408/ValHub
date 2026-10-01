import fs from 'node:fs';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { runCli } from '../src/cli.js';
import { quarantineMedia } from '../src/media-service.js';
import { expectError, PNG, setup, SKIN_A, SKIN_B, WEAPON_1, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup({ established: true });
});
afterEach(() => e.close());

const upload = async (token: string) =>
  (await e.req('POST', '/v1/media', { token, raw: PNG, headers: { 'content-type': 'image/png' } })).json.key as string;
const publicFile = (key: string) => path.join(e.mediaDir, ...key.split('/'));
const quarantineFile = (key: string) => path.join(e.quarantineDir, ...key.split('/'));
const count = (table: string, where = '1=1', ...p: unknown[]) =>
  (e.db.prepare(`SELECT COUNT(*) AS n FROM ${table} WHERE ${where}`).get(...p) as { n: number }).n;

/** alice has one of everything; bob interacts with her content and she with his. */
async function populate() {
  e.riotCountries.alice = 'vnm';
  const alice = await e.login('alice', { language: 'vi' });
  const bob = await e.login('bob', { language: 'en' });
  const carol = await e.login('carol');
  const k1 = await upload(alice.token);
  const k2 = await upload(alice.token);
  const orphan = await upload(alice.token);
  const kBob = await upload(bob.token);
  const alicePost = (await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', body: 'alice post', media: [k1, k2] } })).json;
  const bobPost = (await e.req('POST', '/v1/posts', { token: bob.token, body: { kind: 'text', body: 'bob post', media: [kBob] } })).json;
  const bobCommentOnAlice = (await e.req('POST', `/v1/posts/${alicePost.id}/comments`, { token: bob.token, body: { body: 'bob on alice' } })).json;
  const aliceCommentOnBob = (await e.req('POST', `/v1/posts/${bobPost.id}/comments`, { token: alice.token, body: { body: 'alice on bob' } })).json;
  await e.req('PUT', `/v1/posts/${bobPost.id}/like`, { token: alice.token });
  await e.req('PUT', `/v1/posts/${alicePost.id}/like`, { token: bob.token });
  await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: alice.token, body: { weaponUuid: WEAPON_1 } });
  await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: bob.token, body: { weaponUuid: WEAPON_1 } });
  const aliceReview = (await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: alice.token, body: { weaponUuid: WEAPON_1, rating: 5, body: 'great' } })).json;
  const bobReview = (await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: bob.token, body: { weaponUuid: WEAPON_1, rating: 2, body: 'meh' } })).json;
  await e.req('PUT', `/v1/reviews/${bobReview.id}/like`, { token: alice.token });
  await e.req('PUT', `/v1/reviews/${aliceReview.id}/like`, { token: bob.token });
  const aliceLfg = (await e.req('POST', '/v1/lfg', { token: alice.token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2 } })).json;
  const bobLfg = (await e.req('POST', '/v1/lfg', { token: bob.token, body: { region: 'ap', mode: 'unrated', partyCode: 'BCDEFG', slots: 2 } })).json;
  await e.req('POST', `/v1/lfg/${bobLfg.id}/join`, { token: alice.token, body: {} });
  await e.req('POST', `/v1/lfg/${aliceLfg.id}/join`, { token: bob.token, body: {} });
  return { alice, bob, carol, k1, k2, orphan, kBob, alicePost, bobPost, bobCommentOnAlice, aliceCommentOnBob, aliceReview, bobReview, aliceLfg, bobLfg };
}

describe('GET /v1/me/export', () => {
  it('returns everything stored about the caller as a JSON download, media as URLs', async () => {
    const d = await populate();
    const res = await e.req('GET', '/v1/me/export', { token: d.alice.token });
    expect(res.status).toBe(200);
    expect(res.headers.get('content-disposition')).toContain('attachment');
    expect(res.headers.get('cache-control')).toBe('no-store');
    const x = res.json;
    expect(x.format).toBe('valvn-community-export/1');
    expect(x.profile).toMatchObject({ id: d.alice.user.id, gameName: 'Player alice', country: 'VN', language: 'vi', region: 'ap' });
    expect(x.posts).toHaveLength(1);
    expect(x.posts[0]).toMatchObject({ id: d.alicePost.id, body: 'alice post', hidden: false, language: 'vi', country: 'VN' });
    expect(x.posts[0].media.map((m: any) => m.key)).toEqual([d.k1, d.k2]);
    expect(x.posts[0].media[0].url).toBe(`http://community.test/v1/media/${d.k1}`);
    expect(x.comments.map((c: any) => c.id)).toEqual([d.aliceCommentOnBob.id]);
    expect(x.reviews).toHaveLength(1);
    expect(x.reviews[0]).toMatchObject({ id: d.aliceReview.id, rating: 5, likes: 1 });
    expect(x.postLikes.map((l: any) => l.postId)).toEqual([d.bobPost.id]);
    expect(x.reviewLikes.map((l: any) => l.reviewId)).toEqual([d.bobReview.id]);
    expect(x.skinVotes).toEqual([expect.objectContaining({ skinUuid: SKIN_A, weaponUuid: WEAPON_1, country: 'VN', region: 'ap' })]);
    expect(x.lfgPosts).toEqual([expect.objectContaining({ id: d.aliceLfg.id, partyCode: 'ABCDEF', status: 'open' })]);
    expect(x.lfgJoins.map((j: any) => j.lfgId)).toEqual([d.bobLfg.id]);
    expect(x.media).toHaveLength(3); // two attached + the orphan
    expect(x.media.find((m: any) => m.key === d.orphan)).toMatchObject({ attachedToPost: null, status: 'active', contentType: 'image/png' });
    // Nothing of other people's private data, no puuid.
    const text = JSON.stringify(x);
    expect(text).not.toContain('puuid');
    expect(text).not.toContain('bob post');
    expect(text).not.toContain(d.bob.user.id);
  });

  it('requires a session, is rate limited (5 / hour) and works for a fresh account', async () => {
    expectError(await e.req('GET', '/v1/me/export'), 401, 'unauthorized');
    const { token } = await e.login('newbie');
    for (let i = 0; i < 5; i++) expect((await e.req('GET', '/v1/me/export', { token })).status).toBe(200);
    const res = await e.req('GET', '/v1/me/export', { token });
    expectError(res, 429, 'rate_limited');
    expect(res.headers.get('retry-after')).toBeTruthy();
    const empty = (await e.req('GET', '/v1/me/export', { token: (await e.login('empty')).token })).json;
    expect(empty.posts).toEqual([]);
    expect(empty.media).toEqual([]);
  });

  it('includes reports the user filed (and only those)', async () => {
    const d = await populate();
    e.mature(d.carol.user.id);
    await e.req('POST', '/v1/reports', { token: d.carol.token, body: { targetType: 'post', targetId: d.alicePost.id, reason: 'spam?' } });
    const carol = (await e.req('GET', '/v1/me/export', { token: d.carol.token })).json;
    expect(carol.reportsFiled).toEqual([expect.objectContaining({ targetType: 'post', targetId: d.alicePost.id, reason: 'spam?' })]);
    const alice = (await e.req('GET', '/v1/me/export', { token: d.alice.token })).json;
    expect(alice.reportsFiled).toEqual([]); // being reported is not something alice filed
  });
});

describe('DELETE /v1/me', () => {
  it('hard-deletes everything of the user, and nothing of anyone else', async () => {
    const d = await populate();
    // A quarantined copy of alice's file must go too.
    const qKey = await upload(d.alice.token);
    await quarantineMedia(e.mediaDeps(), [qKey]);
    e.mature(d.carol.user.id);
    // alice reports bob's post (anonymised later); carol reports alice's post and alice's comment.
    await e.req('POST', '/v1/reports', { token: d.alice.token, body: { targetType: 'post', targetId: d.bobPost.id, reason: 'alice was here' } });
    await e.req('POST', '/v1/reports', { token: d.carol.token, body: { targetType: 'post', targetId: d.alicePost.id, reason: 'about alice' } });
    await e.req('POST', '/v1/reports', { token: d.carol.token, body: { targetType: 'comment', targetId: d.bobCommentOnAlice.id, reason: 'on alice post' } });
    await e.req('POST', '/v1/reports', { token: d.carol.token, body: { targetType: 'review', targetId: d.aliceReview.id, reason: 'x' } });
    const aliceId = d.alice.user.id;

    const res = await e.req('DELETE', '/v1/me', { token: d.alice.token });
    expect(res.status).toBe(204);
    expect(res.bytes.length).toBe(0);

    // Alice is gone everywhere.
    expect(count('users', 'id = ?', aliceId)).toBe(0);
    for (const [table, col] of [['posts', 'user_id'], ['comments', 'user_id'], ['skin_reviews', 'user_id'], ['post_likes', 'user_id'], ['review_likes', 'user_id'], ['skin_votes', 'user_id'], ['lfg_posts', 'user_id'], ['lfg_joins', 'user_id'], ['media', 'user_id']]) {
      expect(count(table!, `${col} = ?`, aliceId), table).toBe(0);
    }
    // (Rate-limit counters are kept until they expire: deleting them would let delete + sign-in reset every limit.)
    expect(count('rate_limits', 'bucket LIKE ?', `%:${aliceId}`)).toBeGreaterThan(0);
    // ... including every file, public, quarantined and orphaned.
    for (const k of [d.k1, d.k2, d.orphan]) {
      expect(fs.existsSync(publicFile(k)), k).toBe(false);
      expectError(await e.req('GET', `/v1/media/${k}`), 404, 'not_found');
    }
    expect(fs.existsSync(quarantineFile(qKey))).toBe(false);
    expect(fs.readdirSync(path.join(e.mediaDir, 'u')).sort()).toEqual([d.bob.user.id]);
    // Bob's comment on alice's post went with the post; reports about alice's content are gone.
    expect(count('comments', 'id = ?', d.bobCommentOnAlice.id)).toBe(0);
    expect(count('reports', "target_type = 'post' AND target_id = ?", d.alicePost.id)).toBe(0);
    expect(count('reports', "target_type = 'comment' AND target_id = ?", d.bobCommentOnAlice.id)).toBe(0);
    expect(count('reports', "target_type = 'review' AND target_id = ?", d.aliceReview.id)).toBe(0);
    // The report alice filed stays, anonymised (no user id, no free text).
    const kept = e.db.prepare("SELECT reporter_id, reason, target_id FROM reports WHERE target_type = 'post'").all() as any[];
    expect(kept).toHaveLength(1);
    expect(kept[0].target_id).toBe(d.bobPost.id);
    expect(kept[0].reporter_id).toMatch(/^anon-[0-9a-f]{16}$/);
    expect(kept[0].reason).toBe('');

    // Bob keeps everything, with counts that no longer include alice.
    expect(count('posts', 'user_id = ?', d.bob.user.id)).toBe(1);
    expect(count('media', 'user_id = ?', d.bob.user.id)).toBe(1);
    expect((await e.req('GET', `/v1/media/${d.kBob}`)).status).toBe(200);
    const bobPost = (await e.req('GET', `/v1/posts/${d.bobPost.id}`, { token: d.bob.token })).json;
    expect(bobPost).toMatchObject({ likes: 0, comments: 0 });
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json).toMatchObject({ votes: 1, ratingCount: 1, ratingAvg: 2 });
    expect((await e.req('GET', '/v1/lfg?scope=global', { token: d.bob.token })).json.items.map((i: any) => i.id)).toEqual([d.bobLfg.id]);
    expect((await e.req('GET', '/v1/lfg/mine', { token: d.bob.token })).json.joins).toBe(0);
    expect((await e.req('GET', `/v1/reviews/${d.bobReview.id}/nope`, { token: d.bob.token })).status).toBe(404);
    expect(e.db.prepare('SELECT like_count FROM skin_reviews WHERE id = ?').get(d.bobReview.id)).toEqual({ like_count: 1 - 1 + 0 });
  });

  it('logs the user out for good: token 401, second delete 401; signing in again starts an empty account', async () => {
    const d = await populate();
    expect((await e.req('DELETE', '/v1/me', { token: d.alice.token })).status).toBe(204);
    expectError(await e.req('GET', '/v1/me', { token: d.alice.token }), 401, 'unauthorized');
    expectError(await e.req('DELETE', '/v1/me', { token: d.alice.token }), 401, 'unauthorized');
    expectError(await e.req('GET', '/v1/me/export', { token: d.alice.token }), 401, 'unauthorized');
    const again = await e.login('alice');
    expect(again.user.id).toBe(d.alice.user.id); // same Riot account → same hashed id, but nothing is left of the old data
    const x = (await e.req('GET', '/v1/me/export', { token: again.token })).json;
    expect(x.posts).toEqual([]);
    expect(x.skinVotes).toEqual([]);
    expect(x.media).toEqual([]);
  });

  it('requires a session; the per-user limit (3 / hour) is checked before anything is erased', async () => {
    expectError(await e.req('DELETE', '/v1/me'), 401, 'unauthorized');
    const { token, user } = await e.login('flappy');
    // Pre-load the counter as if the user had already tried three times this hour.
    const windowStart = Math.floor(e.clock.t / 3600_000) * 3600_000;
    e.db.prepare('INSERT INTO rate_limits (bucket, window_start, count) VALUES (?, ?, 3)').run(`accountDelete:${user.id}`, windowStart);
    const res = await e.req('DELETE', '/v1/me', { token });
    expectError(res, 429, 'rate_limited');
    expect(res.headers.get('retry-after')).toBeTruthy();
    expect(e.repo.getUser(user.id)).not.toBeNull(); // nothing was erased
    e.clock.t += 3600_000;
    expect((await e.req('DELETE', '/v1/me', { token })).status).toBe(204);
    // The counters survive the erasure (they hold only an id and a count and expire by themselves): the erase limit
    // cannot be reset by erasing, and neither can any other per-user limit (CS-37).
    expect(count('rate_limits', 'bucket LIKE ?', `%:${user.id}`)).toBeGreaterThan(0);
    for (let i = 0; i < 2; i++) {
      const again = await e.login('flappy');
      expect((await e.req('DELETE', '/v1/me', { token: again.token })).status).toBe(204);
    }
    const last = await e.login('flappy');
    expectError(await e.req('DELETE', '/v1/me', { token: last.token }), 429, 'rate_limited');
  });

  it('erases a user with a lot of media without leaving files behind', async () => {
    const { token, user } = await e.login('hoarder');
    for (let i = 0; i < 12; i++) await upload(token);
    expect(fs.readdirSync(path.join(e.mediaDir, 'u', user.id))).toHaveLength(12);
    expect((await e.req('DELETE', '/v1/me', { token })).status).toBe(204);
    expect(fs.existsSync(path.join(e.mediaDir, 'u', user.id))).toBe(false); // not even an empty directory named after the account
    expect(count('media')).toBe(0);
  });
});

describe('operator CLI', () => {
  const run = async (argv: string[]) => {
    const out: string[] = [];
    const err: string[] = [];
    const code = await runCli(argv, { ...e.mediaDeps(), out: (l) => out.push(l), err: (l) => err.push(l), baseUrl: 'https://c.example' });
    return { code, out: out.join('\n'), err: err.join('\n') };
  };

  it('finds, exports and erases a user by Riot ID or id (dry run first)', async () => {
    const d = await populate();
    const found = await run(['find', '--riot', 'player alice#vn1']);
    expect(found.code).toBe(0);
    expect(JSON.parse(found.out)).toMatchObject({ id: d.alice.user.id, posts: 1, comments: 1, reviews: 1, votes: 1, lfgPosts: 1, media: 3 });
    expect((await run(['find', '--riot', 'nobody#000'])).code).toBe(1);
    expect((await run(['find', '--riot', 'broken'])).code).toBe(1);

    const exp = await run(['export', '--id', d.alice.user.id]);
    expect(exp.code).toBe(0);
    expect(JSON.parse(exp.out).posts[0].media[0].url).toBe(`https://c.example/v1/media/${d.k1}`);

    const dry = await run(['delete', '--id', d.alice.user.id]);
    expect(dry.code).toBe(2);
    expect(dry.out).toContain('DRY RUN');
    expect(count('users', 'id = ?', d.alice.user.id)).toBe(1);

    const done = await run(['delete', '--riot', 'Player alice#VN1', '--yes']);
    expect(done.code).toBe(0);
    expect(count('users', 'id = ?', d.alice.user.id)).toBe(0);
    expect(fs.existsSync(publicFile(d.k1))).toBe(false);
    expect((await run(['delete', '--id', d.alice.user.id, '--yes'])).code).toBe(1);
  });

  it('lists, restores and purges quarantined files; un-hides falsely reported posts', async () => {
    const a = await e.login('alice');
    const key = await upload(a.token);
    const post = (await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x', media: [key] } })).json;
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((n) => e.login(n)));
    reporters.forEach((r) => e.mature(r.user.id));
    for (const r of reporters) {
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'post', targetId: post.id, reason: 'wrong' } });
    }
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(404);
    expect((await run(['quarantine', 'list'])).out).toContain(key);

    const un = await run(['unhide', 'post', post.id]);
    expect(un.code).toBe(0);
    expect(un.out).toContain('1 file');
    expect((await e.req('GET', `/v1/posts/${post.id}`, { token: a.token })).status).toBe(200);
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(200);
    expect(count('reports')).toBe(0);
    expect((await run(['quarantine', 'list'])).out).toContain('no quarantined');

    // restore / purge on a manually quarantined file
    const key2 = await upload(a.token);
    await quarantineMedia(e.mediaDeps(), [key2]);
    expect((await run(['quarantine', 'restore', key2])).code).toBe(0);
    expect((await e.req('GET', `/v1/media/${key2}`)).status).toBe(200);
    await quarantineMedia(e.mediaDeps(), [key2]);
    expect((await run(['quarantine', 'purge', key2])).code).toBe(0);
    expect(e.repo.getMedia(key2)).toBeNull();
    expect((await run(['quarantine', 'restore', key2])).code).toBe(1);
    expect((await run(['unhide', 'post', '00000000-0000-4000-8000-000000000000'])).code).toBe(1);
  });

  it('stats, sweep, help and unknown commands', async () => {
    await populate();
    const stats = JSON.parse((await run(['stats'])).out);
    expect(stats).toMatchObject({ users: 3, posts: 2, comments: 2, media: 4, media_quarantined: 0 });
    expect(stats.media_bytes).toBe(PNG.length * 4);
    expect(JSON.parse((await run(['sweep'])).out)).toHaveProperty('orphanMediaDeleted', 0);
    expect((await run(['help'])).out).toContain('operator CLI');
    expect((await run([])).code).toBe(0);
    expect((await run(['frobnicate'])).code).toBe(1);
    void SKIN_B;
  });
});
