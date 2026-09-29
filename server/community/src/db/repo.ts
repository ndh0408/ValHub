import type { Cursor } from '../cursor.js';
import type { GeoScope } from '../geo/scope.js';
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
  // v3 (migration 0004)
  /** ISO 3166-1 alpha-2 from Riot /userinfo; NULL until the next auth or when unknown. */
  country: string | null;
  /** App language (one of the 17 codes); NULL for clients that never sent one. */
  language: string | null;
}

/** Author columns joined onto content rows (prefixed a_). */
export interface AuthorCols {
  a_id: string;
  a_game_name: string;
  a_tag_line: string;
  a_card_id: string | null;
  a_rank_tier: number | null;
  a_region: string;
  a_country: string | null;
  a_language: string | null;
}

/** Where content / a vote comes from, captured at creation time. */
export interface Origin {
  country: string | null;
  region: string | null;
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
  /** Party language: one of the 17 codes or 'any'. */
  language: string;
  /** NULL on v1 rows → 5 - slots. */
  party_size: number | null;
  /** JSON array of agent uuids. */
  agents: string;
  status: string;
  /** NULL on v1 rows → created_at. */
  updated_at: number | null;
  // v3 (migration 0004)
  country: string | null;
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
  geo?: GeoScope;
  mode?: string;
  rank?: number;
  role?: string;
  mic?: boolean;
  /** Party languages to keep (posts with language 'any' always match). */
  languages?: string[];
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
  // v3
  country: string | null;
  region: string | null;
  language: string | null;
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
  // v3
  country: string | null;
  region: string | null;
  language: string | null;
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
  // v3
  country: string | null;
  region: string | null;
  language: string | null;
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

export interface CommunityActivity {
  country: string;
  posts: number;
  authors: number;
  lfg: number;
}

export interface UserUpsert {
  id: string;
  gameName: string;
  tagLine: string;
  region: string;
  /** Refreshed on every auth (null when Riot does not report a known country). */
  country: string | null;
  /** undefined → keep existing value. */
  language?: string;
  /** undefined → keep existing value. */
  cardId?: string | null;
  rankTier?: number | null;
}

export interface UserPatch {
  cardId?: string | null;
  rankTier?: number | null;
  region?: string;
  language?: string;
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

  /** Expires the user's previous LFG posts and inserts the new one atomically. */
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

  /** Idempotent (the first vote's time and voter origin are kept). Returns true if a new vote was created. */
  voteSkin(userId: string, skinUuid: string, weaponUuid: string, now: number, origin: Origin): boolean;
  unvoteSkin(userId: string, skinUuid: string): void;
  /** Vote counts per skin, optionally only votes cast since `since` by voters in `geo`. */
  voteCounts(skinUuids: string[], since?: number, geo?: GeoScope): Map<string, number>;
  /** Weapon a skin is pinned to (by its first vote or review), or null if unknown. */
  skinWeapon(skinUuid: string): string | null;
  userVotes(userId: string, skinUuids: string[]): Set<string>;
  topSkins(q: { weaponUuid?: string; since?: number; limit: number; geo?: GeoScope }): SkinCount[];
  /** Skins with >= minCount visible ratings, by Bayesian average (C, mean m of the same scope/period). */
  topRatedSkins(q: {
    weaponUuid?: string;
    since?: number;
    limit: number;
    c: number;
    minCount: number;
    geo?: GeoScope;
  }): { skinUuid: string; weaponUuid: string }[];
  /** Skins with >= 1 visible rating, by review count (non-empty body), then rating count. */
  topReviewedSkins(q: { weaponUuid?: string; since?: number; limit: number; geo?: GeoScope }): {
    skinUuid: string;
    weaponUuid: string;
  }[];

  /**
   * Creates or replaces the user's review of a skin; returns its id. Origin is stored on
   * creation only; `language` is stored on creation and, on edits, only when `updateLanguage`.
   */
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
  }): string;
  getReview(id: string, viewerId: string): ReviewView | null;
  getUserReview(userId: string, skinUuid: string): ReviewView | null;
  listReviews(q: {
    skinUuid: string;
    sort: 'new' | 'top';
    cursor?: Cursor;
    limit: number;
    viewerId: string;
    geo?: GeoScope;
    languages?: string[];
  }): ReviewView[];
  deleteReview(id: string): void;
  /** Returns true if the user had a review of that skin. */
  deleteUserReview(userId: string, skinUuid: string): boolean;
  /** Idempotent; keeps skin_reviews.like_count in sync and returns it. */
  setReviewLike(reviewId: string, userId: string, liked: boolean, now: number): number;
  /** Visible rating stats per skin, optionally only reviews updated since `since` by reviewers in `geo`. */
  ratingStats(skinUuids: string[], since?: number, geo?: GeoScope): Map<string, RatingStats>;
  /** Visible rating counts [n1..n5] for a skin (reviewers in `geo`). */
  ratingDistribution(skinUuid: string, geo?: GeoScope): [number, number, number, number, number];

  insertPost(p: PostRow): void;
  getPost(id: string, viewerId: string): PostView | null;
  listPosts(q: {
    kind?: string;
    cursor?: Cursor;
    limit: number;
    viewerId: string;
    geo?: GeoScope;
    languages?: string[];
  }): PostView[];
  deletePost(id: string): void;
  setLike(postId: string, userId: string, liked: boolean, now: number): void;
  likeCount(postId: string): number;

  insertComment(c: CommentRow): void;
  getComment(id: string): (CommentRow & AuthorCols) | null;
  listComments(q: { postId: string; cursor?: Cursor; limit: number }): (CommentRow & AuthorCols)[];
  deleteComment(id: string): void;

  /** Countries with visible posts or LFG posts since `since` (rows without a country are skipped). */
  communities(since: number): CommunityActivity[];

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
