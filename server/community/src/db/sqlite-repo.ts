import type { Cursor } from '../cursor.js';
import type { ReportTarget } from '../validate.js';
import type { Db } from './database.js';
import type {
  AuthorCols,
  CommentRow,
  LfgRow,
  MediaRow,
  PostRow,
  PostView,
  Repo,
  SkinCount,
  UserPatch,
  UserRow,
  UserUpsert,
} from './repo.js';

const AUTHOR_SELECT = `u.id AS a_id, u.game_name AS a_game_name, u.tag_line AS a_tag_line,
  u.card_id AS a_card_id, u.rank_tier AS a_rank_tier, u.region AS a_region`;

const POST_SELECT = `SELECT p.id, p.user_id, p.kind, p.body, p.media, p.payload, p.hidden, p.created_at,
  ${AUTHOR_SELECT},
  (SELECT COUNT(*) FROM post_likes l WHERE l.post_id = p.id) AS likes,
  (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id AND c.hidden = 0) AS comments,
  EXISTS (SELECT 1 FROM post_likes l2 WHERE l2.post_id = p.id AND l2.user_id = @viewer) AS liked
  FROM posts p JOIN users u ON u.id = p.user_id`;

const DAY_MS = 24 * 60 * 60 * 1000;

function placeholders(n: number): string {
  return Array.from({ length: n }, () => '?').join(', ');
}

export class SqliteRepo implements Repo {
  constructor(private readonly db: Db) {}

  ping(): boolean {
    return (this.db.prepare('SELECT 1 AS ok').get() as { ok: number } | undefined)?.ok === 1;
  }

  // ---- users -------------------------------------------------------------

  upsertUser(u: UserUpsert, now: number): UserRow {
    const existing = this.getUser(u.id);
    const cardId = u.cardId === undefined ? (existing?.card_id ?? null) : u.cardId;
    const rankTier = u.rankTier === undefined ? (existing?.rank_tier ?? null) : u.rankTier;
    this.db
      .prepare(
        `INSERT INTO users (id, game_name, tag_line, card_id, rank_tier, region, created_at, updated_at)
         VALUES (@id, @gameName, @tagLine, @cardId, @rankTier, @region, @now, @now)
         ON CONFLICT(id) DO UPDATE SET game_name = excluded.game_name, tag_line = excluded.tag_line,
           card_id = excluded.card_id, rank_tier = excluded.rank_tier, region = excluded.region,
           updated_at = excluded.updated_at`,
      )
      .run({ id: u.id, gameName: u.gameName, tagLine: u.tagLine, cardId, rankTier, region: u.region, now });
    return this.getUser(u.id)!;
  }

  getUser(id: string): UserRow | null {
    return (this.db.prepare('SELECT * FROM users WHERE id = ?').get(id) as UserRow | undefined) ?? null;
  }

  updateUser(id: string, patch: UserPatch, now: number): UserRow | null {
    const existing = this.getUser(id);
    if (!existing) return null;
    this.db
      .prepare('UPDATE users SET card_id = ?, rank_tier = ?, region = ?, updated_at = ? WHERE id = ?')
      .run(
        patch.cardId === undefined ? existing.card_id : patch.cardId,
        patch.rankTier === undefined ? existing.rank_tier : patch.rankTier,
        patch.region ?? existing.region,
        now,
        id,
      );
    return this.getUser(id);
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
    this.db.prepare('DELETE FROM rate_limits WHERE window_start < ?').run(now - DAY_MS);
    this.db.prepare('DELETE FROM lfg_posts WHERE expires_at < ?').run(now - DAY_MS);
  }

  // ---- LFG ---------------------------------------------------------------

  replaceLfg(post: LfgRow): void {
    this.db.transaction(() => {
      this.db.prepare('DELETE FROM lfg_posts WHERE user_id = ?').run(post.user_id);
      this.db
        .prepare(
          `INSERT INTO lfg_posts (id, user_id, region, mode, party_code, slots, rank_tier, note, hidden, created_at, expires_at)
           VALUES (@id, @user_id, @region, @mode, @party_code, @slots, @rank_tier, @note, @hidden, @created_at, @expires_at)`,
        )
        .run(post);
    })();
  }

  listLfg(q: { region?: string; mode?: string; now: number; cursor?: Cursor; limit: number }) {
    const where = ['l.hidden = 0', 'l.expires_at > @now'];
    const params: Record<string, unknown> = { now: q.now, limit: q.limit + 1 };
    if (q.region) {
      where.push('l.region = @region');
      params.region = q.region;
    }
    if (q.mode) {
      where.push('l.mode = @mode');
      params.mode = q.mode;
    }
    if (q.cursor) {
      where.push('(l.created_at < @cAt OR (l.created_at = @cAt AND l.id < @cId))');
      params.cAt = q.cursor.createdAt;
      params.cId = q.cursor.id;
    }
    return this.db
      .prepare(
        `SELECT l.*, ${AUTHOR_SELECT} FROM lfg_posts l JOIN users u ON u.id = l.user_id
         WHERE ${where.join(' AND ')} ORDER BY l.created_at DESC, l.id DESC LIMIT @limit`,
      )
      .all(params) as (LfgRow & AuthorCols)[];
  }

  getLfg(id: string) {
    return (
      (this.db
        .prepare(`SELECT l.*, ${AUTHOR_SELECT} FROM lfg_posts l JOIN users u ON u.id = l.user_id WHERE l.id = ?`)
        .get(id) as (LfgRow & AuthorCols) | undefined) ?? null
    );
  }

  deleteLfg(id: string): void {
    this.db.prepare('DELETE FROM lfg_posts WHERE id = ?').run(id);
  }

  // ---- skin votes ----------------------------------------------------------

  voteSkin(userId: string, skinUuid: string, weaponUuid: string, now: number): boolean {
    // The weapon of a skin is pinned by its first vote so a wrong client value
    // cannot split a skin's count across weapons.
    const res = this.db
      .prepare(
        `INSERT INTO skin_votes (user_id, skin_uuid, weapon_uuid, created_at)
         VALUES (@userId, @skinUuid,
           COALESCE((SELECT weapon_uuid FROM skin_votes WHERE skin_uuid = @skinUuid LIMIT 1), @weaponUuid),
           @now)
         ON CONFLICT(user_id, skin_uuid) DO NOTHING`,
      )
      .run({ userId, skinUuid, weaponUuid, now });
    return res.changes > 0;
  }

  unvoteSkin(userId: string, skinUuid: string): void {
    this.db.prepare('DELETE FROM skin_votes WHERE user_id = ? AND skin_uuid = ?').run(userId, skinUuid);
  }

  voteCounts(skinUuids: string[]): Map<string, number> {
    const out = new Map<string, number>();
    if (skinUuids.length === 0) return out;
    const rows = this.db
      .prepare(
        `SELECT skin_uuid, COUNT(*) AS votes FROM skin_votes
         WHERE skin_uuid IN (${placeholders(skinUuids.length)}) GROUP BY skin_uuid`,
      )
      .all(...skinUuids) as { skin_uuid: string; votes: number }[];
    for (const r of rows) out.set(r.skin_uuid, r.votes);
    return out;
  }

  userVotes(userId: string, skinUuids: string[]): Set<string> {
    if (skinUuids.length === 0) return new Set();
    const rows = this.db
      .prepare(
        `SELECT skin_uuid FROM skin_votes WHERE user_id = ? AND skin_uuid IN (${placeholders(skinUuids.length)})`,
      )
      .all(userId, ...skinUuids) as { skin_uuid: string }[];
    return new Set(rows.map((r) => r.skin_uuid));
  }

  topSkins(q: { weaponUuid?: string; since?: number; limit: number }): SkinCount[] {
    const where: string[] = [];
    const params: Record<string, unknown> = { limit: q.limit };
    if (q.weaponUuid) {
      where.push('weapon_uuid = @weapon');
      params.weapon = q.weaponUuid;
    }
    if (q.since !== undefined) {
      where.push('created_at >= @since');
      params.since = q.since;
    }
    const rows = this.db
      .prepare(
        `SELECT skin_uuid, MIN(weapon_uuid) AS weapon_uuid, COUNT(*) AS votes FROM skin_votes
         ${where.length ? `WHERE ${where.join(' AND ')}` : ''}
         GROUP BY skin_uuid ORDER BY votes DESC, skin_uuid ASC LIMIT @limit`,
      )
      .all(params) as { skin_uuid: string; weapon_uuid: string; votes: number }[];
    return rows.map((r) => ({ skinUuid: r.skin_uuid, weaponUuid: r.weapon_uuid, votes: r.votes }));
  }

  // ---- posts ---------------------------------------------------------------

  insertPost(p: PostRow): void {
    this.db
      .prepare(
        `INSERT INTO posts (id, user_id, kind, body, media, payload, hidden, created_at)
         VALUES (@id, @user_id, @kind, @body, @media, @payload, @hidden, @created_at)`,
      )
      .run(p);
  }

  getPost(id: string, viewerId: string): PostView | null {
    return (
      (this.db.prepare(`${POST_SELECT} WHERE p.id = @id`).get({ id, viewer: viewerId }) as
        | PostView
        | undefined) ?? null
    );
  }

  listPosts(q: { kind?: string; cursor?: Cursor; limit: number; viewerId: string }): PostView[] {
    const where = ['p.hidden = 0'];
    const params: Record<string, unknown> = { viewer: q.viewerId, limit: q.limit + 1 };
    if (q.kind) {
      where.push('p.kind = @kind');
      params.kind = q.kind;
    }
    if (q.cursor) {
      where.push('(p.created_at < @cAt OR (p.created_at = @cAt AND p.id < @cId))');
      params.cAt = q.cursor.createdAt;
      params.cId = q.cursor.id;
    }
    return this.db
      .prepare(`${POST_SELECT} WHERE ${where.join(' AND ')} ORDER BY p.created_at DESC, p.id DESC LIMIT @limit`)
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

  insertComment(c: CommentRow): void {
    this.db
      .prepare(
        `INSERT INTO comments (id, post_id, user_id, body, hidden, created_at)
         VALUES (@id, @post_id, @user_id, @body, @hidden, @created_at)`,
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

  // ---- reports -------------------------------------------------------------

  private static readonly TARGET_TABLE: Record<ReportTarget, string> = {
    post: 'posts',
    comment: 'comments',
    lfg: 'lfg_posts',
  };

  reportTargetOwner(type: ReportTarget, id: string): string | null {
    const table = SqliteRepo.TARGET_TABLE[type];
    const row = this.db.prepare(`SELECT user_id FROM ${table} WHERE id = ?`).get(id) as
      | { user_id: string }
      | undefined;
    return row?.user_id ?? null;
  }

  addReport(
    r: { type: ReportTarget; targetId: string; reporterId: string; reason: string; now: number },
    threshold: number,
  ): number {
    const table = SqliteRepo.TARGET_TABLE[r.type];
    return this.db.transaction(() => {
      this.db
        .prepare(
          `INSERT INTO reports (target_type, target_id, reporter_id, reason, created_at) VALUES (?, ?, ?, ?, ?)
           ON CONFLICT(target_type, target_id, reporter_id) DO NOTHING`,
        )
        .run(r.type, r.targetId, r.reporterId, r.reason, r.now);
      const n = (
        this.db
          .prepare('SELECT COUNT(*) AS n FROM reports WHERE target_type = ? AND target_id = ?')
          .get(r.type, r.targetId) as { n: number }
      ).n;
      if (n >= threshold) this.db.prepare(`UPDATE ${table} SET hidden = 1 WHERE id = ?`).run(r.targetId);
      return n;
    })();
  }

  // ---- media ---------------------------------------------------------------

  insertMedia(m: MediaRow): void {
    this.db
      .prepare(
        `INSERT INTO media (key, user_id, content_type, size, created_at)
         VALUES (@key, @user_id, @content_type, @size, @created_at)`,
      )
      .run(m);
  }

  getMediaMany(keys: string[]): MediaRow[] {
    if (keys.length === 0) return [];
    return this.db
      .prepare(`SELECT * FROM media WHERE key IN (${placeholders(keys.length)})`)
      .all(...keys) as MediaRow[];
  }
}
