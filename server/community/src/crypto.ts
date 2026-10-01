import { createHash, createHmac, randomBytes, timingSafeEqual } from 'node:crypto';

/** User id: hex(sha256(PEPPER + puuid)) truncated to 32 chars. The PUUID is never stored. */
export function hashUserId(pepper: string, puuid: string): string {
  return createHash('sha256').update(pepper + puuid).digest('hex').slice(0, 32);
}

/** Hashed IP bucket id for IP-based rate limits (raw IPs are never stored). */
export function hashIp(pepper: string, ip: string): string {
  return createHash('sha256').update(`ip:${pepper}:${ip}`).digest('hex').slice(0, 24);
}

export function randomHex(bytes: number): string {
  return randomBytes(bytes).toString('hex');
}

export interface SessionClaims {
  sub: string;
  name: string;
  tag: string;
  iat: number;
  exp: number;
  /** Session epoch of the account when the token was issued (absent on tokens from before revocation existed = 0). */
  ep?: number;
}

export const SESSION_TTL_SECONDS = 30 * 24 * 60 * 60;

/**
 * Key id of a signing secret (`kid` header): the first 8 hex characters of a one-way hash, so a token names the
 * secret that signed it without revealing it. Lets two secrets be valid at once while one is being rotated out.
 */
export function sessionKid(secret: string): string {
  return createHash('sha256').update(`kid:${secret}`).digest('hex').slice(0, 8);
}

function sign(secret: string, data: string): Buffer {
  return createHmac('sha256', secret).update(data).digest();
}

export function signSession(secret: string, claims: SessionClaims): string {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT', kid: sessionKid(secret) })).toString('base64url');
  const payload = Buffer.from(JSON.stringify(claims)).toString('base64url');
  const data = `${header}.${payload}`;
  return `${data}.${sign(secret, data).toString('base64url')}`;
}

/**
 * Returns the claims if the token is a valid, unexpired HS256 session signed by one of `secrets` (the current
 * secret first, then the one being rotated out); otherwise null. A token with a `kid` is checked against the
 * secret that key id names; a token without one (issued before rotation existed) against every secret.
 */
export function verifySession(secrets: string | readonly string[], token: string, nowMs: number): SessionClaims | null {
  if (token.length > 4096) return null;
  const list = (typeof secrets === 'string' ? [secrets] : secrets).filter((s) => s !== '');
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [h, p, s] = parts as [string, string, string];
  try {
    const header: unknown = JSON.parse(Buffer.from(h, 'base64url').toString('utf8'));
    if (
      typeof header !== 'object' ||
      header === null ||
      (header as Record<string, unknown>).alg !== 'HS256'
    ) {
      return null;
    }
    const kid = (header as Record<string, unknown>).kid;
    const candidates = typeof kid === 'string' ? list.filter((secret) => sessionKid(secret) === kid) : list;
    const given = Buffer.from(s, 'base64url');
    const valid = candidates.some((secret) => {
      const expected = sign(secret, `${h}.${p}`);
      return given.length === expected.length && timingSafeEqual(given, expected);
    });
    if (!valid) return null;
    const claims: unknown = JSON.parse(Buffer.from(p, 'base64url').toString('utf8'));
    if (typeof claims !== 'object' || claims === null) return null;
    const c = claims as Record<string, unknown>;
    if (typeof c.sub !== 'string' || !/^[0-9a-f]{32}$/.test(c.sub)) return null;
    if (typeof c.exp !== 'number' || typeof c.iat !== 'number' || !Number.isSafeInteger(c.exp) || !Number.isSafeInteger(c.iat) || c.iat * 1000 > nowMs || c.exp <= c.iat) return null;
    if (c.ep !== undefined && (typeof c.ep !== 'number' || !Number.isSafeInteger(c.ep) || c.ep < 0)) return null;
    if (c.exp * 1000 <= nowMs) return null;
    return {
      sub: c.sub,
      name: typeof c.name === 'string' ? c.name : '',
      tag: typeof c.tag === 'string' ? c.tag : '',
      iat: c.iat,
      exp: c.exp,
      ep: typeof c.ep === 'number' && Number.isInteger(c.ep) && c.ep >= 0 ? c.ep : 0,
    };
  } catch {
    return null;
  }
}
