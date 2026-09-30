# ValVN Community server and client: security and privacy audit (read-only)

Date: 2026-09-30, branch `claude/jolly-hawking-23o2j8`. I read the server (`src`, migrations, tests, compose, ops scripts), the legal texts and the Flutter community client. On the live server I made GET, HEAD and OPTIONS requests only. I did not write to the live server or run any code, so test claims come from reading test names.

**SSH to `coolify-dev` was unreachable.** The connection to 100.115.143.40 timed out on every attempt, and Tailscale reports it cannot reach its coordination server. Everything about the host is therefore unverified. That covers running containers, applied hardening flags, `.env` permissions, backup archives, disk space, logs and the cloudflared config.

## Executive summary

**Overall.** I found no path to remote compromise: no SQL injection, auth bypass, path traversal, SSRF or admin HTTP surface. All SQL is parameterised, and the few dynamic parts come from constant maps. Every mutation route derives the user from the token and compares ownership. The privacy engineering is unusually careful. The live server currently holds no visible content: the feed, skin leaderboard and communities endpoints all return empty. The issues below should be fixed before public launch.

**Findings: 41 total.** 3 High, 10 Medium, 26 Low, 2 Info.

**Top risks**
- **CS-01 (High).** Cloudflare caches `/v1/media/*.jpg|png|webp` by file extension. I confirmed this live on a 404 (`cf-cache-status: HIT`). Deleted, quarantined or erased images can therefore stay downloadable from the edge, which breaks the "deleted content is deleted" promise.
- **CS-02 (High).** The published rules promise temporary restrictions and permanent bans, but there is no ban mechanism at all. The operator CLI has no command to hide or delete a single post, comment, review or LFG post, and no way to list reported content.
- **CS-03 (High).** The content filter (README: about 40 ms per 1,000 adversarial characters) runs before rate limiting, and signed-in reads have no limit. One signed-in account can pin the single Node event loop for everyone.
- **CS-04 to CS-13 (Medium).**
  - Session tokens cannot be revoked, and deleting then re-creating an account revives every old token.
  - A user can vote or review the same skin under several uuids (level and chroma variants).
  - Three new sock-puppet accounts can hide any content.
  - Ratings are cheap to steer.
  - Uploaded pixel streams are passed through unchanged.
  - The consent sheet falsely says the PUUID never leaves the device.
  - The client ships Google ML Kit neural translation, which conflicts with "no AI".
  - Erasures are not replayed after a restore, and undo archives are kept forever.
  - Backups are on the same host, unencrypted, with no health signal.
  - IP limiting is bypassable (IPv6 /64 rotation, any Authorization header on media, leftmost X-Forwarded-For).

**Redis.** Not needed; keep SQLite (details in CS-40 and CS-41). The real bottlenecks are single-thread CPU in the filter and aggregate queries, which Redis would not fix.

**Quick wins (hours):**
1. Add CDN-cache and error `no-store` headers on media.
2. Check the token's `iat` against the user's creation time.
3. Move `rateLimit` before `cleanUserText`.
4. Fix the consent sentence.
5. Apply the IPv6 and XFF hardening.
6. Add a server CI workflow.

## Conventions

- `SRV` = `D:\ValVN\server\community\src\`
- `MIG` = `D:\ValVN\server\community\migrations\`
- `OPS` = `D:\ValVN\server\community\` (README, docker-compose.yml, Dockerfile, `ops\`, `scripts\`, `test\`)
- `APP` = `D:\ValVN\lib\features\community\`
- `LIB` = `D:\ValVN\lib\`
- `DOC` = `D:\ValVN\docs\`
- **Risk** column = risk of applying the fix (regression or compatibility), not the risk of the finding.
- "Unverified" means I could not confirm it from the repo or from outside the host.

## Findings (sorted by severity)

| ID | Severity | Area | File(s):line | Current behavior | Problem | Recommended solution | Risk | Effort | Dependencies |
|---|---|---|---|---|---|---|---|---|---|
| CS-01 | High | Media / CDN cache | SRV/routes/media.ts:101-119; live curl | Origin sends `Cache-Control: public, max-age=31536000, immutable`. Verified live: Cloudflare caches `/v1/media/*.jpg` by extension. A never-seen key returned 404 with CF-added `Cache-Control: max-age=14400`, and the second GET gave `cf-cache-status: HIT`, `Age: 29`. API paths are `DYNAMIC`. | Deleted, quarantined and erased-account images stay downloadable from the edge (200 caching inferred from headers, unverified because no media exists live). 404s are cached for clients for 4 h. This contradicts `DOC/legal/privacy.md:44,111` and the quarantine design. | Send `Cloudflare-CDN-Cache-Control: no-store` (or `max-age=60`) on 200s and `Cache-Control: no-store` on every error response. Keep the 1-year header for phones. Alternatives: a CF Cache Rule bypass for `/v1/media/*`, or purge-by-URL on delete or quarantine. | Low (more origin reads) | S | CF zone access only for rule or purge |
| CS-02 | High | Moderation enforcement | SRV/cli.ts:31-43; MIG (no sanction table); DOC/legal/community.md:60-63; DOC/legal/terms.md:86,130; DOC/legal/notice.md s.6 | Operator can only: unhide, list/restore/purge quarantined files, delete a whole user, export. No ban, suspend or restrict. No hide or delete of one post, comment, review or LFG. No list of reported or hidden content. A deleted or banned user signs in again with the same id (SRV/crypto.ts:4-6). No per-viewer block. Images go live instantly. | Published rules promise temporary restriction, permanent ban and urgent takedown, and nothing can enforce them. UGC risk (App Store 1.2 expects block plus timely action). | Migration `sanctions(user_id, kind, until, reason, created_at)` checked in `Ctx.user()` (403 `suspended`). CLI commands `ban`, `unban`, `hide`, `delete-content`, `reports list`, `hidden list`, with audit rows. Client-side block/mute list. Optionally fast-hide images on one report from an established account. Non-AI only. | Medium (policy, client release) | M | New migration; client release |
| CS-03 | High | Availability / rate limits | SRV/routes/posts.ts:134 then 167 and 226 then 228; SRV/routes/reviews.ts:47 then 48; SRV/routes/lfg.ts:135 then 142; SRV/context.ts:141-168; SRV/routes/public-guard.ts:24; OPS/test/abuse.test.ts:27-29; OPS/README.md note 57 | The moderation filter runs before `rateLimit()`, so an over-limit request still pays for it and rejected ones never count. Signed-in requests have no read limit (by design). `GET/PATCH /v1/me` and DELETE of posts, comments, reviews and LFG have none. Node is single-threaded with synchronous SQLite. | One signed-in account (cost: one Riot login) can send about 25 req/s of adversarial bodies and stall every user. Uncached aggregates for signed-in users add load. | Add a coarse per-user bucket (for example 120 req/min, any method) in `Ctx.user()`. Call `rateLimit` before `cleanUserText`. Cap tokens and runs per text. Run `moderate()` in a worker thread. Shed load when event-loop lag exceeds 200 ms. Add a test with an adversarial corpus. | Low | M | None |
| CS-04 | Medium | Sessions / revocation | SRV/crypto.ts:25,40-73; SRV/context.ts:141-156; SRV/routes/account.ts:21-26; OPS/test/account.test.ts:160-172 | HS256 JWT valid 30 days. `user()` only checks that the `sub` row exists. After delete the old token is 401, but re-sign-in re-creates the same id and every pre-deletion token validates again. No logout, `jti`, `kid` or per-user epoch. Rotating `SESSION_SECRET` logs everyone out. | A token stolen before the owner deleted their data, or from a lost phone, revives on next sign-in. A stolen session or a banned user's tokens cannot be ended. The test never checks the old token after re-sign-in (reasoned from code, not executed). | Immediate zero-schema fix: reject `claims.iat < floor(user.created_at/1000)`. Then a `session_epoch` (`ep` claim) bumped on delete, ban or logout, plus `POST /v1/auth/logout` and two-secret (`kid`) rotation. | Low | S then M | Migration; client logout call |
| CS-05 | Medium | Vote integrity | SRV/content.ts:54-72; SRV/routes/skins.ts:32-36; SRV/routes/reviews.ts:41-42; SRV/db/sqlite-repo.ts:268-283; MIG/0001_init.sql (skin_votes PK); DOC/community-api.md:251-255 | The catalog accepts base skin, level and chroma uuids as `skinUuid`. `weaponUuid` only has to be some real weapon, and the first vote or review pins it. The PK is `(user_id, skin_uuid)` on the exact string. | One account can vote or review one real skin under several uuids (base, up to 4 levels, chromas), against `DOC/legal/community.md:46`. Counts fragment. A wrong first `weaponUuid` permanently mis-files a skin. | Build `uuid -> {baseSkinUuid, weaponUuid}` from `/v1/weapons` (weapons, skins, levels, chromas). Store the canonical base uuid and the server-derived weapon, ignoring the client weapon. Merge existing rows in a migration. Keep fail-open until the catalog loads. | Medium (data merge) | M | valorant-api structure; migration |
| CS-06 | Medium | Report brigading | SRV/db/sqlite-repo.ts:733-777; SRV/context.ts:28; SRV/routes/posts.ts:29,256-280; DOC/community-api.md:257-268 | Three reports from distinct accounts that are at least 24 h old with at least 1 action hide any post, comment, review or LFG immediately. Post images are quarantined. Hidden stays hidden until CLI `unhide`. The author gets no signal (404 on own reads) and no appeal except email. No reporter reputation or per-target velocity logic. | Three sock-puppet Riot accounts (each waits 24 h and casts one vote) can censor any user. False reports leave no trace for the author. | Weight reporters (Riot account age if `/userinfo` exposes it, unverified; prior confirmed reports; distinct regions). Raise the threshold with audience size. Cap hides per reporter set per day. Expose `hidden` plus a reason code in the author's own lists. Add an in-app appeal and a CLI queue (CS-02). | Medium (tuning) | M | CS-02 |
| CS-07 | Medium | Rating integrity | SRV/routes/skins.ts:8-12,68-72; SRV/db/sqlite-repo.ts:346-389; SRV/routes/reviews.ts:35-63 | Any account can vote, rate and like immediately. Bayesian rank uses C=5, mean m, minimum 3 ratings. `period=week` counts edits (`updated_at`). | With m near 4.0, five new accounts giving 5 stars score (20+25)/10 = 4.5 and outrank a 200-review skin at 4.4 ((20+880)/205, about 4.39). Guidelines s.6 rests on Riot-login friction alone. | Count only established voters (reuse report eligibility, plus Riot account age if verifiable). Raise `MIN_RATINGS_FOR_RANK` to at least 10 and C to 10-20, or use a Wilson bound. Base the weekly board on first-rating time. Detect bursts of new accounts on one skin. | Low | S-M | Riot `/userinfo` fields (unverified) |
| CS-08 | Medium | Media / client safety | SRV/imaging.ts:6-13,24-26,253-334; SRV/routes/media.ts:56-68; APP/data/image_source.dart:19-49 | The sanitiser strips metadata and trailing data but leaves JPEG scans, PNG deflate and VP8/VP8L streams byte-identical. WebP and animated WebP are accepted. Limits are 50 MP and 16,384 px. | Crafted bitstreams (the CVE-2023-4863 libwebp class) reach every feed viewer, including anonymous ones. A 50 MP image decodes to about 200 MB and can OOM low-end phones unless the client decodes at reduced size. | Re-encode server-side in a memory-safe decoder (WASM such as jsquash or wasm-vips) with `MAX_PIXELS` about 16 MP. At minimum drop WebP and animation and lower the limits. Ensure the client uses `cacheWidth`/`memCacheWidth`. | Medium (CPU, memory, quality) | M | None (README records the no-sharp choice) |
| CS-09 | Medium | Privacy / consent text | APP/community_strings.dart:576-577 (shown at APP/ui/consent/consent_sheet.dart:131); DOC/research/riot-auth.md:182; DOC/legal/privacy.md:9,37,52 | The consent sheet says "Mật khẩu, cookie và PUUID của bạn không bao giờ rời khỏi máy". The uploaded access token is a JWT whose `sub` is the PUUID, and `/userinfo` returns it to the server (hashed into the id, never stored). | Inaccurate statement at the point of consent (GDPR Art. 13/7, NĐ13/2023). The policy is accurate; the sheet contradicts it. | Reword: the PUUID is read once in memory to derive an id and is never stored. Keep sheet, policy and docs from one source. | None | S | Legal wording review |
| CS-10 | Medium | Privacy / "no AI" directive | `D:\ValVN\pubspec.yaml:53`; APP/data/community_translator.dart:1-123; APP/providers/translation_providers.dart:7-13; APP/ui/widgets/translatable_text.dart:61,161; DOC/legal/privacy.md:78-83,121 | Client ships `google_mlkit_translation` (on-device neural translation) with a "Dịch" button. About 30 MB language models are downloaded from Google on demand. | Conflicts with "no AI features anywhere". The model download, and any SDK telemetry (unverified), contact Google, which privacy s.8 and s.13 do not list. | Remove the dependency, the translator, its providers and the button (or hard-disable behind a flag). If ever kept, disclose the Google downloads and add consent. | Low (feature loss) | S | Product decision; update DOC/ARCHITECTURE.md s.5.13 |
| CS-11 | Medium | Erasure vs backups | SRV/account.ts:12-18; SRV/db/sqlite-repo.ts:893-931; OPS/README.md:145-147; OPS/scripts/restore.sh:65-75 (`BACKUP_KEEP_DAYS=36500`); OPS/ops/backup-loop.sh:66-68 | Erasures via API or CLI leave no record. README says to re-apply erasure requests received since (API deletions are recorded nowhere). `restore.sh` writes the undo archive to `BACKUP_DIR/pre-restore/` with a 36,500-day retention, and the retention `find -maxdepth 1` never looks there. | After a restore, accounts erased since the backup silently reappear. Undo archives holding full personal data outlive the promised 14 days (`DOC/legal/privacy.md:96,112`). | Append-only erasure ledger outside the DB snapshot (for example `/data/erasures.jsonl`: id hash plus timestamp, kept at least the backup retention), replayed at boot and by `restore.sh`. Purge `pre-restore/` after 14 days or after a verified restore. | Low | M | None |
| CS-12 | Medium | Backups / DR | OPS/docker-compose.yml:54-82; OPS/ops/backup-loop.sh:23-91; OPS/scripts/restore.sh:43,71-80; OPS/README.md:118-151 | Daily tgz (snapshot plus media) on the same host, mode 0600 but unencrypted, retention `-mtime +14` (about 15 days). No healthcheck or alert on the backup container. Snapshot staged in a 512 MB tmpfs charged to a 256 MB memory limit. Restore extracts media into a 512 MB tmpfs. Restore exercised by hand once (README note 58), no scheduled drill. Host state unverified. | Host loss or ransomware loses data and backups together. A failing backup is silent. Backup and restore stop working once the DB exceeds about 190 MB or media about 450 MB. | Encrypted off-host copy (rclone/age, or Litestream with at most 72 h retention consistent with `privacy.md:96`). Healthcheck on newest-archive age plus an alert. Stage on disk (`/backup/.tmp`). Weekly automated restore drill (`integrity_check`, `foreign_key_check`, row and media counts). Fix the retention arithmetic. | Low | M | Object storage and credentials |
| CS-13 | Medium | IP limiting bypass | SRV/context.ts:171-184; SRV/config.ts:77; SRV/routes/public-guard.ts:24,41-48; SRV/routes/media.ts:93-120; SRV/cache.ts:34-60; OPS/test/abuse.test.ts:41-43 | Limiter key is the full `CF-Connecting-IP`, else the leftmost `X-Forwarded-For` (client-controlled), else the socket. `TRUST_PROXY` defaults to true. The guard skips limiting whenever any `Authorization` header exists, and the media GET never validates it. The limiter map is unbounded until the 10-min prune. | (a) IPv6 attacker rotating addresses in a /64 defeats the anon and `authIp` (30 per 10 min) limits. (b) `Authorization: x` removes the 1,500/min media limit (each cache miss is a DB read plus a file read of up to 2 MB). (c) A path reaching the origin without Cloudflare can spoof XFF. (d) The public feed exposes Riot ID and country to scrapers. | Hash the /64 prefix for IPv6. Drop the XFF fallback (or take the rightmost with a proxy allow-list) and default `TRUST_PROXY=false`. Apply the media limiter regardless of `Authorization`. Cap the limiter map (LRU). Add Cloudflare rate rules for `/v1/auth/riot`, `/v1/media` and `/v1/posts`. | Low | S | CF rules (optional) |
| CS-14 | Low | Rate limits / shared IPs | SRV/context.ts:58; SRV/routes/public-guard.ts:29-48; SRV/config.ts:65-66; OPS/README.md:59 | 30 sign-ins per 10 min and 120 uncached reads per minute per IP. Only aggregate endpoints are cached, so feed, post and comment reads count. Media alone got a NAT-friendly limit. | Carrier-grade NAT, campus and café IPs are shared. First-time visitors can get 429 on sign-in or feed (impact unverified in production). | Use NAT-aware thresholds (for example 300 auth per 10 min, 600 reads per minute). Count only failed Riot verifications toward `authIp`. Add a 5-10 s shared cache for anonymous feed pages. Key IPv6 on /64. | Low | S | Traffic data |
| CS-15 | Low | LFG code exposure | SRV/routes/lfg.ts:39-63,82-104,195-204; DOC/legal/terms.md:77; DOC/legal/community.md:39 | Every `GET /v1/lfg` item carries `partyCode` to any signed-in user, with no per-user read limit. `status=full` and `status=in_game` are also listable. Code ownership cannot be verified. | Bulk harvesting of live party codes enables party-bombing and griefing. Anyone can repost someone else's code. | Return the code only from `POST /v1/lfg/{id}/join` (limited, not own post) and keep it out of lists (send both until old clients age out). Restrict `status` filters to the owner. Add a per-user read limit (CS-03). | Medium (client change) | M | Client release |
| CS-16 | Low | LFG race | SRV/routes/lfg.ts:74-80,172-193; SRV/db/sqlite-repo.ts:154-178,230-250 | PATCH checks owner and expiry, awaits the body, then updates by id only. | A heartbeat racing a re-post extends the replaced (expired) row, giving two active posts for one user. No DB constraint for "one active". | Single statement `UPDATE ... WHERE id=@id AND user_id=@u AND expires_at>@now` and check `changes`. Or an `active` column with a partial unique index. | Low | S | None |
| CS-17 | Low | Media races / dangling rows | SRV/routes/posts.ts:152-160,167-183; SRV/db/sqlite-repo.ts:577-594 (line 590); SRV/routes/media.ts:70-90; MIG/0005_hardening.sql:10; SRV/sweeper.ts:55-59 | The attach `UPDATE media SET post_id` has no `post_id IS NULL` or status guard. Quota is checked before `await put`. `media.post_id` has no FK, and the sweeper only handles `post_id IS NULL`. | Two concurrent posts can claim one upload (deleting one 404s the other's image). Concurrent uploads overshoot quota by up to concurrency times 2 MB. Rows pointing at a vanished post are never swept and stay publicly served. | Guard the attach (`AND post_id IS NULL AND status='active'`, require `changes == keys.length` in the tx). Enforce quota inside the insert transaction. Sweep media whose post no longer exists. | Low | S | None |
| CS-18 | Low | Sanitiser allocation (unverified) | SRV/imaging.ts:128-131,232-244,260-271 | One `Uint8Array` per JPEG standalone marker (2 bytes), per kept PNG chunk and per WebP chunk is allocated before the file is validated. Only the 2 MB size is bounded. | A 2 MB file of `FF 01` markers implies about 1 M objects (estimate about 100 MB transient, not executed) against the 512 MB limit. One signed-in account suffices. | Cap segments and chunks (for example at most 2,048) and fail early. Run the sanitiser in a worker with `resourceLimits`. Fuzz worst cases. | Low | S | None |
| CS-19 | Low | Text sanitisation | SRV/validate.ts:93-106; SRV/moderation/filter.ts:790-818 | Stored text is only NFC and trimmed. The filter ignores invisible and bidi characters for matching but leaves them in the stored text. | RLO/isolates, zero-width characters, C0/C1, 1,000-newline or combining-mark floods can spoof, fingerprint or wreck layouts in posts, comments, notes and reviews. | Strip Cf/Cc except `\n`. Collapse 3 or more newlines. Cap combining marks per base. Test with the evasion corpus. | Low | S | None |
| CS-20 | Low | Moderation quality | SRV/moderation/filter.ts:643-706; SRV/moderation/vi-wordlist.ts:23; SRV/moderation/en-wordlist.ts:22-24; OPS/test/moderation.test.ts:45; OPS/README.md notes 43-44 | Lists are chosen from declared language, script and country. The Vietnamese list runs on Latin text only when language is absent, `vi` or `en` (or country VN). `https` links are kept (only `http` and shorteners are stripped). 14 of 16 lists are unreviewed. | "DM me", "cc" and "vl" are masked in English text (the test asserts `dm game lag` becomes `*** game lag`). Declaring `language: de` skips the Vietnamese list. Phishing links and phrasing like "acc for sale" pass. Unreviewed lists can over-block. | Always apply vi and en for Latin text. Allow-list link domains (client already renders links as plain text). Extend scam patterns. Native review before promoting lists. Count rejects per category to tune. | Low | M | Native reviewers |
| CS-21 | Low | Idempotency | SRV/routes/posts.ts:126-184,221-242; SRV/routes/media.ts:44-91 | No idempotency key or duplicate detection on post, comment or media create. Votes, likes, joins, reports and review PUT are idempotent. | Timeout then retry double-posts (bounded by 10/hour). Duplicate uploads burn quota until the 24 h orphan sweep. | Accept an optional `Idempotency-Key` (per-user 24 h table) or dedupe identical bodies within 60 s. | Low | S | None |
| CS-22 | Low | Docs vs IP-hash storage | SRV/context.ts:159-168; SRV/routes/auth.ts:20; SRV/db/sqlite-repo.ts:136-150; OPS/README.md:209 vs 255-257; DOC/community-api.md:379-380 | `authIp:<hash>` counters are SQLite rows (kept at most 1 day, so also in every backup for about 15 days). README's promise table says IPs exist "only ... in memory". | The README claim is inaccurate. A leaked pepper plus the DB lets the IPv4 space (2^32) be brute-forced. | Keep `authIp` counters in memory (or a non-backed-up store) and fix the README. The privacy.md wording is already compatible. | None | S | None |
| CS-23 | Low | Retention disclosure | SRV/db/sqlite-repo.ts:50-52,147-150; DOC/legal/privacy.md:40,92,94; OPS/README.md:201-202 | Expired and replaced LFG rows (party code, note, author) are kept 8 days for `/communities`. Accounts and content never expire. | Policy says LFG data is "xóa định kỳ" without the 8 days. Inactive accounts' content is kept indefinitely. | State 8 days in privacy s.10 or keep aggregates only. Add an inactivity retention (for example 24 months) or disclose "until you delete". | None | S | None |
| CS-24 | Low | Client-supplied fields | SRV/routes/auth.ts:23-28,51-64,80-95; SRV/routes/posts.ts:32-56,162-165; DOC/research/riot-auth.md:184 | `region`, `rankTier`, `cardId` and `language` come from the client (region editable via PATCH). Store and Night Market `cost` and `date` are unverifiable. `country` is server-derived from Riot (good). | Spoofed region or rank in LFG and region scopes. Fake "store" shares. `cardId` is any UUID. | Derive region from `/userinfo` `affinity` if present (listed at riot-auth.md:184, verify against a real response) or validate a client `id_token` via PAS. Validate `cardId` against the catalog. Label rank and store as self-reported and never use them for privileges. | Low | S-M | Real `/userinfo` sample |
| CS-25 | Low | Riot token handling | SRV/riot.ts:63-95; SRV/routes/auth.ts:33; DOC/legal/privacy.md:51-52,81 | The token is placed only in the `Authorization` header of one `fetch` (no redirect option, unbounded `res.text()`) and never logged. TLS terminates at Cloudflare before the tunnel. | Cloudflare can read the token in transit, while the policy says Cloudflare "chỉ chuyển tiếp". The token is a bearer credential valid up to 1 h. Cloudflare Logpush or header logging would expose it. | Disclose Cloudflare's role. Use `redirect: 'manual'` and a body cap. Keep Logpush and header logging off. | None | S | None |
| CS-26 | Low | Riot outbound load | SRV/riot.ts:82-95; SRV/routes/auth.ts:18-48 | Per-IP limit only. No global concurrency cap, backoff or negative cache for rejected tokens. | Many IPs (or IPv6) mean many concurrent calls from one server IP. A Riot 429 turns every sign-in into 503. | Global semaphore (about 20), a circuit breaker honouring `Retry-After`, and a 60 s negative cache keyed by token hash. | Low | S | None |
| CS-27 | Low | Riot identity | SRV/riot.ts:44-46; OPS/README.md note 3 | Missing `game_name` or `tag_line` is accepted and stored as empty strings. | Accounts without a Riot ID post with a blank author, weakening accountability and CLI lookup by Riot ID. | Treat as unavailable or invalid and require non-empty names. | Low (edge accounts locked out) | S | None |
| CS-28 | Low | Remote-config token sink | APP/providers/community_providers.dart:22-26; LIB/core/config/remote_config.dart:41,60-61,116-147; LIB/core/config/app_constants.dart:97-101 (`remoteConfigUrl = ''`); APP/data/community_http.dart:9-15 | The community base URL (where the Riot access token is sent) can be replaced by bundled, remote or cached config. Only https and a non-empty host are checked. `remoteConfigUrl` is empty today. | Latent credential-exfiltration path if the remote source or cached prefs are ever tampered with. | Remove `communityBaseUrl` from remote config, or pin to allow-listed hosts (`val.gianguyen.cloud`). | Low | S | None |
| CS-29 | Low | Container / network | OPS/docker-compose.yml:12-49; OPS/docker-compose.override.example.yml; OPS/Dockerfile:4,16; SRV/main.ts:46 | Strong hardening is in place (read-only root, cap_drop ALL, no-new-privileges, mem and pids limits, loopback publish). Gaps: the API joins the shared `edge` network, has no `cpus` limit or `init`, uses an unpinned `node:22-bookworm-slim`, and reads secrets via `env_file` (visible to `docker inspect`). Node `keepAliveTimeout` is the 5 s default versus cloudflared idle reuse (about 90 s), which may cause sporadic 502 (unverified). | Lateral movement from other `edge` tenants, host CPU starvation, base-image drift, secret exposure to docker-group users, intermittent 502. | Dedicated tunnel-to-API network. `cpus: "1.0"`, `init: true`. Pin the image digest and rebuild on a schedule. `_FILE` secrets. `server.keepAliveTimeout = 120000` plus `headersTimeout`. | Low | S | Host access |
| CS-30 | Low | CI | `D:\ValVN\.github\workflows\` (only android.yml, ios.yml) | No workflow builds or tests `server/community` (276 `it()` blocks in 21 files, `tsc`, `npm audit`, docker build). | Regressions and vulnerable dependencies are not caught before deploy. | Add `server.yml`: Node 22, `npm ci`, `typecheck`, `test`, `npm audit --omit=dev`, docker build plus an image scan, required on PR. | None | S | None |
| CS-31 | Low | Monitoring / health | SRV/main.ts:35-44; SRV/app.ts:46-54,73-85; OPS/README.md:109-116 | Access log is method, path, status and ms only (privacy-good). No aggregate security counters and no disk, WAL or event-loop metrics. `/healthz` is `SELECT 1`. Unhealthy containers are not restarted (README says so). | Abuse waves, disk-full or a wedged loop are noticed by users first. | Log 1-minute aggregate counters (401/429/5xx per route, no PII). Add a loopback-only deep health check (write probe, disk free, WAL size, loop lag). Add autoheal or a watchdog. Add a disk-space alert. | Low | S-M | Host access |
| CS-32 | Low | DB scale | SRV/db/sqlite-repo.ts:314-334,363-403,811-818; MIG/0001, 0002, 0004; SRV/db/database.ts:17-26 | Leaderboards `GROUP BY` over all votes and reviews on every uncached request. `SUM(size)` over `media` on each upload. 9 secondary indexes on `skin_votes` and 10 on `skin_reviews`. No `ANALYZE` or `PRAGMA optimize`, no periodic `VACUUM`. | Latency spikes that block the event loop at several 100 k rows, plus write amplification. Not an issue today: live data is empty. | Maintain `skin_stats` in the vote/review transaction (or refresh every 60 s) and a `user_media_bytes` counter. `PRAGMA optimize` daily. Prune redundant indexes with `EXPLAIN QUERY PLAN` tests. | Low | M | None |
| CS-33 | Low | i18n / UX | APP/data/community_exception.dart:183-187; SRV/errors.ts; SRV/moderation/filter.ts:21-22; SRV/routes/media.ts:73-75 | Server `message` strings are Vietnamese, and the client shows them verbatim for `invalid_input`. | The app is global (17 languages), so a Japanese user sees Vietnamese filter and quota errors. | Add stable `reason` codes (`content_inappropriate`, `content_scam`, `quota_exceeded` and so on) and map them to localized client strings. Keep `message` as fallback. | Low (additive) | S | None |
| CS-34 | Low | Consent record | APP/providers/consent_providers.dart:16-63; DOC/legal/privacy.md:69,177 | Consent is a local pref (`granted`) with no policy version or timestamp, and nothing is recorded server-side. | Consent cannot be demonstrated (GDPR Art. 7(1)), and the app cannot re-ask after a policy change as privacy s.18 promises. | Store `{version, at}` with the pref. Send `consentVersion` to `/v1/auth/riot` (store only version and time). Re-prompt when the version bumps. | Low | S | Optional migration |
| CS-35 | Low | Data-rights identity check | OPS/README.md:153-190; SRV/cli.ts:79-133 | Email export and erase needs only a Riot ID. Verification is "reply to the account email or add a marker". | Social engineering can leak another user's export (including reports they filed) or erase their data. | Prefer the in-app API. For email, require a one-time code shown in-app (needs a session). Log operator actions with timestamps. | Low | M | None |
| CS-36 | Low | Misc hardening | SRV/context.ts:187-199; OPS/.env.example:13; SRV/app.ts:73-85 | `baseUrl()` trusts `X-Forwarded-Host` when `PUBLIC_BASE_URL` is empty. The example placeholder host is accepted. Authenticated JSON has no `Cache-Control: no-store` (only export and delete). | Host-header injection into media URLs if misconfigured. Caching surprises behind other proxies. | Fail startup without a valid `PUBLIC_BASE_URL` in production and reject `*.example.*`. Add `no-store` to authenticated JSON. | Low | S | None |
| CS-37 | Low | Rate-limit reset | SRV/db/sqlite-repo.ts:918; SRV/routes/account.ts:21-26 | `DELETE /v1/me` deletes every `rate_limits` bucket ending with the user id (including `accountDelete`), and sign-in re-creates the same id. | Per-user limits (votes, likes, comments) reset via delete plus re-auth. | Keep counters until their window ends (they hold no PII), or use a 1 h tombstone. | Low | S | None |
| CS-38 | Low | Content catalog | SRV/content.ts:45,104-120,137-149; SRV/main.ts:23-24 | Fails open until the first successful fetch and during outages after a restart. An unknown id on a set older than 10 min makes the request await a download (20 s timeout). Body size is checked after `res.text()`. | Junk uuids can be stored in the start-up window. An authenticated user can force periodic awaited refreshes. A 30 MB body is read fully. | Persist a catalog snapshot to disk and load it at boot. Refresh in the background only. Check `content-length` first. | Low | S | None |
| CS-39 | Low | Erasure/export drift | OPS/test/account.test.ts:105-158 | Coverage is asserted only for known tables. No test enumerates tables referencing users. | A future table with `user_id` can be forgotten in export or erasure. | Test that enumerates FKs to `users` plus columns named `*user_id` or `reporter_id` and fails unless covered by `buildExport` and `deleteAccountRows`. | None | S | None |
| CS-40 | Info | PostgreSQL readiness | SRV/db/repo.ts:236-239; SRV/geo/scope.ts:71-79; SRV/db/sqlite-repo.ts:197,536,916,958; MIG/0005:15-17; MIG/0001; SRV/db/database.ts:29-52; OPS/test/helpers.ts:50-53 | All SQL is in `db/` except `geoCondition` (SQLite `@name` fragments in `geo/scope.ts`). `Repo` is synchronous (better-sqlite3), has about 60 methods and no `transaction()`. Business rules (report eligibility, LFG replace, weapon pinning) live in SQL. Tests run only on in-memory SQLite. Check-then-act code relies on Node's single thread. | A PG port needs an async interface, a dialect move, contract tests and race fixes (CS-16, CS-17). Dialect items: `json_each`, `COLLATE NOCASE`, scalar `MAX()`, `randomblob`, `UPDATE ... FROM`, `WITHOUT ROWID`, `@named` params. | Make `Repo` async now (compiler-guided). Split it (Users, Content, Moderation, Media, RateLimit). Move `geoCondition` into the repo. Write an engine-parametrized contract suite. Fix races first. Add an ETL script. Migrate only when multi-node, HA or size demands it. | Medium | L | CS-16, CS-17 |
| CS-41 | Info | Redis / seams | SRV/context.ts:69-71,158-168; SRV/cache.ts:1-60; SRV/db/repo.ts:247-248 | The in-process `FixedWindowLimiter` and `TtlCache` are constructed inside `Ctx`. User limits are SQLite rows. Sessions are stateless. Single container. Live data is empty. | Not needed today. Redis would add a moving part without fixing the real bottlenecks (single-thread CPU in the filter and aggregates). | Keep SQLite. Add injected async `RateLimitStore`, `CacheStore` and `RevocationStore` interfaces in `AppDeps`, with the current implementations as defaults. Add a Redis adapter only when two or more API replicas run (INCR+EXPIRE, SET EX, a small set for revoked epochs, `SET NX PX` for the sweeper lock). | Low | S | None |

## Route authorization and limits matrix (verified in code)

| Route | Auth | Ownership / visibility rule (evidence) | Rate limit |
|---|---|---|---|
| POST `/v1/auth/riot` | Riot token, verified via `/userinfo` (auth.ts:22-64) | n/a | `authIp` 30 per 10 min per IP (auth.ts:20) |
| GET/PATCH `/v1/me` | Required (auth.ts:78-95) | Self | None |
| GET `/v1/me/export` | Required | Token subject only (routes/account.ts:8-19) | 5/h |
| DELETE `/v1/me` | Required | Token subject only (routes/account.ts:21-26) | 3/h |
| GET `/v1/lfg`, `/v1/lfg/mine` | Required | Public data / self | None |
| POST `/v1/lfg` | Required | Own | 6 per 10 min |
| PATCH `/v1/lfg/:id` | Required | Owner 403, expired 404 (lfg.ts:74-80; test lfg-v2.test.ts:203) | 120 per 10 min |
| POST `/v1/lfg/:id/join` | Required | Not own 403, hidden or expired 404 (lfg.ts:195-204) | 30 per 10 min |
| DELETE `/v1/lfg/:id` | Required | Owner 403 (lfg.ts:206-215; test lfg.test.ts:110) | None |
| PUT/DELETE `/v1/skins/:s/vote` | Required | Self | 120/h |
| GET skins top, votes, summary, reviews; GET communities | Optional (invalid token gives 401) | Public | Anon: 120/min per IP plus 45 s cache. Signed-in: none |
| PUT `/v1/skins/:s/review` | Required | Own upsert (unique user+skin) | 30/h |
| DELETE `/v1/skins/:s/review`, DELETE `/v1/reviews/:id` | Required | Owner (reviews.ts:65-70,126-134; test reviews.test.ts:246) | None |
| PUT/DELETE `/v1/reviews/:id/like` | Required | Not own 403, hidden 404 (reviews.ts:116-124) | 120/h |
| GET `/v1/posts`, `/:id`, `/:id/comments` | Optional | Hidden gives 404 (posts.ts:96-102) | Anon: 120/min per IP. Signed-in: none |
| POST `/v1/posts` | Required | Media must be own, active and unattached (posts.ts:152-160; test media-lifecycle.test.ts:152) | 10/h |
| DELETE `/v1/posts/:id` | Required | Owner 403 (posts.ts:186-196; test posts.test.ts:274) | None |
| PUT/DELETE `/v1/posts/:id/like` | Required | Visible posts | 120/h |
| POST `/v1/posts/:id/comments` | Required | Visible post | 30 per 10 min |
| DELETE `/v1/comments/:id` | Required | Owner (post owner cannot) (posts.ts:244-252; test posts.test.ts:256) | None |
| POST `/v1/reports` | Required | Target must exist. Own content silently ignored. Always 204 (posts.ts:256-280) | 20/h |
| POST `/v1/media` | Required | Own directory | 20/h plus quotas (limit checked before body read, media.ts:52) |
| GET `/v1/media/:key` | None | Active row only (media.ts:98-99) | Anon 1,500/min per IP, bypassable (CS-13) |
| GET `/healthz` | None | n/a | None |

## Verified correct (evidence)

**Authentication**
- HS256 only, with a fixed header check and constant-time HMAC compare. The token is capped at 4,096 chars, and the claim shape, `sub` format and expiry are checked (`SRV/crypto.ts:40-73`). Tests cover expired, tampered and foreign-signed tokens (`OPS/test/auth.test.ts:104-135`).
- `SESSION_SECRET` and `PEPPER` must be at least 32 chars or the process exits (`SRV/config.ts:23-36`).
- A present but invalid token is 401 even on public reads (`SRV/context.ts:141-156`).
- The user row is loaded on every request, so a deleted user gets 401 (`SRV/context.ts:153-154`; `account.test.ts:160-166`).
- The Riot check runs server-side. The body is validated before Riot is called. Riot answers map to 401 versus 503, including Cloudflare HTML. The user row is written only after success. `country` comes only from Riot and is ignored from clients (`SRV/routes/auth.ts:22-64,83-84`; `SRV/riot.ts:31-95`).
- The token appears only in the `/userinfo` header and is never logged. The access log has no IP, query or headers, and the error log has names and messages only (`SRV/main.ts:35-44`; `SRV/app.ts:78-79`; test `auth.test.ts:43`).
- The user id is a peppered hash and the PUUID is never stored (`SRV/crypto.ts:4-6`).

**Authorization and injection**
- All mutation routes take the user from the token and compare row ownership (matrix above). Media attach uses `WHERE user_id = @user` (`SRV/db/sqlite-repo.ts:590`).
- There is no admin HTTP surface. Probes of `/metrics`, `/debug/pprof`, `/v1/admin` and `/robots.txt` all returned 404.
- Every SQL statement is parameterised. Dynamic parts come only from constant maps (`SRV/db/sqlite-repo.ts:718-723`).

**Input validation**
- Path uuids are checked with a UUID regex (`SRV/validate.ts:28`). Media keys use a strict regex (`SRV/media.ts:15`). Party codes are checked with `PARTY_CODE_RE`.
- Enums, rank 0-27, dates, lengths in code points, array sizes (media at most 4, offers at most 6, roles at most 4, agents at most 5) and costs are bounded (`SRV/routes/posts.ts:26-56`; `SRV/validate.ts`).
- `limit` is 1-50 (100 for skins). Cursors are at most 200 chars, base64url, typed, and use a keyset with an id tie-break (`SRV/cursor.ts:17-39`).
- Country parsing guards against prototype keys (`SRV/geo/countries.ts:263-267`).
- JSON bodies are capped at 64 KB (`SRV/app.ts:17-40`). Uploads are streamed and aborted at 2 MB (`SRV/routes/media.ts:17-39`).

**Media**
- The store guards traversal twice (`SRV/media.ts:88-93`). Writes use temp file plus rename.
- The declared type must match the magic bytes (`SRV/routes/media.ts:47-59`).
- EXIF, GPS, XMP, IPTC, comments, thumbnails, PNG text and time chunks, WebP EXIF and trailing data are dropped. Only orientation survives (`SRV/imaging.ts`).
- Only active rows are served. Responses carry `nosniff`, CSP `sandbox`, `Content-Disposition: inline` and CORP (`SRV/routes/media.ts:98-110`).
- Per-user (50 MB) and global (2 GB) quotas apply (`media.ts:71-79`).
- Rows are deleted before files, so serving stops at once (`SRV/media-service.ts:17-27`).
- Sweeps cover orphans after 24 h, quarantine after 30 days, strays after 1 h and reports after 12 months (`SRV/sweeper.ts:4-10,49-87`).
- No clickable links appear in community UI (no `launchUrl` or linkify under `APP`).

**Deletion and export**
- Deletion runs in one transaction. It covers reports about the user's content, anonymising reports the user filed, the like-counter correction, rate-limit rows and cascades from the user row. Files are removed afterwards, including quarantined copies (`SRV/db/sqlite-repo.ts:893-931`; `SRV/account.ts:12-18`; tests `account.test.ts:105-197`).
- The export covers all 10 tables holding user data plus the user row, with no PUUID or IP (`SRV/account.ts:30-132`; `SRV/db/sqlite-repo.ts:868-891`).
- All FKs to `users` cascade, and `foreign_keys` is on (`SRV/db/database.ts:22`).
- `like_count` is maintained in transactions and corrected on erasure. Post like and comment counts are computed, so they cannot drift.

**Data model and concurrency**
- Votes, likes, joins and reports are idempotent through PK and `ON CONFLICT DO NOTHING`. Reviews are unique per (user, skin) (`MIG/0001`, `MIG/0002`).
- Review upsert, review like counters, reports, LFG replace and post-plus-media attach run in transactions.
- Every list query has a matching index in migrations 0001-0005 (checked query by query). The index-count concern is only CS-32.

**Ops (repo level)**
- Compose hardening: read-only root, `cap_drop: ALL`, no-new-privileges, `mem_limit`, `pids_limit`, tmpfs, loopback-only published port, log rotation, healthcheck (`OPS/docker-compose.yml:22-49,69-82`). Image runs as `node`.
- No secret is committed. `.env` is git-ignored, no `.env` was ever added in history, and `.dockerignore` excludes tests and `.env`.
- Backup uses the SQLite online-backup API, `integrity_check`, an archive test, an atomic rename, and retention only after a successful backup (`OPS/ops/backup-loop.sh:32-66`).
- `restore.sh` verifies the archive, saves an undo archive, and waits for `/healthz` (`OPS/scripts/restore.sh:43-111`).

**Client**
- No token or Riot call happens without consent (`APP/data/community_auth.dart:57-67,141-143`). Anonymous reads send no Authorization header (`APP/data/community_api.dart:629-641`).
- The session lives in secure storage, is wiped on sign-out (`LIB/core/storage/secure_store.dart:29`) and on delete or withdraw (`community_auth.dart:127-138`; `APP/providers/data_rights_providers.dart:100-122`).
- Tokens are never printed (`APP/data/community_models.dart:355-356`). The base URL must be https (`community_http.dart:9-15`).
- A 401 gets one re-sign-in retry, and there is no automatic replay of POSTs (`community_api.dart:654-667`; `LIB/core/network/dio_factory.dart:31-45`).
- Error mapping handles HTML and missing bodies (`APP/data/community_exception.dart:91-121`).
- Images are downscaled to 1,600 px as JPEG q85 before upload (`APP/data/image_source.dart:19-49`). The server strips metadata regardless.

**Live (read-only)**
- HTTP redirects to HTTPS. HSTS preload and `nosniff` are present. API paths are `cf-cache-status: DYNAMIC`.
- Cloudflare managed rules answered 403 on `/.env`.
- Protected routes return 401 without a token. Error bodies follow the documented format.
- `/v1/posts`, `/v1/skins/top` and `/v1/communities` are all empty.

## Privacy and legal promises vs implementation

| Promise (source) | Status | Evidence |
|---|---|---|
| The Riot token is sent only once, after consent, to verify the Riot ID; declining sends nothing (privacy.md:9,49-54) | Implemented | `community_auth.dart:57-67,141-143`; `community_api.dart:629-641` |
| The server uses the token once, discards it, never stores or logs it (privacy.md:52) | Implemented at the origin. Cloudflare sees plaintext in transit (CS-25) | `SRV/riot.ts:82-95`; `SRV/main.ts:35-44` |
| The PUUID is not stored or returned (privacy.md:9,37) | Implemented. The consent sheet wording contradicts it (CS-09) | `SRV/crypto.ts:4-6`; `test/auth.test.ts:43` |
| Country comes from Riot and cannot be edited (privacy.md:36) | Implemented | `SRV/routes/auth.ts:58,83-84` |
| The community session lasts 30 days, is in secure storage, and is wiped on sign-out (privacy.md:53,97,103) | Local wipe implemented. Server token is not revoked (CS-04) | `community_auth.dart:127-138` |
| Access log is method, path, status and time; IP only as a salted hash for limits (privacy.md:43,95) | Implemented. `authIp` hashes persist in SQLite and backups (CS-22) | `SRV/main.ts:35-44`; `sqlite-repo.ts:136-150` |
| Images are public by URL, deleted with the post or account, EXIF stripped (privacy.md:44,111) | Implemented at the origin. Edge cache defeats deletion (CS-01) | `SRV/routes/media.ts`; `SRV/imaging.ts`; live curl |
| Hidden images are quarantined and deleted after 30 days; unused uploads after 24 h (privacy.md:111) | Implemented, same edge caveat | `SRV/sweeper.ts:4-10,49-66` |
| Reports are kept at most 12 months, orphans deleted, the user's own reports anonymised on erase (privacy.md:94) | Implemented | `sweeper.ts:82-87`; `sqlite-repo.ts:779-788,915-917` |
| Backups daily, kept 14 days (privacy.md:45,96,112) | About 15 days. Older files persist if backups fail, and `pre-restore/` is kept forever (CS-11, CS-12) | `backup-loop.sh:66,72`; `restore.sh:72` |
| In-app erase of all community data, irreversible (privacy.md:110) | Implemented. Restore can resurrect it (CS-11) | `sqlite-repo.ts:893-931`; `test/account.test.ts:105-158` |
| In-app JSON export (privacy.md:152) | Implemented | `SRV/account.ts:30-132` |
| Email requests handled within 30 days after verification (privacy.md:110,152) | Process only, weak verification (CS-35) | `README.md:153-190` |
| LFG posts expire 30 min after the last heartbeat; expired data "xóa định kỳ" (privacy.md:40,92) | Partly: 8-day retention undisclosed (CS-23) | `sqlite-repo.ts:50-52` |
| No analytics, crash reporting, ads or tracking (privacy.md:121) | Implemented apart from ML Kit model download and telemetry (unverified) (CS-10) | pubspec deps; pubspec.yaml:53 |
| Local notifications only, no push server or device tokens (privacy.md:117) | Implemented | No device table in `MIG` |
| Users can delete only their own content (privacy.md:128) | Implemented | Route matrix above |
| Cloudflare only relays traffic (privacy.md:33,81) | Not strictly true: TLS ends at the edge (CS-25) | Tunnel design (README:76-96) |
| Reporters are anonymous to the reported user (community.md:50) | Implemented | `posts.ts:256-280`; `test/abuse.test.ts:236-253` |
| Enough reports from different users auto-hide content (community.md:52) | Implemented (eligibility is stricter than the text) | `sqlite-repo.ts:733-777` |
| Temporary restriction and permanent ban (community.md:61-62; terms.md:86,130) | Not implemented (CS-02) | `SRV/cli.ts`; no sanction table |
| One vote per account per skin (community.md:46) | Partly (CS-05) | `content.ts:54-72` |
| The server never acts on the Riot account (privacy.md:54; DOC/community-api.md:406-408) | Implemented | Only `/userinfo` in `riot.ts` |
| Party codes are visible to anyone viewing the post (terms.md:77) | Implemented (signed-in viewers) | `lfg.ts:39-63` |
| IP-infringement reports by email (notice.md s.6) | Manual only, no content-level CLI (CS-02) | `cli.ts:31-43` |

## Redis and PostgreSQL

Keep SQLite in WAL mode. Write volume is tiny, the deployment is one container, sessions are stateless, and the live data is empty. Latency risk comes from single-thread CPU in the filter and aggregate queries, which Redis does not fix (fixes in CS-03 and CS-32).

The scaling path is a move to PostgreSQL, not Redis. Do that only when you run more than one node, need HA or failover, or the DB reaches roughly 10-20 GB (readiness in CS-40). Litestream is a cheaper interim step for off-host backups (CS-12).

Redis becomes worthwhile only with two or more API replicas, for shared limiter counters, cache and a sweeper lock. The clean seam for it is CS-41.

## Unverified items and read-only commands for when SSH returns

**Unverified**
- Host state:
  - containers and applied hardening flags
  - `.env` permissions and that `PUBLIC_BASE_URL` is set
  - backup archive count, age, size and permissions
  - disk free space and log volume
  - the `edge` network membership
  - the cloudflared ingress config
  - firewall rules
- Cloudflare side:
  - custom WAF and rate-limit rules
  - Cache Rules
  - Logpush
  - Access
  - that `CF-Connecting-IP` actually reaches the origin (per-IP limiting would silently degrade otherwise)
- Whether Cloudflare caches 200 media responses (inferred from origin headers plus the live 404 caching).
- Whether `/userinfo` exposes `acct.created_at` or `affinity` (not documented in the repo).
- Sanitiser memory amplification (CS-18), Node keep-alive 502s (CS-29), ML Kit telemetry (CS-10), and `npm audit` results.

**Commands to run (none print secrets)**
```
docker ps --format '{{.Names}} {{.Status}} {{.Ports}}'
docker inspect valvn-community --format '{{.HostConfig.ReadonlyRootfs}} {{.HostConfig.CapDrop}} {{.HostConfig.Memory}} {{.HostConfig.PidsLimit}} {{.HostConfig.RestartPolicy.Name}}'
docker inspect valvn-community --format '{{range .Config.Env}}{{println .}}{{end}}' | cut -d= -f1
stat -c '%a %U %n' /home/huy/stacks/valvn-community/.env
ls -l --time-style=long-iso /home/huy/backups/valvn-community | tail -20
df -h /var/lib/docker /home
docker logs --tail 50 valvn-community | cut -c1-200
```

## Suggested order of work

1. **CS-01:** media cache headers and error `no-store`.
2. **CS-04:** the `iat` versus `created_at` check.
3. **CS-03:** reorder rate limits and add a per-user bucket.
4. **CS-09 and CS-10:** fix the consent text; remove ML Kit.
5. **CS-13:** IPv6 /64 keying, drop the XFF fallback, media limiter fix.
6. **CS-02:** sanctions table plus CLI takedown and hide commands.
7. **CS-05:** canonical skin uuid and derived weapon.
8. **CS-11 and CS-12:** erasure ledger, `pre-restore` retention, off-host encrypted backups, restore drill.
9. **CS-30:** server CI.
10. **CS-08:** decide on re-encoding uploads.