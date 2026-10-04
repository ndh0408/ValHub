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
  operation: 'version' | 'entitlements' | 'inventory' | 'network';
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

export type RiotGameHeadersFn = () => Promise<Record<string, string> | null>;
/** Same version source, validation and six-hour refresh policy as the app.
 * Public metadata only; no Riot credential ever goes to the content host. */
export function createRiotGameHeaders(fetchFn: typeof fetch = fetch, now: () => number = Date.now): RiotGameHeadersFn {
  let cached: Record<string, string> | null = null;
  let expires = 0;
  let retryAt = 0;
  let pending: Promise<Record<string, string> | null> | null = null;
  const load = async () => {
    try {
      const response = await fetchFn('https://valorant-api.com/v1/version', {
        redirect: 'manual', signal: AbortSignal.timeout(10_000), headers: {Accept: 'application/json'},
      });
      const json = await readJson(response, 65536);
      const data = json?.data;
      if (!data || typeof data !== 'object' || Array.isArray(data)) return null;
      const {riotClientVersion: version, riotClientBuild: build} = data as Record<string, unknown>;
      if (typeof version !== 'string' || !/^release-\d{1,3}\.\d{1,3}-shipping-\d{1,4}-\d{4,9}$/.test(version) ||
          typeof build !== 'string' || !/^\d{1,4}(\.\d{1,6}){2,5}$/.test(build)) return null;
      cached = {
        'X-Riot-ClientVersion': version,
        'X-Riot-ClientPlatform': Buffer.from(JSON.stringify({platformType:'PC', platformOS:'Windows',
          platformOSVersion:'10.0.19042.1.256.64bit', platformChipset:'Unknown'})).toString('base64'),
        'User-Agent': `RiotClient/${build} rso-auth (Windows;10;;Professional, x64)`,
      };
      expires = now() + 6 * 60 * 60 * 1000;
      return cached;
    } catch { return null; }
    finally { retryAt = now() + 2000; }
  };
  return () => {
    if (cached && now() < expires) return Promise.resolve({...cached});
    if (pending) return pending.then(value => value ? {...value} : null);
    if (now() < retryAt) return Promise.resolve(null);
    pending = load().finally(() => { pending = null; });
    return pending.then(value => value ? {...value} : null);
  };
}

/** Inventory is read only while saving a rating/review. Nothing is persisted or
 * cached as an ownership assertion; an outage can never authorize a review. */
export function createRiotOwnership(fetchFn: typeof fetch = fetch, diagnostic?: (event: OwnershipDiagnostic) => void,
  gameHeaders: RiotGameHeadersFn = createRiotGameHeaders(fetchFn)): RiotOwnershipFn {
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
      const clientHeaders = await gameHeaders();
      if (!clientHeaders) { report({operation: 'version'}); return 'unavailable'; }
      const inventory = await fetchFn(`https://pd.${shard}.a.pvp.net/store/v1/entitlements/${encodeURIComponent(request.puuid)}/${SKIN_LEVEL}`, {
        method: 'GET', redirect: 'manual', signal,
        headers: { ...clientHeaders, Authorization: `Bearer ${request.accessToken}`, 'X-Riot-Entitlements-JWT': token, Accept: 'application/json' },
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
