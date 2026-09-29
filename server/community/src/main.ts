import path from 'node:path';
import { serve } from '@hono/node-server';
import { createApp } from './app.js';
import { loadConfig } from './config.js';
import { openDatabase } from './db/database.js';
import { SqliteRepo } from './db/sqlite-repo.js';
import { DiskMediaStore } from './media.js';
import { fetchRiotUserinfo } from './riot.js';

let config;
try {
  config = loadConfig(process.env);
} catch (e) {
  console.error((e as Error).message);
  process.exit(1);
}

const db = openDatabase(path.join(config.dataDir, 'community.db'));
const repo = new SqliteRepo(db);
const media = new DiskMediaStore(path.join(config.dataDir, 'media'));

const app = createApp({ repo, media, config, riotUserinfo: fetchRiotUserinfo });

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

// Periodic housekeeping: old rate-limit windows + long-expired LFG posts.
const cleanup = () => {
  try {
    repo.cleanup(Date.now());
  } catch (e) {
    console.error(`cleanup failed: ${(e as Error).message}`);
  }
};
cleanup();
const timer = setInterval(cleanup, 10 * 60_000);
timer.unref();

const shutdown = (signal: string) => {
  console.log(`${signal} received, shutting down`);
  clearInterval(timer);
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
