import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { expect } from 'vitest';
import { createApp } from '../src/app.js';
import { openDatabase, type Db } from '../src/db/database.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';
import { DiskMediaStore } from '../src/media.js';
import type { RiotUserinfoFn } from '../src/riot.js';

export const SECRET = 'test-session-secret-0123456789abcdef';
export const PEPPER = 'test-pepper-0123456789abcdef-0123456';
export const BASE = 'http://community.test';

export const SKIN_A = '11111111-1111-4111-8111-111111111111';
export const SKIN_B = '22222222-2222-4222-8222-222222222222';
export const SKIN_C = '33333333-3333-4333-8333-333333333333';
export const WEAPON_1 = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
export const WEAPON_2 = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

export const PNG = new Uint8Array([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0, 0, 0, 13, 1, 2, 3]);
export const JPEG = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0, 16, 0x4a, 0x46, 0x49, 0x46]);
export const WEBP = new Uint8Array([0x52, 0x49, 0x46, 0x46, 4, 0, 0, 0, 0x57, 0x45, 0x42, 0x50, 1, 2]);

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
}

export function setup() {
  const db: Db = openDatabase(':memory:');
  const repo = new SqliteRepo(db);
  const mediaDir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-media-'));
  const media = new DiskMediaStore(mediaDir);
  const clock = { t: Date.UTC(2026, 8, 1, 12, 0, 0) };
  const riotTokens: string[] = [];
  const errors: string[] = [];

  /** Tokens: good-<name> → accepted (puuid derived from name), down → network error, else rejected. */
  const riot: RiotUserinfoFn = async (token) => {
    riotTokens.push(token);
    if (token === 'down') throw new TypeError('fetch failed');
    if (token.startsWith('good-')) {
      const name = token.slice(5);
      return { ok: true, puuid: `puuid-${name}`, gameName: `Player ${name}`, tagLine: 'VN1' };
    }
    return { ok: false };
  };

  const app = createApp({
    repo,
    media,
    config: { sessionSecret: SECRET, pepper: PEPPER, publicBaseUrl: '', trustProxy: true },
    riotUserinfo: riot,
    now: () => clock.t,
    logError: (m) => errors.push(m),
  });

  async function req(method: string, p: string, o: ReqOpts = {}): Promise<Res> {
    const headers: Record<string, string> = { ...(o.headers ?? {}) };
    let body: Uint8Array | string | undefined = o.raw;
    if (o.body !== undefined) {
      body = typeof o.body === 'string' ? o.body : JSON.stringify(o.body);
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
    return { token: res.json.token as string, user: res.json.user, res };
  }

  function close() {
    db.close();
    fs.rmSync(mediaDir, { recursive: true, force: true });
  }

  return { app, db, repo, media, mediaDir, clock, riotTokens, errors, req, login, close };
}

export type Env = ReturnType<typeof setup>;

export function expectError(res: Res, status: number, code: string) {
  expect(res.status).toBe(status);
  expect(res.headers.get('content-type')).toContain('application/json');
  expect(res.json).toMatchObject({ error: { code, message: expect.any(String) } });
}
