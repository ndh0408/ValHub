import type { UserRow } from '../db/repo.js';
import { invalid } from '../errors.js';
import { parseRegion } from '../validate.js';
import { normalizeAlpha2 } from './countries.js';

export const SCOPES = ['country', 'region', 'global'] as const;
export type ScopeName = (typeof SCOPES)[number];

/** A resolved geographic scope (what a query actually filters on). */
export type GeoScope =
  | { scope: 'global' }
  | { scope: 'country'; country: string }
  | { scope: 'region'; region: string };

export const GLOBAL: GeoScope = { scope: 'global' };

export function parseCountryParam(v: string): string {
  const c = normalizeAlpha2(v);
  if (!c) throw invalid('country phải là mã quốc gia ISO 3166-1 alpha-2 (ví dụ VN).');
  return c;
}

/**
 * Resolves `?scope=&country=&region=` for a viewer.
 *
 * - Explicit `scope` wins; without it, a `country` param implies `country`, a `region` param
 *   implies `region`, otherwise the endpoint default applies.
 * - `country` scope uses the `country` param or the viewer's country; when neither exists it
 *   falls back to `region` scope, which uses the `region` param or the viewer's region; when
 *   that is unknown too (unauthenticated) it falls back to `global`.
 * - Geo params that do not belong to the resolved scope are ignored.
 */
export function resolveScope(
  q: Record<string, string | undefined>,
  viewer: Pick<UserRow, 'country' | 'region'> | null,
  defaultScope: ScopeName,
): GeoScope {
  const country = q.country ? parseCountryParam(q.country) : undefined;
  const region = q.region ? parseRegion(q.region) : undefined;
  let scope: ScopeName;
  if (q.scope) {
    if (!(SCOPES as readonly string[]).includes(q.scope)) {
      throw invalid(`scope phải là một trong: ${SCOPES.join(', ')}.`);
    }
    scope = q.scope as ScopeName;
  } else {
    scope = country ? 'country' : region ? 'region' : defaultScope;
  }
  if (scope === 'country') {
    const c = country ?? viewer?.country ?? null;
    if (c) return { scope: 'country', country: c };
    scope = 'region';
  }
  if (scope === 'region') {
    const r = region ?? viewer?.region ?? null;
    if (r) return { scope: 'region', region: r };
  }
  return GLOBAL;
}

/** Echoed in responses so clients can show which scope was applied after fallbacks. */
export function appliedScope(geo: GeoScope) {
  return {
    scope: geo.scope,
    country: geo.scope === 'country' ? geo.country : null,
    region: geo.scope === 'region' ? geo.region : null,
  };
}

/** SQL condition for a scope on a table alias with `country` / `region` columns ('' for global). */
export function geoCondition(alias: string, geo: GeoScope | undefined, params: Record<string, unknown>): string {
  if (!geo || geo.scope === 'global') return '';
  if (geo.scope === 'country') {
    params.geoCountry = geo.country;
    return `${alias}.country = @geoCountry`;
  }
  params.geoRegion = geo.region;
  return `${alias}.region = @geoRegion`;
}
