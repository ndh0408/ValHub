import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { expect } from 'vitest';
import { createApp } from '../src/app.js';
import type { AppDeps, Tuning } from '../src/context.js';
import type { ContentCatalog } from '../src/content.js';
import { DEFAULT_MIGRATIONS_DIR, openDatabase, type Db } from '../src/db/database.js';
import { countryFromAlpha3 } from '../src/geo/countries.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';
import { DiskMediaStore } from '../src/media.js';
import type { RiotUserinfoFn } from '../src/riot.js';
import type { RiotOwnershipFn } from '../src/riot-ownership.js';


/** Names of every migration file, in order (tests must not hard-code the list: each work package adds some). */
export function migrationNames(): string[] {
  return fs
    .readdirSync(DEFAULT_MIGRATIONS_DIR)
    .filter((f) => /^\d+_.*\.sql$/.test(f))
    .sort();
}

export const SECRET = 'test-session-secret-0123456789abcdef';
export const PEPPER = 'test-pepper-0123456789abcdef-0123456';
export const BASE = 'http://community.test';

export const SKIN_A = '11111111-1111-4111-8111-111111111111';
export const SKIN_B = '22222222-2222-4222-8222-222222222222';
export const SKIN_C = '33333333-3333-4333-8333-333333333333';
export const WEAPON_1 = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
export const WEAPON_2 = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

/** Actual decodable pixels; header-only fixtures belong to parser tests. */
export const PNG = new Uint8Array(fs.readFileSync(new URL('./images/tiny.png', import.meta.url)));
export const JPEG = new Uint8Array(fs.readFileSync(new URL('./images/tiny.jpg', import.meta.url)));
export const WEBP = new Uint8Array(fs.readFileSync(new URL('./images/tiny.webp', import.meta.url)));

export interface SetupOptions {
  /** Fixtures testing totals use established accounts; abuse tests keep new accounts by default. */
  established?: boolean;
  tuning?: Partial<Tuning>;
  content?: ContentCatalog;
  riot?: RiotUserinfoFn;
  ownership?: RiotOwnershipFn;
  /** Event-loop lag probe for load shedding (ms). */
  loadProbe?: () => number;
  /** Receives the access log lines (route pattern, status, request id). */
  logAccess?: AppDeps['logAccess'];
  /** Overrides of the non-tuning config (rotation secret, proxy trust, public base URL). */
  config?: { sessionSecretPrev?: string; trustProxy?: boolean; publicBaseUrl?: string; lfgCodeInList?: boolean };
}

export interface Res {
  status: number;
  headers: Headers;
  json: any;
  bytes: Uint8Array;
}

export interface ReqOpts {
  body?: unknown;
  raw?: Uint8Array | string;
  token?: string;
  headers?: Record<string, string>;
  /** Explicitly test absence of the proof normally sent by the client. */
  omitOwnershipProof?: boolean;
}

export function setup(opts: SetupOptions = {}) {
  const db: Db = openDatabase(':memory:');
  const repo = new SqliteRepo(db, () => clock.t);
  const dataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-data-'));
  const mediaDir = path.join(dataDir, 'media');
  const quarantineDir = path.join(dataDir, 'quarantine');
  const media = new DiskMediaStore(mediaDir, quarantineDir);
  const clock = { t: Date.UTC(2026, 8, 1, 12, 0, 0) };
  const riotTokens: string[] = [];
  const errors: string[] = [];
  /** Riot `country` (alpha-3, as returned by /userinfo) per test user name; unset → Riot sends none. */
  const riotCountries: Record<string, string | undefined> = {};
  const riotProofs = new Map<string, string>();

  /** Tokens: good-<name> → accepted (puuid derived from name), down → network error, else rejected. */
  const riot: RiotUserinfoFn = async (token) => {
    riotTokens.push(token);
    if (token === 'down') throw new TypeError('fetch failed');
    if (token.startsWith('good-')) {
      const name = token.slice(5);
      return {
        ok: true,
        puuid: `puuid-${name}`,
        gameName: `Player ${name}`,
        tagLine: 'VN1',
        country: countryFromAlpha3(riotCountries[name]),
      };
    }
    return { ok: false };
  };

  const app = createApp({
    repo,
    media,
    config: { sessionSecret: SECRET, pepper: PEPPER, publicBaseUrl: '', trustProxy: true, ...opts.tuning, ...opts.config },
    content: opts.content,
    riotUserinfo: opts.riot ?? riot,
    // Old behavior tests still exercise authenticated ownership, using a
    // deterministic Riot inventory fixture. Adversarial tests override it.
    riotOwnership: opts.ownership ?? (async () => 'owned'),
    now: () => clock.t,
    loadProbe: opts.loadProbe,
    logError: (m) => errors.push(m),
    logAccess: opts.logAccess,
  });

  async function req(method: string, p: string, o: ReqOpts = {}): Promise<Res> {
    const headers: Record<string, string> = { ...(o.headers ?? {}) };
    let body: Uint8Array | string | undefined = o.raw;
    if (o.body !== undefined) {
      let json = o.body;
      if (method === 'PUT' && /^\/v1\/skins\/[^/]+\/review$/.test(p) && !o.omitOwnershipProof &&
          json !== null && typeof json === 'object' && !Array.isArray(json) && o.token &&
          riotProofs.has(o.token) && !Object.hasOwn(json, 'accessToken')) {
        json = { ...json, accessToken: riotProofs.get(o.token) };
      }
      body = typeof json === 'string' ? json : JSON.stringify(json);
      headers['content-type'] ??= 'application/json';
    }
    if (o.token) headers.authorization = `Bearer ${o.token}`;
    const res = await app.request(`${BASE}${p}`, { method, headers, body });
    const bytes = new Uint8Array(await res.arrayBuffer());
    let json: any = null;
    if ((res.headers.get('content-type') ?? '').includes('application/json') && bytes.length > 0) {
      json = JSON.parse(new TextDecoder().decode(bytes));
    }
    return { status: res.status, headers: res.headers, json, bytes };
  }

  async function login(name = 'alice', extra: Record<string, unknown> = {}) {
    const res = await req('POST', '/v1/auth/riot', {
      body: { accessToken: `good-${name}`, region: 'ap', ...extra },
    });
    expect(res.status).toBe(200);
    riotProofs.set(res.json.token, `good-${name}`);
    if (opts.established) db.prepare('UPDATE users SET created_at = ? WHERE id = ?').run(clock.t - 2 * 86400_000, res.json.user.id);
    return { token: res.json.token as string, user: res.json.user, res };
  }

  function close() {
    db.close();
    fs.rmSync(dataDir, { recursive: true, force: true, maxRetries: 5, retryDelay: 50 });
  }

  /**
   * Makes a user an established account for the report-hiding rule: account 2 days old and with some
   * activity (a vote). Direct DB access, so no rate limits or clock changes are involved.
   */
  function mature(userId: string) {
    // Never moves the creation time forward: a token issued before it would be refused (see Ctx.user()).
    db.prepare('UPDATE users SET created_at = MIN(created_at, ?) WHERE id = ?').run(clock.t - 2 * 86400_000, userId);
    db.prepare(
      "INSERT OR IGNORE INTO skin_votes (user_id, skin_uuid, weapon_uuid, created_at, country, region) VALUES (?, ?, ?, ?, NULL, 'ap')",
    ).run(userId, '99999999-9999-4999-8999-999999999999', WEAPON_1, clock.t - 86400_000);
  }

  /** Dependencies of the media lifecycle helpers / sweeper, wired to this test environment. */
  const mediaDeps = () => ({ repo, media, now: () => clock.t, logError: (m: string) => errors.push(m) });

  return { app, db, repo, media, mediaDeps, mediaDir, quarantineDir, dataDir, clock, riotTokens, riotCountries, errors, req, login, mature, close };
}

export type Env = ReturnType<typeof setup>;

export function expectError(res: Res, status: number, code: string) {
  expect(res.status).toBe(status);
  expect(res.headers.get('content-type')).toContain('application/json');
  expect(res.json).toMatchObject({ error: { code, message: expect.any(String) } });
}
