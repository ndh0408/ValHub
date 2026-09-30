import fs from 'node:fs/promises';
import path from 'node:path';

/**
 * Game-content catalog: which uuids are real VALORANT skins / weapons / agents, fetched from
 * valorant-api.com (public, no user data sent) and cached by the server for 24 hours. Used to reject
 * made-up ids in votes, reviews, shared stores and LFG posts, and to map any skin / level / chroma uuid to its
 * canonical base skin and weapon (one vote per account per skin, however the client names it).
 *
 * Fails open by design: with no successful fetch yet (start-up, outage) every id is accepted while the
 * catalog loads in the background (no request waits for the download); after the first success an outage
 * keeps using the stale cache and a stale set refreshes in the background; an unknown id triggers at most
 * one (awaited) re-fetch per `recheckGapMs` so a skin released today is not rejected. A snapshot of the last
 * good catalog is written to disk and read back at start-up, so a restart during a valorant-api outage does not
 * reopen the window in which any well-formed uuid is accepted.
 */
export type ContentKind = 'skin' | 'weapon' | 'agent';

/** The canonical identity of a skin: its base skin uuid and the weapon it belongs to. */
export interface SkinRef {
  skinUuid: string;
  weaponUuid: string;
}

export interface ContentCatalog {
  /** false only when the catalog knows for sure that `uuid` is not a `kind`. */
  isKnown(kind: ContentKind, uuid: string): Promise<boolean>;
  /**
   * Synchronous lookup of the base skin and weapon of a skin, skin-level or chroma uuid; null when the catalog
   * does not know it (or has not loaded yet: callers then keep what the client sent).
   */
  resolveSkin?(uuid: string): SkinRef | null;
  /** Changes whenever the skin map is rebuilt (the sweeper re-canonicalises stored votes / reviews then). */
  skinMapVersion?(): number;
}

/** Fixed sets (tests). */
export class StaticCatalog implements ContentCatalog {
  private readonly sets = new Map<ContentKind, Set<string>>();
  private readonly skins = new Map<string, SkinRef>();
  private version = 0;

  constructor(
    sets: Partial<Record<ContentKind, Iterable<string>>>,
    /** alias uuid (level / chroma / the base itself) -> canonical skin + weapon */
    skinMap: Record<string, SkinRef> = {},
  ) {
    for (const [k, v] of Object.entries(sets) as [ContentKind, Iterable<string>][]) {
      this.sets.set(k, new Set([...v].map((s) => s.toLowerCase())));
    }
    for (const [alias, ref] of Object.entries(skinMap)) this.skins.set(alias.toLowerCase(), ref);
    if (this.skins.size > 0) this.version = 1;
  }

  async isKnown(kind: ContentKind, uuid: string): Promise<boolean> {
    const s = this.sets.get(kind);
    return s ? s.has(uuid.toLowerCase()) : true;
  }

  resolveSkin(uuid: string): SkinRef | null {
    return this.skins.get(uuid.toLowerCase()) ?? null;
  }

  skinMapVersion(): number {
    return this.version;
  }

  /** Test hook: replaces the skin map (bumps the version like a real refresh). */
  setSkinMap(skinMap: Record<string, SkinRef>): void {
    this.skins.clear();
    for (const [alias, ref] of Object.entries(skinMap)) this.skins.set(alias.toLowerCase(), ref);
    this.version++;
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
  /** Where the last good catalog is kept between runs (omitted: no snapshot). */
  snapshotFile?: string;
}

const MAX_BODY_BYTES = 30 * 1024 * 1024;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const ENDPOINTS: Record<ContentKind, string> = {
  skin: '/v1/weapons/skins',
  weapon: '/v1/weapons',
  agent: '/v1/agents?isPlayableCharacter=true',
};

const asUuid = (v: unknown): string | null =>
  typeof v === 'string' && UUID_RE.test(v.toLowerCase()) ? v.toLowerCase() : null;

/** Pulls `uuid`, `levels[].uuid` and `chromas[].uuid` out of a valorant-api list, defensively. */
export function extractUuids(body: unknown): Set<string> {
  const out = new Set<string>();
  const add = (v: unknown) => {
    const id = asUuid(v);
    if (id) out.add(id);
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

/**
 * Builds `alias uuid -> {base skin, weapon}` from `/v1/weapons`: every weapon lists its skins, and every skin
 * its levels and chromas. The base skin uuid maps to itself. Defensive: anything malformed is skipped; the first
 * mapping of a uuid wins.
 */
export function extractSkinMap(body: unknown): Map<string, SkinRef> {
  const out = new Map<string, SkinRef>();
  const data = typeof body === 'object' && body !== null ? (body as { data?: unknown }).data : undefined;
  if (!Array.isArray(data)) return out;
  for (const weapon of data) {
    if (typeof weapon !== 'object' || weapon === null) continue;
    const w = weapon as Record<string, unknown>;
    const weaponUuid = asUuid(w.uuid);
    if (!weaponUuid || !Array.isArray(w.skins)) continue;
    for (const skin of w.skins) {
      if (typeof skin !== 'object' || skin === null) continue;
      const s = skin as Record<string, unknown>;
      const base = asUuid(s.uuid);
      if (!base) continue;
      const ref: SkinRef = { skinUuid: base, weaponUuid };
      const put = (id: string | null) => {
        if (id && !out.has(id)) out.set(id, ref);
      };
      put(base);
      for (const key of ['levels', 'chromas']) {
        const list = s[key];
        if (Array.isArray(list)) for (const sub of list) put(asUuid((sub as { uuid?: unknown } | null)?.uuid));
      }
    }
  }
  return out;
}

/** Reads a response body, refusing more than `max` bytes (checks Content-Length first, then counts while reading). */
async function readCapped(res: Response, max: number): Promise<string> {
  const declared = Number(res.headers.get('content-length'));
  if (Number.isFinite(declared) && declared > max) throw new Error('response too large');
  if (!res.body) return '';
  const reader = res.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > max) {
      await reader.cancel().catch(() => {});
      throw new Error('response too large');
    }
    chunks.push(value);
  }
  return Buffer.concat(chunks).toString('utf8');
}

interface Snapshot {
  v: 1;
  loadedAt: Partial<Record<ContentKind, number>>;
  weapon?: string[];
  agent?: string[];
  /** Skin-list ids that are not keys of `map` (normally none). */
  skinExtra?: string[];
  /** Weapon uuids referenced by `map`. */
  weapons?: string[];
  /** [alias uuid, base skin uuid, index into weapons] */
  map?: [string, string, number][];
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
  private readonly snapshotFile: string | undefined;

  private readonly sets = new Map<ContentKind, { ids: Set<string>; loadedAt: number }>();
  private readonly nextAttempt = new Map<ContentKind, number>();
  private readonly inflight = new Map<ContentKind, Promise<void>>();
  private skinMap = new Map<string, SkinRef>();
  private version = 0;
  private saving: Promise<void> = Promise.resolve();

  constructor(o: Options = {}) {
    this.fetchFn = o.fetchFn ?? fetch;
    this.now = o.now ?? (() => Date.now());
    this.baseUrl = o.baseUrl ?? 'https://valorant-api.com';
    this.ttlMs = o.ttlMs ?? 24 * 60 * 60_000;
    this.recheckGapMs = o.recheckGapMs ?? 10 * 60_000;
    this.retryAfterFailureMs = o.retryAfterFailureMs ?? 5 * 60_000;
    this.timeoutMs = o.timeoutMs ?? 20_000;
    this.log = o.log ?? (() => {});
    this.snapshotFile = o.snapshotFile;
  }

  /** Loads (or refreshes) the given kinds now; start-up calls it in the background, tests await it. */
  async warm(kinds: readonly ContentKind[] = ['skin', 'weapon', 'agent']): Promise<void> {
    await Promise.all(kinds.map((k) => this.refresh(k)));
  }

  resolveSkin(uuid: string): SkinRef | null {
    return this.skinMap.get(uuid.toLowerCase()) ?? null;
  }

  skinMapVersion(): number {
    return this.version;
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
      void this.refresh(kind);
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
    const body: unknown = JSON.parse(await readCapped(res, MAX_BODY_BYTES));
    const ids = extractUuids(body);
    if (ids.size === 0) throw new Error('empty catalog');
    this.sets.set(kind, { ids, loadedAt: this.now() });
    this.nextAttempt.delete(kind);
    if (kind === 'weapon') {
      const map = extractSkinMap(body);
      if (map.size > 0) {
        this.skinMap = map;
        this.version++;
      }
    }
    void this.saveSnapshot();
  }

  // ---- snapshot on disk (CS-38) ---------------------------------------------------------------------------

  private snapshot(): Snapshot {
    const weapons = [...new Set([...this.skinMap.values()].map((r) => r.weaponUuid))];
    const weaponIndex = new Map(weapons.map((w, i) => [w, i]));
    const skin = this.sets.get('skin');
    const snap: Snapshot = {
      v: 1,
      loadedAt: Object.fromEntries([...this.sets].map(([k, v]) => [k, v.loadedAt])),
      weapons,
      map: [...this.skinMap].map(([alias, ref]) => [alias, ref.skinUuid, weaponIndex.get(ref.weaponUuid)!]),
    };
    if (skin) snap.skinExtra = [...skin.ids].filter((id) => !this.skinMap.has(id));
    const weapon = this.sets.get('weapon');
    if (weapon) snap.weapon = [...weapon.ids];
    const agent = this.sets.get('agent');
    if (agent) snap.agent = [...agent.ids];
    return snap;
  }

  /** Writes the snapshot (atomic: temp file + rename); saves are serialised, failures only logged. */
  saveSnapshot(): Promise<void> {
    const file = this.snapshotFile;
    if (!file) return Promise.resolve();
    this.saving = this.saving
      .then(async () => {
        await fs.mkdir(path.dirname(file), { recursive: true });
        const tmp = `${file}.tmp`;
        await fs.writeFile(tmp, JSON.stringify(this.snapshot()), { mode: 0o600 });
        await fs.rename(tmp, file);
      })
      .catch((e: unknown) => this.log(`content catalog snapshot not saved: ${(e as Error).name}`));
    return this.saving;
  }

  /**
   * Loads the snapshot written by an earlier run, if any (start-up). A missing, unreadable or malformed file is
   * ignored. Returns true when something was restored. Kinds already loaded from the network are left alone.
   */
  async restoreSnapshot(): Promise<boolean> {
    const file = this.snapshotFile;
    if (!file) return false;
    let snap: Snapshot;
    try {
      snap = JSON.parse(await fs.readFile(file, 'utf8')) as Snapshot;
    } catch {
      return false;
    }
    if (typeof snap !== 'object' || snap === null || snap.v !== 1 || typeof snap.loadedAt !== 'object' || snap.loadedAt === null) return false;
    const ids = (v: unknown): Set<string> | null => {
      if (!Array.isArray(v)) return null;
      const out = new Set<string>();
      for (const x of v) {
        const id = asUuid(x);
        if (id) out.add(id);
      }
      return out.size > 0 ? out : null;
    };
    const at = (k: ContentKind): number => {
      const t = snap.loadedAt[k];
      return typeof t === 'number' && Number.isFinite(t) ? t : 0;
    };
    let restored = false;
    const weapons = Array.isArray(snap.weapons) ? snap.weapons.map(asUuid) : [];
    const map = new Map<string, SkinRef>();
    if (Array.isArray(snap.map)) {
      for (const row of snap.map) {
        if (!Array.isArray(row) || row.length !== 3) continue;
        const alias = asUuid(row[0]);
        const base = asUuid(row[1]);
        const weapon = typeof row[2] === 'number' ? weapons[row[2]] : null;
        if (alias && base && weapon) map.set(alias, { skinUuid: base, weaponUuid: weapon });
      }
    }
    if (!this.sets.has('skin')) {
      const skinIds = new Set(map.keys());
      for (const id of ids(snap.skinExtra) ?? []) skinIds.add(id);
      if (skinIds.size > 0) {
        this.sets.set('skin', { ids: skinIds, loadedAt: at('skin') });
        restored = true;
      }
    }
    const weaponIds = ids(snap.weapon);
    if (!this.sets.has('weapon') && weaponIds) {
      this.sets.set('weapon', { ids: weaponIds, loadedAt: at('weapon') });
      restored = true;
    }
    const agentIds = ids(snap.agent);
    if (!this.sets.has('agent') && agentIds) {
      this.sets.set('agent', { ids: agentIds, loadedAt: at('agent') });
      restored = true;
    }
    if (this.skinMap.size === 0 && map.size > 0) {
      this.skinMap = map;
      this.version++;
      restored = true;
    }
    return restored;
  }
}
