-- Keep only until all tokens of an erased account have expired (30 days).
CREATE TABLE revoked_accounts (
  user_id TEXT PRIMARY KEY,
  epoch INTEGER NOT NULL,
  expires_at INTEGER NOT NULL
) WITHOUT ROWID;
