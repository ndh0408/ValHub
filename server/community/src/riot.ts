import { countryFromAlpha3 } from './geo/countries.js';

/** Result of verifying a Riot access token against /userinfo. */
export type RiotIdentity =
  | {
      ok: true;
      puuid: string;
      gameName: string;
      tagLine: string;
      /** ISO 3166-1 alpha-2 (upper case) mapped from Riot's alpha-3 `country`; null when missing/unknown. */
      country?: string | null;
    }
  | { ok: false };

/** Injectable so tests can stub Riot. Throws only on network failure. */
export type RiotUserinfoFn = (accessToken: string) => Promise<RiotIdentity>;

const USERINFO_URL = 'https://auth.riotgames.com/userinfo';

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

/** Real implementation. The token is only placed in the Authorization header; never logged. */
export const fetchRiotUserinfo: RiotUserinfoFn = async (accessToken) => {
  const res = await fetch(USERINFO_URL, {
    method: 'GET',
    headers: { Authorization: `Bearer ${accessToken}`, Accept: 'application/json' },
    signal: AbortSignal.timeout(10_000),
  });
  const text = await res.text().catch(() => '');
  if (res.status !== 200) return { ok: false };
  return parseUserinfo(text);
};
