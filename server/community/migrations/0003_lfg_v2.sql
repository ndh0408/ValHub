-- LFG v2: rank range, roles, mic, language, live party size / status, join tracking. Additive only.

ALTER TABLE lfg_posts ADD COLUMN rank_min   INTEGER;                       -- NULL/0 = no lower bound
ALTER TABLE lfg_posts ADD COLUMN rank_max   INTEGER;                       -- NULL/0 = no upper bound
ALTER TABLE lfg_posts ADD COLUMN roles      TEXT NOT NULL DEFAULT '[]';    -- JSON array of roles
ALTER TABLE lfg_posts ADD COLUMN mic        INTEGER NOT NULL DEFAULT 0;
ALTER TABLE lfg_posts ADD COLUMN language   TEXT NOT NULL DEFAULT 'vi';
ALTER TABLE lfg_posts ADD COLUMN party_size INTEGER;                       -- NULL (v1 rows) → 5 - slots
ALTER TABLE lfg_posts ADD COLUMN agents     TEXT NOT NULL DEFAULT '[]';    -- JSON array of agent uuids
ALTER TABLE lfg_posts ADD COLUMN status     TEXT NOT NULL DEFAULT 'open';  -- open | full | in_game
ALTER TABLE lfg_posts ADD COLUMN updated_at INTEGER;                       -- NULL (v1 rows) → created_at

-- GET /v1/lfg with the default status=open filter (+ region / mode).
CREATE INDEX idx_lfg_status_feed             ON lfg_posts(status, created_at DESC, id DESC);
CREATE INDEX idx_lfg_status_region_feed      ON lfg_posts(status, region, created_at DESC, id DESC);
CREATE INDEX idx_lfg_status_region_mode_feed ON lfg_posts(status, region, mode, created_at DESC, id DESC);

CREATE TABLE lfg_joins (
  lfg_id     TEXT NOT NULL REFERENCES lfg_posts(id) ON DELETE CASCADE,
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (lfg_id, user_id)
) WITHOUT ROWID;
CREATE INDEX idx_lfg_joins_user ON lfg_joins(user_id);
