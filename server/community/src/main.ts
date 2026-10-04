import path from 'node:path';
import fs from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import { serve } from '@hono/node-server';
import { createAppWithCtx } from './app.js';
import { loadConfig } from './config.js';
import { ValorantContentCatalog } from './content.js';
import { openDatabase } from './db/database.js';
import { startLoadMonitor } from './load.js';
import { SqliteRepo } from './db/sqlite-repo.js';
import { DiskMediaStore } from './media.js';
import { fetchRiotUserinfo, guardRiotUserinfo } from './riot.js';
import { fetchRiotOwnership } from './riot-ownership.js';
import { sweep } from './sweeper.js';
import { ErasureLedger } from './erasures.js';

let config;
try {
  config = loadConfig(process.env);
} catch (e) {
  console.error((e as Error).message);
  process.exit(1);
}

const db = openDatabase(path.join(config.dataDir, 'community.db'));
const repo = new SqliteRepo(db);
const media = new DiskMediaStore(path.join(config.dataDir, 'media'), path.join(config.dataDir, 'quarantine'));
const erasureLedger = new ErasureLedger(path.join(config.dataDir, 'erasures.jsonl'));
await erasureLedger.replay({ repo, media, now: Date.now });
const content = new ValorantContentCatalog({ snapshotFile: path.join(config.dataDir, 'catalog.json'), log: (m) => console.error(m) });
await content.restoreSnapshot();
repo.canonicalizeSkins((id) => content.resolveSkin(id));
void content.warm(); // load the game-content catalog in the background (requests never wait for it)

const load = startLoadMonitor(); // event-loop lag -> 503 load shedding (see load.ts)

const { app, ctx } = createAppWithCtx({
  repo,
  media,
  config,
  erasureLedger,
  deepHealth: async () => {
    const disk = await fs.statfs(config.dataDir);
    const probe = path.join(config.dataDir, `.health-${randomUUID()}`);
    let writable = false;
    try { await fs.writeFile(probe, '', { flag: 'wx', mode: 0o600 }); writable = true; }
    catch { writable = false; }
    finally { await fs.unlink(probe).catch(() => {}); }
    const wal = await fs.stat(path.join(config.dataDir, 'community.db-wal')).catch(() => null);
    return { writable, freeBytes: disk.bavail * disk.bsize, walBytes: wal?.size ?? 0 };
  },
  content,
  riotUserinfo: guardRiotUserinfo(fetchRiotUserinfo),
  riotOwnership: fetchRiotOwnership,
  loadProbe: load.lagMs,
  logError: (m) => console.error(m),
  logAccess: (entry) => console.log(JSON.stringify(entry)),
});

const server = serve({ fetch: app.fetch, port: config.port, hostname: '0.0.0.0' }, (info) => {
  console.log(`valvn-community listening on :${info.port} (data: ${config.dataDir})`);
});

// Periodic sweeper (unref'd: never keeps the process alive): orphan uploads, quarantine expiry, stray files,
// old reports (12 months), reports on deleted content, old rate-limit windows, expired LFG rows.
let sweeping = false;
const runSweep = async () => {
  if (sweeping) return;
  sweeping = true;
  try {
    const r = await sweep({
      repo,
      media,
      now: () => Date.now(),
      logError: (m) => console.error(m),
      prune: () => ctx.pruneMemory(),
      content,
    });
    const changed = Object.entries(r).filter(([, n]) => n > 0);
    if (changed.length > 0) console.log(`sweep: ${changed.map(([k, n]) => `${k}=${n}`).join(' ')}`);
  } catch (e) {
    console.error(`sweep failed: ${(e as Error).message}`);
  } finally {
    sweeping = false;
  }
};
const first = setTimeout(() => void runSweep(), 5_000);
first.unref();
const timer = setInterval(() => void runSweep(), 10 * 60_000);
timer.unref();
const metricsTimer = setInterval(() => {
  const counts = ctx.stats.drain();
  if (Object.keys(counts).length > 0) console.log(JSON.stringify({ security: counts, loopLagMs: load.lagMs() }));
}, 60_000);
metricsTimer.unref();
if ('keepAliveTimeout' in server) server.keepAliveTimeout = 120_000;
if ('headersTimeout' in server) server.headersTimeout = 125_000;

const shutdown = (signal: string) => {
  console.log(`${signal} received, shutting down`);
  clearInterval(timer);
  clearInterval(metricsTimer);
  clearTimeout(first);
  load.stop();
  server.close(() => {
    db.close();
    process.exit(0);
  });
  setTimeout(() => {
    db.close();
    process.exit(0);
  }, 10_000).unref();
};
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
