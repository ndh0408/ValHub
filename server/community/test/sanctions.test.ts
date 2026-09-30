import fs from 'node:fs';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { runCli } from '../src/cli.js';
import { sweep } from '../src/sweeper.js';
import { PNG, setup, SKIN_A, WEAPON_1, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const HOUR = 3600_000;
const DAY = 24 * HOUR;

async function cli(...argv: string[]) {
  const out: string[] = [];
  const err: string[] = [];
  const code = await runCli(argv, { ...e.mediaDeps(), out: (l) => out.push(l), err: (l) => err.push(l), baseUrl: 'https://c.example' });
  return { code, out: out.join('\n'), err: err.join('\n') };
}

const count = (table: string, where = '1=1', ...p: unknown[]) =>
  (e.db.prepare(`SELECT COUNT(*) AS n FROM ${table} WHERE ${where}`).get(...p) as { n: number }).n;

const post = (token: string, body = 'hello there') => e.req('POST', '/v1/posts', { token, body: { kind: 'text', body } });

describe('ban (CS-02)', () => {
  it('a banned account gets 403 suspended with a reason code on every route, except its data rights', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const mine = await post(a.token);
    expect((await cli('ban', '--riot', 'Player alice#VN1', '--reason', 'harassment', '--yes')).code).toBe(0);
    // The ban ended the sessions issued so far (epoch bump): sign in again, refused with the reason.
    const stale = await e.req('GET', '/v1/me', { token: a.token });
    expect(stale.status).toBe(401);

    // Sanction enforced in Ctx.user() also for a token that is still valid (ban without the epoch bump).
    e.repo.addSanction({ userId: b.user.id, kind: 'ban', until: null, reason: 'spam', now: e.clock.t });
    for (const [method, path, body] of [
      ['GET', '/v1/me', undefined],
      ['GET', '/v1/posts', undefined],
      ['POST', '/v1/posts', { kind: 'text', body: 'hi there' }],
      ['GET', '/v1/lfg', undefined],
      ['PATCH', '/v1/me', { region: 'eu' }],
      ['DELETE', `/v1/posts/${mine.json.id}`, undefined],
    ] as const) {
      const res = await e.req(method, path, { token: b.token, body });
      expect(res.status, `${method} ${path}`).toBe(403);
      expect(res.json.error).toMatchObject({
        code: 'suspended',
        reason: 'account_banned',
        params: { kind: 'ban', until: null, cause: 'spam' },
        messageEn: expect.any(String),
      });
    }
    // Data rights and sign-out still work for a banned account.
    expect((await e.req('GET', '/v1/me/export', { token: b.token })).status).toBe(200);
    expect((await e.req('POST', '/v1/auth/logout', { token: b.token })).status).toBe(204);
  });

  it('a banned account cannot get a new session; erasing the account does not lift the ban', async () => {
    const a = await e.login('alice');
    await cli('ban', '--id', a.user.id, '--reason', 'scam', '--yes');
    const again = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } });
    expect(again.status).toBe(403);
    expect(again.json.error).toMatchObject({ code: 'suspended', reason: 'account_banned', params: { kind: 'ban', cause: 'scam' } });
    expect(again.json.token).toBeUndefined();

    // The account row (and everything it owns) can be erased; the ban is not.
    expect((await cli('delete', '--id', a.user.id, '--yes')).code).toBe(0);
    expect(count('users', 'id = ?', a.user.id)).toBe(0);
    expect(count('sanctions', 'user_id = ?', a.user.id)).toBe(1);
    const third = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } });
    expect(third.status).toBe(403);
    expect(count('users', 'id = ?', a.user.id)).toBe(0); // nothing was created for a banned account
  });

  it('a timed ban ends by itself; unban lifts it early and is idempotent', async () => {
    const a = await e.login('alice');
    expect((await cli('ban', '--id', a.user.id, '--days', '3', '--yes')).code).toBe(0);
    const banned = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } });
    expect(banned.status).toBe(403);
    expect(banned.json.error.params.until).toBe(new Date(e.clock.t + 3 * DAY).toISOString());

    e.clock.t += 3 * DAY + HOUR;
    const ok = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } });
    expect(ok.status).toBe(200);

    await cli('ban', '--id', a.user.id, '--yes');
    expect((await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } })).status).toBe(403);
    const lift = await cli('unban', '--id', a.user.id);
    expect(lift.code).toBe(0);
    expect(lift.out).toContain('lifted 1');
    expect((await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } })).status).toBe(200);
    expect((await cli('unban', '--id', a.user.id)).code).toBe(1); // nothing left to lift
  });

  it('only the sanctioned account is affected', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    e.repo.addSanction({ userId: a.user.id, kind: 'ban', until: null, reason: 'spam', now: e.clock.t });
    expect((await e.req('GET', '/v1/me', { token: b.token })).status).toBe(200);
    expect((await post(b.token)).status).toBe(200);
  });
});

describe('temporary restriction (CS-02)', () => {
  it('is read-only: no posting, commenting, LFG, voting, reviewing, reporting or uploading; reading, deleting and profile edits work', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const bobPost = await post(b.token, 'bob says hi');
    const mine = await post(a.token, 'alice says hi');
    expect((await cli('restrict', '--id', a.user.id, '--days', '2', '--reason', 'spam', '--yes')).code).toBe(0);

    const blocked: [string, string, unknown][] = [
      ['POST', '/v1/posts', { kind: 'text', body: 'another post' }],
      ['POST', `/v1/posts/${bobPost.json.id}/comments`, { body: 'a comment' }],
      ['PUT', `/v1/posts/${bobPost.json.id}/like`, undefined],
      ['POST', '/v1/lfg', { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2 }],
      ['PUT', `/v1/skins/${SKIN_A}/vote`, { weaponUuid: WEAPON_1 }],
      ['PUT', `/v1/skins/${SKIN_A}/review`, { weaponUuid: WEAPON_1, rating: 4 }],
      ['POST', '/v1/reports', { targetType: 'post', targetId: bobPost.json.id, reason: 'x' }],
    ];
    for (const [method, path, body] of blocked) {
      const res = await e.req(method, path, { token: a.token, body });
      expect(res.status, `${method} ${path}`).toBe(403);
      expect(res.json.error).toMatchObject({
        code: 'suspended',
        reason: 'account_restricted',
        params: { kind: 'restrict', until: new Date(e.clock.t + 2 * DAY).toISOString(), cause: 'spam' },
      });
    }
    const upload = await e.req('POST', '/v1/media', { token: a.token, raw: PNG, headers: { 'content-type': 'image/png' } });
    expect(upload.status).toBe(403);

    expect((await e.req('GET', '/v1/posts', { token: a.token })).status).toBe(200);
    expect((await e.req('GET', '/v1/me', { token: a.token })).status).toBe(200);
    expect((await e.req('GET', '/v1/skins/top', { token: a.token })).status).toBe(200);
    expect((await e.req('PATCH', '/v1/me', { token: a.token, body: { language: 'en' } })).status).toBe(200);
    expect((await e.req('DELETE', `/v1/posts/${mine.json.id}`, { token: a.token })).status).toBe(204);
    expect((await e.req('POST', '/v1/auth/logout', { token: a.token })).status).toBe(204);

    // Restricted accounts can still sign in (they can read), and the restriction ends by itself.
    const login = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } });
    expect(login.status).toBe(200);
    expect((await post(login.json.token)).status).toBe(403);
    e.clock.t += 2 * DAY + 1000;
    const later = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap' } });
    expect((await post(later.json.token)).status).toBe(200);
  });

  it('a ban beats a restriction, and the longest sanction of a kind wins', () => {
    const now = e.clock.t;
    const u = 'a'.repeat(32);
    e.repo.addSanction({ userId: u, kind: 'restrict', until: now + 10 * DAY, reason: 'spam', now });
    e.repo.addSanction({ userId: u, kind: 'restrict', until: now + 2 * DAY, reason: 'other', now });
    expect(e.repo.activeSanction(u, now)).toMatchObject({ kind: 'restrict', reason: 'spam' });
    e.repo.addSanction({ userId: u, kind: 'ban', until: now + DAY, reason: 'hate', now });
    expect(e.repo.activeSanction(u, now)).toMatchObject({ kind: 'ban', reason: 'hate' });
    expect(e.repo.activeSanction(u, now + 2 * DAY)).toMatchObject({ kind: 'restrict' });
    expect(e.repo.activeSanction(u, now + 11 * DAY)).toBeNull();
  });
});

describe('operator CLI (CS-02)', () => {
  it('validates its input and never changes anything on a dry run', async () => {
    const a = await e.login('alice');
    const dry = await cli('ban', '--id', a.user.id);
    expect(dry.code).toBe(2);
    expect(dry.out).toContain('DRY RUN');
    expect(count('sanctions')).toBe(0);
    expect((await cli('ban', '--id', a.user.id, '--reason', 'because', '--yes')).code).toBe(1);
    expect((await cli('ban', '--id', a.user.id, '--days', '0', '--yes')).code).toBe(1);
    expect((await cli('ban', '--id', 'nothex', '--yes')).code).toBe(1);
    expect((await cli('ban', '--riot', 'Nobody#000', '--yes')).code).toBe(1);
    expect((await cli('ban', '--yes')).code).toBe(1);
    expect((await cli('restrict', '--id', a.user.id, '--yes')).code).toBe(1); // --days is required
    expect(count('sanctions')).toBe(0);
    expect(count('moderation_audit')).toBe(0);
  });

  it('bans an account by id even when it has no row here, and lists sanctions', async () => {
    const ghost = 'f'.repeat(32);
    expect((await cli('ban', '--id', ghost, '--reason', 'evasion', '--yes')).code).toBe(0);
    const list = await cli('sanctions', 'list', '--active');
    expect(list.out).toContain(ghost);
    expect(list.out).toContain('ban permanent reason=evasion');
    expect((await cli('sanctions', 'list', '--id', ghost)).out).toContain('reason=evasion');
    await cli('unban', '--id', ghost);
    expect((await cli('sanctions', 'list', '--active')).out).toContain('(no sanctions)');
    expect((await cli('sanctions', 'list', '--id', ghost)).out).toContain('lifted'); // history is kept
  });

  it('find shows the active sanction', async () => {
    const a = await e.login('alice');
    await cli('restrict', '--id', a.user.id, '--days', '5', '--yes');
    const found = await cli('find', '--riot', 'Player alice#VN1');
    expect(JSON.parse(found.out).sanction).toContain('restrict until');
  });

  it('logs every action in the audit table (structured values only) and lists it', async () => {
    const a = await e.login('alice');
    await cli('ban', '--id', a.user.id, '--days', '7', '--reason', 'spam', '--yes');
    await cli('unban', '--id', a.user.id);
    const rows = e.db.prepare('SELECT action, target_type, target_id, user_id, detail FROM moderation_audit ORDER BY id').all() as any[];
    expect(rows.map((r) => r.action)).toEqual(['ban', 'unban']);
    expect(rows[0]).toMatchObject({ target_type: 'user', target_id: a.user.id, user_id: a.user.id });
    expect(JSON.parse(rows[0].detail)).toMatchObject({ reason: 'spam', until: e.clock.t + 7 * DAY });
    const listed = await cli('audit', 'list', '--id', a.user.id);
    expect(listed.out).toContain('ban');
    expect(listed.out).toContain('unban');
    expect((await cli('audit', 'list')).out.split('\n')).toHaveLength(2);
  });

  it('hide: hides one post now, quarantines its images, and unhide brings it back', async () => {
    const a = await e.login('alice');
    const up = await e.req('POST', '/v1/media', { token: a.token, raw: PNG, headers: { 'content-type': 'image/png' } });
    const p = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'shady', media: [up.json.key] } });
    const res = await cli('hide', 'post', p.json.id);
    expect(res.code).toBe(0);
    expect(res.out).toContain('quarantined 1 file');
    expect((await e.req('GET', `/v1/posts/${p.json.id}`)).status).toBe(404);
    expect((await e.req('GET', `/v1/media/${up.json.key}`)).status).toBe(404);
    expect(fs.existsSync(path.join(e.quarantineDir, ...up.json.key.split('/')))).toBe(true);
    const row = e.db.prepare('SELECT hidden, hidden_reason FROM posts WHERE id = ?').get(p.json.id) as any;
    expect(row).toEqual({ hidden: 1, hidden_reason: 'moderator' });
    expect((await cli('hidden', 'list')).out).toContain(`post ${p.json.id}`);
    expect((await cli('hidden', 'list')).out).toContain('hidden by moderator');

    expect((await cli('hide', 'post', p.json.id)).out).toContain('already hidden');
    expect((await cli('unhide', 'post', p.json.id)).code).toBe(0);
    expect((await e.req('GET', `/v1/posts/${p.json.id}`)).status).toBe(200);
    expect((await e.req('GET', `/v1/media/${up.json.key}`)).status).toBe(200);
    expect((await cli('hidden', 'list')).out).toContain('(nothing is hidden)');
    expect((await cli('hide', 'post', crypto.randomUUID())).code).toBe(1);
    expect((await cli('hide', 'nonsense', crypto.randomUUID())).code).toBe(1);
  });

  it('hide works for comments, reviews and LFG posts too', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const p = await post(a.token);
    const c = await e.req('POST', `/v1/posts/${p.json.id}/comments`, { token: b.token, body: { body: 'a comment' } });
    const r = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: b.token, body: { weaponUuid: WEAPON_1, rating: 3, body: 'ok' } });
    const l = await e.req('POST', '/v1/lfg', { token: b.token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2 } });
    for (const [type, id] of [['comment', c.json.id], ['review', r.json.id], ['lfg', l.json.id]]) {
      expect((await cli('hide', type, id)).code, type).toBe(0);
    }
    expect((await e.req('GET', `/v1/posts/${p.json.id}/comments`, { token: a.token })).json.items).toHaveLength(0);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/reviews`, { token: a.token })).json.items).toHaveLength(0);
    expect((await e.req('GET', '/v1/lfg', { token: a.token })).json.items).toHaveLength(0);
    const hidden = (await cli('hidden', 'list')).out;
    expect(hidden).toContain(`comment ${c.json.id}`);
    expect(hidden).toContain(`review ${r.json.id}`);
    expect(hidden).toContain(`lfg ${l.json.id}`);
  });

  it('delete-content removes one item for good (dry run first), with its comments, likes and images', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const up = await e.req('POST', '/v1/media', { token: a.token, raw: PNG, headers: { 'content-type': 'image/png' } });
    const p = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'to be removed', media: [up.json.key] } });
    await e.req('POST', `/v1/posts/${p.json.id}/comments`, { token: b.token, body: { body: 'nice' } });
    await e.req('PUT', `/v1/posts/${p.json.id}/like`, { token: b.token });
    const other = await post(a.token, 'stays');

    const dry = await cli('delete-content', 'post', p.json.id);
    expect(dry.code).toBe(2);
    expect(count('posts')).toBe(2);

    const done = await cli('delete-content', 'post', p.json.id, '--yes');
    expect(done.code).toBe(0);
    expect(done.out).toContain('1 file');
    expect(count('posts')).toBe(1);
    expect(count('comments')).toBe(0);
    expect(count('post_likes')).toBe(0);
    expect(count('media')).toBe(0);
    expect(fs.existsSync(path.join(e.mediaDir, ...up.json.key.split('/')))).toBe(false);
    expect((await e.req('GET', `/v1/posts/${other.json.id}`)).status).toBe(200);
    expect((await cli('delete-content', 'post', p.json.id, '--yes')).code).toBe(1);
    expect(count('moderation_audit', "action = 'delete-content'")).toBe(1);
  });

  it('delete-content of a review or comment also drops the reports about it', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const c = await e.login('carol');
    const r = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: a.token, body: { weaponUuid: WEAPON_1, rating: 1, body: 'awful' } });
    await e.req('POST', '/v1/reports', { token: b.token, body: { targetType: 'review', targetId: r.json.id, reason: 'x' } });
    await e.req('POST', '/v1/reports', { token: c.token, body: { targetType: 'review', targetId: r.json.id, reason: 'y' } });
    expect(count('reports')).toBe(2);
    expect((await cli('delete-content', 'review', r.json.id, '--yes')).code).toBe(0);
    expect(count('reports')).toBe(0);
    expect(count('skin_reviews')).toBe(0);
  });

  it('reports list shows reporters, eligible reporters, the state and an excerpt', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const c = await e.login('carol');
    const d = await e.login('dave');
    const p = await post(a.token, 'questionable content here');
    e.mature(c.user.id);
    await e.req('POST', '/v1/reports', { token: b.token, body: { targetType: 'post', targetId: p.json.id, reason: 'spam' } }); // too new: counts as a report, not as eligible
    await e.req('POST', '/v1/reports', { token: c.token, body: { targetType: 'post', targetId: p.json.id, reason: 'insult' } });
    const list = await cli('reports', 'list');
    expect(list.out).toContain(`post ${p.json.id}`);
    expect(list.out).toContain(`author=${a.user.id}`);
    expect(list.out).toContain('reports=2 eligible=1');
    expect(list.out).toContain('visible');
    expect(list.out).toContain('questionable content here');
    expect(list.out).toMatch(/reasons: .*spam.*insult|reasons: .*insult.*spam/);
    // Once hidden by reports the state says who hid it.
    e.mature(b.user.id);
    e.mature(d.user.id);
    await e.req('POST', '/v1/reports', { token: b.token, body: { targetType: 'post', targetId: p.json.id, reason: 'spam' } });
    await e.req('POST', '/v1/reports', { token: d.token, body: { targetType: 'post', targetId: p.json.id, reason: 'again' } });
    expect((await cli('reports', 'list')).out).toContain('hidden(reports)');
    expect((await cli('hidden', 'list')).out).toContain('hidden by reports');
    expect((await cli('reports', 'list', '--limit', '1')).out.split('\n')).toHaveLength(1);
  });

  it('existing moderator commands are audited too', async () => {
    const a = await e.login('alice');
    const up = await e.req('POST', '/v1/media', { token: a.token, raw: PNG, headers: { 'content-type': 'image/png' } });
    const p = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'x', media: [up.json.key] } });
    await cli('hide', 'post', p.json.id);
    await cli('unhide', 'post', p.json.id);
    await cli('hide', 'post', p.json.id);
    await cli('quarantine', 'restore', up.json.key);
    await cli('quarantine', 'purge', up.json.key);
    const actions = (e.db.prepare('SELECT action FROM moderation_audit ORDER BY id').all() as { action: string }[]).map((r) => r.action);
    expect(actions).toEqual(['hide', 'unhide', 'hide', 'quarantine-restore']);
  });
});

describe('hidden content is explained to its author', () => {
  it('records why an item is hidden: reports or moderator', async () => {
    const a = await e.login('alice');
    const p1 = await post(a.token, 'one');
    const p2 = await post(a.token, 'two');
    await cli('hide', 'post', p1.json.id);
    const reporters = [] as Awaited<ReturnType<typeof e.login>>[];
    for (const n of ['r1', 'r2', 'r3']) {
      const r = await e.login(n);
      e.mature(r.user.id);
      reporters.push(r);
    }
    for (const r of reporters) {
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'post', targetId: p2.json.id, reason: 'bad' } });
    }
    const rows = e.db.prepare('SELECT id, hidden, hidden_reason FROM posts ORDER BY created_at, id').all() as any[];
    expect(Object.fromEntries(rows.map((r) => [r.id, r.hidden_reason]))).toEqual({ [p1.json.id]: 'moderator', [p2.json.id]: 'reports' });
  });
});

describe('sanctions and data rights', () => {
  it('the export lists sanctions and moderator actions about the account (transparency)', async () => {
    const a = await e.login('alice');
    const p = await post(a.token);
    await cli('hide', 'post', p.json.id);
    await cli('restrict', '--id', a.user.id, '--days', '4', '--reason', 'spam', '--yes');
    const res = await e.req('GET', '/v1/me/export', { token: a.token });
    expect(res.status).toBe(200);
    expect(res.json.sanctions).toEqual([
      { kind: 'restrict', reason: 'spam', createdAt: new Date(e.clock.t).toISOString(), until: new Date(e.clock.t + 4 * DAY).toISOString(), liftedAt: null },
    ]);
    expect(res.json.moderationLog.map((x: any) => x.action)).toEqual(['hide', 'restrict']);
    expect(res.json.moderationLog[0]).toMatchObject({ targetType: 'post', targetId: p.json.id });
  });

  it('the sweeper forgets sanctions that ended more than a year ago and operator log rows older than two years', async () => {
    const u = 'b'.repeat(32);
    const t = e.clock.t;
    e.repo.addSanction({ userId: u, kind: 'ban', until: t - 400 * DAY, reason: 'spam', now: t - 500 * DAY });
    e.repo.addSanction({ userId: u, kind: 'restrict', until: t - 30 * DAY, reason: 'spam', now: t - 60 * DAY });
    e.repo.addSanction({ userId: u, kind: 'ban', until: null, reason: 'hate', now: t - 900 * DAY }); // permanent: kept
    e.repo.addAudit({ at: t - 800 * DAY, action: 'ban', userId: u });
    e.repo.addAudit({ at: t - 10 * DAY, action: 'unban', userId: u });
    await sweep(e.mediaDeps());
    expect(count('sanctions')).toBe(2);
    expect(count('sanctions', 'until IS NULL')).toBe(1);
    expect(count('moderation_audit')).toBe(1);
  });
});

describe('the author sees what is hidden, and why (own lists only)', () => {
  it('GET /v1/me/posts lists own posts including hidden ones with hiddenReason', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const visible = await post(a.token, 'visible one');
    e.clock.t += 1000;
    const shady = await post(a.token, 'shady one');
    e.clock.t += 1000;
    const other = await post(b.token, 'bob post');
    await cli('hide', 'post', shady.json.id);

    const mine = await e.req('GET', '/v1/me/posts', { token: a.token });
    expect(mine.status).toBe(200);
    expect(mine.json.items.map((p: any) => [p.id, p.hidden, p.hiddenReason])).toEqual([
      [shady.json.id, true, 'moderator'],
      [visible.json.id, false, null],
    ]);
    expect(mine.json.nextCursor).toBeNull();
    const paged = await e.req('GET', '/v1/me/posts?limit=1', { token: a.token });
    expect(paged.json.items).toHaveLength(1);
    expect(paged.json.nextCursor).not.toBeNull();
    const page2 = await e.req('GET', `/v1/me/posts?limit=1&cursor=${paged.json.nextCursor}`, { token: a.token });
    expect(page2.json.items[0].id).toBe(visible.json.id);

    // Bob never sees the hidden post, nor any hidden/hiddenReason field on other people's items.
    const feed = await e.req('GET', '/v1/posts?scope=global', { token: b.token });
    expect(feed.json.items.map((p: any) => p.id).sort()).toEqual([other.json.id, visible.json.id].sort());
    for (const p of feed.json.items) {
      if (p.id === visible.json.id) expect('hidden' in p).toBe(false);
    }
    expect((await e.req('GET', `/v1/posts/${shady.json.id}`, { token: b.token })).status).toBe(404);
    expect((await e.req('GET', `/v1/posts/${shady.json.id}`, { token: a.token })).status).toBe(404); // direct reads stay 404
    expect((await e.req('GET', '/v1/me/posts')).status).toBe(401);
    // A post hidden by reports says so.
    const reporters = [] as Awaited<ReturnType<typeof e.login>>[];
    for (const n of ['r1', 'r2', 'r3']) {
      const r = await e.login(n);
      e.mature(r.user.id);
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'post', targetId: visible.json.id, reason: 'x' } });
      reporters.push(r);
    }
    const after = await e.req('GET', '/v1/me/posts', { token: a.token });
    expect(after.json.items.find((p: any) => p.id === visible.json.id)).toMatchObject({ hidden: true, hiddenReason: 'reports' });
  });

  it('myReview and the LFG post of the author carry the same fields', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const r = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: a.token, body: { weaponUuid: WEAPON_1, rating: 2, body: 'meh' } });
    expect(r.json).toMatchObject({ mine: true, hidden: false, hiddenReason: null });
    const l = await e.req('POST', '/v1/lfg', { token: a.token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2 } });
    expect(l.json).toMatchObject({ hidden: false, hiddenReason: null });
    await cli('hide', 'review', r.json.id);
    await cli('hide', 'lfg', l.json.id);

    const summary = await e.req('GET', `/v1/skins/${SKIN_A}/summary`, { token: a.token });
    expect(summary.json.myReview).toMatchObject({ id: r.json.id, hidden: true, hiddenReason: 'moderator' });
    const mine = await e.req('GET', '/v1/lfg/mine', { token: a.token });
    expect(mine.json).toMatchObject({ id: l.json.id, hidden: true, hiddenReason: 'moderator' });
    // Others get neither the items nor the fields.
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`, { token: b.token })).json.myReview).toBeNull();
    expect((await e.req('GET', '/v1/lfg', { token: b.token })).json.items).toHaveLength(0);
    // A visible LFG post of someone else has no such fields.
    const l2 = await e.req('POST', '/v1/lfg', { token: b.token, body: { region: 'ap', mode: 'unrated', partyCode: 'BCDEFG', slots: 2 } });
    const seenByAlice = await e.req('GET', '/v1/lfg', { token: a.token });
    const item = seenByAlice.json.items.find((i: any) => i.id === l2.json.id);
    expect(item).toBeDefined();
    expect('hidden' in item).toBe(false);
  });
});
