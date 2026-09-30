import { countryFromAlpha3 } from './geo/countries.js';

/**
 * Result of verifying a Riot access token against /userinfo.
 * - `ok: false, reason: 'rejected'` (or no reason): Riot refused the token → 401 riot_rejected.
 * - `ok: false, reason: 'unavailable'`: Riot (or Cloudflare in front of it) could not answer:
 *   429, 5xx, timeouts, HTML error pages, unexpected bodies → 503 riot_unavailable. The token may be fine,
 *   so the client must not throw away its Riot session.
 */
export type RiotIdentity =
  | {
      ok: true;
      puuid: string;
      gameName: string;
      tagLine: string;
      /** ISO 3166-1 alpha-2 (upper case) mapped from Riot's alpha-3 `country`; null when missing/unknown. */
      country?: string | null;
    }
  | { ok: false; reason?: 'rejected' | 'unavailable'; retryAfter?: number };

/** Injectable so tests can stub Riot. May throw on network failure (treated as unavailable). */
export type RiotUserinfoFn = (accessToken: string) => Promise<RiotIdentity>;

const USERINFO_URL = 'https://auth.riotgames.com/userinfo';

type NotOk = Extract<RiotIdentity, { ok: false }>;
const UNAVAILABLE: NotOk = { ok: false, reason: 'unavailable' };
const REJECTED: NotOk = { ok: false, reason: 'rejected' };

/** Defensive parse of a /userinfo body (may be HTML from Cloudflare, or partial JSON). */
export function parseUserinfo(text: string): RiotIdentity {
  let body: unknown;
  try {
    body = JSON.parse(text);
  } catch {
    return { ok: false };
  }
  if (typeof body !== 'object' || body === null) return { ok: false };
  const b = body as Record<string, unknown>;
  const sub = typeof b.sub === 'string' ? b.sub.trim().toLowerCase() : '';
  if (sub.length === 0 || sub.length > 128) return { ok: false };
  const acct =
    typeof b.acct === 'object' && b.acct !== null ? (b.acct as Record<string, unknown>) : {};
  const gameName = typeof acct.game_name === 'string' ? acct.game_name.slice(0, 32) : '';
  const tagLine = typeof acct.tag_line === 'string' ? acct.tag_line.slice(0, 16) : '';
  return { ok: true, puuid: sub, gameName, tagLine, country: countryFromAlpha3(b.country) };
}

const looksLikeHtml = (text: string): boolean => /^\s*(<|<!doctype)/i.test(text);

/** Seconds from a Retry-After header (numeric form only), clamped to 1..300; undefined if absent. */
export function parseRetryAfterSeconds(v: string | null | undefined): number | undefined {
  if (!v) return undefined;
  const n = Number(v.trim());
  if (!Number.isFinite(n) || n <= 0) return undefined;
  return Math.min(300, Math.max(1, Math.ceil(n)));
}

/**
 * Turns Riot's answer into an identity / rejected / unavailable decision.
 * Only a real refusal of the token (401 / 403 / 400 with a non-HTML body) counts as rejected.
 */
export function classifyUserinfoResponse(
  status: number,
  text: string,
  retryAfterHeader?: string | null,
): RiotIdentity {
  const retryAfter = parseRetryAfterSeconds(retryAfterHeader);
  const unavailable: NotOk = retryAfter ? { ...UNAVAILABLE, retryAfter } : UNAVAILABLE;
  if (status === 200) {
    const r = parseUserinfo(text);
    // 200 without a usable identity (HTML page, empty / odd JSON) is not a token refusal.
    return r.ok ? r : unavailable;
  }
  if (status === 400 || status === 401 || status === 403) {
    return looksLikeHtml(text) ? unavailable : REJECTED;
  }
  return unavailable; // 429, 5xx, 408, redirects, anything else
}

/** Real implementation. The token is only placed in the Authorization header; never logged. */
export const fetchRiotUserinfo: RiotUserinfoFn = async (accessToken) => {
  let res: Response;
  try {
    res = await fetch(USERINFO_URL, {
      method: 'GET',
      headers: { Authorization: `Bearer ${accessToken}`, Accept: 'application/json' },
      signal: AbortSignal.timeout(10_000),
    });
  } catch {
    return UNAVAILABLE; // network error / timeout
  }
  const text = await res.text().catch(() => '');
  return classifyUserinfoResponse(res.status, text, res.headers.get('retry-after'));
};
