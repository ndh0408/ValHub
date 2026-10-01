-- Exact quota counters for all media rows (active AND quarantined), matching the previous SUM(size).
-- Triggers cover CLI deletes, erasure cascades, restores and direct updates, in the same SQLite transaction.
CREATE TABLE media_totals (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  bytes INTEGER NOT NULL CHECK (bytes >= 0)
);
INSERT INTO media_totals VALUES (1, (SELECT COALESCE(SUM(size), 0) FROM media));

CREATE TABLE user_media_bytes (
  user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  bytes INTEGER NOT NULL CHECK (bytes >= 0)
) WITHOUT ROWID;
INSERT INTO user_media_bytes SELECT user_id, SUM(size) FROM media GROUP BY user_id;

CREATE TRIGGER media_usage_insert AFTER INSERT ON media BEGIN
  UPDATE media_totals SET bytes = bytes + NEW.size WHERE id = 1;
  INSERT INTO user_media_bytes VALUES (NEW.user_id, NEW.size)
    ON CONFLICT(user_id) DO UPDATE SET bytes = bytes + NEW.size;
END;

CREATE TRIGGER media_usage_delete AFTER DELETE ON media BEGIN
  UPDATE media_totals SET bytes = bytes - OLD.size WHERE id = 1;
  UPDATE user_media_bytes SET bytes = bytes - OLD.size WHERE user_id = OLD.user_id;
END;

CREATE TRIGGER media_usage_update AFTER UPDATE OF size, user_id ON media BEGIN
  UPDATE media_totals SET bytes = bytes - OLD.size + NEW.size WHERE id = 1;
  UPDATE user_media_bytes SET bytes = bytes - OLD.size WHERE user_id = OLD.user_id;
  INSERT INTO user_media_bytes VALUES (NEW.user_id, NEW.size)
    ON CONFLICT(user_id) DO UPDATE SET bytes = bytes + NEW.size;
END;
