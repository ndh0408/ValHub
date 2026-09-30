import { afterEach, describe, expect, it } from 'vitest';
import { loadConfig } from '../src/config.js';
import { sessionKid, signSession, verifySession } from '../src/crypto.js';
import { runCli } from '../src/cli.js';
import { SECRET, setup, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

const OTHER_SECRET = 'another-session-secret-0123456789abcdef-xyz';
const THIRD_SECRET = 'third-session-secret-0123456789abcdef-abcdef';

const claimsOf = (token: string) => JSON.parse(Buffer.from(token.split('.')[1]!, 'base64url').toString('utf8'));
const headerOf = (token: string) => JSON.parse(Buffer.from(token.split('.')[0]!, 'base64url').toString('utf8'));

describe('logout and epoch revocation (CS-04)', () => {
  it('POST /v1/auth/logout ends every session of the account, on every device', async () => {
    e = setup();
    const first = await e.login('alice');
    e.clock.t += 1000;
    const second = await e.login('alice'); // a second device
    const bob = await e.login('bob');
    expect(claimsOf(first.token).ep).toBe(0);

    expect((await e.req('GET', '/v1/me', { token: first.token })).status).toBe(200);
    const out = await e.req('POST', '/v1/auth/logout', { token: first.token });
    expect(out.status).toBe(204);
    expect(out.headers.get('cache-control')).toBe('no-store');

    for (const t of [first.token, second.token]) {
      const res = await e.req('GET', '/v1/me', { token: t });
      expect(res.status).toBe(401);
      expect(res.json.error.code).toBe('unauthorized');
    }
    expect((await e.req('GET', '/v1/me', { token: bob.token })).status).toBe(200);

    // Signing in again gives a token of the new epoch.
    const again = await e.login('alice');
    expect(claimsOf(again.token).ep).toBe(1);
    expect((await e.req('GET', '/v1/me', { token: again.token })).status).toBe(200);
    // Logging out needs a session.
    expect((await e.req('POST', '/v1/auth/logout')).status).toBe(401);
    expect((await e.req('POST', '/v1/auth/logout', { token: first.token })).status).toBe(401);
  });

  it('a token from before the account was erased does not come back when the same Riot account signs in again', async () => {
    e = setup();
    const old = await e.login('alice');
    expect((await e.req('DELETE', '/v1/me', { token: old.token })).status).toBe(204);
    expect((await e.req('GET', '/v1/me', { token: old.token })).status).toBe(401);
    e.clock.t += 5000; // the re-sign-in happens later
    const fresh = await e.login('alice');
    expect(fresh.user.id).toBe(old.user.id);
    expect((await e.req('GET', '/v1/me', { token: fresh.token })).status).toBe(200);
    const revived = await e.req('GET', '/v1/me', { token: old.token });
    expect(revived.status).toBe(401);
    expect((await e.req('POST', '/v1/posts', { token: old.token, body: { kind: 'text', body: 'ghost' } })).status).toBe(401);
  });

  it('a token minted in the very second the row was created is valid', async () => {
    e = setup();
    const a = await e.login('alice'); // created_at and iat come from the same clock reading
    expect((await e.req('GET', '/v1/me', { token: a.token })).status).toBe(200);
  });

  it('tokens issued before epochs existed (no ep claim, header without kid) keep working until the epoch moves', async () => {
    e = setup();
    const a = await e.login('alice');
    const legacyHeader = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
    const { ep: _ep, ...claims } = claimsOf(a.token);
    const payload = Buffer.from(JSON.stringify(claims)).toString('base64url');
    const { createHmac } = await import('node:crypto');
    const sig = createHmac('sha256', SECRET).update(`${legacyHeader}.${payload}`).digest('base64url');
    const legacy = `${legacyHeader}.${payload}.${sig}`;
    expect((await e.req('GET', '/v1/me', { token: legacy })).status).toBe(200);
    await e.req('POST', '/v1/auth/logout', { token: a.token });
    expect((await e.req('GET', '/v1/me', { token: legacy })).status).toBe(401);
  });

  it('a ban bumps the epoch through the CLI', async () => {
    e = setup();
    const a = await e.login('alice');
    const out: string[] = [];
    await runCli(['ban', '--id', a.user.id, '--yes'], { ...e.mediaDeps(), out: (l) => out.push(l), err: (l) => out.push(l) });
    expect((e.db.prepare('SELECT session_epoch AS n FROM users WHERE id = ?').get(a.user.id) as any).n).toBe(1);
  });
});

describe('two-secret rotation (CS-04)', () => {
  it('signs with the current secret, names it in the kid header and verifies with either secret', () => {
    const claims = { sub: 'a'.repeat(32), name: 'x', tag: 'y', iat: 1000, exp: 5_000_000_000, ep: 3 };
    const token = signSession(SECRET, claims);
    expect(headerOf(token)).toEqual({ alg: 'HS256', typ: 'JWT', kid: sessionKid(SECRET) });
    expect(sessionKid(SECRET)).toMatch(/^[0-9a-f]{8}$/);
    expect(sessionKid(SECRET)).not.toBe(sessionKid(OTHER_SECRET));
    expect(verifySession(SECRET, token, 2_000_000)).toMatchObject({ sub: claims.sub, ep: 3 });
    expect(verifySession([OTHER_SECRET, SECRET], token, 2_000_000)).toMatchObject({ sub: claims.sub });
    expect(verifySession([SECRET, OTHER_SECRET], token, 2_000_000)).toMatchObject({ sub: claims.sub });
    expect(verifySession(OTHER_SECRET, token, 2_000_000)).toBeNull();
    expect(verifySession([OTHER_SECRET, THIRD_SECRET], token, 2_000_000)).toBeNull();
    expect(verifySession([], token, 2_000_000)).toBeNull();
  });

  it('a token whose kid names no configured secret is refused even if the signature were valid for another', () => {
    const token = signSession(SECRET, { sub: 'a'.repeat(32), name: '', tag: '', iat: 1, exp: 5_000_000_000 });
    // Re-label the header with another secret's key id: the signature no longer matches.
    const parts = token.split('.');
    const forged = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT', kid: sessionKid(OTHER_SECRET) })).toString('base64url');
    expect(verifySession([SECRET, OTHER_SECRET], `${forged}.${parts[1]}.${parts[2]}`, 2_000_000)).toBeNull();
  });

  it('SESSION_SECRET_PREV: tokens of the old secret still work, new ones are signed with the new secret', async () => {
    // The server used to sign with OTHER_SECRET; the operator rotated to SECRET and kept OTHER_SECRET as the previous one.
    e = setup({ config: { sessionSecretPrev: OTHER_SECRET } });
    const fresh = await e.login('alice');
    expect(headerOf(fresh.token).kid).toBe(sessionKid(SECRET));
    const old = signSession(OTHER_SECRET, { sub: fresh.user.id, name: 'x', tag: 'y', iat: Math.floor(e.clock.t / 1000), exp: Math.floor(e.clock.t / 1000) + 3600 });
    expect((await e.req('GET', '/v1/me', { token: old })).status).toBe(200);
    const stranger = signSession(THIRD_SECRET, { sub: fresh.user.id, name: 'x', tag: 'y', iat: Math.floor(e.clock.t / 1000), exp: Math.floor(e.clock.t / 1000) + 3600 });
    expect((await e.req('GET', '/v1/me', { token: stranger })).status).toBe(401);
  });

  it('without a previous secret the old secret is rejected (rotation finished)', async () => {
    e = setup();
    const a = await e.login('alice');
    const old = signSession(OTHER_SECRET, { sub: a.user.id, name: 'x', tag: 'y', iat: Math.floor(e.clock.t / 1000), exp: Math.floor(e.clock.t / 1000) + 3600 });
    expect((await e.req('GET', '/v1/me', { token: old })).status).toBe(401);
  });

  it('config: SESSION_SECRET_PREV is optional, must be long enough and different', () => {
    const base = { SESSION_SECRET: SECRET, PEPPER: 'p'.repeat(40) };
    expect(loadConfig(base).sessionSecretPrev).toBe('');
    expect(loadConfig({ ...base, SESSION_SECRET_PREV: OTHER_SECRET }).sessionSecretPrev).toBe(OTHER_SECRET);
    expect(() => loadConfig({ ...base, SESSION_SECRET_PREV: 'short' })).toThrow(/SESSION_SECRET_PREV/);
    expect(() => loadConfig({ ...base, SESSION_SECRET_PREV: SECRET })).toThrow(/must differ/);
  });
});

describe('consent record (CS-34)', () => {
  const login = (body: Record<string, unknown>) =>
    e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap', ...body } });
  const row = () => e.db.prepare('SELECT consent_version AS v, consent_at AS at FROM users').get() as { v: string | null; at: number | null };

  it('stores the accepted policy version and the time it was first seen; the same version keeps the time', async () => {
    e = setup();
    expect((await login({})).status).toBe(200);
    expect(row()).toEqual({ v: null, at: null }); // optional: clients before this change send nothing
    const t1 = e.clock.t;
    expect((await login({ consentVersion: '2026-09' })).status).toBe(200);
    expect(row()).toEqual({ v: '2026-09', at: t1 });
    e.clock.t += 60_000;
    expect((await login({ consentVersion: '2026-09' })).status).toBe(200);
    expect(row()).toEqual({ v: '2026-09', at: t1 });
    e.clock.t += 60_000;
    expect((await login({})).status).toBe(200); // absent: kept
    expect(row()).toEqual({ v: '2026-09', at: t1 });
    expect((await login({ consentVersion: '2027-01' })).status).toBe(200);
    expect(row()).toEqual({ v: '2027-01', at: e.clock.t });
  });

  it('validates the version and exports it; erasing the account removes it', async () => {
    e = setup();
    for (const bad of ['', 'has space', 'x'.repeat(33), 5, 'é', null]) {
      const res = await login({ consentVersion: bad });
      expect(res.status, JSON.stringify(bad)).toBe(400);
    }
    const ok = await login({ consentVersion: 'v1.2_a-b' });
    expect(ok.status).toBe(200);
    const exp = await e.req('GET', '/v1/me/export', { token: ok.json.token });
    expect(exp.json.profile.consent).toEqual({ version: 'v1.2_a-b', at: new Date(e.clock.t).toISOString() });
    await e.req('DELETE', '/v1/me', { token: ok.json.token });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM users').get()).toEqual({ n: 0 });
  });
});
