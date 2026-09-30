import type { Context, Hono } from 'hono';
import { FixedWindowLimiter, TtlCache } from './cache.js';
import type { Config } from './config.js';
import type { ContentCatalog, ContentKind } from './content.js';
import { isIP } from 'node:net';
import { hashIp, verifySession } from './crypto.js';
import { ipKey, isPrivateAddress } from './ip.js';
import type { AuthorCols, Repo, SanctionRow, UserRow } from './db/repo.js';
import { invalid, reasonError, unauthorized } from './errors.js';
import type { MediaStore } from './media.js';
import { Counters } from './metrics.js';
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
  | 'publicFeedCacheTtlMs'
  | 'mediaEdgeCacheSeconds'
  | 'userRequestLimitPerMin'
  | 'loadShedLagMs'
>;

export const DEFAULT_TUNING: Tuning = {
  mediaUserQuotaBytes: 50 * 1024 * 1024,
  mediaMaxTotalBytes: 2048 * 1024 * 1024,
  anonReadLimitPerMin: 600,
  anonMediaLimitPerMin: 1500,
  publicCacheTtlMs: 0,
  publicFeedCacheTtlMs: 0,
  mediaEdgeCacheSeconds: 0,
  userRequestLimitPerMin: 240,
  loadShedLagMs: 250,
};

/** A report only counts toward hiding when the reporter's account is at least this old (and active). */
export const REPORT_MIN_ACCOUNT_AGE_MS = 24 * 60 * 60_000;

/** The 403 `suspended` error of a sanction: ban (no access) or restriction (read-only), with its end and cause. */
export function suspendedError(s: SanctionRow) {
  return reasonError('suspended', s.kind === 'ban' ? 'account_banned' : 'account_restricted', {
    kind: s.kind,
    until: s.until === null ? null : new Date(s.until).toISOString(),
    cause: s.reason,
  });
}

/**
 * What a sanctioned account may still do. A restricted account is read-only: GET, HEAD, undoing things (DELETE) and
 * editing its own profile / signing out. A banned account can only exercise its data rights (export, erase) and
 * sign out; everything else is refused with 403 `suspended`.
 */
export function sanctionAllows(s: SanctionRow, method: string, path: string): boolean {
  const m = method.toUpperCase();
  if (m === 'POST' && path === '/v1/auth/logout') return true;
  if (s.kind === 'ban') {
    return (m === 'GET' && path === '/v1/me/export') || (m === 'DELETE' && path === '/v1/me');
  }
  if (m === 'GET' || m === 'HEAD' || m === 'OPTIONS' || m === 'DELETE') return true;
  return m === 'PATCH' && path === '/v1/me';
}

export interface AppDeps {
  repo: Repo;
  media: MediaStore;
  config: Pick<Config, 'sessionSecret' | 'pepper' | 'publicBaseUrl' | 'trustProxy'> &
    Partial<Pick<Config, 'sessionSecretPrev'>> &
    Partial<Tuning>;
  /** Real VALORANT ids (skins / weapons / agents); omitted → ids are not checked. */
  content?: ContentCatalog;
  /** Injectable Riot /userinfo call (stubbed in tests). */
  riotUserinfo: RiotUserinfoFn;
  /** Injectable clock (ms since epoch). */
  now?: () => number;
  /** Current event-loop lag in ms (see load.ts); omitted -> the server never sheds load (tests). */
  loadProbe?: () => number;
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
  accountExport: { limit: 5, windowMs: 60 * 60_000 },
  accountDelete: { limit: 3, windowMs: 60 * 60_000 },
} as const;
export type LimitName = keyof typeof LIMITS;

/**
 * Sign-in limits per client address (in memory, hashed; many people share one carrier-grade-NAT address, so the
 * total is generous). Only tokens Riot REJECTS count toward the small failure limit: each of those costs a Riot
 * call and is how a token could be guessed; successful sign-ins are bounded by real Riot logins.
 */
export const AUTH_ATTEMPTS = { limit: 300, windowMs: 10 * 60_000 } as const;
export const AUTH_FAILURES = { limit: 30, windowMs: 10 * 60_000 } as const;

/** Shared helpers handed to every route module. */
export class Ctx {
  readonly now: () => number;
  readonly tuning: Tuning;
  /** Unauthenticated reads per client IP (in memory: no database write per request). */
  readonly anonLimiter = new FixedWindowLimiter();
  /** Aggregate abuse / security counters (no user data), drained by the once-a-minute log line. */
  readonly stats = new Counters();
  /** Requests per signed-in user (coarse bucket for every route and method; in memory). */
  readonly userLimiter = new FixedWindowLimiter();
  /** Anonymous aggregate responses (skin top / votes / summary / reviews, communities). */
  readonly publicCache = new TtlCache<{ body: string; type: string }>(500);

  /** Secrets accepted for verifying session tokens: the current one first, then the one being rotated out. */
  readonly sessionSecrets: readonly string[];

  constructor(readonly deps: AppDeps) {
    this.sessionSecrets = [deps.config.sessionSecret, deps.config.sessionSecretPrev ?? ''].filter((s) => s !== '');
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
    this.userLimiter.prune(now);
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
    const claims = verifySession(this.sessionSecrets, m[1], this.now());
    if (!claims) throw unauthorized();
    const user = this.repo.getUser(claims.sub);
    if (!user) throw unauthorized();
    // A token issued before this account row existed belongs to an account that was erased and has since been
    // re-created (same Riot account = same id): it must not come back to life. Seconds vs milliseconds: a token
    // signed in the same second as the row was created is fine.
    if (claims.iat < Math.floor(user.created_at / 1000)) throw unauthorized();
    // Logout / ban bumped the epoch: older tokens are revoked.
    if ((claims.ep ?? 0) !== user.session_epoch) throw unauthorized();
    // Sanctions (bans, temporary restrictions) are enforced here, before anything else touches the account.
    const sanction = this.repo.activeSanction(user.id, this.now());
    if (sanction && !sanctionAllows(sanction, c.req.method, c.req.path)) {
      this.stats.inc(`suspended:${sanction.kind}`);
      throw suspendedError(sanction);
    }
    // Coarse valve above the per-action limits: every request of a signed-in user, any route and method
    // (reads, deletes and profile calls have no other limit). In memory: no database write per request.
    const bucket = this.userLimiter.hit(user.id, this.tuning.userRequestLimitPerMin, 60_000, this.now());
    if (!bucket.ok) {
      throw reasonError(
        'rate_limited',
        'rate_limited',
        { bucket: 'requests', limit: this.tuning.userRequestLimitPerMin, windowSeconds: 60 },
        bucket.retryAfterSeconds,
      );
    }
    return user;
  }

  /** Event-loop lag in ms (0 without a probe). */
  loadLagMs(): number {
    return this.deps.loadProbe?.() ?? 0;
  }

  /** Fixed-window counter; throws 429 with retryAfter once the limit is exceeded. */
  rateLimit(name: LimitName, subject: string): void {
    const { limit, windowMs } = LIMITS[name];
    const now = this.now();
    const windowStart = Math.floor(now / windowMs) * windowMs;
    const count = this.repo.hitRateLimit(`${name}:${subject}`, windowStart);
    if (count > limit) {
      const retryAfter = Math.max(1, Math.ceil((windowStart + windowMs - now) / 1000));
      throw reasonError(
        'rate_limited',
        'rate_limited',
        { bucket: name, limit, windowSeconds: Math.round(windowMs / 1000) },
        retryAfter,
      );
    }
  }

  /**
   * The rate-limit identity of the client, hashed with the pepper (null if unknown). Behind the Cloudflare Tunnel
   * (`TRUST_PROXY=true`) it is `CF-Connecting-IP`, believed only when the TCP peer is a loopback / private address
   * (the tunnel) and the header is a real IP address; X-Forwarded-For is never used (its leftmost value is client
   * controlled). Otherwise it is the socket address. IPv6 addresses count as their /64 (see ip.ts).
   */
  clientIpHash(c: Context): string | null {
    const env = c.env as { incoming?: { socket?: { remoteAddress?: string } } } | undefined;
    const peer = env?.incoming?.socket?.remoteAddress;
    let ip: string | undefined;
    if (this.deps.config.trustProxy && (peer === undefined || isPrivateAddress(peer))) {
      const forwarded = c.req.header('cf-connecting-ip')?.trim();
      if (forwarded && isIP(forwarded) !== 0) ip = forwarded;
    }
    ip ??= peer;
    return ip ? hashIp(this.deps.config.pepper, ipKey(ip)) : null;
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

/**
 * What the AUTHOR of an item sees about its visibility (never shown to other viewers): `hidden` and, when hidden,
 * `hiddenReason` = `reports` (hidden automatically after enough reports) or `moderator` (hidden by an operator).
 */
export function ownHidden(r: { hidden: number; hidden_reason: string | null }) {
  const hidden = r.hidden === 1;
  return { hidden, hiddenReason: hidden ? (r.hidden_reason ?? 'reports') : null };
}

/** Country / region / language of a content row (stored at creation time). */
export function origin(r: { country: string | null; region: string | null; language: string | null }) {
  return { country: r.country ?? null, region: r.region ?? null, language: r.language ?? null };
}
