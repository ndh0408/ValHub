-- Community scopes v3: country / region / global + content language. Additive only.
--
-- Backfill rules (docs/community-api.md "Community scopes v3"):
-- * users.country / users.language start NULL and are filled when the user next authenticates
--   (country from Riot /userinfo, language from the app).
-- * Content keeps its creation-time values: country and language stay NULL on rows created
--   before this migration. Their region IS known — it is the author's shard — so it is copied
--   from the author once, here, so old content stays visible in `region` scope (and `global`).
--   lfg_posts already has its own region.

ALTER TABLE users ADD COLUMN country  TEXT;   -- ISO 3166-1 alpha-2, e.g. 'VN'
ALTER TABLE users ADD COLUMN language TEXT;   -- one of the 17 app languages

ALTER TABLE posts ADD COLUMN country  TEXT;
ALTER TABLE posts ADD COLUMN region   TEXT;
ALTER TABLE posts ADD COLUMN language TEXT;

ALTER TABLE comments ADD COLUMN country  TEXT;
ALTER TABLE comments ADD COLUMN region   TEXT;
ALTER TABLE comments ADD COLUMN language TEXT;

ALTER TABLE skin_reviews ADD COLUMN country  TEXT;   -- reviewer's country / region at review time
ALTER TABLE skin_reviews ADD COLUMN region   TEXT;
ALTER TABLE skin_reviews ADD COLUMN language TEXT;

ALTER TABLE skin_votes ADD COLUMN country TEXT;      -- voter's country / region at vote time
ALTER TABLE skin_votes ADD COLUMN region  TEXT;

ALTER TABLE lfg_posts ADD COLUMN country TEXT;       -- region + language (party language) exist

UPDATE posts        SET region = (SELECT u.region FROM users u WHERE u.id = posts.user_id)        WHERE region IS NULL;
UPDATE comments     SET region = (SELECT u.region FROM users u WHERE u.id = comments.user_id)     WHERE region IS NULL;
UPDATE skin_reviews SET region = (SELECT u.region FROM users u WHERE u.id = skin_reviews.user_id) WHERE region IS NULL;
UPDATE skin_votes   SET region = (SELECT u.region FROM users u WHERE u.id = skin_votes.user_id)   WHERE region IS NULL;

-- GET /v1/posts?scope=country|region (+ kind), newest first; ?language= in global scope.
CREATE INDEX idx_posts_country_feed      ON posts(country, hidden, created_at DESC, id DESC);
CREATE INDEX idx_posts_country_kind_feed ON posts(country, kind, hidden, created_at DESC, id DESC);
CREATE INDEX idx_posts_region_feed       ON posts(region, hidden, created_at DESC, id DESC);
CREATE INDEX idx_posts_region_kind_feed  ON posts(region, kind, hidden, created_at DESC, id DESC);
CREATE INDEX idx_posts_language_feed     ON posts(language, hidden, created_at DESC, id DESC);
-- GET /v1/communities (last 7 days per country).
CREATE INDEX idx_posts_activity          ON posts(created_at, country, user_id);

-- GET /v1/lfg?scope=country (default status=open filter).
CREATE INDEX idx_lfg_status_country_feed ON lfg_posts(status, country, created_at DESC, id DESC);
CREATE INDEX idx_lfg_activity            ON lfg_posts(created_at, country, user_id);

-- Skin leaderboards / counts / summaries by voter country or region.
CREATE INDEX idx_votes_country_skin   ON skin_votes(country, skin_uuid, created_at);
CREATE INDEX idx_votes_region_skin    ON skin_votes(region, skin_uuid, created_at);
CREATE INDEX idx_votes_country_weapon ON skin_votes(country, weapon_uuid, skin_uuid, created_at);
CREATE INDEX idx_votes_region_weapon  ON skin_votes(region, weapon_uuid, skin_uuid, created_at);
CREATE INDEX idx_votes_skin_country   ON skin_votes(skin_uuid, country, created_at);
CREATE INDEX idx_votes_skin_region    ON skin_votes(skin_uuid, region, created_at);

-- Reviews by reviewer country / region / language (lists, per-skin aggregates, top by rating).
CREATE INDEX idx_reviews_skin_country  ON skin_reviews(skin_uuid, hidden, country, created_at DESC, id DESC);
CREATE INDEX idx_reviews_skin_region   ON skin_reviews(skin_uuid, hidden, region, created_at DESC, id DESC);
CREATE INDEX idx_reviews_skin_language ON skin_reviews(skin_uuid, hidden, language, created_at DESC, id DESC);
CREATE INDEX idx_reviews_country_agg   ON skin_reviews(country, hidden, skin_uuid, rating, updated_at);
CREATE INDEX idx_reviews_region_agg    ON skin_reviews(region, hidden, skin_uuid, rating, updated_at);
