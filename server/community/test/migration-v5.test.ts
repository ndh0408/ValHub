import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import Database from 'better-sqlite3';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { hashUserId } from '../src/crypto.js';
import { DEFAULT_MIGRATIONS_DIR, migrate } from '../src/db/database.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';
import { DiskMediaStore } from '../src/media.js';
import { sweep } from '../src/sweeper.js';
import { migrationNames, PEPPER, PNG } from './helpers.js';

const NOW = Date.UTC(2026, 8, 30, 12, 0, 0);
const DAY = 86400_000;
const uid = (n: string) => hashUserId(PEPPER, `puuid-${n}`);
const key = (u: string, c: string) => `u/${u}/${c.repeat(32)}.png`;

let dir: string;
let db: Database.Database;
const A = uid('a');
const B = uid('b');
const K = { visible: key(A, '1'), hidden: key(A, '2'), orphan: key(A, '3'), fresh: key(B, '4') };
const POST_VISIBLE = '00000000-0000-4000-8000-0000000000a1';
const POST_HIDDEN = '00000000-0000-4000-8000-0000000000a2';

beforeEach(() => {
  dir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-mig5-'));
  const old = path.join(dir, 'old');
  fs.mkdirSync(old);
  for (const f of ['0001_init.sql', '0002_reviews.sql', '0003_lfg_v2.sql', '0004_scopes.sql']) {
    fs.copyFileSync(path.join(DEFAULT_MIGRATIONS_DIR, f), path.join(old, f));
  }
  db = new Database(path.join(dir, 'community.db'));
  db.pragma('foreign_keys = ON');
  expect(migrate(db, old)).toHaveLength(4);

  for (const [id, name] of [[A, 'alice'], [B, 'bob']] as const) {
    db.prepare(
      "INSERT INTO users (id, game_name, tag_line, region, created_at, updated_at) VALUES (?, ?, 'VN1', 'ap', ?, ?)",
    ).run(id, name, NOW - 90 * DAY, NOW - 90 * DAY);
  }
  const media = db.prepare('INSERT INTO media (key, user_id, content_type, size, created_at) VALUES (?, ?, ?, ?, ?)');
  media.run(K.visible, A, 'image/png', PNG.length, NOW - 10 * DAY);
  media.run(K.hidden, A, 'image/png', PNG.length, NOW - 10 * DAY);
  media.run(K.orphan, A, 'image/png', PNG.length, NOW - 5 * DAY); // uploaded, never used
  media.run(K.fresh, B, 'image/png', PNG.length, NOW - 60_000); // uploaded a minute ago, not used yet
  const post = db.prepare(
    "INSERT INTO posts (id, user_id, kind, body, media, hidden, created_at) VALUES (?, ?, 'text', 'x', ?, ?, ?)",
  );
  post.run(POST_VISIBLE, A, JSON.stringify([K.visible]), 0, NOW - 9 * DAY);
  post.run(POST_HIDDEN, A, JSON.stringify([K.hidden]), 1, NOW - 9 * DAY);
  const report = db.prepare(
    "INSERT INTO reports (target_type, target_id, reporter_id, reason, created_at) VALUES ('post', ?, ?, 'spam', ?)",
  );
  report.run(POST_HIDDEN, B, NOW - 8 * DAY);
  report.run(POST_HIDDEN, A, NOW - 8 * DAY);
});

afterEach(() => {
  db.close();
  fs.rmSync(dir, { recursive: true, force: true, maxRetries: 5, retryDelay: 50 });
});

describe('migration 0005 on a database with 0001-0004 data', () => {
  it('applies only 0005, keeps every row, backfills media attachment and rebuilds reports', () => {
    expect(migrate(db)).toEqual(migrationNames().slice(4));
    expect(migrate(db)).toEqual([]);
    const rows = Object.fromEntries(
      (db.prepare('SELECT key, post_id, status, quarantined_at FROM media').all() as { key: string }[]).map((r) => [r.key, r]),
    );
    expect(rows).toEqual({
      [K.visible]: { key: K.visible, post_id: POST_VISIBLE, status: 'active', quarantined_at: null },
      [K.hidden]: { key: K.hidden, post_id: POST_HIDDEN, status: 'active', quarantined_at: null },
      [K.orphan]: { key: K.orphan, post_id: null, status: 'active', quarantined_at: null },
      [K.fresh]: { key: K.fresh, post_id: null, status: 'active', quarantined_at: null },
    });
    expect(db.prepare('SELECT COUNT(*) AS n FROM posts').get()).toEqual({ n: 2 });
    // reports: same rows, same primary key, but no foreign key to users any more
    expect(db.prepare('SELECT target_id, reporter_id, reason FROM reports ORDER BY reporter_id').all()).toHaveLength(2);
    expect(() =>
      db
        .prepare("INSERT INTO reports (target_type, target_id, reporter_id, reason, created_at) VALUES ('post', ?, 'anon-0123456789abcdef', '', ?)")
        .run(POST_VISIBLE, NOW),
    ).not.toThrow();
    const names = (db.prepare("SELECT name FROM sqlite_master WHERE type = 'index'").all() as { name: string }[]).map((r) => r.name);
    for (const n of ['idx_media_post', 'idx_media_orphans', 'idx_media_quarantine', 'idx_reports_reporter', 'idx_reports_created']) {
      expect(names, n).toContain(n);
    }
    const idx = (sql: string) => (db.prepare(`EXPLAIN QUERY PLAN ${sql}`).all() as { detail: string }[]).map((r) => r.detail).join(' | ');
    expect(idx("SELECT * FROM media WHERE status = 'active' AND post_id IS NULL AND created_at < 5")).toContain('idx_media_orphans');
    expect(idx('DELETE FROM reports WHERE created_at < 5')).toContain('idx_reports_created');
  });

  it('the first sweep quarantines files of posts hidden before the feature and purges old orphans, nothing else', async () => {
    migrate(db);
    const media = new DiskMediaStore(path.join(dir, 'media'), path.join(dir, 'quarantine'));
    for (const k of Object.values(K)) await media.put(k, PNG);
    const repo = new SqliteRepo(db);
    const r = await sweep({ repo, media, now: () => NOW });
    expect(r).toMatchObject({ hiddenQuarantined: 1, orphanMediaDeleted: 1, quarantinePurged: 0, strayFilesDeleted: 0 });
    expect(repo.getMedia(K.hidden)!.status).toBe('quarantined');
    expect(fs.existsSync(path.join(dir, 'quarantine', ...K.hidden.split('/')))).toBe(true);
    expect(fs.existsSync(path.join(dir, 'media', ...K.hidden.split('/')))).toBe(false);
    expect(repo.getMedia(K.orphan)).toBeNull(); // 5 days old, never attached
    expect(fs.existsSync(path.join(dir, 'media', ...K.orphan.split('/')))).toBe(false);
    expect(repo.getMedia(K.visible)!.status).toBe('active');
    expect(repo.getMedia(K.fresh)).not.toBeNull(); // younger than 24 h: might still be about to be attached
    // A second sweep changes nothing.
    expect(await sweep({ repo, media, now: () => NOW })).toMatchObject({ hiddenQuarantined: 0, orphanMediaDeleted: 0 });
  });

  it('account deletion works on the migrated schema (reports anonymised, no foreign key error)', async () => {
    migrate(db);
    const repo = new SqliteRepo(db);
    repo.deleteAccountRows(B);
    expect(repo.getUser(B)).toBeNull();
    const kept = db.prepare('SELECT reporter_id, reason FROM reports WHERE target_id = ?').all(POST_HIDDEN) as { reporter_id: string; reason: string }[];
    expect(kept).toHaveLength(2);
    expect(kept.filter((k) => k.reporter_id.startsWith('anon-'))).toEqual([{ reporter_id: expect.stringMatching(/^anon-/), reason: '' }]);
  });
});
