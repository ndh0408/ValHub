import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import { ApiError } from '../errors.js';

/** Public reads that work without a session. */
const PUBLIC_READS = [/^\/v1\/posts(\/|$)/, /^\/v1\/skins\//, /^\/v1\/communities$/];

/** Anonymous aggregate queries worth caching for everyone (identical for every anonymous viewer). */
const CACHEABLE = [
  /^\/v1\/skins\/top$/,
  /^\/v1\/skins\/votes$/,
  /^\/v1\/skins\/[0-9a-f-]{36}\/(summary|reviews)$/i,
  /^\/v1\/communities$/,
];

/**
 * Abuse resistance for requests WITHOUT a session (`Authorization` header): a per-client-IP limit
 * (hashed IP, in memory) and a short TTL cache for aggregate queries, so scraping or a hot leaderboard
 * cannot hammer SQLite. Signed-in requests are limited per user elsewhere and never cached.
 */
export function registerPublicGuard(app: Hono, x: Ctx): void {
  app.use('/v1/*', async (c, next) => {
    if (c.req.method !== 'GET' && c.req.method !== 'HEAD') return next();
    if (c.req.header('authorization')) return next();
    const path = c.req.path;
    const isMedia = path.startsWith('/v1/media/');
    if (!isMedia && !PUBLIC_READS.some((re) => re.test(path))) return next();

    const ttl = x.tuning.publicCacheTtlMs;
    const cacheable = ttl > 0 && CACHEABLE.some((re) => re.test(path));
    let key = '';
    if (cacheable) {
      const params = [...new URL(c.req.url).searchParams.entries()].sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
      key = `${path}?${new URLSearchParams(params).toString()}`;
      // A cache hit costs nothing (no database work), so it is not counted against the limit: many users
      // can share one IP (carrier-grade NAT) and read the same leaderboard.
      const hit = x.publicCache.get(key, x.now());
      if (hit) return c.body(hit.body, 200, { 'content-type': hit.type, 'x-cache': 'hit' });
    }

    const ip = x.clientIpHash(c);
    if (ip) {
      const limit = isMedia ? x.tuning.anonMediaLimitPerMin : x.tuning.anonReadLimitPerMin;
      const r = x.anonLimiter.hit(`${isMedia ? 'media' : 'read'}:${ip}`, limit, 60_000, x.now());
      if (!r.ok) {
        throw new ApiError('rate_limited', 'Bạn thao tác quá nhanh, vui lòng thử lại sau.', r.retryAfterSeconds);
      }
    }

    if (cacheable) {
      c.header('x-cache', 'miss');
      await next();
      if (c.res.status === 200) {
        const body = await c.res.clone().text();
        x.publicCache.set(
          key,
          { body, type: c.res.headers.get('content-type') ?? 'application/json; charset=utf-8' },
          ttl,
          x.now(),
        );
      }
      return;
    }
    return next();
  });
}
