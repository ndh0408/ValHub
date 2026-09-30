import path from 'node:path';

export interface Config {
  port: number;
  dataDir: string;
  sessionSecret: string;
  pepper: string;
  /** e.g. https://community.example.com — no trailing slash. Empty → derive from request. */
  publicBaseUrl: string;
  /** Trust CF-Connecting-IP / X-Forwarded-* (true behind the Cloudflare Tunnel). */
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
  const anonReadLimitPerMin = num('ANON_READ_LIMIT_PER_MIN', 120, 1, 100_000);
  const anonMediaLimitPerMin = num('ANON_MEDIA_LIMIT_PER_MIN', 1500, 1, 1_000_000);
  const cacheSeconds = num('PUBLIC_CACHE_TTL_SECONDS', 45, 0, 3600);

  if (problems.length > 0) throw new Error(`Invalid configuration:\n- ${problems.join('\n- ')}`);

  return {
    port,
    dataDir: path.resolve(env.DATA_DIR || '/data'),
    sessionSecret,
    pepper,
    publicBaseUrl,
    trustProxy: (env.TRUST_PROXY ?? 'true').toLowerCase() !== 'false',
    mediaUserQuotaBytes: Math.round(mediaUserQuotaMb * 1024 * 1024),
    mediaMaxTotalBytes: Math.round(mediaMaxTotalMb * 1024 * 1024),
    anonReadLimitPerMin: Math.round(anonReadLimitPerMin),
    anonMediaLimitPerMin: Math.round(anonMediaLimitPerMin),
    publicCacheTtlMs: Math.round(cacheSeconds * 1000),
  };
}
