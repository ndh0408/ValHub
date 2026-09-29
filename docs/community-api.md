# ValVN Community API (v1)

Backend for the "Cộng đồng" tab: looking-for-group (LFG) posts that join a Riot
party by code, skin voting (one vote per account per skin → most-loved
leaderboard), a feed of posts with images / likes / comments / reports, and
"khoe cửa hàng / Chợ Đêm" posts.

- Runtime: Cloudflare Worker (TypeScript) in `server/community/`, D1 database
  `valvn-community`, R2 bucket `valvn-community-media`.
- Base URL: configured in the app (`AppConstants.communityBaseUrl`, overridable by
  remote config key `communityBaseUrl`).
- JSON everywhere (`content-type: application/json; charset=utf-8`) except media
  upload. Times are ISO-8601 UTC strings. UUIDs lowercase.
- Errors: HTTP status + `{"error": {"code": "snake_case", "message": "…"}}`.
  Codes: `unauthorized` (401), `forbidden` (403), `not_found` (404),
  `invalid_input` (400), `rate_limited` (429, `retryAfter` seconds in body and
  `Retry-After` header), `riot_rejected` (401, Riot refused the token),
  `server_error` (500).
- Pagination: `?cursor=<opaque>&limit=<1..50, default 20>` →
  `{"items": [...], "nextCursor": "…" | null}`.

## Privacy and identity

- The app sends a Riot **access token only** to `POST /v1/auth/riot`. The Worker
  calls `GET https://auth.riotgames.com/userinfo` with it, reads `sub` (PUUID),
  `acct.game_name`, `acct.tag_line`, then **drops the token** (never stored, never
  logged). This is the only place a Riot token leaves the device.
- The PUUID is never stored or returned: the user id is
  `hex(sha256(PEPPER + puuid))[0..32]` (`PEPPER` = Worker secret).
- The Worker issues its own session token: HS256 JWT signed with the Worker secret
  `SESSION_SECRET`, claims `{sub: userId, name, tag, iat, exp}` (30 days).
  Clients send `Authorization: Bearer <token>`. Riot ID is refreshed on every
  `/v1/auth/riot`.
- Public author object (everywhere a user is shown):

```json
{"id": "9f2c…", "gameName": "KAYN", "tagLine": "04082", "cardId": "uuid|null",
 "rankTier": 17, "region": "ap"}
```

## Endpoints

### Auth / profile

| Method | Path | Body | Response |
|---|---|---|---|
| POST | `/v1/auth/riot` | `{"accessToken", "region", "cardId"?, "rankTier"?}` | `{"token", "expiresAt", "user": Author}` |
| GET | `/v1/me` | — | `Author` |
| PATCH | `/v1/me` | `{"cardId"?, "rankTier"?, "region"?}` | `Author` |

`region` ∈ `ap, na, eu, kr, latam, br`. `rankTier` 0..27 (client-reported, shown
as-is).

### LFG (tìm đồng đội)

| Method | Path | Body / query | Response |
|---|---|---|---|
| GET | `/v1/lfg` | `?region=ap&mode=<mode>&cursor&limit` | page of `LfgPost` (active, newest first) |
| POST | `/v1/lfg` | `{"region", "mode", "partyCode", "slots", "rankTier"?, "note"?}` | `LfgPost` |
| DELETE | `/v1/lfg/{id}` | — (own post only) | `204` |

- `mode` ∈ `competitive, unrated, swiftplay, spikerush, deathmatch, teamdeathmatch, premier, custom`.
- `partyCode`: 6 uppercase letters/digits (`^[A-Z0-9]{6}$`). `slots` 1..4 (players wanted).
- `note` ≤ 140 chars. Posts expire after **30 minutes**; one active post per user
  (a new post replaces the previous one).
- `LfgPost`: `{"id", "author": Author, "region", "mode", "partyCode", "slots",
  "rankTier", "note", "createdAt", "expiresAt"}`.
- Rate limit: 6 posts / 10 min per user.

### Skin votes (xếp hạng skin được yêu thích)

| Method | Path | Body / query | Response |
|---|---|---|---|
| PUT | `/v1/skins/{skinUuid}/vote` | `{"weaponUuid"}` | `{"skinUuid", "votes", "voted": true}` |
| DELETE | `/v1/skins/{skinUuid}/vote` | — | `{"skinUuid", "votes", "voted": false}` |
| GET | `/v1/skins/top` | `?weapon=<uuid>&period=all\|week&limit=1..100` (auth optional) | `{"items": [{"rank", "skinUuid", "weaponUuid", "votes", "voted"}]}` |
| GET | `/v1/skins/votes` | `?ids=uuid,uuid,…` (≤ 50; auth optional) | `{"items": [{"skinUuid", "votes", "voted"}]}` |

One vote per user per skin (idempotent PUT). `period=week` counts votes cast in the
last 7 days. `voted` is `false` when unauthenticated.

### Feed (bảng tin)

| Method | Path | Body / query | Response |
|---|---|---|---|
| GET | `/v1/posts` | `?kind=<kind>&cursor&limit` | page of `Post` (newest first, hidden excluded) |
| GET | `/v1/posts/{id}` | — | `Post` |
| POST | `/v1/posts` | `{"kind", "body", "media"?: [key…], "payload"?}` | `Post` |
| DELETE | `/v1/posts/{id}` | own only | `204` |
| PUT / DELETE | `/v1/posts/{id}/like` | — | `{"likes", "liked"}` |
| GET | `/v1/posts/{id}/comments` | `?cursor&limit` | page of `Comment` (oldest first) |
| POST | `/v1/posts/{id}/comments` | `{"body"}` (≤ 500) | `Comment` |
| DELETE | `/v1/comments/{id}` | own only | `204` |
| POST | `/v1/reports` | `{"targetType": "post"\|"comment"\|"lfg", "targetId", "reason"}` | `204` |
| POST | `/v1/media` | raw bytes, `content-type: image/jpeg\|image/png\|image/webp`, ≤ 2 MB | `{"key", "url"}` |
| GET | `/v1/media/{key}` | — (public, cacheable 1 year) | image bytes |

- `kind` ∈ `text, store, nightmarket`. `body` ≤ 1000 chars (may be empty when
  `media` or `payload` is present). `media` ≤ 4 keys previously uploaded by the
  same user.
- `payload` for `store`: `{"date": "YYYY-MM-DD", "offers": [{"skinUuid", "cost"}]}`;
  for `nightmarket`: `{"date", "offers": [{"skinUuid", "baseCost", "discountCost",
  "discountPercent"}]}`. Max 6 offers. The app renders names / images from
  valorant-api (vi-VN) using the uuids.
- `Post`: `{"id", "author": Author, "kind", "body", "media": [{"key", "url"}],
  "payload", "likes", "liked", "comments", "createdAt"}`.
- `Comment`: `{"id", "postId", "author": Author, "body", "createdAt"}`.
- Moderation: 3 distinct reports hide a post / comment / LFG post. Users can only
  delete their own content.
- Rate limits: posts 10 / hour, comments 30 / 10 min, media 20 / hour, reports 20 /
  hour per user; votes 120 / hour.

## Client rules

- Every account-changing Riot action (joining a party by code) stays user-initiated
  with a confirmation; the community server never touches Riot on the user's
  behalf beyond `/userinfo` during `/v1/auth/riot`.
- The community session token is stored in secure storage under
  `acct.<puuid>.community` and wiped with the account.
