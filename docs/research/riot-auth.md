# Riot account authentication for ValVN (Flutter)

Research date: **2026-09-28**. Target: Flutter 3.47.x on iOS and Android, cloning ValBuddy's model: sign in on Riot's own page inside a WebView, never see the password, keep up to **10** accounts (ValBuddy 2.1.0 raised the limit from 5; its privacy page still says 5), and store tokens and cookies only on the device.

> **Note (SUMMARY review, 2026-09-28):** the original file was truncated in the middle of §1.5. The rest of §1.5 and §1.6–§10 were written during the cross-doc review from the sources in §0 plus GinzaTech/Vshop `services/riot/account-api.ts` + `utils/riot-cookies.ts`, Fantsry `auth_remote_datasource.dart`, KaiC5504/DailyStore `docs/riot-api.md` (real-account checks 2026-09-23) and live `curl` probes. `docs/research/SUMMARY.md` is the authoritative digest.

Valorant client version today (live, `GET https://valorant-api.com/v1/version`):

```json
{"manifestId":"67AF51413C6922AE","branch":"release-13.06","version":"13.06.00.5435758",
 "riotClientVersion":"release-13.06-shipping-13-5435758","riotClientBuild":"111.0.0.3261.5663",
 "buildDate":"2026-09-03T00:14:05Z"}
```

## Evidence labels used in this document

| Label | Meaning |
|---|---|
| **[LIVE]** | Reproduced on 2026-09-28 with `curl` against production Riot hosts (unauthenticated or with bad credentials, since no test account was available). |
| **[DOC]** | Documented by techchrism's community docs, https://valapidocs.techchrism.me. The source repo `techchrism/valorant-api-docs` was last changed on 2024-04-19. |
| **[SRC:x]** | Seen in working open-source code: `x` = repo and date of its last commit (see §0). |
| **[UNVERIFIED]** | Inference, or behaviour that needs a real account and device to confirm. Do not rely on it until it is tested. |

---

## 0. Sources consulted (all read on 2026-09-28)

| Source | Last activity | Why it matters |
|---|---|---|
| valapidocs.techchrism.me / github.com/techchrism/valorant-api-docs (`valorant-api-types/src/endpoints/auth/*.ts`) | 2024-04-19 | Canonical community docs for Cookie Reauth, Entitlement, Player Info, Riot Geo, ClientPlatform |
| github.com/techchrism/riot-auth-test | 2024-05-04 | Measured how long cookie reauth lasts (7 days vs 21 days) |
| github.com/giorgi-o/SkinPeek (`valorant/auth.js`, `misc/util.js`) | 2025-01-18 (**archived 2025-06-04**) | Reference cookie reauth, rate-limit and Cloudflare detection, ClientPlatform builder |
| github.com/GinzaTech/Vshop (React Native/Expo, Vietnamese team) | **2026-09-27** | Current production WebView login with state/nonce, per-account cookie snapshots, silent renewal, localized `/vi-vn/opt_in/` callback |
| github.com/VShopApp/mobile (React Native) | 2025-08-01 | WebView login with `onNavigationStateChange` |
| github.com/Fantsry/store-checkerval (**Flutter**, flutter_inappwebview) | 2026-09-22 | Flutter WebView login and Dio `GET /authorize` cookie reauth with `followRedirects:false` |
| github.com/Anton7444/valorant-shop, victorxia18/valorant-shop-checker, quocbao8925/shop_checker | 2026-03 → 2026-09 | Paste-the-redirect-URL flow using `client_id=riot-client`, `prompt=login` |
| https://auth.riotgames.com/.well-known/openid-configuration | live | Supported `prompt`, `response_mode`, `ui_locales` values |
| pub.dev: flutter_inappwebview 6.1.5 / 6.2.0-beta.3 plus platform package sources | 2024-10 / 2026-02 | CookieManager behaviour on iOS and Android |
| valbuddy.app, valbuddy.app/privacy | live | The app's model: "session cookies ... stored exclusively in ... iOS Keychain / Android Keystore, scoped per account, for up to five accounts"; "login takes place in a secure in-app web view on auth.riotgames.com" |
| developer.riotgames.com/docs/valorant, riotgames.com/en/legal, riotgames.com/en/terms-of-service | live | Policy and ToS (§9) |

---

## Architecture at a glance

```
[Add account]
  clear WebView cookies ──► InAppWebView(authorize URL, ui_locales=vi, random state+nonce)
        Riot page (authenticate.riotgames.com): Riot ID / Google / Apple / Xbox / PS, hCaptcha, MFA
        ──► 303 to https://playvalorant.com/opt_in#access_token=..&id_token=..&expires_in=3600&state=..
  intercept the navigation (CANCEL), validate state and nonce, parse the tokens
  read cookies for https://auth.riotgames.com/ (ssid, tdid, clid, asid, ccid, sub, csid, ...)
  POST entitlements ──► entitlements_token
  GET  userinfo     ──► puuid (sub), game_name#tag_line, country
  PUT  riot-geo     ──► affinities.live (e.g. "ap") ──► shard ("ap")
  store {tokens, cookies, region, shard} in flutter_secure_storage under the puuid
  clear WebView cookies again (so the next account starts clean)

[Every API call]  Authorization + X-Riot-Entitlements-JWT + X-Riot-ClientPlatform + X-Riot-ClientVersion
[Token < 5 min left, or PD answers 400 BAD_CLAIMS / 401]
  single-flight per account: GET https://auth.riotgames.com/authorize?...&prompt=none  (Cookie: stored jar, no redirects)
     3xx Location = playvalorant.com/opt_in#access_token=...                 → new tokens; merge Set-Cookie into jar
     3xx Location = ...#error=interaction_required / authenticate.riotgames.com/login → session dead: mark "needs login"
     403 Cloudflare / 429                                                      → transient: back off, keep the session
```

---

## 1. WebView login flow

### 1.1 Authorize URL

Base: `https://auth.riotgames.com/authorize`

| Param | Value | Notes |
|---|---|---|
| `client_id` | `play-valorant-web-prod` | [DOC][SRC: all repos]. [LIVE] the server echoes `x-riot-clientid: play-valorant-web-prod`. |
| `redirect_uri` | `https://playvalorant.com/opt_in` | Must match exactly what is registered for this client. [UNVERIFIED] whether other URIs are rejected; do not change it. |
| `response_type` | `token id_token` (encode the space as `%20`) | Implicit or hybrid; tokens come back in the URL **fragment**. [LIVE] the OIDC config lists `id_token token` as supported. |
| `scope` | `account openid` | [DOC] the current doc includes `account`. [SRC] SkinPeek, VShop and Fantsry all use it. |
| `nonce` | random value (for example 32 random bytes as hex) | Required. Any string is accepted: [SRC] SkinPeek used `1` and `69420`; [LIVE] `abc123` was accepted and echoed into the login URL. It comes back in the `id_token` `nonce` claim, so validate it (GinzaTech does). |
| `state` | random value (32 bytes as hex) | [LIVE] Echoed back in the callback fragment (seen in the error callback). [SRC:GinzaTech 2026] validates `state` on success. |
| `ui_locales` | `vi` | [LIVE] Turns the Riot login page Vietnamese: the redirect contains `locale=vi-VN`. The `Accept-Language` header alone did **not** change the locale (it stayed `en-US`). Supported: `en, cs, de, el, es, es-419, fr, hu, it, ms, pl, pt-BR, ro, ru, tr, ja, ko, id, th, vi, zh-Hans, zh-Hant, ar`. |
| `prompt` | *(omit)* for normal login | Supported: `login, create, consent, none, select_account` [LIVE, openid-configuration]. With `prompt=login`, the server added `security_profile=low` to the login redirect [LIVE]; its effect is unknown, so avoid it and clear cookies instead (§2.1, §2.3). `prompt=none` is for silent reauth (§3.2). |

Example (valid today):

```
https://auth.riotgames.com/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in&client_id=play-valorant-web-prod&response_type=token%20id_token&scope=account%20openid&nonce=<64-hex>&state=<64-hex>&ui_locales=vi
```

Dart's `Uri(queryParameters: …)` encodes spaces as `+`. VShop's JS `URLSearchParams` also sends `+` and works in production [SRC:GinzaTech], but building the query by hand with `%20` matches the documented URL exactly. That is what the code below does.

### 1.2 Redirect chain as observed [LIVE, 2026-09-28]

1. `GET https://auth.riotgames.com/authorize?...` returns **303**:
   `Location: https://authenticate.riotgames.com/login?client_id=play-valorant-web-prod&nonce=…&redirect_uri=https%3A%2F%2Fauth.riotgames.com%2Fauthorize%3F…&response_type=token%20id_token&scope=account%20openid&state=…&locale=vi-VN&method=riot_identity`
   It also sets `asid` (HttpOnly, SameSite=Strict), `ccid=play-valorant-web-prod`, `clid=uw1` and `__cf_bm` (Domain=riotgames.com, 30 min). `server: cloudflare`, `x-rsorouterclusterid: uw1`.
2. `GET authenticate.riotgames.com/login?...` returns **302** to `/?client_id=…&method=riot_identity&platform=web&redirect_uri=…`. It sets `authenticator.sid` (Max-Age=1200), `tdid` (**Domain=riotgames.com, Max-Age=31536000**, HttpOnly) and `__cflb`.
3. `200` serves the SPA `https://lolstatic-a.akamaihd.net/rso-authenticator-ui/0.127.4/rso-authenticator-ui.js`. Its CSP allows `hcaptcha.com` and `*.hcaptcha.com`. The bundle calls `/api/v1/login`, `/api/v1/configuration`, `/api/v1/handoff/verify` and `/api/v1/tos`, and contains the Google, Apple, Facebook, Xbox and PlayStation identity providers plus MFA and hCaptcha flows. **All of this runs inside the WebView; the app never touches it.**
4. After a successful login, the SPA sends the browser back to `auth.riotgames.com/authorize?...`, which sets the SSO cookies (`ssid`, …) and returns **303** to:
   ```
   https://playvalorant.com/opt_in#access_token={JWT}&scope=openid&iss=https%3A%2F%2Fauth.riotgames.com&id_token={JWT}&token_type=Bearer&session_state={...}&expires_in=3600
   ```
   This is the [DOC] format. The `state` param is appended when you send one [LIVE for the error case, SRC for success].
5. If the WebView keeps going: `https://playvalorant.com/opt_in` returns **307** to `/{locale}/opt_in` [LIVE: `/en-us/opt_in`]. VShop saw **`/vi-vn/opt_in/`** on Android after a real sign-in [SRC:GinzaTech CHANGELOG]. Browsers carry the fragment through the 307, so the tokens also appear on the localized URL.

### 1.3 Detecting completion

Treat a URL as the callback when **all** of these hold:

- scheme is `https`, and host is `playvalorant.com` (also accept `www.playvalorant.com`);
- path matches `^/(?:[a-z]{2}-[a-z]{2}/)?opt_in/?$` (case-insensitive), which covers `/opt_in`, `/opt_in/`, `/vi-vn/opt_in/` and `/en-us/opt_in`;
- the fragment (or, as a fallback, the query) contains `access_token` **or** `error`.

Hook the check into three `flutter_inappwebview` callbacks, as the working Flutter app does [SRC:Fantsry 2026]:

1. `shouldOverrideUrlLoading` (needs `useShouldOverrideUrlLoading: true`). Return `NavigationActionPolicy.CANCEL` on a match so playvalorant.com never loads. This also saves bandwidth and avoids its cookie banner.
2. `onLoadStart` and `onUpdateVisitedHistory`, as fallbacks. For example, a server redirect may not reach `shouldOverrideUrlLoading` on some iOS or Android WebView versions [UNVERIFIED which ones].
3. Ignore `onReceivedError` and `onReceivedHttpError` for the callback URL, because the cancelled navigation can surface as an error.

Guard with a `_completed` flag so the handler runs only once.

Also restrict **main-frame** navigation to trusted hosts: `*.riotgames.com`, `playvalorant.com`, the social identity providers (`accounts.google.com`, `appleid.apple.com`, `login.live.com`, `*.playstation.com`, `*.facebook.com`), `*.hcaptcha.com` and `lolstatic` hosts. Open anything else (for example the "Forgot password" help center) with `url_launcher`. Allow sub-frame navigation (hCaptcha iframes); use `navigationAction.isForMainFrame`.

### 1.4 Parsing the fragment and validating it

Fragment keys: `access_token`, `id_token`, `token_type` (`Bearer`), `expires_in` (seconds, `3600`), `scope`, `iss`, `session_state`, `state`. On error you get `error`, `error_description` and `iss` instead [LIVE].

Validation, following GinzaTech's `validateInteractiveAuthCallback`:

- `state` equals the value you generated.
- Each of `access_token`, `id_token` and `state` appears exactly once and is non-empty.
- There is no `error` param.
- The `nonce` claim of the `id_token` equals your nonce. This correlates the callback with your request; it is **not** a signature check. The signing keys are at `https://auth.riotgames.com/jwks.json` (kid `rso-prod-2024-11` on the day of research) if you want full verification.
- The `sub` claim of the access token is the PUUID. When re-logging an existing saved account, check it equals that account's PUUID; if not, the user signed into a different account.

### 1.5 hCaptcha, MFA, "stay signed in", social login

- **hCaptcha** is rendered by Riot's page. It needs JavaScript, DOM storage and, on Android, third-party cookies (`thirdPartyCookiesEnabled: true`, which is the default in inappwebview). Never automate it.
- **MFA**: email OTP, authenticator app, and "approve in Riot Mobile" are all screens of Riot's SPA and complete inside the WebView; the app only sees the final callback. [SRC:Fantsry 2026] notes that after an approval on Riot Mobile the pending `/authorize` redirects straight to the callback. Never try to answer MFA from native code.
- **"Stay signed in"** (checkbox `#rememberme` in `rso-authenticator-ui`; the bundle also has an `auth_remember_me` constant [LIVE bundle 0.127.4]). With it ticked Riot issues long-lived SSO cookies; DailyStore (iOS, real account, 2026-09-23) tells its users to tick it. Show a hint above the WebView ("Hãy tick *Duy trì đăng nhập* để không phải đăng nhập lại") instead of scripting the checkbox. Effect of leaving it unticked on `ssid` lifetime: [UNVERIFIED].
- **Social login (Google, Apple, Facebook, Xbox, PlayStation).** The Riot SPA navigates the main frame (`window.location.href = …`) to the provider and back. Google refuses OAuth inside embedded WebViews that it can detect (`disallowed_useragent`, detection is by User-Agent). Both 2026 open-source apps that ship WebView login set a plain mobile-browser UA on the WebView: Fantsry (Flutter, `InAppWebViewSettings.userAgent = "Mozilla/5.0 (Linux; Android 13; Mobile) … Chrome/120 … Mobile Safari/537.36"`) and GinzaTech/Vshop (RN, Android Chrome UA on both platforms). ValBuddy advertises Google sign-in since 1.2.0, so it must do something equivalent [UNVERIFIED how]. Recommendation: set a platform-matching mobile Safari/Chrome UA (see `flutter-stack.md` §6), allow main-frame navigation to the provider hosts (§1.3), and if a provider still fails show "Đăng nhập Google không khả dụng trong ứng dụng, hãy dùng Riot ID" rather than an endless spinner. Whether spoofing the UA violates Google's policy: treat as a product risk (§10).
- **Popups.** If a provider opens a window (`window.open`/`target=_blank`), inappwebview calls `onCreateWindow`; load `createWindowAction.request.url` in the same WebView and return `false` [UNVERIFIED which providers need it]. Keep `supportMultipleWindows: false` (the default), as Fantsry does.

### 1.6 Reading the cookies after the callback

- Read with `CookieManager.instance().getCookies(url: WebUri('https://auth.riotgames.com/'))`. That returns what a browser would send to `/authorize`: host cookies (`ssid`, `clid`, `csid`, `sub`, `asid`, `ccid`, …) **and** parent-domain cookies (`tdid`, `__cf_bm` on `.riotgames.com`). Fantsry additionally reads `https://riotgames.com` and `https://playvalorant.com`; not needed for re-auth.
- Minimum set that must be present: `ssid` (the SSO session). Community apps treat `ssid, clid, csid, tdid` (yugam23/Valorant-Store-Checker `ESSENTIAL_COOKIE_NAMES`) or `ssid, clid, csid, tdid, asid` (DailyStore) as the essential set. **Store every cookie returned**, not just these; unknown ones are harmless and Riot may add new ones.
- iOS: `WKHTTPCookieStore` can lag the navigation event; wait ~300 ms and retry once if `ssid` is missing [UNVERIFIED timing, widely reported]. Android: without the `GET_COOKIE_INFO` WebView feature only `name=value` pairs come back, which is all the re-auth needs.
- If `ssid` is still missing, the login cannot be renewed later: keep the tokens for this hour, but mark the account "needs login on expiry" and log a (token-free) session event.

---

## 2. Multiple accounts and cookie isolation

### 2.1 Rules

1. **Before** every "add account" / "re-login": `CookieManager.instance().deleteAllCookies()` (and on iOS also `WebStorageManager` data for `riotgames.com` if a stale SPA state appears [UNVERIFIED need]). Otherwise Riot's SSO silently logs the WebView into the previous account.
2. **After** capturing the cookies: delete them from the WebView store again. The app's own per-account jar (secure storage) is the only source of truth; nothing is shared between accounts.
3. Each account = one jar `{name: value}` keyed by PUUID (§5). Silent re-auth sends that jar in a `Cookie:` header from Dio; the WebView store is never used for re-auth, so switching accounts is just "use another jar".
4. When re-logging a saved account, compare the new access token `sub` with the saved PUUID. If they differ, the user signed into another Riot account: ask whether to add it as a new account instead of overwriting (GinzaTech/Vshop binds every renewal to the expected PUUID for the same reason).
5. Limit: 10 accounts (ValBuddy 2.1.0). Adding the 11th shows "Đã đạt tối đa 10 tài khoản".

### 2.2 Why not a fresh cookie store per WebView

- iOS `incognito: true` gives a non-persistent `WKWebsiteDataStore`, but inappwebview's `CookieManager` reads `WKWebsiteDataStore.default()`, so the cookies would be invisible (see `flutter-stack.md` §6). Native Swift apps can read a non-persistent store directly (DailyStore does), Flutter cannot without a custom plugin.
- Android has one process-wide `CookieManager`; separate stores need `ProfileStore` (WebView 118+ `MULTI_PROFILE`), which inappwebview 6.2 beta does not expose [UNVERIFIED]. Clearing before and after is simpler and works on both platforms.

### 2.3 `prompt=login` and `select_account`

`prompt=login` forces the password screen but adds `security_profile=low` to the login redirect [LIVE], with unknown effect; `select_account` is listed by the OIDC config but its behaviour on Riot's SPA is [UNVERIFIED]. Use cookie clearing (2.1) instead of either.

---

## 3. Tokens: bootstrap and silent re-authentication

### 3.1 After the WebView callback (and after every re-auth)

| # | Request | Result | Notes |
|---|---|---|---|
| 1 | parse fragment | `access_token` (JWT, `exp` = now + 3600 s), `id_token`, `expires_in` | PUUID = access-token `sub` (base64url-decode the payload; no signature check needed for this) |
| 2 | `POST https://entitlements.auth.riotgames.com/api/token/v1`, headers `Authorization: Bearer {access}`, `Content-Type: application/json`, body `{}` | `{"entitlements_token":"eyJ…"}` | [DOC][SRC: SkinPeek, Vshop, Fantsry, DailyStore 2026-09-23]. Re-fetch after every re-auth |
| 3 | `GET https://auth.riotgames.com/userinfo` (Bearer) | `sub`, `acct.game_name`, `acct.tag_line`, `country`, `affinity` … | [DOC]. Only needed once per login (and to refresh a changed Riot ID) |
| 4 | `PUT https://riot-geo.pas.si.riotgames.com/pas/v1/product/valorant` (Bearer), body `{"id_token":"{id}"}` | `{"token":…,"affinities":{"pbe":"na","live":"ap"}}` | [DOC]. `region = affinities.live`; `shard = {na,latam,br→na; eu→eu; ap→ap; kr→kr}`. Cache per account; re-check occasionally (region transfers) |
| 5 | `GET https://valorant-api.com/v1/version` | `riotClientVersion`, `riotClientBuild` | for `X-Riot-ClientVersion` and the User-Agent (§3.6) |

Persist: cookie jar (rotated), tokens + expiry (optional, they are 1 h), PUUID, Riot ID, region, shard.

### 3.2 Silent re-auth, primary: `GET /authorize?prompt=none` with the cookie jar

```
GET https://auth.riotgames.com/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in&client_id=play-valorant-web-prod&response_type=token%20id_token&scope=account%20openid&nonce=1&prompt=none
Cookie: ssid=…; clid=…; csid=…; tdid=…; asid=…; …        (the account's jar)
User-Agent: RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)
(no redirect following)
```

| Response | Meaning | Action |
|---|---|---|
| `303`, `Location: https://playvalorant.com/opt_in#access_token=…&id_token=…&expires_in=3600` | OK | parse tokens, **merge every `Set-Cookie` into the jar and persist it before anything else**, then redo §3.1 steps 2 (and 4 if region unknown) |
| `303`, `Location: …#error=interaction_required&error_description=login_required` [LIVE] | session dead | mark account "needs login"; do **not** retry |
| `303`/`302` to `https://authenticate.riotgames.com/login?…` (absolute URL) [LIVE, when `prompt` is omitted] | session dead | same |
| `403` with HTML (`Just a moment...`), `429`, timeouts, 5xx | transient (Cloudflare, rate limit, network) | keep the session, back off (30 s → 10 min, honour `Retry-After` if present), try the fallback (3.3) once |
| anything else without `access_token` | unknown | treat as transient once, then as dead after 3 consecutive failures |

Notes:
- `prompt=none` is a standard OIDC value listed by Riot's openid-configuration [LIVE]; SkinPeek and Fantsry omit it and detect the login redirect instead. Both work; `prompt=none` gives a clean machine-readable error.
- `response_type=token%20id_token` and `token+id_token` are both accepted [LIVE 2026-09-28].
- SkinPeek's check `location.startsWith("/login")` is **stale**: today's dead-session `Location` is absolute. Test for `access_token` / `error` instead.
- techchrism's 2023 measurement (riot-auth-test): ~7–9 % of re-auths failed sporadically and passed on the next try, so allow one immediate retry before declaring anything.

### 3.3 Silent re-auth, fallback: `POST /api/v1/authorization` with cookies

```
POST https://auth.riotgames.com/api/v1/authorization
Content-Type: application/json
Cookie: <jar>
User-Agent: RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)
{"client_id":"play-valorant-web-prod","nonce":"1","redirect_uri":"https://playvalorant.com/opt_in","response_type":"token id_token","scope":"account openid"}
```

- Dead session → `200 {"type":"auth","country":"…"}` [LIVE 2026-09-28, no cookies].
- Valid session → `{"type":"response","response":{"parameters":{"uri":"https://playvalorant.com/opt_in#access_token=…"}}}` [SRC: GinzaTech/Vshop 2026-09-27 uses this as its *only* renewal and reports live Android verification; Fantsry 2026 uses it as the fallback after GET]. `{"type":"multifactor"}` also means "needs interactive login".
- This is the same URL whose **`PUT`** (username/password) is dead behind hCaptcha; the cookie-only `POST` is a different call and still works.

### 3.4 Cookie lifetime and rotation

- Each successful re-auth rotates `ssid`, `clid`, `csid` with `Max-Age` 30 days; `tdid` (1 year) and `asid` do not rotate (DailyStore, real account, 2026-09-23). So the session **slides**: as long as the app re-auths at least every few weeks and saves the rotated cookies, the user stays signed in ("weeks rather than days" in ValBuddy 2.0.3).
- techchrism (2023): replaying the *original* cookies or only `ssid` died after ~7 days; storing the refreshed full set lasted 21 days (end of test). ⇒ always persist the whole rotated jar.
- Keep the **previous** jar as a fallback and retry once with it if the new one is rejected (covers a crash between receiving and saving; DailyStore does this).
- Refresh proactively: when the access token has < 5 min left (Vshop uses 90 s–5 min), on `401` from auth hosts and on `400 {"errorCode":"BAD_CLAIMS"}` from PD/GLZ. Single-flight per account (one in-flight re-auth shared by all callers).
- Keep dormant accounts alive: the background task (§7) should re-auth every saved account at least once every ~7 days even if the user never opens it [recommendation; exact server-side idle limit UNVERIFIED].

### 3.5 Error classification (what ValBuddy 2.0.3 calls "only Riot actually asking for your password signs you out")

| Class | Signals | UI |
|---|---|---|
| `needsLogin` | §3.2 dead-session rows; `type` = `auth` or `multifactor` from §3.3; PUUID mismatch (§2.1.4) | account row shows "Cần đăng nhập lại"; data screens show cached data + banner; background checks skip the account and send one "Cần đăng nhập lại" notification |
| `transient` | network errors, timeouts (30 s, ValBuddy 2.1.0), 403 HTML, 429, 5xx | keep session, show cached data with "Cập nhật lúc …", retry with backoff |
| `maintenance` | PD `403 {"errorCode":"SCHEDULED_DOWNTIME"}` or public status JSON (see `riot-endpoints.md` §4) | maintenance banner |

### 3.6 User-Agent and TLS fingerprint

- Send a Riot-client-looking UA on auth and game-server calls: `RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)` (SkinPeek builds it from the live client build; Fantsry hard-codes `RiotClient/43.0.1.4195386.4190634 rso-auth (Windows; 10;;Enterprise; x64)`; DailyStore uses `RiotGamesApi/24.11.0.4602 rso-auth (Windows;10;;Professional, x64) riot_client/0` and notes that Riot has blocked apps by UA before). Put it in one constant that a remote config can override.
- Dart's `HttpClient` TLS fingerprint differs from a browser's; Vshop pins a TLS 1.2+/ChaCha20/AES-GCM cipher list for the same reason. No 2026 report of Riot blocking by JA3 was found [UNVERIFIED]. If Cloudflare starts answering 403 to Dart, a native HTTP stack (`cronet_http` / `cupertino_http` behind `package:http`) is the escape hatch.

---

## 4. Headers for game-server calls (summary)

`Authorization: Bearer {access_token}`, `X-Riot-Entitlements-JWT: {entitlements_token}`, `X-Riot-ClientVersion: {riotClientVersion}`, `X-Riot-ClientPlatform: {base64 PC platform JSON}`, `User-Agent` (§3.6), `Content-Type: application/json` on bodies. Full table and hosts in `riot-endpoints.md` §1–2 and `SUMMARY.md`.

---

## 5. On-device storage

| Data | Where | Why |
|---|---|---|
| Cookie jar per account (`acct.{puuid}.cookies`), previous jar (`acct.{puuid}.cookies.prev`) | `flutter_secure_storage` (Keychain `first_unlock_this_device` / Android Keystore AES-GCM) | secrets; readable by background tasks while the phone is locked |
| Access / id / entitlements tokens + expiry | secure storage (optional; can always be rebuilt) or memory | 1 h lifetime |
| PUUID, Riot ID, region, shard, avatar card id, last-known rank | `shared_preferences` | not secret; lets the account list render without touching the keystore |

- Never log tokens, cookies or PUUIDs (CLAUDE.md); the session log (ValBuddy "Export Session Log") records only event names, HTTP status codes and timings.
- iOS Keychain survives uninstall: on first launch after install (no prefs flag), wipe the app's keychain items.
- Android: disable auto-backup (keystore-wrapped data cannot be restored on another device); see `flutter-stack.md` §4.4.
- ValBuddy 1.1.1 changelog: "cookies wrongly stored in Keychain" broke multi-account; i.e. scope every secure key by PUUID.

---

## 6. Sign-out / remove account

1. Delete the account's jar, tokens and cached data (ValBuddy A11). Keep its wishlist only if the product wants "sticky picks" (ValBuddy W6 keeps wishlists across sign-out/re-add).
2. There is no documented token-revocation call for this client; clearing local state is the sign-out [UNVERIFIED whether `https://auth.riotgames.com/logout` with the jar invalidates `ssid`; not needed].
3. Cancel that account's scheduled notifications and background work entries.

---

## 7. Background tasks (wishlist check, store-reset notification)

- The background isolate has no Riverpod scope: use the plain `SecureVault` + `RiotReauthClient` classes (see `flutter-stack.md` §13).
- Per account: read jar → §3.2 re-auth → persist rotated jar → entitlements → storefront → notify → done. Serialise accounts (one at a time), stop early when the OS budget (~30 s on iOS) is nearly spent, and remember the last successful day per account.
- A `needsLogin` result in the background must never loop; notify once and skip that account until the user logs in again.
- If the foreground app and the background task could re-auth the same account at the same time, the rotated cookies from one call can invalidate the other: guard with a per-account lock file / prefs timestamp (Vshop: "Serialized Riot cookie operations and shared concurrent token renewals across startup, foreground recovery and wishlist checks").

---

## 8. Vietnam specifics

- VN accounts are normal Riot accounts on the AP shard (`affinities.live = "ap"`, PD `pd.ap.a.pvp.net`, GLZ `glz-ap-1.ap.a.pvp.net`). No VN-specific login flow was found (GinzaTech/Vshop, a Vietnamese team, uses the standard flow); still **test with a real VN account early**.
- `ui_locales=vi` makes Riot's login page Vietnamese [LIVE]. The post-login redirect may pass through `/vi-vn/opt_in/` [SRC:GinzaTech]; the §1.3 regex accepts it.
- Common VN login methods include Google and Facebook; see the social-login risk in §1.5 / §10.

---

## 9. Policy and terms

- These are internal game-client endpoints, not the official Riot Developer API (which needs an approved production key and has no store/loadout/live-game data). Riot does not document or support them; community apps (SkinPeek, VShop, ValBuddy, DailyStore) have used them for years, but Riot can change or block them at any time.
- Show the Riot "Legal Jibber Jabber" disclaimer (Vietnamese text in `valbuddy-features.md` §8.13) and do not use Riot or ValBuddy branding as the app's own.
- State-changing calls (loadout PUT, agent select/lock, party/queue actions, quit) must always be user-initiated with clear confirmation for anything with penalties; no automation (instalock loops, auto-accept) [recommendation; Riot's stance on third-party instalock is UNVERIFIED].
- The password never touches the app; only Riot's page sees it. Tokens/cookies stay on device (ValBuddy's privacy model).

---

## 10. Open risks and UNVERIFIED items

1. **Google sign-in in a WebView** relies on a spoofed mobile-browser UA; Google can tighten detection at any time. Mitigation: remote-configurable UA, clear fallback message, Riot ID login always available.
2. **Cookie lifetime without "Stay signed in"** and the server-side idle limit are unmeasured; test with real accounts over 2–4 weeks.
3. **Cloudflare / UA / TLS blocking** of non-browser clients on `auth.riotgames.com` and PD hosts (seen as HTML 403 in `[LOG26]` for the real client too). Mitigation: classify as transient, back off, UA constant, native HTTP stack as escape hatch.
4. **Which of GET `/authorize` vs POST `/api/v1/authorization` Riot keeps** — implement both (§3.2/§3.3) behind one interface.
5. **Concurrent re-auth** (foreground + background) invalidating rotated cookies — per-account lock + previous-jar fallback.
6. iOS `WKHTTPCookieStore` propagation delay; Android WebView builds without `GET_COOKIE_INFO`.
7. Popup-based social providers (`onCreateWindow`) and Apple/Xbox/PlayStation flows inside the WebView are untested.
8. Legal/ToS exposure of using internal endpoints (§9).
