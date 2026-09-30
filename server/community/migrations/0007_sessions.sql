-- Session revocation (CS-04) and consent record (CS-34). Additive; never edit an applied migration.
--
-- session_epoch: put in the `ep` claim of every session token; a token whose epoch differs from the account's is
-- refused. Bumped on logout (POST /v1/auth/logout) and on ban, so those sessions end at once. (A deleted and
-- re-created account is covered separately: tokens issued before the new row existed are refused.)
--
-- consent_version / consent_at: the policy version the client says the user accepted (POST /v1/auth/riot
-- `consentVersion`) and when the server first saw that version, so consent can be demonstrated (GDPR Art. 7(1)).
-- Both are removed with the account.

ALTER TABLE users ADD COLUMN session_epoch   INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN consent_version TEXT;
ALTER TABLE users ADD COLUMN consent_at      INTEGER;
