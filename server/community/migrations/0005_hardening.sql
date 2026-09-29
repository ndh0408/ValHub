-- Server hardening & privacy promises. Additive; never edit an applied migration.
--
-- 1. Media lifecycle: track which post a file is attached to and whether it is quarantined
--    (hidden by reports: kept privately for moderators, never served), so unattached uploads,
--    files of deleted / hidden posts and files of deleted accounts can be purged.
-- 2. reports: drop the foreign key to users so a deleted account's reports can be anonymised
--    (reporter_id becomes an opaque "anon-…" value) instead of deleted; index by age for the
--    12-month retention sweep.

ALTER TABLE media ADD COLUMN post_id        TEXT;                              -- NULL = not attached to any post
ALTER TABLE media ADD COLUMN status         TEXT NOT NULL DEFAULT 'active';    -- active | quarantined
ALTER TABLE media ADD COLUMN quarantined_at INTEGER;

-- Backfill: files referenced by an existing post are attached to it.
UPDATE media SET post_id = m2.pid
FROM (SELECT j.value AS k, p.id AS pid FROM posts p, json_each(p.media) j) AS m2
WHERE m2.k = media.key;

CREATE INDEX idx_media_post       ON media(post_id);
CREATE INDEX idx_media_orphans    ON media(status, post_id, created_at);
CREATE INDEX idx_media_quarantine ON media(status, quarantined_at);

CREATE TABLE reports_new (
  target_type TEXT NOT NULL,               -- post | comment | lfg | review
  target_id   TEXT NOT NULL,
  reporter_id TEXT NOT NULL,               -- users.id, or 'anon-<random>' after the reporter deleted their account
  reason      TEXT NOT NULL,
  created_at  INTEGER NOT NULL,
  PRIMARY KEY (target_type, target_id, reporter_id)
) WITHOUT ROWID;
INSERT INTO reports_new (target_type, target_id, reporter_id, reason, created_at)
  SELECT target_type, target_id, reporter_id, reason, created_at FROM reports;
DROP TABLE reports;
ALTER TABLE reports_new RENAME TO reports;
CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_created  ON reports(created_at);
