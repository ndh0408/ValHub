import type { SkinRef } from './content.js';

export type OwnershipResult = 'owned' | 'not_owned' | 'unavailable' | 'rejected';
export interface OwnershipRequest {
  accessToken: string;
  /** Derived exclusively from Riot /userinfo, never from the request body. */
  puuid: string;
  /** Region from the authenticated server account. */
  region: string;
  skinUuid: string;
  resolveSkin: (uuid: string) => SkinRef | null;
}
export type RiotOwnershipFn = (request: OwnershipRequest) => Promise<OwnershipResult>;
/** Fixed operation names/statuses only: never tokens, subjects, URLs or bodies. */
export interface OwnershipDiagnostic {
  operation: 'entitlements' | 'inventory' | 'network';
  status?: number;
}
const SKIN_LEVEL = 'e7c63390-eda7-46e0-bb7a-a6abdacd2433';
const SHARDS: Record<string, string> = { ap: 'ap', na: 'na', br: 'na', latam: 'na', eu: 'eu', kr: 'kr' };

/** Bounded JSON, fixed Riot hosts, no redirects, no request/credential logging. */
async function readJson(response: Response, maxBytes: number): Promise<Record<string, unknown> | null> {
  if (response.status !== 200 || Number(response.headers.get('content-length')) > maxBytes) {
    await response.body?.cancel(); return null;
  }
  if (!response.body) return null;
  const reader = response.body.getReader();
  const parts: Uint8Array[] = []; let total = 0;
  for (;;) {
    const {done, value} = await reader.read();
    if (done) break;
    total += value.length;
    if (total > maxBytes) { await reader.cancel(); return null; }
    parts.push(value);
  }
  try {
    const json: unknown = JSON.parse(Buffer.concat(parts).toString('utf8'));
    return json !== null && typeof json === 'object' && !Array.isArray(json) ? json as Record<string, unknown> : null;
  } catch { return null; }
}

/** Inventory is read only while saving a rating/review. Nothing is persisted or
 * cached as an ownership assertion; an outage can never authorize a review. */
export function createRiotOwnership(fetchFn: typeof fetch = fetch, diagnostic?: (event: OwnershipDiagnostic) => void): RiotOwnershipFn {
  let active = 0;
  const report = (event: OwnershipDiagnostic) => {
    // Observability must never change authorization or turn an outage into a grant.
    try { diagnostic?.(event); } catch { /* a broken log sink cannot authorize */ }
  };
  return async (request) => {
    const shard = Object.hasOwn(SHARDS, request.region) ? SHARDS[request.region] : undefined;
    if (!shard || active >= 20) return 'unavailable';
    // Catalog aliases are required: entitlement ItemID is a level, not a base skin.
    if (!request.resolveSkin(request.skinUuid)) return 'unavailable';
    active++;
    try {
      const signal = AbortSignal.timeout(15_000);
      const entitlement = await fetchFn('https://entitlements.auth.riotgames.com/api/token/v1', {
        method: 'POST', redirect: 'manual', signal,
        headers: {Authorization: `Bearer ${request.accessToken}`, 'Content-Type': 'application/json'}, body: '{}',
      });
      report({operation: 'entitlements', status: entitlement.status});
      if (entitlement.status === 401) { await entitlement.body?.cancel(); return 'rejected'; }
      const auth = await readJson(entitlement, 65536);
      const token = auth?.entitlements_token;
      if (typeof token !== 'string' || token.length === 0 || token.length > 16384) return 'unavailable';
      const inventory = await fetchFn(`https://pd.${shard}.a.pvp.net/store/v1/entitlements/${encodeURIComponent(request.puuid)}/${SKIN_LEVEL}`, {
        method: 'GET', redirect: 'manual', signal,
        headers: { Authorization: `Bearer ${request.accessToken}`, 'X-Riot-Entitlements-JWT': token, Accept: 'application/json' },
      });
      report({operation: 'inventory', status: inventory.status});
      if (inventory.status === 401) { await inventory.body?.cancel(); return 'rejected'; }
      const data = await readJson(inventory, 2 * 1024 * 1024);
      if (!data || !Array.isArray(data.Entitlements) ||
          (data.Subject !== undefined && (typeof data.Subject !== 'string' || data.Subject.toLowerCase() !== request.puuid)) ||
          (data.ItemTypeID !== undefined && data.ItemTypeID !== SKIN_LEVEL)) return 'unavailable';
      for (const value of data.Entitlements) {
        if (!value || typeof value !== 'object' || Array.isArray(value)) return 'unavailable';
        const row = value as Record<string, unknown>;
        if (typeof row.ItemID !== 'string' || (row.TypeID !== undefined && row.TypeID !== SKIN_LEVEL)) return 'unavailable';
        if (request.resolveSkin(row.ItemID.toLowerCase())?.skinUuid === request.skinUuid) return 'owned';
      }
      return 'not_owned';
    } catch { report({operation: 'network'}); return 'unavailable'; }
    finally { active--; }
  };
}

export const fetchRiotOwnership = createRiotOwnership();
