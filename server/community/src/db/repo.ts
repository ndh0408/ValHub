import type { Cursor } from '../cursor.js';
import type { ReportTarget } from '../validate.js';

export interface UserRow {
  id: string;
  game_name: string;
  tag_line: string;
  card_id: string | null;
  rank_tier: number | null;
  region: string;
  created_at: number;
  updated_at: number;
}

/** Author columns joined onto content rows (prefixed a_). */
export interface AuthorCols {
  a_id: string;
  a_game_name: string;
  a_tag_line: string;
  a_card_id: string | null;
  a_rank_tier: number | null;
  a_region: string;
}

export interface LfgRow {
  id: string;
  user_id: string;
  region: string;
  mode: string;
  party_code: string;
  slots: number;
  rank_tier: number | null;
  note: string | null;
  hidden: number;
  created_at: number;
  expires_at: number;
}

export interface PostRow {
  id: string;
  user_id: string;
  kind: string;
  body: string;
  media: string;
  payload: string | null;
  hidden: number;
  created_at: number;
}

export interface PostView extends PostRow, AuthorCols {
  likes: number;
  comments: number;
  liked: number;
}

export interface CommentRow {
  id: string;
  post_id: string;
  user_id: string;
  body: string;
  hidden: number;
  created_at: number;
}

export interface MediaRow {
  key: string;
  user_id: string;
  content_type: string;
  size: number;
  created_at: number;
}

export interface SkinCount {
  skinUuid: string;
  weaponUuid: string;
  votes: number;
}

export interface UserUpsert {
  id: string;
  gameName: string;
  tagLine: string;
  region: string;
  /** undefined → keep existing value. */
  cardId?: string | null;
  rankTier?: number | null;
}

export interface UserPatch {
  cardId?: string | null;
  rankTier?: number | null;
  region?: string;
}

/**
 * Storage abstraction used by the HTTP layer. Synchronous because the only
 * implementation (better-sqlite3) is synchronous; swap freely in tests.
 */
export interface Repo {
  ping(): boolean;

  upsertUser(u: UserUpsert, now: number): UserRow;
  getUser(id: string): UserRow | null;
  updateUser(id: string, patch: UserPatch, now: number): UserRow | null;

  /** Increments the counter for (bucket, windowStart) and returns the new count. */
  hitRateLimit(bucket: string, windowStart: number): number;
  /** Deletes stale rate-limit windows and long-expired LFG posts. */
  cleanup(now: number): void;

  /** Deletes the user's previous LFG posts and inserts the new one atomically. */
  replaceLfg(post: LfgRow): void;
  listLfg(q: {
    region?: string;
    mode?: string;
    now: number;
    cursor?: Cursor;
    limit: number;
  }): (LfgRow & AuthorCols)[];
  getLfg(id: string): (LfgRow & AuthorCols) | null;
  deleteLfg(id: string): void;

  /** Idempotent. Returns true if a new vote row was created. */
  voteSkin(userId: string, skinUuid: string, weaponUuid: string, now: number): boolean;
  unvoteSkin(userId: string, skinUuid: string): void;
  voteCounts(skinUuids: string[]): Map<string, number>;
  userVotes(userId: string, skinUuids: string[]): Set<string>;
  topSkins(q: { weaponUuid?: string; since?: number; limit: number }): SkinCount[];

  insertPost(p: PostRow): void;
  getPost(id: string, viewerId: string): PostView | null;
  listPosts(q: { kind?: string; cursor?: Cursor; limit: number; viewerId: string }): PostView[];
  deletePost(id: string): void;
  setLike(postId: string, userId: string, liked: boolean, now: number): void;
  likeCount(postId: string): number;

  insertComment(c: CommentRow): void;
  getComment(id: string): (CommentRow & AuthorCols) | null;
  listComments(q: { postId: string; cursor?: Cursor; limit: number }): (CommentRow & AuthorCols)[];
  deleteComment(id: string): void;

  /** Owner of a report target, or null if it does not exist. */
  reportTargetOwner(type: ReportTarget, id: string): string | null;
  /**
   * Records a report (idempotent per reporter) and hides the target once
   * `threshold` distinct users reported it. Returns the distinct report count.
   */
  addReport(
    r: { type: ReportTarget; targetId: string; reporterId: string; reason: string; now: number },
    threshold: number,
  ): number;

  insertMedia(m: MediaRow): void;
  getMediaMany(keys: string[]): MediaRow[];
}
