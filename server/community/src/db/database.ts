import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import Database from 'better-sqlite3';

export type Db = Database.Database;

/** `migrations/` at the package root (works from both src/db and dist/db). */
export const DEFAULT_MIGRATIONS_DIR = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '..',
  '..',
  'migrations',
);

/** Opens (or creates) the SQLite database with WAL + foreign keys, then applies migrations. */
export function openDatabase(file: string, migrationsDir = DEFAULT_MIGRATIONS_DIR): Db {
  if (file !== ':memory:') fs.mkdirSync(path.dirname(file), { recursive: true });
  const db = new Database(file);
  if (file !== ':memory:') db.pragma('journal_mode = WAL');
  db.pragma('synchronous = NORMAL');
  db.pragma('foreign_keys = ON');
  db.pragma('busy_timeout = 5000');
  migrate(db, migrationsDir);
  return db;
}

/** Applies every `NNNN_*.sql` file not yet recorded in `schema_migrations`, in order. */
export function migrate(db: Db, migrationsDir = DEFAULT_MIGRATIONS_DIR): string[] {
  db.exec(`CREATE TABLE IF NOT EXISTS schema_migrations (
    name TEXT PRIMARY KEY,
    applied_at INTEGER NOT NULL
  )`);
  const applied = new Set(
    (db.prepare('SELECT name FROM schema_migrations').all() as { name: string }[]).map((r) => r.name),
  );
  const files = fs
    .readdirSync(migrationsDir)
    .filter((f) => /^\d+_.*\.sql$/.test(f))
    .sort();
  const newlyApplied: string[] = [];
  for (const f of files) {
    if (applied.has(f)) continue;
    const sql = fs.readFileSync(path.join(migrationsDir, f), 'utf8');
    db.transaction(() => {
      db.exec(sql);
      db.prepare('INSERT INTO schema_migrations (name, applied_at) VALUES (?, ?)').run(f, Date.now());
    })();
    newlyApplied.push(f);
  }
  return newlyApplied;
}
