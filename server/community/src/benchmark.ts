import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { performance } from 'node:perf_hooks';
import { openDatabase } from './db/database.js';
import { SqliteRepo } from './db/sqlite-repo.js';

function measure(fn: () => unknown, iterations: number): { medianMs: number; p95Ms: number } {
  for (let i = 0; i < 5; i++) fn();
  const samples: number[] = [];
  for (let i = 0; i < iterations; i++) { const start = performance.now(); fn(); samples.push(performance.now() - start); }
  samples.sort((a, b) => a - b);
  return { medianMs: samples[Math.floor(samples.length / 2)]!, p95Ms: samples[Math.ceil(samples.length * 0.95) - 1]! };
}

/** Synthetic, isolated query benchmark. Never opens a caller-supplied or production database. */
export async function benchmark(rows = 100_000, iterations = 31): Promise<Record<string, unknown>> {
  if (!Number.isSafeInteger(rows) || rows < 1000 || rows > 1_000_000 ||
      !Number.isSafeInteger(iterations) || iterations < 5 || iterations > 1000) throw new Error('Invalid benchmark size');
  const base = path.resolve(os.tmpdir());
  const dir = await fs.mkdtemp(path.join(base, 'valvn-query-bench-'));
  const db = openDatabase(path.join(dir, 'bench.db'));
  try {
    const users = 1000;
    const user = (n: number) => n.toString(16).padStart(32, '0');
    const insertUser = db.prepare('INSERT INTO users(id, created_at, updated_at) VALUES(?,0,0)');
    const insertMedia = db.prepare('INSERT INTO media(key,user_id,content_type,size,created_at) VALUES(?,?,\'image/png\',1024,0)');
    const insertVote = db.prepare('INSERT INTO skin_votes(user_id,skin_uuid,weapon_uuid,created_at) VALUES(?,?,?,0)');
    const insertReview = db.prepare('INSERT INTO skin_reviews(id,user_id,skin_uuid,weapon_uuid,rating,created_at,updated_at) VALUES(?,?,?,?,?,0,0)');
    db.transaction(() => {
      for (let i = 0; i < users; i++) insertUser.run(user(i));
      for (let i = 0; i < rows; i++) {
        insertMedia.run(`u/${user(i % users)}/${i.toString(16).padStart(32, '0')}.png`, user(i % users));
        const skin = `skin-${Math.floor(i / users)}`;
        insertVote.run(user(i % users), skin, 'weapon');
        insertReview.run(`review-${i}`, user(i % users), skin, 'weapon', i % 5 + 1);
      }
    })();
    db.pragma('optimize');
    const repo = new SqliteRepo(db);
    const total = db.prepare('SELECT COALESCE(SUM(size), 0) AS n FROM media');
    const perUser = db.prepare('SELECT COALESCE(SUM(size), 0) AS n FROM media WHERE user_id = ?');
    const queries = {
      mediaSumGlobal: measure(() => total.get(), iterations),
      mediaSumUser: measure(() => perUser.get(user(1)), iterations),
      mediaRepoGlobal: measure(() => repo.mediaBytes(), iterations),
      mediaRepoUser: measure(() => repo.mediaBytes(user(1)), iterations),
      topSkins: measure(() => repo.topSkins({ limit: 20 }), iterations),
      ratingStats20: measure(() => repo.ratingStats(Array.from({ length: 20 }, (_, i) => `skin-${i}`)), iterations),
    };
    const plans = {
      mediaSumGlobal: db.prepare('EXPLAIN QUERY PLAN SELECT COALESCE(SUM(size), 0) FROM media').all(),
      mediaSumUser: db.prepare('EXPLAIN QUERY PLAN SELECT COALESCE(SUM(size), 0) FROM media WHERE user_id = ?').all(user(1)),
    };
    return { synthetic: true, node: process.version, platform: `${process.platform}/${process.arch}`,
      users, rowsPerTable: rows, iterations, queries, plans };
  } finally {
    db.close();
    // Explicitly verify the generated target stays beneath the named temporary prefix before recursive cleanup.
    const relative = path.relative(base, path.resolve(dir));
    if (relative.startsWith('valvn-query-bench-') && !relative.includes(path.sep) && !path.isAbsolute(relative)) {
      await fs.rm(dir, { recursive: true, force: true });
    }
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  console.log(JSON.stringify(await benchmark(Number(process.argv[2] ?? 100_000)), null, 2));
}
