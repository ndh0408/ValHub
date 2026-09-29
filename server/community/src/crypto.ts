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
}

export const SESSION_TTL_SECONDS = 30 * 24 * 60 * 60;

const HEADER = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');

function sign(secret: string, data: string): Buffer {
  return createHmac('sha256', secret).update(data).digest();
}

export function signSession(secret: string, claims: SessionClaims): string {
  const payload = Buffer.from(JSON.stringify(claims)).toString('base64url');
  const data = `${HEADER}.${payload}`;
  return `${data}.${sign(secret, data).toString('base64url')}`;
}

/** Returns the claims if the token is a valid, unexpired HS256 session; otherwise null. */
export function verifySession(secret: string, token: string, nowMs: number): SessionClaims | null {
  if (token.length > 4096) return null;
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
    const expected = sign(secret, `${h}.${p}`);
    const given = Buffer.from(s, 'base64url');
    if (given.length !== expected.length || !timingSafeEqual(given, expected)) return null;
    const claims: unknown = JSON.parse(Buffer.from(p, 'base64url').toString('utf8'));
    if (typeof claims !== 'object' || claims === null) return null;
    const c = claims as Record<string, unknown>;
    if (typeof c.sub !== 'string' || !/^[0-9a-f]{32}$/.test(c.sub)) return null;
    if (typeof c.exp !== 'number' || typeof c.iat !== 'number') return null;
    if (c.exp * 1000 <= nowMs) return null;
    return {
      sub: c.sub,
      name: typeof c.name === 'string' ? c.name : '',
      tag: typeof c.tag === 'string' ? c.tag : '',
      iat: c.iat,
      exp: c.exp,
    };
  } catch {
    return null;
  }
}
