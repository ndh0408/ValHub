import path from 'node:path';
import { serve } from '@hono/node-server';
import { createAppWithCtx } from './app.js';
import { loadConfig } from './config.js';
import { ValorantContentCatalog } from './content.js';
import { openDatabase } from './db/database.js';
import { startLoadMonitor } from './load.js';
import { SqliteRepo } from './db/sqlite-repo.js';
import { DiskMediaStore } from './media.js';
import { fetchRiotUserinfo, guardRiotUserinfo } from './riot.js';
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
  content,
  riotUserinfo: guardRiotUserinfo(fetchRiotUserinfo),
  loadProbe: load.lagMs,
  logError: (m) => console.error(m),
});

// Minimal access log: method, path (no query string, no headers), status, duration.
const handler = async (req: Request, env: unknown) => {
  const started = Date.now();
  const res = await app.fetch(req, env);
  const { pathname } = new URL(req.url);
  if (pathname !== '/healthz') {
    console.log(`${req.method} ${pathname} ${res.status} ${Date.now() - started}ms`);
  }
  return res;
};

const server = serve({ fetch: handler, port: config.port, hostname: '0.0.0.0' }, (info) => {
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
