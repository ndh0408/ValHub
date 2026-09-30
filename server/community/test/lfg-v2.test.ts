import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import Database from 'better-sqlite3';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { DEFAULT_MIGRATIONS_DIR, migrate } from '../src/db/database.js';
import { SqliteRepo } from '../src/db/sqlite-repo.js';
import { expectError, migrationNames, setup, type Env } from './helpers.js';

const AGENT_1 = 'add6443a-41bd-e414-f6ad-e58d267f4e95';
const AGENT_2 = 'a3bfb853-43b2-7238-a4f1-ad90e9e46bcc';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const base = (over: Record<string, unknown> = {}) => ({
  region: 'ap',
  mode: 'competitive',
  partyCode: 'AB12CD',
  slots: 2,
  ...over,
});

describe('POST /v1/lfg v2 fields', () => {
  it('defaults the v2 fields', async () => {
    const { token } = await e.login('alice');
    const res = await e.req('POST', '/v1/lfg', { token, body: base({ slots: 3 }) });
    expect(res.status).toBe(200);
    expect(res.json).toMatchObject({
      rankMin: null,
      rankMax: null,
      roles: [],
      mic: false,
      language: 'vi',
      partySize: 2,
      agents: [],
      status: 'open',
      joins: 0,
      updatedAt: res.json.createdAt,
    });
  });

  it('stores all v2 fields', async () => {
    const { token } = await e.login('alice');
    const res = await e.req('POST', '/v1/lfg', {
      token,
      body: base({
        rankMin: 12,
        rankMax: 18,
        roles: ['controller', 'sentinel'],
        mic: true,
        language: 'en',
        partySize: 3,
        agents: [AGENT_1, AGENT_2.toUpperCase()],
      }),
    });
    expect(res.status).toBe(200);
    expect(res.json).toMatchObject({
      rankMin: 12,
      rankMax: 18,
      roles: ['controller', 'sentinel'],
      mic: true,
      language: 'en',
      partySize: 3,
      agents: [AGENT_1, AGENT_2],
      status: 'open',
    });
  });

  it('validates v2 fields strictly', async () => {
    const { token } = await e.login('alice');
    const bad = [
      { rankMin: -1 },
      { rankMax: 28 },
      { rankMin: 1.5 },
      { rankMin: '12' },
      { rankMin: 20, rankMax: 10 },
      { roles: 'duelist' },
      { roles: ['duelist', 'duelist'] },
      { roles: ['duelist', 'initiator', 'controller', 'sentinel', 'flex'] },
      { roles: ['healer'] },
      { mic: 'true' },
      { mic: 1 },
      { language: 'xx' },
      { language: 'vi-VN-x' },
      { partySize: 0 },
      { partySize: 6 },
      { agents: [AGENT_1, AGENT_1] },
      { agents: ['nope'] },
      { agents: Array.from({ length: 6 }, (_, i) => `00000000-0000-4000-8000-00000000000${i}`) },
    ];
    for (const over of bad) {
      expectError(await e.req('POST', '/v1/lfg', { token, body: base(over) }), 400, 'invalid_input');
    }
    // 0 means "any" on that side, so it never violates rankMin <= rankMax.
    expect((await e.req('POST', '/v1/lfg', { token, body: base({ rankMin: 15, rankMax: 0 }) })).status).toBe(200);
    expect((await e.req('POST', '/v1/lfg', { token, body: base({ roles: [], agents: [], mic: false }) })).status).toBe(200);
  });
});

describe('GET /v1/lfg filters', () => {
  async function seed() {
    const specs: Record<string, Record<string, unknown>> = {
      norange: {},
      gold: { rankMin: 9, rankMax: 11, roles: ['duelist'], mic: true, language: 'vi' },
      high: { rankMin: 18, roles: ['controller', 'sentinel'], language: 'en' },
      low: { rankMax: 8, mic: false, language: 'any' },
      anyrange: { rankMin: 0, rankMax: 0, roles: ['flex'], mic: true },
    };
    const tokens: Record<string, string> = {};
    for (const [name, over] of Object.entries(specs)) {
      e.clock.t += 1000;
      const { token } = await e.login(name);
      tokens[name] = token;
      expect((await e.req('POST', '/v1/lfg', { token, body: base(over) })).status).toBe(200);
    }
    const { token } = await e.login('viewer');
    const names = async (qs: string) =>
      (await e.req('GET', `/v1/lfg${qs}`, { token })).json.items.map((i: any) => i.author.gameName.slice(7)).sort();
    return { names, tokens };
  }

  it('rank keeps posts whose range contains the tier or has no range', async () => {
    const { names } = await seed();
    expect(await names('?rank=10')).toEqual(['anyrange', 'gold', 'norange']);
    expect(await names('?rank=20')).toEqual(['anyrange', 'high', 'norange']);
    expect(await names('?rank=3')).toEqual(['anyrange', 'low', 'norange']);
    expect(await names('?rank=9')).toEqual(['anyrange', 'gold', 'norange']);
    expect(await names('?rank=8')).toEqual(['anyrange', 'low', 'norange']);
    expect(await names('')).toEqual(['anyrange', 'gold', 'high', 'low', 'norange']);
  });

  it('role, mic and language filters', async () => {
    const { names } = await seed();
    // Posts listing no roles accept any role.
    expect(await names('?role=controller')).toEqual(['high', 'low', 'norange']);
    expect(await names('?role=duelist')).toEqual(['gold', 'low', 'norange']);
    expect(await names('?mic=true')).toEqual(['anyrange', 'gold']);
    expect(await names('?mic=false')).toEqual(['high', 'low', 'norange']);
    // language=X matches X and "any"; language=any disables the filter.
    expect(await names('?language=en')).toEqual(['high', 'low']);
    expect(await names('?language=vi')).toEqual(['anyrange', 'gold', 'low', 'norange']);
    expect(await names('?language=any')).toHaveLength(5);
    expect(await names('?rank=10&mic=true&role=duelist')).toEqual(['gold']);
  });

  it('validates filters', async () => {
    const { token } = await e.login('viewer');
    for (const qs of ['rank=28', 'rank=-1', 'rank=abc', 'role=healer', 'mic=yes', 'language=xx', 'status=closed']) {
      expectError(await e.req('GET', `/v1/lfg?${qs}`, { token }), 400, 'invalid_input');
    }
  });

  it('lists only open posts by default; full / in_game via status', async () => {
    const { names, tokens } = await seed();
    const goldId = (await e.req('GET', '/v1/lfg/mine', { token: tokens.gold })).json.id;
    const highId = (await e.req('GET', '/v1/lfg/mine', { token: tokens.high })).json.id;
    await e.req('PATCH', `/v1/lfg/${goldId}`, { token: tokens.gold, body: { status: 'full' } });
    await e.req('PATCH', `/v1/lfg/${highId}`, { token: tokens.high, body: { status: 'in_game' } });
    expect(await names('')).toEqual(['anyrange', 'low', 'norange']);
    expect(await names('?status=open')).toEqual(['anyrange', 'low', 'norange']);
    expect(await names('?status=full')).toEqual(['gold']);
    expect(await names('?status=in_game')).toEqual(['high']);
  });
});

describe('PATCH /v1/lfg/{id}', () => {
  it('updates party state and extends expiry (heartbeat)', async () => {
    const { token } = await e.login('alice');
    const created = (await e.req('POST', '/v1/lfg', { token, body: base({ note: 'hi' }) })).json;
    e.clock.t += 20 * 60_000;
    const hb = await e.req('PATCH', `/v1/lfg/${created.id}`, { token, body: {} });
    expect(hb.status).toBe(200);
    expect(hb.json.expiresAt).toBe(new Date(e.clock.t + 30 * 60_000).toISOString());
    expect(hb.json.updatedAt).toBe(new Date(e.clock.t).toISOString());
    expect(hb.json.createdAt).toBe(created.createdAt);

    // Would have expired without the heartbeat.
    e.clock.t += 25 * 60_000;
    expect((await e.req('GET', '/v1/lfg', { token })).json.items).toHaveLength(1);

    const upd = await e.req('PATCH', `/v1/lfg/${created.id}`, {
      token,
      body: { partySize: 4, slots: 1, note: null, status: 'full' },
    });
    expect(upd.json).toMatchObject({ partySize: 4, slots: 1, note: null, status: 'full', partyCode: 'AB12CD' });
    const back = await e.req('PATCH', `/v1/lfg/${created.id}`, { token, body: { status: 'open', note: 'lại' } });
    expect(back.json).toMatchObject({ status: 'open', note: 'lại' });

    // No heartbeat for 30 minutes → expired, and PATCH can no longer revive it.
    e.clock.t += 30 * 60_000;
    expect((await e.req('GET', '/v1/lfg', { token })).json.items).toEqual([]);
    expectError(await e.req('PATCH', `/v1/lfg/${created.id}`, { token, body: {} }), 404, 'not_found');
  });

  it('is owner-only and validated', async () => {
    const alice = await e.login('alice');
    const bob = await e.login('bob');
    const id = (await e.req('POST', '/v1/lfg', { token: alice.token, body: base() })).json.id;
    expectError(await e.req('PATCH', `/v1/lfg/${id}`, { token: bob.token, body: {} }), 403, 'forbidden');
    expectError(
      await e.req('PATCH', '/v1/lfg/00000000-0000-4000-8000-000000000000', { token: alice.token, body: {} }),
      404,
      'not_found',
    );
    for (const body of [
      { status: 'closed' },
      { status: null },
      { partySize: 0 },
      { partySize: 6 },
      { partySize: null },
      { slots: 5 },
      { slots: null },
      { note: 'x'.repeat(141) },
    ]) {
      expectError(await e.req('PATCH', `/v1/lfg/${id}`, { token: alice.token, body }), 400, 'invalid_input');
    }
    expectError(await e.req('PATCH', `/v1/lfg/${id}`, { body: {} }), 401, 'unauthorized');
  });
});

describe('POST /v1/lfg/{id}/join', () => {
  it('counts one join per user and refuses the owner', async () => {
    const [owner, a, b] = await Promise.all(['owner', 'a', 'b'].map((n) => e.login(n)));
    const id = (await e.req('POST', '/v1/lfg', { token: owner!.token, body: base() })).json.id;
    expectError(await e.req('POST', `/v1/lfg/${id}/join`, { token: owner!.token, body: {} }), 403, 'forbidden');
    expect((await e.req('POST', `/v1/lfg/${id}/join`, { token: a!.token, body: {} })).json).toEqual({ joins: 1 });
    expect((await e.req('POST', `/v1/lfg/${id}/join`, { token: a!.token })).json).toEqual({ joins: 1 });
    expect((await e.req('POST', `/v1/lfg/${id}/join`, { token: b!.token, body: {} })).json).toEqual({ joins: 2 });
    expect((await e.req('GET', '/v1/lfg/mine', { token: owner!.token })).json.joins).toBe(2);
    expect((await e.req('GET', '/v1/lfg', { token: a!.token })).json.items[0].joins).toBe(2);

    expectError(
      await e.req('POST', '/v1/lfg/00000000-0000-4000-8000-000000000000/join', { token: a!.token, body: {} }),
      404,
      'not_found',
    );
    expectError(await e.req('POST', `/v1/lfg/${id}/join`, { body: {} }), 401, 'unauthorized');
    e.clock.t += 31 * 60_000;
    expectError(await e.req('POST', `/v1/lfg/${id}/join`, { token: b!.token, body: {} }), 404, 'not_found');
  });

  it('joins are reset when the owner posts a new LFG', async () => {
    const [owner, a] = await Promise.all(['owner', 'a'].map((n) => e.login(n)));
    const id = (await e.req('POST', '/v1/lfg', { token: owner!.token, body: base() })).json.id;
    await e.req('POST', `/v1/lfg/${id}/join`, { token: a!.token, body: {} });
    const next = await e.req('POST', '/v1/lfg', { token: owner!.token, body: base({ partyCode: 'ZZZZZZ' }) });
    expect(next.json.joins).toBe(0);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM lfg_joins').get()).toEqual({ n: 0 });
  });
});

describe('GET /v1/lfg/mine', () => {
  it('returns the caller’s active post (any status) or null', async () => {
    const { token } = await e.login('alice');
    const none = await e.req('GET', '/v1/lfg/mine', { token });
    expect(none.status).toBe(200);
    expect(none.json).toBeNull();
    expect(new TextDecoder().decode(none.bytes)).toBe('null');

    const id = (await e.req('POST', '/v1/lfg', { token, body: base() })).json.id;
    await e.req('PATCH', `/v1/lfg/${id}`, { token, body: { status: 'in_game' } });
    const mine = await e.req('GET', '/v1/lfg/mine', { token });
    expect(mine.json).toMatchObject({ id, status: 'in_game' });

    e.clock.t += 31 * 60_000;
    expect((await e.req('GET', '/v1/lfg/mine', { token })).json).toBeNull();
    expectError(await e.req('GET', '/v1/lfg/mine'), 401, 'unauthorized');
  });
});

describe('migration from a v1 database', () => {
  it('adds v2 columns with sensible defaults for existing rows', () => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'valvn-mig-'));
    const v1Dir = path.join(dir, 'v1');
    fs.mkdirSync(v1Dir);
    fs.copyFileSync(path.join(DEFAULT_MIGRATIONS_DIR, '0001_init.sql'), path.join(v1Dir, '0001_init.sql'));
    const db = new Database(path.join(dir, 'community.db'));
    try {
      db.pragma('foreign_keys = ON');
      expect(migrate(db, v1Dir)).toEqual(['0001_init.sql']);
      db.prepare(
        `INSERT INTO users (id, game_name, tag_line, region, created_at, updated_at) VALUES ('${'a'.repeat(32)}', 'Old', 'VN1', 'ap', 1, 1)`,
      ).run();
      db.prepare(
        `INSERT INTO lfg_posts (id, user_id, region, mode, party_code, slots, created_at, expires_at)
         VALUES ('00000000-0000-4000-8000-000000000001', '${'a'.repeat(32)}', 'ap', 'unrated', 'AAAAAA', 3, 1000, 9999999999999)`,
      ).run();

      expect(migrate(db)).toEqual(migrationNames().slice(1));
      const repo = new SqliteRepo(db);
      const row = repo.getLfg('00000000-0000-4000-8000-000000000001')!;
      expect(row).toMatchObject({
        roles: '[]',
        agents: '[]',
        mic: 0,
        language: 'vi',
        status: 'open',
        party_size: null,
        updated_at: null,
        rank_min: null,
        joins: 0,
      });
      expect(repo.listLfg({ status: 'open', now: 2000, limit: 10, rank: 15, role: 'duelist' })).toHaveLength(1);
    } finally {
      db.close();
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });
});
