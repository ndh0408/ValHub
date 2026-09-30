import { afterEach, describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';
import { ipKey, isPrivateAddress } from '../src/ip.js';
import { expectError, PNG, setup, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

const cf = (addr: string) => ({ 'cf-connecting-ip': addr });

describe('ipKey: what a client address is limited as (CS-13)', () => {
  it('IPv4 stays as it is; IPv6 counts as its /64 whatever its spelling', () => {
    expect(ipKey('203.0.113.7')).toBe('203.0.113.7');
    const a = ipKey('2001:db8:1:2:aaaa:bbbb:cccc:dddd');
    expect(a).toBe('2001:0db8:0001:0002::/64');
    // The rest of the address is the subscriber's to rotate: same key.
    expect(ipKey('2001:db8:1:2::1')).toBe(a);
    expect(ipKey('2001:DB8:1:2:ffff:ffff:ffff:ffff')).toBe(a);
    expect(ipKey('[2001:db8:1:2::9]')).toBe(a);
    expect(ipKey('2001:db8:1:2::9%eth0')).toBe(a);
    // A different /64 is a different client.
    expect(ipKey('2001:db8:1:3::1')).not.toBe(a);
    // Compressed forms.
    expect(ipKey('::1')).toBe('0000:0000:0000:0000::/64');
    expect(ipKey('2001:db8::1')).toBe('2001:0db8:0000:0000::/64');
    expect(ipKey('fe80::1:2:3:4')).toBe('fe80:0000:0000:0000::/64');
    // IPv4-mapped and dotted-tail forms.
    expect(ipKey('::ffff:203.0.113.7')).toBe('203.0.113.7');
    expect(ipKey('64:ff9b::203.0.113.7')).toBe('0064:ff9b:0000:0000::/64');
    // Junk keeps a bounded, lower-cased raw form (never throws).
    expect(ipKey('Not An IP')).toBe('not an ip');
    expect(ipKey('x'.repeat(500))).toHaveLength(64);
    expect(ipKey('1:2:3:4:5:6:7:8:9')).toBe('1:2:3:4:5:6:7:8:9');
  });

  it('recognises the addresses a tunnel or reverse proxy connects from', () => {
    for (const ip of ['127.0.0.1', '10.1.2.3', '172.16.0.5', '172.31.255.1', '192.168.1.1', '169.254.1.1', '100.64.0.1', '100.127.9.9', '::1', 'fd12:3456::1', 'fe80::1', '::ffff:172.18.0.3']) {
      expect(isPrivateAddress(ip), ip).toBe(true);
    }
    for (const ip of ['8.8.8.8', '203.0.113.7', '172.32.0.1', '172.15.0.1', '100.63.0.1', '100.128.0.1', '11.0.0.1', '2001:db8::1', 'garbage', '']) {
      expect(isPrivateAddress(ip), ip).toBe(false);
    }
  });
});

describe('client identity behind the tunnel (CS-13)', () => {
  it('an IPv6 client rotating addresses inside its /64 shares one limit', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 5 } });
    for (let i = 0; i < 5; i++) {
      expect((await e.req('GET', '/v1/communities', { headers: cf(`2001:db8:aa:bb::${i + 1}`) })).status).toBe(200);
    }
    expectError(await e.req('GET', '/v1/communities', { headers: cf('2001:db8:aa:bb:1234:5678:9abc:def0') }), 429, 'rate_limited');
    // Another /64, and an IPv4 address, are other clients.
    expect((await e.req('GET', '/v1/communities', { headers: cf('2001:db8:aa:cc::1') })).status).toBe(200);
    expect((await e.req('GET', '/v1/communities', { headers: cf('203.0.113.9') })).status).toBe(200);
  });

  it('X-Forwarded-For is never a rate-limit identity', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 2 } });
    for (let i = 0; i < 10; i++) {
      expect((await e.req('GET', '/v1/communities', { headers: { 'x-forwarded-for': `198.51.100.${i}, 10.0.0.1` } })).status).toBe(200);
    }
    // With CF-Connecting-IP present it is the only thing used, whatever X-Forwarded-For says.
    for (let i = 0; i < 2; i++) expect((await e.req('GET', '/v1/communities', { headers: { ...cf('203.0.113.1'), 'x-forwarded-for': `1.1.1.${i}` } })).status).toBe(200);
    expectError(await e.req('GET', '/v1/communities', { headers: { ...cf('203.0.113.1'), 'x-forwarded-for': '9.9.9.9' } }), 429, 'rate_limited');
  });

  it('CF-Connecting-IP must be an IP address; junk falls back to the socket (unknown here)', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 1 } });
    for (let i = 0; i < 5; i++) expect((await e.req('GET', '/v1/communities', { headers: cf(`junk-${i}`) })).status).toBe(200);
  });

  it('with TRUST_PROXY off the header is ignored: the socket address is the identity', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 1 }, config: { trustProxy: false } });
    // No socket in in-process requests, so nothing to key on: the spoofed header buys nothing and nothing is limited.
    for (let i = 0; i < 3; i++) expect((await e.req('GET', '/v1/communities', { headers: cf('203.0.113.1') })).status).toBe(200);
    // With a socket, requests share its address whatever they claim.
    const env = { incoming: { socket: { remoteAddress: '198.51.100.20' } } };
    const call = (claimed: string) => e.app.request('http://community.test/v1/communities', { headers: cf(claimed) }, env);
    expect((await call('203.0.113.50')).status).toBe(200);
    expect((await call('203.0.113.51')).status).toBe(429);
  });

  it('TRUST_PROXY on: the header is believed only when the TCP peer is a private / loopback address', async () => {
    e = setup({ tuning: { anonReadLimitPerMin: 1 } });
    const via = (peer: string, claimed: string) =>
      e.app.request('http://community.test/v1/communities', { headers: cf(claimed) }, { incoming: { socket: { remoteAddress: peer } } });
    // The tunnel (private address) forwards two different clients: two buckets.
    expect((await via('172.18.0.4', '203.0.113.1')).status).toBe(200);
    expect((await via('172.18.0.4', '203.0.113.2')).status).toBe(200);
    expect((await via('172.18.0.4', '203.0.113.1')).status).toBe(429);
    // A client that reaches the server directly from a public address cannot choose its identity.
    expect((await via('198.51.100.77', '203.0.113.60')).status).toBe(200);
    expect((await via('198.51.100.77', '203.0.113.61')).status).toBe(429);
  });

  it('TRUST_PROXY defaults to false and is only true when set to "true"', () => {
    const base = { SESSION_SECRET: 'x'.repeat(32), PEPPER: 'y'.repeat(32) };
    expect(loadConfig(base).trustProxy).toBe(false);
    expect(loadConfig({ ...base, TRUST_PROXY: 'true' }).trustProxy).toBe(true);
    expect(loadConfig({ ...base, TRUST_PROXY: 'TRUE ' }).trustProxy).toBe(true);
    expect(loadConfig({ ...base, TRUST_PROXY: 'false' }).trustProxy).toBe(false);
    expect(loadConfig({ ...base, TRUST_PROXY: '1' }).trustProxy).toBe(false);
  });
});

describe('media limiter cannot be skipped with an Authorization header (CS-13)', () => {
  it('any Authorization value, valid or not, still counts against the media limit', async () => {
    e = setup({ tuning: { anonMediaLimitPerMin: 3 } });
    const { token } = await e.login('alice');
    const key = (await e.req('POST', '/v1/media', { token, raw: PNG, headers: { 'content-type': 'image/png' } })).json.key;
    for (let i = 0; i < 3; i++) {
      expect((await e.req('GET', `/v1/media/${key}`, { headers: { ...cf('203.0.113.5'), authorization: `Bearer junk-${i}` } })).status).toBe(200);
    }
    expectError(await e.req('GET', `/v1/media/${key}`, { headers: { ...cf('203.0.113.5'), authorization: 'x' } }), 429, 'rate_limited');
    expectError(await e.req('GET', `/v1/media/${key}`, { headers: cf('203.0.113.5') }), 429, 'rate_limited');
  });
});

describe('sign-in limits are NAT friendly and live in memory (CS-14, CS-22)', () => {
  const attempt = (token: string, headers: Record<string, string>) =>
    e.req('POST', '/v1/auth/riot', { headers, body: { accessToken: token, region: 'ap' } });

  it('successful sign-ins are not counted as failures: a shared address serves many users', async () => {
    e = setup();
    const headers = cf('100.64.9.9');
    for (let i = 0; i < 60; i++) expect((await attempt(`good-user${i}`, headers)).status, `sign-in ${i}`).toBe(200);
    // ... and the small failure limit (30 rejected tokens / 10 min) still protects Riot.
    for (let i = 0; i < 30; i++) expect((await attempt(`bad-${i}`, headers)).status).toBe(401);
    const blocked = await attempt('good-user1', headers);
    expectError(blocked, 429, 'rate_limited');
    expect(blocked.json.error.params).toMatchObject({ bucket: 'authFailures', limit: 30, windowSeconds: 600 });
    expect(Number(blocked.headers.get('retry-after'))).toBeGreaterThan(0);
    // Another address is unaffected, and the failure window ends by itself.
    expect((await attempt('good-other', cf('100.64.9.10'))).status).toBe(200);
    e.clock.t += 10 * 60_000;
    expect((await attempt('good-user1', headers)).status).toBe(200);
  });

  it('riot_unavailable (Riot is down) does not count as a failure of the client', async () => {
    e = setup();
    const headers = cf('203.0.113.77');
    for (let i = 0; i < 40; i++) expect((await attempt('down', headers)).status).toBe(503);
    expect((await attempt('good-alice', headers)).status).toBe(200);
  });

  it('every attempt counts toward a generous total (300 / 10 min)', async () => {
    e = setup();
    const headers = cf('203.0.113.78');
    // Invalid bodies never reach Riot and cost nothing there, but still count as attempts.
    for (let i = 0; i < 300; i++) {
      const res = await e.req('POST', '/v1/auth/riot', { headers, body: { region: 'ap' } });
      expect(res.status, `attempt ${i}`).toBe(400);
    }
    const over = await e.req('POST', '/v1/auth/riot', { headers, body: { region: 'ap' } });
    expectError(over, 429, 'rate_limited');
    expect(over.json.error.params).toMatchObject({ bucket: 'authIp', limit: 300 });
  });

  it('nothing about the address is stored: the counters are in memory, the database has no trace', async () => {
    e = setup();
    await attempt('good-alice', cf('203.0.113.7'));
    await attempt('bad', cf('203.0.113.7'));
    expect(JSON.stringify(e.db.prepare('SELECT * FROM rate_limits').all())).not.toContain('auth');
    expect(e.db.prepare("SELECT COUNT(*) AS n FROM rate_limits WHERE bucket LIKE 'auth%'").get()).toEqual({ n: 0 });
  });
});

describe('anonymous feed pages are shared for a few seconds (CS-14)', () => {
  it('caches GET /v1/posts for anonymous viewers only, briefly, per query', async () => {
    e = setup({ tuning: { publicFeedCacheTtlMs: 5000 } });
    const a = await e.login('alice');
    await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'first' } });
    const first = await e.req('GET', '/v1/posts?scope=global');
    expect(first.headers.get('x-cache')).toBe('miss');
    expect(first.json.items).toHaveLength(1);
    await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'second' } });
    e.clock.t += 3000;
    const cached = await e.req('GET', '/v1/posts?scope=global');
    expect(cached.headers.get('x-cache')).toBe('hit');
    expect(cached.json.items).toHaveLength(1); // stale by design, for 5 s
    // A different query is a different entry; a signed-in viewer always sees live data.
    expect((await e.req('GET', '/v1/posts?scope=global&kind=text')).headers.get('x-cache')).toBe('miss');
    const live = await e.req('GET', '/v1/posts?scope=global', { token: a.token });
    expect(live.headers.get('x-cache')).toBeNull();
    expect(live.json.items).toHaveLength(2);
    e.clock.t += 3000;
    const fresh = await e.req('GET', '/v1/posts?scope=global');
    expect(fresh.headers.get('x-cache')).toBe('miss');
    expect(fresh.json.items).toHaveLength(2);
    // A single post and its comments are not cached.
    const id = fresh.json.items[0].id;
    expect((await e.req('GET', `/v1/posts/${id}`)).headers.get('x-cache')).toBeNull();
  });

  it('is off by default in tests, 5 s in the real configuration (PUBLIC_FEED_CACHE_SECONDS)', () => {
    const base = { SESSION_SECRET: 'x'.repeat(32), PEPPER: 'y'.repeat(32) };
    expect(loadConfig(base).publicFeedCacheTtlMs).toBe(5000);
    expect(loadConfig({ ...base, PUBLIC_FEED_CACHE_SECONDS: '0' }).publicFeedCacheTtlMs).toBe(0);
    expect(loadConfig(base).anonReadLimitPerMin).toBe(600);
  });
});
