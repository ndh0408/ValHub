import fs from 'node:fs/promises';
import path from 'node:path';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { pathToFileURL } from 'node:url';

const MiB = 1024 * 1024;
const day = 86_400_000;
export type AlertCode = 'probe_failed' | 'disk_unwritable' | 'disk_low' | 'wal_large' |
  'loop_lag' | 'server_errors' | 'backup_stale' | 'drill_stale';
export interface HealthSample {
  writable: boolean;
  freeBytes: number;
  walBytes: number;
  loopLagMs: number;
  http: { requests: number; serverErrors: number };
}

/** Reject partial/non-numeric health replies; raw HTTP bodies never reach the alert hook or logs. */
export function parseHealth(value: unknown): HealthSample {
  if (typeof value !== 'object' || value === null) throw new Error('Invalid health');
  const v = value as Record<string, unknown>;
  const http = v.http as Record<string, unknown> | undefined;
  const finite = (n: unknown): n is number => typeof n === 'number' && Number.isFinite(n) && n >= 0;
  if (typeof v.writable !== 'boolean' || !finite(v.freeBytes) || !finite(v.walBytes) ||
      !finite(v.loopLagMs) || !http || !finite(http.requests) || !finite(http.serverErrors) ||
      http.serverErrors > http.requests) throw new Error('Invalid health');
  return { writable: v.writable, freeBytes: v.freeBytes, walBytes: v.walBytes,
    loopLagMs: v.loopLagMs, http: { requests: http.requests, serverErrors: http.serverErrors } };
}

export function localHealthUrl(raw: string): URL {
  const url = new URL(raw);
  if (url.protocol !== 'http:' || !['127.0.0.1', '[::1]'].includes(url.hostname) ||
      url.username || url.password || url.search || url.hash || url.pathname !== '/healthz/deep') {
    throw new Error('Watchdog URL must be an uncredentialed loopback /healthz/deep endpoint');
  }
  return url;
}

/** Three consecutive bad samples trigger transient alerts. Persistent disk/backup risks alert immediately. */
export class WatchdogState {
  private probeFailures = 0;
  private lagFailures = 0;
  private errorFailures = 0;
  private previous?: HealthSample;

  sample(health: HealthSample | null, now: number, backupAt: number | null, drillAt: number | null,
    backupMaxAge = 26 * 3_600_000): AlertCode[] {
    const alerts: AlertCode[] = [];
    if (!health) {
      if (++this.probeFailures >= 3) alerts.push('probe_failed');
      this.lagFailures = 0;
      this.errorFailures = 0;
      this.previous = undefined;
    } else {
      this.probeFailures = 0;
      if (!health.writable) alerts.push('disk_unwritable');
      if (health.freeBytes < 128 * MiB) alerts.push('disk_low');
      if (health.walBytes > 128 * MiB) alerts.push('wal_large');
      this.lagFailures = health.loopLagMs >= 200 ? this.lagFailures + 1 : 0;
      if (this.lagFailures >= 3) alerts.push('loop_lag');
      const requests = health.http.requests - (this.previous?.http.requests ?? health.http.requests);
      const errors = health.http.serverErrors - (this.previous?.http.serverErrors ?? health.http.serverErrors);
      this.errorFailures = requests >= 20 && errors >= 0 && errors / requests >= 0.05 ? this.errorFailures + 1 : 0;
      if (this.errorFailures >= 3) alerts.push('server_errors');
      this.previous = health;
    }
    // A future timestamp is also invalid: an incorrect host clock must not hide stale backups.
    if (backupAt === null || backupAt > now + 60_000 || now - backupAt > backupMaxAge) alerts.push('backup_stale');
    if (drillAt === null || drillAt > now + 60_000 || now - drillAt > 8 * day) alerts.push('drill_stale');
    return alerts;
  }
}

export async function readHealth(url: URL): Promise<HealthSample | null> {
  try {
    const response = await fetch(url, { redirect: 'error', signal: AbortSignal.timeout(5_000) });
    // Low disk legitimately returns 503 with a usable body. Never follow a redirect out of loopback.
    if (response.status !== 200 && response.status !== 503) return null;
    if (!response.body) return null;
    const reader = response.body.getReader();
    const chunks: Uint8Array[] = [];
    let length = 0;
    for (;;) {
      const chunk = await reader.read();
      if (chunk.done) break;
      length += chunk.value.byteLength;
      if (length > 16_384) { await reader.cancel(); return null; }
      chunks.push(chunk.value);
    }
    return parseHealth(JSON.parse(Buffer.concat(chunks).toString('utf8')));
  } catch { return null; }
}

async function markerTime(dir: string, name: string): Promise<number | null> {
  try { const stat = await fs.stat(path.join(dir, name)); return stat.isFile() ? stat.mtimeMs : null; }
  catch { return null; }
}

const runFile = promisify(execFile);
/** Optional operator executable: fixed codes only, no shell interpolation or tokens/user content. */
export async function alertHook(file: string, codes: AlertCode[], recovered: boolean): Promise<void> {
  if (!path.isAbsolute(file)) throw new Error('Alert hook must be an absolute executable path');
  await runFile(file, [recovered ? 'recovered' : 'alert', ...codes], { timeout: 10_000, maxBuffer: 16_384,
    env: { PATH: process.env.PATH, NODE_ENV: 'production' }, windowsHide: true });
}

export async function runWatchdog(): Promise<void> {
  const url = localHealthUrl(process.env.WATCHDOG_URL ?? 'http://127.0.0.1:8080/healthz/deep');
  const backupDir = process.env.WATCHDOG_BACKUP_DIR ?? '/backup';
  const interval = Number(process.env.WATCHDOG_INTERVAL_SECONDS ?? 60);
  const backupInterval = Number(process.env.BACKUP_INTERVAL_SECONDS ?? 86400);
  if (!Number.isFinite(interval) || interval < 10 || interval > 3600 ||
      !Number.isFinite(backupInterval) || backupInterval < 60) throw new Error('Invalid watchdog interval');
  const state = new WatchdogState();
  const once = process.argv.includes('--once');
  let stopping = false;
  process.once('SIGTERM', () => { stopping = true; });
  process.once('SIGINT', () => { stopping = true; });
  let previous = '';
  let lastAlert = 0;
  do {
    const [health, backupAt, drillAt] = await Promise.all([
      readHealth(url), markerTime(backupDir, 'last-success'), markerTime(backupDir, 'last-drill'),
    ]);
    const now = Date.now();
    const codes = state.sample(health, now, backupAt, drillAt, (backupInterval + 7200) * 1000);
    const signature = codes.join(',');
    console.log(JSON.stringify({ watchdog: codes.length ? 'alert' : health ? 'ok' : 'warming', codes, at: now }));
    await fs.writeFile('/tmp/valvn-watchdog-heartbeat', String(now), { mode: 0o600 });
    if (signature !== previous || (codes.length > 0 && now - lastAlert >= 3_600_000)) {
      const hook = process.env.WATCHDOG_ALERT_HOOK;
      if (hook) {
        try { await alertHook(hook, codes, codes.length === 0); }
        catch { console.error(JSON.stringify({ watchdog: 'hook_failed' })); }
      }
      previous = signature;
      lastAlert = now;
    }
    if (once) { process.exitCode = codes.length > 0 || !health ? 1 : 0; break; }
    // Short chunks permit graceful shutdown without waiting a full sampling interval.
    for (let waited = 0; waited < interval && !stopping; waited++) {
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  } while (!stopping);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  await runWatchdog();
}
