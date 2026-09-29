/**
 * Game-content catalog: which uuids are real VALORANT skins / weapons / agents, fetched from
 * valorant-api.com (public, no user data sent) and cached by the server for 24 hours. Used to reject
 * made-up ids in votes, reviews, shared stores and LFG posts.
 *
 * Fails open by design: with no successful fetch yet (start-up, outage) every id is accepted while the
 * catalog loads in the background (no request waits for the download); after the first success an outage
 * keeps using the stale cache and a stale set refreshes in the background; an unknown id triggers at most
 * one (awaited) re-fetch per `recheckGapMs` so a skin released today is not rejected.
 */
export type ContentKind = 'skin' | 'weapon' | 'agent';

export interface ContentCatalog {
  /** false only when the catalog knows for sure that `uuid` is not a `kind`. */
  isKnown(kind: ContentKind, uuid: string): Promise<boolean>;
}

/** Fixed sets (tests). */
export class StaticCatalog implements ContentCatalog {
  private readonly sets = new Map<ContentKind, Set<string>>();

  constructor(sets: Partial<Record<ContentKind, Iterable<string>>>) {
    for (const [k, v] of Object.entries(sets) as [ContentKind, Iterable<string>][]) {
      this.sets.set(k, new Set([...v].map((s) => s.toLowerCase())));
    }
  }

  async isKnown(kind: ContentKind, uuid: string): Promise<boolean> {
    const s = this.sets.get(kind);
    return s ? s.has(uuid.toLowerCase()) : true;
  }
}

interface Options {
  fetchFn?: typeof fetch;
  now?: () => number;
  baseUrl?: string;
  ttlMs?: number;
  recheckGapMs?: number;
  retryAfterFailureMs?: number;
  timeoutMs?: number;
  log?: (msg: string) => void;
}

const MAX_BODY_BYTES = 30 * 1024 * 1024;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const ENDPOINTS: Record<ContentKind, string> = {
  skin: '/v1/weapons/skins',
  weapon: '/v1/weapons',
  agent: '/v1/agents?isPlayableCharacter=true',
};

/** Pulls `uuid`, `levels[].uuid` and `chromas[].uuid` out of a valorant-api list, defensively. */
export function extractUuids(body: unknown): Set<string> {
  const out = new Set<string>();
  const add = (v: unknown) => {
    if (typeof v === 'string' && UUID_RE.test(v.toLowerCase())) out.add(v.toLowerCase());
  };
  const data = typeof body === 'object' && body !== null ? (body as { data?: unknown }).data : undefined;
  if (!Array.isArray(data)) return out;
  for (const item of data) {
    if (typeof item !== 'object' || item === null) continue;
    const o = item as Record<string, unknown>;
    add(o.uuid);
    for (const key of ['levels', 'chromas']) {
      const list = o[key];
      if (Array.isArray(list)) for (const sub of list) add((sub as { uuid?: unknown } | null)?.uuid);
    }
  }
  return out;
}

export class ValorantContentCatalog implements ContentCatalog {
  private readonly fetchFn: typeof fetch;
  private readonly now: () => number;
  private readonly baseUrl: string;
  private readonly ttlMs: number;
  private readonly recheckGapMs: number;
  private readonly retryAfterFailureMs: number;
  private readonly timeoutMs: number;
  private readonly log: (msg: string) => void;

  private readonly sets = new Map<ContentKind, { ids: Set<string>; loadedAt: number }>();
  private readonly nextAttempt = new Map<ContentKind, number>();
  private readonly inflight = new Map<ContentKind, Promise<void>>();

  constructor(o: Options = {}) {
    this.fetchFn = o.fetchFn ?? fetch;
    this.now = o.now ?? (() => Date.now());
    this.baseUrl = o.baseUrl ?? 'https://valorant-api.com';
    this.ttlMs = o.ttlMs ?? 24 * 60 * 60_000;
    this.recheckGapMs = o.recheckGapMs ?? 10 * 60_000;
    this.retryAfterFailureMs = o.retryAfterFailureMs ?? 5 * 60_000;
    this.timeoutMs = o.timeoutMs ?? 20_000;
    this.log = o.log ?? (() => {});
  }

  /** Loads (or refreshes) the given kinds now; start-up calls it in the background, tests await it. */
  async warm(kinds: readonly ContentKind[] = ['skin', 'weapon', 'agent']): Promise<void> {
    await Promise.all(kinds.map((k) => this.refresh(k)));
  }

  async isKnown(kind: ContentKind, uuid: string): Promise<boolean> {
    const id = uuid.toLowerCase();
    let entry = this.sets.get(kind);
    if (!entry) {
      void this.refresh(kind); // never loaded: fail open now, load in the background
      return true;
    }
    if (this.now() - entry.loadedAt > this.ttlMs) void this.refresh(kind); // stale: use it, refresh meanwhile
    if (entry.ids.has(id)) return true;
    // Unknown: it may have been released since the last refresh.
    if (this.now() - entry.loadedAt >= this.recheckGapMs) {
      await this.refresh(kind, true);
      entry = this.sets.get(kind)!;
      return entry.ids.has(id);
    }
    return false;
  }

  /** Single-flight refresh of one kind; failures keep the old set and back off. */
  private refresh(kind: ContentKind, force = false): Promise<void> {
    const running = this.inflight.get(kind);
    if (running) return running;
    if (!force && this.now() < (this.nextAttempt.get(kind) ?? 0)) return Promise.resolve();
    const p = this.load(kind)
      .catch((e: unknown) => {
        this.nextAttempt.set(kind, this.now() + this.retryAfterFailureMs);
        this.log(`content catalog (${kind}) refresh failed: ${(e as Error).name}`);
      })
      .finally(() => this.inflight.delete(kind));
    this.inflight.set(kind, p);
    return p;
  }

  private async load(kind: ContentKind): Promise<void> {
    const res = await this.fetchFn(`${this.baseUrl}${ENDPOINTS[kind]}`, {
      headers: { accept: 'application/json' },
      signal: AbortSignal.timeout(this.timeoutMs),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const text = await res.text();
    if (text.length > MAX_BODY_BYTES) throw new Error('response too large');
    const ids = extractUuids(JSON.parse(text));
    if (ids.size === 0) throw new Error('empty catalog');
    this.sets.set(kind, { ids, loadedAt: this.now() });
    this.nextAttempt.delete(kind);
  }
}
