import type { Context, Hono } from 'hono';
import { FixedWindowLimiter, TtlCache } from './cache.js';
import type { Config } from './config.js';
import type { ContentCatalog, ContentKind } from './content.js';
import { hashIp, verifySession } from './crypto.js';
import type { AuthorCols, Repo, UserRow } from './db/repo.js';
import { ApiError, invalid, unauthorized } from './errors.js';
import type { MediaStore } from './media.js';
import { deleteMedia, quarantineMedia, type MediaDeps } from './media-service.js';
import type { RiotUserinfoFn } from './riot.js';
import { parseJsonObject, type Json } from './validate.js';

/** Tunable limits. Anything left out gets the default below (tests run with the cache off). */
export type Tuning = Pick<
  Config,
  | 'mediaUserQuotaBytes'
  | 'mediaMaxTotalBytes'
  | 'anonReadLimitPerMin'
  | 'anonMediaLimitPerMin'
  | 'publicCacheTtlMs'
  | 'mediaEdgeCacheSeconds'
>;

export const DEFAULT_TUNING: Tuning = {
  mediaUserQuotaBytes: 50 * 1024 * 1024,
  mediaMaxTotalBytes: 2048 * 1024 * 1024,
  anonReadLimitPerMin: 120,
  anonMediaLimitPerMin: 1500,
  publicCacheTtlMs: 0,
  mediaEdgeCacheSeconds: 0,
};

/** A report only counts toward hiding when the reporter's account is at least this old (and active). */
export const REPORT_MIN_ACCOUNT_AGE_MS = 24 * 60 * 60_000;

export interface AppDeps {
  repo: Repo;
  media: MediaStore;
  config: Pick<Config, 'sessionSecret' | 'pepper' | 'publicBaseUrl' | 'trustProxy'> & Partial<Tuning>;
  /** Real VALORANT ids (skins / weapons / agents); omitted → ids are not checked. */
  content?: ContentCatalog;
  /** Injectable Riot /userinfo call (stubbed in tests). */
  riotUserinfo: RiotUserinfoFn;
  /** Injectable clock (ms since epoch). */
  now?: () => number;
  /** Error sink; receives only error names/messages, never request data. */
  logError?: (msg: string) => void;
}

export type App = Hono;

/** Per-user rate limits from the spec (+ a couple of defensive extras, see README Notes). */
export const LIMITS = {
  lfg: { limit: 6, windowMs: 10 * 60_000 },
  posts: { limit: 10, windowMs: 60 * 60_000 },
  comments: { limit: 30, windowMs: 10 * 60_000 },
  media: { limit: 20, windowMs: 60 * 60_000 },
  reports: { limit: 20, windowMs: 60 * 60_000 },
  votes: { limit: 120, windowMs: 60 * 60_000 },
  likes: { limit: 120, windowMs: 60 * 60_000 },
  reviews: { limit: 30, windowMs: 60 * 60_000 },
  lfgPatch: { limit: 120, windowMs: 10 * 60_000 },
  lfgJoin: { limit: 30, windowMs: 10 * 60_000 },
  authIp: { limit: 30, windowMs: 10 * 60_000 },
  accountExport: { limit: 5, windowMs: 60 * 60_000 },
  accountDelete: { limit: 3, windowMs: 60 * 60_000 },
} as const;
export type LimitName = keyof typeof LIMITS;

/** Shared helpers handed to every route module. */
export class Ctx {
  readonly now: () => number;
  readonly tuning: Tuning;
  /** Unauthenticated reads per client IP (in memory: no database write per request). */
  readonly anonLimiter = new FixedWindowLimiter();
  /** Anonymous aggregate responses (skin top / votes / summary / reviews, communities). */
  readonly publicCache = new TtlCache<{ body: string; type: string }>(500);

  constructor(readonly deps: AppDeps) {
    this.now = deps.now ?? (() => Date.now());
    this.tuning = { ...DEFAULT_TUNING };
    for (const k of Object.keys(DEFAULT_TUNING) as (keyof Tuning)[]) {
      const v = deps.config[k];
      if (typeof v === 'number') this.tuning[k] = v;
    }
  }

  /** Drops expired in-memory entries (called by the periodic sweeper). */
  pruneMemory(): void {
    const now = this.now();
    this.anonLimiter.prune(now);
    this.publicCache.prune(now);
  }

  /** Dependencies of the media lifecycle helpers. */
  get mediaDeps(): MediaDeps {
    return { repo: this.deps.repo, media: this.deps.media, now: this.now, logError: this.deps.logError };
  }

  deleteMedia(keys: readonly string[]): Promise<void> {
    return deleteMedia(this.mediaDeps, keys);
  }

  quarantineMedia(keys: readonly string[]): Promise<void> {
    return quarantineMedia(this.mediaDeps, keys);
  }

  /**
   * Rejects (400) an id the content catalog knows is not a real skin / weapon / agent. Fails open when
   * there is no catalog, it has nothing yet, or it throws.
   */
  async assertContent(kind: ContentKind, uuid: string, field: string): Promise<void> {
    const catalog = this.deps.content;
    if (!catalog) return;
    let known = true;
    try {
      known = await catalog.isKnown(kind, uuid);
    } catch {
      known = true;
    }
    if (!known) {
      const what = kind === 'skin' ? 'skin' : kind === 'weapon' ? 'vũ khí' : 'đặc vụ';
      throw invalid(`${field} không phải ${what} của VALORANT.`);
    }
  }

  get repo(): Repo {
    return this.deps.repo;
  }

  json(c: Context, data: unknown, status: 200 | 201 = 200): Response {
    return c.body(JSON.stringify(data), status, { 'content-type': 'application/json; charset=utf-8' });
  }

  noContent(c: Context): Response {
    return c.body(null, 204);
  }

  async readJson(c: Context): Promise<Json> {
    return parseJsonObject(await c.req.text());
  }

  /**
   * Resolves the session user. With `required = false`, a missing header yields
   * null, but a present-and-invalid token is still rejected (so clients refresh).
   */
  user(c: Context, required: true): UserRow;
  user(c: Context, required: false): UserRow | null;
  user(c: Context, required: boolean): UserRow | null {
    const header = c.req.header('authorization');
    if (!header) {
      if (required) throw unauthorized('Cần đăng nhập.');
      return null;
    }
    const m = /^Bearer\s+(\S+)$/i.exec(header.trim());
    if (!m?.[1]) throw unauthorized();
    const claims = verifySession(this.deps.config.sessionSecret, m[1], this.now());
    if (!claims) throw unauthorized();
    const user = this.repo.getUser(claims.sub);
    if (!user) throw unauthorized();
    return user;
  }

  /** Fixed-window counter; throws 429 with retryAfter once the limit is exceeded. */
  rateLimit(name: LimitName, subject: string): void {
    const { limit, windowMs } = LIMITS[name];
    const now = this.now();
    const windowStart = Math.floor(now / windowMs) * windowMs;
    const count = this.repo.hitRateLimit(`${name}:${subject}`, windowStart);
    if (count > limit) {
      const retryAfter = Math.max(1, Math.ceil((windowStart + windowMs - now) / 1000));
      throw new ApiError('rate_limited', 'Bạn thao tác quá nhanh, vui lòng thử lại sau.', retryAfter);
    }
  }

  /** Client IP (CF-Connecting-IP behind the tunnel), hashed with the pepper; null if unknown. */
  clientIpHash(c: Context): string | null {
    let ip: string | undefined;
    if (this.deps.config.trustProxy) {
      ip =
        c.req.header('cf-connecting-ip')?.trim() ||
        c.req.header('x-forwarded-for')?.split(',')[0]?.trim() ||
        undefined;
    }
    if (!ip) {
      const env = c.env as { incoming?: { socket?: { remoteAddress?: string } } } | undefined;
      ip = env?.incoming?.socket?.remoteAddress;
    }
    return ip ? hashIp(this.deps.config.pepper, ip) : null;
  }

  /** Absolute base URL for links (PUBLIC_BASE_URL, else request origin via tunnel headers). */
  baseUrl(c: Context): string {
    if (this.deps.config.publicBaseUrl) return this.deps.config.publicBaseUrl;
    const url = new URL(c.req.url);
    let proto = url.protocol.replace(':', '');
    let host = url.host;
    if (this.deps.config.trustProxy) {
      const fp = c.req.header('x-forwarded-proto')?.split(',')[0]?.trim().toLowerCase();
      if (fp === 'http' || fp === 'https') proto = fp;
      const fh = c.req.header('x-forwarded-host')?.split(',')[0]?.trim();
      if (fh && /^[A-Za-z0-9.-]+(:\d{1,5})?$/.test(fh)) host = fh;
    }
    return `${proto}://${host}`;
  }

  mediaUrl(base: string, key: string): string {
    return `${base}/v1/media/${key}`;
  }
}

export const iso = (ms: number): string => new Date(ms).toISOString();

export function author(r: AuthorCols) {
  return {
    id: r.a_id,
    gameName: r.a_game_name,
    tagLine: r.a_tag_line,
    cardId: r.a_card_id,
    rankTier: r.a_rank_tier,
    region: r.a_region,
    country: r.a_country ?? null,
    language: r.a_language ?? null,
  };
}

export function authorFromUser(u: UserRow) {
  return {
    id: u.id,
    gameName: u.game_name,
    tagLine: u.tag_line,
    cardId: u.card_id,
    rankTier: u.rank_tier,
    region: u.region,
    country: u.country ?? null,
    language: u.language ?? null,
  };
}

/** Country / region / language of a content row (stored at creation time). */
export function origin(r: { country: string | null; region: string | null; language: string | null }) {
  return { country: r.country ?? null, region: r.region ?? null, language: r.language ?? null };
}
