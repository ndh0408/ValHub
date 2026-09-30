/** Small in-memory TTL cache (insertion-ordered eviction once `max` entries are reached). */
export class TtlCache<V> {
  private readonly map = new Map<string, { value: V; expires: number }>();

  constructor(private readonly max = 500) {}

  get(key: string, now: number): V | undefined {
    const e = this.map.get(key);
    if (!e) return undefined;
    if (e.expires <= now) {
      this.map.delete(key);
      return undefined;
    }
    return e.value;
  }

  set(key: string, value: V, ttlMs: number, now: number): void {
    if (this.map.size >= this.max && !this.map.has(key)) {
      const oldest = this.map.keys().next().value;
      if (oldest !== undefined) this.map.delete(oldest);
    }
    this.map.set(key, { value, expires: now + ttlMs });
  }

  prune(now: number): void {
    for (const [k, e] of this.map) if (e.expires <= now) this.map.delete(k);
  }

  get size(): number {
    return this.map.size;
  }
}

/**
 * In-memory fixed-window counter per key (unauthenticated reads, the per-user request bucket, sign-in attempts per
 * IP: no database write per request). The map is capped (`maxEntries`, least recently used dropped first), so a
 * flood of distinct keys (an IPv6 range, random ids) cannot grow it without bound between prunes.
 */
export class FixedWindowLimiter {
  private readonly windows = new Map<string, { start: number; count: number }>();

  constructor(private readonly maxEntries = 100_000) {}

  /** Registers a hit; `retryAfterSeconds` is set once the limit is exceeded. */
  hit(key: string, limit: number, windowMs: number, now: number): { ok: boolean; retryAfterSeconds: number } {
    const start = Math.floor(now / windowMs) * windowMs;
    let w = this.windows.get(key);
    if (w) {
      // Refresh recency (Map keeps insertion order: the first key is the least recently used).
      this.windows.delete(key);
    } else if (this.windows.size >= this.maxEntries) {
      const oldest = this.windows.keys().next().value;
      if (oldest !== undefined) this.windows.delete(oldest);
    }
    if (!w || w.start !== start) w = { start, count: 0 };
    this.windows.set(key, w);
    w.count++;
    if (w.count > limit) {
      return { ok: false, retryAfterSeconds: Math.max(1, Math.ceil((start + windowMs - now) / 1000)) };
    }
    return { ok: true, retryAfterSeconds: 0 };
  }

  /** Like `hit` but does not count: has this key already exceeded `limit` in the current window? */
  peek(key: string, limit: number, windowMs: number, now: number): { ok: boolean; retryAfterSeconds: number } {
    const start = Math.floor(now / windowMs) * windowMs;
    const w = this.windows.get(key);
    if (w && w.start === start && w.count >= limit) {
      return { ok: false, retryAfterSeconds: Math.max(1, Math.ceil((start + windowMs - now) / 1000)) };
    }
    return { ok: true, retryAfterSeconds: 0 };
  }

  prune(now: number, maxAgeMs = 10 * 60_000): void {
    for (const [k, w] of this.windows) if (w.start + maxAgeMs < now) this.windows.delete(k);
  }

  get size(): number {
    return this.windows.size;
  }
}
