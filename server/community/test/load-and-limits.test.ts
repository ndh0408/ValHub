import { afterEach, describe, expect, it } from 'vitest';
import { FixedWindowLimiter } from '../src/cache.js';
import { loadConfig } from '../src/config.js';
import { cleanUserText, MAX_TOKENS, MAX_UNITS, moderate } from '../src/moderation/filter.js';
import { startLoadMonitor } from '../src/load.js';
import { setup, SKIN_A, WEAPON_1, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

const BAD = 'you are a nigger'; // rejected by the filter (hate)

describe('CS-03: the rate limit runs before the text filter', () => {
  it('posts: a rejected attempt still counts, and an over-limit request is 429 whatever its text', async () => {
    e = setup();
    const { token } = await e.login();
    for (let i = 0; i < 10; i++) {
      const res = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: BAD } });
      expect(res.status, `attempt ${i + 1}`).toBe(400);
      expect(res.json.error.reason).toBe('content_inappropriate');
    }
    const eleventh = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: BAD } });
    expect(eleventh.status).toBe(429);
    expect(eleventh.json.error).toMatchObject({
      code: 'rate_limited',
      reason: 'rate_limited',
      params: { bucket: 'posts', limit: 10, windowSeconds: 3600 },
    });
    // A clean post is refused too: the quota is spent.
    const clean = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hello there' } });
    expect(clean.status).toBe(429);
  });

  it('structural validation errors do not cost quota (cheap, before the limit)', async () => {
    e = setup();
    const { token } = await e.login();
    for (let i = 0; i < 12; i++) {
      const res = await e.req('POST', '/v1/posts', { token, body: { kind: 'nope', body: 'x' } });
      expect(res.status).toBe(400);
    }
    const ok = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hello there' } });
    expect(ok.status).toBe(200);
  });

  it('comments: 30 rejected attempts then 429', async () => {
    e = setup();
    const a = await e.login('alice');
    const b = await e.login('bob');
    const post = await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'hello there' } });
    for (let i = 0; i < 30; i++) {
      const res = await e.req('POST', `/v1/posts/${post.json.id}/comments`, { token: b.token, body: { body: BAD } });
      expect(res.status).toBe(400);
    }
    const next = await e.req('POST', `/v1/posts/${post.json.id}/comments`, { token: b.token, body: { body: BAD } });
    expect(next.status).toBe(429);
  });

  it('reviews: 30 rejected attempts then 429', async () => {
    e = setup();
    const { token } = await e.login();
    for (let i = 0; i < 30; i++) {
      const res = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, {
        token,
        body: { weaponUuid: WEAPON_1, rating: 5, body: BAD },
      });
      expect(res.status).toBe(400);
    }
    const next = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, {
      token,
      body: { weaponUuid: WEAPON_1, rating: 5, body: BAD },
    });
    expect(next.status).toBe(429);
  });

  it('LFG: create (6 / 10 min) and PATCH (120 / 10 min) count rejected notes', async () => {
    e = setup();
    const { token } = await e.login();
    const create = (note: string) =>
      e.req('POST', '/v1/lfg', {
        token,
        body: { region: 'ap', mode: 'competitive', partyCode: 'ABC123', slots: 2, note },
      });
    for (let i = 0; i < 6; i++) expect((await create(BAD)).status).toBe(400);
    expect((await create(BAD)).status).toBe(429);
    e.clock.t += 10 * 60_000;
    const ok = await create('chill game');
    expect(ok.status).toBe(200);
    const patch = (note: string) =>
      e.req('PATCH', `/v1/lfg/${ok.json.id}`, { token, body: { note } });
    expect((await patch(BAD)).status).toBe(400);
    expect((await patch('still chill')).status).toBe(200);
  });
});

describe('CS-03: coarse per-user request bucket', () => {
  it('limits every request of a signed-in user (any method), per user, per minute', async () => {
    e = setup({ tuning: { userRequestLimitPerMin: 20 } });
    const a = await e.login('alice');
    const b = await e.login('bob');
    const statuses: number[] = [];
    for (let i = 0; i < 25; i++) statuses.push((await e.req('GET', '/v1/me', { token: a.token })).status);
    expect(statuses.slice(0, 20).every((s) => s === 200)).toBe(true);
    expect(statuses.slice(20).every((s) => s === 429)).toBe(true);

    const limited = await e.req('DELETE', `/v1/lfg/${crypto.randomUUID()}`, { token: a.token });
    expect(limited.status).toBe(429);
    expect(limited.json.error).toMatchObject({
      code: 'rate_limited',
      reason: 'rate_limited',
      params: { bucket: 'requests', limit: 20, windowSeconds: 60 },
      messageEn: expect.any(String),
    });
    expect(Number(limited.headers.get('retry-after'))).toBeGreaterThan(0);
    expect(limited.json.error.retryAfter).toBeGreaterThan(0);

    // Someone else, and anonymous reads, are unaffected.
    expect((await e.req('GET', '/v1/me', { token: b.token })).status).toBe(200);
    expect((await e.req('GET', '/v1/posts')).status).toBe(200);

    // The next minute starts fresh.
    e.clock.t += 60_000;
    expect((await e.req('GET', '/v1/me', { token: a.token })).status).toBe(200);
  });

  it('the default is 240 a minute and it is read from USER_REQUEST_LIMIT_PER_MIN', () => {
    const base = { SESSION_SECRET: 'x'.repeat(32), PEPPER: 'y'.repeat(32) };
    expect(loadConfig(base).userRequestLimitPerMin).toBe(240);
    expect(loadConfig({ ...base, USER_REQUEST_LIMIT_PER_MIN: '600' }).userRequestLimitPerMin).toBe(600);
    expect(() => loadConfig({ ...base, USER_REQUEST_LIMIT_PER_MIN: '1' })).toThrow(/USER_REQUEST_LIMIT_PER_MIN/);
    expect(loadConfig(base).loadShedLagMs).toBe(250);
    expect(loadConfig({ ...base, LOAD_SHED_LAG_MS: '0' }).loadShedLagMs).toBe(0);
  });
});

describe('CS-03: load shedding on event-loop lag', () => {
  it('answers 503 server_busy + Retry-After while the lag is above the threshold, except /healthz', async () => {
    let lag = 0;
    e = setup({ loadProbe: () => lag });
    const { token } = await e.login();
    expect((await e.req('GET', '/v1/me', { token })).status).toBe(200);

    lag = 300;
    const shed = await e.req('GET', '/v1/me', { token });
    expect(shed.status).toBe(503);
    expect(shed.json.error).toMatchObject({ code: 'server_busy', reason: 'server_busy', retryAfter: 2 });
    expect(shed.headers.get('retry-after')).toBe('2');
    expect(shed.headers.get('cache-control')).toBe('no-store');
    expect((await e.req('GET', '/v1/posts')).status).toBe(503);
    expect((await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hi there' } })).status).toBe(503);
    expect((await e.req('GET', '/healthz')).status).toBe(200);

    lag = 100;
    expect((await e.req('GET', '/v1/me', { token })).status).toBe(200);
  });

  it('LOAD_SHED_LAG_MS = 0 turns shedding off', async () => {
    e = setup({ loadProbe: () => 10_000, tuning: { loadShedLagMs: 0 } });
    expect((await e.req('GET', '/v1/posts')).status).toBe(200);
  });

  it('the monitor turns the histogram into a lag reading (deterministic, fake histogram)', async () => {
    let p95ms = 12; // a healthy loop: ticks arrive about one resolution apart
    let resets = 0;
    const monitor = startLoadMonitor(20, 10, () => ({
      enable: () => true,
      disable: () => true,
      reset: () => void resets++,
      percentile: () => p95ms * 1e6,
    }));
    try {
      await new Promise((r) => setTimeout(r, 60));
      expect(monitor.lagMs()).toBe(2); // 12 ms between ticks - the 10 ms resolution
      expect(resets).toBeGreaterThan(0);
      p95ms = 410; // a blocked loop
      await new Promise((r) => setTimeout(r, 60));
      expect(monitor.lagMs()).toBe(400);
      p95ms = 3; // never negative
      await new Promise((r) => setTimeout(r, 60));
      expect(monitor.lagMs()).toBe(0);
    } finally {
      monitor.stop();
    }
  });

  it('the real monitor starts, reads a sane value and stops', async () => {
    const monitor = startLoadMonitor(50, 10);
    try {
      await new Promise((r) => setTimeout(r, 120));
      expect(monitor.lagMs()).toBeGreaterThanOrEqual(0);
      expect(Number.isFinite(monitor.lagMs())).toBe(true);
    } finally {
      monitor.stop();
    }
  });
});

describe('CS-03: work caps in the content filter', () => {
  it('refuses a text with too many words or isolated letters (400 content_too_complex)', () => {
    const tooManyWords = 'a '.repeat(MAX_TOKENS + 5);
    expect(moderate(tooManyWords).rejected).toBe('complex');
    expect(() => cleanUserText(tooManyWords, 'en')).toThrowError(/isolated characters|ký tự rời rạc/);
    const tooManyUnits = 'x.'.repeat(MAX_UNITS + 5);
    expect(moderate(tooManyUnits).rejected).toBe('complex');
    expect(moderate('z'.repeat(5000)).rejected).toBe('complex'); // beyond MAX_INPUT_CHARS
  });

  it('the API returns the reason and both messages', async () => {
    e = setup();
    const { token } = await e.login();
    const res = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'a '.repeat(450) } });
    expect(res.status).toBe(400);
    expect(res.json.error).toMatchObject({
      code: 'invalid_input',
      reason: 'content_too_complex',
      message: expect.stringContaining('ký tự'),
      messageEn: expect.stringContaining('isolated'),
    });
  });

  it('ordinary long text is untouched by the caps', () => {
    const long = 'Xin chào các bạn, hôm nay mình muốn chia sẻ bộ skin mới rất đẹp nhé. '.repeat(14).slice(0, 1000);
    const r = moderate(long, { language: 'vi', country: 'VN' });
    expect(r.rejected).toBeNull();
    expect(r.text).toBe(long);
  });

  it('inputs just under the caps stay fast (adversarial corpus, generous bound)', () => {
    const ZW = '​';
    const corpus = [
      'a '.repeat(MAX_TOKENS - 2),
      'x.'.repeat(MAX_UNITS - 2),
      'f u c k '.repeat(70),
      'a b c d e f g h i j k l m n o p q r s t u v w x y z '.repeat(11),
      `a${ZW}`.repeat(300),
      '1 2 3 4 5 6 7 8 9 0 '.repeat(29),
      'a-b_c*d.e,f'.repeat(90),
      'dm'.repeat(400),
    ];
    const t = Date.now();
    for (const text of corpus) moderate(text, { language: 'vi', country: 'VN' });
    expect(Date.now() - t).toBeLessThan(2500);
  });
});

describe('CS-13: the limiter map is capped', () => {
  it('drops the least recently used key beyond maxEntries and keeps counting the rest', () => {
    const l = new FixedWindowLimiter(3);
    const now = 1_000_000;
    for (const k of ['a', 'b', 'c']) l.hit(k, 5, 60_000, now);
    l.hit('a', 5, 60_000, now); // a is most recent, b least
    l.hit('d', 5, 60_000, now); // evicts b
    expect(l.size).toBe(3);
    // b starts from scratch; a kept its count (2 so far)
    for (let i = 0; i < 3; i++) expect(l.hit('a', 5, 60_000, now).ok).toBe(true);
    expect(l.hit('a', 5, 60_000, now).ok).toBe(false);
  });
});
