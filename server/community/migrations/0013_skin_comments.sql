-- Plain discussion is independent of ownership-verified star reviews.
-- Existing post comments/foreign keys and rating aggregates are untouched.
CREATE TABLE skin_comments (
  id TEXT PRIMARY KEY,
  skin_uuid TEXT NOT NULL,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  hidden INTEGER NOT NULL DEFAULT 0 CHECK (hidden IN (0, 1)),
  hidden_reason TEXT,
  created_at INTEGER NOT NULL,
  country TEXT,
  region TEXT,
  language TEXT
);
-- Bounded oldest-first cursor pagination and per-account export/erasure.
CREATE INDEX idx_skin_comments_skin ON skin_comments(skin_uuid, hidden, created_at, id);
CREATE INDEX idx_skin_comments_user ON skin_comments(user_id);
