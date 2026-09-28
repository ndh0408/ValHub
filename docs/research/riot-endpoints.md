# Riot PVP (unofficial game-client) API — endpoint reference for ValVN

> Research date: **2026-09-28**. Current client version (valorant-api.com `/v1/version`):
> `release-13.06-shipping-13-5435758` (build date 2026-09-03). Current act: **V26 ACT V**
> (`8102cd81-43a0-d0d7-bd59-47b8fe9bed1b`, 2026-08-19 → 2026-10-14).
>
> Scope: every Riot endpoint needed to clone **ValBuddy 2.1.2** (App Store id6757810434) in Flutter:
> daily shop, bundles, night market, accessory store, wallet, collection, loadout editing,
> account level, rank/MMR/RR history/peak/leaderboard, match history + full scoreboard, battle pass,
> weekly missions + daily checkpoints, live game (agent select pick/lock, in-game players),
> friends/presence/chat (ValBuddy 2.1.x has "Friends' profiles accessible from chat").
>
> These are **undocumented internal endpoints** of the Valorant client (Riot does not support them).
> Everything below is written so that a Dart/`dio` client can be implemented directly.

## Legend and evidence

Status tags:

- **CURRENT** — seen in real Valorant client traffic (ShooterGame.log) in 2025-06 and/or 2026-04, or used
  by an actively maintained companion app in 2026.
- **LEGACY** — still answered by some servers / used by some apps, but the game client no longer calls
  it. May break without notice.
- **DEPRECATED** — replaced; do not implement.
- **UNVERIFIED** — plausible (single secondary source, or inferred), not confirmed by primary evidence.

Evidence codes used throughout:

| Code | Source | Date / notes |
|---|---|---|
| `[LOG25]` | Real `ShooterGame.log` files, AP shard (github.com/ShidqiFaadhil/logs) | 2025-06-06 — primary evidence of URLs/methods/QueryNames |
| `[LOG26]` | Real `ShooterGame.log` + local-API snapshot, EU shard, client `release-12.07-shipping-9-4488404` (github.com/LRAFam/upforge-desktop `scripts/riot-api-probe`) | 2026-04-23 — primary evidence |
| `[VAD]` | valapidocs.techchrism.me / github techchrism/valorant-api-docs (Zod types + real response fixtures) | last commit 2024-04-19; fixtures 2023; some IDs anonymised |
| `[VAD-F]` | github PrometheuzzZ/valorant-api-docs fork (docs site valdocs.prometheuz.me) | updated to 2026-09-24, many AI-authored commits → secondary |
| `[SP]` | giorgi-o/SkinPeek (Discord store bot) | storefront v3 switch in commit `6e30c0c` 2024-09-24 |
| `[VS]` | GinzaTech/Vshop (React Native companion app, Vietnamese comments) | commit 2026-09-27 |
| `[RB]` | Recon Bolt Swift package `ValorantAPI` (fork yanislgha/ValorantAPI) incl. real response fixtures | 2025-08 (fixtures 2021-2023) |
| `[VAPI]` | valorant-api.com (third-party static content API) | queried live 2026-09-28 |
| `[MISC]` | zachrip/valpal, truearken/valclient (Go), nekodayo1337/VL-loadout-editor, molenzwiebel/Deceive, zayKenyon/VALORANT-rank-yoinker (VRY), Anton7444/valorant-shop (2026-09), VShopApp/mobile (2025-08) | cross-checks |

---

## 0. Feature → endpoint map (TL;DR)

| ValBuddy feature | Endpoint(s) | Host | Status |
|---|---|---|---|
| Daily shop (4 skins + VP + countdown) | `POST /store/v3/storefront/{puuid}` body `{}` | pd | CURRENT |
| Featured bundles (all, items, prices, discounts, time left) | same storefront | pd | CURRENT |
| Night Market (`BonusStore`, discount %, `IsSeen`, time left) | same storefront | pd | CURRENT |
| Accessory store (Kingdom Credits, weekly) | same storefront | pd | CURRENT |
| Wallet (VP, Radianite, KC, Agent Tokens) | `GET /store/v1/wallet/{puuid}` | pd | CURRENT |
| Price list for any skin (wishlist) | `GET /store/v1/offers/` | pd | LEGACY / UNVERIFIED |
| Collection (owned items per type) | `GET /store/v1/entitlements/{puuid}/{itemTypeId}` (or without type = all) | pd | CURRENT |
| Favorites (hearted skins) | `GET /favorites/v1/players/{puuid}/favorites` | pd | CURRENT |
| Skin upgrade definitions (levels/chromas, Radianite costs) | `GET /contract-definitions/v3/item-upgrades` | pd | CURRENT |
| Loadout read / edit | `GET`/`PUT /personalization/v3/players/{puuid}/playerloadout` | pd | CURRENT (v2 = LEGACY) |
| Account level & XP | `GET /account-xp/v1/players/{puuid}` | pd | CURRENT |
| Riot ID for PUUIDs | `PUT /name-service/v2/players` body `["puuid",...]` | pd | CURRENT |
| Rank, RR, per-season history, peak, leaderboard position | `GET /mmr/v1/players/{puuid}` | pd | CURRENT |
| RR change per match | `GET /mmr/v1/players/{puuid}/competitiveupdates` | pd | CURRENT (not seen in logs, used by all trackers) |
| Leaderboard | `GET /mmr/v1/leaderboards/affinity/{region}/queue/competitive/season/{seasonId}` | pd | CURRENT (UNVERIFIED in 2026 logs) |
| Match history list | `GET /match-history/v1/history/{puuid}` | pd | CURRENT |
| Match details (scoreboard, rounds, kills, economy) | `GET /match-details/v1/matches/{matchId}` | pd | CURRENT |
| Battle pass level/XP, weekly missions | `GET /contracts/v1/contracts/{puuid}` | pd | CURRENT |
| Daily checkpoints ("Daily Ticket") | `GET /daily-ticket/v1/{puuid}`, `POST /daily-ticket/v1/{puuid}/renew` | pd | CURRENT |
| Seasons / acts / events | `GET /content-service/v3/content` | shared | CURRENT |
| Config (act-end offset, feature flags, service URLs) | `GET /v1/config/{region}` | shared | CURRENT |
| Penalties | `GET /restrictions/v3/penalties` | pd | CURRENT |
| Live game detection | `GET /session/v1/sessions/{puuid}`, `GET /pregame/v1/players/{puuid}`, `GET /core-game/v1/players/{puuid}` | glz | CURRENT |
| Agent select: view / select / lock | `GET /pregame/v1/matches/{id}`, `POST .../select/{agentId}`, `POST .../lock/{agentId}` | glz | CURRENT |
| In-game players (who you're playing with) | `GET /core-game/v1/matches/{id}` (+ `/loadouts`) | glz | CURRENT |
| Party & remote queue (ValBuddy 2.1.0 S1–S4: queue picker, start/leave matchmaking, ready, invite, party code, kick) | `GET /parties/v1/players/{puuid}`, `GET /parties/v1/parties/{partyId}` + mutations in §15.4 | glz | CURRENT (queue/join/leave/setReady seen in `[LOG25]`/`[LOG26]`) |
| Quit match (ValBuddy G10: agent select **and** running match) | `POST /pregame/v1/matches/{id}/quit`, `POST /core-game/v1/players/{puuid}/disassociate/{matchId}` | glz | CURRENT per `[VAD]`; user-initiated only, with confirm |
| Live round score (ValBuddy G7) | own XMPP presence `partyOwnerMatchScoreAllyTeam/EnemyTeam` (§16) | chat | CURRENT (field seen in `[LOG26]` presence) |
| Friends, presence, chat | XMPP over TLS `:5223` (host from client-config + PAS token) | chat | CURRENT |
| Names/images/prices tiers of all items | valorant-api.com (`/v1/weapons`, `/bundles`, `/contracts`, `/missions`, ...) | 3rd party | CURRENT |

Endpoints that only work for **your own** PUUID: storefront, wallet, entitlements, loadout, favorites,
account-xp, contracts, daily-ticket, penalties, session. Endpoints that work for **any** PUUID
(needed for "friends' profiles" and live-game lobby): `mmr/v1/players/{puuid}`, `competitiveupdates`,
`match-history`, `match-details`, `name-service`.

---

## 1. Hosts, regions and shards

```
PD      https://pd.{shard}.a.pvp.net                 player data (store, loadout, mmr, matches, contracts)
GLZ     https://glz-{region}-1.{shard}.a.pvp.net     live services (session, pregame, core-game, parties)
SHARED  https://shared.{shard}.a.pvp.net             content-service, config, latency
```

| `region` (from riot-geo `affinities.live`) | `shard` | GLZ host |
|---|---|---|
| `na` | `na` | `glz-na-1.na.a.pvp.net` |
| `latam` | `na` | `glz-latam-1.na.a.pvp.net` |
| `br` | `na` | `glz-br-1.na.a.pvp.net` |
| `eu` | `eu` | `glz-eu-1.eu.a.pvp.net` |
| `ap` | `ap` | `glz-ap-1.ap.a.pvp.net` |
| `kr` | `kr` | `glz-kr-1.kr.a.pvp.net` |
| `pbe` (from `affinities.pbe`) | `pbe` | UNVERIFIED |

- **Vietnam** (LoL server "VN2") players are `region=ap`, `shard=ap` (`[VS]` maps `vn`, `vn2` → `ap`;
  `[LOG25]` AP traffic goes to `pd.ap`, `glz-ap-1.ap`, `shared.ap`).
- Pitfall seen in `[VS]`: building GLZ as `glz-{shard}-1.{shard}` is wrong for `latam`/`br`. Keep
  `region` and `shard` as two separate values.
- Riot's own client resolves every service URL from the Config endpoint (`SERVICEURL_*` keys, §13.2);
  hard-coding the patterns above matches what all third-party apps do.

---

## 2. Common request headers

| Header | Value | Notes |
|---|---|---|
| `Authorization` | `Bearer {access_token}` | RSO access token (JWT, `exp` = 1 h) |
| `X-Riot-Entitlements-JWT` | `{entitlements_token}` | from entitlements endpoint (§3) |
| `X-Riot-ClientVersion` | `release-13.06-shipping-13-5435758` | from valorant-api.com `/v1/version` → `data.riotClientVersion`; send on **every** PD/GLZ/shared call |
| `X-Riot-ClientPlatform` | base64 of platform JSON (below) | send on every call |
| `Content-Type` | `application/json` | on POST/PUT with a body |
| `Accept-Encoding` | `gzip` | recommended; match details are 0.2–2 MB |
| `User-Agent` | e.g. `RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)` (`riotClientBuild` = valorant-api `/v1/version` → `111.0.0.3261.5663` today) | *(SUMMARY review)* SkinPeek/Fantsry/DailyStore send a Riot-client UA; DailyStore: "Riot has blocked third-party apps by User-Agent before". Keep it one remotely overridable constant |

Client platform — both encodings are used successfully by maintained apps:

```jsonc
// JSON that gets base64-encoded
{"platformType":"PC","platformOS":"Windows","platformOSVersion":"10.0.19042.1.256.64bit","platformChipset":"Unknown"}
```

```
// compact JSON → base64  ([VS] 2026)
eyJwbGF0Zm9ybVR5cGUiOiJQQyIsInBsYXRmb3JtT1MiOiJXaW5kb3dzIiwicGxhdGZvcm1PU1ZlcnNpb24iOiIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwicGxhdGZvcm1DaGlwc2V0IjoiVW5rbm93biJ9
// tab-indented + \r\n JSON → base64 ([VAD] common-components, [SP])
ew0KCSJwbGF0Zm9ybVR5cGUiOiAiUEMiLA0KCSJwbGF0Zm9ybU9TIjogIldpbmRvd3MiLA0KCSJwbGF0Zm9ybU9TVmVyc2lvbiI6ICIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwNCgkicGxhdGZvcm1DaGlwc2V0IjogIlVua25vd24iDQp9
```

Client-version handling:

- Fetch `https://valorant-api.com/v1/version` at app start and cache `riotClientVersion`
  (current value above). Ship a hard-coded fallback in the app.
- `[VS]` observed `MMR_FetchPlayer` failing with a stale version and retries after reading the real
  version from `GET glz /session/v1/sessions/{puuid}` → `clientVersion` (only available while the
  user is logged into the game). Which endpoints hard-fail on a stale version: **UNVERIFIED**; always
  send the latest.
- Console accounts (ValBuddy 2.0.3 "console platform support"): all third-party apps still send the PC
  platform header. Whether PD endpoints need a console `platformType` for console-only data:
  **UNVERIFIED**.

---

## 3. Auth prerequisites (summary; tokens every endpoint needs)

(Auth deserves its own research doc; only what the endpoint layer depends on is listed.)

| Step | Request | Result | Status |
|---|---|---|---|
| Login | In-app **WebView** to `https://auth.riotgames.com/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in&client_id=play-valorant-web-prod&response_type=token%20id_token&scope=account%20openid&nonce={random}&state={random}` — user signs in on Riot's page (password, Google/Apple/Xbox, MFA, hCaptcha handled by Riot) | Redirect to `https://playvalorant.com/opt_in#access_token=…&id_token=…&token_type=Bearer&expires_in=3600` → parse fragment. Keep the `auth.riotgames.com` cookies (`ssid`, `clid`, `csid`, `sub`, `tdid`, …) from the WebView cookie store | CURRENT (`[VS]` 2026-09, Anton7444 2026-09, VShopApp) |
| Silent re-auth | `GET` same authorize URL (+ `&prompt=none`) with `Cookie:` header, no redirects followed | `303` with `Location: https://playvalorant.com/opt_in#access_token=…`; dead cookies ⇒ `Location` fragment `#error=interaction_required&error_description=login_required` (with `prompt=none`) or an **absolute** `https://authenticate.riotgames.com/login?…` (without) — **[LIVE 2026-09-28]**. SkinPeek's old `startsWith("/login")` test no longer matches; test for `access_token` instead. Fallback: `POST https://auth.riotgames.com/api/v1/authorization` (see `SUMMARY.md` §3) | CURRENT (`[SP]` `redeemCookies`; DailyStore 2026-09-23 with a real account: `ssid`/`clid`/`csid` rotate with Max-Age 30 days) |
| Username/password API (`POST`+`PUT https://auth.riotgames.com/api/v1/authorization`) | — | Blocked by hCaptcha since 2023-08 (`[SP]` commit `70b4855` "temporary bypass for hCaptcha"); fragile UA hacks | **DEPRECATED for ValVN** |
| Entitlements | `POST https://entitlements.auth.riotgames.com/api/token/v1`, `Authorization: Bearer`, `Content-Type: application/json`, body `{}` | `{"entitlements_token":"eyJ…"}` | CURRENT |
| PUUID + Riot ID | `GET https://auth.riotgames.com/userinfo` (Bearer) | `sub` = PUUID, `acct.game_name`, `acct.tag_line`, `country` | CURRENT (PUUID is also the `sub` claim of the access token) |
| Region | `PUT https://riot-geo.pas.si.riotgames.com/pas/v1/product/valorant` (Bearer), body `{"id_token":"…"}` | `{"token":"eyJ…","affinities":{"pbe":"na","live":"ap"}}` → `region = affinities.live` | CURRENT |
| PAS token (chat) | `GET https://riot-geo.pas.si.riotgames.com/pas/v1/service/chat` (Bearer) | raw JWT string; payload has `affinity` (e.g. `jp1`) | CURRENT |
| Client config (chat hosts) | `GET https://clientconfig.rpg.riotgames.com/api/v1/config/player?app=Riot%20Client` (Bearer + entitlements) | `chat.affinities` (affinity→host), `chat.affinity_domains`, `chat.port` | CURRENT |

---

## 4. Errors, rate limits, anti-bot

Standard error body (all PD/GLZ services):

```json
{"httpStatus":400,"errorCode":"BAD_CLAIMS","message":"Failure validating/decoding RSO Access Token"}
```

| Situation | Response | Handling |
|---|---|---|
| Access token expired/invalid | `400 BAD_CLAIMS` | silent re-auth, retry once (`[SP]`) |
| Not in pregame / core-game, unknown match | `404 RESOURCE_NOT_FOUND` (`{"httpStatus":404,"errorCode":"RESOURCE_NOT_FOUND","message":"resource not found"}`) | treat as "not in game" (`[RB]`) |
| Maintenance | `403 SCHEDULED_DOWNTIME` | show maintenance banner (`[SP]` `isMaintenance`) |
| `competitiveupdates` start index beyond history | `400 BAD_PARAMETER` | treat as empty page (`[RB]`) |
| Page wider than 20 | `400 MATCH_HISTORY_INVALID_INDICES` (match-history) / `400 MMR_INVALID_INDICES` (competitiveupdates) | always page by ≤ 20 (DailyStore, real account, 2026-09-23) |
| Match not processed yet | `404` right after a game ends (`[LOG26]` shows a 404 then 200) | retry after ~`match.details.delay` (config) |
| Rate limited | `429` | exponential backoff; `Retry-After` presence **UNVERIFIED** |
| Cloudflare challenge | `403` with **HTML** body `<title>Just a moment...</title>` | seen even for the real client on `name-service` bursts (`[LOG26]`, error `ERROR_BODY_DESERIALIZE_FAILURE`). Never assume JSON; back off; batch requests |

Maintenance/incident status (public, no auth): `https://valorant.secure.dyn.riotcdn.net/channels/public/x/status/{region}.json` (`[SP]`).

Client guidance: cache aggressively (storefront until the smallest remaining-duration, match details
forever, MMR 1–5 min), serialise per-account requests, batch `name-service` lookups (≤ ~100 PUUIDs per
call is common practice; exact limit **UNVERIFIED**).

---

## 5. Store

### 5.1 Storefront v3 — daily shop, bundles, night market, accessory store — **CURRENT**

```
POST https://pd.{shard}.a.pvp.net/store/v3/storefront/{puuid}
Headers: Authorization, X-Riot-Entitlements-JWT, X-Riot-ClientVersion, X-Riot-ClientPlatform,
         Content-Type: application/json
Body:    {}
```

History: `GET /store/v2/storefront/{puuid}` (QueryName `Store_GetStorefrontV2`) is **DEPRECATED** —
SkinPeek moved to `POST /store/v3` on **2024-09-24** (`[SP]` commit `6e30c0c`); the game client calls
`Store_GetStorefrontV3` `POST` in `[LOG25]` and `[LOG26]`. The response schema is the same as v2
(`[VAD-F]`, `[RB]`, `[VS]`, Anton7444 all parse it identically).

Example response (structure verified; values from a real `[RB]` fixture with real item IDs, arrays trimmed):

```jsonc
{
  "FeaturedBundle": {
    "Bundle": {                                   // the "headline" bundle; pricing maps may be null here
      "ID": "4ac0cf99-0a6f-41a7-bd94-9a58fe7ec106",
      "DataAssetID": "550d9d34-4942-a605-ba3c-b09452e52f83",   // → valorant-api /v1/bundles/{id} = "Neo Frontier"
      "CurrencyID": "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741",
      "Items": [ /* same shape as Bundles[].Items */ ],
      "ItemOffers": null,
      "TotalBaseCost": null,
      "TotalDiscountedCost": null,
      "TotalDiscountPercent": 0,
      "DurationRemainingInSeconds": 1821001,
      "WholesaleOnly": false
    },
    "Bundles": [                                  // ALL bundles currently in the store (usually 1–3)
      {
        "ID": "4ac0cf99-0a6f-41a7-bd94-9a58fe7ec106",
        "DataAssetID": "550d9d34-4942-a605-ba3c-b09452e52f83",
        "CurrencyID": "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741",
        "Items": [
          {
            "Item": { "ItemTypeID": "e7c63390-eda7-46e0-bb7a-a6abdacd2433",   // skin level
                      "ItemID": "6f60b3ce-4cbf-91ea-2ca7-59bbf1923751", "Amount": 1 },
            "BasePrice": 2175, "CurrencyID": "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741",
            "DiscountPercent": 0, "DiscountedPrice": 2175, "IsPromoItem": false
          },
          {
            "Item": { "ItemTypeID": "dd3bf334-87f3-40bd-b043-682a57a8dc3a",   // buddy level
                      "ItemID": "fc35c2a0-4028-f217-faac-79a02aeeef90", "Amount": 2 },
            "BasePrice": 475, "CurrencyID": "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741",
            "DiscountPercent": 1, "DiscountedPrice": 0, "IsPromoItem": false  // 1 = 100 % off (free in bundle)
          }
        ],
        "ItemOffers": [
          {
            "BundleItemOfferID": "fc35c2a0-4028-f217-faac-79a02aeeef90",
            "Offer": {
              "OfferID": "fc35c2a0-4028-f217-faac-79a02aeeef90",
              "IsDirectPurchase": true,
              "StartDate": "0001-01-01T00:00:00Z",
              "Cost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 475 },
              "Rewards": [ { "ItemTypeID": "dd3bf334-87f3-40bd-b043-682a57a8dc3a",
                             "ItemID": "fc35c2a0-4028-f217-faac-79a02aeeef90", "Quantity": 2 } ]
            },
            "DiscountPercent": 1,
            "DiscountedCost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 0 }
          }
        ],
        "TotalBaseCost":       { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 14600 },
        "TotalDiscountedCost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 8700 },
        "TotalDiscountPercent": 0.405,
        "DurationRemainingInSeconds": 1821001,
        "WholesaleOnly": false
      }
    ],
    "BundleRemainingDurationInSeconds": 1821001
  },
  "SkinsPanelLayout": {                           // DAILY SHOP
    "SingleItemOffers": [                         // 4 skin-LEVEL uuids
      "0ddbdf8c-43b0-e2f1-94f8-d6be9d2a2110",     // Sentinels of Light Ares (level 1)
      "29be6d9e-48b2-1229-4f7d-4da1c20deda9",
      "003e0991-4370-8837-f8fc-6ab3acec2dbf",
      "49b00063-4a7e-6c73-b8c9-68a8d5727757"
    ],
    "SingleItemStoreOffers": [
      {
        "OfferID": "0ddbdf8c-43b0-e2f1-94f8-d6be9d2a2110",
        "IsDirectPurchase": true,
        "StartDate": "2023-06-27T19:09:58.407604254Z",
        "Cost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 2175 },
        "Rewards": [ { "ItemTypeID": "e7c63390-eda7-46e0-bb7a-a6abdacd2433",
                       "ItemID": "0ddbdf8c-43b0-e2f1-94f8-d6be9d2a2110", "Quantity": 1 } ]
      }
      // … 3 more
    ],
    "SingleItemOffersRemainingDurationInSeconds": 17401
  },
  "UpgradeCurrencyStore": {                       // VP → Radianite packs
    "UpgradeCurrencyOffers": [
      {
        "OfferID": "f9cfa034-c7e1-4995-904c-1a296e7b1760",
        "StorefrontItemID": "187c8a5e-47de-f4ca-b02b-7697611cff5b",
        "Offer": {
          "OfferID": "f9cfa034-c7e1-4995-904c-1a296e7b1760", "IsDirectPurchase": true,
          "StartDate": "2020-01-01T00:00:00Z",
          "Cost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 1600 },
          "Rewards": [ { "ItemTypeID": "ea6fcd2e-8373-4137-b1c0-b458947aa86d",  // "currency" reward type
                         "ItemID": "e59aa87c-4cbf-517a-5983-6e81511be9b7",       // Radianite
                         "Quantity": 20 } ]
        },
        "DiscountedPercent": 0.2
      }
    ]
  },
  "AccessoryStore": {                             // Kingdom Credits store, weekly rotation
    "AccessoryStoreOffers": [                     // may be null if the player owns everything ([RB])
      {
        "Offer": {
          "OfferID": "7294e647-bede-52b6-a128-2d4d46140949", "IsDirectPurchase": true,
          "StartDate": "2012-01-01T00:00:00Z",
          "Cost": { "85ca954a-41f2-ce94-9b45-8ca3dd39a00d": 4000 },          // KC
          "Rewards": [ { "ItemTypeID": "d5f120f8-ff8c-4aac-92ea-f2b5acbe9475",  // spray
                         "ItemID": "b4b684bd-40bd-15b2-86b5-3b827a636090", "Quantity": 1 } ]
        },
        "ContractID": "be540721-4d60-0675-a586-ecb14adcb5f7"               // battle pass it came from
      }
      // … typically 4 offers: sprays 4000 KC, cards 6500 KC, titles/buddies (prices vary)
    ],
    "AccessoryStoreRemainingDurationInSeconds": 535801,
    "StorefrontID": "27ce4bc3-81b1-575c-bcdf-572df8e8ce84"
  },
  "BonusStore": {                                 // NIGHT MARKET — key ABSENT when no night market
    "BonusStoreOffers": [                         // 6 offers
      {
        "BonusOfferID": "e0c08290-92d1-4437-ac01-83257a08b8e2",
        "Offer": {
          "OfferID": "ba42fe63-457a-78ce-4499-47950a698129", "IsDirectPurchase": true,
          "StartDate": "2022-09-28T03:53:13.268732Z",
          "Cost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 1775 },          // full price
          "Rewards": [ { "ItemTypeID": "e7c63390-eda7-46e0-bb7a-a6abdacd2433",
                         "ItemID": "ba42fe63-457a-78ce-4499-47950a698129",   // Reaver Vandal
                         "Quantity": 1 } ]
        },
        "DiscountPercent": 22,                     // INTEGER percent here (not a fraction!)
        "DiscountCosts": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 1385 },  // night-market price
        "IsSeen": false                            // card not yet revealed (flipped) by the player
      }
    ],
    "BonusStoreRemainingDurationInSeconds": 1109206
  }
  // "PluginStores": [ … ]  present in real 2026-09 responses (DailyStore) and typed in [VAD-F]; not a ValBuddy feature — ignore
}
```

Field meanings / app logic:

| Field | Use in ValVN |
|---|---|
| `SkinsPanelLayout.SingleItemStoreOffers[].Rewards[0].ItemID` | skin **level** UUID → find skin in valorant-api `/v1/weapons/skins` (search `levels[].uuid`) for name, tier, video |
| `…Cost["85ad13f7-…"]` | VP price |
| `SingleItemOffersRemainingDurationInSeconds` | countdown to daily reset. Compute `expiresAt = responseTime + seconds`; never hard-code reset hour |
| `FeaturedBundle.Bundles[]` | render **all** current bundles (not only `Bundle`) |
| `Bundles[].DataAssetID` | valorant-api `/v1/bundles/{DataAssetID}` for name/art. New bundles may 404 on valorant-api for a few hours after a patch (`[VS]` keeps a fallback) |
| `Items[].BasePrice / DiscountedPrice / DiscountPercent` | per-item price; `DiscountPercent` is a **fraction** (0.33 = 33 %, 1 = free) |
| `TotalBaseCost / TotalDiscountedCost / TotalDiscountPercent` | whole-bundle price; may be `null` in `Bundle` — fall back to summing `Items[].DiscountedPrice` (`[SP]`, `[VS]`) |
| `WholesaleOnly` | `true` = items not purchasable individually |
| `DurationRemainingInSeconds` (per bundle) | per-bundle countdown |
| `BonusStore` | present only while a Night Market is running; `DiscountPercent` is an **integer**; `DiscountCosts` = discounted price; `Offer.Cost` = original price |
| `BonusStoreOffers[].IsSeen` | revealed state. No endpoint to "flip"/mark seen was found — reveal animation should be local-only (**UNVERIFIED**) |
| `AccessoryStore` | KC offers; reward type decides name lookup (spray/card/title/buddy/flex); `ContractID` = source battle pass |
| `UpgradeCurrencyStore` | optional "buy Radianite" info |

Next Night Market start date is not exposed by Riot; SkinPeek reads a community-maintained gist
(`https://gist.githubusercontent.com/mistralwz/17bb10db4bb77df5530024bcb0385042/raw/nmdate.txt`) — third-party, **UNVERIFIED** reliability.

### 5.2 Wallet — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/store/v1/wallet/{puuid}
Headers: standard (§2)
```

```json
{
  "Balances": {
    "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 1450,
    "e59aa87c-4cbf-517a-5983-6e81511be9b7": 60,
    "85ca954a-41f2-ce94-9b45-8ca3dd39a00d": 11200,
    "f08d4ae3-939c-4576-ab26-09ce1f23bb37": 2
  }
}
```

VP / Radianite / Kingdom Credits / Agent Tokens — see currency table (Appendix B). A currency with 0
balance may be missing from the map → default 0 (`[RB]` `StoreWallet.subscript`).

### 5.3 Offers (global price list) — **LEGACY / UNVERIFIED**

```
GET https://pd.{shard}.a.pvp.net/store/v1/offers/        (trailing slash per [VAD])
```

```jsonc
{
  "Offers": [
    { "OfferID": "4845a7ab-4120-ae1c-aec1-9e915a7424b1", "IsDirectPurchase": true,
      "StartDate": "2023-06-29T16:23:34.057714689Z",
      "Cost": { "85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741": 1275 },
      "Rewards": [ { "ItemTypeID": "e7c63390-eda7-46e0-bb7a-a6abdacd2433",
                     "ItemID": "4845a7ab-4120-ae1c-aec1-9e915a7424b1", "Quantity": 1 } ] }
  ],
  "UpgradeCurrencyOffers": [ /* same as storefront */ ]
}
```

Not called by the game client in `[LOG25]`/`[LOG26]`; removed from `[VAD-F]` (2026-06); still used by
VShopApp (2025-08). Use only to show a price for wishlist items not currently in the shop; fall back to
content-tier standard prices if it fails.

### 5.4 Agent storefront — optional, **CURRENT** (shape UNVERIFIED)

`GET https://pd.{shard}.a.pvp.net/store/v1/storefronts/agent` (`Store_GetAgentStorefront` in `[LOG25]`).
`[VAD-F]` shape: `{"AgentStore":{"AgentStoreOffers":[{"AgentID":"…","StoreOffers":[Offer…]}],"CurrentFeaturedAgent":"…","NextFeaturedAgent":"…"}}`.
Not a ValBuddy feature.

### 5.5 Do NOT implement

Purchasing (`store/v1/order`, `Store_CreateOrder`/`GetOrder`), gifting (`store/v1/gifts/{puuid}/…`),
mass rewards (`mass-rewards/v1/players/{puuid}/reconcile`), `name-service/v3/players` POST
(`DisplayNameService_UpdatePlayer`, game-internal), latency ingest, session connect/heartbeat. They
change account state or impersonate the game client and are out of ValBuddy's scope.

---

## 6. Collection (entitlements)

### 6.1 Owned items — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/store/v1/entitlements/{puuid}/{ItemTypeID}
GET https://pd.{shard}.a.pvp.net/store/v1/entitlements/{puuid}        // all types at once ([RB], valpal, [VAD-F])
```

The game client queries each type separately at login (`[LOG25]`, `[LOG26]`: 17 type IDs). For ValVN,
one "all types" call per refresh is cheaper.

```jsonc
{
  "EntitlementsByTypes": [
    {
      "ItemTypeID": "e7c63390-eda7-46e0-bb7a-a6abdacd2433",           // skin levels
      "Entitlements": [
        { "TypeID": "4e60e748-bce6-4faa-9327-ebbe6089d5fe",             // "permanent" entitlement kind, NOT the item type
          "ItemID": "5fc3c5e8-470e-7683-b594-6580d5e3d624" }
      ]
    },
    {
      "ItemTypeID": "dd3bf334-87f3-40bd-b043-682a57a8dc3a",           // buddy levels
      "Entitlements": [
        { "TypeID": "4e60e748-bce6-4faa-9327-ebbe6089d5fe",
          "ItemID": "49ea4428-4511-ba9b-31db-64a9e552383f",             // buddy LEVEL uuid
          "InstanceID": "90431b40-a439-410f-8c51-765452353200" }        // one row per owned copy
      ]
    }
  ]
}
```

Older/alternate single-type shape `{"ItemTypeID":"…","Entitlements":[…]}` is also handled by `[VS]`
(`extractOwnedItemIds`) — parse both defensively. Types the player owns nothing of are omitted.

Semantics per type (full ID table in Appendix A):

- **Weapon skins**: a skin is owned when its level-1 skin-level UUID is in `e7c63390…`; upgraded levels
  appear as extra skin-level entitlements; unlocked chromas appear in `3ad1b2b2…`. "Standard"/default
  skins and a skin's base chroma are always owned and never listed.
- **Buddies**: listed per **instance** (`InstanceID`); a buddy bought twice (bundles often give
  `Amount: 2`) can be equipped on two guns. `InstanceID` is needed for `CharmInstanceID` in the loadout.
- **Agents** (`01bb38e1…`): only non-starter agents; Jett, Phoenix, Sova, Brimstone, Sage are always
  owned (`[RB]` asserts starters are never listed).
- **Premium battle pass**: an entry in `f85cb6f7…` whose `ItemID` equals the current battle-pass
  contract UUID (valorant-api `/v1/contracts`, `content.relationType == "Season"`) ⇒ premium
  (`[SP]` `getBattlepassPurchase`).
- **Sprays / Flex / Player cards / Titles**: `d5f120f8…`, `03a572de…`, `3f296c07…`, `de7caa6b…`.
  Default spray/flex/card/title are granted as entitlements to every account (e.g. STAT-COM Flex
  `af52b5a0-4a4c-03b2-c9d7-8187a08a2675`).
- **Level borders**: *not* entitlements — unlocked by account level; list via valorant-api
  `/v1/levelborders` (`startingLevel`) and compare with account-xp `Progress.Level`.
- **"Player banners"**: no separate item type was found; cards have `smallArt`/`wideArt`/`largeArt`.
  **UNVERIFIED** whether a new banner type exists in 2026.

### 6.2 Favorites — **CURRENT** (shape partially UNVERIFIED)

```
GET https://pd.{shard}.a.pvp.net/favorites/v1/players/{puuid}/favorites
```

```jsonc
{
  "Subject": "c5a5af97-d9b8-5217-9d26-1b35f93ca3d0",        // UNVERIFIED
  "FavoritedContent": {                                    // confirmed key (VL-loadout-editor, krizad bot)
    "27f21d97-4c4b-bd1c-1f08-31830ab0be84": {              // key = favourited item (skin) id
      "FavoriteID": "…",                                   // UNVERIFIED
      "ItemID": "27f21d97-4c4b-bd1c-1f08-31830ab0be84"     // confirmed
    }
  }
}
```

Only needed to show hearts in the collection. Add/remove endpoints: **UNVERIFIED**, not needed.

### 6.3 Item upgrades (skin level/chroma upgrade definitions) — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/contract-definitions/v3/item-upgrades
```
(QueryName is `ItemProgressionDefinitionsV2_Fetch` even though the path is v3 — `[VAD]`, `[LOG25]`, `[LOG26]`.)

```jsonc
{
  "Definitions": [
    {
      "ID": "…",
      "Item": { "ItemTypeID": "e7c63390-eda7-46e0-bb7a-a6abdacd2433", "ItemID": "…" },
      "RequiredEntitlement": { "ItemTypeID": "e7c63390-…", "ItemID": "…" },
      "ProgressionSchedule": { "Name": "…", "ProgressionCurrencyID": "e59aa87c-…", "ProgressionDeltaPerLevel": [10, 10, 15] },
      "RewardSchedule": { "ID": "…", "Name": "…", "Prerequisites": null,
        "RewardsPerLevel": [ { "EntitlementRewards": [ { "Amount": 1, "ItemTypeID": "e7c63390-…", "ItemID": "…" } ],
                               "WalletRewards": null, "CounterRewards": null } ] },
      "Sidegrades": [ { "SidegradeID": "…", "Options": [ { "OptionID": "…",
          "Cost": { "WalletCosts": [ { "CurrencyID": "e59aa87c-…", "AmountToDeduct": 15 } ] },
          "Rewards": [ { "Amount": 1, "ItemTypeID": "3ad1b2b2-…", "ItemID": "…" } ] } ],
          "Prerequisites": { "RequiredEntitlements": [ { "ItemTypeID": "e7c63390-…", "ItemID": "…" } ] } } ]
    }
  ]
}
```

Optional: show Radianite cost of the next level/chroma in the collection screen.

---

## 7. Loadout

### 7.1 Get loadout — `GET /personalization/v3/players/{puuid}/playerloadout` — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/personalization/v3/players/{puuid}/playerloadout
```

Evidence: game client calls it (`playerLoadoutUpdate` QueryName) in `[LOG25]`; used by `[VS]`,
valpal, truearken/valclient, VRY forks, VL-loadout-editor in 2025-2026. NOUSSS/precise-gunplay (2026)
comments "Riot removed v2 (404)". v3 most likely arrived with **Flex** in patch 10.00 (Jan 2025) —
date **UNVERIFIED**.

Real response (`[VAD-F]` fixture; IDs verified against valorant-api; `Guns` trimmed from 20 entries):

```jsonc
{
  "Subject": "ce586d80-382b-54a1-8e90-ef51153f8592",
  "Version": 25,                                  // optimistic-concurrency counter, bumps on every change
  "Guns": [                                       // 19 weapons + melee
    {
      "ID": "9c82e19d-4575-0200-1a81-3eacf00cf872",           // Vandal (weapon uuid)
      "SkinID": "27f21d97-4c4b-bd1c-1f08-31830ab0be84",        // skin
      "SkinLevelID": "1ab72e66-4da3-33a0-164f-908113e075a4",   // equipped level
      "ChromaID": "19629ae1-4996-ae98-7742-24a240d41f99",      // equipped chroma
      "CharmInstanceID": "33aca844-ace2-456b-915a-191e95858f40",  // buddy instance (from entitlements InstanceID)
      "CharmID": "acfd6c31-4786-6059-b93a-d49a8c23e2f6",       // buddy uuid (valorant-api /v1/buddies)
      "CharmLevelID": "ecdd3c7a-42fb-e92d-a400-a480c15a6253",  // buddy level uuid
      "Attachments": []
    },
    {
      "ID": "2f59173c-4bed-b6c3-2191-dea9b58be9c7",           // Melee — never has Charm* fields
      "SkinID": "12cc9ed2-4430-d2fe-3064-f7a19b1ba7c7",
      "SkinLevelID": "854938f3-4532-b300-d9a2-379d987d7469",
      "ChromaID": "cac83e5c-47a1-3519-5420-1db1fdbc4892",
      "Attachments": []
    }
  ],
  "ActiveExpressions": [                          // Expressions wheel (4 slots, index = slot); replaces v2 "Sprays"
    { "TypeID": "03a572de-4234-31ed-d344-ababa488f981", "AssetID": "af52b5a0-4a4c-03b2-c9d7-8187a08a2675" }, // Flex: STAT-COM
    { "TypeID": "d5f120f8-ff8c-4aac-92ea-f2b5acbe9475", "AssetID": "8ade5e91-4a18-db7a-9bda-c2a7c37f3ada" }, // spray
    { "TypeID": "d5f120f8-ff8c-4aac-92ea-f2b5acbe9475", "AssetID": "6983ae7c-4cb5-835c-8f62-b7affbaae20e" },
    { "TypeID": "d5f120f8-ff8c-4aac-92ea-f2b5acbe9475", "AssetID": "7e2ba2e8-4597-060a-b41e-81acedca414e" }
  ],
  "DynamicOptions": {},                           // usually empty
  "Identity": {
    "PlayerCardID": "7a241692-4361-aec4-95cc-c0a700c9f2d9",
    "PlayerTitleID": "faa51024-4bc3-3cdb-6d15-31990f4b01e1",
    "AccountLevel": 0,                            // NOT reliable (0 in real responses) → use account-xp
    "PreferredLevelBorderID": "00000000-0000-0000-0000-000000000000",  // zero UUID = automatic border
    "HideAccountLevel": false
  },
  "Incognito": false                              // "hide my name" / streamer-style identity hiding
}
```

### 7.2 Set loadout — `PUT /personalization/v3/players/{puuid}/playerloadout` — **CURRENT**

```
PUT https://pd.{shard}.a.pvp.net/personalization/v3/players/{puuid}/playerloadout
Headers: standard + Content-Type: application/json
Body:    the full loadout object (as returned by GET) with your modifications
Response 200: the new full loadout (same shape, Version incremented)
```

Body rules (from `[VS]` `updatePlayerLoadoutV3`, VL-loadout-editor, valclient):

- Always start from a **fresh GET** and send the **whole** object back: `Guns` (every entry the GET returned — 21 weapons incl. Bandit + Warden + melee in 13.06; never hard-code the count), `ActiveExpressions`
  (all slots), `DynamicOptions`, `Identity`, `Incognito`. `[VS]` and VL-loadout-editor also send
  `Subject` + `Version` (works); valclient omits them (also works per its README). Sending `Version`
  from the GET is recommended — it is the concurrency token.
- Never send partial `Guns` — omitted guns may be reset (**UNVERIFIED**, not worth testing on real accounts).
- **Round-trip unknown fields.** Keep the GET body as a raw `Map<String, dynamic>` and mutate only the keys you
  understand; patch 13.06 added Agent ID / Agent Mastery cosmetics whose loadout representation is **UNVERIFIED**,
  and a typed model that drops unknown keys could wipe them (SUMMARY review).
- After a 200, re-GET and compare `Version` to confirm it persisted (VL-loadout-editor does this).
- Only equip items the player owns (entitlements) or defaults; invalid combos are rejected
  (status/body **UNVERIFIED**, treat any non-200 as "rolled back").
- The game client does not observe your change until it re-fetches (RMS push happens server-side).

Recipes:

| Change | Mutation |
|---|---|
| Weapon skin | set `SkinID` = skin uuid, `SkinLevelID` = an owned level uuid of that skin (level 1 always owned when skin owned), `ChromaID` = owned chroma uuid (base chroma = `skin.chromas[0].uuid`) |
| Skin level (e.g. level 4 VFX) | change `SkinLevelID` only |
| Chroma | change `ChromaID` only (must be owned or base chroma) |
| Buddy | set `CharmInstanceID` (entitlement `InstanceID`), `CharmID` (buddy uuid = parent of level in valorant-api `/v1/buddies`), `CharmLevelID` (entitlement `ItemID`). If that instance is on another gun, **remove the three Charm fields from that gun** (one instance = one gun). Remove buddy = delete the three fields |
| Spray in wheel slot *i* | `ActiveExpressions[i] = {"TypeID":"d5f120f8-ff8c-4aac-92ea-f2b5acbe9475","AssetID":sprayUuid}` |
| Flex in wheel slot *i* | `ActiveExpressions[i] = {"TypeID":"03a572de-4234-31ed-d344-ababa488f981","AssetID":flexUuid}` (up to 4 flex/sprays mixed) |
| Player card | `Identity.PlayerCardID` |
| Title | `Identity.PlayerTitleID` (empty title UUID from valorant-api `playertitles` where `titleText == null` = "no title") |
| Level border | `Identity.PreferredLevelBorderID` = a level-border uuid whose `startingLevel ≤ account level`; zero UUID = auto |
| Hide account level | `Identity.HideAccountLevel = true` |
| Incognito | `Incognito = true` |

### 7.3 Loadout v2 — **LEGACY/DEPRECATED**

`GET`/`PUT https://pd.{shard}.a.pvp.net/personalization/v2/players/{puuid}/playerloadout` — old shape
with `Sprays: [{"EquipSlotID":"…","SprayID":"…","SprayLevelID":null}]` instead of `ActiveExpressions`,
no Flex. Reported 404 by one 2026 project; `[VS]` keeps it only as a fallback. Do not build on it.

### 7.4 In-match loadouts (read-only, other players)

`GET glz /pregame/v1/matches/{matchId}/loadouts` and `GET glz /core-game/v1/matches/{matchId}/loadouts` →
`{"Loadouts":[{"CharacterID":"…","Loadout":{"Subject":"…","Sprays":{…},"Expressions":{"AESSelections":[{"SocketID":"…","AssetID":"…","TypeID":"…"}]},"Items":{"{weaponId}":{"ID":"…","TypeID":"…","Sockets":{"{socketId}":{"ID":"{socketId}","Item":{"ID":"{itemId}","TypeID":"…"}}}}}}}]}`.
Socket IDs (VRY): skin `bcef87d6-209b-46c6-8b19-fbe40bd95abc`, skin level `e7c63390-…`,
chroma `3ad1b2b2-…`, buddy `77258665-71d1-4623-bc72-44db9bd5b3b3`, buddy level `dd3bf334-…`.
Useful for "see enemy skins" in the live-game screen (optional).

---

## 8. Account level / XP — `GET /account-xp/v1/players/{puuid}` — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/account-xp/v1/players/{puuid}      // own PUUID only
```

```jsonc
{
  "Version": 1545,
  "Subject": "07c0d846-fde0-4d1c-ac0e-4e8fde5c8d5a",
  "Progress": { "Level": 150, "XP": 3941 },        // XP = progress inside current level
  "History": [                                     // recent matches (window size UNVERIFIED; trimmed)
    {
      "ID": "912b5e54-c923-4c10-a216-2a77720cd98a", // match id
      "MatchStart": "2023-02-06T07:38:03Z",
      "StartProgress": { "Level": 149, "XP": 3615 },
      "EndProgress":   { "Level": 149, "XP": 3723 },
      "XPDelta": 108,
      "XPSources": [ { "ID": "time-played", "Amount": 108 } ],   // also "match-win", "first-win-of-the-day"
      "XPMultipliers": []
    }
  ],
  "LastTimeGrantedFirstWin": "2023-02-13T05:46:37.647412992Z",
  "NextTimeFirstWinAvailable": "2023-02-14T03:46:37.647412992Z"
}
```

Account levels cost 5 000 XP each (game rule; not in the response — **UNVERIFIED** for 2026, but no
change announced). Show `Progress.XP / 5000`. Level border art: valorant-api `/v1/levelborders`.

---

## 9. Name service — `PUT /name-service/v2/players` — **CURRENT**

```
PUT https://pd.{shard}.a.pvp.net/name-service/v2/players
Headers: standard + Content-Type: application/json
Body:    ["b5c5e47c-1818-4959-a12f-2b1ea3cd354f", "…"]        // array of PUUIDs
```

```json
[
  { "DisplayName": "", "Subject": "b5c5e47c-1818-4959-a12f-2b1ea3cd354f", "GameName": "Player01", "TagLine": "0001" }
]
```

QueryName `DisplayNameService_FetchPlayers_BySubjects` in `[LOG26]` (2026-04). Use for match
scoreboards, live-game lobbies, leaderboard and friends. **Correction (SUMMARY review):** in real 2026-09
match-details responses `players[].gameName`/`tagLine` arrive **blank** (DailyStore, 2026-09-24), so always
resolve blank names through this endpoint (one batched call per match, cache by PUUID). Respect `PlayerIdentity.Incognito` of other players in pregame/core-game UI (whether the server
masks names for incognito players: **UNVERIFIED**). Batch calls: `[LOG26]` shows Cloudflare `403`
HTML pages on bursts of this endpoint.

---

## 10. Rank / MMR

### 10.1 Player MMR — `GET /mmr/v1/players/{puuid}` — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/mmr/v1/players/{puuid}           // any PUUID
```

Real (2023 fixture, `[VAD]`, trimmed):

```jsonc
{
  "Version": 1687555469522,
  "Subject": "…",
  "NewPlayerExperienceFinished": true,
  "QueueSkills": {
    "competitive": {
      "TotalGamesNeededForRating": 0,
      "TotalGamesNeededForLeaderboard": 0,
      "CurrentSeasonGamesNeededForRating": 0,     // >0 = still in placements
      "SeasonalInfoBySeasonID": {                 // one entry per ACT played; may be null for a queue
        "97233b42-bca0-4596-90e4-dae7026bcb7b": {
          "SeasonID": "97233b42-bca0-4596-90e4-dae7026bcb7b",
          "NumberOfWins": 85,
          "NumberOfWinsWithPlacements": 85,
          "NumberOfGames": 154,
          "Rank": 24,                             // act-rank badge tier
          "CapstoneWins": 0,
          "LeaderboardRank": 35,                  // 0 = not on leaderboard
          "CompetitiveTier": 24,                  // tier at end/now of that act
          "RankedRating": 930,                    // RR (Immortal+/Radiant keeps accumulating)
          "WinsByTier": { "22": 4, "23": 13, "24": 68 },   // tier → wins; may be null
          "GamesNeededForRating": 0,
          "TotalWinsNeededForRank": 0
        }
      }
    },
    "unrated":   { "…": "…" },
    "swiftplay": { "…": "…" },
    "deathmatch": { "…": "…" }                     // other queues: spikerush, ggteam, onefa, snowball, premier, …
  },
  "LatestCompetitiveUpdate": {
    "MatchID": "577f9c0d-0497-40a4-8674-80b087ba1c86",
    "MapID": "/Game/Maps/Canyon/Canyon",
    "SeasonID": "2602eadd-756e-4085-9b08-c8a7bd0c895d",
    "MatchStartTime": 1687553350054,
    "TierAfterUpdate": 27, "TierBeforeUpdate": 27,
    "RankedRatingAfterUpdate": 925, "RankedRatingBeforeUpdate": 910,
    "RankedRatingEarned": 15, "RankedRatingPerformanceBonus": 0,
    "CompetitiveMovement": "MOVEMENT_UNKNOWN",
    "AFKPenalty": 0
  },
  "IsLeaderboardAnonymized": false,
  "IsActRankBadgeHidden": true
}
```

Derived values (verified approach in Superamaja/valorant-lightweight-tracker vs VRY, 2026):

| Metric | Computation |
|---|---|
| Current tier + RR | `QueueSkills.competitive.SeasonalInfoBySeasonID[currentActId]` → `CompetitiveTier`, `RankedRating`. Current act id from content-service (§13.1) or valorant-api `/v1/seasons`. If absent ⇒ unranked this act (or placements: `CurrentSeasonGamesNeededForRating > 0`). `LatestCompetitiveUpdate` is a good cross-check when its `SeasonID == currentActId` |
| Peak rank | `max` over all acts of `max(int(keys(WinsByTier)))` (also consider `Rank`). Map old acts through their own tier table (valorant-api `/v1/seasons/competitive` → `competitiveTiersUuid`; pre-Episode-5 tables differ) |
| Per-season history | iterate `SeasonalInfoBySeasonID`, join with content-service names |
| Win rate (current act) | `NumberOfWins / NumberOfGames` |
| Leaderboard position | `LeaderboardRank` of current act (or presence `playerPresenceData.leaderboardPosition`) |
| Rank-up calculator (ValBuddy 2.1) | RR needed = `100 - RR` per tier (Iron 1 … Immortal 1); average `RankedRatingEarned` of recent wins/losses from competitive updates → games needed. Immortal+ thresholds come from the leaderboard `tierDetails` |

Tier numbers (current table `03621f52-342b-cf4e-4f86-9350a49c6d04`): 0 Unranked, 3–5 Iron 1–3, 6–8 Bronze,
9–11 Silver, 12–14 Gold, 15–17 Platinum, 18–20 Diamond, 21–23 Ascendant, 24–26 Immortal 1–3, 27 Radiant
(1–2 unused).

### 10.2 Competitive updates (RR change per match) — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/mmr/v1/players/{puuid}/competitiveupdates?startIndex=0&endIndex=20&queue=competitive
```

Query: `startIndex` (default 0), `endIndex` (default 10, exclusive upper bound; **max page = 20**, wider pages fail with `400 MMR_INVALID_INDICES` — DailyStore 2026),
`queue` (omit = all queues; for RR use `competitive`). Works for any PUUID. `400 BAD_PARAMETER` when
paging past the end (`[RB]`).

```json
{
  "Version": 0,
  "Subject": "ba8855a1-9b0c-4779-aaf4-71d3cdae5709",
  "Matches": [
    {
      "MatchID": "cde3c5cc-f449-4235-bd66-3cc81f836188",
      "MapID": "/Game/Maps/Canyon/Canyon",
      "SeasonID": "8e5f9e79-f433-4933-b027-0bad1d48bbf8",
      "MatchStartTime": 1687553350054,
      "TierAfterUpdate": 27,
      "TierBeforeUpdate": 27,
      "RankedRatingAfterUpdate": 925,
      "RankedRatingBeforeUpdate": 910,
      "RankedRatingEarned": 15,
      "RankedRatingPerformanceBonus": 0,
      "CompetitiveMovement": "MOVEMENT_UNKNOWN",
      "AFKPenalty": 0
    }
  ]
}
```

`RankedRatingEarned` = RR delta shown per match (positive/negative; can be 0 for draws/remakes or when
an unrated match is included without `queue=competitive`). Promotion/demotion = `TierAfterUpdate` vs
`TierBeforeUpdate`. `MapID` is a map **path** → valorant-api `/v1/maps` `mapUrl`.

### 10.3 Leaderboard — **CURRENT (not observed in logs)**

```
GET https://pd.{shard}.a.pvp.net/mmr/v1/leaderboards/affinity/{region}/queue/competitive/season/{actId}?startIndex=0&size=510&query={optional name}
```

```jsonc
{
  "Deployment": "na-glz-na-1",
  "QueueID": "competitive",
  "SeasonID": "b3df5980-2781-47d0-afc7-25fddfdd0b58",
  "Players": [
    { "PlayerCardID": "db189915-…", "TitleID": "bb326701-…", "IsBanned": false, "IsAnonymized": false,
      "puuid": "ea27bf66-…", "gameName": "Player01", "tagLine": "0001",
      "leaderboardRank": 1, "rankedRating": 1143, "numberOfWins": 139, "competitiveTier": 27 }
  ],
  "totalPlayers": 16002,
  "immortalStartingPage": 51, "immortalStartingIndex": 501,
  "topTierRRThreshold": 450,
  "tierDetails": {                                 // RR thresholds for Immortal 1..Radiant this act
    "24": { "rankedRatingThreshold": 0,   "startingPage": 795, "startingIndex": 7949 },
    "25": { "rankedRatingThreshold": 90,  "startingPage": 410, "startingIndex": 4096 },
    "26": { "rankedRatingThreshold": 200, "startingPage": 51,  "startingIndex": 501 },
    "27": { "rankedRatingThreshold": 450, "startingPage": 1,   "startingIndex": 1 }
  },
  "startIndex": 0,
  "query": ""
}
```

`IsAnonymized` players have hidden names. Leaderboard is per `{region}` affinity (use `ap` for VN).

---

## 11. Match history and match details

### 11.1 Match history — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/match-history/v1/history/{puuid}?startIndex=0&endIndex=20&queue=competitive
```

`queue` optional (see Appendix C). Page size: **max 20** — `endIndex - startIndex > 20` fails with
`400 MATCH_HISTORY_INVALID_INDICES` (DailyStore, real account, 2026-09-23). Works for any PUUID.

```json
{
  "Subject": "881ae8e1-2e79-4e52-8033-98dd2e8a66e3",
  "BeginIndex": 0,
  "EndIndex": 20,
  "Total": 90,
  "History": [
    { "MatchID": "9825b934-db09-431c-882b-bf17654991a7", "GameStartTime": 1687553350054, "QueueID": "competitive" }
  ]
}
```

### 11.2 Match details — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/match-details/v1/matches/{matchId}
```

Response 200–2 000 KB (use gzip, cache forever). Trimmed real structure (`[VAD]` fixture,
competitive, 17 rounds):

```jsonc
{
  "matchInfo": {
    "matchId": "4d11a098-b5be-45aa-bbc7-911c30ff2484",
    "mapId": "/Game/Maps/Ascent/Ascent",                 // map PATH → valorant-api /v1/maps mapUrl
    "gamePodId": "aresriot.aws-chi1-prod.na-gp-chicago-1",
    "gameLoopZone": "aresriot.aws-usw2-prod.na-glz-na-1",
    "gameServerAddress": "",
    "gameVersion": "release-06.08-shipping-19-875485",
    "gameLengthMillis": 1733478,                         // null while incomplete
    "gameStartMillis": 1684034322111,
    "provisioningFlowID": "Matchmaking",                 // or "CustomGame"
    "isCompleted": true,
    "customGameName": "",
    "forcePostProcessing": false,
    "queueID": "competitive",                            // "" for custom
    "gameMode": "/Game/GameModes/Bomb/BombGameMode.BombGameMode_C",
    "isRanked": true,
    "isMatchSampled": true,
    "seasonId": "919ff599-c588-4195-abbc-d69425725b5b",  // act id
    "completionState": "Completed",                      // "Surrendered" | "VoteDraw" | "" (remake value UNVERIFIED)
    "platformType": "PC",
    "premierMatchInfo": {},
    "partyRRPenalties": { "765b96a5-21d7-4c3c-aeee-d4e9aba0d6cb": 0 },
    "shouldMatchDisablePenalties": false
  },
  "players": [
    {
      "subject": "256e532f-5f88-40e9-8fc8-aa413f48806a",
      "gameName": "Player01", "tagLine": "0001",
      "platformInfo": { "platformType": "PC", "platformOS": "Windows", "platformOSVersion": "10.0.22621.1.768.64bit", "platformChipset": "Unknown" },
      "teamId": "Red",                                   // "Red"/"Blue"; in Deathmatch = the player's PUUID
      "partyId": "765b96a5-21d7-4c3c-aeee-d4e9aba0d6cb",
      "characterId": "cd8363e1-498b-47f8-9901-07e5f83169fb",   // agent uuid
      "stats": {                                         // may be null for observers
        "score": 5148, "roundsPlayed": 17, "kills": 19, "deaths": 10, "assists": 2,
        "playtimeMillis": 1733478,
        "abilityCasts": { "grenadeCasts": 8, "ability1Casts": 7, "ability2Casts": 8, "ultimateCasts": 2 }
      },
      "roundDamage": [ { "round": 0, "receiver": "4c1c080c-…", "damage": 171 } ],   // may be null
      "competitiveTier": 26,                             // tier at match time
      "isObserver": false,
      "playerCard": "e177b7e0-a741-4f5c-917c-e706de9e812d",
      "playerTitle": "1969a5fb-b0de-4dc8-91e3-f824c6813edd",
      "preferredLevelBorder": "fbda745c-bc84-4c73-8930-72daa9f300ff",
      "accountLevel": 450,
      "sessionPlaytimeMinutes": 77,
      "xpModifications": [ { "Value": 1.03, "ID": "348960b9-025a-432d-80f1-85ec19813d93" } ],  // premium BP bonus etc.
      "behaviorFactors": { "afkRounds": 0, "collisions": 0.0896, "commsRatingRecovery": 0,
        "damageParticipationOutgoing": 0, "friendlyFireIncoming": 0, "friendlyFireOutgoing": 0,
        "mouseMovement": 0, "stayedInSpawnRounds": 0 },
      "newPlayerExperienceDetails": { "…": "…" }
    }
  ],
  "bots": [],
  "coaches": [],
  "teams": [
    { "teamId": "Red",  "won": true,  "roundsPlayed": 17, "roundsWon": 13, "numPoints": 13 },
    { "teamId": "Blue", "won": false, "roundsPlayed": 17, "roundsWon": 4,  "numPoints": 4 }
  ],                                                     // may be null (e.g. some customs)
  "roundResults": [
    {
      "roundNum": 2,
      "roundResult": "Bomb detonated",                   // "Eliminated" | "Bomb detonated" | "Bomb defused" | "Surrendered" | "Round timer expired"
      "roundCeremony": "CeremonyDefault",                // CeremonyAce | CeremonyTeamAce | CeremonyFlawless | CeremonyClutch | CeremonyThrifty | CeremonyCloser | ""
      "winningTeam": "Red",
      "bombPlanter": "4018021d-010d-4cc0-b5f0-771d65f8d501",
      "plantRoundTime": 65086,
      "plantLocation": { "x": 5476, "y": -6755 },
      "plantSite": "A",
      "defuseRoundTime": 0,
      "defuseLocation": { "x": 0, "y": 0 },
      "plantPlayerLocations": [ { "subject": "…", "viewRadians": 4.83, "location": { "x": 5476, "y": -6755 } } ],
      "defusePlayerLocations": null,
      "roundResultCode": "Detonate",                     // "Elimination" | "Detonate" | "Defuse" | "Surrendered" | "" (timer)
      "playerStats": [
        {
          "subject": "4018021d-010d-4cc0-b5f0-771d65f8d501",
          "kills": [ /* same shape as top-level kills (without "round") */ ],
          "damage": [ { "receiver": "…", "damage": 156, "legshots": 0, "bodyshots": 2, "headshots": 1 } ],
          "score": 0,
          "economy": { "loadoutValue": 5150, "weapon": "9C82E19D-4575-0200-1A81-3EACF00CF872",
                       "armor": "822BCAB2-40A2-324E-C137-E09195AD7692", "remaining": 3100, "spent": 500 },
          "ability": { "grenadeEffects": null, "ability1Effects": null, "ability2Effects": null, "ultimateEffects": null },
          "wasAfk": false, "wasPenalized": false, "stayedInSpawn": false
        }
      ],
      "playerEconomies": [ { "subject": "…", "loadoutValue": 5150, "weapon": "…", "armor": "…", "remaining": 3100, "spent": 500 } ],
      "playerScores": [ { "subject": "…", "score": 0 } ]
    }
  ],
  "kills": [
    {
      "gameTime": 66764, "roundTime": 11728, "round": 0,
      "killer": "6f8a5ca7-b5d5-4317-b998-96a5b90a5b2b",
      "victim": "ba240338-a50d-4e6f-954e-50e404b118da",
      "victimLocation": { "x": 3745, "y": -4737 },
      "assistants": [],
      "playerLocations": [ { "subject": "…", "viewRadians": 4.575, "location": { "x": 4574, "y": -3815 } } ],
      "finishingDamage": { "damageType": "Weapon",     // Weapon | Ability | Bomb | Fall | Melee | Invalid | ""
                           "damageItem": "9C82E19D-4575-0200-1A81-3EACF00CF872",  // weapon uuid (UPPERCASE) or "Ultimate"/"Ability1"/"Ability2"/"GrenadeAbility"/"Primary"/""
                           "isSecondaryFireMode": false }
    }
  ]
}
```

Important parsing notes:

- Real responses use **UPPERCASE** UUIDs for `weapon`, `armor`, `damageItem` (confirmed in the `[RB]`
  real fixture). Lower-case before looking up valorant-api.
- Every array/object above may be `null` for customs, deathmatch, or incomplete games — make every
  field nullable in Dart models (`[VAD]` Zod schema marks them nullable).
- Deathmatch: `teamId` is the PUUID; `teams[].numPoints` = kills.
- **2026 additions seen in real responses (DailyStore, 2026-09):** `roundResults[].firstBloodPlayer`,
  `roundResults[].winningTeamRole`, `matchMvp` (exact parent object UNVERIFIED), `teams[].mvp`, and obfuscated `TempValue*`
  fields (ignore). `players[].gameName/tagLine` may be blank → name-service. `roundResults[].playerEconomies[]`
  is filled only in competitive; other modes only fill `playerStats[].economy`. Custom games: `queueID == ""`.
  Patch 13.06 "Performance Score" field name: **UNVERIFIED** — keep ACS computed.

Derived scoreboard stats (per player `p`):

| Stat | Formula |
|---|---|
| K / D / A | `stats.kills / deaths / assists` |
| K/D ratio | `kills / max(deaths,1)` |
| ACS | `stats.score / stats.roundsPlayed` |
| ADR | `Σ roundResults[].playerStats[p].damage[].damage / roundsPlayed` |
| HS % | `Σ headshots / Σ (headshots+bodyshots+legshots)` over `playerStats[p].damage[]` (hits, not kills) |
| First bloods / first deaths | per round, min `roundTime` in `kills` |
| Multi-kills, clutches | group `kills` by round; ceremony strings |
| Economy per round | `playerEconomies[]` or `playerStats[].economy` (`loadoutValue`, `spent`, `remaining`, `weapon`, `armor`) |
| Win / loss / draw | `teams[team of p].won`; draw if both `won == false` and equal rounds |
| Placement (1st, 2nd…) | sort players by `stats.score` |
| RR change | from competitive updates (`RankedRatingEarned`) matched by `MatchID` |
| Map / mode / agent | `matchInfo.mapId` (path), `matchInfo.queueID` + `gameMode` path, `players[].characterId` |

---

## 12. Battle pass, missions, daily checkpoints

### 12.1 Contracts — `GET /contracts/v1/contracts/{puuid}` — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/contracts/v1/contracts/{puuid}          // own PUUID only
```

QueryName `Contracts_FetchContracts` in `[LOG25]` and `[LOG26]`. Structure from the real `[RB]` fixture
(2022); IDs swapped for current 2026 contract/mission IDs from valorant-api to show the joins:

```jsonc
{
  "Version": 2185,
  "Subject": "…",
  "Contracts": [                                   // battle passes, event passes, agent contracts…
    {
      "ContractDefinitionID": "3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9",   // = valorant-api /v1/contracts uuid (Season 2026 // Act V)
      "ContractProgression": {
        "TotalProgressionEarned": 197800,          // total XP in this pass
        "TotalProgressionEarnedVersion": 71,
        "HighestRewardedLevel": { "d95831b3-ae9e-499b-989e-746020cd3b97": { "Amount": 4, "Version": 4 } }
      },
      "ProgressionLevelReached": 4,                // current tier
      "ProgressionTowardsNextLevel": 57800         // XP inside current tier
    }
  ],
  "ProcessedMatches": [
    { "ID": "c25e7636-…", "StartTime": 1660075851445, "XPGrants": null, "RewardGrants": null,
      "MissionDeltas": null, "ContractDeltas": null, "CouldProgressMissions": true }
  ],
  "ActiveSpecialContract": "ace2bb52-de25-45b5-8e11-3dd2088f914d",       // active agent contract/recruitment
  "Missions": [                                    // WEEKLY missions currently assigned
    {
      "ID": "ea28678a-4ac4-eeec-d835-59bba4e082bd", // = valorant-api /v1/missions uuid ("Get Headshots", 33 900 XP)
      "Objectives": { "04ff6167-4976-eeb3-3e66-a78c57164351": 37 },   // objectiveUuid → current progress
      "Complete": false,
      "ExpirationTime": "2026-08-18T00:00:00Z"
    }
  ],
  "MissionMetadata": {
    "NPECompleted": true,
    "WeeklyCheckpoint": "2026-08-04T00:00:00Z",    // activation date of last completed weekly set (may be absent)
    "WeeklyRefillTime": "2026-08-11T00:00:00Z"     // when next weeklies arrive (may be absent)
  }
}
```

Battle-pass tracker logic:

1. Current battle pass = valorant-api `/v1/contracts` entry with `content.relationType == "Season"`
   and `relationUuid == currentActId` (today: `3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9`, "Season 2026 // Act V",
   11 chapters, 55 levels + epilogue, `premiumVPCost` 1000).
2. Find it in `Contracts[]` by `ContractDefinitionID`. Missing ⇒ level 0.
3. Level = `ProgressionLevelReached`; XP in level = `ProgressionTowardsNextLevel`; XP required for the next
   level = `chapters.flatMap(levels)[level].xp` from valorant-api (formula in `[SP]`:
   2000 + (level-2)×750 for levels 2–50, 36 500 for 51–55 — prefer the data).
4. Premium vs free: entitlements `f85cb6f7…` contains the contract UUID ⇒ premium (§6.1). Free-track
   rewards: `chapters[].freeRewards`.
5. Weekly missions: join `Missions[]` with valorant-api `/v1/missions` (`title`, `xpGrant`,
   `progressToComplete`, `activationDate`, `expirationDate`, `type == "EAresMissionType::Weekly"`).
   Weekly sets activate on Tuesdays 00:00 UTC in 2026 data; use `WeeklyRefillTime`/`ExpirationTime`
   rather than hard-coding.

Related (optional): `GET pd /contracts/v1/players/{puuid}/matches/{matchId}` (`Contracts_FetchProcessedMatch`,
XP granted by one match) and `GET pd /contracts/v1/agents/activeRecruitmentEvent` — both CURRENT in logs,
shapes **UNVERIFIED**. `POST pd /contracts/v1/contracts/{puuid}/special/{contractId}` activates an agent
contract (changes account state — not needed). Old `contract-definitions/v2/definitions/*` paths:
**DEPRECATED** (not in 2025-2026 logs).

### 12.2 Daily Ticket (daily checkpoints) — **CURRENT**

Daily missions were replaced in Episode 7 (2023-06) by "Dailies": 4 checkpoints ("diamonds") × 4
charges; +1 charge per round won in round-based modes, +2 per match in Spike Rush/Escalation/TDM,
Deathmatch excluded; each checkpoint grants XP (battle/event/agent pass) + Kingdom Credits; a missed day
gives a 2× multiplier the next day (playvalorant.com Progression Update Explainer).

```
GET  https://pd.{shard}.a.pvp.net/daily-ticket/v1/{puuid}             QueryName DailyRewards_GET   ([LOG26])
POST https://pd.{shard}.a.pvp.net/daily-ticket/v1/{puuid}/renew       QueryName DailyRewards_RENEW ([LOG25]), body {}
```

Response (`[RB]` model + fixture; wrapper key per `[RB]` `DailyTicketResponse`):

```jsonc
{
  "DailyRewards": {                               // other top-level keys (Version/Subject) UNVERIFIED
    "RemainingLifetimeSeconds": 13177,            // seconds until this day's ticket expires (reset countdown)
    "BonusMilestonesPending": 0,                  // pending 2× catch-up bonuses
    "Milestones": [                               // always 4
      { "Progress": 4, "BonusApplied": true  },   // Progress 0..4 charges; 4 = checkpoint complete
      { "Progress": 3, "BonusApplied": false },
      { "Progress": 0, "BonusApplied": false },
      { "Progress": 0, "BonusApplied": false }
    ]
  }
}
```

- The game calls `renew` at login (`[LOG25]`), `GET` in `[LOG26]`. For a read-only app: call `GET`; call
  `renew` only when `RemainingLifetimeSeconds <= 0` or the GET 404s (Recon Bolt renews by default —
  it is a benign, game-initiated call, but it does mutate server state).
- Reset time is **per player/region**: an AP account's ticket expired at 13:00 UTC on 2025-06-06
  (`[LOG25]`), an EU account ~02:00 UTC on 2026-04-24 (`[LOG26]`, assuming UTC log timestamps). Always
  use `RemainingLifetimeSeconds`.
- XP/KC amounts per checkpoint are not in the response (**UNVERIFIED**; announced values were 1 000 XP
  per checkpoint in 2023).

---

## 13. Content and config

### 13.1 Content service — `GET /content-service/v3/content` — **CURRENT**

```
GET https://shared.{shard}.a.pvp.net/content-service/v3/content
```

```jsonc
{
  "DisabledIDs": [],
  "Seasons": [
    { "ID": "3737c391-497a-6e82-aeb5-cc9f701f72e2", "Name": "V26",    "Type": "episode",
      "StartTime": "2026-06-24T00:00:00Z", "EndTime": "2027-01-06T00:00:00Z", "IsActive": true },
    { "ID": "8102cd81-43a0-d0d7-bd59-47b8fe9bed1b", "Name": "ACT V", "Type": "act",
      "StartTime": "2026-08-19T00:00:00Z", "EndTime": "2026-10-14T00:00:00Z", "IsActive": true }
  ],
  "Events": [
    { "ID": "96682481-4f7b-6322-18bb-f1a76f91a35f", "Name": "Champions",
      "StartTime": "2022-08-23T14:00:00Z", "EndTime": "2022-09-21T21:00:00Z", "IsActive": false }
  ]
}
```

(IDs/dates of the V26 entries taken from valorant-api `/v1/seasons`; exact `Name` strings the service
returns for 2025+ "Season 20xx" episodes are **UNVERIFIED** — use valorant-api for display names.)
Active act = `Type == "act" && IsActive`. Also works without auth on valorant-api `/v1/seasons`.

### 13.2 Config — `GET /v1/config/{region}` — **CURRENT**

```
GET https://shared.{shard}.a.pvp.net/v1/config/{region}          // [LOG26] uses the SHARED host
```

(`[VS]` uses `pd.{shard}` — works? **UNVERIFIED**; follow the client.) Response
`{"LastApplication":"…","Collapsed":{…string→string…}}`. Useful keys:

- `competitiveSeasonOffsetEndTime` — seconds by which this region's act end is offset (`[RB]`) → precise
  "act ends in" countdown.
- `match.details.delay` — delay before match details are available.
- `SERVICEURL_*` — authoritative service hosts (e.g. `SERVICEURL_DAILY_TICKET`, `SERVICEURL_STORE`).
- Feature flags (`mainmenubar.store.enabled`, …) and `SERVICE_TICKER_MESSAGE(.locale)` (in-game
  maintenance ticker).

---

## 14. Penalties — `GET /restrictions/v3/penalties` — **CURRENT**

```
GET https://pd.{shard}.a.pvp.net/restrictions/v3/penalties        // token identifies the player; no PUUID in path
```

```jsonc
{
  "Subject": "604aa5b4-a60f-421f-b800-80d7f840a13b",
  "Penalties": [                                   // [] normally; item shape from [VAD-F] = UNVERIFIED, values illustrative
    {
      "ID": "…", "IssuingGameStartUnixMillis": 1717000000000, "IssuingMatchID": "…",
      "Expiry": "2026-09-30T00:00:00Z", "GamesRemaining": 0,
      "ApplyToAllPlatforms": true, "ApplyToPlatforms": [], "ApplyToPlatformGroups": [],
      "InfractionID": "…", "Origin": "…", "ForgivenessIneligible": false, "IsAutomatedDetection": true,
      "QueueDelayEffect": null, "QueueRestrictionEffect": null, "RankedRatingPenaltyEffect": null,
      "GameBanEffect": null, "XPMultiplierEffect": null, "WarningEffect": null, "PremierRestrictionEffect": null
    }
  ],
  "Infractions": [],                               // [VAD-F], UNVERIFIED
  "Version": 1685246809473
}
```

Also CURRENT in logs but optional: `GET pd /restrictions/v1/activeFutureInterventions`,
`GET pd /restrictions/v1/avoidList`.

---

## 15. Live game (agent select → in match)

Mobile apps cannot use the local client websocket (RMS); poll the remote endpoints (every 2–5 s while a
"live" screen is open, 15–60 s otherwise).

### 15.1 Session — **CURRENT**

`GET https://glz-{region}-1.{shard}.a.pvp.net/session/v1/sessions/{puuid}` (`[VAD-F]` shape, `[VS]` uses it;
values below are illustrative):

```jsonc
{
  "subject": "…", "cxnState": "CONNECTED", "cxnCloseReason": "", "clientID": "…",
  "clientVersion": "release-13.06-shipping-13-5435758",   // real version → X-Riot-ClientVersion fallback
  "loopState": "MENUS",                                     // MENUS | PREGAME | INGAME
  "loopStateMetadata": "",                                  // match id when PREGAME/INGAME ([VAD-F], UNVERIFIED)
  "version": 1, "lastHeartbeatTime": "…", "expiredTime": "…", "heartbeatIntervalMillis": 150000,
  "playtimeNotification": "", "playtimeMinutes": 42, "isRestricted": false,
  "clientPlatformInfo": { "platformType": "PC", "platformOS": "Windows", "platformOSVersion": "…", "platformChipset": "Unknown", "platformDevice": "" },
  "connectionTime": "…", "shouldForceInvalidate": false
}
```

404 when the player is not logged into the game.

### 15.2 Pregame (agent select) — **CURRENT** (`[LOG26]`)

| Purpose | Request |
|---|---|
| Am I in agent select? | `GET glz /pregame/v1/players/{puuid}` → `{"Subject":"…","MatchID":"a6e7cba8-…","Version":1622392993783}`; `404` = no |
| Lobby state | `GET glz /pregame/v1/matches/{matchId}` |
| Hover agent | `POST glz /pregame/v1/matches/{matchId}/select/{agentId}` (no body) → pregame match |
| Lock agent | `POST glz /pregame/v1/matches/{matchId}/lock/{agentId}` (no body) → pregame match |
| Lobby loadouts | `GET glz /pregame/v1/matches/{matchId}/loadouts` |
| Dodge (quit) | `POST glz /pregame/v1/matches/{matchId}/quit` — **penalty/RR loss**. ValBuddy exposes it as "Quit Match" (G10) behind a confirmation; do the same |

Pregame match (real `[RB]` fixture, trimmed):

```jsonc
{
  "ID": "a6e7cba8-a4ef-4aae-b775-4eb61e43a0d1",
  "Version": 1623704079442,
  "Teams": [ /* Blue and Red (only ally team is visible in matchmaking) */ ],
  "AllyTeam": {
    "TeamID": "Red",
    "Players": [
      {
        "Subject": "d31583b9-98f0-5986-8d1d-dbf1f77f6305",
        "CharacterID": "569fdd95-4d10-43ab-ca70-79becc718b46",     // "" before hovering
        "CharacterSelectionState": "locked",                        // "" | "selected" | "locked"
        "PregamePlayerState": "joined",
        "CompetitiveTier": 0,                                       // often 0 → fetch MMR per player
        "PlayerIdentity": { "Subject": "…", "PlayerCardID": "3dbe8ac5-…", "PlayerTitleID": "540826d2-…",
                            "AccountLevel": 1, "PreferredLevelBorderID": "", "Incognito": false, "HideAccountLevel": false },
        "SeasonalBadgeInfo": { "SeasonID": "", "NumberOfWins": 0, "WinsByTier": null, "Rank": 0, "LeaderboardRank": 0 },
        "IsCaptain": false
      }
    ]
  },
  "EnemyTeam": null,
  "ObserverSubjects": [], "MatchCoaches": [],
  "EnemyTeamSize": 5, "EnemyTeamLockCount": 4,
  "PregameState": "character_select_active",                         // map_select_* | character_select_active | character_select_finished | provisioned
  "LastUpdated": "0001-01-01T00:00:00Z",
  "MapID": "/Game/Maps/Triad/Triad",
  "Mode": "/Game/GameModes/QuickBomb/QuickBombGameMode.QuickBombGameMode_C",
  "QueueID": "spikerush",
  "ProvisioningFlowID": "Matchmaking",
  "IsRanked": false,
  "PhaseTimeRemainingNS": 59763637886,                               // nanoseconds → agent-select timer
  "GamePodID": "aresriot.aws-rclusterprod-euc1-1.eu-gp-frankfurt-awsedge-1",
  "VoiceSessionID": "…", "MUCName": "…@ares-pregame.eu2.pvp.net", "TeamMatchToken": "…",
  "altModesFlagADA": false
}
```

Agent lock only works for agents the player owns (entitlements `01bb38e1…` + starters).

### 15.3 Core game (in match) — **CURRENT** (`[LOG26]`)

| Purpose | Request |
|---|---|
| Am I in a match? | `GET glz /core-game/v1/players/{puuid}` → `{"Subject":"…","MatchID":"…","Version":…}`; `404` = no |
| Match & players | `GET glz /core-game/v1/matches/{matchId}` |
| Players' skins | `GET glz /core-game/v1/matches/{matchId}/loadouts` |
| Leave match | `POST glz /core-game/v1/players/{puuid}/disassociate/{matchId}` (`[VAD]` `CoreGame_DisassociatePlayer`; also what the Project-A server emulator implements). ValBuddy 2.1.1 exposes "leave running match" — expose only behind a confirmation. GinzaTech/Vshop instead calls `POST /core-game/v1/matches/{matchId}/quit`: **UNVERIFIED**, not in `[VAD]` — do not use |

```jsonc
{
  "MatchID": "cfa364b6-bc65-4805-9988-3ba02ba506ac",
  "Version": 170225830284,
  "State": "IN_PROGRESS",                                 // PREPROVISION | PROVISIONING | IN_PROGRESS | POST_GAME | CLOSED
  "MapID": "/Game/Maps/Ascent/Ascent",
  "ModeID": "/Game/GameModes/Bomb/BombGameMode.BombGameMode_C",
  "ProvisioningFlow": "Matchmaking",
  "GamePodID": "aresriot.aws-usw1-prod.na-gp-norcal-1",
  "AllMUCName": "…-all@ares-coregame.na1.pvp.net", "TeamMUCName": "…", "TeamVoiceID": "…", "TeamMatchToken": "…",
  "IsReconnectable": false,
  "ConnectionDetails": { "GameServerHosts": ["…"], "GameServerHost": "…", "GameServerPort": 7401, "…": "…" },
  "PostGameDetails": null,
  "Players": [
    {
      "Subject": "c89423c6-e3a1-476e-897a-533dbebdd00f",
      "TeamID": "Blue",
      "CharacterID": "734c8419-92dd-4653-8655-018fe5a544af",
      "PlayerIdentity": { "Subject": "…", "PlayerCardID": "…", "PlayerTitleID": "…", "AccountLevel": 239,
                          "PreferredLevelBorderID": "…", "Incognito": false, "HideAccountLevel": true },
      "SeasonalBadgeInfo": { "SeasonID": "", "NumberOfWins": 0, "WinsByTier": null, "Rank": 0, "LeaderboardRank": 0 },
      "IsCoach": false,
      "IsAssociated": true
    }
  ],
  "MatchmakingData": { "QueueID": "competitive" }   // null for customs ([VAD] fixture); QueueID per [VS]; other keys UNVERIFIED
}
```

Live-game lobby (ValBuddy "see who you're playing with"): pregame/core-game match → PUUIDs →
`name-service` (names) + `mmr/v1/players/{puuid}` per player (current rank, peak) → cache per match.
Respect `Incognito` / `HideAccountLevel`.

### 15.4 Party (optional) — **CURRENT**

`GET glz /parties/v1/players/{puuid}` → `{"Subject":"…","Version":…,"CurrentPartyID":"a457b58c-…","Invites":null,"Requests":[],"PlatformInfo":{…}}`
(the client appends ping query params like `?aresriot.aws-apse1-prod.ap-gp-singapore-1=24`; optional).
`GET glz /parties/v1/parties/{partyId}` → `Members[]` (`Subject`, `CompetitiveTier`, `PlayerIdentity`, `IsOwner`,
`IsReady`, `Pings`, `PlatformType`), `State` (e.g. `DEFAULT`, `MATCHMAKING`), `Accessibility` (`OPEN`/`CLOSED`),
`MatchmakingData.QueueID`, `QueueEntryTime` (queue timer), `EligibleQueues`, `QueueIneligibilities`
(why a queue is blocked), `RestrictedSeconds`, `InviteCode` ("" = none), `Requests`.

**Correction (SUMMARY review):** ValBuddy 2.1.0 *does* ship party & remote queue (S1–S4), so these
mutations are in scope (all `POST` on GLZ unless noted; response = party object; `[VAD]` party endpoints,
`[LOG25]`/`[LOG26]` for the starred ones):

| Action | Request |
|---|---|
| Change queue * | `POST /parties/v1/parties/{partyId}/queue` body `{"queueId":"competitive"}` |
| Start matchmaking * | `POST /parties/v1/parties/{partyId}/matchmaking/join` |
| Leave matchmaking * | `POST /parties/v1/parties/{partyId}/matchmaking/leave` |
| Ready / unready * | `POST /parties/v1/parties/{partyId}/members/{puuid}/setReady` body `{"ready":true}` |
| Open / close party | `POST /parties/v1/parties/{partyId}/accessibility` body `{"accessibility":"OPEN"}` |
| Invite friend by Riot ID | `POST /parties/v1/parties/{partyId}/invites/name/{gameName}/tag/{tagLine}` (URL-encode both) |
| Generate / disable party code | `POST` / `DELETE /parties/v1/parties/{partyId}/invitecode` |
| Join with code | `POST /parties/v1/players/joinbycode/{code}` |
| Accept an invite (join a party) | `POST /parties/v1/players/{puuid}/joinparty/{partyId}` — community clients (valclient.js, Project-A); **UNVERIFIED 2026** |
| Decline a join request | `POST /parties/v1/parties/{partyId}/request/{requestId}/decline` |
| Leave party / kick member (owner) | `DELETE /parties/v1/players/{puuid}` (own PUUID = leave, other = kick; RadiantConnect) |
| Refresh own rank in party | `POST /parties/v1/parties/{partyId}/members/{puuid}/refreshCompetitiveTier` |

Where an incoming invite shows up for the invitee (`GET /parties/v1/players/{puuid}` → `Invites`, typed `null`
in `[VAD]`, vs. XMPP) is **UNVERIFIED** — parse `Invites` defensively as a list of objects with `PartyID`.

---

## 16. Friends, presence, chat (XMPP) — **CURRENT**

ValBuddy 2.1.x shows a chat tab with friends' profiles. There is no REST endpoint for the friend list
remotely; the game uses Riot's XMPP chat.

Connection (`[VS]` `utils/xmpp-client.ts` + `chat-service.ts`, 2026; valapidocs XMPP page):

1. `GET` PAS token (§3). Decode JWT → `affinity` (e.g. `jp1`, `eu1`, `na1`, `kr1`).
2. `GET` client-config (§3) → `chat.affinities[affinity]` = host (e.g. `jp1.chat.si.riotgames.com`),
   `chat.affinity_domains[affinity]` = XMPP domain prefix, `chat.port` (5223). Fallback hosts in `[VS]`:
   `ap→jp1`, `eu→euw1`, `na→na2`, `kr→kr1`, `br→br`, `latam→la1` (`*.chat.si.riotgames.com`).
3. TLS TCP socket to `{host}:5223` (Flutter: `SecureSocket.connect`). Messages arrive fragmented —
   buffer until complete XML.
4. Stream: `<?xml version="1.0" encoding="UTF-8"?><stream:stream to="{domain}.pvp.net" xml:lang="en" version="1.0" xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams">`
5. SASL: `<auth mechanism="X-Riot-RSO-PAS" xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><rso_token>{access_token}</rso_token><pas_token>{pas_token}</pas_token></auth>` → `<success/>`, reopen stream.
6. Bind `<iq id="_xmpp_bind1" type="set"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/></iq>`, session
   `<iq id="_xmpp_session1" type="set"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></iq>`.
7. Entitlements: `<iq id="xmpp_entitlements_0" type="set"><entitlements xmlns="urn:riotgames:entitlements"><token xmlns="">{entitlements_token}</token></entitlements></iq>`.
8. Friends: `<iq type="get" id="roster_1"><query xmlns="jabber:iq:riotgames:roster" last_state="true"/></iq>`;
   history: `<iq type="get" id="…"><query xmlns="jabber:iq:riotgames:archive"><with>{jid}</with></query></iq>`.
9. Send own `<presence/>`; keep-alive: write a single space every ~120 s.
10. Direct message: `<message id="…" to="{puuid}@{domain}.pvp.net" type="chat"><body>…</body></message>`.

Presence stanza for a Valorant friend (format from molenzwiebel/Deceive; `<p>` = base64 JSON):

```xml
<presence from='41c322a1-b328-495b-a004-5ccd3e45eae8@eu1.pvp.net/RC-…' id='b-…'>
  <games><valorant><st>chat</st><s.t>1776984071363</s.t><s.p>valorant</s.p><s.r>PC</s.r><p>eyJpc0lkbGUiOmZhbHNlLCJpc1ZhbGlkIjp0cnVlLC…</p><pty/></valorant></games>
  <show>chat</show><platform>riot</platform><status/>
</presence>
```

Decoded `<p>` — **nested format (2024+), real sample from `[LOG26]` (2026-04)**:

```json
{
  "isIdle": false,
  "isValid": true,
  "matchPresenceData": { "matchMap": "", "provisioningFlow": "Invalid", "queueId": "deathmatch", "sessionLoopState": "MENUS" },
  "maxPartySize": 5,
  "partyId": "62d30f62-98c0-4f6f-8380-350a84aac00e",
  "partyOwnerMatchScoreAllyTeam": 0,
  "partyOwnerMatchScoreEnemyTeam": 0,
  "partyPresenceData": {
    "customGameName": "", "customGameTeam": "", "isPartyCrossPlayEnabled": false, "isPartyOwner": true,
    "isPlayerCrossPlayEnabled": false, "maxPartySize": 5, "partyAccessibility": "CLOSED",
    "partyClientVersion": "release-12.07-shipping-9-4488404", "partyId": "62d30f62-98c0-4f6f-8380-350a84aac00e",
    "partyLFM": false, "partyOwnerMatchMap": "", "partyOwnerMatchScoreAllyTeam": 0, "partyOwnerMatchScoreEnemyTeam": 0,
    "partyOwnerProvisioningFlow": "Invalid", "partyOwnerSessionLoopState": "MENUS", "partyPrecisePlatformTypes": 1,
    "partySize": 1, "partyState": "DEFAULT", "partyVersion": 1776984071363, "queueEntryTime": "2026.04.23-22.40.57",
    "rosterId": "", "tournamentId": ""
  },
  "partySize": 1,
  "playerPresenceData": { "accountLevel": 98, "competitiveTier": 12, "leaderboardPosition": 0,
                          "playerCardId": "5b338357-4ee4-b112-a050-bcbf542ad9ba", "playerTitleId": "95cd86c0-4911-548c-ad76-98a4dfb3d55b" },
  "premierPresenceData": { "division": 0, "plating": 0, "rosterId": "", "rosterName": "", "rosterTag": "",
                           "rosterType": "VCT", "score": 0, "showAura": false, "showPlating": false, "showTag": false },
  "provisioningFlow": "Invalid",
  "queueId": "deathmatch"
}
```

Roster items (`jabber:iq:riotgames:roster`, `last_state="true"`) look like
`<item jid='{puuid}@{domain}.pvp.net' puuid='…' subscription='both'><state>online|offline|…</state><last_online>2025-03-11 22:00:04.505</last_online><id name='GameName' tagline='TAG'/><platforms><riot name='…' tagline='…'/></platforms></item>`
(community clients 2025: Nakik/ValorantApp, lol-headless-client; attribute set **UNVERIFIED** — fall back to
name-service for names). `last_online` feeds ValBuddy's "last online" line.

**Your own presence** (from your game client's resource, same bare JID as you) also arrives over XMPP. It is the
data source for ValBuddy's **live round score** (G7: `partyOwnerMatchScoreAllyTeam` / `…EnemyTeam`, top level or in
`partyPresenceData`), the current `partyId` (GinzaTech/Vshop reads it this way) and `sessionLoopState`. Whether the
score updates every round is **UNVERIFIED**; hide the score when both values are 0 in `INGAME`.

The older flat format (`sessionLoopState`, `partyOwnerMatchMap`, `competitiveTier` at top level —
`[VAD]` Presence schema) is **DEPRECATED**; parse nested first, fall back to flat. Friend JIDs are
`{puuid}@{domain}.pvp.net`, so a friend's PUUID feeds directly into MMR / match-history ("friends'
profiles").

---

## 17. Static data needed alongside (valorant-api.com, no auth)

Not Riot, but every Riot response above is IDs only. Key endpoints (all `?language=vi-VN` for
Vietnamese names — supported locale list on valorant-api.com):

| Need | Endpoint |
|---|---|
| Client version | `/v1/version` |
| Weapons, skins, levels, chromas (video, tier) | `/v1/weapons`, `/v1/weapons/skins`, `/v1/weapons/skinlevels`, `/v1/weapons/skinchromas` |
| Content tiers (Select/Deluxe/Premium/Exclusive/Ultra, colors) | `/v1/contenttiers` |
| Bundles | `/v1/bundles/{DataAssetID}` |
| Buddies / levels | `/v1/buddies`, `/v1/buddies/levels` |
| Sprays, Flex, cards, titles, level borders | `/v1/sprays`, `/v1/flex`, `/v1/playercards`, `/v1/playertitles`, `/v1/levelborders` |
| Agents, maps, queues, game modes | `/v1/agents?isPlayableCharacter=true`, `/v1/maps` (match on `mapUrl`), `/v1/gamemodes/queues`, `/v1/gamemodes` |
| Ranks | `/v1/competitivetiers`, `/v1/seasons`, `/v1/seasons/competitive` |
| Battle pass & missions | `/v1/contracts`, `/v1/missions` |
| Currencies | `/v1/currencies` |

---

## Appendix A — Item type IDs (`ItemTypeID` / content types)

Internal names from nyrpqsqq35/valoreye `ValorantItemType` enum, cross-checked with entitlement calls in
`[LOG25]`/`[LOG26]`, `[RB]` `ItemType.ID`, `[SP]`, `[VS]`, VRY sockets.

| ItemTypeID | Internal name | Meaning in ValVN | Used in |
|---|---|---|---|
| `01bb38e1-da47-4e6a-9b3d-945fe4655707` | Character | Agents (non-starter unlocks) | entitlements |
| `e7c63390-eda7-46e0-bb7a-a6abdacd2433` | EquippableSkinLevel | **Weapon skins** (skin levels) — daily shop/NM/bundle rewards | entitlements, offers, sockets |
| `3ad1b2b2-acdb-4524-852f-954a76ddae0a` | EquippableSkinChroma | Skin chromas / variants | entitlements, sockets |
| `bcef87d6-209b-46c6-8b19-fbe40bd95abc` | EquippableSkin | Skin (parent) | loadout sockets |
| `dd3bf334-87f3-40bd-b043-682a57a8dc3a` | EquippableCharmLevel | **Gun buddies** (buddy levels, with `InstanceID`) | entitlements, offers, sockets |
| `77258665-71d1-4623-bc72-44db9bd5b3b3` | EquippableCharm | Buddy (parent) | sockets; queried by client |
| `d5f120f8-ff8c-4aac-92ea-f2b5acbe9475` | Spray | Sprays; also `ActiveExpressions.TypeID` for sprays | entitlements, offers, loadout |
| `290f8769-97c6-492a-a1a8-caacf3d5b325` | SprayLevel | Spray levels | entitlements |
| `03a572de-4234-31ed-d344-ababa488f981` | Flex ("Totem") | Flex items (since 10.00); `ActiveExpressions.TypeID` for flex | entitlements, offers, loadout |
| `3f296c07-64c3-494c-923b-fe692a4fa1bd` | PlayerCard | Player cards | entitlements, offers |
| `de7caa6b-adf7-4588-bbd1-143831e786c6` | PlayerTitle | Titles | entitlements, offers |
| `f85cb6f7-33e5-4dc8-b609-ec7212301948` | PremiumContract | Premium battle/event pass ownership | entitlements |
| `0381b6a6-e901-4225-a30c-b18afc6d0ad4` | Contract | Contracts (agent/other) — exact use **UNVERIFIED** | entitlements |
| `ac3c307a-368f-4db8-940d-68914b26d89a` | Mission | Missions | entitlements |
| `6520634c-bd1e-4fc4-81af-cac5dc723105` | EquippableAttachment | Weapon attachments (unused by UI) | entitlements |
| `51c9eb99-3e6b-4658-801f-a5a7fd64bb9d` | Equippable | Equippables (weapons) | entitlements |
| `e632de5f-3ef9-45fe-97f2-10ee16ac1d50` | Loyalty (entitlement type) | **UNVERIFIED** | entitlements |
| `ea6fcd2e-8373-4137-b1c0-b458947aa86d` | CurrencyReward | `ItemTypeID` of currency rewards in offers (e.g. Radianite packs) | offers |
| `4e60e748-bce6-4faa-9327-ebbe6089d5fe` | PermanentEntitlement | value of each entitlement row's `TypeID` (not an item type) | entitlements |

Level borders have no ItemTypeID (level-gated). Weapon IDs: valorant-api `/v1/weapons` (21 entries incl.
Melee `2f59173c-4bed-b6c3-2191-dea9b58be9c7`, Vandal `9c82e19d-4575-0200-1a81-3eacf00cf872`).

## Appendix B — Currency IDs

| CurrencyID | Name (valorant-api 2026-09) | Internal (valoreye) | Where |
|---|---|---|---|
| `85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741` | VALORANT Points (VP) | AresPoint | wallet, shop, bundles, NM |
| `e59aa87c-4cbf-517a-5983-6e81511be9b7` | Radianite Points | UpgradeToken | wallet, upgrades |
| `85ca954a-41f2-ce94-9b45-8ca3dd39a00d` | Kingdom Credits (KC) | — | wallet, accessory store |
| `f08d4ae3-939c-4576-ab26-09ce1f23bb37` | Agent Tokens (formerly "Free Agents") | RecruitmentToken | wallet, agent unlocks |
| `8e755510-5d2b-4921-ad75-bed2de113b18` | Contract XP (internal) | ContractXPCurrency | not in wallet (**UNVERIFIED**) |

## Appendix C — Queue IDs (valorant-api `/v1/gamemodes/queues`, 2026-09-28)

PC: `competitive`, `unrated`, `swiftplay`, `spikerush`, `deathmatch`, `hurm` (Team Deathmatch), `ggteam`
(Escalation), `onefa` (Replication), `snowball`, `valaram` (All Random One Site), `dodgeball` (Knockout),
`fortcollins` (Retake), `abilitydraftarena` (Gauntlet: Glitched), `skirmish2v2`, `skirmishascension1v1`,
`skirmishascension2v2`, `newmap` (Summit), `premier`, `custom` (match-details `queueID` is `""` for customs).
Console: same names prefixed `console_` (e.g. `console_competitive`, `console_unrated`,
`console_swiftplay`, `console_hurm`, `console_deathmatch`, `console_skirmish2v2`, …). Whether console
ranked appears under `QueueSkills["console_competitive"]` in MMR: **UNVERIFIED**.

## Appendix D — Competitive tier numbers

`0` Unranked · `1-2` unused · `3/4/5` Iron 1/2/3 · `6-8` Bronze · `9-11` Silver · `12-14` Gold ·
`15-17` Platinum · `18-20` Diamond · `21-23` Ascendant · `24-26` Immortal 1/2/3 · `27` Radiant
(table `03621f52-342b-cf4e-4f86-9350a49c6d04`, used by the current act). Images per tier in valorant-api
`/v1/competitivetiers/{uuid}`.

## Appendix E — 2024–2026 change log (what broke older clones)

| When | Change | Action for ValVN |
|---|---|---|
| 2023-06 (Ep 7) | Daily missions → Daily Ticket checkpoints (`/daily-ticket/v1`) + Kingdom Credits + Accessory store | implement §12.2, KC currency, `AccessoryStore` |
| 2023-08 → | Username/password auth API blocked by hCaptcha | WebView login only (§3) |
| 2024-05 | Riot client headers automated in SkinPeek (version from valorant-api) | always send fresh `X-Riot-ClientVersion` |
| 2024–2025 (exact date UNVERIFIED) | XMPP private presence became nested (`matchPresenceData`/`partyPresenceData`/`playerPresenceData`) | parse nested, fall back to flat |
| 2024-09-24 | Storefront `GET /store/v2` → `POST /store/v3` with `{}` body | §5.1 |
| 2025-01 (patch 10.00) | Flex cosmetic + Expressions wheel; loadout `personalization/v3` with `ActiveExpressions`/`DynamicOptions` (v2 `Sprays` gone) — v3 date inferred | §7 |
| 2025-01 | Episodes renamed "Season 2025/2026" (valorant-api episode names `V25`, `V26`) | display names from valorant-api |
| ≤ 2026-04 | Config fetched from `shared.{shard}` host by the client | §13.2 |
| ≤ 2026-04 | `store/v1/offers` no longer called by the client | treat as optional |
| 2026-04 | Cloudflare challenge pages observed on PD (`name-service`) | handle HTML 403, back off |

## Appendix F — Open risks / UNVERIFIED items

1. **ToS / ban risk**: undocumented endpoints; Riot tolerates read-only companion apps, but automated
   state-changing calls (loadout PUT, agent lock, renew) are at the user's risk. Keep volumes human-like.
2. **Auth fragility**: WebView + cookie re-auth may be broken at any time by Riot (captcha, new
   `authenticate.riotgames.com` flows, Google login inside WebViews blocked by Google's embedded-browser
   policy — may require `ASWebAuthenticationSession`/Custom Tabs instead of a WebView).
3. `store/v1/offers` availability in 2026 (removed from client traffic).
4. Agent storefront shape comes only from `[VAD-F]` (`PluginStores` is now seen in real 2026 responses; ignored).
5. Loadout v3 introduction date, whether v2 still answers, exact PUT validation errors, whether omitting
   `Version` is accepted, partial `Guns` behaviour.
6. Daily-ticket wrapper keys beyond `DailyRewards`; reset time rules; XP/KC per checkpoint.
7. Favorites response fields other than `FavoritedContent{…ItemID}`; add/remove endpoints.
8. Penalty object shape (`[VAD-F]` only); `Infractions`.
9. Console accounts: required `X-Riot-ClientPlatform`, console queue keys in MMR/match history.
10. Leaderboard endpoint not seen in 2025/2026 logs (still used by third-party apps).
11. Night-market next-start date only via a community gist; no "mark seen" endpoint.
12. Rate limits (exact quotas, `Retry-After`) and Cloudflare thresholds on PD hosts.
13. ~~`competitiveupdates`/`match-history` maximum page size~~ = 20 (resolved); `name-service` max batch size still UNVERIFIED.
14. Whether the server masks names/levels of `Incognito` / `HideAccountLevel` players in name-service.
15. Content-service season `Name` strings for 2025+ ("V26" vs "Season 2026").

## Appendix G — Sources

- valapidocs.techchrism.me and github.com/techchrism/valorant-api-docs (`valorant-api-types/src/endpoints/*`, `tests/endpoint-responses/*`)
- github.com/PrometheuzzZ/valorant-api-docs (2026 fork: storefront v3, loadout v3, all-owned-items, penalties, session)
- github.com/giorgi-o/SkinPeek (`valorant/shop.js`, `battlepass.js`, `inventory.js`, `auth.js`, `misc/util.js`; commit `6e30c0c` 2024-09-24)
- github.com/GinzaTech/Vshop (`services/riot/endpoints.ts`, `loadout-api.ts`, `storefront-parser.ts`, `progression-api.ts`, `match-api.ts`, `utils/xmpp-client.ts`, `utils/chat-service.ts`; 2026-09-27)
- github.com/yanislgha/ValorantAPI (Recon Bolt Swift API: `Requests/*`, `Models/*`, `Tests/.../examples/*`)
- github.com/ShidqiFaadhil/logs (ShooterGame.log, 2025-06-06, AP) and github.com/LRAFam/upforge-desktop `scripts/riot-api-probe/probe-output-*` (2026-04-23, EU)
- github.com/zachrip/valpal, github.com/truearken/valclient, github.com/nekodayo1337/VL-loadout-editor, github.com/zayKenyon/VALORANT-rank-yoinker, github.com/molenzwiebel/Deceive, github.com/nyrpqsqq35/valoreye, github.com/Superamaja/valorant-lightweight-tracker (docs/backend-spec.md), github.com/Anton7444/valorant-shop, github.com/VShopApp/mobile, github.com/techchrism/riot-auth-test
- valorant-api.com (`/v1/version`, `/currencies`, `/seasons`, `/seasons/competitive`, `/competitivetiers`, `/contracts`, `/missions`, `/flex`, `/levelborders`, `/gamemodes/queues`, `/weapons`, `/bundles`)
- playvalorant.com "Progression Update Explainer + FAQ" (Daily checkpoints, Accessory store); ValBuddy site and App Store listing (feature list, v2.1.2 notes)
