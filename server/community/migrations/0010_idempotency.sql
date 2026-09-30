CREATE TABLE request_keys (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  fingerprint TEXT NOT NULL,
  body TEXT NOT NULL CHECK(json_valid(body)),
  status INTEGER NOT NULL,
  expires_at INTEGER NOT NULL
) WITHOUT ROWID;
CREATE INDEX request_keys_expiry ON request_keys(expires_at);
-- Deletion must remove cached copies of content too.
CREATE TRIGGER request_keys_post_delete AFTER DELETE ON posts BEGIN
  DELETE FROM request_keys WHERE json_extract(body, '$.id') = OLD.id;
END;
CREATE TRIGGER request_keys_comment_delete AFTER DELETE ON comments BEGIN
  DELETE FROM request_keys WHERE json_extract(body, '$.id') = OLD.id;
END;
CREATE TRIGGER request_keys_media_delete AFTER DELETE ON media BEGIN
  DELETE FROM request_keys WHERE json_extract(body, '$.key') = OLD.key;
END;
