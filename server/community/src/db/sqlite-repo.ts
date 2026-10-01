import type { Cursor } from '../cursor.js';
import { geoCondition, type GeoScope } from '../geo/scope.js';
import type { ReportTarget } from '../validate.js';
import type { Db } from './database.js';
import { reasonError } from '../errors.js';
import type { StoredResponse } from './repo.js';
import type {
  AccountData,
  AuditRow,
  AuthorCols,
  CanonicalizeResult,
  CommentRow,
  CommunityActivity,
  HiddenItem,
  LfgPatch,
  LfgQuery,
  LfgRow,
  LfgView,
  MediaRow,
  Origin,
  PostRow,
  PostView,
  RatingStats,
  ReportOutcome,
  ReportedTarget,
  Repo,
  ReviewRow,
  ReviewView,
  SanctionKind,
  SanctionRow,
  SkinCount,
  SweepCounts,
  UserPatch,
  UserRow,
  UserUpsert,
} from './repo.js';

const AUTHOR_SELECT = `u.id AS a_id, u.game_name AS a_game_name, u.tag_line AS a_tag_line,
  u.card_id AS a_card_id, u.rank_tier AS a_rank_tier, u.region AS a_region,
  u.country AS a_country, u.language AS a_language`;

const POST_SELECT = `SELECT p.id, p.user_id, p.kind, p.body, p.media, p.payload, p.hidden, p.hidden_reason, p.created_at,
  p.country, p.region, p.language,
  ${AUTHOR_SELECT},
  (SELECT COUNT(*) FROM post_likes l WHERE l.post_id = p.id) AS likes,
  (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id AND c.hidden = 0) AS comments,
  EXISTS (SELECT 1 FROM post_likes l2 WHERE l2.post_id = p.id AND l2.user_id = @viewer) AS liked
  FROM posts p JOIN users u ON u.id = p.user_id`;

const LFG_SELECT = `SELECT l.*, ${AUTHOR_SELECT},
  (SELECT COUNT(*) FROM lfg_joins j WHERE j.lfg_id = l.id) AS joins
  FROM lfg_posts l JOIN users u ON u.id = l.user_id`;

const REVIEW_SELECT = `SELECT r.*, ${AUTHOR_SELECT},
  EXISTS (SELECT 1 FROM review_likes rl WHERE rl.review_id = r.id AND rl.user_id = @viewer) AS liked
  FROM skin_reviews r JOIN users u ON u.id = r.user_id`;

const DAY_MS = 24 * 60 * 60 * 1000;
/** Expired LFG posts are kept this long so /v1/communities can count a week of LFG activity. */
const LFG_RETENTION_MS = 8 * DAY_MS;

/** Binds `values` as @<prefix>0, @<prefix>1, … and returns the placeholder list. */
function inList(prefix: string, values: readonly string[], params: Record<string, unknown>): string {
  return values
    .map((v, i) => {
      params[`${prefix}${i}`] = v;
      return `@${prefix}${i}`;
    })
    .join(', ');
}

/** Media keys of a post's `media` JSON column (defensive: anything unexpected → none). */
function parseKeys(json: string): string[] {
  try {
    const v: unknown = JSON.parse(json);
    return Array.isArray(v) ? v.filter((k): k is string => typeof k === 'string') : [];
  } catch {
    return [];
  }
}

function and(where: string[]): string {
  return where.filter(Boolean).join(' AND ');
}

export class SqliteRepo implements Repo {
  constructor(private readonly db: Db, private readonly now: () => number = Date.now) {}

  getRequestKey(id: string, now: number): StoredResponse | null {
    return (this.db.prepare('SELECT fingerprint, body, status FROM request_keys WHERE id = ? AND expires_at > ?').get(id, now) as StoredResponse | undefined) ?? null;
  }
  saveRequestKey(row: StoredResponse & { id: string; userId: string; expiresAt: number }): void {
    this.db.prepare(`INSERT OR REPLACE INTO request_keys (id, user_id, fingerprint, body, status, expires_at)
      VALUES (@id, @userId, @fingerprint, @body, @status, @expiresAt)`).run(row);
  }

  ping(): boolean {
    return (this.db.prepare('SELECT 1 AS ok').get() as { ok: number } | undefined)?.ok === 1;
  }

  // ---- users -------------------------------------------------------------

  upsertUser(u: UserUpsert, now: number): UserRow {
    const existing = this.getUser(u.id);
    const cardId = u.cardId === undefined ? (existing?.card_id ?? null) : u.cardId;
    const rankTier = u.rankTier === undefined ? (existing?.rank_tier ?? null) : u.rankTier;
    const language = u.language === undefined ? (existing?.language ?? null) : u.language;
    // The consent time is when this version was first recorded; the same version again keeps it.
    const consentVersion = u.consentVersion ?? existing?.consent_version ?? null;
    const consentAt =
      u.consentVersion === undefined || u.consentVersion === existing?.consent_version
        ? (existing?.consent_at ?? null)
        : now;
    this.db
      .prepare(
        `INSERT INTO users (id, game_name, tag_line, card_id, rank_tier, region, country, language, created_at, updated_at,
           consent_version, consent_at, session_epoch)
         VALUES (@id, @gameName, @tagLine, @cardId, @rankTier, @region, @country, @language, @now, @now,
           @consentVersion, @consentAt, COALESCE((SELECT epoch FROM revoked_accounts WHERE user_id = @id), 0))
         ON CONFLICT(id) DO UPDATE SET game_name = excluded.game_name, tag_line = excluded.tag_line,
           card_id = excluded.card_id, rank_tier = excluded.rank_tier, region = excluded.region,
           country = excluded.country, language = excluded.language, updated_at = excluded.updated_at,
           consent_version = excluded.consent_version, consent_at = excluded.consent_at`,
      )
      .run({
        consentVersion,
        consentAt,
        id: u.id,
        gameName: u.gameName,
        tagLine: u.tagLine,
        cardId,
        rankTier,
        region: u.region,
        country: u.country,
        language,
        now,
      });
    return this.getUser(u.id)!;
  }

  getUser(id: string): UserRow | null {
    return (this.db.prepare('SELECT * FROM users WHERE id = ?').get(id) as UserRow | undefined) ?? null;
  }

  updateUser(id: string, patch: UserPatch, now: number): UserRow | null {
    const existing = this.getUser(id);
    if (!existing) return null;
    this.db
      .prepare('UPDATE users SET card_id = ?, rank_tier = ?, region = ?, language = ?, updated_at = ? WHERE id = ?')
      .run(
        patch.cardId === undefined ? existing.card_id : patch.cardId,
        patch.rankTier === undefined ? existing.rank_tier : patch.rankTier,
        patch.region ?? existing.region,
        patch.language ?? existing.language,
        now,
        id,
      );
    return this.getUser(id);
  }

  bumpSessionEpoch(id: string): number | null {
    const row = this.db
      .prepare('UPDATE users SET session_epoch = session_epoch + 1 WHERE id = ? RETURNING session_epoch')
      .get(id) as { session_epoch: number } | undefined;
    return row?.session_epoch ?? null;
  }

  // ---- rate limits / maintenance ------------------------------------------

  hitRateLimit(bucket: string, windowStart: number): number {
    const row = this.db
      .prepare(
        `INSERT INTO rate_limits (bucket, window_start, count) VALUES (?, ?, 1)
         ON CONFLICT(bucket, window_start) DO UPDATE SET count = count + 1
         RETURNING count`,
      )
      .get(bucket, windowStart) as { count: number };
    return row.count;
  }

  cleanup(now: number): void {
    this.db.prepare('DELETE FROM request_keys WHERE expires_at <= ?').run(now);
    this.db.prepare('DELETE FROM revoked_accounts WHERE expires_at <= ?').run(now);
    this.db.prepare('DELETE FROM rate_limits WHERE window_start < ?').run(now - DAY_MS);
    this.db.prepare('DELETE FROM lfg_posts WHERE expires_at < ?').run(now - LFG_RETENTION_MS);
    // Sanctions that ended (or were lifted) more than a year ago and operator log rows older than two years.
    this.db
      .prepare(
        'DELETE FROM sanctions WHERE (lifted_at IS NOT NULL AND lifted_at < @old) OR (until IS NOT NULL AND until < @old)',
      )
      .run({ old: now - 365 * DAY_MS });
    this.db.prepare('DELETE FROM moderation_audit WHERE at < ?').run(now - 730 * DAY_MS);
    this.db.pragma('optimize');
  }

  // ---- LFG ---------------------------------------------------------------

  replaceLfg(post: Omit<LfgRow, 'hidden_reason'>): void {
    this.db.transaction(() => {
      // One active post per user: earlier posts expire now (kept for the weekly activity count).
      // A replacement starts a new join count even though old posts remain
      // for activity statistics.
      this.db
        .prepare(
          'DELETE FROM lfg_joins WHERE lfg_id IN (SELECT id FROM lfg_posts WHERE user_id = @userId AND expires_at > @now)',
        )
        .run({ userId: post.user_id, now: post.created_at });
      this.db
        .prepare('UPDATE lfg_posts SET expires_at = @now WHERE user_id = @userId AND expires_at > @now')
        .run({ userId: post.user_id, now: post.created_at });
      this.db
        .prepare(
          `INSERT INTO lfg_posts (id, user_id, region, mode, party_code, slots, rank_tier, note, hidden,
             created_at, expires_at, rank_min, rank_max, roles, mic, language, party_size, agents, status,
             updated_at, country)
           VALUES (@id, @user_id, @region, @mode, @party_code, @slots, @rank_tier, @note, @hidden,
             @created_at, @expires_at, @rank_min, @rank_max, @roles, @mic, @language, @party_size, @agents,
             @status, @updated_at, @country)`,
        )
        .run(post);
    })();
  }

  listLfg(q: LfgQuery): LfgView[] {
    const params: Record<string, unknown> = { now: q.now, status: q.status, limit: q.limit + 1 };
    const where = ['l.hidden = 0', 'l.expires_at > @now', 'l.status = @status', geoCondition('l', q.geo, params)];
    if (q.mode) {
      where.push('l.mode = @mode');
      params.mode = q.mode;
    }
    if (q.rank !== undefined) {
      // A bound of NULL or 0 means "any" on that side.
      where.push(
        '(l.rank_min IS NULL OR l.rank_min = 0 OR l.rank_min <= @rank)',
        '(l.rank_max IS NULL OR l.rank_max = 0 OR l.rank_max >= @rank)',
      );
      params.rank = q.rank;
    }
    if (q.role) {
      // Posts that list no roles accept any role.
      where.push(`(l.roles = '[]' OR EXISTS (SELECT 1 FROM json_each(l.roles) WHERE json_each.value = @role))`);
      params.role = q.role;
    }
    if (q.mic !== undefined) {
      where.push('l.mic = @mic');
      params.mic = q.mic ? 1 : 0;
    }
    if (q.languages && q.languages.length > 0 && !q.languages.includes('any')) {
      // Parties open to any language always match.
      where.push(`(l.language = 'any' OR l.language IN (${inList('lang', q.languages, params)}))`);
    }
    if (q.cursor) {
      where.push('(l.created_at < @cAt OR (l.created_at = @cAt AND l.id < @cId))');
      params.cAt = q.cursor.createdAt;
      params.cId = q.cursor.id;
    }
    return this.db
      .prepare(`${LFG_SELECT} WHERE ${and(where)} ORDER BY l.created_at DESC, l.id DESC LIMIT @limit`)
      .all(params) as LfgView[];
  }

  getLfg(id: string): LfgView | null {
    return (this.db.prepare(`${LFG_SELECT} WHERE l.id = ?`).get(id) as LfgView | undefined) ?? null;
  }

  getActiveLfgForUser(userId: string, now: number): LfgView | null {
    return (
      (this.db
        .prepare(`${LFG_SELECT} WHERE l.user_id = ? AND l.expires_at > ? ORDER BY l.created_at DESC LIMIT 1`)
        .get(userId, now) as LfgView | undefined) ?? null
    );
  }

  updateLfg(id: string, patch: LfgPatch, now: number, expiresAt: number, userId?: string): boolean {
    const sets = ['updated_at = @now', 'expires_at = @expiresAt'];
    const params: Record<string, unknown> = { id, now, expiresAt };
    if (patch.party_size !== undefined) {
      sets.push('party_size = @partySize');
      params.partySize = patch.party_size;
    }
    if (patch.slots !== undefined) {
      sets.push('slots = @slots');
      params.slots = patch.slots;
    }
    if (patch.note !== undefined) {
      sets.push('note = @note');
      params.note = patch.note;
    }
    if (patch.status !== undefined) {
      sets.push('status = @status');
      params.status = patch.status;
    }
    if (userId !== undefined) params.owner = userId;
    return this.db.prepare(`UPDATE lfg_posts SET ${sets.join(', ')} WHERE id = @id AND expires_at > @now
      ${userId === undefined ? '' : 'AND user_id = @owner'}`).run(params).changes === 1;
  }

  deleteLfg(id: string): void {
    this.db.prepare('DELETE FROM lfg_posts WHERE id = ?').run(id);
  }

  joinLfg(id: string, userId: string, now: number): number {
    this.db
      .prepare(
        `INSERT INTO lfg_joins (lfg_id, user_id, created_at) VALUES (?, ?, ?)
         ON CONFLICT(lfg_id, user_id) DO NOTHING`,
      )
      .run(id, userId, now);
    return (this.db.prepare('SELECT COUNT(*) AS n FROM lfg_joins WHERE lfg_id = ?').get(id) as { n: number }).n;
  }

  // ---- skin votes ----------------------------------------------------------

  /** Only established accounts contribute to public totals; new accounts can still save their own choices. */
  private trustedUser(userId: string): string {
    return `EXISTS (SELECT 1 FROM users trust WHERE trust.id = ${userId}
      AND trust.created_at <= ${Math.floor(this.now() - DAY_MS)}
      AND NOT EXISTS (SELECT 1 FROM sanctions s WHERE s.user_id = trust.id AND s.lifted_at IS NULL AND (s.until IS NULL OR s.until > ${Math.floor(this.now())}))
      AND (EXISTS (SELECT 1 FROM posts a WHERE a.user_id = trust.id AND a.hidden = 0)
        OR EXISTS (SELECT 1 FROM comments a WHERE a.user_id = trust.id AND a.hidden = 0)
        OR EXISTS (SELECT 1 FROM skin_votes a WHERE a.user_id = trust.id)
        OR EXISTS (SELECT 1 FROM skin_reviews a WHERE a.user_id = trust.id AND a.hidden = 0)
        OR EXISTS (SELECT 1 FROM post_likes a WHERE a.user_id = trust.id)
        OR EXISTS (SELECT 1 FROM review_likes a WHERE a.user_id = trust.id)))`;
  }

  voteSkin(
    userId: string,
    skinUuid: string,
    weaponUuid: string,
    now: number,
    origin: Origin,
    authoritativeWeapon = false,
  ): boolean {
    // Without a catalog the weapon of a skin is pinned by its first vote/review so a wrong client value cannot
    // split a skin's count across weapons; with one, the catalog's weapon is stored as given.
    // The voter's country/region are captured now.
    const res = this.db
      .prepare(
        `INSERT INTO skin_votes (user_id, skin_uuid, weapon_uuid, created_at, country, region)
         VALUES (@userId, @skinUuid,
           CASE WHEN @authoritative = 1 THEN @weaponUuid ELSE
             COALESCE((SELECT weapon_uuid FROM skin_votes WHERE skin_uuid = @skinUuid LIMIT 1),
                      (SELECT weapon_uuid FROM skin_reviews WHERE skin_uuid = @skinUuid LIMIT 1),
                      @weaponUuid) END,
           @now, @country, @region)
         ON CONFLICT(user_id, skin_uuid) DO NOTHING`,
      )
      .run({
        userId,
        skinUuid,
        weaponUuid,
        now,
        country: origin.country,
        region: origin.region,
        authoritative: authoritativeWeapon ? 1 : 0,
      });
    return res.changes > 0;
  }

  unvoteSkin(userId: string, skinUuid: string): void {
    this.db.prepare('DELETE FROM skin_votes WHERE user_id = ? AND skin_uuid = ?').run(userId, skinUuid);
  }

  voteCounts(skinUuids: string[], since?: number, geo?: GeoScope): Map<string, number> {
    const out = new Map<string, number>();
    if (skinUuids.length === 0) return out;
    const params: Record<string, unknown> = {};
    const where = [`v.skin_uuid IN (${inList('s', skinUuids, params)})`, geoCondition('v', geo, params), this.trustedUser('v.user_id')];
    if (since !== undefined) {
      where.push('v.created_at >= @since');
      params.since = since;
    }
    const rows = this.db
      .prepare(`SELECT v.skin_uuid, COUNT(*) AS votes FROM skin_votes v WHERE ${and(where)} GROUP BY v.skin_uuid`)
      .all(params) as { skin_uuid: string; votes: number }[];
    for (const r of rows) out.set(r.skin_uuid, r.votes);
    return out;
  }

  userVotes(userId: string, skinUuids: string[]): Set<string> {
    if (skinUuids.length === 0) return new Set();
    const params: Record<string, unknown> = { userId };
    const rows = this.db
      .prepare(`SELECT skin_uuid FROM skin_votes WHERE user_id = @userId AND skin_uuid IN (${inList('s', skinUuids, params)})`)
      .all(params) as { skin_uuid: string }[];
    return new Set(rows.map((r) => r.skin_uuid));
  }

  topSkins(q: { weaponUuid?: string; since?: number; limit: number; geo?: GeoScope }): SkinCount[] {
    const params: Record<string, unknown> = { limit: q.limit };
    const where = [geoCondition('v', q.geo, params), this.trustedUser('v.user_id')];
    if (q.weaponUuid) {
      where.push('v.weapon_uuid = @weapon');
      params.weapon = q.weaponUuid;
    }
    if (q.since !== undefined) {
      where.push('v.created_at >= @since');
      params.since = q.since;
    }
    const cond = and(where);
    const rows = this.db
      .prepare(
        `SELECT v.skin_uuid, MIN(v.weapon_uuid) AS weapon_uuid, COUNT(*) AS votes FROM skin_votes v
         ${cond ? `WHERE ${cond}` : ''}
         GROUP BY v.skin_uuid ORDER BY votes DESC, v.skin_uuid ASC LIMIT @limit`,
      )
      .all(params) as { skin_uuid: string; weapon_uuid: string; votes: number }[];
    return rows.map((r) => ({ skinUuid: r.skin_uuid, weaponUuid: r.weapon_uuid, votes: r.votes }));
  }

  canonicalizeSkins(resolve: (uuid: string) => { skinUuid: string; weaponUuid: string } | null): CanonicalizeResult {
    const out: CanonicalizeResult = { votesRewritten: 0, votesMerged: 0, reviewsRewritten: 0, reviewsMerged: 0, weaponsFixed: 0 };
    this.db.transaction(() => {
      const uuids = this.db
        .prepare('SELECT skin_uuid FROM skin_votes UNION SELECT skin_uuid FROM skin_reviews')
        .all() as { skin_uuid: string }[];
      for (const { skin_uuid: uuid } of uuids) {
        const fresh = resolve(uuid);
        if (fresh) this.db.prepare('INSERT OR REPLACE INTO skin_aliases VALUES (?, ?, ?)').run(uuid, fresh.skinUuid, fresh.weaponUuid);
        const saved = this.db.prepare('SELECT skin_uuid AS skinUuid, weapon_uuid AS weaponUuid FROM skin_aliases WHERE alias_uuid = ?').get(uuid) as { skinUuid: string; weaponUuid: string } | undefined;
        const ref = fresh ?? saved;
        if (!ref) continue;
        if (ref.skinUuid !== uuid) {
          // Votes: rows that would collide with the user's canonical vote stay behind and are dropped.
          this.db.prepare(`UPDATE skin_votes AS base SET
            country = CASE WHEN (SELECT created_at FROM skin_votes WHERE skin_uuid = @alias AND user_id = base.user_id) < base.created_at
              THEN (SELECT country FROM skin_votes WHERE skin_uuid = @alias AND user_id = base.user_id) ELSE base.country END,
            region = CASE WHEN (SELECT created_at FROM skin_votes WHERE skin_uuid = @alias AND user_id = base.user_id) < base.created_at
              THEN (SELECT region FROM skin_votes WHERE skin_uuid = @alias AND user_id = base.user_id) ELSE base.region END,
            created_at = MIN(base.created_at,
            (SELECT alias.created_at FROM skin_votes alias WHERE alias.skin_uuid = @alias AND alias.user_id = base.user_id))
            WHERE base.skin_uuid = @base AND EXISTS (SELECT 1 FROM skin_votes alias WHERE alias.skin_uuid = @alias AND alias.user_id = base.user_id)`)
            .run({ alias: uuid, base: ref.skinUuid });
          out.votesRewritten += this.db
            .prepare('UPDATE OR IGNORE skin_votes SET skin_uuid = ?, weapon_uuid = ? WHERE skin_uuid = ?')
            .run(ref.skinUuid, ref.weaponUuid, uuid).changes;
          out.votesMerged += this.db.prepare('DELETE FROM skin_votes WHERE skin_uuid = ?').run(uuid).changes;
          // Reviews: one per user and skin; on a collision the most recently edited one survives.
          const aliasRows = this.db
            .prepare('SELECT * FROM skin_reviews WHERE skin_uuid = ?')
            .all(uuid) as ReviewRow[];
          for (const row of aliasRows) {
            const other = this.db
              .prepare('SELECT * FROM skin_reviews WHERE user_id = ? AND skin_uuid = ?')
              .get(row.user_id, ref.skinUuid) as ReviewRow | undefined;
            if (other) {
              out.reviewsMerged++;
              const keep = row.updated_at > other.updated_at ? row : other;
              const drop = keep === row ? other : row;
              this.db.prepare(`INSERT OR IGNORE INTO review_likes (review_id, user_id, created_at)
                SELECT ?, user_id, created_at FROM review_likes WHERE review_id = ?`).run(keep.id, drop.id);
              this.db.prepare(`INSERT OR IGNORE INTO reports (target_type, target_id, reporter_id, reason, created_at)
                SELECT target_type, ?, reporter_id, reason, created_at FROM reports WHERE target_type = 'review' AND target_id = ?`).run(keep.id, drop.id);
              this.db.prepare("DELETE FROM reports WHERE target_type = 'review' AND target_id = ?").run(drop.id);
              const earliest = row.created_at < other.created_at ? row : other;
              this.db.prepare(`UPDATE skin_reviews SET created_at = ?, country = ?, region = ?, hidden = ?, hidden_reason = ?,
                like_count = (SELECT COUNT(*) FROM review_likes WHERE review_id = ?) WHERE id = ?`)
                .run(earliest.created_at, earliest.country, earliest.region, Math.max(row.hidden, other.hidden),
                  row.hidden_reason === 'moderator' || other.hidden_reason === 'moderator' ? 'moderator' : row.hidden_reason ?? other.hidden_reason,
                  keep.id, keep.id);
              this.db.prepare('DELETE FROM skin_reviews WHERE id = ?').run(drop.id);
              if (keep === other) continue;
            } else {
              out.reviewsRewritten++;
            }
            this.db
              .prepare('UPDATE skin_reviews SET skin_uuid = ?, weapon_uuid = ? WHERE id = ?')
              .run(ref.skinUuid, ref.weaponUuid, row.id);
          }
        }
        // A skin filed under the wrong weapon (a client sent a wrong weaponUuid with the first vote).
        for (const table of ['skin_votes', 'skin_reviews']) {
          out.weaponsFixed += this.db
            .prepare(`UPDATE ${table} SET weapon_uuid = ? WHERE skin_uuid = ? AND weapon_uuid <> ?`)
            .run(ref.weaponUuid, ref.skinUuid, ref.weaponUuid).changes;
        }
      }
    })();
    return out;
  }

  skinAlias(uuid: string): { skinUuid: string; weaponUuid: string } | null {
    return this.db.prepare(`SELECT skin_uuid AS skinUuid, weapon_uuid AS weaponUuid FROM skin_aliases
      WHERE alias_uuid = @id OR skin_uuid = @id ORDER BY (alias_uuid = @id) DESC LIMIT 1`)
      .get({ id: uuid.toLowerCase() }) as { skinUuid: string; weaponUuid: string } | undefined ?? null;
  }

  skinWeapon(skinUuid: string): string | null {
    const row = this.db
      .prepare(
        `SELECT COALESCE((SELECT weapon_uuid FROM skin_votes WHERE skin_uuid = @s LIMIT 1),
                         (SELECT weapon_uuid FROM skin_reviews WHERE skin_uuid = @s LIMIT 1)) AS w`,
      )
      .get({ s: skinUuid }) as { w: string | null };
    return row.w;
  }

  /** Visible reviews (alias r) of a period / scope / weapon. */
  private reviewFilters(
    q: { weaponUuid?: string; since?: number; geo?: GeoScope },
    params: Record<string, unknown>,
  ): string {
    const where = ['r.hidden = 0', geoCondition('r', q.geo, params), this.trustedUser('r.user_id')];
    if (q.weaponUuid) {
      where.push('r.weapon_uuid = @weapon');
      params.weapon = q.weaponUuid;
    }
    if (q.since !== undefined) {
      where.push('r.created_at >= @since');
      params.since = q.since;
    }
    return and(where);
  }

  topRatedSkins(q: {
    weaponUuid?: string;
    since?: number;
    limit: number;
    c: number;
    minCount: number;
    geo?: GeoScope;
  }) {
    // m = mean of all visible ratings of the same period and scope (not restricted by weapon).
    const meanParams: Record<string, unknown> = {};
    const meanWhere = this.reviewFilters({ since: q.since, geo: q.geo }, meanParams);
    const { m } = this.db.prepare(`SELECT AVG(r.rating) AS m FROM skin_reviews r WHERE ${meanWhere}`).get(meanParams) as {
      m: number | null;
    };
    if (m === null) return [];
    const params: Record<string, unknown> = { limit: q.limit, c: q.c, m, minCount: q.minCount };
    const where = this.reviewFilters(q, params);
    const rows = this.db
      .prepare(
        `SELECT r.skin_uuid, MIN(r.weapon_uuid) AS weapon_uuid FROM skin_reviews r WHERE ${where}
         GROUP BY r.skin_uuid HAVING COUNT(*) >= @minCount
         ORDER BY (@c * @m + SUM(r.rating)) * 1.0 / (@c + COUNT(*)) DESC, COUNT(*) DESC, r.skin_uuid ASC
         LIMIT @limit`,
      )
      .all(params) as { skin_uuid: string; weapon_uuid: string }[];
    return rows.map((r) => ({ skinUuid: r.skin_uuid, weaponUuid: r.weapon_uuid }));
  }

  topReviewedSkins(q: { weaponUuid?: string; since?: number; limit: number; geo?: GeoScope }) {
    const params: Record<string, unknown> = { limit: q.limit };
    const where = this.reviewFilters(q, params);
    const rows = this.db
      .prepare(
        `SELECT r.skin_uuid, MIN(r.weapon_uuid) AS weapon_uuid FROM skin_reviews r WHERE ${where}
         GROUP BY r.skin_uuid
         ORDER BY SUM(CASE WHEN r.body <> '' THEN 1 ELSE 0 END) DESC, COUNT(*) DESC, r.skin_uuid ASC
         LIMIT @limit`,
      )
      .all(params) as { skin_uuid: string; weapon_uuid: string }[];
    return rows.map((r) => ({ skinUuid: r.skin_uuid, weaponUuid: r.weapon_uuid }));
  }

  // ---- skin reviews ----------------------------------------------------------

  upsertReview(r: {
    userId: string;
    skinUuid: string;
    weaponUuid: string;
    rating: number;
    body: string;
    now: number;
    origin: Origin;
    language: string | null;
    updateLanguage: boolean;
    authoritativeWeapon?: boolean;
  }) {
    return this.db.transaction(() => {
      const existing = this.db
        .prepare('SELECT id FROM skin_reviews WHERE user_id = ? AND skin_uuid = ?')
        .get(r.userId, r.skinUuid) as { id: string } | undefined;
      if (existing) {
        // Editing keeps id, likes, created_at, the hidden flag (editing cannot un-hide) and the
        // creation-time origin; the text language changes only when the client sends one.
        this.db
          .prepare(
            `UPDATE skin_reviews SET rating = @rating, body = @body, updated_at = @now
             ${r.updateLanguage ? ', language = @language' : ''} WHERE id = @id`,
          )
          .run({
            rating: r.rating,
            body: r.body,
            now: r.now,
            id: existing.id,
            ...(r.updateLanguage ? { language: r.language } : {}),
          });
        return existing.id;
      }
      const id = crypto.randomUUID();
      this.db
        .prepare(
          `INSERT INTO skin_reviews (id, user_id, skin_uuid, weapon_uuid, rating, body, created_at, updated_at,
             country, region, language)
           VALUES (@id, @userId, @skinUuid, @weaponUuid, @rating, @body, @now, @now, @country, @region, @language)`,
        )
        .run({
          id,
          userId: r.userId,
          skinUuid: r.skinUuid,
          weaponUuid: r.authoritativeWeapon ? r.weaponUuid : (this.skinWeapon(r.skinUuid) ?? r.weaponUuid),
          rating: r.rating,
          body: r.body,
          now: r.now,
          country: r.origin.country,
          region: r.origin.region,
          language: r.language,
        });
      return id;
    })();
  }

  getReview(id: string, viewerId: string): ReviewView | null {
    return (
      (this.db.prepare(`${REVIEW_SELECT} WHERE r.id = @id`).get({ id, viewer: viewerId }) as ReviewView | undefined) ??
      null
    );
  }

  getUserReview(userId: string, skinUuid: string): ReviewView | null {
    return (
      (this.db
        .prepare(`${REVIEW_SELECT} WHERE r.user_id = @viewer AND r.skin_uuid = @skin`)
        .get({ viewer: userId, skin: skinUuid }) as ReviewView | undefined) ?? null
    );
  }

  listReviews(q: {
    skinUuid: string;
    sort: 'new' | 'top';
    cursor?: Cursor;
    limit: number;
    viewerId: string;
    geo?: GeoScope;
    languages?: string[];
  }): ReviewView[] {
    const params: Record<string, unknown> = { skin: q.skinUuid, viewer: q.viewerId, limit: q.limit + 1 };
    const where = ['r.skin_uuid = @skin', 'r.hidden = 0', geoCondition('r', q.geo, params)];
    if (q.languages && q.languages.length > 0) {
      where.push(`r.language IN (${inList('lang', q.languages, params)})`);
    }
    let order: string;
    if (q.sort === 'top') {
      order = 'r.like_count DESC, r.created_at DESC, r.id DESC';
      if (q.cursor) {
        where.push(`(r.like_count < @cLikes OR (r.like_count = @cLikes AND
          (r.created_at < @cAt OR (r.created_at = @cAt AND r.id < @cId))))`);
        params.cLikes = q.cursor.likes ?? 0;
        params.cAt = q.cursor.createdAt;
        params.cId = q.cursor.id;
      }
    } else {
      order = 'r.created_at DESC, r.id DESC';
      if (q.cursor) {
        where.push('(r.created_at < @cAt OR (r.created_at = @cAt AND r.id < @cId))');
        params.cAt = q.cursor.createdAt;
        params.cId = q.cursor.id;
      }
    }
    return this.db
      .prepare(`${REVIEW_SELECT} WHERE ${and(where)} ORDER BY ${order} LIMIT @limit`)
      .all(params) as ReviewView[];
  }

  deleteReview(id: string): void {
    this.db.prepare('DELETE FROM skin_reviews WHERE id = ?').run(id);
  }

  deleteUserReview(userId: string, skinUuid: string): boolean {
    return (
      this.db.prepare('DELETE FROM skin_reviews WHERE user_id = ? AND skin_uuid = ?').run(userId, skinUuid).changes > 0
    );
  }

  setReviewLike(reviewId: string, userId: string, liked: boolean, now: number): number {
    return this.db.transaction(() => {
      const changes = liked
        ? this.db
            .prepare(
              `INSERT INTO review_likes (review_id, user_id, created_at) VALUES (?, ?, ?)
               ON CONFLICT(review_id, user_id) DO NOTHING`,
            )
            .run(reviewId, userId, now).changes
        : this.db.prepare('DELETE FROM review_likes WHERE review_id = ? AND user_id = ?').run(reviewId, userId).changes;
      if (changes > 0) {
        this.db
          .prepare('UPDATE skin_reviews SET like_count = MAX(0, like_count + ?) WHERE id = ?')
          .run(liked ? 1 : -1, reviewId);
      }
      const row = this.db.prepare('SELECT like_count FROM skin_reviews WHERE id = ?').get(reviewId) as
        | { like_count: number }
        | undefined;
      return row?.like_count ?? 0;
    })();
  }

  ratingStats(skinUuids: string[], since?: number, geo?: GeoScope): Map<string, RatingStats> {
    const out = new Map<string, RatingStats>();
    if (skinUuids.length === 0) return out;
    const params: Record<string, unknown> = {};
    const where = [
      this.reviewFilters({ since, geo }, params),
      `r.skin_uuid IN (${inList('s', skinUuids, params)})`,
    ];
    const rows = this.db
      .prepare(
        `SELECT r.skin_uuid, COUNT(*) AS n, SUM(r.rating) AS s, SUM(CASE WHEN r.body <> '' THEN 1 ELSE 0 END) AS rc
         FROM skin_reviews r WHERE ${and(where)} GROUP BY r.skin_uuid`,
      )
      .all(params) as { skin_uuid: string; n: number; s: number; rc: number }[];
    for (const r of rows) out.set(r.skin_uuid, { count: r.n, sum: r.s, reviewCount: r.rc });
    return out;
  }

  ratingDistribution(skinUuid: string, geo?: GeoScope): [number, number, number, number, number] {
    const dist: [number, number, number, number, number] = [0, 0, 0, 0, 0];
    const params: Record<string, unknown> = { skin: skinUuid };
    const where = [this.reviewFilters({ geo }, params), 'r.skin_uuid = @skin'];
    const rows = this.db
      .prepare(`SELECT r.rating, COUNT(*) AS n FROM skin_reviews r WHERE ${and(where)} GROUP BY r.rating`)
      .all(params) as { rating: number; n: number }[];
    for (const r of rows) if (r.rating >= 1 && r.rating <= 5) dist[r.rating - 1] = r.n;
    return dist;
  }

  // ---- posts ---------------------------------------------------------------

  insertPost(p: Omit<PostRow, 'hidden_reason'>): void {
    this.db.transaction(() => {
      this.db
        .prepare(
          `INSERT INTO posts (id, user_id, kind, body, media, payload, hidden, created_at, country, region, language)
           VALUES (@id, @user_id, @kind, @body, @media, @payload, @hidden, @created_at, @country, @region, @language)`,
        )
        .run(p);
      // The files of a new post are attached to it in the same transaction (they stop being orphans).
      const keys = parseKeys(p.media);
      if (keys.length > 0) {
        const params: Record<string, unknown> = { post: p.id, user: p.user_id };
        const changed = this.db
          .prepare(`UPDATE media SET post_id = @post WHERE user_id = @user AND post_id IS NULL AND status = 'active' AND key IN (${inList('k', keys, params)})`)
          .run(params).changes;
        if (changed !== keys.length) throw reasonError('invalid_input', 'media_unavailable');
      }
    })();
  }

  getPost(id: string, viewerId: string): PostView | null {
    return (
      (this.db.prepare(`${POST_SELECT} WHERE p.id = @id`).get({ id, viewer: viewerId }) as
        | PostView
        | undefined) ?? null
    );
  }

  listPosts(q: {
    kind?: string;
    cursor?: Cursor;
    limit: number;
    viewerId: string;
    geo?: GeoScope;
    languages?: string[];
    /** Only this author's posts, hidden ones included (their own list). */
    ownOf?: string;
  }): PostView[] {
    const params: Record<string, unknown> = { viewer: q.viewerId, limit: q.limit + 1 };
    const where = [q.ownOf ? 'p.user_id = @ownOf' : 'p.hidden = 0', geoCondition('p', q.geo, params)];
    if (q.ownOf) params.ownOf = q.ownOf;
    if (q.kind) {
      where.push('p.kind = @kind');
      params.kind = q.kind;
    }
    if (q.languages && q.languages.length > 0) {
      where.push(`p.language IN (${inList('lang', q.languages, params)})`);
    }
    if (q.cursor) {
      where.push('(p.created_at < @cAt OR (p.created_at = @cAt AND p.id < @cId))');
      params.cAt = q.cursor.createdAt;
      params.cId = q.cursor.id;
    }
    return this.db
      .prepare(`${POST_SELECT} WHERE ${and(where)} ORDER BY p.created_at DESC, p.id DESC LIMIT @limit`)
      .all(params) as PostView[];
  }

  deletePost(id: string): void {
    // post_likes and comments cascade.
    this.db.prepare('DELETE FROM posts WHERE id = ?').run(id);
  }

  setLike(postId: string, userId: string, liked: boolean, now: number): void {
    if (liked) {
      this.db
        .prepare(
          `INSERT INTO post_likes (post_id, user_id, created_at) VALUES (?, ?, ?)
           ON CONFLICT(post_id, user_id) DO NOTHING`,
        )
        .run(postId, userId, now);
    } else {
      this.db.prepare('DELETE FROM post_likes WHERE post_id = ? AND user_id = ?').run(postId, userId);
    }
  }

  likeCount(postId: string): number {
    return (this.db.prepare('SELECT COUNT(*) AS n FROM post_likes WHERE post_id = ?').get(postId) as { n: number })
      .n;
  }

  // ---- comments --------------------------------------------------------------

  insertComment(c: Omit<CommentRow, 'hidden_reason'>): void {
    this.db
      .prepare(
        `INSERT INTO comments (id, post_id, user_id, body, hidden, created_at, country, region, language)
         VALUES (@id, @post_id, @user_id, @body, @hidden, @created_at, @country, @region, @language)`,
      )
      .run(c);
  }

  getComment(id: string) {
    return (
      (this.db
        .prepare(`SELECT c.*, ${AUTHOR_SELECT} FROM comments c JOIN users u ON u.id = c.user_id WHERE c.id = ?`)
        .get(id) as (CommentRow & AuthorCols) | undefined) ?? null
    );
  }

  listComments(q: { postId: string; cursor?: Cursor; limit: number }) {
    const where = ['c.post_id = @postId', 'c.hidden = 0'];
    const params: Record<string, unknown> = { postId: q.postId, limit: q.limit + 1 };
    if (q.cursor) {
      where.push('(c.created_at > @cAt OR (c.created_at = @cAt AND c.id > @cId))');
      params.cAt = q.cursor.createdAt;
      params.cId = q.cursor.id;
    }
    return this.db
      .prepare(
        `SELECT c.*, ${AUTHOR_SELECT} FROM comments c JOIN users u ON u.id = c.user_id
         WHERE ${where.join(' AND ')} ORDER BY c.created_at ASC, c.id ASC LIMIT @limit`,
      )
      .all(params) as (CommentRow & AuthorCols)[];
  }

  deleteComment(id: string): void {
    this.db.prepare('DELETE FROM comments WHERE id = ?').run(id);
  }

  // ---- communities -----------------------------------------------------------

  communities(since: number): CommunityActivity[] {
    return this.db
      .prepare(
        `WITH
           p AS (SELECT country, user_id FROM posts
                 WHERE created_at >= @since AND hidden = 0 AND country IS NOT NULL),
           l AS (SELECT country, user_id FROM lfg_posts
                 WHERE created_at >= @since AND hidden = 0 AND country IS NOT NULL),
           pc AS (SELECT country, COUNT(*) AS posts FROM p GROUP BY country),
           lc AS (SELECT country, COUNT(*) AS lfg FROM l GROUP BY country),
           ac AS (SELECT country, COUNT(DISTINCT user_id) AS authors
                  FROM (SELECT country, user_id FROM p UNION ALL SELECT country, user_id FROM l)
                  GROUP BY country)
         SELECT ac.country AS country, COALESCE(pc.posts, 0) AS posts, ac.authors AS authors,
                COALESCE(lc.lfg, 0) AS lfg
         FROM ac LEFT JOIN pc ON pc.country = ac.country LEFT JOIN lc ON lc.country = ac.country
         ORDER BY posts DESC, lfg DESC, authors DESC, country ASC`,
      )
      .all({ since }) as CommunityActivity[];
  }

  // ---- reports -------------------------------------------------------------

  private static readonly TARGET_TABLE: Record<ReportTarget, string> = {
    post: 'posts',
    comment: 'comments',
    lfg: 'lfg_posts',
    review: 'skin_reviews',
  };

  reportTargetOwner(type: ReportTarget, id: string): string | null {
    const table = SqliteRepo.TARGET_TABLE[type];
    const row = this.db.prepare(`SELECT user_id FROM ${table} WHERE id = ?`).get(id) as
      | { user_id: string }
      | undefined;
    return row?.user_id ?? null;
  }

  /**
   * Reporters of a target whose report counts toward hiding: an established account (at least as old as
   * `cutoff` says) that has done something on the service (post, comment, review, vote, like).
   */
  private eligibleReporters(type: ReportTarget, targetId: string, cutoff: number): number {
    return (
      this.db
        .prepare(
          `SELECT COUNT(*) AS n FROM reports r JOIN users u ON u.id = r.reporter_id
           WHERE r.target_type = @type AND r.target_id = @id AND u.created_at <= @cutoff AND (
             EXISTS (SELECT 1 FROM posts x WHERE x.user_id = u.id) OR
             EXISTS (SELECT 1 FROM comments x WHERE x.user_id = u.id) OR
             EXISTS (SELECT 1 FROM skin_reviews x WHERE x.user_id = u.id) OR
             EXISTS (SELECT 1 FROM skin_votes x WHERE x.user_id = u.id) OR
             EXISTS (SELECT 1 FROM post_likes x WHERE x.user_id = u.id) OR
             EXISTS (SELECT 1 FROM review_likes x WHERE x.user_id = u.id))`,
        )
        .get({ type, id: targetId, cutoff }) as { n: number }
    ).n;
  }

  /** Confirmed reports earn one extra point; no reporter may auto-hide more than three items per UTC day. */
  private reportWeights(type: ReportTarget, id: string, now: number, minAge: number): { id: string; weight: number }[] {
    const confirmed = Object.entries(SqliteRepo.TARGET_TABLE).map(([kind, table]) =>
      `EXISTS (SELECT 1 FROM reports old JOIN ${table} t ON t.id = old.target_id
        WHERE old.target_type = '${kind}' AND old.reporter_id = u.id AND t.hidden_reason = 'moderator')`).join(' OR ');
    return this.db.prepare(`SELECT u.id, 1 + CASE WHEN ${confirmed} THEN 1 ELSE 0 END AS weight
      FROM reports r JOIN users u ON u.id = r.reporter_id
      WHERE r.target_type = @type AND r.target_id = @id AND u.created_at <= @cutoff
        AND u.id <> COALESCE((SELECT user_id FROM ${SqliteRepo.TARGET_TABLE[type]} WHERE id = @id), '')
        AND ${this.trustedUser('u.id')}
        AND (SELECT COUNT(*) FROM moderation_audit a WHERE a.action = 'report-hide' AND a.user_id = u.id AND a.at >= @day) < 3`)
      .all({ type, id, cutoff: now - minAge, day: Math.floor(now / DAY_MS) * DAY_MS }) as { id: string; weight: number }[];
  }

  addReport(
    r: { type: ReportTarget; targetId: string; reporterId: string; reason: string; now: number },
    threshold: number,
    minReporterAgeMs: number,
  ): ReportOutcome {
    const table = SqliteRepo.TARGET_TABLE[r.type];
    return this.db.transaction(() => {
      this.db
        .prepare(
          `INSERT INTO reports (target_type, target_id, reporter_id, reason, created_at) VALUES (?, ?, ?, ?, ?)
           ON CONFLICT(target_type, target_id, reporter_id) DO NOTHING`,
        )
        .run(r.type, r.targetId, r.reporterId, r.reason, r.now);
      const count = (
        this.db
          .prepare('SELECT COUNT(*) AS n FROM reports WHERE target_type = ? AND target_id = ?')
          .get(r.type, r.targetId) as { n: number }
      ).n;
      const reporters = this.reportWeights(r.type, r.targetId, r.now, minReporterAgeMs);
      const eligible = reporters.reduce((sum, reporter) => sum + reporter.weight, 0);
      if (r.type === 'review') {
        this.db.prepare('UPDATE skin_reviews SET report_count = ? WHERE id = ?').run(eligible, r.targetId);
      }
      let newlyHidden = false;
      if (eligible >= threshold) {
        newlyHidden =
          this.db
            .prepare(`UPDATE ${table} SET hidden = 1, hidden_reason = 'reports' WHERE id = ? AND hidden = 0`)
            .run(r.targetId).changes > 0;
        if (newlyHidden) for (const reporter of reporters) this.addAudit({ at: r.now, action: 'report-hide', userId: reporter.id });
      }
      return { count, eligible, newlyHidden };
    })();
  }

  sweepReports(olderThan: number): SweepCounts {
    const reportsExpired = this.db.prepare('DELETE FROM reports WHERE created_at < ?').run(olderThan).changes;
    let reportsOrphaned = 0;
    for (const [type, table] of Object.entries(SqliteRepo.TARGET_TABLE)) {
      reportsOrphaned += this.db
        .prepare(`DELETE FROM reports WHERE target_type = ? AND target_id NOT IN (SELECT id FROM ${table})`)
        .run(type).changes;
    }
    return { reportsExpired, reportsOrphaned };
  }

  // ---- media ---------------------------------------------------------------

  insertMedia(m: Pick<MediaRow, 'key' | 'user_id' | 'content_type' | 'size' | 'created_at'>, limits?: { user: number; total: number }): void {
    this.db.transaction(() => {
      if (limits && this.mediaBytes(m.user_id) + m.size > limits.user) throw reasonError('invalid_input', 'quota_exceeded', { maxMb: Math.round(limits.user / 1048576) });
      if (limits && this.mediaBytes() + m.size > limits.total) throw reasonError('storage_full', 'storage_full');
      this.db
      .prepare(
        `INSERT INTO media (key, user_id, content_type, size, created_at)
         VALUES (@key, @user_id, @content_type, @size, @created_at)`,
      )
      .run(m);
    })();
  }

  getMediaMany(keys: string[]): MediaRow[] {
    if (keys.length === 0) return [];
    const params: Record<string, unknown> = {};
    return this.db.prepare(`SELECT * FROM media WHERE key IN (${inList('k', keys, params)})`).all(params) as MediaRow[];
  }

  getMedia(key: string): MediaRow | null {
    return (this.db.prepare('SELECT * FROM media WHERE key = ?').get(key) as MediaRow | undefined) ?? null;
  }

  mediaBytes(userId?: string): number {
    const row = (
      userId === undefined
        ? this.db.prepare('SELECT COALESCE(SUM(size), 0) AS n FROM media').get()
        : this.db.prepare('SELECT COALESCE(SUM(size), 0) AS n FROM media WHERE user_id = ?').get(userId)
    ) as { n: number };
    return row.n;
  }

  mediaOfUser(userId: string): MediaRow[] {
    return this.db.prepare('SELECT * FROM media WHERE user_id = ? ORDER BY created_at, key').all(userId) as MediaRow[];
  }

  mediaOrphans(cutoff: number): MediaRow[] {
    return this.db
      .prepare(`SELECT * FROM media WHERE (post_id IS NULL AND status = 'active' AND created_at < ?) OR
        (post_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM posts WHERE posts.id = media.post_id))`)
      .all(cutoff) as MediaRow[];
  }

  mediaQuarantineDue(cutoff: number): MediaRow[] {
    return this.db
      .prepare(`SELECT * FROM media WHERE status = 'quarantined' AND quarantined_at < ?`)
      .all(cutoff) as MediaRow[];
  }

  mediaOfHiddenPosts(): MediaRow[] {
    return this.db
      .prepare(`SELECT m.* FROM media m JOIN posts p ON p.id = m.post_id WHERE p.hidden = 1 AND m.status = 'active'`)
      .all() as MediaRow[];
  }

  setMediaQuarantined(keys: string[], now: number): void {
    if (keys.length === 0) return;
    const params: Record<string, unknown> = { now };
    this.db
      .prepare(
        `UPDATE media SET status = 'quarantined', quarantined_at = @now WHERE key IN (${inList('k', keys, params)})`,
      )
      .run(params);
  }

  setMediaActive(keys: string[]): void {
    if (keys.length === 0) return;
    const params: Record<string, unknown> = {};
    this.db
      .prepare(`UPDATE media SET status = 'active', quarantined_at = NULL WHERE key IN (${inList('k', keys, params)})`)
      .run(params);
  }

  deleteMediaRows(keys: string[]): void {
    if (keys.length === 0) return;
    const params: Record<string, unknown> = {};
    this.db.prepare(`DELETE FROM media WHERE key IN (${inList('k', keys, params)})`).run(params);
  }

  // ---- account data rights -----------------------------------------------------

  accountData(userId: string): AccountData | null {
    const user = this.getUser(userId);
    if (!user) return null;
    const all = <T>(sql: string) => this.db.prepare(sql).all(userId) as T[];
    return {
      user,
      posts: all<PostRow>('SELECT * FROM posts WHERE user_id = ? ORDER BY created_at, id'),
      comments: all<CommentRow>('SELECT * FROM comments WHERE user_id = ? ORDER BY created_at, id'),
      reviews: all<ReviewRow>('SELECT * FROM skin_reviews WHERE user_id = ? ORDER BY created_at, id'),
      postLikes: all('SELECT post_id, created_at FROM post_likes WHERE user_id = ? ORDER BY created_at, post_id'),
      reviewLikes: all(
        'SELECT review_id, created_at FROM review_likes WHERE user_id = ? ORDER BY created_at, review_id',
      ),
      votes: all(
        'SELECT skin_uuid, weapon_uuid, country, region, created_at FROM skin_votes WHERE user_id = ? ORDER BY created_at, skin_uuid',
      ),
      lfgPosts: all<LfgRow>('SELECT * FROM lfg_posts WHERE user_id = ? ORDER BY created_at, id'),
      lfgJoins: all('SELECT lfg_id, created_at FROM lfg_joins WHERE user_id = ? ORDER BY created_at, lfg_id'),
      reportsFiled: all(
        'SELECT target_type, target_id, reason, created_at FROM reports WHERE reporter_id = ? ORDER BY created_at, target_id',
      ),
      media: this.mediaOfUser(userId),
      sanctions: all<SanctionRow>('SELECT * FROM sanctions WHERE user_id = ? ORDER BY created_at, id'),
      moderationLog: all<AuditRow>('SELECT * FROM moderation_audit WHERE user_id = ? ORDER BY at, id'),
      requestKeys: all('SELECT id, body, status, expires_at FROM request_keys WHERE user_id = ? ORDER BY expires_at, id'),
    };
  }

  deleteAccountRows(userId: string): void {
    this.db.transaction(() => {
      this.db.prepare(`INSERT OR REPLACE INTO revoked_accounts (user_id, epoch, expires_at)
        SELECT id, session_epoch + 1, ? FROM users WHERE id = ?`).run(this.now() + 30 * DAY_MS, userId);
      // Reports about the user's content go with the content.
      const owned: [string, string][] = [
        ['post', 'posts'],
        ['comment', 'comments'],
        ['review', 'skin_reviews'],
        ['lfg', 'lfg_posts'],
      ];
      for (const [type, table] of owned) {
        this.db
          .prepare(`DELETE FROM reports WHERE target_type = ? AND target_id IN (SELECT id FROM ${table} WHERE user_id = ?)`)
          .run(type, userId);
      }
      // ... including reports about other people's comments on the user's posts (they cascade away).
      this.db
        .prepare(
          `DELETE FROM reports WHERE target_type = 'comment' AND target_id IN
             (SELECT c.id FROM comments c JOIN posts p ON p.id = c.post_id WHERE p.user_id = ?)`,
        )
        .run(userId);
      // Reports the user filed stay (they may have hidden content) but lose their identity and free text.
      this.db
        .prepare(`UPDATE reports SET reporter_id = 'anon-' || lower(hex(randomblob(8))), reason = '' WHERE reporter_id = ?`)
        .run(userId);
      // rate_limits rows are NOT deleted: they hold only the id and a count, expire on their own (swept after a
      // day) and deleting them would let delete + sign-in reset every per-user limit (CS-37).
      // The denormalised like counters of other people's reviews must not keep counting this user's likes
      // (the like rows themselves cascade away with the user).
      this.db
        .prepare(
          `UPDATE skin_reviews SET like_count = MAX(0, like_count - 1)
           WHERE id IN (SELECT review_id FROM review_likes WHERE user_id = ?)`,
        )
        .run(userId);
      // Posts (+ comments, likes), comments, reviews (+ likes), likes, votes, LFG posts (+ joins) and
      // media rows cascade from the user row.
      this.db.prepare('DELETE FROM users WHERE id = ?').run(userId);
    })();
  }

  restoreTarget(type: ReportTarget, id: string): boolean {
    const table = SqliteRepo.TARGET_TABLE[type];
    return this.db.transaction(() => {
      const changed = this.db.prepare(`UPDATE ${table} SET hidden = 0, hidden_reason = NULL WHERE id = ?`).run(id).changes;
      if (changed === 0) return false;
      this.db.prepare('DELETE FROM reports WHERE target_type = ? AND target_id = ?').run(type, id);
      if (type === 'review') this.db.prepare('UPDATE skin_reviews SET report_count = 0 WHERE id = ?').run(id);
      return true;
    })();
  }

  hideTarget(type: ReportTarget, id: string): { ownerId: string; newlyHidden: boolean } | null {
    const table = SqliteRepo.TARGET_TABLE[type];
    return this.db.transaction(() => {
      const row = this.db.prepare(`SELECT user_id, hidden FROM ${table} WHERE id = ?`).get(id) as
        | { user_id: string; hidden: number }
        | undefined;
      if (!row) return null;
      // A moderator's decision replaces the automatic reason (the author is told which one applies).
      this.db.prepare(`UPDATE ${table} SET hidden = 1, hidden_reason = 'moderator' WHERE id = ?`).run(id);
      return { ownerId: row.user_id, newlyHidden: row.hidden === 0 };
    })();
  }

  deleteTarget(type: ReportTarget, id: string): { ownerId: string; mediaKeys: string[] } | null {
    const table = SqliteRepo.TARGET_TABLE[type];
    return this.db.transaction(() => {
      const row = this.db.prepare(`SELECT * FROM ${table} WHERE id = ?`).get(id) as
        | { user_id: string; media?: string }
        | undefined;
      if (!row) return null;
      const mediaKeys = type === 'post' ? parseKeys(row.media ?? '[]') : [];
      // Reports about the item, and about comments that go away with a post.
      if (type === 'post') {
        this.db
          .prepare(
            `DELETE FROM reports WHERE target_type = 'comment' AND target_id IN (SELECT id FROM comments WHERE post_id = ?)`,
          )
          .run(id);
      }
      this.db.prepare('DELETE FROM reports WHERE target_type = ? AND target_id = ?').run(type, id);
      if (type === 'post') {
        // The files go with the post: their rows are removed here, the files by the caller.
        if (mediaKeys.length > 0) {
          const params: Record<string, unknown> = {};
          this.db.prepare(`DELETE FROM media WHERE key IN (${inList('k', mediaKeys, params)})`).run(params);
        }
      }
      this.db.prepare(`DELETE FROM ${table} WHERE id = ?`).run(id); // likes / comments / joins cascade
      return { ownerId: row.user_id, mediaKeys };
    })();
  }

  reportedTargets(q: { limit: number; now: number; minReporterAgeMs: number }): ReportedTarget[] {
    const groups = this.db
      .prepare(
        `SELECT target_type AS type, target_id AS targetId, COUNT(*) AS reports, MAX(created_at) AS lastAt
         FROM reports GROUP BY target_type, target_id ORDER BY lastAt DESC, target_id LIMIT ?`,
      )
      .all(q.limit) as { type: ReportTarget; targetId: string; reports: number; lastAt: number }[];
    return groups.map((g) => {
      const table = SqliteRepo.TARGET_TABLE[g.type];
      const textCol = g.type === 'lfg' ? 'note' : 'body';
      const row = this.db
        .prepare(`SELECT user_id, hidden, hidden_reason, substr(COALESCE(${textCol}, ''), 1, 80) AS excerpt FROM ${table} WHERE id = ?`)
        .get(g.targetId) as { user_id: string; hidden: number; hidden_reason: string | null; excerpt: string } | undefined;
      const reasons = this.db
        .prepare('SELECT DISTINCT reason FROM reports WHERE target_type = ? AND target_id = ? AND reason <> \'\' LIMIT 5')
        .all(g.type, g.targetId) as { reason: string }[];
      return {
        type: g.type,
        targetId: g.targetId,
        reports: g.reports,
        eligible: this.eligibleReporters(g.type, g.targetId, q.now - q.minReporterAgeMs),
        lastAt: g.lastAt,
        reasons: reasons.map((r) => r.reason),
        ownerId: row?.user_id ?? null,
        hidden: row?.hidden === 1,
        hiddenReason: row?.hidden_reason ?? null,
        excerpt: row?.excerpt ?? '',
      };
    });
  }

  hiddenItems(limit: number): HiddenItem[] {
    return (
      this.db
        .prepare(
          `SELECT type, id, ownerId, hiddenReason, createdAt, excerpt FROM (
             SELECT 'post' AS type, id, user_id AS ownerId, hidden_reason AS hiddenReason, created_at AS createdAt, substr(body, 1, 80) AS excerpt FROM posts WHERE hidden = 1
             UNION ALL
             SELECT 'comment', id, user_id, hidden_reason, created_at, substr(body, 1, 80) FROM comments WHERE hidden = 1
             UNION ALL
             SELECT 'lfg', id, user_id, hidden_reason, created_at, substr(COALESCE(note, ''), 1, 80) FROM lfg_posts WHERE hidden = 1
             UNION ALL
             SELECT 'review', id, user_id, hidden_reason, created_at, substr(body, 1, 80) FROM skin_reviews WHERE hidden = 1
           ) ORDER BY createdAt DESC, id LIMIT ?`,
        )
        .all(limit) as HiddenItem[]
    );
  }

  // ---- sanctions and the operator audit log -----------------------------------------------------------------

  addSanction(s: { userId: string; kind: SanctionKind; until: number | null; reason: string; now: number }): SanctionRow {
    const res = this.db
      .prepare('INSERT INTO sanctions (user_id, kind, until, reason, created_at) VALUES (?, ?, ?, ?, ?)')
      .run(s.userId, s.kind, s.until, s.reason, s.now);
    return this.db.prepare('SELECT * FROM sanctions WHERE id = ?').get(Number(res.lastInsertRowid)) as SanctionRow;
  }

  activeSanction(userId: string, now: number): SanctionRow | null {
    return (
      (this.db
        .prepare(
          `SELECT * FROM sanctions WHERE user_id = ? AND lifted_at IS NULL AND (until IS NULL OR until > ?)
           ORDER BY CASE kind WHEN 'ban' THEN 0 ELSE 1 END, COALESCE(until, 9007199254740991) DESC, id DESC LIMIT 1`,
        )
        .get(userId, now) as SanctionRow | undefined) ?? null
    );
  }

  liftSanctions(userId: string, now: number): number {
    return this.db
      .prepare('UPDATE sanctions SET lifted_at = ? WHERE user_id = ? AND lifted_at IS NULL AND (until IS NULL OR until > ?)')
      .run(now, userId, now).changes;
  }

  listSanctions(q: { userId?: string; activeOnly: boolean; now: number; limit: number }): SanctionRow[] {
    const where: string[] = [];
    const params: Record<string, unknown> = { limit: q.limit, now: q.now };
    if (q.userId) {
      where.push('user_id = @userId');
      params.userId = q.userId;
    }
    if (q.activeOnly) where.push('lifted_at IS NULL AND (until IS NULL OR until > @now)');
    return this.db
      .prepare(`SELECT * FROM sanctions ${where.length ? `WHERE ${where.join(' AND ')}` : ''} ORDER BY created_at DESC, id DESC LIMIT @limit`)
      .all(params) as SanctionRow[];
  }

  addAudit(a: {
    at: number;
    action: string;
    targetType?: string;
    targetId?: string;
    userId?: string;
    detail?: unknown;
  }): void {
    this.db
      .prepare('INSERT INTO moderation_audit (at, action, target_type, target_id, user_id, detail) VALUES (?, ?, ?, ?, ?, ?)')
      .run(a.at, a.action, a.targetType ?? null, a.targetId ?? null, a.userId ?? null, a.detail === undefined ? null : JSON.stringify(a.detail));
  }

  listAudit(q: { userId?: string; limit: number }): AuditRow[] {
    return (
      q.userId
        ? this.db.prepare('SELECT * FROM moderation_audit WHERE user_id = ? ORDER BY at DESC, id DESC LIMIT ?').all(q.userId, q.limit)
        : this.db.prepare('SELECT * FROM moderation_audit ORDER BY at DESC, id DESC LIMIT ?').all(q.limit)
    ) as AuditRow[];
  }

  stats(): Record<string, number> {
    const out: Record<string, number> = {};
    for (const t of ['users', 'posts', 'comments', 'skin_reviews', 'skin_votes', 'lfg_posts', 'media', 'reports', 'sanctions']) {
      out[t] = (this.db.prepare(`SELECT COUNT(*) AS n FROM ${t}`).get() as { n: number }).n;
    }
    out.media_bytes = this.mediaBytes();
    out.media_quarantined = (
      this.db.prepare("SELECT COUNT(*) AS n FROM media WHERE status = 'quarantined'").get() as { n: number }
    ).n;
    return out;
  }

  findUsersByRiotId(gameName: string, tagLine: string): UserRow[] {
    return this.db
      .prepare('SELECT * FROM users WHERE game_name = ? COLLATE NOCASE AND tag_line = ? COLLATE NOCASE')
      .all(gameName, tagLine) as UserRow[];
  }
}
