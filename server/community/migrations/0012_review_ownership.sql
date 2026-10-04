-- Existing reviews are preserved, but are not retroactively claimed as verified.
ALTER TABLE skin_reviews ADD COLUMN ownership_verified_at INTEGER;
