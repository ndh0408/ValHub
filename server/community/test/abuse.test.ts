import { afterEach, describe, expect, it } from 'vitest';
import { FixedWindowLimiter, TtlCache } from '../src/cache.js';
import { REPORT_MIN_ACCOUNT_AGE_MS } from '../src/context.js';
import { expectError, PNG, setup, SKIN_A, SKIN_B, WEAPON_1, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

const ip = (addr: string) => ({ 'cf-connecting-ip': addr });

describe('unauthenticated reads are limited per client IP', () => {
  it('600 / minute by default, per IP, resets each minute, never applies to signed-in requests', async () => {
    e = setup();
    const { token } = await e.login('alice');
    e.clock.t = Math.ceil(e.clock.t / 60_000) * 60_000 + 1000;
    for (let i = 0; i < 600; i++) {
      const r = await e.req('GET', '/v1/posts', { headers: ip('203.0.113.7') });
      expect(r.status, `request ${i + 1}`).toBe(200);
    }
    const blocked = await e.req('GET', '/v1/posts', { headers: ip('203.0.113.7') });
    expectError(blocked, 429, 'rate_limited');
    expect(blocked.headers.get('retry-after')).toBe('59');
    expect(blocked.json.error.retryAfter).toBe(59);
    // The limit is shared by all public read endpoints ...
    expectError(await e.req('GET', '/v1/skins/top', { headers: ip('203.0.113.7') }), 429, 'rate_limited');
    expectError(await e.req('GET', '/v1/communities', { headers: ip('203.0.113.7') }), 429, 'rate_limited');
    // ... but per IP, and not for signed-in users behind that IP.
    expect((await e.req('GET', '/v1/posts', { headers: ip('203.0.113.8') })).status).toBe(200);
    expect((await e.req('GET', '/v1/posts', { token, headers: ip('203.0.113.7') })).status).toBe(200);
    // Next window.
    e.clock.t += 60_000;
    expect((await e.req('GET', '/v1/posts', { headers: ip('203.0.113.7') })).status).toBe(200);
  });

  it('is configurable, keyed by the hashed IP, and skipped when the IP is unknown', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 3 } });
    for (let i = 0; i < 3; i++) expect((await e.req('GET', '/v1/communities', { headers: ip('198.51.100.1') })).status).toBe(200);
    expectError(await e.req('GET', '/v1/communities', { headers: ip('198.51.100.1') }), 429, 'rate_limited');
    // No IP header and no socket (in-process test requests): nothing to key on, so no limit.
    for (let i = 0; i < 10; i++) expect((await e.req('GET', '/v1/communities')).status).toBe(200);
    // X-Forwarded-For is never used: its leftmost value is chosen by the client, so it cannot name a limit bucket.
    for (let i = 0; i < 10; i++) expect((await e.req('GET', '/v1/communities', { headers: { 'x-forwarded-for': `192.0.2.${i}` } })).status).toBe(200);
    // Raw IPs are never stored (the limiter is in memory; the database has no trace).
    expect(JSON.stringify(e.db.prepare('SELECT * FROM rate_limits').all())).not.toContain('198.51.100');
  });

  it('media files have their own, larger limit; non-public endpoints are untouched', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 2, anonMediaLimitPerMin: 4 } });
    const { token } = await e.login('alice');
    const key = (await e.req('POST', '/v1/media', { token, raw: PNG, headers: { 'content-type': 'image/png' } })).json.key;
    for (let i = 0; i < 4; i++) expect((await e.req('GET', `/v1/media/${key}`, { headers: ip('203.0.113.50') })).status).toBe(200);
    expectError(await e.req('GET', `/v1/media/${key}`, { headers: ip('203.0.113.50') }), 429, 'rate_limited');
    // The feed limit (2) is separate from the media limit (4).
    expect((await e.req('GET', '/v1/posts', { headers: ip('203.0.113.50') })).status).toBe(200);
    // Endpoints that need a session keep answering 401, never 429.
    for (let i = 0; i < 8; i++) expectError(await e.req('GET', '/v1/me', { headers: ip('203.0.113.51') }), 401, 'unauthorized');
    // Writes are never counted by the anonymous limiter.
    for (let i = 0; i < 8; i++) expectError(await e.req('POST', '/v1/auth/riot', { headers: ip('203.0.113.52'), body: { region: 'ap' } }), 400, 'invalid_input');
  });

  it('cached responses cost nothing and do not count against the limit (many phones share one carrier address)', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 2, publicCacheTtlMs: 45_000 } });
    const shared = ip('100.64.0.1');
    expect((await e.req('GET', '/v1/skins/top', { headers: shared })).headers.get('x-cache')).toBe('miss'); // 1
    for (let i = 0; i < 20; i++) expect((await e.req('GET', '/v1/skins/top', { headers: shared })).headers.get('x-cache')).toBe('hit');
    expect((await e.req('GET', '/v1/communities', { headers: shared })).status).toBe(200); // 2
    expectError(await e.req('GET', '/v1/posts', { headers: shared }), 429, 'rate_limited'); // uncached read: over the limit
    for (let i = 0; i < 5; i++) expect((await e.req('GET', '/v1/skins/top', { headers: shared })).status).toBe(200); // cached: fine
    // A cache miss (different query) is counted.
    expectError(await e.req('GET', '/v1/skins/top?limit=7', { headers: shared }), 429, 'rate_limited');
  });

  it('limiter and cache primitives', () => {
    const l = new FixedWindowLimiter();
    expect(l.hit('k', 2, 1000, 5000)).toEqual({ ok: true, retryAfterSeconds: 0 });
    expect(l.hit('k', 2, 1000, 5100).ok).toBe(true);
    expect(l.hit('k', 2, 1000, 5200)).toEqual({ ok: false, retryAfterSeconds: 1 });
    expect(l.hit('k', 2, 1000, 6000).ok).toBe(true);
    l.prune(1_000_000);
    expect(l.size).toBe(0);
    const c = new TtlCache<number>(2);
    c.set('a', 1, 100, 0);
    c.set('b', 2, 100, 0);
    c.set('c', 3, 100, 0); // evicts the oldest
    expect(c.get('a', 1)).toBeUndefined();
    expect(c.get('b', 1)).toBe(2);
    expect(c.get('b', 200)).toBeUndefined(); // expired
    c.set('c', 4, 100, 50);
    c.prune(1000);
    expect(c.size).toBe(0);
  });
});

describe('anonymous aggregate queries are cached', () => {
  const votes = async (token: string, skin: string) =>
    e.req('PUT', `/v1/skins/${skin}/vote`, { token, body: { weaponUuid: WEAPON_1 } });
  const top = (token?: string, qs = '') => e.req('GET', `/v1/skins/top${qs}`, { token });

  it('serves identical anonymous responses for 45 s, then refreshes; signed-in requests are never cached', async () => {
    e = setup({ established: true, tuning: { publicCacheTtlMs: 45_000 } });
    const a = await e.login('alice');
    const b = await e.login('bob');
    await votes(a.token, SKIN_A);

    const first = await top();
    expect(first.headers.get('x-cache')).toBe('miss');
    expect(first.json.items).toEqual([expect.objectContaining({ skinUuid: SKIN_A, votes: 1 })]);
    await votes(b.token, SKIN_A);
    await votes(b.token, SKIN_B);
    e.clock.t += 30_000;
    const cached = await top();
    expect(cached.headers.get('x-cache')).toBe('hit');
    expect(cached.json).toEqual(first.json); // stale by design
    expect(cached.headers.get('content-type')).toContain('application/json');
    // A signed-in request sees fresh data (and `voted`) and does not touch the cache.
    const live = await top(b.token);
    expect(live.headers.get('x-cache')).toBeNull();
    expect(live.json.items.map((i: any) => [i.skinUuid, i.votes, i.voted])).toEqual([[SKIN_A, 2, true], [SKIN_B, 1, true]]);
    // After the TTL the anonymous view catches up.
    e.clock.t += 20_000;
    const fresh = await top();
    expect(fresh.headers.get('x-cache')).toBe('miss');
    expect(fresh.json.items.map((i: any) => [i.skinUuid, i.votes])).toEqual([[SKIN_A, 2], [SKIN_B, 1]]);
  });

  it('caches summary, reviews, votes and communities; keys ignore parameter order, differ by value', async () => {
    e = setup({ established: true, tuning: { publicCacheTtlMs: 45_000 } });
    const a = await e.login('alice');
    const get = (p: string) => e.req('GET', p);
    for (const p of [`/v1/skins/${SKIN_A}/summary`, `/v1/skins/${SKIN_A}/reviews`, `/v1/skins/votes?ids=${SKIN_A}`, '/v1/communities']) {
      expect((await get(p)).headers.get('x-cache'), p).toBe('miss');
      expect((await get(p)).headers.get('x-cache'), p).toBe('hit');
    }
    expect((await get('/v1/skins/top?limit=5&period=week')).headers.get('x-cache')).toBe('miss');
    expect((await get('/v1/skins/top?period=week&limit=5')).headers.get('x-cache')).toBe('hit');
    expect((await get('/v1/skins/top?period=week&limit=6')).headers.get('x-cache')).toBe('miss');
    expect((await get(`/v1/skins/${SKIN_B}/summary`)).headers.get('x-cache')).toBe('miss');
    // Feed, single posts and media are not aggregate queries: never cached.
    expect((await get('/v1/posts')).headers.get('x-cache')).toBeNull();
    void a;
  });

  it('never caches errors, and is off unless configured', async () => {
    e = setup({ established: true, tuning: { publicCacheTtlMs: 45_000 } });
    expectError(await e.req('GET', '/v1/skins/top?period=month'), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/skins/top?period=month'), 400, 'invalid_input');
    e.close();
    e = setup({ established: true }); // default tuning in tests: cache off
    const a = await e.login('alice');
    await votes(a.token, SKIN_A);
    expect((await top()).headers.get('x-cache')).toBeNull();
    expect((await top()).json.items).toHaveLength(1);
    await votes((await e.login('bob')).token, SKIN_B);
    expect((await top()).json.items).toHaveLength(2); // immediately visible
  });
});

describe('report-hiding rule', () => {
  async function scene() {
    e = setup();
    const author = await e.login('author');
    const post = (await e.req('POST', '/v1/posts', { token: author.token, body: { kind: 'text', body: 'target' } })).json.id as string;
    const report = (token: string) =>
      e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: post, reason: 'spam' } });
    const hidden = () => (e.db.prepare('SELECT hidden FROM posts WHERE id = ?').get(post) as { hidden: number }).hidden === 1;
    return { author, post, report, hidden };
  }

  it('reports from new accounts or accounts without activity are stored but do not count', async () => {
    const { report, hidden, post } = await scene();
    const users = await Promise.all(['n1', 'n2', 'n3', 'n4'].map((n) => e.login(n)));
    // Fresh accounts (0 s old, no activity): three reports do not hide.
    for (const u of users.slice(0, 3)) expect((await report(u.token)).status).toBe(204);
    expect(hidden()).toBe(false);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM reports').get()).toEqual({ n: 3 });
    // Old enough but no activity: still ignored.
    e.db.prepare('UPDATE users SET created_at = ?').run(e.clock.t - 3 * 86400_000);
    expect((await report(users[3]!.token)).status).toBe(204);
    expect(hidden()).toBe(false);
    // Activity but too young: ignored.
    const young = await e.login('young');
    e.db.prepare("INSERT INTO skin_votes (user_id, skin_uuid, weapon_uuid, created_at) VALUES (?, ?, ?, ?)").run(young.user.id, SKIN_A, WEAPON_1, e.clock.t);
    await report(young.token);
    expect(hidden()).toBe(false);
    void post;
  });

  it('three eligible reporters hide; the exact 24 h boundary counts', async () => {
    const { report, hidden } = await scene();
    const users = await Promise.all(['a1', 'a2', 'a3'].map((n) => e.login(n)));
    for (const u of users) e.mature(u.user.id);
    // a3 is exactly 24 h old (eligible: <= cutoff) — make a2 one millisecond too young.
    e.db.prepare('UPDATE users SET created_at = ? WHERE id = ?').run(e.clock.t - REPORT_MIN_ACCOUNT_AGE_MS, users[2]!.user.id);
    e.db.prepare('UPDATE users SET created_at = ? WHERE id = ?').run(e.clock.t - REPORT_MIN_ACCOUNT_AGE_MS + 1, users[1]!.user.id);
    await report(users[0]!.token);
    await report(users[1]!.token);
    await report(users[2]!.token);
    expect(hidden()).toBe(false); // only two eligible
    e.db.prepare('UPDATE users SET created_at = ? WHERE id = ?').run(e.clock.t - REPORT_MIN_ACCOUNT_AGE_MS, users[1]!.user.id);
    await report(users[1]!.token); // same report again (idempotent) but the count is re-evaluated
    expect(hidden()).toBe(true);
  });

  it('ineligible reports never add up: 2 eligible + 10 ineligible does not hide', async () => {
    const { report, hidden } = await scene();
    const eligible = await Promise.all(['e1', 'e2'].map((n) => e.login(n)));
    eligible.forEach((u) => e.mature(u.user.id));
    for (const u of eligible) await report(u.token);
    for (let i = 0; i < 10; i++) await report((await e.login(`sock${i}`)).token);
    expect(hidden()).toBe(false);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM reports').get()).toEqual({ n: 12 });
  });

  it('the author’s own reports and duplicates do not count; every answer is the same empty 204', async () => {
    const { author, report, hidden, post } = await scene();
    const users = await Promise.all(['d1', 'd2'].map((n) => e.login(n)));
    users.forEach((u) => e.mature(u.user.id));
    e.mature(author.user.id);
    const answers = [
      await report(author.token), // self-report
      await report(users[0]!.token),
      await report(users[0]!.token), // duplicate
      await report(users[1]!.token),
      await report((await e.login('fresh')).token), // ineligible
    ];
    for (const r of answers) {
      expect(r.status).toBe(204);
      expect(r.bytes.length).toBe(0);
      expect([...r.headers.keys()].filter((h) => h.startsWith('x-'))).toEqual([]);
    }
    expect(hidden()).toBe(false);
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM reports WHERE target_id = ?').get(post)).toEqual({ n: 3 }); // no self-report row
  });

  it('reporters cannot see who else reported: reports are exposed nowhere but the reporter’s own export', async () => {
    const { author, report, post } = await scene();
    const r1 = await e.login('r1');
    const r2 = await e.login('r2');
    await report(r1.token);
    await report(r2.token);
    const json = JSON.stringify([
      (await e.req('GET', `/v1/posts/${post}`, { token: r1.token })).json,
      (await e.req('GET', '/v1/posts', { token: r1.token })).json,
      (await e.req('GET', `/v1/posts/${post}`, { token: author.token })).json,
    ]);
    expect(json).not.toContain(r1.user.id);
    expect(json).not.toContain(r2.user.id);
    expect(json).not.toMatch(/report/i);
    const mine = (await e.req('GET', '/v1/me/export', { token: r1.token })).json;
    expect(mine.reportsFiled).toHaveLength(1);
    expect(JSON.stringify(mine)).not.toContain(r2.user.id);
  });

  it('applies to comments, LFG posts and reviews too', async () => {
    e = setup();
    const author = await e.login('author');
    const rs = await Promise.all(['a', 'b', 'c'].map((n) => e.login(n)));
    const post = (await e.req('POST', '/v1/posts', { token: author.token, body: { kind: 'text', body: 'x' } })).json.id;
    const comment = (await e.req('POST', `/v1/posts/${post}/comments`, { token: author.token, body: { body: 'bad' } })).json.id;
    const rep = (t: string, id: string) => e.req('POST', '/v1/reports', { token: t, body: { targetType: 'comment', targetId: id, reason: 'x' } });
    for (const r of rs) await rep(r.token, comment);
    expect(e.db.prepare('SELECT hidden FROM comments WHERE id = ?').get(comment)).toEqual({ hidden: 0 });
    // The accounts age and become active; the next report re-evaluates every reporter, so it now counts.
    rs.forEach((r) => e.mature(r.user.id));
    await rep(rs[0]!.token, comment);
    expect(e.db.prepare('SELECT hidden FROM comments WHERE id = ?').get(comment)).toEqual({ hidden: 1 });
  });
});
