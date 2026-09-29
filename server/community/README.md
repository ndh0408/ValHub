# ValVN Community server

Backend for the app's "Cộng đồng" tab: LFG (tìm đồng đội), skin votes, feed posts with
images / likes / comments / reports. API contract: [`docs/community-api.md`](../../docs/community-api.md).

- Node 22 + TypeScript, [Hono](https://hono.dev) on `@hono/node-server`, listening on `PORT` (default 8080).
- SQLite via `better-sqlite3` (WAL) at `$DATA_DIR/community.db`; migrations in `migrations/` are applied
  automatically at startup and tracked in `schema_migrations`.
- Uploaded images on disk at `$DATA_DIR/media/u/<userId>/<random>.<ext>`.
- Runs as a Docker container behind a Cloudflare Tunnel.

## Layout

```
src/
  main.ts            process entry: config, DB, HTTP server, housekeeping timer, graceful shutdown
  app.ts             createApp(deps) — Hono app, error handling, body limits
  context.ts         shared helpers: auth, rate limits, base URL, serializers
  routes/            auth.ts, lfg.ts, skins.ts, posts.ts (posts, likes, comments, reports), media.ts
  db/                database.ts (open + migrate), repo.ts (Repo interface), sqlite-repo.ts
  config.ts crypto.ts cursor.ts errors.ts media.ts riot.ts validate.ts
migrations/0001_init.sql
test/                vitest (in-memory SQLite + temp media dir, stubbed Riot /userinfo, fake clock)
```

Everything external is injected into `createApp({ repo, media, config, riotUserinfo, now })`, so tests
never touch the network or the real clock.

## Configuration (env)

| Var | Required | Meaning |
|---|---|---|
| `SESSION_SECRET` | yes, ≥ 32 chars | HS256 key for community session tokens (30 days). Rotating it logs everyone out. |
| `PEPPER` | yes, ≥ 32 chars | user id = `hex(sha256(PEPPER + puuid))[0..32]`. **Never change after launch.** |
| `PUBLIC_BASE_URL` | no | Public origin used for media URLs, e.g. `https://community.example.com`. Empty → derived from the request (`X-Forwarded-Proto` / `X-Forwarded-Host`). |
| `TRUST_PROXY` | no (default `true`) | Trust `CF-Connecting-IP` / `X-Forwarded-*`. |
| `PORT` | no (8080) | |
| `DATA_DIR` | no (`/data`) | SQLite file + media directory. |

The process exits immediately with a clear message if a secret is missing or too short.

## Development

```bash
cd server/community
npm install
npm test            # vitest
npm run typecheck   # tsc --noEmit
cp .env.example .env   # fill secrets, set DATA_DIR=./data
npm run dev         # tsx watch on :8080
```

## Deploy (Debian 13 + Docker + Cloudflare Tunnel)

On the server, from a checkout of this repo:

```bash
cd server/community
cp .env.example .env
# fill SESSION_SECRET and PEPPER (openssl rand -hex 32 for each) and PUBLIC_BASE_URL
chmod 600 .env

docker compose build
docker compose up -d
docker compose ps                      # STATUS should become "healthy"
curl -s http://127.0.0.1:8787/healthz  # {"ok":true}
docker compose logs -f valvn-community
```

The container publishes only `127.0.0.1:8787 → 8080`. Point the tunnel at it, e.g. in
`/etc/cloudflared/config.yml`:

```yaml
ingress:
  - hostname: community.example.com
    service: http://127.0.0.1:8787
  - service: http_status:404
```

If `cloudflared` itself runs in Docker, either use `network_mode: host` for it, or attach both
containers to a shared network and use `service: http://valvn-community:8080`, e.g. with a
`docker-compose.override.yml`:

```yaml
services:
  valvn-community:
    networks: [tunnel]
networks:
  tunnel:
    external: true
    name: ${TUNNEL_NETWORK:-cloudflared}
```

Then set `communityBaseUrl` in the app (or remote config) to `https://community.example.com`.

Update: `git pull && docker compose up -d --build` (migrations run automatically on start).

The container runs as the unprivileged `node` user with a read-only root filesystem; the only
writable paths are the `valvn-community-data` volume (`/data`) and a tmpfs `/tmp`.

### Backup

All state lives in the `valvn-community-data` volume (`community.db` + `media/`).

```bash
# 1) consistent online snapshot of the SQLite DB (safe while running, WAL-aware)
docker exec valvn-community node -e "const D=require('better-sqlite3');const d=new D('/data/community.db');d.backup('/data/backup.db').then(()=>d.close())"

# 2) archive snapshot + media to the current directory
docker run --rm -v valvn-community-data:/data:ro -v "$PWD":/backup debian:13-slim \
  tar czf /backup/valvn-community-$(date +%F).tgz -C /data backup.db media
```

Restore: `docker compose down`, extract the archive into the volume, rename `backup.db` to
`community.db` (removing any `community.db-wal` / `-shm`), then `docker compose up -d`.
Keep `.env` (especially `PEPPER`) backed up separately — without it user ids cannot be reproduced.

## Notes (spec gaps / decisions)

Behaviour chosen where `docs/community-api.md` is silent or ambiguous:

1. **Auth on reads.** Only `GET /v1/skins/top`, `GET /v1/skins/votes` (marked "auth optional") and
   `GET /v1/media/{key}` (public) work without a token. All other endpoints, including
   `GET /v1/lfg`, `GET /v1/posts`, `GET /v1/posts/{id}` and comment lists, require a session.
   On auth-optional endpoints a *present but invalid/expired* token is still rejected with 401 so the
   client knows to refresh.
2. **Error body for 429:** `{"error": {"code": "rate_limited", "message": "…", "retryAfter": N}}`
   (retryAfter inside the error object) plus the `Retry-After` header.
3. **Riot unreachable** (network error/timeout calling `/userinfo`) → `500 server_error`, not
   `riot_rejected`, so the client does not discard a possibly valid Riot session. A 200 response
   without a usable `sub` is treated as `riot_rejected`. Missing `game_name`/`tag_line` → empty strings.
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
8. **Skin votes:** the `weaponUuid` of a skin is pinned by its first vote (later votes with a
   different weapon count toward the same skin/weapon), so a bad client value cannot split counts.
   `GET /v1/skins/top` default `limit` is 20. `ids` duplicates are collapsed; order is preserved.
   PUT and DELETE both count toward the 120/hour vote limit.
9. **Posts:** `payload` is required for `store` / `nightmarket` and forbidden for `text`. Payload is
   normalised (unknown fields dropped); `offers` must have 1–6 entries; costs are integers
   0..1,000,000; `discountPercent` 0..100; `discountCost ≤ baseCost`; `date` must be a real calendar
   date. `body` is trimmed. A media key that does not exist → 400; one owned by another user → 403.
   Deleting a post deletes its likes and comments; uploaded image files are kept.
10. **Counts:** `comments` on a post counts only non-hidden comments. Likes on hidden posts → 404.
11. **Reports:** `targetId` must be an existing UUID target (else 404); `reason` is free text,
    1–200 chars. Re-reporting is idempotent; self-reports are accepted (204) but not counted.
    Hidden content is excluded from lists and returns 404 on direct GET; the author can still delete it.
12. **Extra rate limits** not in the spec: likes 120/hour per user, and `POST /v1/auth/riot`
    30 / 10 min per client IP (`CF-Connecting-IP`, stored only as a peppered hash). Rate limits use
    fixed windows stored in SQLite, so they survive restarts.
13. **Media:** content-type must be `image/jpeg|png|webp` *and* match the magic bytes. `GET` sends
    `Cache-Control: public, max-age=31536000, immutable`, an `ETag`, and honours `If-None-Match` (304).
14. **Housekeeping:** every 10 minutes the server deletes rate-limit windows older than 1 day and LFG
    posts that expired more than 1 day ago.
15. String length limits count Unicode code points (so Vietnamese diacritics count as one character).
