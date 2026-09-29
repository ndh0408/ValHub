-- ValVN community schema v1. Times are integer milliseconds since epoch (UTC).
-- Ids are lowercase UUIDs, except users.id = hex(sha256(PEPPER + puuid))[0..32].

CREATE TABLE users (
  id          TEXT PRIMARY KEY,
  game_name   TEXT NOT NULL DEFAULT '',
  tag_line    TEXT NOT NULL DEFAULT '',
  card_id     TEXT,
  rank_tier   INTEGER,
  region      TEXT NOT NULL DEFAULT 'ap',
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL
);

CREATE TABLE lfg_posts (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  region      TEXT NOT NULL,
  mode        TEXT NOT NULL,
  party_code  TEXT NOT NULL,
  slots       INTEGER NOT NULL,
  rank_tier   INTEGER,
  note        TEXT,
  hidden      INTEGER NOT NULL DEFAULT 0,
  created_at  INTEGER NOT NULL,
  expires_at  INTEGER NOT NULL
);
-- GET /v1/lfg (all four filter combinations), newest first.
CREATE INDEX idx_lfg_feed             ON lfg_posts(created_at DESC, id DESC);
CREATE INDEX idx_lfg_region_feed      ON lfg_posts(region, created_at DESC, id DESC);
CREATE INDEX idx_lfg_mode_feed        ON lfg_posts(mode, created_at DESC, id DESC);
CREATE INDEX idx_lfg_region_mode_feed ON lfg_posts(region, mode, created_at DESC, id DESC);
CREATE INDEX idx_lfg_user             ON lfg_posts(user_id);
CREATE INDEX idx_lfg_expires          ON lfg_posts(expires_at);

CREATE TABLE skin_votes (
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  skin_uuid   TEXT NOT NULL,
  weapon_uuid TEXT NOT NULL,
  created_at  INTEGER NOT NULL,
  PRIMARY KEY (user_id, skin_uuid)
) WITHOUT ROWID;
-- counts per skin, top (all / weapon, all-time / week).
CREATE INDEX idx_votes_skin         ON skin_votes(skin_uuid, created_at);
CREATE INDEX idx_votes_weapon_skin  ON skin_votes(weapon_uuid, skin_uuid, created_at);
CREATE INDEX idx_votes_created      ON skin_votes(created_at, skin_uuid);

CREATE TABLE posts (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind        TEXT NOT NULL,
  body        TEXT NOT NULL DEFAULT '',
  media       TEXT NOT NULL DEFAULT '[]',   -- JSON array of media keys
  payload     TEXT,                         -- JSON object or NULL
  hidden      INTEGER NOT NULL DEFAULT 0,
  created_at  INTEGER NOT NULL
);
CREATE INDEX idx_posts_feed      ON posts(hidden, created_at DESC, id DESC);
CREATE INDEX idx_posts_kind_feed ON posts(kind, hidden, created_at DESC, id DESC);
CREATE INDEX idx_posts_user      ON posts(user_id);

CREATE TABLE post_likes (
  post_id     TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at  INTEGER NOT NULL,
  PRIMARY KEY (post_id, user_id)
) WITHOUT ROWID;
CREATE INDEX idx_likes_user ON post_likes(user_id);

CREATE TABLE comments (
  id          TEXT PRIMARY KEY,
  post_id     TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body        TEXT NOT NULL,
  hidden      INTEGER NOT NULL DEFAULT 0,
  created_at  INTEGER NOT NULL
);
-- GET /v1/posts/{id}/comments oldest first + comment counts.
CREATE INDEX idx_comments_post ON comments(post_id, hidden, created_at, id);
CREATE INDEX idx_comments_user ON comments(user_id);

CREATE TABLE reports (
  target_type TEXT NOT NULL,               -- post | comment | lfg
  target_id   TEXT NOT NULL,
  reporter_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reason      TEXT NOT NULL,
  created_at  INTEGER NOT NULL,
  PRIMARY KEY (target_type, target_id, reporter_id)
) WITHOUT ROWID;
CREATE INDEX idx_reports_reporter ON reports(reporter_id);

CREATE TABLE media (
  key          TEXT PRIMARY KEY,           -- u/<userId>/<random>.<ext>
  user_id      TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL,
  size         INTEGER NOT NULL,
  created_at   INTEGER NOT NULL
);
CREATE INDEX idx_media_user ON media(user_id, created_at);

CREATE TABLE rate_limits (
  bucket       TEXT NOT NULL,              -- <name>:<userId or hashed ip>
  window_start INTEGER NOT NULL,
  count        INTEGER NOT NULL,
  PRIMARY KEY (bucket, window_start)
) WITHOUT ROWID;
CREATE INDEX idx_rate_limits_window ON rate_limits(window_start);
