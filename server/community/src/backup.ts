import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import Database from 'better-sqlite3';
import { execFileSync } from 'node:child_process';
import { MEDIA_KEY_RE } from './media.js';
import { openDatabase } from './db/database.js';
import { SqliteRepo } from './db/sqlite-repo.js';
import { DiskMediaStore } from './media.js';
import { ErasureLedger } from './erasures.js';

export async function extractBackup(archive: string, dest: string): Promise<void> {
  const names = execFileSync('tar', ['tzf', archive], { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 }).trim().split('\n');
  for (const name of names) {
    if (!/^(\.\/)?(?:snap\.db|erasures\.jsonl|media(?:\/[a-z0-9./_-]*)?)?\/?$/.test(name) || name.split('/').includes('..')) throw new Error('Unsafe archive path');
  }
  const types = execFileSync('tar', ['tvzf', archive], { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
  if (types.trim().split('\n').some((line) => !/^[d-]/.test(line))) throw new Error('Archive links are not allowed');
  await fs.mkdir(dest, { recursive: true, mode: 0o700 });
  execFileSync('tar', ['xzf', archive, '-C', dest, '--no-same-owner', '--no-same-permissions']);
  await verifyBackup(dest);
}

/** Check a staged restore, never the live database. Verify DB/FKs, row counts and every active image size. */
export async function verifyBackup(dir: string, file = 'snap.db'): Promise<Record<string, number>> {
  new ErasureLedger(path.join(dir, 'erasures.jsonl')).entries();
  const db = new Database(path.join(dir, file), { readonly: true, fileMustExist: true });
  try {
    if (db.pragma('integrity_check', { simple: true }) !== 'ok' || (db.pragma('foreign_key_check') as unknown[]).length !== 0) throw new Error('Backup database checks failed');
    const rows = db.prepare("SELECT key, size FROM media WHERE status = 'active'").all() as { key: string; size: number }[];
    for (const row of rows) {
      if (!MEDIA_KEY_RE.test(row.key)) throw new Error('Invalid backup media key');
      const stat = await fs.stat(path.join(dir, 'media', row.key));
      if (!stat.isFile() || stat.size !== row.size) throw new Error('Backup media size mismatch');
    }
    const counts: Record<string, number> = { mediaFiles: rows.length };
    for (const table of ['users', 'posts', 'comments', 'skin_votes', 'skin_reviews', 'media']) {
      counts[table] = (db.prepare(`SELECT COUNT(*) AS n FROM ${table}`).get() as { n: number }).n;
    }
    return counts;
  } finally { db.close(); }
}

/** Exercise migrations and erasure replay on the extracted copy; never opens the live volume. */
export async function drillBackup(dir: string): Promise<Record<string, number>> {
  await fs.copyFile(path.join(dir, 'snap.db'), path.join(dir, 'community.db'));
  const db = openDatabase(path.join(dir, 'community.db'));
  try {
    await new ErasureLedger(path.join(dir, 'erasures.jsonl')).replay({
      repo: new SqliteRepo(db),
      media: new DiskMediaStore(path.join(dir, 'media'), path.join(dir, 'quarantine')),
      now: Date.now,
    });
  } finally { db.close(); }
  return verifyBackup(dir, 'community.db');
}

/** Online SQLite snapshot then copy active media. A racing deletion fails the backup safely. */
export async function stageBackup(data: string, stage: string): Promise<void> {
  await fs.mkdir(stage, { recursive: true, mode: 0o700 });
  const source = new Database(path.join(data, 'community.db'), { fileMustExist: true });
  try { await source.backup(path.join(stage, 'snap.db')); } finally { source.close(); }
  const snap = new Database(path.join(stage, 'snap.db'));
  try {
    // The online snapshot inherits WAL mode. Make it a standalone DB so verification
    // cannot leave snap.db-wal/-shm files in the archive (restore rejects extra paths).
    snap.pragma('journal_mode = DELETE');
    const rows = snap.prepare("SELECT key FROM media WHERE status = 'active'").all() as { key: string }[];
    await fs.mkdir(path.join(stage, 'media'), { recursive: true });
    for (const row of rows) {
      if (!MEDIA_KEY_RE.test(row.key)) throw new Error('Invalid backup media key');
      const dest = path.join(stage, 'media', row.key);
      await fs.mkdir(path.dirname(dest), { recursive: true });
      await fs.copyFile(path.join(data, 'media', row.key), dest);
    }
    await fs.copyFile(path.join(data, 'erasures.jsonl'), path.join(stage, 'erasures.jsonl')).catch((e: NodeJS.ErrnoException) => {
      if (e.code !== 'ENOENT') throw e;
    });
  } finally { snap.close(); }
  await verifyBackup(stage);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [cmd, dir, dest] = process.argv.slice(2);
  if (cmd === 'stage' && dir && dest) await stageBackup(dir, dest);
  else if (cmd === 'extract' && dir && dest) await extractBackup(dir, dest);
  else if (cmd === 'verify' && dir) console.log(JSON.stringify(await verifyBackup(dir)));
  else if (cmd === 'drill' && dir) console.log(JSON.stringify(await drillBackup(dir)));
  else if (cmd === 'health' && dir) {
    const now = Date.now();
    const maxAge = (Number(process.env.BACKUP_INTERVAL_SECONDS ?? 86400) * 2 + 3600) * 1000;
    const latest = (await fs.stat(path.join(dir, 'last-success'))).mtimeMs;
    const drill = (await fs.stat(path.join(dir, 'last-drill'))).mtimeMs;
    if (now - latest > maxAge || now - drill > 8 * 86400_000) process.exitCode = 1;
  } else throw new Error('Usage: backup stage <data> <stage> | verify <stage> | health <backup>');
}
