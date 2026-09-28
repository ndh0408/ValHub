# ValVN research SUMMARY (authoritative reference)

> Review date **2026-09-28**. Valorant client `release-13.06-shipping-13-5435758` (valorant-api `/v1/version`: `riotClientBuild 111.0.0.3261.5663`, `manifestId 67AF51413C6922AE`, build 2026-09-03). Current act: **V26 // ACT V** (`8102cd81-43a0-d0d7-bd59-47b8fe9bed1b`, 2026-08-19 → 2026-10-14). Target: ValBuddy **2.1.2** parity, Flutter 3.47.5 / Dart 3.13.4, Vietnamese UI.
>
> This file de-duplicates and overrides the five detail docs. When a detail doc and this file disagree, **this file wins**. The detail docs hold the long-form evidence and example payloads:
> - `riot-auth.md`: login and tokens
> - `riot-endpoints.md` (EP)
> - `content-api.md` (CA)
> - `valbuddy-features.md` (VF)
> - `flutter-stack.md` (FS)
>
> Section refs like "EP §5.1" point into those files.

Evidence labels:

| Label | Meaning |
|---|---|
| **[LIVE]** | Reproduced with curl on 2026-09-28 |
| **[REAL-2026]** | Verified with a real account by a named 2026 open-source app |
| **[DOC]** | techchrism valapidocs (last changed 2024-04) |
| **[SRC]** | Read in named, maintained source code |
| **[LOG]** | Real ShooterGame.log traffic, 2025-06 (AP) and 2026-04 (EU) |
| **UNVERIFIED** | Not confirmed |

New primary sources used in this review, beyond the detail docs:
- KaiC5504/DailyStore `docs/riot-api.md`: iOS app, real-account checks on 2026-09-23/24.
- GinzaTech/Vshop @ `9796ba6` (2026-09-27).
- Fantsry/store-checkerval: Flutter, 2026-09-22.
- techchrism/riot-auth-test.
- SkinPeek @ `67882a0`.
- RadiantConnect and valclient.js.
- Live curl probes.

---

## 1. Corrections made during this review

| # | Where | Problem | Resolution (and evidence) |
|---|---|---|---|
| 1 | `riot-auth.md` | The file was **truncated** mid-sentence in §1.5. The referenced §2.4, §3.2 and §9 did not exist | Completed §1.5–§10: MFA, remember-me, social-login UA, cookie capture, multi-account isolation, bootstrap, silent re-auth (primary + fallback), rotation, error classes, storage, sign-out, background, VN, policy, risks |
| 2 | riot-auth, FS §9 | "up to 5 accounts" | **10 accounts** (ValBuddy 2.1.0 changelog; VF A3) |
| 3 | FS §0/§10 | The router had **4** tabs ("Kho đồ", "Sự nghiệp") | **5 tabs**: Cửa hàng · Battle Pass · Bộ sưu tập · Hồ sơ · Cài đặt (VF §6). Snippet re-checked with `flutter analyze` |
| 4 | FS §7 | `RiotAuthInterceptor` refreshed only on **401** | PD/GLZ signal an expired token with **`400 {"errorCode":"BAD_CLAIMS"}`** (EP §4, SkinPeek, Fantsry). Refresh on 401 **or** 400 BAD_CLAIMS. Snippet re-checked |
| 5 | FS §6 | Callback detector `host.endsWith('playvalorant.com') && path.contains('opt_in')` was too loose, and no UA was set | Strict regex from riot-auth §1.3, plus a mobile-browser `userAgent` for Google sign-in. Re-checked |
| 6 | FS §16 vs CA §2 | Content cache fetched `weapons/skins` and keyed on `version` | Fetch **`/v1/weapons`** (it includes the weapon↔skin relation) and key on **`manifestId`** + `vi-VN` + schema version |
| 7 | EP §3, SkinPeek | Dead-session test `Location.startsWith("/login")` | Today's dead `Location` is the **absolute** `https://authenticate.riotgames.com/login?...`, or `#error=interaction_required&error_description=login_required` with `prompt=none` **[LIVE]**. Test for `access_token`/`error` instead |
| 8 | EP §9, §11 | "match-details already contains gameName/tagLine" | In real 2026-09 responses `players[].gameName/tagLine` arrive **blank** **[REAL-2026 DailyStore]**. Always resolve names via name-service |
| 9 | EP §10.2, §11.1 | Page size "25 observed, larger UNVERIFIED" | **Max 20** per page. Wider pages fail with `400 MATCH_HISTORY_INVALID_INDICES` / `400 MMR_INVALID_INDICES` **[REAL-2026 DailyStore]** |
| 10 | EP §15.4 | Party mutations were "not ValBuddy features" | ValBuddy 2.1.0 ships party + remote queue (VF S1–S4). Full endpoint list added (§6.4 here) |
| 11 | EP §15.2/15.3 | Quit/leave marked "do not expose" | ValBuddy exposes **Quit Match** in agent select and in a running match (VF G10). Expose it behind a confirmation. Core-game quit = `disassociate` ([DOC]); Vshop's `/core-game/v1/matches/{id}/quit` is UNVERIFIED |
| 12 | EP §5.1 | `PluginStores` UNVERIFIED | Present in real 2026 storefront responses **[REAL-2026 DailyStore]**. Not a feature; ignore it |
| 13 | EP §7.2 | "`Guns` (all 20)" | 21 weapons in 13.06 (Bandit and Warden added). Never hard-code the count, and **round-trip unknown fields** on PUT |
| 14 | EP §16 | No source for the **live round score** (G7) or for friends' "last online" | Own XMPP presence `partyOwnerMatchScoreAllyTeam/EnemyTeam`; roster `<last_online>` |
| 15 | CA §6.2/§11 | Loadout spray field `Sprays[].SprayID` (v2) | v3 `ActiveExpressions[].{TypeID,AssetID}` |
| 16 | CA §12 | Battle-pass XP off-by-one UNVERIFIED | Resolved by arithmetic on a ValBuddy screenshot: next-level XP = `flat[ProgressionLevelReached].xp` (§9.4) |
| 17 | CA §9.1 | Custom-game `queueID` `""` vs `"custom"` UNVERIFIED | `""`, with `provisioningFlowID "CustomGame"` **[REAL-2026 DailyStore]** |
| 18 | VF S33 | Weapon categories taken from `shopData.categoryText` | App-owned labels keyed by the `category` enum (the Shotgun text is broken, CA §3.1) |
| 19 | VF S50/S55/S60, EP headers, FS pubspec | Missing data sources, UA and packages | Added data lines, a `User-Agent` row, and `xml` 7.1.0 + `share_plus` 13.3.0 (both resolve, analyze clean) |

---

## 2. Architecture in one picture

```
[WebView login]  auth.riotgames.com/authorize (ui_locales=vi, state, nonce, mobile-browser UA)
      └─ callback https://playvalorant.com[/vi-vn]/opt_in#access_token&id_token  → CANCEL navigation
      └─ read cookies for https://auth.riotgames.com/ (ssid, clid, csid, tdid, asid, …) → per-PUUID jar (secure storage)
[Bootstrap]      entitlements token → userinfo (Riot ID) → riot-geo (region → shard) → valorant-api version
[Every call]     PD / GLZ / shared with the headers in §5; 401 or 400 BAD_CLAIMS → single-flight re-auth → retry once
[Re-auth]        GET /authorize?prompt=none + Cookie jar (no redirects) → tokens; persist rotated cookies
                 fallback: POST /api/v1/authorization + Cookie jar
[Social]         XMPP TLS :5223 (PAS token + access token SASL) → roster, presence (incl. OWN presence), chat
[Content]        valorant-api.com ?language=vi-VN, disk cache keyed on manifestId, parsed in an isolate
[Local only]     wishlist, presets, RR history (true peak / daily RR), price table, notifications, session log
```

---

## 3. Auth flow (final)

### 3.1 Constants

| Name | Value |
|---|---|
| `client_id` | `play-valorant-web-prod` |
| `redirect_uri` | `https://playvalorant.com/opt_in` |
| `response_type` | `token id_token`. Send `token%20id_token`; `token+id_token` is also accepted **[LIVE]** |
| `scope` | `account openid` |
| Login extras | `nonce` = 32 random bytes as hex, `state` = 32 random bytes as hex, `ui_locales=vi` |
| Re-auth extras | `nonce=1`, `prompt=none` |
| Callback match | All of: scheme `https`; host `playvalorant.com` or `www.playvalorant.com`; path matches `^/(?:[a-z]{2}-[a-z]{2}/)?opt_in/?$` (case-insensitive); fragment (or query) has `access_token` or `error` |
| WebView UA | iOS: `Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1`. Android: `Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36`. Remote-overridable |
| API UA | `RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)`. Remote-overridable |
| Max accounts | 10 |

### 3.2 Login (add account / re-login)

1. Call `CookieManager.instance().deleteAllCookies()`, so the WebView never reuses another account's SSO session.
2. Open this URL in `InAppWebView`: `https://auth.riotgames.com/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in&client_id=play-valorant-web-prod&response_type=token%20id_token&scope=account%20openid&nonce={n}&state={s}&ui_locales=vi`
   - Settings: `useShouldOverrideUrlLoading: true`, `javaScriptEnabled`, `thirdPartyCookiesEnabled`, `sharedCookiesEnabled`, `incognito: false`, and the mobile-browser `userAgent`.
   - Show the hint "Hãy tick *Duy trì đăng nhập*".
3. Restrict navigation.
   - Allow main-frame navigation only to: `*.riotgames.com`, `playvalorant.com`, `accounts.google.com`, `appleid.apple.com`, `login.live.com`, `*.playstation.com`, `*.facebook.com`, `*.hcaptcha.com` and the lolstatic hosts.
   - Open anything else with `url_launcher`.
   - Allow sub-frames (hCaptcha).
   - Handle `onCreateWindow` by loading the URL in the same WebView (need is UNVERIFIED).
4. Detect the callback.
   - Check in `shouldOverrideUrlLoading` (return CANCEL), `onLoadStart` and `onUpdateVisitedHistory`.
   - Run the handler once (`_completed` flag).
   - Ignore load errors for the callback URL.
5. Validate the callback:
   - there is no `error`;
   - `state` matches;
   - `access_token` and `id_token` are each present exactly once;
   - `id_token.nonce == nonce`;
   - on re-login, `access_token.sub` equals the saved PUUID. If it doesn't, offer "add as new account".
6. Capture the cookies.
   - Wait ~300 ms (iOS cookie-store lag), then call `getCookies(url: https://auth.riotgames.com/)`.
   - Require `ssid`; retry once if it's missing.
   - Save **all** cookies as `{name: value}` in secure storage under the PUUID.
   - Clear the WebView cookies again.
7. Bootstrap (§3.3).

### 3.3 Bootstrap (after login and after every re-auth)

| Step | Request | Take |
|---|---|---|
| a | `POST https://entitlements.auth.riotgames.com/api/token/v1` · `Authorization: Bearer {access}` · `Content-Type: application/json` · body `{}` | `entitlements_token` |
| b | `GET https://auth.riotgames.com/userinfo` (Bearer). Login only | `sub` (PUUID), `acct.game_name`, `acct.tag_line`, `country` |
| c | `PUT https://riot-geo.pas.si.riotgames.com/pas/v1/product/valorant` (Bearer), body `{"id_token":"…"}`. At login, or when the region is unknown | `affinities.live` → region; shard map in §4 |
| d | `GET https://valorant-api.com/v1/version`. At app start and every 6 h | `riotClientVersion`, `riotClientBuild`, `manifestId` |

Token lifetimes:
- Access and id tokens last 3600 s (`expires_in`, JWT `exp`). Refresh when less than 5 min is left.
- Entitlements token: re-fetch after every re-auth.

### 3.4 Silent re-auth (per account, single-flight)

**Primary** **[LIVE shape, REAL-2026 DailyStore/Fantsry/SkinPeek]**:

```
GET https://auth.riotgames.com/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in&client_id=play-valorant-web-prod&response_type=token%20id_token&scope=account%20openid&nonce=1&prompt=none
Cookie: {jar}        User-Agent: {API UA}        followRedirects=false, validateStatus < 500
```

| Result | Class | Action |
|---|---|---|
| 303 → `…/opt_in#access_token=…&id_token=…&expires_in=3600` | ok | Merge `Set-Cookie` into the jar and **persist it before anything else**; then bootstrap step a |
| 303 → `…#error=interaction_required…login_required`, or 30x → absolute `https://authenticate.riotgames.com/login?…` | needsLogin | Stop, mark the account, notify once |
| 403 HTML (Cloudflare), 429, 5xx, timeout | transient | Keep the session. Retry once with the **previous** jar. Back off 30 s → 10 min, honouring `Retry-After` |
| Anything else without a token | transient once, then fallback | |

**Fallback** **[LIVE dead case; SRC Vshop 2026 (its only renewal, device-verified), Fantsry 2026]**:

- Request: `POST https://auth.riotgames.com/api/v1/authorization` with the same Cookie and UA, `Content-Type: application/json`, and body `{"client_id":"play-valorant-web-prod","nonce":"1","redirect_uri":"https://playvalorant.com/opt_in","response_type":"token id_token","scope":"account openid"}`.
- ok: `{"type":"response","response":{"parameters":{"uri":"https://playvalorant.com/opt_in#access_token=…"}}}`.
- needsLogin: `{"type":"auth",…}` or `{"type":"multifactor",…}`.
- The username/password **PUT** on this URL is dead behind hCaptcha. Never implement it.

Cookie facts:
- Each re-auth rotates `ssid`, `clid` and `csid` with `Max-Age` 30 days. `tdid` (1 year) and `asid` don't rotate **[REAL-2026 DailyStore]**. The session therefore slides forward.
- 2023 measurement (techchrism/riot-auth-test): replaying the original cookies died after ~7 days; the refreshed full set lasted 21+ days; ~7–9 % of attempts failed sporadically.
- Therefore:
  - always save the rotated cookies;
  - keep the previous jar;
  - retry once on failure;
  - re-auth dormant accounts at least every ~7 days from the background task.

Re-auth triggers:
- the token has less than 5 min left;
- `401` from auth hosts;
- `400 BAD_CLAIMS` from PD/GLZ;
- a name-service `403` with a **JSON** body (Vshop treats it as an auth failure).

Concurrency:
- Keep one in-flight re-auth per PUUID, shared by the UI, the providers and the background isolate.
- Use a per-account lock plus a timestamp in prefs.
- Two parallel re-auths can invalidate each other's rotated cookies.

### 3.5 Storage

Secure storage uses `storageNamespace: valvn_secure` and iOS `first_unlock_this_device`:

| Key | Value |
|---|---|
| `acct.{puuid}.cookies` / `acct.{puuid}.cookies.prev` | JSON `{name: value}`, current and previous jar |
| `acct.{puuid}.access`, `.id`, `.entitlements`, `.expiry` | optional token cache |

Non-secret metadata goes in `shared_preferences`: PUUID, Riot ID, region, shard, card id, last rank, needsLogin flag.

Other rules:
- Wipe the keychain on first launch after a reinstall.
- Keep Android backup disabled.
- Sign-out: delete that PUUID's jar, tokens, caches and scheduled notifications. Keep the wishlist (VF W6).

---

## 4. Hosts, regions, shards

| `affinities.live` (region) | shard | PD | GLZ | shared | status JSON |
|---|---|---|---|---|---|
| `ap` (**Vietnam**) | `ap` | `pd.ap.a.pvp.net` | `glz-ap-1.ap.a.pvp.net` | `shared.ap.a.pvp.net` | `ap.json` 200 **[LIVE]** |
| `na` | `na` | `pd.na.a.pvp.net` | `glz-na-1.na.a.pvp.net` | `shared.na.a.pvp.net` | `na.json` 200 **[LIVE]** |
| `latam` | `na` | `pd.na.a.pvp.net` | `glz-latam-1.na.a.pvp.net` | `shared.na.a.pvp.net` | `latam.json` 403 (name UNVERIFIED) |
| `br` | `na` | `pd.na.a.pvp.net` | `glz-br-1.na.a.pvp.net` | `shared.na.a.pvp.net` | `br.json` 403 (name UNVERIFIED) |
| `eu` | `eu` | `pd.eu.a.pvp.net` | `glz-eu-1.eu.a.pvp.net` | `shared.eu.a.pvp.net` | `eu.json` 200 **[LIVE]** |
| `kr` | `kr` | `pd.kr.a.pvp.net` | `glz-kr-1.kr.a.pvp.net` | `shared.kr.a.pvp.net` | `kr.json` 403 (name UNVERIFIED) |
| `pbe` | `pbe` | UNVERIFIED | UNVERIFIED | | |

Keep `region` and `shard` as two separate fields, because GLZ uses both. The AP hosts are confirmed in [LOG] 2025-06.

---

## 5. Headers

### 5.1 Game servers (PD / GLZ / shared): send on every call

| Header | Value |
|---|---|
| `Authorization` | `Bearer {access_token}` |
| `X-Riot-Entitlements-JWT` | `{entitlements_token}` |
| `X-Riot-ClientVersion` | `{riotClientVersion}` from valorant-api `/v1/version`. Fallback constant: `release-13.06-shipping-13-5435758`. If a call fails with a version error while the user is in game, retry with the GLZ session's `clientVersion` |
| `X-Riot-ClientPlatform` | `ew0KCSJwbGF0Zm9ybVR5cGUiOiAiUEMiLA0KCSJwbGF0Zm9ybU9TIjogIldpbmRvd3MiLA0KCSJwbGF0Zm9ybU9TVmVyc2lvbiI6ICIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwNCgkicGxhdGZvcm1DaGlwc2V0IjogIlVua25vd24iDQp9` (tab/CRLF PC JSON; **[REAL-2026 DailyStore]**, SkinPeek). The compact variant `eyJwbGF0Zm9ybVR5cGUiOiJQQyIs…` also works (Vshop) |
| `User-Agent` | API UA (§3.1) |
| `Content-Type` | `application/json` on POST/PUT with a body |
| `Accept-Encoding` | `gzip` |

### 5.2 Auth hosts

| Calls | Headers |
|---|---|
| `/authorize`, `/api/v1/authorization` | `Cookie` + API UA (+ JSON content type on POST) |
| Entitlements, userinfo, riot-geo, PAS | `Authorization: Bearer` |
| Client config | Bearer **and** `X-Riot-Entitlements-JWT` |

### 5.3 valorant-api.com

- No auth.
- Always send `?language=vi-VN`. It is case-sensitive: `vi` and `vi-vn` return 404.
- Response envelope: `{"status":200,"data":…}`.

---

## 6. Final endpoint table

Status codes:

| Code | Meaning |
|---|---|
| **C** | Current: seen in client traffic 2025/2026, or used by a maintained 2026 app |
| **D** | Documented only (valapidocs / community) |
| **U** | UNVERIFIED |

"Own" = works only for the signed-in PUUID; "Any" = works for any PUUID.

### 6.1 Auth / account

| # | Method + URL | Body / query | Feature | St. |
|---|---|---|---|---|
| A-1 | WebView `GET https://auth.riotgames.com/authorize?…` | §3.2 | A1, A2, A3 | C |
| A-2 | `GET https://auth.riotgames.com/authorize?…&prompt=none` + Cookie | — | A5–A7 | C |
| A-3 | `POST https://auth.riotgames.com/api/v1/authorization` + Cookie | §3.4 | A5 fallback | C |
| A-4 | `POST https://entitlements.auth.riotgames.com/api/token/v1` | `{}` | all | C |
| A-5 | `GET https://auth.riotgames.com/userinfo` | — | A4 (Riot ID) | C |
| A-6 | `PUT https://riot-geo.pas.si.riotgames.com/pas/v1/product/valorant` | `{"id_token":…}` | region/shard | C |
| A-7 | `GET https://riot-geo.pas.si.riotgames.com/pas/v1/service/chat` | — → raw JWT (`affinity` claim) | S5–S7 | C |
| A-8 | `GET https://clientconfig.rpg.riotgames.com/api/v1/config/player?app=Riot%20Client` | — → `chat.affinities`, `chat.affinity_domains`, `chat.port` | S5–S7 | C |

### 6.2 PD: `https://pd.{shard}.a.pvp.net`

| # | Method + path | Notes | Feature | St. |
|---|---|---|---|---|
| P-1 | `POST /store/v3/storefront/{puuid}` body `{}` (400 without a body) | Daily shop, bundles, Night Market (`BonusStore` absent when none), accessory store. Own | B1–B6, W2 | C |
| P-2 | `GET /store/v1/wallet/{puuid}` | `Balances{currencyId: n}`; a missing currency = 0. Own | B2 | C |
| P-3 | `GET /store/v1/entitlements/{puuid}/{itemTypeId}` | One call per type (what the client does). Shape is `{ItemTypeID, Entitlements[{TypeID,ItemID,InstanceID?}]}` or `EntitlementsByTypes[]`; parse both. Own | C1–C10, G4 | C |
| P-4 | `GET /store/v1/entitlements/{puuid}` (all types) | Optional optimisation | C* | D |
| P-5 | `GET /store/v1/offers/` | Global price list; not in 2025/26 client traffic | B9, C8 fallback | U |
| P-6 | `GET /favorites/v1/players/{puuid}/favorites` | `FavoritedContent{id:{ItemID}}`. Own | C (hearts) | C |
| P-7 | `GET /contract-definitions/v3/item-upgrades` | RP costs of levels and chromas | B7 (optional) | C |
| P-8 | `GET` / `PUT /personalization/v3/players/{puuid}/playerloadout` | PUT = the whole object from a fresh GET, mutated. Own | C2–C4, U6/U7 | C |
| P-9 | `GET /account-xp/v1/players/{puuid}` | `Progress.{Level,XP}`; 5000 XP per level. Own | R1, A4 | C |
| P-10 | `PUT /name-service/v2/players` body `["puuid",…]` | `[{Subject,GameName,TagLine,DisplayName}]`; batch. Any | R10–R14, G5, S2, S5 | C |
| P-11 | `GET /mmr/v1/players/{puuid}` | `QueueSkills`, `LatestCompetitiveUpdate`. Any | R2, R3, R6, G5, G6, S2 | C |
| P-12 | `GET /mmr/v1/players/{puuid}/competitiveupdates?startIndex=&endIndex=&queue=competitive` | Page ≤ 20. Any | R4, R5, R6, R8 | C |
| P-13 | `GET /match-history/v1/history/{puuid}?startIndex=&endIndex=&queue=` | Page ≤ 20. Any | R8, R9, R13 | C |
| P-14 | `GET /match-details/v1/matches/{matchId}` | 0.2–2 MB; use gzip; cache forever; 404 right after a match | R10–R12, G11 | C |
| P-15 | `GET /contracts/v1/contracts/{puuid}` | BP progress, weekly `Missions`, `MissionMetadata`. Own | P1–P3, P5 | C |
| P-16 | `GET /daily-ticket/v1/{puuid}`; `POST …/renew` with `{}` only if expired or 404 | 4 checkpoints. Own | P4 | C (shape U) |
| P-17 | `GET /restrictions/v3/penalties` | Queue bans (optional badge) | — | C |
| P-18 | `GET /mmr/v1/leaderboards/affinity/{region}/queue/competitive/season/{actId}?startIndex=0&size=510` | Not a ValBuddy feature | — | D |

### 6.3 Shared: `https://shared.{shard}.a.pvp.net`

| # | Method + path | Notes | Feature | St. |
|---|---|---|---|---|
| S-1 | `GET /content-service/v3/content` | `Seasons[]` (`Type` act/episode, `IsActive`). Or use valorant-api `/v1/seasons` | R2, P1 | C |
| S-2 | `GET /v1/config/{region}` | `Collapsed` map: `competitiveSeasonOffsetEndTime`, `match.details.delay`, `SERVICEURL_*` | act countdown | C |

### 6.4 GLZ: `https://glz-{region}-1.{shard}.a.pvp.net`

| # | Method + path | Notes | Feature | St. |
|---|---|---|---|---|
| G-1 | `GET /session/v1/sessions/{puuid}` | `loopState` MENUS/PREGAME/INGAME, `clientVersion`, `clientPlatformInfo`; 404 = game not running | R7, G1 | C |
| G-2 | `GET /pregame/v1/players/{puuid}` | `{MatchID}`; 404 = not in agent select | G1, G2 | C |
| G-3 | `GET /pregame/v1/matches/{matchId}` | `AllyTeam.Players[]`, `PhaseTimeRemainingNS`, `MapID`, `QueueID` | G3, G4 | C |
| G-4 | `POST /pregame/v1/matches/{matchId}/select/{agentId}` | Hover (tap) | G4 | C |
| G-5 | `POST /pregame/v1/matches/{matchId}/lock/{agentId}` | Lock (hold); owned agents only | G4 | C |
| G-6 | `POST /pregame/v1/matches/{matchId}/quit` | **Dodge: penalty.** Confirm first | G10 | D |
| G-7 | `GET /pregame/v1/matches/{matchId}/loadouts` | Ally skins | G8 | C |
| G-8 | `GET /core-game/v1/players/{puuid}` | `{MatchID}`; 404 = not in a match | G1, R7 | C |
| G-9 | `GET /core-game/v1/matches/{matchId}` | `Players[]` (both teams), `MapID`, `ModeID`, `MatchmakingData.QueueID`, `State` | G3, G5, G6 | C |
| G-10 | `GET /core-game/v1/matches/{matchId}/loadouts` | Everyone's skins (sockets) | G8 | C |
| G-11 | `POST /core-game/v1/players/{puuid}/disassociate/{matchId}` | **Leave a running match: penalty.** Confirm first | G10 | D |
| G-12 | `GET /parties/v1/players/{puuid}` | `CurrentPartyID`, `Requests`, `Invites` (shape U) | S1 | C |
| G-13 | `GET /parties/v1/parties/{partyId}` | `Members[]`, `State`, `Accessibility`, `MatchmakingData.QueueID`, `QueueEntryTime`, `EligibleQueues`, `QueueIneligibilities`, `InviteCode` | S1–S4 | C |
| G-14 | `POST /parties/v1/parties/{partyId}/queue` body `{"queueId":"…"}` | Change queue | S1, S4 | C |
| G-15 | `POST /parties/v1/parties/{partyId}/matchmaking/join`; `…/matchmaking/leave` | Start / cancel queue | S1 | C |
| G-16 | `POST /parties/v1/parties/{partyId}/members/{puuid}/setReady` body `{"ready":bool}` | Ready up | S1 | C |
| G-17 | `POST /parties/v1/parties/{partyId}/invites/name/{gameName}/tag/{tagLine}` | Invite (URL-encode both parts) | S3 | D |
| G-18 | `POST` / `DELETE /parties/v1/parties/{partyId}/invitecode` | Generate / disable code | S1 | D |
| G-19 | `POST /parties/v1/players/joinbycode/{code}` | Join with a code | S1 | D |
| G-20 | `POST /parties/v1/players/{puuid}/joinparty/{partyId}` | Accept an invite | S1 | U |
| G-21 | `POST /parties/v1/parties/{partyId}/request/{requestId}/decline` | Decline a request | S1 | D |
| G-22 | `DELETE /parties/v1/players/{puuid}` | Leave (own PUUID) / kick (other PUUID; owner only) | S4 | D |
| G-23 | `POST /parties/v1/parties/{partyId}/accessibility` body `{"accessibility":"OPEN"}` or `"CLOSED"` | Open / close the party | S1 (optional) | D |
| G-24 | `POST /parties/v1/parties/{partyId}/members/{puuid}/refreshCompetitiveTier` | Refresh own rank in the party | S2 | D |

### 6.5 Chat (XMPP): `{chat.affinities[affinity]}:5223`, TLS

Connection sequence:
1. Get the PAS JWT and read its `affinity` claim (e.g. `jp1`).
2. From client config take the host (`chat.affinities[affinity]`, e.g. `jp1.chat.si.riotgames.com`) and the domain (`chat.affinity_domains[affinity]`).
   - Open the stream with `to="{domain}.pvp.net"`.
   - Fallback hosts (`*.chat.si.riotgames.com`): `ap→jp1`, `eu→euw1`, `na→na2`, `kr→kr1`, `br→br`, `latam→la1`.
3. SASL `X-Riot-RSO-PAS` with `<rso_token>{access}</rso_token><pas_token>{pas}</pas_token>`, then reopen the stream.
4. Bind, then session.
5. Send entitlements: `<iq type="set"><entitlements xmlns="urn:riotgames:entitlements"><token xmlns="">{ent}</token></entitlements></iq>`.
6. Request the roster: `<iq type="get"><query xmlns="jabber:iq:riotgames:roster" last_state="true"/></iq>`.
7. Send `<presence/>`.
8. Keep-alive: write one space every ~120 s.

Other stanzas:
- History: `<query xmlns="jabber:iq:riotgames:archive"><with>{jid}</with></query>`.
- Send a message: `<message to="{puuid}@{domain}.pvp.net" type="chat"><body>…</body></message>`.

**Reconnect with fresh tokens after every re-auth.** Vshop keeps its chat store and drops only the socket. Details in EP §16.

| Data | Where |
|---|---|
| Friend list | Roster `<item jid puuid subscription><state/><last_online/><id name tagline/><platforms><riot name tagline/></platforms></item>`. Attributes U; resolve names via P-10 if missing |
| Friend activity | Presence `<games><valorant><p>{base64 JSON}</p>…</valorant></games>`, `<show>` (chat/away/dnd), `<status>`. See the JSON field list below; fall back to the old flat format |
| **Own** live score / party id | Your own presence (another resource of your JID), same JSON |

Presence JSON fields:
- `isIdle`
- `matchPresenceData.{sessionLoopState, matchMap, queueId, provisioningFlow}`
- `partyPresenceData.{partyId, partyState, partySize, maxPartySize, queueEntryTime, partyOwnerMatchScoreAllyTeam/EnemyTeam, isPartyOwner}`
- `playerPresenceData.{playerCardId, playerTitleId, accountLevel, competitiveTier}`

### 6.6 Public / third-party

| # | URL | Use |
|---|---|---|
| X-1 | `https://valorant.secure.dyn.riotcdn.net/channels/public/x/status/{region}.json` | Maintenance/incident banner **[LIVE]**. Fields: `{maintenances[], incidents[]}`, `titles[{locale:"vi_VN",content}]`, `incident_severity`, `platforms` |
| X-2 | `https://valorant-api.com/v1/...` (§7.9) | All names, images and videos |
| X-3 | `https://gist.githubusercontent.com/mistralwz/17bb10db4bb77df5530024bcb0385042/raw/nmdate.txt` | Next Night Market date (third-party, U). Optional |
| X-4 | ValVN-hosted `prices.json` (GitHub Pages / static, no user data) | B9/C8 price overrides (ValBuddy 2.1.1 does the same with its own site) |

### 6.7 Never implement

- Purchases/orders, gifts, mass-rewards.
- `name-service/v3` POST.
- Latency ingest, session connect/heartbeat.
- Contract activation.
- The username/password `PUT /api/v1/authorization`.
- Any automated (not user-initiated) mutation.

---

## 7. ID tables

### 7.1 Item types (entitlements, offers, rewards)

| ItemTypeID | Meaning | Riot `ItemID` is | valorant-api |
|---|---|---|---|
| `e7c63390-eda7-46e0-bb7a-a6abdacd2433` | Weapon skin **level** | Level uuid (store / NM / bundle = level 1) | `/v1/weapons` → `skins[].levels[].uuid` |
| `3ad1b2b2-acdb-4524-852f-954a76ddae0a` | Skin chroma | Chroma uuid | `skins[].chromas[].uuid` |
| `dd3bf334-87f3-40bd-b043-682a57a8dc3a` | Gun buddy **level** (has `InstanceID`) | Buddy level uuid | `/v1/buddies` → `levels[].uuid` |
| `d5f120f8-ff8c-4aac-92ea-f2b5acbe9475` | Spray (also an `ActiveExpressions.TypeID`) | Spray uuid | `/v1/sprays` |
| `03a572de-4234-31ed-d344-ababa488f981` | Flex / "Totem" (also an `ActiveExpressions.TypeID`) | Flex uuid | `/v1/flex` |
| `3f296c07-64c3-494c-923b-fe692a4fa1bd` | Player card | Card uuid | `/v1/playercards` |
| `de7caa6b-adf7-4588-bbd1-143831e786c6` | Player title | Title uuid | `/v1/playertitles` |
| `01bb38e1-da47-4e6a-9b3d-945fe4655707` | Agent (non-starter) | Agent uuid | `/v1/agents` |
| `f85cb6f7-33e5-4dc8-b609-ec7212301948` | Premium contract ownership (BP or event pass bought) | Contract uuid | `/v1/contracts` |
| `ea6fcd2e-8373-4137-b1c0-b458947aa86d` | Currency reward (in offers) | Currency uuid | `/v1/currencies` |
| `4e60e748-bce6-4faa-9327-ebbe6089d5fe` | Value of each entitlement row's `TypeID` (not an item type) | — | — |
| `bcef87d6-209b-46c6-8b19-fbe40bd95abc` / `77258665-71d1-4623-bc72-44db9bd5b3b3` | Loadout socket ids: skin / buddy (match loadouts) | | |

Verification: nine types are in the [DOC] Owned Items table. The Flex id is used in 8+ maintained repos (2025–2026). Others: EP Appendix A.

### 7.2 Currencies **[LIVE /v1/currencies]**

| uuid | Currency | Label in UI |
|---|---|---|
| `85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741` | VALORANT Points | VP |
| `e59aa87c-4cbf-517a-5983-6e81511be9b7` | Radianite Points | RP (tooltip "Radianite") |
| `85ca954a-41f2-ce94-9b45-8ca3dd39a00d` | Kingdom Credits ("Dough") | KC |
| `f08d4ae3-939c-4576-ab26-09ce1f23bb37` | Agent Tokens | Huy hiệu đặc vụ |

### 7.3 Content tiers

| devName | uuid | rank | vi (short) | Fallback price (VP) |
|---|---|---|---|---|
| Select | `12683d76-48d7-84a3-4e09-6985794f0445` | 0 | Tuyển Chọn | 875 (official) |
| Deluxe | `0cebb8be-46d7-c12a-d306-e9907bfc5a25` | 1 | Sang Chảnh | 1275 (official) |
| Premium | `60bca009-4182-7998-dee7-b8a2558dc369` | 2 | Cao Cấp | 1775 (official) |
| Exclusive | `e046854e-406c-37f4-6607-19a9ba8426fc` | 3 | Độc Quyền | ≈ 2175 (varies, UNVERIFIED) |
| Ultra | `411e4a55-4e59-7757-41f0-86a53f101bb5` | 4 | Siêu Cấp | ≈ 2475 (varies, UNVERIFIED) |

- Colors are `RRGGBBAA`; convert them to Flutter ARGB (CA §10.4).
- The LimitedEdition content edition is `3d190ff8-49c2-2ae5-f8b1-a3b782fb4b79`.

### 7.4 Competitive tiers

The current table is `03621f52-342b-cf4e-4f86-9350a49c6d04` (Episode5, used from E5 A1 through V26):

| Tier | Rank |
|---|---|
| 0 | Unranked |
| 1–2 | Unused (treat as unranked) |
| 3–5 | Iron |
| 6–8 | Bronze |
| 9–11 | Silver |
| 12–14 | Gold |
| 15–17 | Platinum |
| 18–20 | Diamond |
| 21–23 | Ascendant |
| 24–26 | Immortal |
| 27 | Radiant |

Older acts use other tables, and tiers 21–24 mean different ranks there. Resolve `seasonId` → `/v1/seasons/competitive` → `competitiveTiersUuid`. For an unknown act, use the newest table.

### 7.5 Queues (match history / MMR / party)

| queueId | Mode |
|---|---|
| `competitive`, `unrated`, `swiftplay`, `spikerush`, `deathmatch` | as named |
| `hurm` | Team Deathmatch |
| `ggteam` | Escalation |
| `onefa` | Replication |
| `snowball`, `valaram`, `abilitydraftarena`, `skirmish2v2`, `skirmishascension1v1/2v2`, `premier` | as named |
| `dodgeball` | Knockout |
| `fortcollins` | Retake |
| `newmap` | Re-pointed to a different map every season |
| `""` | Custom game |
| `console_*` | Console variants of the above |

Always take labels from `/v1/gamemodes/queues?language=vi-VN` (`dropdownText`). The app fallback table is in VF §8.9.

### 7.6 Special UUIDs

| What | UUID |
|---|---|
| Starter agents (always owned, never in entitlements; = `isBaseContent`) | Jett `add6443a-41bd-e414-f6ad-e58d267f4e95`, Phoenix `eb93336a-449b-9c1b-0a54-a891f7921d69`, Sova `320b2a48-4d9b-a075-30f1-1f93a9b638fa`, Brimstone `9f0d8ba9-4140-b941-57d3-a7ad57c6b417`, Sage `569fdd95-4d10-43ab-ca70-79becc718b46` |
| Melee | `2f59173c-4bed-b6c3-2191-dea9b58be9c7` |
| Vandal | `9c82e19d-4575-0200-1a81-3eacf00cf872` |
| Phantom | `ee8e8d15-496b-07ac-e5f6-8fae5d4c7b1a` |
| Warden | `8db0a1bf-4a50-832a-4566-faaaa6d250ca` |
| Bandit | `410b2e0b-4ceb-1321-1727-20858f7f3477` |
| "Standard" skin theme (filter out) | `5a629df4-4765-0214-bd40-fbb96542941f` |
| "Random favorite" skin theme (filter out) | `0d7a5bfb-4850-098e-1821-d989bbfd58a8` |
| No title | `d13e579c-435e-44d4-cec2-6eae5a3c5ed4` |
| Null spray | `d7efbdd5-4a77-f858-a133-cfb8956ca1fe` |
| Auto level border | `00000000-0000-0000-0000-000000000000` |
| Current act / episode (**compute, never hard-code**) | Act `8102cd81-43a0-d0d7-bd59-47b8fe9bed1b`, episode `3737c391-497a-6e82-aeb5-cc9f701f72e2`, next act `d816f426-48ea-f052-117f-9697a155b319` |
| Current battle pass / event pass (compute) | BP `3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9`, event pass `d70f2a95-4682-5216-984f-ddaaa14436a7` |

### 7.7 Agent roles (vi)

| Role | vi | uuid |
|---|---|---|
| Duelist | Đối đầu | `dbe8757e-9e92-4ed4-b39f-9dfc589691d4` |
| Initiator | Khởi tranh | `1b47567f-8f7b-444b-aae3-b0c634622d10` |
| Controller | Kiểm soát | `4ee40330-ecdd-4f2f-98a8-eb1243428373` |
| Sentinel | Hộ vệ | `5fc02f99-4091-4486-a531-98459a3e95e9` |

### 7.8 Error codes

| Response | Meaning |
|---|---|
| `400 BAD_CLAIMS` | Token expired or invalid |
| `404 RESOURCE_NOT_FOUND` | Not in pregame / core-game |
| `403 SCHEDULED_DOWNTIME` | Maintenance |
| `400 BAD_PARAMETER` | Page past the end |
| `400 MATCH_HISTORY_INVALID_INDICES` / `400 MMR_INVALID_INDICES` | Page wider than 20 |
| `403` with an **HTML** body "Just a moment..." | Cloudflare |
| `429` | Rate limit |

### 7.9 valorant-api endpoints the app caches (all with `?language=vi-VN`)

| Group | Endpoints |
|---|---|
| Version (no language param) | `/v1/version` |
| Weapons (primary) | `/v1/weapons` (skins + levels + chromas) |
| Store items | `/v1/bundles`, `/v1/contenttiers`, `/v1/contenteditions`, `/v1/currencies` |
| Cosmetics | `/v1/buddies`, `/v1/sprays`, `/v1/playercards`, `/v1/playertitles`, `/v1/levelborders`, `/v1/flex` |
| Game | `/v1/agents?isPlayableCharacter=true`, `/v1/maps`, `/v1/gamemodes`, `/v1/gamemodes/queues`, `/v1/gamemodes/equippables`, `/v1/gear`, `/v1/ceremonies` |
| Ranks and seasons | `/v1/competitivetiers`, `/v1/seasons`, `/v1/seasons/competitive`, `/v1/events` |
| Progression | `/v1/contracts`, `/v1/missions` |
| Optional | `/v1/themes` |

- Total ≈ 7.8 MB raw / ≈ 1.0 MB gzip.
- On a cache miss, fall back to the per-uuid endpoint (`/v1/weapons/skinlevels/{id}`, `/v1/bundles/{id}`, …).

---

## 8. Feature → data source mapping (every ValBuddy 2.1.2 feature)

Numbers refer to §6 rows. "local" = computed or stored on the device. UI details are in CA and VF.

### 8.1 Account (A)

| ID | Data | Notes |
|---|---|---|
| A1 Riot WebView sign-in | A-1, §3.2 | The password is never seen |
| A2 Google sign-in | A-1 + mobile-browser UA | U: see risk R1 |
| A3 Multi-account (10) | Per-PUUID jars, local | Switching = changing the active PUUID; data providers are families keyed by PUUID |
| A4 Account row | Local metadata + P-9 level + P-11 rank + card from P-8 | Refresh on switch |
| A5 Keep-alive / A6 safe switch / A7 auto-restore | §3.4 classification | Only `needsLogin` sends the user to login |
| A8 Console platform | Setting PC/PS/Xbox: filter P-13 by `console_*` queues and read `QueueSkills["console_competitive"]` if present | U (feature flag, default PC) |
| A9 30 s timeout + retry | Dio `receiveTimeout 30s`, error view "Thử lại" | |
| A10 Export session log | Local ring buffer (event, host path template, status, ms) + `share_plus` | No tokens or PUUIDs |
| A11 Sign-out wipes data | §3.5 | |

### 8.2 Store (B) and wishlist (W)

| ID | Data | Notes |
|---|---|---|
| B1 Daily store | P-1 `SkinsPanelLayout.SingleItemStoreOffers[]` (`Rewards[0].ItemID` = level-1 uuid, `Cost[VP]`); countdown `SingleItemOffersRemainingDurationInSeconds`; names/art/tier from `/v1/weapons` + `/v1/contenttiers` | Reset is 00:00 UTC = 07:00 VN (**[REAL-2026]** AP), but always derive it from the seconds |
| B2 Wallet | P-2 | VP · KC · RP |
| B3 Accessory store | P-1 `AccessoryStore.AccessoryStoreOffers[]`: `Offer.Rewards[0].ItemTypeID` → type label, `Cost[KC]`, `ContractID` → "Từ …"; `AccessoryStoreRemainingDurationInSeconds` | May be null |
| B4 Bundles | P-1 `FeaturedBundle.Bundles[]` (all of them, not only `Bundle`): `DataAssetID` → `/v1/bundles`, `Items[]` prices, totals, `DurationRemainingInSeconds` | Totals may be null → sum `DiscountedPrice` |
| B5 Night Market | P-1 `BonusStore` (absent = none): `Offer.Cost` = full price, `DiscountCosts` = NM price, `DiscountPercent` = **integer %**, `IsSeen`, `BonusStoreRemainingDurationInSeconds` | Flip animation is local (no endpoint) |
| B6 Segmented store | P-1 | The NM segment appears only when `BonusStore` exists |
| B7 Skin detail | `/v1/weapons` levels (`streamedVideo`, `levelItem`) and chromas (`swatch`, `fullRender`, `streamedVideo`); P-7 optional RP costs | Video URLs embed the patch branch |
| B8 Store reset notification | Local notification at `now + remaining + 60 s`, re-scheduled after each P-1 | Inexact alarm |
| B9 Correct prices | Order: ValVN `prices.json` (X-4) > prices seen in the live store (P-1) > P-5 (U) > tier fallback §7.3 | Label estimates with "≈" |
| B10 Compact cards / image cache | `cached_network_image` + a long-lived cache manager | |
| W1–W3 Wishlist per account | Local (prefs, keyed by PUUID). Store the skin **uuid** and match on any of its level uuids | |
| W2/W4 Alerts | Background task per account: §3.4 → P-1 → intersect with daily offers, NM and bundle items | Once per account per UTC day |
| W5 Deep link | Notification payload `{puuid, skinUuid, place}` | |
| W6 Sticky picks | Wishlist survives sign-out | |
| W7 Filter/sort/value | Content tiers, prices (B9) | |

### 8.3 Collection and loadout (C)

| ID | Data | Notes |
|---|---|---|
| C1/C2 Hub + equipped card | P-8 `Identity.PlayerCardID` → `/v1/playercards.wideArt` | |
| C3 Card/title/weapons/expressions/presets | P-8 GET/PUT: `Identity.PlayerCardID`, `PlayerTitleID`, `Guns[]`, `ActiveExpressions[]`, `PreferredLevelBorderID`, `HideAccountLevel`, `Incognito` | PUT from a fresh GET as a raw map, keep unknown keys, re-GET and compare `Version` |
| C4 Skins/chromas/buddies | P-3 skin levels, chromas, buddies (`InstanceID` → `CharmInstanceID`) | One buddy instance per gun |
| C5 Browse | P-3 per type + `/v1/*`: Flex, sprays, cards, titles; level borders by account level (P-9) | Starters and defaults are always owned |
| C6/C7 Sort & filters | Local (content tier `rank`, name, weapon, price) | |
| C8 Collection value | P-3 skin levels × B9 prices | Exclude reward skins |
| C9 Reward source labels | `/v1/contracts` rewards (`EquippableSkinLevel` uuid) → `relationType` Season / Agent / Event → "Phần thưởng Battle Pass / Hợp đồng đặc vụ / Vé sự kiện" | Local index |
| C10 Search | Local | |
| U6 Presets | Local per PUUID (snapshot of `Guns` / expressions / identity); apply = PUT | Riot has no preset API |
| U7 Expressions wheel | `ActiveExpressions[i] = {TypeID: spray or flex type, AssetID}` | Slot = array order |
| (hearts) | P-6 | Optional |

### 8.4 Battle Pass (P)

| ID | Data | Notes |
|---|---|---|
| P1 Pass card | P-15 `Contracts[ContractDefinitionID == currentBP]` + `/v1/contracts` chapters. Premium = P-3 `f85cb6f7` contains the BP uuid | Formulas in §9.4 |
| P2 All rewards | `/v1/contracts` `chapters[].levels[]` (premium track) and `freeRewards` (free track) | 55 levels (10 chapters + epilogue) |
| P3 Weekly missions | P-15 `Missions[]` joined with `/v1/missions` (`title`, `xpGrant`, `progressToComplete`, `objectives`). Countdown = `MissionMetadata.WeeklyRefillTime` or the mission's `ExpirationTime` | |
| P4 Daily checkpoints | P-16 `DailyRewards.Milestones[4]{Progress 0..4, BonusApplied}`, `RemainingLifetimeSeconds` | Shape U |
| P5 All completed | Local, from P3 + P4 | |

### 8.5 Profile, rank, matches (R)

| ID | Data | Notes |
|---|---|---|
| R1 Identity header | P-8 card, local Riot ID, P-9 `Progress.Level/XP` (XP / 5000) | |
| R2 Rank card | P-11 current-act entry (`CompetitiveTier`, `RankedRating`), peak over acts; act id from S-1 or `/v1/seasons` | §9.5 |
| R3 True peak | Local RR history (P-12 pages stored on device) | §9.5 |
| R4 RR per match | P-12 `RankedRatingEarned`, joined by `MatchID` | |
| R5 Daily RR | Local grouping of P-12 by device-local date | §9.6 |
| R6 Rank-Up Calculator | P-11 + recent P-12 | §9.7 |
| R7 Current game card | Poll G-1 / G-2 / G-8 (+ own presence for the score) | |
| R8/R9 Match list + filters | P-13 with a server-side `queue` filter. The map filter needs P-14 per match (cached), or P-12 `MapID` for competitive | Page 20 |
| R10–R12 Match detail | P-14 + P-10 for blank names + P-11 per player for ranks (or `players[].competitiveTier` at match time) | §9.8 |
| R13 Friends' profiles | Friend PUUID from the roster → P-11, P-12, P-13 | Any-PUUID endpoints |
| R14 Other players' stats | G-3 / G-9 PUUIDs → P-11, P-13 | Respect `Incognito` |

### 8.6 Live game (G)

| ID | Data | Notes |
|---|---|---|
| G1 Detection | Poll G-2, then G-8 (404 = no); also G-1 `loopState` | Cadence in §10 |
| G2 Auto-open | Local setting + the MENUS→PREGAME transition | |
| G3 Header | Map from G-3 / G-9 `MapID` → `/v1/maps.mapUrl`; queue from `QueueID` / `MatchmakingData.QueueID`; mode from the `ModeID` directory key | |
| G4 Agent select | G-3 (`CharacterID`, `CharacterSelectionState`); owned agents from P-3 + starters; hover = G-4 (tap), lock = G-5 (hold) | Never automate |
| G5 Rosters | G-3 `AllyTeam.Players` / G-9 `Players`; names from P-10; rank from P-11 (pregame `CompetitiveTier` is often 0) | |
| G6 Peak rank | P-11 per player (cache per match) | |
| G7 Live score | **Own XMPP presence** `partyOwnerMatchScoreAllyTeam/EnemyTeam` | Freshness U |
| G8 Everyone's skins | G-7 / G-10 sockets (§7.1) | |
| G9 Refresh ring + mode names | Local timer; `/v1/gamemodes/queues` | |
| G10 Quit match | G-6 (agent select) / G-11 (in match), behind a confirm dialog | Penalties |
| G11 Final scoreboard | P-14 after the match (retry 404s using `match.details.delay` / backoff) | |

### 8.7 Party and social (S)

| ID | Data | Notes |
|---|---|---|
| S1 Party & remote queue | G-12 → G-13; G-14, G-15, G-16, G-18, G-19, G-20, G-21 | The game must be running on PC or console |
| S2 Member ranks | G-13 `Members[].CompetitiveTier` (+ P-11 for RR) | |
| S3 One-tap invites | XMPP online friends → G-17 (needs gameName/tagLine) | |
| S4 Smart party screen | G-13 `EligibleQueues`, `QueueIneligibilities`, `State`, `QueueEntryTime`; kick = G-22 | Lock queue changes while in a match |
| S5 Friends list | XMPP roster + presence; names from P-10; avatar = `playerPresenceData.playerCardId` | |
| S6 Chat | XMPP messages + archive | UGC review risk |
| S7 Chat header | Presence + roster; profile button → R13 | |

### 8.8 App (X)

| ID | Data |
|---|---|
| X1 Settings | Local |
| X2 Clear cache | valorant-api files + image cache + match cache |
| X3 Ad privacy | Not applicable unless the app ships ads |
| X4 Offline cache | Last successful responses per PUUID, on disk |
| X5–X7 Theme / icons | Local |
| X9 Number format | `NumberFormat.decimalPattern('vi')` → `1.162.500` |

---

## 9. Derived computations

### 9.1 Countdowns

- `expiresAt = responseReceivedAt + seconds`, for every `*RemainingDurationInSeconds` and `RemainingLifetimeSeconds`.
- Refetch when any of them expires.
- Never hard-code reset hours.

### 9.2 Bundles and Night Market

- Bundle price = `TotalDiscountedCost[VP]`, or Σ `Items[].DiscountedPrice` when that is null.
- "Mua lẻ" (bought separately) = Σ `BasePrice`. Saving = the difference.
- Bundle item `DiscountPercent` is a **fraction** (1 = free).
- NM `DiscountPercent` is an **integer %**. NM price = `DiscountCosts[VP]`; original price = `Offer.Cost[VP]`.

### 9.3 Collection value

Sum, over owned skins, of the price from the B9 order. Owned = level-1 entitlement. Exclude Standard and Random themes and reward-source skins.

### 9.4 Battle pass

- Let `flat = chapters.flatMap(c => c.levels)`.
- Level = `ProgressionLevelReached` (0 if the contract is missing).
- XP needed for the next level = `flat[level].xp` (while level < 55).
- Level bar = `ProgressionTowardsNextLevel / flat[level].xp`.
- Total bar = `TotalProgressionEarned / Σ flat[].xp` (1,162,500 for 2026 passes).
- Check against screenshot SS-1 "Level 46 · 7.966 / 35.750": `flat[46].xp` = 2000 + 45×750 = 35,750 ✓.
- Current BP = the act with `startTime ≤ now < endTime` whose contract has `content.relationType == "Season"` and `relationUuid == act.uuid`. Between acts, fall back to the latest such contract.

### 9.5 Rank, peak, true peak

- Current rank = `QueueSkills.competitive.SeasonalInfoBySeasonID[currentAct]`. Missing → unranked; `CurrentSeasonGamesNeededForRating > 0` → placements.
- Peak tier = the max over acts of max(`CompetitiveTier`, keys of `WinsByTier`), mapped through each act's tier table. Compare by table + tier, not by raw number across E4/E5.
- True peak RR (R3) = the max `RankedRatingAfterUpdate` among stored P-12 rows where `TierAfterUpdate == peakTier`. It is only known for history the device has seen; label it accordingly.

### 9.6 Daily RR

Group stored P-12 rows (`queue=competitive`) by the local date of `MatchStartTime` (ms). For each day:
- net = Σ `RankedRatingEarned`;
- wins/losses from P-14 `teams[].won` when cached, otherwise from the sign of the RR (0 → draw or remake);
- start rank = the first row's `TierBefore` / `RankedRatingBefore`;
- end rank = the last row's `TierAfter` / `RankedRatingAfter`.

### 9.7 Rank-Up Calculator (targets up to Immortal 1 = tier 24)

1. `need = (targetTier - tier) * 100 - rr`. Tiers 3..24 are 100 RR each.
2. From the last ~20 competitive updates:
   - `G` = mean positive `RankedRatingEarned`;
   - `L` = mean |negative|;
   - `p` = wins / (wins + losses).
3. Current form: `E = p*G - (1-p)*L`. Matches = `ceil(need / E)` if `E > 0`, else "không ước tính được".
4. Best case = `ceil(need / G)`.
5. Table for p ∈ {45, 50, 55, 60, 65 %}, using the same G and L.

This ignores demotion shields and placements.

### 9.8 Scoreboard (per player p, from P-14)

| Stat | How |
|---|---|
| K/D/A | `stats.*` |
| ACS | `score / roundsPlayed` |
| ADR | Σ `roundResults[].playerStats[p].damage[].damage` / rounds |
| HS% | Σ headshots / Σ (head + body + leg), from the same `damage[]`. Show "–" when there is no hit data (DM, Skirmish) |
| First bloods | Minimum-`roundTime` kill per round, or `roundResults[].firstBloodPlayer` when present |
| Result | `teams[].won`. DM: your kills vs the best other player's kills. TDM: team `numPoints` |

Parsing notes:
- Weapon and armor UUIDs arrive UPPERCASE; lowercase them before lookup.
- `damageItem` `GrenadeAbility` corresponds to the agent ability slot `Grenade`.

### 9.9 Status texts

Session `loopState`:
- MENUS → "Đang ở sảnh chờ", or "Đang tìm trận · mm:ss" when party `State == "MATCHMAKING"` (timer from `QueueEntryTime`).
- PREGAME → "Đang chọn đặc vụ · {map}".
- INGAME → "Đang đấu · {map} · a – b".

Friends:
- presence `<show>away` or `isIdle` → "Vắng mặt";
- offline → "Hoạt động {relative(last_online)}".

---

## 10. Polling and caching policy

| Data | Cache TTL | Poll |
|---|---|---|
| valorant-api content | Until `manifestId` changes; also refresh every 7 days; refetch on a miss (debounced 6 h) | App start, or resume after > 6 h |
| Storefront, wallet | Storefront until its smallest remaining duration; wallet 5 min | On focus |
| Entitlements, loadout | 10 min; invalidate after a PUT | On focus |
| MMR, competitive updates | 2–5 min | On focus, and after a match ends |
| Match details | Forever (immutable); keep the last ~200 on disk | — |
| Contracts, daily ticket | 5 min | On focus |
| Session / pregame / core-game | None | Every 3–5 s while the live sheet or agent select is open; 15–30 s on Profile; never in the background |
| Party | None | Every 3–5 s on the party screen |
| Status JSON | 5 min | On focus |
| XMPP | Live socket while the app is in the foreground; reconnect after re-auth | — |

Also:
- Serialise requests per account, with at most 2–3 concurrent.
- Batch name-service lookups.
- Pause everything when the app is backgrounded (Riverpod 3 pauses invisible providers anyway).

---

## 11. Error handling

1. Parse every Riot and valorant-api body defensively:
   - make every field nullable and ignore unknown keys;
   - arrays may be `null`;
   - lowercase UUIDs; read numbers as `num`;
   - never assume a non-2xx body is JSON (Cloudflare returns HTML).
2. `400 BAD_CLAIMS` or `401` → single-flight re-auth → retry once → otherwise `needsLogin`.
3. `403` HTML, `429`, 5xx or a timeout → transient:
   - exponential backoff, honouring `Retry-After` (else 10 s → 20 s → …, capped at 10 min);
   - show cached data with "Cập nhật lúc …".
4. `403 SCHEDULED_DOWNTIME`, or active maintenance in X-1 → maintenance banner, using the vi title from `titles[locale=vi_VN]`.
5. A `404` on pregame/core-game is a state, not an error. A `404` on match-details right after a match means retry later.
6. Riverpod: `retry:` returns `null` for `NeedsLoginException` and for any 4xx (FS §9).

---

## 12. Chosen stack (snippets in FS)

Flutter **3.47.5** / Dart **3.13.4**. All of the `pubspec.yaml` below resolves together and `flutter analyze` is clean **[BUILT]**:

```yaml
environment: { sdk: ^3.13.4, flutter: ">=3.47.0" }
dependencies:
  flutter_localizations: { sdk: flutter }
  material_ui: ^1.4.0            # Flutter 3.47 Material split — import package:material_ui, not flutter/material
  cupertino_ui: ^1.1.1
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.4.3       # no codegen; set retry: on providers
  go_router: ^18.0.1             # StatefulShellRoute.indexedStack, 5 tabs
  dio: ^5.11.1
  flutter_inappwebview: 6.2.0-beta.3   # exact; stable 6.1.5 fails on AGP 9
  flutter_secure_storage: ^11.2.0
  shared_preferences: ^2.5.5
  path_provider: ^2.1.6
  cached_network_image: ^4.0.2
  flutter_cache_manager: ^3.4.5
  video_player: ^2.14.0
  fl_chart: ^1.2.0               # optional RR chart (needs MaterialUiCompatibilityBridge)
  flutter_local_notifications: ^22.3.1
  timezone: ^0.11.1
  flutter_timezone: ^5.1.0
  workmanager: ^0.10.10
  intl: ^0.20.3
  collection: ^1.19.1
  url_launcher: ^6.3.2
  package_info_plus: ^10.2.1
  xml: ^7.1.0                    # XMPP stanzas
  share_plus: ^13.3.0            # export session log
  # home_widget: ^0.10.0         # optional, not a ValBuddy feature
dev_dependencies: { flutter_test: { sdk: flutter }, flutter_lints: ^6.0.0, mocktail: ^1.0.5 }
dependency_overrides:
  flutter_inappwebview_android: 1.2.0-beta.3
  flutter_inappwebview_ios: 1.2.0-beta.3
  flutter_inappwebview_macos: 1.2.0-beta.3
  flutter_inappwebview_web: 1.2.0-beta.3
  flutter_inappwebview_windows: 0.7.0-beta.3
  flutter_inappwebview_platform_interface: 1.4.0-beta.3
```

Android:
- AGP 9.1.0, Gradle 9.3.1, KGP 2.4.0.
- compileSdk and targetSdk 36, minSdk 24, Java 17 target.
- `android.builtInKotlin=false`, core-library desugaring.
- **Explicit `INTERNET` permission.**
- Backup disabled.
- Inexact alarms only: strip the exact-alarm permissions.
- Do **not** add `permission_handler`; it forces compileSdk 37.

iOS:
- Deployment target 15.0, SwiftPM, UIScene.
- Keychain accessibility `first_unlock_this_device`.
- `BGTaskSchedulerPermittedIdentifiers` = the workmanager task id.
- `CFBundleDevelopmentRegion vi`.

Other:
- Name clash: import inappwebview with `hide AndroidOptions`.
- Fonts: Be Vietnam Pro + Anton, bundled. Bebas Neue and Teko lack Vietnamese glyphs.
- l10n: gen-l10n with `lib/l10n/app_vi.arb`; delegates `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`.
- CI: FS §19.

---

## 13. UNVERIFIED items and defensive implementation

| # | Item | Defensive implementation |
|---|---|---|
| U1 | Google/Facebook sign-in inside the WebView (UA spoof) | Remote-overridable WebView UA; allowlist the IdP hosts; on a provider error page show "Hãy đăng nhập bằng Riot ID"; feature flag `social_login_hint` |
| U2 | Which re-auth call Riot keeps (GET prompt=none vs POST authorization) | `RiotReauthClient` tries GET, then POST; both parsers unit-tested; remote flag to swap the order |
| U3 | Cookie lifetime without "Stay signed in"; idle expiry | UI hint; background re-auth every ≤ 7 days; the needsLogin state never loops |
| U4 | `store/v1/offers` availability | Call once per 24 h, app-wide, behind flag `use_offers_endpoint`. On any non-200, disable for 24 h and use the B9 price chain |
| U5 | Night Market next date (gist) | Flag `nm_next_date_source`; hide the line when absent or invalid |
| U6 | Daily ticket wrapper keys / renew semantics | Parse `DailyRewards ?? root`. Call `renew` only if GET returns 404 or `RemainingLifetimeSeconds <= 0`, at most once per day |
| U7 | Favorites response fields | Optional; ignore on failure |
| U8 | Loadout PUT validation, 13.06 Agent ID fields, `Guns` count | Raw-map round-trip; fresh GET before PUT; compare `Version` after. Treat non-200 as a rollback and show "Không thể lưu trang bị" |
| U9 | Live score via own presence (freshness, field location) | Read the nested field, then top-level. Hide it when both values are 0 or the presence is older than 2 min. Flag `live_score` |
| U10 | Roster item attributes (`last_online`, `id`) | Tolerant XML parsing; fall back to P-10 for names; omit "last online" if missing |
| U11 | Accept-invite endpoint and invite discovery | Show incoming invites only if `Invites` parses to a non-empty list. Accept via G-20 behind flag `party_accept_invite`; otherwise show "Hãy chấp nhận trong game" |
| U12 | Console accounts (headers, `console_*` MMR keys) | Default PC. The console setting only changes the queue filters and the QueueSkills key, falling back to the PC keys. Flag `console_support` |
| U13 | Patch 13.06 Performance Score / Agent Mastery / Accolades in the API | Compute ACS locally; ignore unknown fields; add later behind flags |
| U14 | Cloudflare/UA/TLS blocking of Dart clients | Remotely overridable UA constant; classify HTML 403 as transient; escape hatch `cronet_http` / `cupertino_http` |
| U15 | `name-service` batch limit and 403 semantics | Batch ≤ 50 PUUIDs. JSON 403 → one re-auth, then retry. HTML 403 → backoff |
| U16 | Whether the server masks incognito players | Always hide names/levels client-side when `Incognito` / `HideAccountLevel` is true ("Người chơi ẩn danh") |
| U17 | Rate limits / whether `Retry-After` is sent | Per-host token bucket (≈ 1 req/s steady, bursts ≤ 5); honour the header when present |
| U18 | Minimap projection, act-rank triangle algorithm | Not needed for parity; skip |
| U19 | vi-VN client strings for the new 13.06 UI | Proposed strings in VF §7.3; verify with VN players before release |
| U20 | Contract Radianite reward `amount`, BP level-skip price | Do not display amounts that are not verified |
| U21 | Social-provider popups (`onCreateWindow`) | Load in the same WebView; log (token-free) when triggered |
| U22 | pbe shard hosts | Not supported (hide PBE) |

Remote config:
- Host one static JSON (GitHub Pages) containing `{flags, webViewUserAgent, apiUserAgent, clientVersionOverride, prices}`.
- Bundle a default copy in the app.
- Never send user data.

---

## 14. Open risks (product level)

1. **ToS / account risk** from using internal endpoints and state-changing calls (loadout, agent lock, queue, quit).
   - Keep every mutation user-initiated.
   - Confirm anything with penalties; no automation.
   - Show the disclaimer on the welcome screen and in settings.
2. **Auth fragility**: hCaptcha changes, Google's embedded-browser policy, Cloudflare. Mitigated by §3.4, U1, U2 and U14.
3. **iOS background work** is best effort: BGAppRefresh maybe once a day, ~30 s budget, up to 10 accounts. Tell users. The reset notification does not depend on background work.
4. **App Store review**: chat is UGC (needs a block/report path), Riot branding, embedded login of a third party.
5. **Third-party content API** (valorant-api.com) outages, and lag after patches. Mitigated by the disk cache, bundled small tables, per-uuid fallback and placeholder UI.
6. **Beta WebView plugin** (`flutter_inappwebview` 6.2.0-beta.3), and churn from Flutter's Material split (November 2026 stable).
7. **VN-specific login** has not been tested with a real VN account (AP shard assumed). Test it first.
8. **Concurrent re-auth** across isolates can invalidate rotated cookies. Use a per-account lock.

---

## 15. Sources (this review)

- The detail docs in this folder (each has its own source list).
- KaiC5504/DailyStore (2026-09-24):
  - `docs/riot-api.md`
  - `docs/decisions.md`
  - `ios/Packages/ValorantCore/Sources/ValorantCore/RiotAPI.swift`
- GinzaTech/Vshop @ 9796ba6 (2026-09-27):
  - `services/riot/endpoints.ts`, `services/riot/account-api.ts`, `services/riot/combat-api.ts`
  - `utils/auth-session.ts`, `utils/riot-cookies.ts`, `utils/riot-auth-navigation.ts`
  - `components/LoginWebView.tsx`
  - `utils/xmpp-client.ts`, `utils/chat-service.ts`
  - `CHANGELOG.md`
- Fantsry/store-checkerval (2026-09-22):
  - `lib/features/auth/data/datasources/auth_remote_datasource.dart`
  - `lib/features/auth/presentation/login_page.dart`
  - `lib/core/network/auth_interceptor.dart`
  - `lib/core/constants/api_constants.dart`
- techchrism/valorant-api-docs: `valorant-api-types/src/endpoints/{auth,party,pregame,currentgame,store}/*.ts` and `commonTypes.ts`.
- techchrism/riot-auth-test: `readme.md`.
- giorgi-o/SkinPeek @ 67882a0: `valorant/shop.js`, `valorant/auth.js`, `valorant/battlepass.js`, `misc/util.js`, `discord/embed.js`.
- Community clients:
  - RiisDev/RadiantConnect `Network/PartyEndpoints/PartyEndpoints.cs`
  - igorwessel/valclient.js `src/group.ts`
  - sero7k/Project-A `Server/projecta/control_plane/routes/core_game.py`
  - Nakik/ValorantApp `utils.py`
  - Mathss18/lol-headless-client `xmpp.client.service.ts`
  - yugam23/Valorant-Store-Checker `src/lib/constants.ts`
- Live requests:
  - `auth.riotgames.com/authorize` (both encodings, with and without `prompt=none`)
  - `POST auth.riotgames.com/api/v1/authorization`
  - `valorant.secure.dyn.riotcdn.net/channels/public/x/status/{ap,na,eu,latam,br,kr}.json`
  - `valorant-api.com/v1/{version,currencies}`
  - the pub.dev API, for package versions
