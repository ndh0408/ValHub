import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import Database from 'better-sqlite3';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { hashUserId } from '../src/crypto.js';
import { countryFromAlpha3 } from '../src/geo/countries.js';
import { DEFAULT_MIGRATIONS_DIR, migrate } from '../src/db/database.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';
import { DiskMediaStore } from '../src/media.js';
import type { RiotUserinfoFn } from '../src/riot.js';
import { PEPPER, SECRET, SKIN_A, SKIN_B, WEAPON_1 } from './helpers.js';

const BASE = 'http://community.test';
const NOW = Date.UTC(2026, 8, 1, 12, 0, 0);
const uid = (name: string) => hashUserId(PEPPER, `puuid-${name}`);
const POST_ID = '00000000-0000-4000-8000-0000000000a1';
const COMMENT_ID = '00000000-0000-4000-8000-0000000000b1';
const REVIEW_ID = '00000000-0000-4000-8000-0000000000c1';
const LFG_ID = '00000000-0000-4000-8000-0000000000d1';

let dir: string;
let db: Database.Database;

beforeEach(() => {
  dir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-mig3-'));
  // A database exactly as production has it today: migrations 0001-0003 applied, with data.
  const oldDir = path.join(dir, 'old');
  fs.mkdirSync(oldDir);
  for (const f of ['0001_init.sql', '0002_reviews.sql', '0003_lfg_v2.sql']) {
    fs.copyFileSync(path.join(DEFAULT_MIGRATIONS_DIR, f), path.join(oldDir, f));
  }
  db = new Database(path.join(dir, 'community.db'));
  db.pragma('foreign_keys = ON');
  expect(migrate(db, oldDir)).toEqual(['0001_init.sql', '0002_reviews.sql', '0003_lfg_v2.sql']);

  const user = db.prepare(
    `INSERT INTO users (id, game_name, tag_line, card_id, rank_tier, region, created_at, updated_at)
     VALUES (?, ?, 'VN1', NULL, 12, ?, ?, ?)`,
  );
  user.run(uid('old1'), 'Player old1', 'ap', NOW - 40 * 86400_000, NOW - 40 * 86400_000);
  user.run(uid('old2'), 'Player old2', 'eu', NOW - 40 * 86400_000, NOW - 40 * 86400_000);
  db.prepare(
    `INSERT INTO posts (id, user_id, kind, body, media, payload, hidden, created_at)
     VALUES (?, ?, 'text', 'bài cũ', '[]', NULL, 0, ?)`,
  ).run(POST_ID, uid('old1'), NOW - 3 * 86400_000);
  db.prepare(
    `INSERT INTO comments (id, post_id, user_id, body, hidden, created_at) VALUES (?, ?, ?, 'bình luận cũ', 0, ?)`,
  ).run(COMMENT_ID, POST_ID, uid('old2'), NOW - 3 * 86400_000);
  const vote = db.prepare('INSERT INTO skin_votes (user_id, skin_uuid, weapon_uuid, created_at) VALUES (?, ?, ?, ?)');
  vote.run(uid('old1'), SKIN_A, WEAPON_1, NOW - 30 * 86400_000);
  vote.run(uid('old2'), SKIN_A, WEAPON_1, NOW - 2 * 86400_000);
  vote.run(uid('old2'), SKIN_B, WEAPON_1, NOW - 2 * 86400_000);
  db.prepare(
    `INSERT INTO skin_reviews (id, user_id, skin_uuid, weapon_uuid, rating, body, created_at, updated_at)
     VALUES (?, ?, ?, ?, 4, 'ổn', ?, ?)`,
  ).run(REVIEW_ID, uid('old1'), SKIN_A, WEAPON_1, NOW - 5 * 86400_000, NOW - 5 * 86400_000);
  db.prepare(
    `INSERT INTO lfg_posts (id, user_id, region, mode, party_code, slots, created_at, expires_at)
     VALUES (?, ?, 'ap', 'unrated', 'AAAAAA', 3, ?, ?)`,
  ).run(LFG_ID, uid('old1'), NOW - 60_000, NOW + 29 * 60_000);
});

afterEach(() => {
  db.close();
  fs.rmSync(dir, { recursive: true, force: true, maxRetries: 5, retryDelay: 50 });
});

const columns = (table: string) => (db.pragma(`table_info(${table})`) as { name: string }[]).map((c) => c.name);
const indexes = () => (db.prepare("SELECT name FROM sqlite_master WHERE type = 'index'").all() as { name: string }[]).map((r) => r.name);

function makeApp(country: string | undefined) {
  const riot: RiotUserinfoFn = async (token) => {
    const name = token.replace('good-', '');
    return { ok: true, puuid: `puuid-${name}`, gameName: `Player ${name}`, tagLine: 'VN1', country: countryFromAlpha3(country) };
  };
  const app = createApp({
    repo: new SqliteRepo(db),
    media: new DiskMediaStore(path.join(dir, 'media')),
    config: { sessionSecret: SECRET, pepper: PEPPER, publicBaseUrl: '', trustProxy: true },
    riotUserinfo: riot,
    now: () => NOW,
    logError: () => {},
  });
  const req = async (method: string, p: string, o: { token?: string; body?: unknown } = {}) => {
    const res = await app.request(`${BASE}${p}`, {
      method,
      headers: {
        ...(o.token ? { authorization: `Bearer ${o.token}` } : {}),
        ...(o.body !== undefined ? { 'content-type': 'application/json' } : {}),
      },
      body: o.body === undefined ? undefined : JSON.stringify(o.body),
    });
    const text = await res.text();
    return { status: res.status, json: text ? JSON.parse(text) : null };
  };
  const login = async (name: string, extra: Record<string, unknown> = {}) => {
    const res = await req('POST', '/v1/auth/riot', { body: { accessToken: `good-${name}`, region: 'ap', ...extra } });
    expect(res.status).toBe(200);
    return res.json as { token: string; user: Record<string, unknown> };
  };
  return { req, login };
}

describe('migration 0004 on a database with 0001-0003 data', () => {
  it('is additive: applies once, keeps every row, adds columns and indexes', () => {
    const before = {
      users: db.prepare('SELECT COUNT(*) AS n FROM users').get(),
      posts: db.prepare('SELECT COUNT(*) AS n FROM posts').get(),
      votes: db.prepare('SELECT COUNT(*) AS n FROM skin_votes').get(),
    };
    expect(migrate(db)).toEqual(['0004_scopes.sql', '0005_hardening.sql']);
    expect(migrate(db)).toEqual([]);
    expect(db.prepare('SELECT COUNT(*) AS n FROM users').get()).toEqual(before.users);
    expect(db.prepare('SELECT COUNT(*) AS n FROM posts').get()).toEqual(before.posts);
    expect(db.prepare('SELECT COUNT(*) AS n FROM skin_votes').get()).toEqual(before.votes);

    expect(columns('users')).toEqual(expect.arrayContaining(['country', 'language']));
    for (const t of ['posts', 'comments', 'skin_reviews']) {
      expect(columns(t), t).toEqual(expect.arrayContaining(['country', 'region', 'language']));
    }
    expect(columns('skin_votes')).toEqual(expect.arrayContaining(['country', 'region']));
    expect(columns('lfg_posts')).toContain('country');

    const idx = indexes();
    for (const name of [
      'idx_posts_country_feed', 'idx_posts_country_kind_feed', 'idx_posts_region_feed', 'idx_posts_region_kind_feed',
      'idx_posts_language_feed', 'idx_posts_activity', 'idx_lfg_status_country_feed', 'idx_lfg_activity',
      'idx_votes_country_skin', 'idx_votes_region_skin', 'idx_votes_country_weapon', 'idx_votes_region_weapon',
      'idx_votes_skin_country', 'idx_votes_skin_region', 'idx_reviews_skin_country', 'idx_reviews_skin_region',
      'idx_reviews_skin_language', 'idx_reviews_country_agg', 'idx_reviews_region_agg',
    ]) {
      expect(idx, name).toContain(name);
    }
  });

  it('backfills content region from the author; country and language stay NULL', () => {
    migrate(db);
    const one = (sql: string, ...p: unknown[]) => db.prepare(sql).get(...p);
    expect(one('SELECT country, region, language FROM posts WHERE id = ?', POST_ID)).toEqual({
      country: null,
      region: 'ap',
      language: null,
    });
    expect(one('SELECT country, region, language FROM comments WHERE id = ?', COMMENT_ID)).toEqual({
      country: null,
      region: 'eu', // old2 is on shard eu
      language: null,
    });
    expect(one('SELECT country, region, language FROM skin_reviews WHERE id = ?', REVIEW_ID)).toEqual({
      country: null,
      region: 'ap',
      language: null,
    });
    expect(db.prepare('SELECT user_id, country, region FROM skin_votes ORDER BY created_at, skin_uuid').all()).toEqual([
      { user_id: uid('old1'), country: null, region: 'ap' },
      { user_id: uid('old2'), country: null, region: 'eu' },
      { user_id: uid('old2'), country: null, region: 'eu' },
    ]);
    expect(one('SELECT country, language FROM users WHERE id = ?', uid('old1'))).toEqual({ country: null, language: null });
    expect(one('SELECT region, country, language, status, party_size FROM lfg_posts WHERE id = ?', LFG_ID)).toEqual({
      region: 'ap',
      country: null,
      language: 'vi',
      status: 'open',
      party_size: null,
    });
  });

  it('old content stays visible in global and (by shard) region scope, but not in a country scope', async () => {
    migrate(db);
    const { req, login } = makeApp('vnm');
    const posts = async (qs: string, token?: string) => (await req('GET', `/v1/posts?${qs}`, { token })).json.items.map((p: any) => p.id);
    expect(await posts('')).toEqual([POST_ID]); // unauthenticated → global
    expect(await posts('scope=global')).toEqual([POST_ID]);
    expect(await posts('scope=region&region=ap')).toEqual([POST_ID]);
    expect(await posts('scope=region&region=eu')).toEqual([]);
    expect(await posts('scope=country&country=VN')).toEqual([]);

    // Votes and reviews: old ones count globally and by shard, not by country.
    const top = async (qs: string) => (await req('GET', `/v1/skins/top?${qs}`)).json.items.map((i: any) => [i.skinUuid, i.votes]);
    expect(await top('')).toEqual([[SKIN_A, 2], [SKIN_B, 1]]);
    expect(await top('scope=region&region=eu')).toEqual([[SKIN_A, 1], [SKIN_B, 1]]);
    expect(await top('scope=region&region=ap')).toEqual([[SKIN_A, 1]]);
    expect(await top('scope=country&country=VN')).toEqual([]);
    const summary = async (qs: string) => (await req('GET', `/v1/skins/${SKIN_A}/summary?${qs}`)).json;
    expect(await summary('')).toMatchObject({ votes: 2, ratingCount: 1, ratingAvg: 4 });
    expect(await summary('region=ap')).toMatchObject({ votes: 1, ratingCount: 1 });
    expect(await summary('country=VN')).toMatchObject({ votes: 0, ratingCount: 0 });

    // LFG: the old post is found by its own region, not by country.
    const { token } = await login('old2', { region: 'ap' });
    const lfg = async (qs: string) => (await req('GET', `/v1/lfg?${qs}`, { token })).json.items.map((p: any) => p.id);
    expect(await lfg('region=ap')).toEqual([LFG_ID]);
    expect(await lfg('scope=global')).toEqual([LFG_ID]);
    expect(await lfg('scope=country&country=VN')).toEqual([]);
    const old = (await req('GET', '/v1/lfg?region=ap', { token })).json.items[0];
    expect(old).toMatchObject({ language: 'vi', partySize: 2, country: null, status: 'open', joins: 0 });

    // Old rows do not show up in /v1/communities (no country).
    expect((await req('GET', '/v1/communities?period=all')).json.items).toEqual([]);
  });

  it('backfills the user on next auth only; content keeps its creation-time values', async () => {
    migrate(db);
    const { req, login } = makeApp('vnm');
    const sess = await login('old1', { region: 'ap', language: 'vi' });
    expect(sess.user).toMatchObject({ country: 'VN', language: 'vi', region: 'ap' });
    expect(db.prepare('SELECT country, language FROM users WHERE id = ?').get(uid('old1'))).toEqual({
      country: 'VN',
      language: 'vi',
    });
    // The old post is untouched (still NULL country) ...
    expect(db.prepare('SELECT country, language FROM posts WHERE id = ?').get(POST_ID)).toEqual({ country: null, language: null });
    const old = (await req('GET', `/v1/posts/${POST_ID}`, { token: sess.token })).json;
    expect(old).toMatchObject({ country: null, region: 'ap', language: null, author: { country: 'VN', language: 'vi' } });
    // ... while a new post carries the author's current values.
    const fresh = (await req('POST', '/v1/posts', { token: sess.token, body: { kind: 'text', body: 'bài mới' } })).json;
    expect(fresh).toMatchObject({ country: 'VN', region: 'ap', language: 'vi' });
    const vn = (await req('GET', '/v1/posts?country=VN', { token: sess.token })).json.items.map((p: any) => p.id);
    expect(vn).toEqual([fresh.id]);
    expect((await req('GET', '/v1/communities?period=all')).json.items).toEqual([
      { country: 'VN', posts: 1, authors: 1, lfg: 0 },
    ]);
  });

  it('leaves the pre-v3 API responses valid for old clients (only additive fields)', async () => {
    migrate(db);
    const { req, login } = makeApp(undefined);
    const { token } = await login('old2', { region: 'eu' }); // no language sent: an old client
    const me = (await req('GET', '/v1/me', { token })).json;
    expect(me).toMatchObject({ id: uid('old2'), gameName: 'Player old2', region: 'eu', country: null, language: null });
    const feed = (await req('GET', '/v1/posts', { token })).json;
    // eu viewer without a country → region scope eu → the old ap post is not in it; global has it.
    expect(feed.items).toEqual([]);
    expect((await req('GET', '/v1/posts?scope=global', { token })).json.items[0]).toMatchObject({
      id: POST_ID,
      body: 'bài cũ',
      likes: 0,
      liked: false,
      comments: 1,
    });
    const comments = (await req('GET', `/v1/posts/${POST_ID}/comments`, { token })).json.items;
    expect(comments).toEqual([expect.objectContaining({ id: COMMENT_ID, postId: POST_ID, body: 'bình luận cũ' })]);
  });
});
