-- Moderation tooling (WP-SRV: CS-02 sanctions, CS-06 hidden reasons). Additive; never edit an applied migration.
--
-- 1. sanctions: temporary restriction ('restrict': read-only) and ban ('ban': no access) of an account, checked by
--    Ctx.user(). There is deliberately NO foreign key to users: a ban must survive the account's deletion (the user
--    id is a hash of the Riot account, so erasing the account and signing in again yields the same id).
--    `reason` is a short code (spam, harassment, hate, scam, nsfw, evasion, minor, illegal, other), never free text.
-- 2. moderation_audit: one row per operator action (CLI), with structured detail only.
-- 3. hidden_reason on the four content tables: why a row is hidden ('reports' = auto-hidden by reports,
--    'moderator' = hidden by an operator), so its author can be told and can appeal.

CREATE TABLE sanctions (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    TEXT NOT NULL,
  kind       TEXT NOT NULL CHECK (kind IN ('ban', 'restrict')),
  until      INTEGER,                   -- ms since epoch; NULL = permanent
  reason     TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  lifted_at  INTEGER                    -- set when an operator lifts it early
);
CREATE INDEX idx_sanctions_user ON sanctions(user_id, lifted_at, until);

CREATE TABLE moderation_audit (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  at          INTEGER NOT NULL,
  action      TEXT NOT NULL,            -- ban | restrict | unban | hide | unhide | delete-content | quarantine-restore | ...
  target_type TEXT,                     -- user | post | comment | lfg | review | media
  target_id   TEXT,
  user_id     TEXT,                     -- the account concerned (author / sanctioned), when known
  detail      TEXT                      -- JSON, structured values only
);
CREATE INDEX idx_audit_at   ON moderation_audit(at);
CREATE INDEX idx_audit_user ON moderation_audit(user_id);

ALTER TABLE posts        ADD COLUMN hidden_reason TEXT;
ALTER TABLE comments     ADD COLUMN hidden_reason TEXT;
ALTER TABLE lfg_posts    ADD COLUMN hidden_reason TEXT;
ALTER TABLE skin_reviews ADD COLUMN hidden_reason TEXT;

-- Everything hidden before this migration was hidden by reports (there was no other way).
UPDATE posts        SET hidden_reason = 'reports' WHERE hidden = 1;
UPDATE comments     SET hidden_reason = 'reports' WHERE hidden = 1;
UPDATE lfg_posts    SET hidden_reason = 'reports' WHERE hidden = 1;
UPDATE skin_reviews SET hidden_reason = 'reports' WHERE hidden = 1;
