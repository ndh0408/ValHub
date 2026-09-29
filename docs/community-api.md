# ValVN Community API (v1)

Backend for the "Cộng đồng" tab: looking-for-group (LFG) posts that join a Riot
party by code, skin voting (one vote per account per skin → most-loved
leaderboard), a feed of posts with images / likes / comments / reports, and
"khoe cửa hàng / Chợ Đêm" posts.

- Runtime: Node (Hono, TypeScript) in `server/community/`, SQLite + media files on a
  Docker volume, deployed on the owner's server behind the Cloudflare Tunnel
  `cf-gianguyen` (see `server/community/README.md`).
- Base URL: `https://val.gianguyen.cloud` (`AppConstants.communityBaseUrl`, overridable
  by remote config key `communityBaseUrl`).
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

- The app sends a Riot **access token only** to `POST /v1/auth/riot`. The server
  calls `GET https://auth.riotgames.com/userinfo` with it, reads `sub` (PUUID),
  `acct.game_name`, `acct.tag_line`, then **drops the token** (never stored, never
  logged). This is the only place a Riot token leaves the device.
- The PUUID is never stored or returned: the user id is
  `hex(sha256(PEPPER + puuid))[0..32]` (`PEPPER` = server secret).
- The server issues its own session token: HS256 JWT signed with the server secret
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

#### LFG v2 — requirements, live party state, join tracking (additive)

`POST /v1/lfg` also accepts (all optional):

| Field | Type | Meaning |
|---|---|---|
| `rankMin`, `rankMax` | int 0..27 | Accepted current-rank range (competitive tiers; 0 = any). `rankMin ≤ rankMax`. |
| `roles` | array of `duelist, initiator, controller, sentinel, flex` (≤ 4, unique) | Roles the party still needs. |
| `mic` | bool | Voice chat required. |
| `language` | `vi` \| `en` \| `any` (default `vi`) | Party language. |
| `partySize` | int 1..5 | Current party size when posting (default `5 - slots`). |
| `agents` | array of agent uuids (≤ 5) | Agents already picked by the party (optional, shown as icons). |

New endpoints:

| Method | Path | Body | Response |
|---|---|---|---|
| PATCH | `/v1/lfg/{id}` | own post: `{"partySize"?, "slots"?, "note"?, "status"?: "open"\|"full"\|"in_game"}` | `LfgPost` (also extends `expiresAt` to now + 30 min on every PATCH = "still active" heartbeat) |
| POST | `/v1/lfg/{id}/join` | `{}` — records that the caller tapped "Vào tổ đội" (after the Riot join succeeded) | `{"joins": n}` (one per user; not own post) |

- `GET /v1/lfg` accepts `rank=<tier>` (only posts whose range contains it or has no
  range), `role=<role>`, `mic=true|false`, `language=`, `status=open` (default: open
  posts only). `mode` / `region` as before.
- `LfgPost` gains `"rankMin", "rankMax", "roles", "mic", "language", "partySize",
  "agents", "status", "joins", "updatedAt"`.
- Status `full` / `in_game` posts are hidden from lists (default filter) but still
  returned to their owner via `GET /v1/lfg/mine` → `LfgPost | null` (new).
- Posts with no PATCH heartbeat for 30 minutes expire as before.

Client behaviour (poster): while the LFG screen / app is open, the poster's app polls
its own Riot party (G-12/G-13) every 20 s: it PATCHes `partySize` / `slots` when members
change, sets `status: "full"` when the party reaches 5 (or the mode maximum), and
`in_game` when the party enters matchmaking or a match; it shows a local notification
"<Riot ID> đã vào tổ đội" when a new member appears. Creating a post auto-generates a
party code (G-18) and opens the party when the user has not typed one. Joiner: the
list shows only posts matching the viewer's rank by default ("Phù hợp với rank của
bạn" toggle), marks mismatches, and "Vào tổ đội" joins by code (G-19) after one
confirmation, then calls `POST /v1/lfg/{id}/join`.

### Skin votes (xếp hạng skin được yêu thích)

| Method | Path | Body / query | Response |
|---|---|---|---|
| PUT | `/v1/skins/{skinUuid}/vote` | `{"weaponUuid"}` | `{"skinUuid", "votes", "voted": true}` |
| DELETE | `/v1/skins/{skinUuid}/vote` | — | `{"skinUuid", "votes", "voted": false}` |
| GET | `/v1/skins/top` | `?weapon=<uuid>&period=all\|week&limit=1..100` (auth optional) | `{"items": [{"rank", "skinUuid", "weaponUuid", "votes", "voted"}]}` |
| GET | `/v1/skins/votes` | `?ids=uuid,uuid,…` (≤ 50; auth optional) | `{"items": [{"skinUuid", "votes", "voted"}]}` |

One vote per user per skin (idempotent PUT). `period=week` counts votes cast in the
last 7 days. `voted` is `false` when unauthenticated.

### Skin reviews (đánh giá skin — như Daily Val)

Each user has at most **one review per skin**: a 1–5 star rating plus optional text,
editable any time (`updatedAt` changes). Reviews can be liked ("Hữu ích") and
reported (`targetType: "review"`; 3 reports hide it). Hidden reviews are excluded
from averages.

| Method | Path | Body / query | Response |
|---|---|---|---|
| PUT | `/v1/skins/{skinUuid}/review` | `{"weaponUuid", "rating": 1..5, "body"?: ≤ 500 chars}` | `Review` (create or replace own) |
| DELETE | `/v1/skins/{skinUuid}/review` | — | `204` |
| GET | `/v1/skins/{skinUuid}/reviews` | `?sort=new\|top&cursor&limit` (auth optional) | page of `Review` (`top` = most liked, then newest) |
| GET | `/v1/skins/{skinUuid}/summary` | auth optional | `SkinSummary` |
| PUT / DELETE | `/v1/reviews/{id}/like` | — (not own review) | `{"likes", "liked"}` |
| DELETE | `/v1/reviews/{id}` | own only | `204` |

- `Review`: `{"id", "skinUuid", "author": Author, "rating", "body", "likes", "liked",
  "createdAt", "updatedAt", "mine"}`.
- `SkinSummary`: `{"skinUuid", "weaponUuid", "votes", "voted", "ratingAvg" (1 decimal,
  null when no ratings), "ratingCount", "distribution": [n1, n2, n3, n4, n5],
  "reviewCount" (reviews with non-empty body), "myReview": Review | null}`.
- `GET /v1/skins/top` gains `sort=votes|rating|reviews` (default `votes`) and every
  item gains `"ratingAvg", "ratingCount", "reviewCount"`. `period=all` (default) is
  all-time; `period=week` counts only activity (votes / ratings) of the last 7 days.
  `sort=rating` ranks by a Bayesian average `(C·m + Σratings) / (C + n)` with
  `m` = global mean rating and `C` = 5, and only includes skins with ≥ 3 ratings.
- `GET /v1/skins/votes?ids=` items gain `"ratingAvg", "ratingCount"` (for badges in
  lists and the skin detail sheet).
- Rate limits: reviews (create/update) 30 / hour, review likes share the likes
  limit.

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

## Community scopes v3 — country / region / global (additive)

ValVN is global (18 VALORANT languages, every country). Community content lives in
three nested scopes; the viewer chooses which one to browse.

| Scope | Meaning | Default for |
|---|---|---|
| `country` | Authors from one country (ISO 3166-1 alpha-2). Default = the viewer's own country. | Feed, skin leaderboard |
| `region` | Authors on one VALORANT shard (`ap, kr, eu, na, latam, br`). Default = viewer's shard — the people you can actually party with. | LFG |
| `global` | Everyone; filter by `language` (comma list). | — |

Identity additions:

- `country`: taken from Riot `/userinfo` (`country`, ISO 3166-1 **alpha-3** lowercase
  such as `vnm`) during `POST /v1/auth/riot`, mapped to alpha-2 upper case (`VN`) by the
  server (full ISO table in code; unknown → `null`). Not user-editable (prevents faking
  a country); refreshed on every auth.
- `language`: the app language (one of `ar, de, en, es, fr, id, it, ja, ko, pl, pt, ru,
  th, tr, vi, zh-CN, zh-TW`), sent in `POST /v1/auth/riot` body `language` and
  updatable via `PATCH /v1/me {"language"}`.
- `Author` gains `"country"` (alpha-2 or null) and `"language"`.

Content additions (all stored at creation time, from the author):

- `Post`, `Comment`, `Review`, `LfgPost` gain `"country"`, `"region"` and `"language"`.
  `POST /v1/posts`, comments, reviews and LFG accept an optional `language` (the
  language the text is written in; default = author language) so the reader's app can
  offer on-device translation.
- LFG `language` accepts the 17 codes above plus `any` (replaces `vi|en|any`).

Query additions:

| Endpoint | New query params | Default |
|---|---|---|
| `GET /v1/posts` | `scope=country\|region\|global`, `country=XX`, `region=ap…`, `language=vi,en` | `scope=country` with the viewer's country (falls back to `region` when the viewer has no country, `global` when unauthenticated) |
| `GET /v1/lfg` | `scope`, `country`, `language` (region already exists) | `scope=region` with the viewer's region |
| `GET /v1/skins/top`, `GET /v1/skins/votes`, `GET /v1/skins/{uuid}/summary` | `scope`, `country`, `region` | `scope=global` |
| `GET /v1/skins/{uuid}/reviews` | `scope`, `country`, `region`, `language` | `scope=global` |
| `GET /v1/communities` (new) | `period=week` | Countries with activity: `{"items": [{"country", "posts", "authors", "lfg"}]}` sorted by posts desc (last 7 days) |

- Votes and reviews record the voter's `country` / `region` at the time of the vote, so
  per-country leaderboards count votes cast by people from that country.
- Existing rows without country/region/language stay visible in `global` (and in
  `region` when their region is known) and are backfilled when their author next
  authenticates (users only; content keeps its creation-time values).

Moderation v3: the content filter runs per language (`language` of the text, plus a
cheap script/charset heuristic when absent). Word lists ship for vi and en and
best-effort lists for the other 15 languages, all marked for native review; the
filter must never reject text only because it is in an unsupported language.

## Client rules

- Every account-changing Riot action (joining a party by code) stays user-initiated
  with a confirmation; the community server never touches Riot on the user's
  behalf beyond `/userinfo` during `/v1/auth/riot`.
- The Riot access token is sent to `/v1/auth/riot` only after the user agreed, once per account
  (consent sheet: what is sent, what others see, links to the privacy policy and community
  guidelines; stored under `acct.<puuid>.community.consent`). Declining sends nothing.
- Translation of posts / comments / reviews happens on the device (ML Kit); no text is sent
  to any server.
- The community session token is stored in secure storage under
  `acct.<puuid>.community` and wiped with the account.
