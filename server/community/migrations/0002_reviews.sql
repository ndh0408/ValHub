-- Skin reviews (Daily Val-style): one 1–5 star rating + optional text per user per skin.
-- Additive only. reports.target_type is free TEXT (no CHECK), so 'review' needs no schema change.

CREATE TABLE skin_reviews (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  skin_uuid    TEXT NOT NULL,
  weapon_uuid  TEXT NOT NULL,
  rating       INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  body         TEXT NOT NULL DEFAULT '',
  hidden       INTEGER NOT NULL DEFAULT 0,
  report_count INTEGER NOT NULL DEFAULT 0,
  like_count   INTEGER NOT NULL DEFAULT 0,
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  UNIQUE (user_id, skin_uuid)
);
-- GET /v1/skins/{skin}/reviews?sort=new
CREATE INDEX idx_reviews_skin_new ON skin_reviews(skin_uuid, hidden, created_at DESC, id DESC);
-- GET /v1/skins/{skin}/reviews?sort=top
CREATE INDEX idx_reviews_skin_top ON skin_reviews(skin_uuid, hidden, like_count DESC, created_at DESC, id DESC);
-- per-skin aggregates (avg, count, distribution) and top by rating / reviews
CREATE INDEX idx_reviews_skin_agg ON skin_reviews(skin_uuid, hidden, rating, updated_at);
CREATE INDEX idx_reviews_weapon ON skin_reviews(weapon_uuid, skin_uuid, hidden);
-- period=week and the global mean
CREATE INDEX idx_reviews_updated ON skin_reviews(updated_at, hidden);

CREATE TABLE review_likes (
  review_id   TEXT NOT NULL REFERENCES skin_reviews(id) ON DELETE CASCADE,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at  INTEGER NOT NULL,
  PRIMARY KEY (review_id, user_id)
) WITHOUT ROWID;
CREATE INDEX idx_review_likes_user ON review_likes(user_id);
