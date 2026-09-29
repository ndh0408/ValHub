import fs from 'node:fs';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { ORPHAN_MEDIA_MS, QUARANTINE_MS, REPORT_RETENTION_MS, STRAY_GRACE_MS, sweep } from '../src/sweeper.js';
import { PNG, setup, SKIN_A, type Env } from './helpers.js';

const HOUR = 3600_000;
const DAY = 24 * HOUR;

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const upload = async (token: string) =>
  (await e.req('POST', '/v1/media', { token, raw: PNG, headers: { 'content-type': 'image/png' } })).json.key as string;
const publicFile = (key: string) => path.join(e.mediaDir, ...key.split('/'));
const quarantineFile = (key: string) => path.join(e.quarantineDir, ...key.split('/'));
const run = () => sweep(e.mediaDeps());
const setMtime = (file: string, ms: number) => fs.utimesSync(file, ms / 1000, ms / 1000);

describe('orphan uploads', () => {
  it('deletes uploads never attached to a post after 24 h, keeps fresh and attached ones', async () => {
    const { token } = await e.login('alice');
    const orphan = await upload(token);
    const attached = await upload(token);
    await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'x', media: [attached] } });
    e.clock.t += 23 * HOUR;
    const fresh = await upload(token);

    let r = await run();
    expect(r.orphanMediaDeleted).toBe(0);
    e.clock.t += 2 * HOUR; // orphan is now 25 h old, fresh 2 h
    r = await run();
    expect(r.orphanMediaDeleted).toBe(1);
    expect(e.repo.getMedia(orphan)).toBeNull();
    expect(fs.existsSync(publicFile(orphan))).toBe(false);
    expect(e.repo.getMedia(attached)).not.toBeNull();
    expect(fs.existsSync(publicFile(attached))).toBe(true);
    expect(e.repo.getMedia(fresh)).not.toBeNull();
    expect((await e.req('GET', `/v1/media/${attached}`)).status).toBe(200);
    expect(ORPHAN_MEDIA_MS).toBe(DAY);
  });
});

describe('quarantine', () => {
  async function hiddenPost() {
    const a = await e.login('alice');
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((n) => e.login(n)));
    reporters.forEach((r) => e.mature(r.user.id));
    const key = await upload(a.token);
    const post = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x', media: [key] } });
    for (const r of reporters) {
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'post', targetId: post.json.id, reason: 'x' } });
    }
    return { key, post: post.json.id as string };
  }

  it('is purged after 30 days, not before', async () => {
    const { key } = await hiddenPost();
    e.clock.t += 29 * DAY;
    expect((await run()).quarantinePurged).toBe(0);
    expect(fs.existsSync(quarantineFile(key))).toBe(true);
    e.clock.t += 2 * DAY;
    expect((await run()).quarantinePurged).toBe(1);
    expect(fs.existsSync(quarantineFile(key))).toBe(false);
    expect(e.repo.getMedia(key)).toBeNull();
    expect(QUARANTINE_MS).toBe(30 * DAY);
  });

  it('catches up: files of a hidden post that are still public get quarantined', async () => {
    const a = await e.login('alice');
    const key = await upload(a.token);
    const post = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x', media: [key] } });
    // Hidden before this feature existed (or the move failed): row active, file public.
    e.db.prepare('UPDATE posts SET hidden = 1 WHERE id = ?').run(post.json.id);
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(200);
    const r = await run();
    expect(r.hiddenQuarantined).toBe(1);
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(404);
    expect(fs.existsSync(quarantineFile(key))).toBe(true);
    expect((await run()).hiddenQuarantined).toBe(0); // idempotent
  });

  it('a row marked quarantined whose bytes are still public is moved', async () => {
    const a = await e.login('alice');
    const key = await upload(a.token);
    e.repo.setMediaQuarantined([key], e.clock.t); // status only; the move "failed"
    expect(fs.existsSync(publicFile(key))).toBe(true);
    await run();
    e.clock.t += HOUR;
    setMtime(publicFile(key), e.clock.t - 2 * HOUR);
    await run();
    expect(fs.existsSync(publicFile(key))).toBe(false);
    expect(fs.existsSync(quarantineFile(key))).toBe(true);
  });
});

describe('stray files', () => {
  it('deletes files without a row once older than the grace period', async () => {
    const { user } = await e.login('alice');
    const stray = `u/${user.id}/${'e'.repeat(32)}.png`;
    await e.media.put(stray, PNG);
    const strayQ = `u/${user.id}/${'f'.repeat(32)}.png`;
    await e.media.put(strayQ, PNG);
    await e.media.quarantine(strayQ);
    // Real mtimes are "now"; the sweeper clock is the fake clock.
    e.clock.t = Date.now();
    expect((await run()).strayFilesDeleted).toBe(0); // too fresh: an upload may be writing its row
    e.clock.t = Date.now() + STRAY_GRACE_MS + 60_000;
    const r = await run();
    expect(r.strayFilesDeleted).toBe(2);
    expect(fs.existsSync(publicFile(stray))).toBe(false);
    expect(fs.existsSync(quarantineFile(strayQ))).toBe(false);
  });

  it('keeps files that have a row, ignores temp files, survives a missing directory', async () => {
    const { token } = await e.login('alice');
    const key = await upload(token);
    fs.writeFileSync(`${publicFile(key)}.123.tmp`, 'partial');
    e.clock.t = Date.now() + 2 * STRAY_GRACE_MS;
    await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'x', media: [key] } });
    const r = await run();
    expect(r.strayFilesDeleted).toBe(0);
    expect(fs.existsSync(publicFile(key))).toBe(true);
    fs.rmSync(e.mediaDir, { recursive: true, force: true });
    fs.rmSync(e.quarantineDir, { recursive: true, force: true });
    await expect(run()).resolves.toBeDefined();
  });
});

describe('reports', () => {
  const insertReport = (type: string, target: string, reporter: string, createdAt: number) =>
    e.db
      .prepare('INSERT INTO reports (target_type, target_id, reporter_id, reason, created_at) VALUES (?, ?, ?, ?, ?)')
      .run(type, target, reporter, 'x', createdAt);

  it('deletes reports older than 12 months, keeps younger ones', async () => {
    const a = await e.login('alice');
    const post = (await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x' } })).json.id;
    insertReport('post', post, 'r-old', e.clock.t - REPORT_RETENTION_MS - DAY);
    insertReport('post', post, 'r-new', e.clock.t - REPORT_RETENTION_MS + DAY);
    const r = await run();
    expect(r.reportsExpired).toBe(1);
    expect(e.db.prepare('SELECT reporter_id FROM reports').all()).toEqual([{ reporter_id: 'r-new' }]);
    expect(REPORT_RETENTION_MS).toBe(365 * DAY);
  });

  it('deletes reports about content that no longer exists (all four kinds)', async () => {
    const a = await e.login('alice');
    const post = (await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x' } })).json.id;
    const ghost = '00000000-0000-4000-8000-00000000dead';
    for (const t of ['post', 'comment', 'lfg', 'review']) insertReport(t, ghost, 'r1', e.clock.t);
    insertReport('post', post, 'r1', e.clock.t);
    const r = await run();
    expect(r.reportsOrphaned).toBe(4);
    expect(e.db.prepare('SELECT target_type FROM reports').all()).toEqual([{ target_type: 'post' }]);
    // Deleting the post makes its report an orphan too.
    await e.req('DELETE', `/v1/posts/${post}`, { token: a.token });
    expect((await run()).reportsOrphaned).toBe(1);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM reports').get()).toEqual({ n: 0 });
  });

  it('a hidden post stays hidden after its reports are purged', async () => {
    const a = await e.login('alice');
    const post = (await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x' } })).json.id;
    e.db.prepare('UPDATE posts SET hidden = 1 WHERE id = ?').run(post);
    insertReport('post', post, 'r1', e.clock.t - REPORT_RETENTION_MS - DAY);
    await run();
    expect(e.db.prepare('SELECT hidden FROM posts WHERE id = ?').get(post)).toEqual({ hidden: 1 });
  });
});

describe('housekeeping', () => {
  it('drops old rate-limit windows and long-expired LFG rows, and prunes memory', async () => {
    const { token } = await e.login('alice');
    await e.req('POST', '/v1/lfg', { token, body: { region: 'ap', mode: 'custom', partyCode: 'AAAAAA', slots: 1 } });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM rate_limits').get()).not.toEqual({ n: 0 });
    e.clock.t += 10 * DAY;
    let pruned = 0;
    await sweep({ ...e.mediaDeps(), prune: () => (pruned += 1) });
    expect(pruned).toBe(1);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM lfg_posts').get()).toEqual({ n: 0 });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM rate_limits').get()).toEqual({ n: 0 });
  });

  it('every step is independent: a failing store does not stop the database steps', async () => {
    const { token } = await e.login('alice');
    await upload(token);
    const broken = {
      ...e.media,
      list: async () => {
        throw new Error('disk gone');
      },
      delete: async () => {
        throw new Error('disk gone');
      },
    };
    const post = (await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'x' } })).json.id;
    e.db
      .prepare("INSERT INTO reports (target_type, target_id, reporter_id, reason, created_at) VALUES ('post', ?, 'r', 'x', ?)")
      .run(post, e.clock.t - REPORT_RETENTION_MS - DAY);
    e.clock.t += 2 * DAY;
    const r = await sweep({ ...e.mediaDeps(), media: broken as never });
    expect(r.reportsExpired).toBe(1);
    expect(e.errors.some((m) => m.includes('stray-files failed'))).toBe(true);
    void SKIN_A;
  });
});
