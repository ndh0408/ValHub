-- The catalog supplies this mapping at runtime; no game ids are hard-coded into migrations.
-- Persist it so the data migration can be resumed after a restart or upstream outage.
CREATE TABLE skin_aliases (
  alias_uuid TEXT PRIMARY KEY,
  skin_uuid TEXT NOT NULL,
  weapon_uuid TEXT NOT NULL
) WITHOUT ROWID;
