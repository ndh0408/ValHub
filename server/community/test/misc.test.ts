import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { loadConfig } from '../src/config.js';
import { migrate, openDatabase } from '../src/db/database.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';
import { DiskMediaStore } from '../src/media.js';
import { expectError, PEPPER, PNG, SECRET, setup, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

describe('routing and error format', () => {
  it('returns JSON 404 for unknown routes and methods', async () => {
    expectError(await e.req('GET', '/'), 404, 'not_found');
    expectError(await e.req('GET', '/v1/nope'), 404, 'not_found');
    expectError(await e.req('POST', '/v1/me'), 404, 'not_found');
    expectError(await e.req('GET', '/v2/posts'), 404, 'not_found');
  });

  it('answers OPTIONS harmlessly', async () => {
    const res = await e.req('OPTIONS', '/v1/posts');
    expect(res.status).toBe(204);
  });

  it('has a health check', async () => {
    const res = await e.req('GET', '/healthz');
    expect(res.status).toBe(200);
    expect(res.json).toEqual({ ok: true });
  });

  it('turns unexpected exceptions into server_error without leaking details', async () => {
    const { token } = await e.login('a');
    e.db.exec('DROP TABLE lfg_posts');
    const res = await e.req('GET', '/v1/lfg', { token });
    expectError(res, 500, 'server_error');
    expect(JSON.stringify(res.json)).not.toContain('lfg_posts');
    expect(e.errors).toHaveLength(1);
    expect(e.errors[0]).not.toContain(token);
  });

  it('rejects oversized JSON bodies', async () => {
    const { token } = await e.login('a');
    const res = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'x'.repeat(70_000) } });
    expectError(res, 400, 'invalid_input');
  });
});

describe('rate limiting', () => {
  it('returns 429 with Retry-After and resets in the next window', async () => {
    const { token } = await e.login('a');
    // Align to the start of an hour window for a deterministic Retry-After.
    e.clock.t = Math.ceil(e.clock.t / 3600_000) * 3600_000 + 60_000;
    for (let i = 0; i < 10; i++) {
      expect((await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: `p${i}` } })).status).toBe(200);
    }
    const res = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'p11' } });
    expectError(res, 429, 'rate_limited');
    expect(res.headers.get('retry-after')).toBe('3540');
    expect(res.json.error.retryAfter).toBe(3540);

    e.clock.t += 3540_000;
    expect((await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'again' } })).status).toBe(200);
  });

  it('limits are per user', async () => {
    const a = await e.login('a');
    const b = await e.login('b');
    for (let i = 0; i < 10; i++) await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x' } });
    expectError(await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x' } }), 429, 'rate_limited');
    expect((await e.req('POST', '/v1/posts', { token: b.token, body: { kind: 'text', body: 'x' } })).status).toBe(200);
  });

  it('limits comments, media and reports', async () => {
    const { token } = await e.login('a');
    const postId = (await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'x' } })).json.id;
    for (let i = 0; i < 30; i++) {
      await e.req('POST', `/v1/posts/${postId}/comments`, { token, body: { body: 'c' } });
    }
    expectError(
      await e.req('POST', `/v1/posts/${postId}/comments`, { token, body: { body: 'c' } }),
      429,
      'rate_limited',
    );
    for (let i = 0; i < 20; i++) {
      await e.req('POST', '/v1/media', { token, raw: PNG, headers: { 'content-type': 'image/png' } });
    }
    expectError(
      await e.req('POST', '/v1/media', { token, raw: PNG, headers: { 'content-type': 'image/png' } }),
      429,
      'rate_limited',
    );
    for (let i = 0; i < 20; i++) {
      await e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: postId, reason: 'x' } });
    }
    expectError(
      await e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: postId, reason: 'x' } }),
      429,
      'rate_limited',
    );
  });

  it('limits auth attempts per client IP (CF-Connecting-IP)', async () => {
    const headers = { 'cf-connecting-ip': '203.0.113.7' };
    for (let i = 0; i < 30; i++) {
      await e.req('POST', '/v1/auth/riot', { headers, body: { accessToken: 'bad', region: 'ap' } });
    }
    expectError(
      await e.req('POST', '/v1/auth/riot', { headers, body: { accessToken: 'good-a', region: 'ap' } }),
      429,
      'rate_limited',
    );
    const other = await e.req('POST', '/v1/auth/riot', {
      headers: { 'cf-connecting-ip': '203.0.113.8' },
      body: { accessToken: 'good-a', region: 'ap' },
    });
    expect(other.status).toBe(200);
    expect(JSON.stringify(e.db.prepare('SELECT * FROM rate_limits').all())).not.toContain('203.0.113');
  });
});

describe('infrastructure', () => {
  it('loadConfig fails fast on missing or short secrets', () => {
    expect(() => loadConfig({})).toThrow(/SESSION_SECRET/);
    expect(() => loadConfig({ SESSION_SECRET: 'short', PEPPER: PEPPER })).toThrow(/SESSION_SECRET/);
    expect(() => loadConfig({ SESSION_SECRET: SECRET, PEPPER: 'short' })).toThrow(/PEPPER/);
    expect(() => loadConfig({ SESSION_SECRET: SECRET, PEPPER, PUBLIC_BASE_URL: 'ftp://x' })).toThrow(
      /PUBLIC_BASE_URL/,
    );
    const cfg = loadConfig({ SESSION_SECRET: SECRET, PEPPER, PUBLIC_BASE_URL: 'https://c.example.vn/', PORT: '9000' });
    expect(cfg).toMatchObject({ port: 9000, publicBaseUrl: 'https://c.example.vn' });
    expect(loadConfig({ SESSION_SECRET: SECRET, PEPPER }).port).toBe(8080);
  });

  it('uses PUBLIC_BASE_URL for media URLs when set', async () => {
    const db = openDatabase(':memory:');
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-media-'));
    try {
      const app = createApp({
        repo: new SqliteRepo(db),
        media: new DiskMediaStore(dir),
        config: { sessionSecret: SECRET, pepper: PEPPER, publicBaseUrl: 'https://cd.example.vn', trustProxy: true },
        riotUserinfo: async () => ({ ok: true, puuid: 'p', gameName: 'G', tagLine: 'T' }),
      });
      const auth = await app.request('http://internal:8080/v1/auth/riot', {
        method: 'POST',
        body: JSON.stringify({ accessToken: 'x', region: 'ap' }),
      });
      const { token } = (await auth.json()) as { token: string };
      const up = await app.request('http://internal:8080/v1/media', {
        method: 'POST',
        headers: { authorization: `Bearer ${token}`, 'content-type': 'image/png' },
        body: PNG,
      });
      const { url } = (await up.json()) as { url: string };
      expect(url).toMatch(/^https:\/\/cd\.example\.vn\/v1\/media\/u\//);
    } finally {
      db.close();
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });

  it('applies migrations once and records them', () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-db-'));
    try {
      const file = path.join(dir, 'community.db');
      const db = openDatabase(file);
      expect(db.pragma('journal_mode', { simple: true })).toBe('wal');
      expect(migrate(db)).toEqual([]);
      const rows = db.prepare('SELECT name FROM schema_migrations').all();
      expect(rows).toEqual([{ name: '0001_init.sql' }]);
      db.close();
      const again = openDatabase(file);
      expect(again.prepare('SELECT COUNT(*) AS n FROM schema_migrations').get()).toEqual({ n: 1 });
      again.close();
    } finally {
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });

  it('DiskMediaStore refuses keys outside its root', async () => {
    await expect(e.media.put('../evil.png', PNG)).rejects.toThrow();
    await expect(e.media.put(`u/${'a'.repeat(32)}/../../x.png`, PNG)).rejects.toThrow();
    expect(await e.media.get('../../etc/passwd')).toBeNull();
    const key = `u/${'a'.repeat(32)}/${'b'.repeat(32)}.png`;
    await e.media.put(key, PNG);
    expect(fs.existsSync(path.join(e.mediaDir, 'u', 'a'.repeat(32), `${'b'.repeat(32)}.png`))).toBe(true);
  });

  it('cleanup drops stale rate-limit windows and long-expired LFG posts', async () => {
    const { token } = await e.login('a');
    await e.req('POST', '/v1/lfg', { token, body: { region: 'ap', mode: 'custom', partyCode: 'AAAAAA', slots: 1 } });
    e.repo.cleanup(e.clock.t + 2 * 86400_000);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM lfg_posts').get()).toEqual({ n: 0 });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM rate_limits').get()).toEqual({ n: 0 });
  });
});
