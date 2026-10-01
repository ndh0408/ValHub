import fs from 'node:fs';
import path from 'node:path';
import { describe, it, expect } from 'vitest';
import Database from 'better-sqlite3';
import { openDatabase, DEFAULT_MIGRATIONS_DIR, migrate } from '../src/db/database.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';

function check(db: Database.Database): void {
  const repo = new SqliteRepo(db);
  const sum = (db.prepare('SELECT COALESCE(SUM(size),0) AS n FROM media').get() as { n: number }).n;
  expect(repo.mediaBytes()).toBe(sum);
  for (const { id } of db.prepare('SELECT id FROM users').all() as { id: string }[]) {
    expect(repo.mediaBytes(id)).toBe((db.prepare('SELECT COALESCE(SUM(size),0) AS n FROM media WHERE user_id=?').get(id) as { n: number }).n);
  }
  expect(db.pragma('foreign_key_check')).toEqual([]);
}

describe('transactional media usage', () => {
  it('matches SUM after insertion, quarantine, resize, ownership change, rollback, cascade erasure', () => {
    const db = openDatabase(':memory:');
    try {
      db.exec("INSERT INTO users(id,created_at,updated_at) VALUES('a',0,0),('b',0,0)");
      db.exec("INSERT INTO media(key,user_id,content_type,size,created_at) VALUES('one','a','image/png',20,0),('two','a','image/png',30,0),('three','b','image/png',50,0)");
      check(db);
      db.exec("UPDATE media SET status='quarantined' WHERE key='one'");
      check(db);
      db.exec("UPDATE media SET size=25,user_id='b' WHERE key='one'");
      check(db);
      expect(() => db.transaction(() => { db.exec("DELETE FROM media WHERE key='two'"); throw new Error('crash'); })()).toThrow('crash');
      check(db);
      db.exec("DELETE FROM users WHERE id='b'");
      check(db);
      expect(db.prepare("SELECT * FROM user_media_bytes WHERE user_id='b'").get()).toBeUndefined();
      db.exec("DELETE FROM media WHERE key='two'");
      check(db);
      expect(new SqliteRepo(db).mediaBytes()).toBe(0);
      expect(new SqliteRepo(db).mediaBytes('missing')).toBe(0);
    } finally { db.close(); }
  });
  it('backfills existing media once and includes quarantined bytes', () => {
    const db = new Database(':memory:');
    try {
      db.pragma('foreign_keys = ON');
      db.exec('CREATE TABLE schema_migrations(name TEXT PRIMARY KEY, applied_at INTEGER NOT NULL)');
      for (const file of fs.readdirSync(DEFAULT_MIGRATIONS_DIR).filter((f) => /^\d+_.*\.sql$/.test(f) && f < '0011').sort()) {
        db.exec(fs.readFileSync(path.join(DEFAULT_MIGRATIONS_DIR, file), 'utf8'));
        db.prepare('INSERT INTO schema_migrations VALUES(?,0)').run(file);
      }
      db.exec("INSERT INTO users(id,created_at,updated_at) VALUES('a',0,0)");
      db.exec("INSERT INTO media(key,user_id,content_type,size,created_at,status) VALUES('one','a','image/png',20,0,'active'),('two','a','image/png',30,0,'quarantined')");
      expect(migrate(db)).toEqual(['0011_media_usage.sql']);
      expect(migrate(db)).toEqual([]);
      check(db);
      expect(new SqliteRepo(db).mediaBytes()).toBe(50);
      db.exec("DELETE FROM users WHERE id='a'");
      check(db);
    } finally { db.close(); }
  });
});
