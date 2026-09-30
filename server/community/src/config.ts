import path from 'node:path';

export interface Config {
  port: number;
  dataDir: string;
  sessionSecret: string;
  /**
   * The previous session secret during a rotation: tokens signed with it are still accepted (never used to sign),
   * so nobody is logged out. Empty when no rotation is in progress.
   */
  sessionSecretPrev: string;
  pepper: string;
  /** e.g. https://community.example.com — no trailing slash. Empty → derive from request. */
  publicBaseUrl: string;
  /**
   * Believe `CF-Connecting-IP` (the client address Cloudflare adds) and `X-Forwarded-Proto/Host`. Default false: a
   * server reachable without Cloudflare would let clients choose their own rate-limit identity. docker-compose.yml
   * sets it to true for the Cloudflare Tunnel deployment. Even then the header is only believed when the TCP peer is
   * a loopback / private address (the tunnel), see ip.ts.
   */
  trustProxy: boolean;
  /** Per-user image storage quota (bytes). */
  mediaUserQuotaBytes: number;
  /** Total image storage cap (bytes); uploads are refused beyond it. */
  mediaMaxTotalBytes: number;
  /** Unauthenticated public reads allowed per client IP per minute (media files: anonMediaLimitPerMin). */
  anonReadLimitPerMin: number;
  anonMediaLimitPerMin: number;
  /** How long anonymous aggregate responses (skin top / votes / summary / reviews, communities) are cached; 0 = off. */
  publicCacheTtlMs: number;
  /** How long an anonymous feed page (GET /v1/posts) is cached, shared by every anonymous viewer; 0 = off. */
  publicFeedCacheTtlMs: number;
  /**
   * How long Cloudflare's edge may keep a media 200 (Cloudflare-CDN-Cache-Control). Devices always get the
   * 1-year immutable Cache-Control. 0 (default) = no-store at the edge, so deleted / quarantined images stop
   * being served at once; a small value (<= 60) trades a short deletion lag for fewer origin reads.
   */
  mediaEdgeCacheSeconds: number;
  /** Requests per signed-in user per minute, any method and route (a coarse valve above the per-action limits). */
  userRequestLimitPerMin: number;
  /** Event-loop lag (ms) above which requests are answered 503 + Retry-After (load shedding); 0 = off. */
  loadShedLagMs: number;
}

const MIN_SECRET_LENGTH = 32;

/** Reads config from the environment; throws (fail fast) on missing / weak secrets. */
export function loadConfig(env: NodeJS.ProcessEnv): Config {
  const problems: string[] = [];
  const secret = (name: string): string => {
    const v = env[name] ?? '';
    if (v.length < MIN_SECRET_LENGTH) {
      problems.push(`${name} must be set and at least ${MIN_SECRET_LENGTH} characters long`);
    }
    return v;
  };
  const sessionSecret = secret('SESSION_SECRET');
  const pepper = secret('PEPPER');
  const sessionSecretPrev = (env.SESSION_SECRET_PREV ?? '').trim();
  if (sessionSecretPrev !== '') {
    if (sessionSecretPrev.length < MIN_SECRET_LENGTH) {
      problems.push(`SESSION_SECRET_PREV must be empty or at least ${MIN_SECRET_LENGTH} characters long`);
    } else if (sessionSecretPrev === sessionSecret) {
      problems.push('SESSION_SECRET_PREV must differ from SESSION_SECRET (remove it when the rotation is over)');
    }
  }

  const portRaw = env.PORT ?? '8080';
  const port = Number(portRaw);
  if (!Number.isInteger(port) || port < 1 || port > 65535) problems.push(`PORT is invalid: ${portRaw}`);

  let publicBaseUrl = (env.PUBLIC_BASE_URL ?? '').trim().replace(/\/+$/, '');
  if (publicBaseUrl !== '') {
    try {
      const u = new URL(publicBaseUrl);
      if (u.protocol !== 'https:' && u.protocol !== 'http:') throw new Error('protocol');
      publicBaseUrl = u.origin + u.pathname.replace(/\/+$/, '');
    } catch {
      problems.push('PUBLIC_BASE_URL must be an absolute http(s) URL');
    }
  }

  const num = (name: string, def: number, min: number, max: number): number => {
    const raw = env[name];
    if (raw === undefined || raw.trim() === '') return def;
    const n = Number(raw);
    if (!Number.isFinite(n) || n < min || n > max) {
      problems.push(`${name} must be a number between ${min} and ${max}`);
      return def;
    }
    return n;
  };
  const mediaUserQuotaMb = num('MEDIA_USER_QUOTA_MB', 50, 1, 10_000);
  const mediaMaxTotalMb = num('MEDIA_MAX_TOTAL_MB', 2048, 1, 10_000_000);
  const anonReadLimitPerMin = num('ANON_READ_LIMIT_PER_MIN', 600, 1, 100_000);
  const anonMediaLimitPerMin = num('ANON_MEDIA_LIMIT_PER_MIN', 1500, 1, 1_000_000);
  const cacheSeconds = num('PUBLIC_CACHE_TTL_SECONDS', 45, 0, 3600);
  const feedCacheSeconds = num('PUBLIC_FEED_CACHE_SECONDS', 5, 0, 300);
  const mediaEdgeCacheSeconds = num('MEDIA_EDGE_CACHE_SECONDS', 0, 0, 3600);
  const userRequestLimitPerMin = num('USER_REQUEST_LIMIT_PER_MIN', 240, 10, 1_000_000);
  const loadShedLagMs = num('LOAD_SHED_LAG_MS', 250, 0, 60_000);

  if (problems.length > 0) throw new Error(`Invalid configuration:\n- ${problems.join('\n- ')}`);

  return {
    port,
    dataDir: path.resolve(env.DATA_DIR || '/data'),
    sessionSecret,
    sessionSecretPrev,
    pepper,
    publicBaseUrl,
    trustProxy: (env.TRUST_PROXY ?? 'false').trim().toLowerCase() === 'true',
    mediaUserQuotaBytes: Math.round(mediaUserQuotaMb * 1024 * 1024),
    mediaMaxTotalBytes: Math.round(mediaMaxTotalMb * 1024 * 1024),
    anonReadLimitPerMin: Math.round(anonReadLimitPerMin),
    anonMediaLimitPerMin: Math.round(anonMediaLimitPerMin),
    publicCacheTtlMs: Math.round(cacheSeconds * 1000),
    publicFeedCacheTtlMs: Math.round(feedCacheSeconds * 1000),
    mediaEdgeCacheSeconds: Math.round(mediaEdgeCacheSeconds),
    userRequestLimitPerMin: Math.round(userRequestLimitPerMin),
    loadShedLagMs: Math.round(loadShedLagMs),
  };
}
