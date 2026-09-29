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
  // v2 (migration 0003)
  rank_min: number | null;
  rank_max: number | null;
  /** JSON array of roles. */
  roles: string;
  mic: number;
  language: string;
  /** NULL on v1 rows → 5 - slots. */
  party_size: number | null;
  /** JSON array of agent uuids. */
  agents: string;
  status: string;
  /** NULL on v1 rows → created_at. */
  updated_at: number | null;
}

export interface LfgView extends LfgRow, AuthorCols {
  joins: number;
}

export interface LfgPatch {
  party_size?: number;
  slots?: number;
  note?: string | null;
  status?: string;
}

export interface LfgQuery {
  region?: string;
  mode?: string;
  rank?: number;
  role?: string;
  mic?: boolean;
  language?: string;
  status: string;
  now: number;
  cursor?: Cursor;
  limit: number;
}

export interface ReviewRow {
  id: string;
  user_id: string;
  skin_uuid: string;
  weapon_uuid: string;
  rating: number;
  body: string;
  hidden: number;
  report_count: number;
  like_count: number;
  created_at: number;
  updated_at: number;
}

export interface ReviewView extends ReviewRow, AuthorCols {
  liked: number;
}

export interface RatingStats {
  count: number;
  sum: number;
  /** Reviews with a non-empty body. */
  reviewCount: number;
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
  listLfg(q: LfgQuery): LfgView[];
  getLfg(id: string): LfgView | null;
  /** The user's current (unexpired) post, whatever its status. */
  getActiveLfgForUser(userId: string, now: number): LfgView | null;
  /** Applies the patch and sets updated_at = now, expires_at = expiresAt. */
  updateLfg(id: string, patch: LfgPatch, now: number, expiresAt: number): void;
  deleteLfg(id: string): void;
  /** Idempotent per user; returns the post's join count. */
  joinLfg(id: string, userId: string, now: number): number;

  /** Idempotent. Returns true if a new vote row was created. */
  voteSkin(userId: string, skinUuid: string, weaponUuid: string, now: number): boolean;
  unvoteSkin(userId: string, skinUuid: string): void;
  /** Vote counts per skin, optionally only votes cast since `since`. */
  voteCounts(skinUuids: string[], since?: number): Map<string, number>;
  /** Weapon a skin is pinned to (by its first vote or review), or null if unknown. */
  skinWeapon(skinUuid: string): string | null;
  userVotes(userId: string, skinUuids: string[]): Set<string>;
  topSkins(q: { weaponUuid?: string; since?: number; limit: number }): SkinCount[];
  /** Skins with >= minCount visible ratings, by Bayesian average (C, global mean m). */
  topRatedSkins(q: { weaponUuid?: string; since?: number; limit: number; c: number; minCount: number }): {
    skinUuid: string;
    weaponUuid: string;
  }[];
  /** Skins with >= 1 visible rating, by review count (non-empty body), then rating count. */
  topReviewedSkins(q: { weaponUuid?: string; since?: number; limit: number }): {
    skinUuid: string;
    weaponUuid: string;
  }[];

  /** Creates or replaces the user's review of a skin; returns its id. */
  upsertReview(r: {
    userId: string;
    skinUuid: string;
    weaponUuid: string;
    rating: number;
    body: string;
    now: number;
  }): string;
  getReview(id: string, viewerId: string): ReviewView | null;
  getUserReview(userId: string, skinUuid: string): ReviewView | null;
  listReviews(q: {
    skinUuid: string;
    sort: 'new' | 'top';
    cursor?: Cursor;
    limit: number;
    viewerId: string;
  }): ReviewView[];
  deleteReview(id: string): void;
  /** Returns true if the user had a review of that skin. */
  deleteUserReview(userId: string, skinUuid: string): boolean;
  /** Idempotent; keeps skin_reviews.like_count in sync and returns it. */
  setReviewLike(reviewId: string, userId: string, liked: boolean, now: number): number;
  /** Visible (non-hidden) rating stats per skin, optionally only reviews updated since `since`. */
  ratingStats(skinUuids: string[], since?: number): Map<string, RatingStats>;
  /** Visible rating counts [n1..n5] for a skin. */
  ratingDistribution(skinUuid: string): [number, number, number, number, number];

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
