# ValVN Community server

Backend for the app's "Cộng đồng" tab: LFG (tìm đồng đội, v2 with rank range / roles / live party
status / joins), skin votes, inventory-verified skin reviews (stars + text), separate plain skin comments, feed posts with images /
likes / comments / reports, country / region / global community scopes (v3), and a multi-language content
filter. API contract: [`docs/community-api.md`](../../docs/community-api.md).

- Node 22 + TypeScript, [Hono](https://hono.dev) on `@hono/node-server`, listening on `PORT` (default 8080).
- SQLite via `better-sqlite3` (WAL) at `$DATA_DIR/community.db`; migrations in `migrations/` are applied
  automatically at startup and tracked in `schema_migrations`.
- Uploaded images on disk at `$DATA_DIR/media/u/<userId>/<random>.<ext>` (public) and, when hidden by
  reports, `$DATA_DIR/quarantine/…` (private).
- Self-hosted: Docker on the owner's Debian server, behind a Cloudflare Tunnel (see Deploy).

## Layout

```
src/
  main.ts            process entry: config, DB, HTTP server, periodic sweeper, graceful shutdown
  app.ts             createApp(deps) — Hono app, error handling, body limits
  context.ts         shared helpers: auth, rate limits, tuning, base URL, serializers, content checks
  cli.ts             operator CLI (find / export / delete a user, ban / restrict / unban, hide / delete-content,
                     reports list, hidden list, audit list, quarantine, unhide, stats, sweep)
  account.ts         right to erasure + export (used by the API and the CLI)
  sweeper.ts         periodic housekeeping (orphan uploads, quarantine expiry, stray files, old reports, ...)
  imaging.ts         metadata-stripping JPEG / PNG / WebP sanitiser (pure TypeScript)
  media.ts           MediaStore (disk: public + quarantine areas), magic-byte sniffing
  media-service.ts   delete / quarantine helpers shared by routes, sweeper and CLI
  content.ts         valorant-api catalog (real skin / weapon / agent uuids), 24 h cache
  cache.ts           in-memory TTL cache and fixed-window limiter (anonymous traffic)
  routes/            auth, account, lfg, skins, reviews, skin-comments, communities, posts (+ likes, comments, reports),
                     media, public-guard (anonymous rate limit + cache)
  geo/               countries.ts (ISO 3166-1 alpha-3 -> alpha-2, 249 entries), languages.ts (the 17 app languages),
                     scope.ts (country / region / global resolution + SQL condition)
  moderation/        filter.ts (normalise, match, mask/reject, links, phones, which lists apply), wordlists.ts (registry),
                     vi-wordlist.ts + en-wordlist.ts (reviewed), lists/<lang>.ts (14 best-effort lists, NEEDS NATIVE REVIEW)
  db/                database.ts (open + migrate), repo.ts (Repo interface), sqlite-repo.ts
  load.ts            event-loop lag monitor (load shedding)      metrics.ts   aggregate counters (no user data)
  reasons.ts         stable error reason codes + Vietnamese / English texts
  config.ts crypto.ts cursor.ts errors.ts riot.ts validate.ts
migrations/          0001_init.sql ... 0013_skin_comments.sql — additive; never edit an applied migration
ops/backup-loop.sh   the valvn-backup service's loop        scripts/restore.sh   restore from a backup archive
test/                vitest (in-memory SQLite + temp dirs, stubbed Riot /userinfo, fake clock)
```

Everything external is injected into `createApp({ repo, media, config, riotUserinfo, content, now })`, so tests
never touch the network or the real clock.

## Configuration (env)

Build 4021 local evidence: [catalog/discussion checkpoint](../../docs/SKIN_CATALOG_AND_DISCUSSION_2026-10-04.md).
Plain comments require a Community session but no skin ownership. Star reviews
require Riot identity/inventory proof; client ownership flags never authorize a
review. `skin_comment` reports, own export and erasure use the existing systems.
The production service must be updated before the new comment routes are usable.

The runtime image contains Node, native production dependencies and age, with
npm/corepack removed after the build. Use the existing `node dist/cli.js` operator
commands; package installation remains in the build stage. Runtime PCRE is
explicitly refreshed along with age. Image scanning retains the existing
CRITICAL/HIGH and ignore-unfixed policy; no vulnerability suppression was added.

| Var | Required | Meaning |
|---|---|---|
| `SESSION_SECRET` | yes, ≥ 32 chars | HS256 key for community session tokens (30 days). Replacing it logs everyone out unless you rotate with `SESSION_SECRET_PREV` (note 61). |
| `SESSION_SECRET_PREV` | no, ≥ 32 chars | The previous secret during a rotation: tokens signed with it are still accepted (never used to sign). Remove it after 30 days. |
| `PEPPER` | yes, ≥ 32 chars | user id = `hex(sha256(PEPPER + puuid))[0..32]`; also salts the hashed IPs. **Never change after launch.** |
| `PUBLIC_BASE_URL` | yes in production | HTTPS public origin for media URLs, e.g. `https://val.gianguyen.cloud`; placeholder hosts, credentials, query and fragment are rejected. Development may derive it from the request. |
| `TRUST_PROXY` | no (default **`false`**) | Believe `CF-Connecting-IP` (client address) and `X-Forwarded-Proto/Host`. `docker-compose.yml` sets it to `true` (`${TRUST_PROXY:-true}`) because that stack is reached through the Cloudflare Tunnel only; a server reachable without Cloudflare must leave it `false`. Even when true, the header is only believed if the TCP peer is a loopback / private address (note 64). |
| `PORT` | no (8080) | |
| `DATA_DIR` | no (`/data`) | SQLite file + `media/` + `quarantine/`. |
| `MEDIA_USER_QUOTA_MB` | no (50) | Per-user image storage. Over it: `400 invalid_input` with a readable message. |
| `MEDIA_MAX_TOTAL_MB` | no (2048) | Total image storage. Over it: `507 storage_full`. |
| `ANON_READ_LIMIT_PER_MIN` | no (600) | Requests without a session per client IP per minute (feed, skins, communities). Generous on purpose: many phones share one carrier-grade-NAT address. |
| `ANON_MEDIA_LIMIT_PER_MIN` | no (1500) | Same, for image files (generous: many phones share one carrier-grade-NAT address). |
| `PUBLIC_CACHE_TTL_SECONDS` | no (45) | Cache of anonymous aggregate responses; `0` = off. |
| `PUBLIC_FEED_CACHE_SECONDS` | no (5) | Cache of an anonymous feed page (`GET /v1/posts`), shared by every anonymous viewer; `0` = off. |
| `USER_REQUEST_LIMIT_PER_MIN` | no (240) | Requests per signed-in user per minute, any method and route (`429 rate_limited`, `params.bucket = "requests"`); a coarse valve above the per-action limits (10 - 1,000,000). |
| `LOAD_SHED_LAG_MS` | no (250) | Event-loop lag above which every request except `/healthz` is answered `503 server_busy` + `Retry-After: 2` (load shedding, see note 59); `0` = off. |
| `MEDIA_EDGE_CACHE_SECONDS` | no (0) | How long Cloudflare's edge may keep an image (`Cloudflare-CDN-Cache-Control`). `0` = `no-store`: deleted / quarantined images stop being served at once. Devices always keep the 1-year `Cache-Control`. A value <= 60 trades a short deletion lag for fewer origin reads. |
| `BACKUP_DIR`, `BACKUP_KEEP_DAYS`, `BACKUP_INTERVAL_SECONDS` | no | Backup service: writable host directory (`./backups`, uid 1000), retention (1–14 days, default 14), period (≥60 seconds, default 86400). |
| `BACKUP_OFFSITE_CMD`, `BACKUP_AGE_RECIPIENT` | no | Optional operator command and age public recipient. Hook receives `BACKUP_FILE`, pointing only to the encrypted `.tgz.age`; failure prevents the success stamp. |
| `SESSION_SECRET_FILE`, `SESSION_SECRET_PREV_FILE`, `PEPPER_FILE` | no | Read a secret from a mounted file instead of the corresponding env value; setting both is rejected. Compose secret mounts must be provided by the operator. |
| `LFG_CODE_IN_LIST` | no (true) | Compatibility flag: false hides another author's party code in lists; join returns it. Keep true until the updated app requests the code before joining. |

The process exits immediately with a clear message if a secret is missing / too short or a number is out of range.

## Development

```bash
cd server/community
npm ci --ignore-scripts
npm test            # vitest
npm run typecheck   # tsc --noEmit
cp .env.example .env   # fill secrets, set DATA_DIR=./data
npm run dev         # tsx watch on :8080
```

## Deploy (self-hosted: Docker + Cloudflare Tunnel)

Production is Docker Compose on the owner's Debian server (`/home/huy/stacks/valvn-community`), published as
`https://val.gianguyen.cloud` through the Cloudflare Tunnel `cf-gianguyen`. `cloudflared` runs in its own stack and
reaches the API over the shared Docker network `edge` (service `http://valvn-community:8080`).

```bash
cd server/community
cp .env.example .env               # fill SESSION_SECRET, PEPPER (openssl rand -hex 32 each), PUBLIC_BASE_URL
chmod 600 .env
mkdir -p backups && chown 1000:1000 backups && chmod 700 backups
cp docker-compose.override.example.yml docker-compose.override.yml   # joins the external `edge` network

docker compose build
docker compose up -d               # valvn-community (API) + valvn-backup (daily backups)
docker compose ps                  # both "Up", the API becomes "healthy"
curl -s http://127.0.0.1:8787/healthz   # {"ok":true}
docker compose logs -f valvn-community
```

- `docker-compose.yml` publishes only `127.0.0.1:8787 → 8080`. Without the shared network, point the tunnel at
  `http://127.0.0.1:8787` instead (`cloudflared` on the host) — the override file is only for the `edge` network.
- **Update:** `git pull && docker compose build && docker compose up -d` (migrations run at start; each one is
  additive, so rolling back the image is safe: the previous version simply ignores the new columns).
- **Hardening** (both services): read-only root filesystem, `cap_drop: [ALL]`, `no-new-privileges`, non-root
  user, `mem_limit` (API 512 MB, backup 256 MB), `pids_limit` (128 / 64), size-limited `tmpfs /tmp`, json-file
  logs rotated (10 MB × 3). The only writable paths are the data volume and `/tmp`.
- **Moving from the old host-only setup:** the `valvn-backup` service used to live in
  `docker-compose.override.yml` on the server, reading `backup-loop.sh` from the stack directory. It is now part
  of `docker-compose.yml` with `ops/backup-loop.sh`: delete the `valvn-backup` block from the host's override
  (keep only the `edge` network), set `BACKUP_DIR=/home/huy/backups/valvn-community` in `.env`, then
  `docker compose up -d` (the container is recreated; existing archives are kept and count toward retention).

### Cloudflare and media caching (CS-01)

Cloudflare's default cache level caches static file extensions (`.jpg`, `.png`, `.webp`) **whatever the origin says**,
and it also caches error pages for them (a 404 for a media path was seen with `cf-cache-status: HIT`). The origin
therefore sends, on every media `200` / `304`, `Cache-Control: public, max-age=31536000, immutable` (devices) **and**
`Cloudflare-CDN-Cache-Control: no-store` (the edge; overrides `Cache-Control` for Cloudflare only), and
`Cache-Control: no-store` on **every** other response (errors included, JSON included). This is what makes a
deleted, quarantined or erased image disappear from the edge together with the database row.

**Verify after every deploy** (twice; the second answer must not be a `HIT`):

```bash
curl -sI https://val.gianguyen.cloud/v1/media/u/<userId>/<key>.jpg | grep -i -E 'cf-cache-status|cache-control|age'
curl -sI https://val.gianguyen.cloud/v1/media/u/00000000000000000000000000000000/00000000000000000000000000000000.jpg
# expected: HTTP 404, cache-control: no-store, cf-cache-status: DYNAMIC (or BYPASS) - never HIT
```

**Fallback if the edge still answers `HIT`** (a Cache Rule or Page Rule with `Cache Everything` / `Ignore cache-control`
on the zone overrides origin headers): Cloudflare dashboard -> Caching -> Cache Rules -> Create rule, expression
`(starts_with(http.request.uri.path, "/v1/media/"))`, action **Bypass cache** (place it above other cache rules).
To remove one image that is already cached: Caching -> Configuration -> Purge Cache -> Custom Purge -> URL.

### Restart policy and health

`restart: unless-stopped` restarts a container whose process exits (crash, out-of-memory kill, host reboot) but
Docker **never restarts a container only because its health check fails**. The API's health check (`GET /healthz`
every 30 s, 3 retries) shows `unhealthy` in `docker compose ps`.

Enable the monitoring profile with `docker compose --profile monitoring up -d`. `valvn-watchdog` shares the API
network namespace and reads `/healthz/deep` over actual loopback; it reads backup markers through a read-only
mount. It alerts immediately for an unwritable disk, free space below 128 MiB, WAL above 128 MiB, backup older
than its interval plus two hours, or a restore drill older than eight days. Three consecutive failed probes,
samples with at least 200 ms lag, or windows of at least 20 requests with at least 5% server errors trigger
their own alerts. Health probes are excluded from the request totals. Each sample emits bounded JSON containing
fixed codes, and its health check detects a stalled watchdog process.

Logs remain available without an alert destination. For delivery, mount a reviewed executable using a Compose
override and set `WATCHDOG_ALERT_HOOK=/hooks/alert`. It receives `alert|recovered` followed by fixed codes;
execution has a ten-second timeout, no shell, and no inherited app secrets. Alerts repeat hourly while a fault
persists. No destination or credentials are fabricated. A faulty/hung API requires operator investigation and,
if appropriate, `docker compose restart valvn-community`; the watchdog has no Docker socket or restart rights.
Test one sample inside the shared network namespace with `node dist/watchdog.js --once`.

### Backup

The `valvn-backup` service takes an online SQLite snapshot and copies only active media referenced by that
snapshot, plus `/data/erasures.jsonl`. It verifies database integrity, foreign keys and every media file size,
then atomically renames a mode-0600 `.tgz` archive. Staging uses `BACKUP_DIR/.tmp` on disk. A racing media deletion
fails that run instead of publishing an incomplete snapshot. Quarantine is excluded.

Every run performs verification; once a week an extracted copy runs migrations and erasure replay, then is
verified again. `last-success` and `last-drill` drive the backup container healthcheck (success within two
intervals + one hour, drill within eight days). The loop retries after failures and runs retention even when
backup fails: archives expire at 1–14 days, undo archives at 14 days, abandoned staging at 24 hours.
One-off backup: `docker compose run --rm -e BACKUP_ONCE=1 valvn-backup`.

Optional off-site transfer: set `BACKUP_AGE_RECIPIENT` to the destination's age public key and
`BACKUP_OFFSITE_CMD` to a reviewed uploader available inside the backup container. The hook receives
`BACKUP_FILE` as the encrypted `.tgz.age` path; the private decryption key stays off-host. Configure credentials
and executable mounts in an operator override, and enforce ≤14-day remote retention. No remote destination is
configured by this repository. To restore encrypted data, decrypt it to a protected `.tgz` first.

Keep the backup directory mode 700 and `.env` (especially `PEPPER`) backed up separately. Deleted data can
remain in old archives up to 14 days; restore replay removes erased accounts before serving. The current erasure
ledger must survive independently of an old archive: copy it securely off-host after erasures. If the whole host
and that current ledger are lost, a stale backup cannot know deletions received afterwards.

### Restore runbook

```bash
cd server/community
# 1. check the archive, change nothing
scripts/restore.sh ~/backups/valvn-community/valvn-community-20260930-0300.tgz
# 2. restore for real
scripts/restore.sh ~/backups/valvn-community/valvn-community-20260930-0300.tgz --yes
```

`--yes` verifies the archive (`integrity_check`), stops the services, **saves the current data as a normal
backup archive in `BACKUP_DIR/pre-restore/`** (the undo), replaces `community.db` (+ WAL) and `media/`, drops rows of
quarantined files (the quarantine directory is not in backups), starts the services, waits for `/healthz` and prints
row counts. To undo, run the script on the archive in `pre-restore/`. Afterwards check `docker compose logs
valvn-community` and open the app. Notes:

- Restore keeps the current erasure ledger, merges the snapshot ledger and replays it **before restart**. Startup also replays it before listening. Corrupt ledger entries fail closed; recover the ledger before serving. Account recreation after a recorded deletion is preserved.
- Restoring to a new host: install Docker, copy `.env` (same `PEPPER`), `docker compose build`, then run the script
  (it starts from an empty volume: `docker compose up -d` once first, or `docker volume create valvn-community-data`).
- Manual restore without the script: stop the services, extract `snap.db` as `community.db` and `media/` into the
  volume, delete `community.db-wal` / `-shm`, preserve/merge the latest ledger, run `node dist/cli.js replay-erasures`, then start.

## Data-rights runbook (requests by email)

The API exposes both rights (for the app to call): `GET /v1/me/export` (JSON download, 5 / hour) and
`DELETE /v1/me` (hard delete, 3 / hour). For a request that arrives by email, use the operator CLI inside the
container — it runs exactly the same code as the API:

```bash
# 1. find the account by Riot ID (no PUUID is stored: the id is a salted hash)
docker compose exec valvn-community node dist/cli.js find --riot "Name#TAG"

# 2. ACCESS / PORTABILITY: everything we store about it, as JSON (media as URLs)
docker compose exec valvn-community node dist/cli.js export --riot "Name#TAG" > export.json

# 3. ERASURE: dry run first (prints what would go), then for real
docker compose exec valvn-community node dist/cli.js delete --riot "Name#TAG"
docker compose exec valvn-community node dist/cli.js delete --riot "Name#TAG" --yes
```

Erasure removes: posts (with their comments and likes), comments, reviews (with likes), likes, votes, LFG posts and
joins, uploaded images (public and quarantined files) and the user row. **Reports the user
filed** are kept but anonymised (`reporter_id` → `anon-…`, free text cleared) because they may have hidden
content; reports **about** their content are deleted. Backups keep older copies for up to 14 days (see Backup).
**Verify account ownership before acting.** Use the authenticated in-app API whenever possible.
Use the API or CLI for erasure; direct SQL skips the durable ledger and media lifecycle.
For email requests, prefer directing the verified account holder to the in-app export/delete actions. A Riot ID
alone does not prove ownership. The server cannot access Riot account email; any manual identity verification
must happen before the operator invokes the CLI. A one-time in-app verification code is future client work.

## Moderation runbook

- Content hidden when eligible report weights reach 3 (see note 53) disappears from lists; its images move to
  `quarantine/` (404 on `/v1/media`) and are purged after 30 days.
- `node dist/cli.js quarantine list` lists them; `quarantine restore <key>` puts one back; `quarantine purge <key>`
  deletes it now. **False reports:** `node dist/cli.js unhide post|comment|lfg|review <uuid>` un-hides the content,
  forgets its reports and restores its images.
- **Sanctions and takedowns (note 62).** All commands are run as `docker compose exec valvn-community node dist/cli.js …`; a
  command that changes something needs `--yes` (without it: a dry run, exit code 2) and writes a row to the audit table.
  `--reason` is a code: `spam harassment hate scam nsfw evasion minor illegal other` (the user sees the code, never free text).

  ```bash
  ... reports list                          # reported items: reporters, eligible reporters, state, excerpt (newest first)
  ... hidden list                           # everything hidden, by reports or by a moderator
  ... hide post <uuid>                      # hide one post / comment / lfg / review now (post images are quarantined)
  ... delete-content review <uuid> --yes    # delete one item for good (its comments, likes, images and reports too)
  ... restrict --riot "Name#TAG" --days 7 --reason spam --yes   # read-only for 7 days
  ... ban --riot "Name#TAG" --reason harassment --yes            # permanent (add --days N for a timed ban)
  ... unban --riot "Name#TAG"               # lift every active sanction of the account
  ... sanctions list --active               # who is sanctioned now (also: --id, --riot, --limit)
  ... audit list --riot "Name#TAG"          # what operators did about an account (also without --riot: latest actions)
  ```

  **Appeals** (community guidelines, section 9): the author writes to the address in the app's legal notice with their
  Riot ID; look at `audit list --riot …`, `reports list` and `hidden list`, then `unhide` / `unban`. The author sees
  that something is hidden, and by whom (`hidden: true`, `hiddenReason` `reports` or `moderator`), in their own lists.
- `node dist/cli.js stats` (row counts, image bytes, quarantined files) and `node dist/cli.js sweep` (run the
  housekeeping now). The sweeper runs by itself every 10 minutes (and 5 s after start): orphan uploads (> 24 h),
  quarantine (> 30 days), stray files without a database row, reports older than 12 months and reports about
  deleted content, rate-limit windows, LFG rows expired for more than 8 days.

## Privacy promises and where they are implemented

| Promise | Implementation |
|---|---|
| Riot token never stored / logged | only in the `Authorization` header of the `/userinfo` call; access log has no query / headers |
| PUUID never stored | `hex(sha256(PEPPER + puuid))[0..32]`; IPs only as peppered hashes **in memory** (anonymous reads, sign-in attempts): nothing about an address is written to the database or to backups (CS-22) |
| Photos carry no location / camera data | `imaging.ts` strips EXIF / GPS / XMP / IPTC / comments / thumbnails on upload (note 47) |
| Deleted content is deleted | post delete removes its images; account delete removes everything (notes 50, 52); orphan uploads purged after 24 h |
| Reports are kept 12 months at most | sweeper deletes reports older than 365 days and reports on deleted content |
| Sanctions outlive an erasure (abuse prevention, legitimate interest) | `sanctions` has no foreign key to users: a ban / restriction (user id hash, kind, end, reason code, time) stays after `DELETE /v1/me` so an erased account cannot start over; ended sanctions are swept after 12 months, operator log rows after 24 months (note 62). **The privacy policy must say so.** |
| Export and erasure on request | `GET /v1/me/export`, `DELETE /v1/me`, CLI runbook above |
| Backups | 14 days, mode 0600 / dir 0700, quarantine excluded; deleted data lives on in them until they age out |
| Riot IDs are public **by design** | authors of posts / comments / reviews / LFG show their Riot ID, region, country, rank and card to every reader (that is what makes the feature useful); users consent in the app before their first sign-in and can erase everything |

## Notes (spec gaps / decisions)

Behaviour chosen where `docs/community-api.md` is silent or ambiguous:

1. **Auth on reads.** Only `GET /v1/skins/top`, `GET /v1/skins/votes` (marked "auth optional") and
   `GET /v1/media/{key}` (public) work without a token. All other endpoints, including
   `GET /v1/lfg`, `GET /v1/posts`, `GET /v1/posts/{id}` and comment lists, require a session.
   On auth-optional endpoints a *present but invalid/expired* token is still rejected with 401 so the
   client knows to refresh. (v3 made the feed public too, see 37; anonymous traffic is limited, see 54.)
2. **Error body for 429:** `{"error": {"code": "rate_limited", "message": "…", "retryAfter": N}}`
   (retryAfter inside the error object) plus the `Retry-After` header.
3. **Riot unreachable** (network error / timeout / 429 / 5xx / HTML) → `503 riot_unavailable`, not
   `riot_rejected`, so the client does not discard a possibly valid Riot session (see 55).
   Missing `game_name`/`tag_line` → empty strings.
4. **PUUID normalisation:** the `sub` is trimmed and lower-cased before hashing.
5. **UUID input** (path params, `weaponUuid`, `cardId`, `skinUuid` in payloads, `targetId`) is
   accepted in any case and normalised to lower-case; ids that are not UUIDs are rejected with 400
   (or 404 for path ids of posts/comments/LFG).
6. **Status codes:** all successful creates return `200` with the resource (no `201`); deletes and
   reports return `204`. Wrong method on a known path → `404 not_found`. Oversized JSON bodies
   (> 64 KB) and images (> 2 MB) → `400 invalid_input`.
7. **LFG:** `region` and `mode` filters on `GET /v1/lfg` are both optional (no filter = all).
   If `rankTier` is omitted on create it defaults to the author's profile rank (explicit `null` = none).
   `note` is trimmed; an empty note is stored as `null`. Deleting an expired / hidden own post is allowed.
8. **Skin votes:** base, level and chroma UUIDs resolve to one base skin. The server derives its weapon from the
   catalog; a persisted alias table merges historic collisions. Without a known mapping, the first weapon is pinned
   until a catalog refresh canonicalizes it. Catalog mappings survive restart.
   `GET /v1/skins/top` default `limit` is 20. `ids` duplicates are collapsed; order is preserved.
   PUT and DELETE both count toward the 120/hour vote limit.
9. **Posts:** `payload` is required for `store` / `nightmarket` and forbidden for `text`. Payload is
   normalised (unknown fields dropped); `offers` must have 1–6 entries; costs are integers
   0..1,000,000; `discountPercent` 0..100; `discountCost ≤ baseCost`; `date` must be a real calendar
   date. `body` is trimmed. A media key that does not exist → 400; one owned by another user → 403.
   Deleting a post deletes its likes, comments and images (see 50).
10. **Counts:** `comments` on a post counts only non-hidden comments. Likes on hidden posts → 404.
11. **Reports:** `targetId` must be an existing UUID target (else 404); `reason` is free text,
    1–200 chars. Re-reporting is idempotent; self-reports are accepted (204) but not counted; only reports
    from established accounts count toward hiding (see 53).
    Hidden content is excluded from lists and returns 404 on direct GET; the author can still delete it.
12. **Extra rate limits** not in the spec: likes 120/hour per user, and `POST /v1/auth/riot` per client address (note 64:
    300 attempts and 30 rejected tokens per 10 min, in memory as peppered hashes). Per-user limits use fixed windows
    stored in SQLite, so they survive restarts.
13. **Media:** content-type must be `image/jpeg|png|webp` *and* match the magic bytes. `GET` sends
    `Cache-Control: public, max-age=31536000, immutable` (+ `Cloudflare-CDN-Cache-Control: no-store`), an `ETag`, and
    honours `If-None-Match` (304).
    Files are sanitised on upload and served with hardened headers (see 47–49).
14. **Housekeeping:** superseded by the sweeper (see 51).
15. String length limits count Unicode code points (so Vietnamese diacritics count as one character).
16. **Migrations** are strictly additive: `0002_reviews.sql` (skin_reviews, review_likes) and
    `0003_lfg_v2.sql` (`ALTER TABLE lfg_posts ADD COLUMN …` + lfg_joins). `reports.target_type` never had
    a CHECK constraint, so accepting `review` needed no schema change.

### Skin reviews

17. Editing a review (PUT again) keeps its `id`, `createdAt`, likes and hidden flag (editing cannot
    un-hide a reported review); only `rating`, `body` and `updatedAt` change.
    `DELETE /v1/skins/{skin}/review` is idempotent (204 even without a review).
18. `sort=new` orders by `createdAt` (edits do not bump a review). `sort=top` = like count desc, then
    newest; its cursor also carries the like count, and a cursor from one sort order is rejected (400)
    by the other. Likes can change between pages, so a review may rarely repeat/skip across pages.
19. `myReview` in the summary is returned to its author even when hidden by reports (so they can see
    or delete it). Hidden reviews are excluded from lists, averages, counts and the distribution, and
    liking them returns 404. Liking or unliking your own review → 403.
20. `period=week` counts votes cast and reviews first created (`createdAt`) in the last 7 days; edits do not bump the week;
    `ratingAvg` / `ratingCount` / `reviewCount` in `/v1/skins/top` follow the same period.
21. `sort=rating`: `m` is the mean of all visible ratings in the period across **all** weapons (the
    `weapon` filter only restricts which skins are ranked); ties → more ratings, then skin uuid.
    `sort=reviews`: skins with at least one visible rating, ordered by `reviewCount` (non-empty body),
    then `ratingCount`. `sort=votes` lists skins that have votes, as before.
22. A known skin's `weaponUuid` comes from the catalog (even without activity); an unmapped skin falls back to
    its first vote or review. Only established, unsanctioned accounts contribute to public votes and rating statistics:
    age ≥24 hours plus a visible post/comment/review, vote or like. Choices from new accounts are saved immediately.
    Rating ranking requires ≥10 ratings and uses Bayesian C=15.

### LFG v2

23. Rank range: `0` (or absent) on either side means "no bound" on that side, so `rankMin ≤ rankMax`
    is only enforced when both are non-zero. `rank=<tier>` keeps posts whose bounds contain the tier.
24. `role=<role>` keeps posts that need that role **or list no roles** (open to anyone).
    `language=vi|en` keeps posts in that language or `any`; `language=any` disables the filter.
    `status` accepts `open` (default), `full`, `in_game`.
25. PATCH on an expired post → 404 (a heartbeat cannot revive it; the client posts a new one).
    `partySize` / `slots` / `status` cannot be `null`; `note: null` clears the note.
    `partySize + slots` is not constrained (a full party keeps its last `slots`).
26. `POST /v1/lfg/{id}/join` requires an open party; full/in-game posts or the owner return 403, expired/hidden posts
    return 404. It returns `{joins, partyCode}`. Joins are dropped when the owner replaces the post. Rows created before v2 report
    `partySize = 5 - slots` and `updatedAt = createdAt`.
27. Extra rate limits: PATCH 120 / 10 min (a 20 s heartbeat fits easily), join 30 / 10 min.
    Reviews 30 / hour (create + edit); review likes share the 120 / hour likes limit with post likes.

### Content filter (`src/moderation/`)

28. Applied to post bodies, comments, review bodies and LFG notes (create and PATCH), after length
    validation. Profanity is masked with `***`. Hate, sexual harassment and "kill yourself"-style
    harassment → 400 `Nội dung chứa từ ngữ không phù hợp`. Account selling / boosting ads and phone
    numbers → 400 with a separate message. Report `reason` and Riot names are not filtered.
29. Matching is per whole word or phrase. Words listed **without** accents match any accenting
    (`dm` ↔ `đm`); words listed **with** accents only match that form, which keeps `đĩ`≠`đi`,
    `lồn`≠`lon`, `cặc`≠`các`, `buồi`≠`buổi`, `đéo`≠`đeo`. As a consequence, unaccented spellings of those
    ambiguous words are only caught inside listed phrases (`dit me`, `du ma`, …). Elongations match only
    when the word really has repeated letters (`đmmmm`, `fuuuck`). Words that are also common innocent
    words were left out on purpose (`éo` / éo le, `hiếp` / ức hiếp, `xoạc` / xoạc chân, `ba que` / bà quê,
    `cl` / Champions League, `óc chó` / walnut). `bắc kỳ` is rejected even though it is also a
    historical place name.
30. Links: `http://`, scheme-less `www.` and URL-shortener links (list in `vi-wordlist.ts`) are removed;
    other `https://` links are kept verbatim and excluded from word matching. Bare domains without
    `www.` (e.g. `example.com`) are left alone unless they are known shorteners. If stripping leaves a
    post or comment empty, it is rejected as empty.

### Community scopes v3

31. **Migration `0004_scopes.sql` is additive** (`ALTER TABLE … ADD COLUMN`, `UPDATE` backfill, new
    indexes) and safe on the live database. Old clients keep working: every new request field is optional,
    every new response field is additive (`country`, `language`, `appliedScope`, …), and explicit old
    parameters (`GET /v1/lfg?region=ap`) behave as before.
32. **Country** comes only from Riot `/userinfo` (`country`, alpha-3, any case) and is stored as ISO alpha-2
    (`vnm` → `VN`; table in `src/geo/countries.ts`, all 249 assigned codes). Missing / unknown → `null`.
    It is overwritten on every `POST /v1/auth/riot` (so it also becomes `null` if Riot stops sending one).
    A `country` sent by the client (auth body or `PATCH /v1/me`) is ignored, like any unknown field.
33. **Language.** `language` (auth body, `PATCH /v1/me`, per-item `language`) accepts the 17 codes in any case
    and also `_` or a region suffix: `pt-BR` → `pt`, `es-MX` → `es`, `zh_CN` / `zh-Hans` / `zh-SG` → `zh-CN`,
    `zh-HK` / `zh-Hant` → `zh-TW`; bare `zh` is rejected (script unknown). `null` is rejected. When auth omits
    `language` the stored value is kept (`null` for a user who never sent one).
34. **Content values are frozen at creation.** Posts, comments and reviews store the author's `country`,
    `region` and `language` when created (a per-item `language` overrides the author's); LFG posts store the
    author's `country` (region / party language come from the request). Moving country / shard or changing the
    app language later does not touch old content. Editing a review keeps its country / region; its `language`
    changes only when the edit sends one.
35. **Votes and ratings count by the voter's country / region at the time of the vote / review** (`skin_votes`
    and `skin_reviews` carry them). Re-sending a vote is idempotent, so it keeps the original values.
    A user without a country still counts in `region` and `global` scope, never in a country's.
36. **Scope resolution** (`src/geo/scope.ts`): an explicit `scope` wins; without it a `country` param implies
    `country` scope, a `region` param implies `region`, otherwise the endpoint default applies. Feed default =
    `country`, LFG default = `region`, skins (top / votes / summary / reviews) default = `global`. Where the spec
    scope table lists the skin leaderboard under "country" but the endpoint table says `scope=global`, the
    endpoint table (`global`) is implemented; clients pass `scope=country` explicitly. A `country` scope with no
    country (param or viewer) falls back to `region` (param or the viewer's shard), then to `global`; the applied
    result is returned as `appliedScope: {scope, country, region}` on feed / LFG / reviews lists, skins top /
    votes and summary. Params that do not belong to the resolved scope are ignored. `country` must be a real
    ISO alpha-2 code.
37. `GET /v1/posts` (and `/v1/posts/{id}` and its comments) is readable **without a session** (scope `global`,
    `liked: false`); an invalid token is still 401. LFG lists still require a session. Public reads are not
    rate-limited **per client address** since the hardening work (note 54).
38. **`language` filters** (comma lists of the 17 codes) on the feed and reviews match the item's stored text
    language exactly, so rows with no language (created before v3, or by clients that never sent one) are
    excluded **only when the filter is used**. LFG's `language` matches the party language or `any`;
    `language=any` (or a list containing `any`) disables the filter.
39. **LFG party language** now accepts the 17 codes plus `any` (old `vi | en | any` still fine). When omitted it
    defaults to the author's language, and to `any` when the author never sent one. Old stored party languages are retained.
40. **Replaced LFG posts are kept (expired), not deleted**, so `/v1/communities` can count a week of LFG
    activity; their joins are deleted and they are purged 8 days after expiry. `GET /v1/lfg/mine`, lists and
    `join` only see unexpired posts, as before. `DELETE /v1/lfg/{id}` on such an expired own post now answers
    204 instead of 404.
41. **`GET /v1/communities`** (public): `period=week` (default, last 7 days) or `all`. `posts` = visible posts,
    `lfg` = LFG posts (including replaced ones), `authors` = distinct users among those, all grouped by the
    author's country at creation time; content without a country is not listed. Sorted by posts, then lfg,
    authors, country code. Comments and hidden content are not counted.
42. **Backfill** (in the migration): `region` of old posts / comments / reviews / votes is copied from their
    author's shard (`lfg_posts` already had its own), so they stay visible in `region` and `global` scope.
    `country` / `language` stay `NULL` on old rows (hence invisible in a country scope); users get theirs at
    their next `POST /v1/auth/riot`.

### Content filter v3 (per language)

43. `moderate(text, {language, country})` applies: English always; the list of the text's language (the item's
    `language`, else the author's; `zh-CN` / `zh-TW` share `zh`); lists implied by the script / charset
    (Hangul → ko, kana → ja, Han → zh, Thai → th, Arabic script → ar, Cyrillic → ru, Vietnamese letters → vi,
    ß → de, ñ ¿ ¡ → es, ą ę ł → pl, ğ ı ş → tr); the Vietnamese list applies only to declared `vi`, VN country or
    detected Vietnamese script, preserving English gaming abbreviations such as DM/CC. Also use the local-language list implied
    by the author's country (VN → vi, MX → es, BR → pt, DE → de, TR → tr, ID → id, …). Text in a language
    without a list (Hindi, Greek, Hebrew, Swahili, …) only gets English matching and is **never** rejected for
    that.
44. **vi and en are reviewed; the other 14 lists (ar de es fr id it ja ko pl pt ru th tr zh) are best-effort and
    marked NEEDS NATIVE REVIEW** (`reviewed: false`, a banner in each `src/moderation/lists/<lang>.ts`, and
    `LISTS_NEEDING_NATIVE_REVIEW`; a test checks the banners). Expect false negatives; ordinary words that are
    also insults were left out on purpose and are listed at the top of each file. Entry syntax (see
    `types.ts`): `word`, `two words`, `stem*` (prefix, inflected languages), `*part*` (substring, for Chinese /
    Japanese / Thai), plus per-list `exceptions` (e.g. Korean `병신년`, Thai `เหี้ยม`, Japanese `おかまいなく`).
45. Phone numbers: Vietnamese numbers as before, plus international numbers written with a leading `+` and a
    country code (8–15 digits, separators allowed). Local formats of other countries are not detected.

### Hardening and privacy (migration 0005)

46. **Migration `0005_hardening.sql`** (additive, safe on the live database): `media` gains `post_id`, `status`
    (`active` | `quarantined`) and `quarantined_at` (backfilled from the posts' `media` JSON: files already used by a
    post are attached to it); `reports` is rebuilt without its foreign key to `users` (same columns, data copied) so
    a deleted account's reports can be anonymised instead of deleted; two indexes for the media sweep and the report
    retention sweep. Old clients are unaffected: no request or response shape changed except the new error codes
    (`riot_unavailable` 503, `storage_full` 507), which old clients show as their generic server-error message.
47. **Uploads are sanitised** (`src/imaging.ts`, pure TypeScript, no native dependency). JPEG: only known structure is
    kept (SOF, DQT, DHT, DAC, DRI, DNL, SOS + scan data, a canonical JFIF header without thumbnail, ICC profile,
    Adobe marker); EXIF (incl. GPS), XMP, IPTC / Photoshop, comments, MPF, thumbnails and every unknown / extension
    marker are dropped, and so is anything after EOI. PNG: whitelist of `IHDR PLTE IDAT IEND tRNS gAMA cHRM sRGB
    iCCP sBIT bKGD` (text, `eXIf`, `tIME`, APNG chunks dropped; CRCs untouched), data after `IEND` dropped. WebP:
    `VP8 VP8L VP8X ALPH ICCP` kept; animation flags / `ANIM` / `ANMF` rejected, `EXIF` / `XMP` dropped, RIFF size and VP8X flags rebuilt. **Only the EXIF
    orientation** is kept, rewritten as a 26-byte block, so phone photos are not shown sideways. Files that are not
    structurally valid images (truncated, bad segment lengths, no scan / IDAT / IEND) or larger than 16 megapixels /
    8,192 px a side are refused with 400 (client-side decompression bombs). `sharp` was evaluated and not used: it
    adds ~30 MB of prebuilt libvips per platform (glibc / musl / arm), more memory per upload and a larger attack
    surface to do what a small parser does exactly; the trade-off is that pixels are not re-encoded (no generation
    loss, but also no removal of data hidden *inside* the pixel stream). A fuzz test mutates valid files 1,500 times
    and checks that nothing but `ImageError` is thrown, no metadata survives and a second pass changes nothing.
48. **Storage quotas.** Per user (`MEDIA_USER_QUOTA_MB`, default 50, counted on the sanitised size of active +
    quarantined files): `400 invalid_input` with a readable Vietnamese message (a user problem, and old clients
    show `invalid_input` messages). Total (`MEDIA_MAX_TOTAL_MB`, default 2048): `507 storage_full` (a server
    problem). Deleting posts / accounts frees space immediately.
49. **Serving media.** `GET /v1/media/{key}` needs an *active database row*: deleted, quarantined and stray files are
    404 even if bytes remain on disk. Responses carry `Content-Disposition: inline`, `X-Content-Type-Options: nosniff`,
    `Content-Security-Policy: default-src 'none'; img-src 'self' data:; sandbox`, `Referrer-Policy: no-referrer`,
    `Cross-Origin-Resource-Policy: cross-origin`, the 1-year immutable `Cache-Control` for devices and
    `Cloudflare-CDN-Cache-Control: no-store` for the edge (304s too, see "Cloudflare and media caching"). Every error
    response, and every response without its own `Cache-Control`, is `Cache-Control: no-store`.
50. **Media lifecycle.** A file is attached to its post when the post is created (same transaction); it cannot be used by
    a second post (400) and quarantined files cannot be attached. **Post deleted by its author** → files and rows deleted
    (public and quarantined copies). **Post newly hidden by reports** → row `quarantined`, file moved to
    `$DATA_DIR/quarantine/`, 404 on `/v1/media`, purged after 30 days; **un-hiding** is a moderator action
    (`cli unhide`). **Account deleted** → all its files. **Uploaded but never attached** for 24 h → deleted. A file
    on disk without a database row (failed delete, crash between file and row) is deleted by the sweeper after 1 h.
    Files of posts hidden before this feature existed are quarantined by the first sweep.
51. **Sweeper** (`src/sweeper.ts`, inside the server process, every 10 minutes and 5 s after start, `unref`'d, never
    overlapping, each step independent and tolerant of failures): hidden-post media catch-up, orphan uploads (> 24 h),
    quarantine expiry (> 30 days), stray files, **reports older than 12 months** (a report is personal data; a post that
    was hidden stays hidden), **reports about content that no longer exists**, rate-limit windows older than 1 day,
    LFG rows expired for more than 8 days, and the in-memory limiter / cache. Results are logged only when non-zero.
52. **`DELETE /v1/me`** (auth, 3 / hour, `204`) hard-deletes the account: posts (with comments and likes), comments,
    reviews (with likes), likes, votes, LFG posts and joins, media rows and files, the user row. **Rate-limit counters are
    kept** until their window ends (they hold only the id and a count, nothing else; deleting them would let delete +
    sign-in reset every per-user limit, CS-37).
    Reports it filed are anonymised (`reporter_id` = `anon-<random>`, `reason` cleared); reports about its content are
    deleted; the like counters of other people's reviews are decremented; the (empty) upload directory is removed.
    The session token stops working at once (401). Signing in again with the same Riot account creates an empty
    account with the same id. **`GET /v1/me/export`** (auth, 5 / hour) returns one JSON document (`format:
    valvn-community-export/1`, `Content-Disposition: attachment`, `no-store`): profile, posts (media as URLs, hidden
    flag), comments, reviews, post / review likes, votes (with the country / region stored at vote time), LFG posts and
    joins, reports it filed, media list. Nothing about other people's private data; no PUUID or IP exists to export.
53. **Report-hiding rule.** A report is always accepted and stored (`204`), but only reports from **established accounts**
    contribute weight toward the threshold of 3: age at least **24 hours** and activity (a visible post/comment/review,
    vote or like), with no active sanction. Each contributes weight 1, or 2 after a report on content currently hidden
    by a moderator. Each reporter can contribute to at most 3 automatic hides per UTC day. Eligibility is re-evaluated whenever a new
    report about the same target arrives (so reports from accounts that have matured since count then). The author's
    own reports never count (not even stored); duplicates are ignored; the answer is the same empty `204` in every
    case, so a reporter cannot tell whether their report counted, hid the content, or who else reported. Reports are
    exposed nowhere except in the reporter's own export (`reportsFiled`) and the operator CLI. Reviewers' and authors'
    Riot IDs are public by design (privacy policy).
54. **Anonymous traffic.** Requests without an `Authorization` header to the public reads (`/v1/posts…`, `/v1/skins/…`,
    `/v1/communities`) are limited per client address (note 64, hashed with the pepper, **in memory only**):
    `ANON_READ_LIMIT_PER_MIN` (600); image files have their own `ANON_MEDIA_LIMIT_PER_MIN` (1500) that an
    `Authorization` header does **not** skip (image files never look at it). Responses served from the cache are not counted (they cost no database work). Over the limit: `429` with `Retry-After`. Signed-in requests are limited per
    user only. If no IP is known (in-process tests) the limit is skipped. **Cache:** anonymous `GET /v1/skins/top`,
    `/votes`, `/{uuid}/summary`, `/{uuid}/reviews` and `/v1/communities` are cached for `PUBLIC_CACHE_TTL_SECONDS` (45)
    per path + sorted query (max 500 entries, errors never cached): an anonymous viewer can see data up to 45 s old;
    signed-in requests are never cached and see live data. The anonymous feed page `GET /v1/posts` is cached for
    `PUBLIC_FEED_CACHE_SECONDS` (5), per query. Responses show `x-cache: hit|miss`.
55. **Riot errors** (replaces note 3): `POST /v1/auth/riot` maps Riot's answer to `401 riot_rejected` only for a real
    refusal of the token (400 / 401 / 403 with a non-HTML body). Everything else is `503 riot_unavailable` with
    `Retry-After` (Riot's, clamped to 1–300 s, when present): 429, 5xx, 408, redirects, timeouts and network errors,
    HTML pages (Cloudflare challenges, gateway errors), and `200` with a body that has no usable `sub`. The user row is
    only written after a successful verification. Injected stubs may return `{ok: false, reason}`; no `reason` = rejected,
    a thrown error = unavailable.
56. **Real game content only.** Votes, reviews (`skinUuid`, `weaponUuid`), shared stores / Night Market (`payload.offers[].skinUuid`)
    and LFG `agents` are checked against valorant-api.com (`/v1/weapons/skins` incl. level and chroma uuids, `/v1/weapons`,
    `/v1/agents?isPlayableCharacter=true`), fetched by the server (no user data sent) and cached 24 h per kind. Unknown
    ids → `400 invalid_input`. It fails open: while nothing has ever been fetched (start-up, outage) every well-formed
    uuid is accepted and the catalog loads in the background (no request waits for the download); after that an outage keeps the stale cache; an unknown id triggers at most one refresh per
    10 minutes so a skin released today is not rejected. Not validated: `cardId`, reads and deletes.
57. **Filter evasion** (`src/moderation/filter.ts`), all read alongside the plain text so nothing that matched before
    stops matching: invisible characters (zero-width space / joiners, soft hyphen, word joiner, bidi controls,
    variation selectors, BOM, fillers, tag characters) are ignored **and** also tried as word separators; NFKC folds
    full-width, math / circled / squared letters and digits; Cyrillic / Greek look-alike letters are folded to Latin (and
    Latin letters inside a Cyrillic word to Cyrillic) as *additional* spellings of the word, and such text still counts
    as Latin for the Vietnamese / country rules; leetspeak now includes `5` → s and `7` → t; words hidden by
    separators (`f.u.c.k`, `f,u,c,k`, `f/u/c/k`, `f|u|c|k`, `f🔥u🔥c🔥k`, `dit_me`, `ngu-vl`) and **spelled-out runs of at
    least three single letters** (`f u c k`, `đ i t m e`, `v c l`), including a listed word *inside* a longer run
    (`I f u c k you`); phone numbers survive full-width digits, invisible characters, dots / dashes / slashes.
    **Known gaps:** two-letter spaced words (`d m`, `시 발`, `傻 逼`) are not read as words (too many false
    positives); look-alikes beyond the built-in table; accents added on purpose to defeat accent-exact entries
    (`đĩ` with Zalgo marks); leetspeak with punctuation (`sh!t`); phonetic / transliterated spellings; text inside images.
    The filter is a best-effort deterrent: reports and moderators remain the backstop. Cost: typical 1,000-character
    text ≈ 3 ms, worst case just under the caps (note 59) ≈ 20 ms; the rate limit runs before the filter.
58. **Ops.** Container `mem_limit` (512 MB / backup 256 MB), `pids_limit`, `cap_drop: [ALL]`, read-only root, size-limited
    tmpfs; `valvn-backup` is part of `docker-compose.yml` (`ops/backup-loop.sh`: integrity-checked snapshots, atomic
    archives, independent retention, weekly restore drill, encrypted off-site hook, `BACKUP_ONCE=1`);
    `scripts/restore.sh` verifies, saves an undo archive, restores, waits for health. The whole stack (build, start,
    backup, CLI erase, restore, health) was exercised in earlier work. WP-SRV validation is recorded in HANDOFF_REPORT.md; no production deploy was performed.

### Phase 1b hardening (WP-SRV, from the independent audit)

59. **CS-03: availability.** (a) On every write route the per-action rate limit now runs **before** the text filter, the
    catalog lookups and the database checks (only cheap shape validation comes first), so an over-limit request costs
    almost nothing and an attempt the filter rejects still counts (posts 10 / h, comments 30 / 10 min, reviews 30 / h, LFG
    6 / 10 min, PATCH 120 / 10 min). (b) A coarse bucket in `Ctx.user()`: `USER_REQUEST_LIMIT_PER_MIN` (240) requests per
    user per minute for **every** method and route (in memory, no database write); reads, deletes and profile calls had
    no limit before. (c) The filter refuses, instead of scanning, a text with more than 400 words, more than 300
    isolated letters in spelled-out runs, or more than 4,000 UTF-16 units (`400 invalid_input`, reason
    `content_too_complex`); a legitimate 1,000-character text has ~200 words. The matcher was also made ~6x faster
    (first-word hash index instead of scanning every entry, per-letter forms computed once per run, an ASCII fast path in
    `canon()`): worst case 114 ms -> ~20 ms per call. (d) Load shedding: `src/load.ts` measures the event-loop delay
    (p95 of the last second, `perf_hooks.monitorEventLoopDelay`); above `LOAD_SHED_LAG_MS` (250) every request except
    `/healthz` is answered `503 server_busy` with `Retry-After: 2` before any work is done. A `worker_threads` filter was
    considered and not needed: with the rate limit first, one account can trigger at most ~250 filter runs an hour.
60. **Error format (CS-33 / GL-15 / GL-28, additive).** Errors may carry `reason` (stable code, `src/reasons.ts`),
    `params` (limits, field names) and `messageEn` next to the unchanged Vietnamese `message`. New codes: `suspended`
    (403, note 62) and `server_busy` (503). Rate-limit errors return `params: {bucket, limit, windowSeconds}`.
61. **CS-04: sessions can be revoked.** Every account has a `session_epoch` (migration 0007) that is put in the `ep` claim
    of each token; a token whose epoch differs from the account's is refused (`401`). `POST /v1/auth/logout` (auth, `204`)
    bumps it, ending the account's sessions on **all** devices (the app signs in again with its Riot session when needed);
    banning an account bumps it too. Tokens issued before the account row existed are refused (`iat` older than
    `created_at`, compared in whole seconds), so a token stolen before an erasure does not come back when the same Riot
    account signs in again. Tokens issued before this change (no `ep`, header without `kid`) are epoch 0 and keep working.
    **Rotating `SESSION_SECRET` without logging anyone out:** put the current value in `SESSION_SECRET_PREV`, set a new
    `SESSION_SECRET`, restart. New tokens are signed with the new secret and carry `kid` (first 8 hex characters of a hash
    of the secret that signed them); a token is checked against the secret its `kid` names (or against both when it has no
    `kid`). After 30 days (the token lifetime) remove `SESSION_SECRET_PREV`.
62. **CS-02: sanctions and takedown tools** (migration 0006: `sanctions`, `moderation_audit`, `hidden_reason` columns).
    Two kinds. **restrict** = read-only: reading, `DELETE` (undoing), `PATCH /v1/me` and logout work; every other write is
    refused. **ban** = no access at all except data rights (`GET /v1/me/export`, `DELETE /v1/me`) and logout, and no new
    session (`POST /v1/auth/riot` refuses after verifying the Riot token, before creating anything). Both answer
    `403 suspended` with `reason` `account_banned` / `account_restricted` and `params {kind, until (ISO or null), cause}`.
    The check is in `Ctx.user()`, one indexed lookup per authenticated request. A ban is permanent unless `--days` is given;
    a ban beats a restriction; the longest sanction of a kind wins. **Sanctions survive an erasure**: the id is a hash of
    the Riot account, so without this a banned user would delete the account and sign in again. Nothing else about the
    account survives. Content hidden by an operator has `hidden_reason = 'moderator'`, by reports `'reports'` (rows hidden
    before the migration are `'reports'`). The audit table records action, target and structured details, never free text.
    **Authors are told what is hidden:** their own `Post`, `Review` and `LfgPost` objects carry `hidden` and `hiddenReason`
    (`reports` | `moderator`); the new `GET /v1/me/posts` lists their posts including hidden ones (a hidden post still
    answers 404 on `GET /v1/posts/{id}`, for everyone). Other viewers never see those fields.
63. **CS-34: consent record.** `POST /v1/auth/riot` accepts an optional `consentVersion` (1-32 characters of `A-Z a-z 0-9 . _ -`);
    the server stores the version and the time it first saw that version (`users.consent_version` / `consent_at`), keeps the
    time while the version is unchanged, and returns it in the export (`profile.consent`). Nothing is stored for clients that
    do not send it. It goes with the account on erasure.
64. **CS-13 / CS-14 / CS-22 / CS-37: who is "a client".** The rate-limit identity is `CF-Connecting-IP` when `TRUST_PROXY=true`,
    the header parses as an IP address **and** the TCP peer is a loopback / private / Tailscale address (the tunnel or a
    reverse proxy on the same host or Docker network; a client reaching the server directly from a public address cannot
    choose its identity); otherwise the socket address. `X-Forwarded-For` is never used. IPv6 addresses count as their **/64**
    (`src/ip.ts`), so rotating addresses inside a subscriber's prefix does not multiply the limit. Limits: anonymous reads
    600 / min, images 1500 / min (any `Authorization` header is ignored for images), `POST /v1/auth/riot` **300 attempts and
    30 rejected tokens per 10 min** (successful sign-ins are not counted as failures, `riot_unavailable` is not the client's
    fault), all in memory (LRU-capped at 100,000 keys), hashed with the pepper. Rate-limit counters of a user are **not**
    deleted with the account (CS-37). **After deploying check that the header arrives:** two different phones must not share a
    limit, e.g. `docker compose logs valvn-community | grep anon429` staying at zero under normal traffic; if every client
    suddenly gets `429`, `CF-Connecting-IP` is missing (bucketed by the tunnel's address). **Cloudflare rate rules** worth adding
    (Security -> WAF -> Rate limiting rules; they act before the origin): `/v1/auth/riot` 30 requests / 10 min per IP
    (block 10 min), `/v1/media` 300 / min per IP, `/v1/posts` 120 / min per IP (managed challenge).

### WP-SRV operational details and remaining seams

Migrations 0008–0010 add persisted skin aliases, account revocation tombstones (30-day token lifetime), and
24-hour request keys. Canonicalization runs at startup and after catalog map refresh; collisions keep the earliest
creation/origin, latest review body, hidden/moderator state and distinct likes/reports. `/data/catalog.json` restores
the last catalog snapshot before serving; unknown UUID refresh is background-only with capped response size/backoff.

Erasure appends and fsyncs `{id, at, epoch}` to `/data/erasures.jsonl` before deleting rows/files. It contains only the
salted account id and deletion metadata; restrict its permissions and preserve it as a security/deletion log. Sanctions,
moderation audit and short-lived rate/revocation counters survive account deletion to prevent evasion. LFG rows remain
for up to eight days after expiry, orphan uploads 24 hours, quarantine 30 days, reports 365 days, request keys 24 hours.
The legal/client documents outside this package still need the corresponding retention disclosures and localized UI.
Cloudflare terminates TLS and can see the Riot token in transit; the origin never stores/logs it. Origin verification
uses manual redirects, capped responses, at most 20 concurrent calls, outage cooldown and a bounded 60-second cache
of rejected token hashes in memory.

`Idempotency-Key` is optional for POST posts/comments/media. It hashes request bytes/content type and replays a
successful response for 24 hours; a different payload returns 409. Concurrent retries share the result, each request
revalidates authentication, and content deletion removes cached copies. This is retry protection, with a crash window
between content commit and saving the key; callers must not assume exactly-once creation across crashes.

The deep probe `/healthz/deep` accepts only a real loopback TCP peer with no forwarding headers: DB ping, data write
probe, free bytes, WAL bytes and event-loop lag (unwritable or <64 MiB free → 503). Run it inside the API container.
Minute security counters and access logs contain only route patterns/status totals, never IDs embedded in paths.
The optional monitoring profile checks disk, WAL, lag, errors and backup/drill age. Alert delivery and dedicated
tunnel network remain operator setup; the shared `edge` override is retained until its actual topology is reviewed.
PRAGMA optimize runs in housekeeping. Migration 0011 maintains global/per-user media byte counters in SQLite
triggers, including quarantine, resize, ownership changes and erasure cascades. Quota reads no longer scan media.
Public aggregate eligibility uses a statement-local set of trusted users, keeping account-age/sanction rules intact.
Run `npm run build && node dist/benchmark.js 100000` for an isolated synthetic benchmark (temporary DB only).
Measurements and limits are in `docs/performance.md`; skin aggregate tables and index removal remain deferred until
scoped production query measurements justify their write/migration cost.
CI performs test/typecheck/audit/build/script checks and weekly image scanning, with no publish/deploy step.

Keep one SQLite API replica. For PostgreSQL, introduce an awaited Repo contract at each call site, move `geoCondition`
SQL into a database dialect, split Users/Content/Moderation/Media/RateLimit repositories, and run the same contract suite
against both engines. Preserve transactional media quota/attachment and LFG ownership/expiry guards. ETL must retain
ids, epochs, alias mappings, consent and deletion/security records. Dialect work includes named params, JSON functions,
NOCASE, scalar MAX, randomblob and WITHOUT ROWID. No PostgreSQL migration is part of this change.

For multiple replicas, the proposed AppDeps seams are async `RateLimitStore.consume(key, limit, window)`,
`CacheStore.get/set/delete`, and `RevocationStore.getEpoch/bumpEpoch`; keep current SQLite/in-memory defaults first.
An adapter must provide atomic counters with expiry, TTL entries, durable revocations and a leased sweep lock, and the
idempotency store must coordinate across replicas. These seams are documented, not implemented; Redis is unnecessary
for the current deployment and does not remove synchronous SQLite/filter CPU work.
