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
- Errors: HTTP status + `{"error": {"code": "snake_case", "message": "…", "messageEn"?, "reason"?, "params"?}}`.
  Codes: `unauthorized` (401), `forbidden` (403), `not_found` (404),
  `invalid_input` (400), `rate_limited` (429, `retryAfter` seconds in the error object
  and `Retry-After` header), `riot_rejected` (401, Riot refused the token),
  `riot_unavailable` (503, Riot could not answer; `retryAfter` / `Retry-After` when
  known), `storage_full` (507, the server's image storage is full), `suspended` (403, the
  account is banned or restricted; see "Sanctions"), `server_busy` (503, the server is
  shedding load: retry after `Retry-After` seconds), `server_error` (500).
  `message` is a Vietnamese, human-readable text kept for old clients; clients switch on
  `code`. Errors may also carry (all additive): `reason` — a stable snake_case code for the
  exact case (`content_inappropriate`, `field_too_long`, `rate_limited`, …) — `params` —
  the numbers / field names behind it (`{"field": "body", "max": 500}`,
  `{"bucket": "posts", "limit": 10, "windowSeconds": 3600}`) — and `messageEn`, the English
  text of `message`. New clients should localise from `reason` + `params` and fall back to
  `message`.
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
  `SESSION_SECRET`, claims `{sub: userId, name, tag, iat, exp, ep}` (30 days; `ep` = the
  account's session epoch, header `kid` = key id), revocable: see `POST /v1/auth/logout`.
  Clients send `Authorization: Bearer <token>`. Riot ID is refreshed on every
  `/v1/auth/riot`.
- Public author object (everywhere a user is shown):

```json
{"id": "9f2c…", "gameName": "KAYN", "tagLine": "04082", "cardId": "uuid|null",
 "rankTier": 17, "region": "ap", "country": "VN|null", "language": "vi|null"}
```

  (`country` / `language` were added in "Community scopes v3" below; `null` for accounts
  that never reported one.) Riot ID, region, country, rank and card are **public by
  design**: every reader of a post / comment / review / LFG post sees them (the app asks
  for consent before the first sign-in).
- Reports are personal data: a report is deleted after 12 months, or as soon as the
  content it is about is deleted; a deleted account's reports are anonymised (see
  "Data rights").

## Endpoints

### Auth / profile

| Method | Path | Body | Response |
|---|---|---|---|
| POST | `/v1/auth/riot` | `{"accessToken", "region", "cardId"?, "rankTier"?, "language"?, "consentVersion"?}` | `{"token", "expiresAt", "user": Author}` |
| POST | `/v1/auth/logout` | — | `204` (ends every session of the account) |
| GET | `/v1/me` | — | `Author` |
| PATCH | `/v1/me` | `{"cardId"?, "rankTier"?, "region"?, "language"?}` | `Author` |
| GET | `/v1/me/export` | — | JSON download of all the caller's data (see "Data rights") |
| DELETE | `/v1/me` | — | `204` (hard delete of the account and its data) |

`region` ∈ `ap, na, eu, kr, latam, br`. `rankTier` 0..27 (client-reported, shown
as-is). `consentVersion` (optional, 1–32 characters of `A-Z a-z 0-9 . _ -`, e.g. `"2026-09"`)
is the version of the privacy policy / community guidelines the user accepted in the app: the
server stores the version and the time it first saw it (returned in the data export), nothing else.

**`POST /v1/auth/logout`** (session required) ends **every** session of the account, on all
devices: the tokens issued so far answer `401`, and the app signs in again with its Riot
session when it needs to. A token issued before the account was erased is also refused after
the same Riot account signs in again, and banning an account ends its sessions too.

`POST /v1/auth/riot` errors: `400 invalid_input` (bad body, before Riot is called),
`401 riot_rejected` (Riot refused the token: the client should refresh its Riot session
once and retry), `503 riot_unavailable` (Riot rate-limited us, is down, timed out or
answered with an error page: **the token may be fine**, so the client keeps its Riot
session and retries later, after `Retry-After` when present, 1–300 s), `429 rate_limited`
(30 attempts / 10 min per client IP). No user is created or changed unless Riot verified
the token.

### Sanctions (hạn chế và khóa tài khoản)

The community guidelines allow temporary restrictions and permanent bans; moderators apply them
from the operator tool. A sanctioned account gets **`403 suspended`** on the routes it may not use:

```json
{"error": {"code": "suspended", "reason": "account_restricted", "message": "…", "messageEn": "…",
           "params": {"kind": "restrict", "until": "2026-10-07T12:00:00.000Z", "cause": "spam"}}}
```

- `reason`: `account_restricted` (read-only) or `account_banned` (no access). `params.kind` is
  `restrict` or `ban`; `params.until` is when it ends (ISO-8601, `null` = permanent);
  `params.cause` is a reason code: `spam`, `harassment`, `hate`, `scam`, `nsfw`, `evasion`,
  `minor`, `illegal` or `other`.
- A **restricted** account can read everything, delete its own content, edit its profile
  (`PATCH /v1/me`) and sign out; it cannot post, comment, create LFG posts, vote, review, like,
  report or upload (`403 suspended` on those).
- A **banned** account can only export or erase its data (`GET /v1/me/export`, `DELETE /v1/me`)
  and sign out. `POST /v1/auth/riot` also answers `403 suspended` (no session is issued), and
  existing sessions were ended when the ban was applied (`401`, then the sign-in above).
- Erasing an account does **not** lift a ban or restriction (the id is derived from the Riot
  account, so it would return unchanged). The export lists the account's sanctions
  (`sanctions`) and the moderator actions that concerned it (`moderationLog`).
- Appeals: by email, quoting the Riot ID (community guidelines, section 9).

### Data rights (quyền về dữ liệu)

Both endpoints need a session (`401` otherwise).

**`GET /v1/me/export`** — rate limit 5 / hour per user (`429`). Returns `200` with
`content-type: application/json; charset=utf-8`,
`content-disposition: attachment; filename="valvn-community-export.json"` and
`cache-control: no-store`. Body (arrays are empty when there is nothing; times ISO-8601;
media as URLs; hidden content is included with `hidden: true`):

```json
{
  "format": "valvn-community-export/1",
  "exportedAt": "…",
  "profile": {"id", "gameName", "tagLine", "cardId", "rankTier", "region", "country",
              "language", "createdAt", "updatedAt", "consent": {"version", "at"} | null},
  "posts":    [{"id", "kind", "body", "media": [{"key", "url"}], "payload", "hidden",
                "country", "region", "language", "createdAt"}],
  "comments": [{"id", "postId", "body", "hidden", "country", "region", "language", "createdAt"}],
  "reviews":  [{"id", "skinUuid", "weaponUuid", "rating", "body", "hidden", "likes",
                "country", "region", "language", "createdAt", "updatedAt"}],
  "postLikes":   [{"postId", "createdAt"}],
  "reviewLikes": [{"reviewId", "createdAt"}],
  "skinVotes":   [{"skinUuid", "weaponUuid", "country", "region", "createdAt"}],
  "lfgPosts": [{"id", "region", "country", "mode", "partyCode", "slots", "rankTier", "note",
                "rankMin", "rankMax", "roles", "mic", "language", "partySize", "agents",
                "status", "hidden", "createdAt", "expiresAt", "updatedAt"}],
  "lfgJoins": [{"lfgId", "createdAt"}],
  "reportsFiled": [{"targetType", "targetId", "reason", "createdAt"}],
  "media": [{"key", "url", "contentType", "size", "status": "active|quarantined",
             "attachedToPost": "uuid|null", "createdAt"}],
  "sanctions": [{"kind": "ban|restrict", "reason", "createdAt", "until": "…|null", "liftedAt": "…|null"}],
  "moderationLog": [{"at", "action", "targetType", "targetId"}]
}
```

It contains only the caller's own data: nothing about other people, and no PUUID or IP
address (neither is ever stored).

**`DELETE /v1/me`** — rate limit 3 / hour per user (`429`, checked before anything is
erased). Hard-deletes, in one step: the caller's posts (with the comments and likes on
them), comments, reviews (with their likes), post and review likes, skin votes, LFG posts
and joins, uploaded images (files and rows, including quarantined copies) and the user
row. Reports **about** their content are deleted; reports they **filed** are kept but
anonymised (reporter becomes an opaque id, free text cleared) because they may have hidden
content; the like counters of other people's reviews are corrected. Returns `204` with
`cache-control: no-store`. The session token stops working immediately (`401`), also for a
second `DELETE`. Signing in again with the same Riot account creates a new, empty account
(same `id`). Server backups keep older copies for at most 14 days.

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
| GET | `/v1/me/posts` | `?cursor&limit` (session required) | page of the caller's own `Post`s, newest first, **hidden ones included** |
| POST | `/v1/posts` | `{"kind", "body", "media"?: [key…], "payload"?}` | `Post` |
| DELETE | `/v1/posts/{id}` | own only | `204` |
| PUT / DELETE | `/v1/posts/{id}/like` | — | `{"likes", "liked"}` |
| GET | `/v1/posts/{id}/comments` | `?cursor&limit` | page of `Comment` (oldest first) |
| POST | `/v1/posts/{id}/comments` | `{"body"}` (≤ 500) | `Comment` |
| DELETE | `/v1/comments/{id}` | own only | `204` |
| POST | `/v1/reports` | `{"targetType": "post"\|"comment"\|"lfg"\|"review", "targetId", "reason"}` (`reason` 1–200 chars) | `204` |
| POST | `/v1/media` | raw bytes, `content-type: image/jpeg\|image/png\|image/webp`, ≤ 2 MB | `{"key", "url"}` |
| GET | `/v1/media/{key}` | — (public; devices may cache 1 year, the CDN edge may not) | image bytes |

- `kind` ∈ `text, store, nightmarket`. `body` ≤ 1000 chars (may be empty when
  `media` or `payload` is present). `media` ≤ 4 keys previously uploaded by the
  same user (see "Media rules" below).
- `payload` for `store`: `{"date": "YYYY-MM-DD", "offers": [{"skinUuid", "cost"}]}`;
  for `nightmarket`: `{"date", "offers": [{"skinUuid", "baseCost", "discountCost",
  "discountPercent"}]}`. Max 6 offers. The app renders names / images from
  valorant-api (vi-VN) using the uuids.
- `Post`: `{"id", "author": Author, "kind", "body", "media": [{"key", "url"}],
  "payload", "likes", "liked", "comments", "createdAt"}`.
- `Comment`: `{"id", "postId", "author": Author, "body", "createdAt"}`.
- Moderation: 3 distinct **eligible** reports hide a post / comment / review / LFG post
  (see "Report eligibility"). Users can only delete their own content.
- **Hidden content is explained to its author.** On the author's OWN items — `Post` (also in
  `GET /v1/me/posts`), `Review` (also `myReview` of the summary) and `LfgPost` (also
  `GET /v1/lfg/mine`) — the objects carry `"hidden": bool` and `"hiddenReason": null | "reports" |
  "moderator"` (hidden automatically after enough reports, or by a moderator). Other viewers never
  get these fields (and never get hidden items). A hidden post still answers `404` on
  `GET /v1/posts/{id}`; its author finds it in `GET /v1/me/posts`, can delete it, and can appeal
  by email (community guidelines, section 9).
- Rate limits: posts 10 / hour, comments 30 / 10 min, media 20 / hour, reports 20 /
  hour per user; votes 120 / hour.
- Real game content only: `skinUuid` and `weaponUuid` of votes and reviews, `skinUuid` of
  shared store / Night Market offers and the `agents` of an LFG post are checked against
  valorant-api.com (skin uuids include level and chroma uuids). An unknown id is
  `400 invalid_input`. The check never blocks users when the catalog is not available
  (it accepts every well-formed uuid until the server has loaded it).

#### Report eligibility

`POST /v1/reports` always answers `204` with an empty body — for a report that counts, one
that does not, a duplicate and a report about your own content — so a reporter cannot tell
whether their report counted, whether the content is now hidden, or who else reported
(reports are never exposed, except a user's own filed reports in their data export). The
target must exist (`404` otherwise). A report is stored, but **counts toward the 3 that
hide content only if the reporter's account is at least 24 hours old and has done at least
one thing on the service** (a post, comment, review, vote or like). Eligibility is
re-evaluated whenever another report about the same target arrives. The author's own
reports never count. Hidden content disappears from lists and answers `404` on direct
reads (its author can still delete it); a hidden post's images are quarantined (below).

#### Media rules

- **Upload** (`POST /v1/media`, auth, 20 / hour): the `content-type` must be one of
  `image/jpeg`, `image/png`, `image/webp` **and** match the file's magic bytes; ≤ 2 MB
  (`400 invalid_input` otherwise). The server **strips all metadata** — EXIF (including GPS
  location and camera data), XMP, IPTC, comments, embedded thumbnails, PNG text / time
  chunks, WebP EXIF / XMP — and anything appended after the image data. Only the EXIF
  *orientation* survives, so photos are not shown sideways. The stored file is therefore
  not byte-identical to the upload, and `key` / `url` refer to the sanitised file. A file
  that is not a structurally valid image, or is larger than 50 megapixels or 16,384 px on a
  side, is `400 invalid_input`.
- **Storage limits:** each user may store 50 MB of images (counted on the sanitised
  size; deleting posts frees it): beyond that `400 invalid_input` with the message
  `Bạn đã dùng hết dung lượng ảnh (50 MB). Hãy xóa bớt bài viết có ảnh rồi thử lại.`
  If the server's total image storage is full: `507 storage_full` (`Kho ảnh của máy chủ
  đã đầy, vui lòng thử lại sau.`); retry later.
- **Attaching:** `media` keys of `POST /v1/posts` must belong to the caller (`403`
  otherwise), exist and be usable (`400 invalid_input` for an unknown or quarantined key)
  and not be used by another post (`400`): one file, one post. A file that is never
  attached to a post is **deleted 24 hours after upload** (upload again if a post
  failed later than that).
- **Serving** (`GET /v1/media/{key}`, public, no session): only files that exist **and have
  an active record** are served; deleted files, files of deleted accounts and quarantined
  files answer `404 not_found`. Responses carry `Cache-Control: public, max-age=31536000,
  immutable` (for devices), `Cloudflare-CDN-Cache-Control: no-store` (the CDN edge must not keep
  the file: a deleted or quarantined image must stop being served at once), an `ETag`
  (`If-None-Match` → `304`), `Content-Disposition: inline`,
  `X-Content-Type-Options: nosniff`, `Content-Security-Policy: default-src 'none'; img-src
  'self' data:; sandbox`, `Referrer-Policy: no-referrer` and `Cross-Origin-Resource-Policy:
  cross-origin`.
- **Lifecycle:** deleting a post deletes its images; deleting an account deletes all its
  images; when a post is hidden by reports its images are moved to a private quarantine
  (404 on `/v1/media`) and permanently deleted after 30 days, unless a moderator restores
  them.

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

- **Scope resolution.** An explicit `scope` wins; without it, a `country` param implies
  `country` scope and a `region` param implies `region` scope, otherwise the endpoint
  default above applies. `scope=country` without `country` uses the viewer's country;
  when there is none it falls back to `region` (the `region` param, else the viewer's
  shard), and to `global` when that is unknown too (e.g. no session). Params that do not
  belong to the resolved scope are ignored. `country` must be a real ISO alpha-2 code and
  `region` one of the six shards (`400 invalid_input` otherwise).
- **`appliedScope`.** Every scoped response says which scope was actually applied after
  those fallbacks: `"appliedScope": {"scope": "country|region|global", "country": "VN" | null,
  "region": "ap" | null}` (`country` is set only for `country` scope, `region` only for
  `region` scope). It is a top-level field next to `items` / `nextCursor` on the pages of
  `GET /v1/posts`, `GET /v1/lfg` and `GET /v1/skins/{uuid}/reviews`, next to `items` on
  `GET /v1/skins/top` and `GET /v1/skins/votes`, and next to the other fields of
  `GET /v1/skins/{uuid}/summary`. `GET /v1/communities` has none. Clients use it to show
  the scope the server chose (e.g. "Khu vực" when the viewer has no country).
- Votes and reviews record the voter's `country` / `region` at the time of the vote, so
  per-country leaderboards count votes cast by people from that country.
- Existing rows without country/region/language stay visible in `global` (and in
  `region` when their region is known) and are backfilled when their author next
  authenticates (users only; content keeps its creation-time values).

Moderation v3: the content filter runs per language (`language` of the text, plus a
cheap script/charset heuristic when absent). Word lists ship for vi and en and
best-effort lists for the other 15 languages, all marked for native review; the
filter must never reject text only because it is in an unsupported language.

## Anonymous access, rate limits and caching

**Public reads need no session** (no `Authorization` header): `GET /v1/posts`,
`/v1/posts/{id}`, `/v1/posts/{id}/comments`, `/v1/skins/top`, `/v1/skins/votes`,
`/v1/skins/{uuid}/summary`, `/v1/skins/{uuid}/reviews`, `/v1/communities` and
`/v1/media/{key}`. Without a session the default scope is `global` (an explicit `scope` /
`country` / `region` still works), `liked` / `voted` are `false` and `myReview` is `null`. Everything else — including `GET /v1/lfg` and every write — needs a
session. A token that is *present but invalid or expired* is `401` even on a public read, so
the client can refresh it.

**Limits for requests without a session** (per client IP, hashed with a server secret and
kept in memory only; never stored or logged):

| Requests | Limit |
|---|---|
| public reads other than image files | 120 / minute |
| image files (`/v1/media/…`) | 1500 / minute |

Over the limit: `429 rate_limited` with `retryAfter` (seconds until the minute ends) in the
error object and `Retry-After`. Signed-in requests are limited per user only (the per-user
limits listed with each feature; `GET /v1/me/export` 5 / hour, `DELETE /v1/me` 3 / hour),
never per IP; on top of those, a signed-in user may make at most **240 requests per
minute** in total (any method, any route: `429`, `reason: "rate_limited"`,
`params: {"bucket": "requests", "limit": 240, "windowSeconds": 60}`). Per-action limits are
counted **before** the text is checked, so a request that the content filter rejects still
counts toward them. `POST /v1/auth/riot` is limited to 30 attempts / 10 min per client IP.

**Cache:** anonymous `GET /v1/skins/top`, `/v1/skins/votes`, `/v1/skins/{uuid}/summary`,
`/v1/skins/{uuid}/reviews` and `/v1/communities` are answered from a shared in-memory cache
for **45 seconds** (per path and query string; parameter order does not matter; errors are
never cached), so an anonymous viewer can see data up to 45 s old, and a cache hit does not
count against the limit above. The response header `x-cache: hit|miss` tells which. Requests
with a session are never cached and always see live data. The feed, single posts, comments
and image files are not cached by the server (images are immutable and cacheable by clients;
the CDN edge is told not to store them, see "Media rules").

**No shared caching.** Every response except a media `200` / `304` carries
`Cache-Control: no-store` — errors (`404` included) and authenticated JSON alike — so no
proxy or CDN may keep them.

`GET /v1/communities` also accepts `period=all` (all time) besides the default
`period=week`.

## Client rules

- Every account-changing Riot action (joining a party by code) stays user-initiated
  with a confirmation; the community server never touches Riot on the user's
  behalf beyond `/userinfo` during `/v1/auth/riot`.
- Public reads (feed, posts, comments, skin top / votes / summary / reviews, communities) are made
  without a session and without an `Authorization` header until the user joins.
- The Riot access token is sent to `/v1/auth/riot` only after the user agreed, once per account
  (consent sheet: what is sent, what others see, links to the privacy policy and community
  guidelines; stored under `acct.<puuid>.community.consent`). Declining sends nothing.
- Translation of posts / comments / reviews happens on the device (ML Kit); no text is sent
  to any server.
- The community session token is stored in secure storage under
  `acct.<puuid>.community` and wiped with the account.
