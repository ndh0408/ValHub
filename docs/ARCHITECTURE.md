# ValVN architecture and internal API

This is the contract between the **foundation** (`lib/core/`, `lib/app/`) and the
**feature agents** (`lib/features/<name>/`). Everything listed here exists in the code
today; if you need something that is not here, ask the lead instead of editing
`lib/core/` or another feature's folder.

Research references: `docs/research/SUMMARY.md` (authoritative), `riot-endpoints.md` (EP),
`content-api.md` (CA), `valbuddy-features.md` (VF: screen map §6, glossary §8),
`flutter-stack.md` (FS).

---

## 1. Folder layout

```
lib/
├─ main.dart                 bootstrap: locale, tz, prefs, keychain wipe after reinstall,
│                            remote config, session log, notifications, workmanager, ProviderScope(retry: riotRetry)
├─ app/
│  ├─ app.dart               ValVnApp: MaterialApp.router (material_ui), themes, vi locale,
│  │                         notification deep links, resume hooks
│  ├─ router.dart            routerProvider, appRedirect(), buildAppRoutes(), createAppRouter()
│  ├─ shell.dart             AppTab (5 tabs), AppShell: FloatingNavBar + LiveGameOverlayHost + StoreResetReminderHost
│  └─ deep_links.dart        parseDeepLink(), planLinkNavigation(), openAppLink() for notification payloads
├─ core/
│  ├─ accounts/              Account model, AccountRepository, providers, AccountChip / switcher sheet
│  ├─ auth/                  WebView login, callback validation, cookie jar, re-auth, SessionManager
│  ├─ background/            workmanager dispatcher, BackgroundContext, session keep-alive
│  ├─ config/                constants, remote config, client version (/v1/version)
│  ├─ content/               valorant-api.com repository + typed models + ContentDb
│  ├─ l10n/                  shared Vietnamese strings, vi locale setup
│  ├─ logging/               SessionLog (scrubbed ring buffer, exportable)
│  ├─ network/               RiotException, error classification, dio factory/interceptors, limiter, retry policy
│  ├─ notifications/         NotificationService (local notifications, tz)
│  ├─ riot/                  PvpApi (every game-client endpoint), hosts, ids, platform status (X-1)
│  ├─ settings/              AppSettings shared by several features
│  ├─ storage/               Prefs, SecureStore, JsonFileCache
│  ├─ theme/                 dark/light Material 3 themes, colors, tier color parsing, themeModeProvider
│  ├─ ui/                    shared widgets (AsyncValueView, ErrorView, Skeleton, CountdownText, …)
│  ├─ util/                  json.dart, format.dart, clock.dart, countdown.dart
│  └─ wishlist/              per-account wishlist storage (shared contract)
└─ features/
   ├─ home/                              TAB 0 Trang chủ (bảng điều khiển thông minh, 8 thẻ; docs/design/HOME.md)
   ├─ store/          (+ skin_detail/)   TAB 1 Cửa hàng (+ StoreResetReminderHost luôn được dựng trong shell)
   ├─ community/                         TAB 2 Cộng đồng (feed, LFG, skin votes + reviews; docs/community-api.md)
   ├─ collection/                        TAB 3 Bộ sưu tập
   ├─ wishlist/                          Wishlist + catalog + background check
   ├─ profile/                           TAB 4 Hồ sơ, match detail, player profile; có hàng Battle Pass và nút ⚙
   ├─ battlepass/                        không phải tab: route /battlepass* nằm trong nhánh Hồ sơ
   ├─ live_game/                         global "Chi tiết trận" sheet, overlay host, current-game card
   ├─ social/                            party & remote queue, friends, chat (XMPP)
   └─ settings/                          không phải tab: route /settings* nằm trong nhánh Hồ sơ (nút ⚙); welcome, session log, about, notification priming
test/                         mirrors lib/ (test/core/…, test/app/…, test/features/<f>/…)
test/fixtures/content/        trimmed real valorant-api vi-VN responses
test/helpers/                 createTestPrefs(), fakeJwt(), loadContentFixtures()
assets/config/remote_config.json   bundled remote-config defaults
assets/fonts/                 Be Vietnam Pro (400/500/600/700) + Anton, OFL.txt
```

Every feature folder follows `data/` (parsing, repositories), `providers/`, `ui/`,
`<f>_strings.dart`, `<f>_routes.dart` (when it has routes).

## 2. Ownership map

| Owner | Folder | Screens (VF §6) |
|---|---|---|
| Foundation (lead) | `lib/core/`, `lib/app/`, `lib/main.dart`, platform files, `pubspec.yaml` | S02 login (`LoginScreen`), S05 account switcher |
| Store agent | `lib/features/store/`, `lib/features/skin_detail/` | S10–S16 |
| Wishlist agent | `lib/features/wishlist/` | S3A, S3B, W2/W4 background check |
| Battle Pass agent | `lib/features/battlepass/` | S20, S21 |
| Collection agent | `lib/features/collection/` | S30–S39 |
| Profile agent | `lib/features/profile/` | S40–S44 |
| Live-game agent | `lib/features/live_game/` | S50, S51, R7 card, overlay |
| Home agent | `lib/features/home/` | Trang chủ (8 thẻ, tùy chỉnh) |
| Social agent | `lib/features/social/` | S55, S60, S61 |
| Settings agent | `lib/features/settings/` | S01, S04, S70–S72 |

Home imports these symbols of other features **read-only** (their signatures are frozen): the
providers and pure helpers listed in `docs/design/HOME.md` §3.6 (`liveGameProvider`,
`storefrontProvider`, `walletProvider`, `wishlistHitsProvider`, `rankSummaryProvider`,
`rrHistoryProvider`, `rankUpEstimateProvider`, `battlePassOverviewProvider`,
`dailyTicketProvider`, `friendsProvider`, `platformStatusProvider`, `accountActivityProvider`,
`savedStorefrontProvider`, `matchingLfgPreviewProvider`, `trendingSkinsProvider`, the `*Routes`
helpers…). Small additions that Home introduced in other features:
`SettingsGearButton` (`features/settings/ui/settings_gear_button.dart`),
`BattlePassProgressSubtitle` (`features/battlepass/ui/battlepass_entry.dart`),
`StoreResetReminderHost` (`features/store/store_reset_reminder_host.dart`),
`savedStorefrontProvider` / `storefrontSellsSkin` (moved to `core/domain/economy/saved_storefront.dart`),
`dailyRrOn` (moved to `core/domain/competitive/rank_calc.dart`), `TabPageScaffold(controller:)`,
`FloatingNavBar(emphasizedIndex:)` and a static `SkeletonShimmer` under "reduce motion".

Rules:

- Edit only your folder (and `test/features/<f>/`). Other features' public entry points
  (the `*_routes.dart` locations, `showSkinDetailSheet`, `showLiveGameSheet`,
  `CurrentGameCard`, `showPlayerLoadoutSheet`, `showNotificationPrimingSheet`) may be
  **imported**; their signatures are frozen.
- Keep the stub class names and constructor parameters; you may add optional
  parameters.
- Need a dependency, asset, platform change or a core API? Ask the lead.

## 3. Conventions

- **Imports:** `package:material_ui/material_ui.dart` (never `flutter/material.dart`),
  `package:flutter_riverpod/flutter_riverpod.dart`, `package:go_router/go_router.dart`.
  `flutter_inappwebview` must be imported with `hide AndroidOptions`.
- **Strings:** no user-visible literal outside `*_strings.dart`. Shared copy is in
  `core/l10n/` (`CommonStrings`, `AuthStrings`, `AccountStrings`, `ContentStrings`,
  `NotificationStrings`); feature copy in `lib/features/<f>/<f>_strings.dart`
  (`abstract final class XStrings { static const …; static String f(…) => …; }`).
  Natural Vietnamese per VF §8 (sentence case, "bạn", "hằng ngày", keep VP/RR/K/D/A…).
- **Numbers / dates:** always through `core/util/format.dart` (never `toString()` for
  user-visible numbers).
- **JSON:** Riot/valorant-api bodies are untrusted: parse with `core/util/json.dart`,
  every field nullable, lowercase UUIDs (`lowerUuid`), numbers via `asInt`/`asNum`.
- **Time:** read "now" from `clockProvider` (`ref.watch(clockProvider).now()`); derive
  countdowns with `Deadline.fromSeconds(seconds, receivedAt: now)`.
- **Providers:** Riverpod 3, no codegen. Data providers are families keyed by PUUID,
  usually `FutureProvider.autoDispose.family`. The app-wide `ProviderScope(retry:
  riotRetry)` never retries `NeedsLoginException`, maintenance or 4xx.
- **Mutations** (loadout PUT, agent select/lock, party/queue, quit/dodge) must be
  triggered by an explicit user action; anything with a penalty needs a confirmation
  dialog. Never automate.
- **Secrets:** never log or display tokens, cookies, PUUIDs. Use `SessionLog` (it
  scrubs) — not `print`/`debugPrint` with data.
- **Tests:** pure logic gets unit tests under `test/` mirroring `lib/` paths. Use
  `createTestPrefs()`, `MemorySecureStore`, `FixedClock`, `mocktail`, fixtures in
  `test/fixtures/`.
- **Analyze:** `flutter analyze` must stay at **0 issues** (infos are fatal) for your
  files. Lints: `analysis_options.yaml` (strict casts/inference/raw types,
  `avoid_dynamic_calls`, `discarded_futures`, `unawaited_futures`, …). Run
  `dart format lib test`.

Toolchain: `export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk`, then
`flutter analyze`, `flutter test`, `flutter build apk --debug`.

---

## 4. Routing

Routes are composed in `lib/app/router.dart`; features only edit their own
`*_routes.dart`.

| Branch / level | Routes file (export) | Locations |
|---|---|---|
| top level | `settings_routes.dart` (`settingsTopLevelRoutes`) | `/welcome` → `WelcomeScreen` |
| top level | core (`AuthRoutes`) | `/login`, `/login?reauth=<puuid>` → `LoginScreen` |
| top level | `community_routes.dart` (`communityTopLevelRoutes`) | `/compose` → `ComposeScreen` (`extra`: `ComposeDraft`), `/post/:id` → `PostDetailScreen` (`extra`: `CommunityPost`), `/community/skin/:uuid` → `SkinReviewScreen` (`CommunityRoutes.skin(uuid)`, `openSkinReview(context, uuid)` from anywhere) |
| top level | `profile_routes.dart` (`profileTopLevelRoutes`) | `/player/:puuid[?hidden=1]` → `PlayerProfileScreen`, `/match/:id[?player=<puuid>]` → `MatchDetailScreen` (full screen, e.g. from the live-game sheet) |
| tab 0 | `home_routes.dart` (`homeBranchRoutes`) | `/home[?focus=<card>]` (`HomeRoutes.focus(HomeCardId)`) |
| tab 1 | `store_routes.dart` (`storeBranchRoutes`) | `/store[?segment=daily\|nightmarket\|accessories\|bundles]`, `/store/bundle/:id` |
| tab 2 | `community_routes.dart` (`communityBranchRoutes`) | `/community[?section=feed\|lfg\|skins]` |
| tab 3 | `collection_routes.dart` (`collectionBranchRoutes({nested})`) | `/collection`, `/card`, `/title`, `/weapons`, `/weapons/:weaponId`, `/weapons/:weaponId/skin/:skinId`, `/expressions`, `/presets`, `/browse/:type` |
| tab 3 (nested) | `wishlist_routes.dart` (`wishlistRoutes`, relative) | `/collection/wishlist`, `/collection/catalog` |
| tab 4 | `profile_routes.dart` (`profileBranchRoutes({nested})`) | `/profile`, `/profile/rankup`, `/profile/daily-rr`, `/profile/match/:id` |
| tab 4 (nested) | `social_routes.dart` (`socialRoutes`, relative) | `/profile/party`, `/profile/friends`, `/profile/friends/:puuid/chat` |
| tab 4 (hosted) | `battlepass_routes.dart` (`battlepassBranchRoutes`) | `/battlepass`, `/battlepass/rewards` (opened from Trang chủ / Hồ sơ, on top of the tab) |
| tab 4 (hosted) | `settings_routes.dart` (`settingsBranchRoutes`) | `/settings`, `/settings/log`, `/settings/status`, `/settings/about[/<doc>]` (opened by the ⚙ button of Trang chủ / Hồ sơ) |

Location helpers (use them instead of string literals):
`StoreRoutes.bundle(id)`, `StoreRoutes.segment(StoreSegment.nightMarket)`,
`BattlePassRoutes.rewards`, `CollectionRoutes.weapon(id)`, `CollectionRoutes.weaponSkin(w, s)`,
`CollectionRoutes.browse(CollectionBrowseType.spray)`, `WishlistRoutes.wishlist`,
`ProfileRoutes.match(id, {player})`, `ProfileRoutes.matchFullScreen(id, {player})`,
`ProfileRoutes.player(puuid, {hidden})`, `SocialRoutes.chat(puuid)`,
`SettingsRoutes.log`, `AuthRoutes.loginPath(reauthPuuid: puuid)`.

```dart
context.push(ProfileRoutes.match(matchId));   // inside the tab (keeps the nav bar)
context.push(ProfileRoutes.player(puuid));    // full screen, above the tab bar
context.go(StoreRoutes.root);                 // switch tab
```

The shell has **five branches** in `AppTab` order: Trang chủ · Cửa hàng · Cộng đồng · Bộ sưu tập ·
Hồ sơ (never hard-code a branch index: use `AppTab.x.index`). Battle Pass and Cài đặt are not tabs:
their routes keep their paths and are extra roots of the Hồ sơ branch, so a `push` from Trang chủ or
Hồ sơ stays inside that tab and Back returns to it. Links to them from a notification use
`openAppLink(router, link)` (`planLinkNavigation`): it `go`es to `/profile` and pushes the page, so
Back works.

Redirect (`appRedirect`, unit-tested): no accounts → everything except `/welcome` and
`/login` goes to `/welcome`; with accounts `/welcome` and `/` (the "default tab", which core code
and the error page use without knowing feature paths) go to `/home`.

Community previews for other screens (`lib/features/community/community_previews.dart`):
`matchingLfgPreviewProvider(puuid)` → 2 open LFG posts that fit the account's rank (only when the account
already agreed to join **and** the Cộng đồng tab already created a session: a preview never signs in) +
`LfgPreviewCard`; `trendingSkinsProvider(TopPeriod.week)` → top skins (read-only, anonymous) +
`TrendingSkinsCard`. Trang chủ reads the two providers directly.

Sheets (not routes): `showSkinDetailSheet(context, skinOrLevelUuid: id, mode:
SkinDetailMode.store|owned|catalog)`, `openSkinVideo(context, videoUrl:)` (S16), `showLiveGameSheet(context)`,
`showPlayerLoadoutSheet(context, matchId:, playerPuuid:, pregame:, viewerPuuid:, playerName:)` (last three optional),
`showBuddyPickerSheet(context, weaponId:)`, `showNotificationPrimingSheet(context) →
Future<bool>` (asks the OS itself; `true` only when notifications end up allowed;
`runNotificationPriming()` also tells "Để sau" apart from a refusal),
`showAccountSwitcherSheet(context)`.

Notification payloads are route locations, optionally with `account=<puuid>`
(`/store?account=…&segment=nightmarket`); `ValVnApp` switches the account and navigates.

---

## 5. Core API reference

### 5.1 Accounts — `core/accounts/`

```dart
enum GamePlatform { pc, playstation, xbox }            // .label, .isConsole
class Account {                                         // non-secret metadata (prefs)
  String puuid, gameName, tagLine, region, shard;
  GamePlatform platform; bool needsLogin;
  String? cardId; int? level; int? rankTier; String? rankSeasonId; DateTime? addedAt;
  String get riotId;            // "Tên#TAG"
  RiotHosts get hosts;
  Account copyWith({...});
}
class MaxAccountsException { int max; String get message; }   // "Đã đạt tối đa 10 tài khoản."
```

| Provider | Type | Use |
|---|---|---|
| `accountsProvider` | `NotifierProvider<AccountsNotifier, List<Account>>` | all accounts |
| `activePuuidProvider` | `NotifierProvider<ActivePuuidNotifier, String?>` | `.notifier.select(puuid)` switches account |
| `activeAccountProvider` | `Provider<Account?>` | the account shown in the UI |
| `accountProvider(puuid)` | `Provider.family<Account?, String>` | one account |
| `hasAccountsProvider` | `Provider<bool>` | router redirect |
| `accountRepositoryProvider` | `Provider<AccountRepository>` | low level |

`AccountsNotifier`: `completeLogin(tokens:, cookies:)` (login screen only),
`updateAccount(puuid, (a) => a.copyWith(level: 222, cardId: …, rankTier: …))` — **features
should call this to cache card/level/rank for the switcher (A4)**, `remove(puuid)` (sign-out:
wipes secrets, `acct.<puuid>.*` prefs, `acct/<puuid>/…` caches, notifications; keeps the
wishlist), `signOutAll()`, `reload()`, `isFull`.

Widgets: `AccountChip({showName})` (tab headers), `AccountAvatar(account:, size:)`,
`AccountTile(account:, selected:, onTap:, trailing:)` (settings list), `AccountSwitcherSheet`.

Refetch after a re-login:

```dart
ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
```

### 5.2 Riot game-client API — `core/riot/pvp_api.dart`

`pvpApiProvider` → `PvpApi`. Every method takes the **signed-in account's** `puuid`
(whose tokens/shard are used); "any player" endpoints take `subject`. Returns decoded
JSON (`JsonMap` / `List<JsonMap>`); throws only `RiotException` subtypes. GETs get two
quick inline retries on transient errors; mutations are never retried.

| # | Method |
|---|---|
| P-1 | `storefront(puuid)` (POST `{}`) |
| P-2 | `wallet(puuid)` |
| P-3 / P-4 | `entitlements(puuid, itemTypeId)` / `allEntitlements(puuid)` |
| P-5 | `offers(puuid)` (UNVERIFIED; flag `use_offers_endpoint`) |
| P-6 | `favorites(puuid)` |
| P-7 | `itemUpgrades(puuid)` |
| P-8 | `playerLoadout(puuid)`, `putPlayerLoadout(puuid, rawLoadout)` (whole raw map from a fresh GET) |
| P-9 | `accountXp(puuid)` |
| P-10 | `names(puuid, subjects)` → `List<JsonMap>` (batched ≤ 50) |
| P-11 | `mmr(puuid, {subject})` |
| P-12 | `competitiveUpdates(puuid, {subject, startIndex, endIndex, queue = 'competitive'})` (page ≤ 20) |
| P-13 | `matchHistory(puuid, {subject, startIndex, endIndex, queue})` (page ≤ 20) |
| P-14 | `matchDetails(puuid, matchId)` |
| P-15 | `contracts(puuid)` |
| P-16 | `dailyTicket(puuid)`, `renewDailyTicket(puuid)` |
| P-17 | `penalties(puuid)` |
| S-1 / S-2 | `content(puuid)`, `config(puuid)` |
| G-1 | `gameSession(puuid)` |
| G-2…G-7 | `pregamePlayer`, `pregameMatch(puuid, matchId)`, `pregameSelectAgent(puuid, matchId, agentId)`, `pregameLockAgent(…)`, `pregameQuit(puuid, matchId)` ⚠ penalty, `pregameLoadouts(puuid, matchId)` |
| G-8…G-11 | `coreGamePlayer`, `coreGameMatch(puuid, matchId)`, `coreGameLoadouts(puuid, matchId)`, `coreGameDisassociate(puuid, matchId)` ⚠ penalty |
| G-12…G-24 | `partyPlayer`, `party(puuid, partyId)`, `partyChangeQueue(puuid, partyId, queueId)`, `partyJoinMatchmaking`, `partyLeaveMatchmaking`, `partySetReady(puuid, partyId, ready:)`, `partyInviteByRiotId(puuid, partyId, gameName:, tagLine:)`, `partyGenerateInviteCode`, `partyDisableInviteCode`, `partyJoinByCode(puuid, code)`, `partyAcceptInvite(puuid, partyId)` (flag `party_accept_invite`), `partyDeclineRequest(puuid, partyId, requestId)`, `partyRemovePlayer(puuid, {subject})`, `partySetAccessibility(puuid, partyId, open:)`, `partyRefreshCompetitiveTier(puuid, partyId)` |
| A-7 / A-8 | `chatPasToken(puuid)` → raw JWT, `chatClientConfig(puuid)` (XMPP bootstrap) |
| X-1 | `platformStatus(region)` (no auth) |

`404`s are states for live-game endpoints:

```dart
final pregame = await api.pregamePlayer(puuid).orNullIfNotFound();  // null = not in agent select
```

Also in `core/riot/`: `RiotHosts(region:, shard:)` (`.pd`, `.glz`, `.shared`),
`shardForRegion(region)`, `supportedRegions`; ids in `riot_ids.dart`
(`ItemTypeIds`, `CurrencyIds`, `ContentTierIds`, `SpecialIds`, `AgentRoleIds`,
`LoadoutSocketIds`); `platformStatusProvider(region)` → `PlatformStatus`
(`maintenances`, `incidents`, `headline`; vi titles).

### 5.3 Errors — `core/network/riot_exception.dart`

```dart
sealed class RiotException implements Exception { bool get isRetryable; }
final class NeedsLoginException   ({String? puuid, String? reason})   // cookies dead → /login?reauth=
final class TransientException    ({Duration? retryAfter, int? status, String? reason})  // network, CF 403, 429, 5xx
final class MaintenanceException  ({String? message})                  // 403 SCHEDULED_DOWNTIME
final class NotFoundException     ({String? errorCode})                // 404
final class RiotApiException      (int status, {String? errorCode, String? message})
extension on Future<T> { Future<T?> orNullIfNotFound(); }
```

`describeError(error) → ErrorDescription(title, message, needsLogin, puuid, canRetry, icon)`
gives the Vietnamese copy; `classifyError(anyError) → RiotException`; `riotRetry` is the
global Riverpod retry policy; `backoffDelay(attempt)`, `parseRetryAfter(header)`.

### 5.4 Sessions (rarely needed directly) — `core/auth/`

`sessionManagerProvider` → `SessionManager`:
`Future<RiotSession> session(puuid)`, `refreshAfterAuthFailure(puuid, failedAccessToken:)`,
`peek(puuid)`, `invalidate(puuid)`, `forget(puuid)`, `Stream<SessionEvent> events`
(`SessionNeedsLogin` / `SessionRestored`). `RiotSession` has `puuid, accessToken, idToken,
entitlementsToken, expiresAt, hosts, region, shard, clientVersion, userAgent, gameHeaders`
(its `toString` never prints tokens). `sessionProvider(puuid)` exposes it as a
`FutureProvider`. PvpApi already attaches sessions, retries once on 401 / 400 BAD_CLAIMS
after a single-flight re-auth, and maps failures — features should not build requests.

The XMPP client (social) needs the raw tokens: `final s = await
ref.read(sessionManagerProvider).session(puuid);` then `s.accessToken`,
`s.entitlementsToken`, plus `pvp.chatPasToken(puuid)` / `pvp.chatClientConfig(puuid)`.
Reconnect after every re-auth (listen to `events` or re-read the session on 401).

### 5.5 Content — `core/content/`

`contentProvider` → `FutureProvider<ContentDb>` (kept alive; language from
`AppSettings.itemLanguage`: `vi-VN` default, `en-US` optional). Use
`ref.watch(contentProvider).value ?? ContentDb.empty()` for synchronous lookups (fallback
tables for currencies, content tiers and queue names are always present).

Typed models (all fields nullable-safe): `Weapon` (`category: WeaponCategory` with vi
`label`, `skins`, `shopCost`), `WeaponSkin` (`levels`, `chromas`, `contentTierUuid`,
`themeUuid`, `weaponUuid`, `level1Uuid`, `image`, `render`, `previewVideo`,
`isStandard`, `isRandomFavorite`, `isCollectible`, `isLimitedEdition`), `SkinLevel`
(`levelItem`, `levelItemLabel`, `streamedVideo`, `description`), `SkinChroma` (`label`,
`fullRender`, `swatch`, `streamedVideo`), `Bundle` (`cardImage`, `verticalPromoImage`,
descriptions), `Buddy`/`BuddyLevel`, `Spray` (`image`, `animatedImage`), `PlayerCard`
(`smallArt`, `wideArt`, `largeArt`), `PlayerTitle` (`text`), `FlexItem`, `LevelBorder`,
`ContentTier` (`shortName`, `fallbackPrice`, `highlightColor`), `Currency` (`label`,
`fullLabel`), `Agent` (`role.label`, portraits, `abilities`, `ability(slot)`, `isStarter`),
`GameMap` (`mapUrl`, `splash`, `listViewIcon`), `GameQueue` (`label`), `GameMode`,
`Ceremony`, `Gear`, `GameEvent`, `CompetitiveTierTable`/`CompetitiveTier` (`displayName` "Kim Cương 1",
`isUnranked`, icons, colors), `Season` (`isAct`, `title`, times), `CompetitiveSeason`
(`borders`), `Contract` (`relation`, `relationUuid`, `chapters`, `flatLevels`, `totalXp`,
`xpForNextLevel(level)`), `ContractReward` (`type.label`, `type.itemTypeId`), `Mission`.

`ContentDb` lookups (inputs are lowercased): `weapon`, `skin`, `skinByLevelUuid`,
`skinByChromaUuid`, `skinByAnyUuid`, `skinLevel`, `skinChroma`, `weaponBySkin`,
`collectibleSkins`, `bundleByUuid`, `buddy`, `buddyByLevelUuid`, `spray`, `card`, `title`,
`flex`, `levelBorderFor(level, preferredId:)`, `contentTier`, `currency`,
`item(itemTypeId, itemId) → ContentItemRef(name, typeLabel, image, contentTierUuid)`,
`agent`, `mapByUrl(mapId)`, `queue`, `queueName(queueId)` (API → VF §8.9 fallback →
raw id; handles `console_*` and `""`), `queueShortName`, `gameModeByPath(modeId)`,
`ceremony('CeremonyAce')`, `gearItem(armorId)`, `event(uuid)`,
`weaponOrEquippable(damageItem)` (kill feed; includes Golden Gun / NPE Classic),
`tierTableForSeason(seasonId)` (SUMMARY §7.4; unknown act →
newest table), `tier(n, seasonUuid:)`, `season`, `competitiveSeason`, `acts`,
`currentAct(now)`, `episodeOf(act)`, `actTitle(act)`, `contract`, `currentBattlePass(now)`,
`mission`, `rewardSource(itemUuid)` / `rewardSourceForSkin(skin)` → `RewardSource.label`
("Phần thưởng Battle Pass" …).

On a miss (a Riot uuid not in `ContentDb` after a patch) call
`ref.read(contentMissReporterProvider).report()` (re-downloads at most every 6 h) and render
`CommonStrings.unknownItem`.

### 5.6 Storage — `core/storage/`

- `prefsProvider` → `Prefs` (sync reads over `SharedPreferencesWithCache`): `getString/
  getInt/getBool/getDouble/getStringList/getJson/getDateTime`, `set…`, `remove`,
  `removePrefix`, `reload`. Key rules (`PrefKeys`): feature keys `f.<feature>.<name>`;
  per-account data wiped at sign-out `PrefKeys.account(puuid, name)` (`acct.<puuid>.…`);
  per-account data kept at sign-out `PrefKeys.accountKept(puuid, name)` (`keep.<puuid>.…`).
- `jsonFileCacheProvider` → `JsonFileCache` (app-support dir): `read(key) → CachedJson(data,
  savedAt)`, `write(key, json)`, `readRaw/writeRaw`, `delete`, `deletePrefix`, `clear`,
  `sizeBytes`. Per-account offline caches (X4) MUST use `JsonFileCache.accountKey(puuid,
  name)`; match details (immutable) can use a global key.
- `secureStoreProvider` → `SecureStore` (secrets only; features normally never touch it).

### 5.7 Settings and wishlist (shared contracts)

- `appSettingsProvider` → `AppSettings { themeMode, itemLanguage, autoOpenLiveGame,
  showPeakRankInGame, showLiveScore, storeResetNotifications, wishlistNotifications,
  nightMarketNotifications }`; write with `ref.read(appSettingsProvider.notifier).update((s)
  => s.copyWith(...))`, `setThemeMode`, `setItemLanguage`. `themeModeProvider` derives from
  it. Background isolates: `readAppSettings(prefs)`.
- `wishlistProvider(puuid)` → `Set<String>` of **skin uuids**; notifier `add`, `remove`,
  `toggle` (→ new membership), `contains`. `WishlistRepository(prefs)` for background
  isolates. Stored under `keep.<puuid>.wishlist` (survives sign-out, VF W6).

### 5.8 Notifications — `core/notifications/notification_service.dart`

`notificationServiceProvider` → `NotificationService`:
`requestPermission()` (Android 13+/iOS; normally reached through
`showNotificationPrimingSheet`, which calls it), 
`areEnabled()`, `openSystemSettings()`,
`scheduleAt({id, at, title, body, channel, payload, accountPuuid, tag})` (inexact,
tz-aware; `accountPuuid` makes it cancelled on sign-out), `showNow({...})`,
`cancel(id, {tag})`, `cancelAll()`, `pendingIds()`, `cancelForAccount(puuid)`.
Channels: `NotificationChannel.storeReset | wishlist | nightMarket | account`.
Stable ids: `NotificationIds.storeReset(puuid)`, `.nightMarket(puuid)`,
`.wishlistHit(puuid, skinUuid)`, `.sessionExpired(puuid)`, `.forKey(anyKey)`.
Android small icon: `@drawable/ic_stat_valvn` (white V, kept by `res/raw/keep.xml`),
tinted Valorant red.

```dart
// B8: store reset reminder (re-schedule after every storefront fetch).
// StoreStrings.reset… are examples: add them to your own strings file.
await ref.read(notificationServiceProvider).scheduleAt(
  id: NotificationIds.storeReset(puuid),
  at: dailyDeadline.expiresAt.add(const Duration(minutes: 1)),
  title: StoreStrings.resetNotificationTitle,
  body: StoreStrings.resetNotificationBody(account.riotId),
  channel: NotificationChannel.storeReset,
  payload: '${StoreRoutes.root}?account=$puuid',
  accountPuuid: puuid,
);
```

### 5.9 Background — `core/background/`

One periodic workmanager task `kWishlistCheckTask = 'vn.valvn.app.wishlistCheck'` (≥ 6 h,
network required; same id in Info.plist and AppDelegate). It runs
`runSessionKeepAlive()` (re-auths dormant accounts every 3 days, notifies "Cần đăng nhập
lại" once) then `runWishlistCheck()` (wishlist feature,
`lib/features/wishlist/background/wishlist_check.dart`): at most one storefront read per
account per UTC day, which serves both the wishlist alerts (setting
`wishlistNotifications`) and "Chợ Đêm đã mở!" once per Night Market (setting
`nightMarketNotifications`). No Riverpod there: use

```dart
final ctx = await BackgroundContext.instance();   // prefs, accounts, sessions, pvp,
                                                   // content, notifications, wishlist, log, settings
try { … } finally { await ctx.finish(); }
```

### 5.10 Shared UI — `core/ui/`

| Widget | Purpose |
|---|---|
| `AsyncValueView<T>(value:, data:, onRetry:, isEmpty:, emptyMessage:, loading:, empty:, puuid:)` | loading skeleton / error ("Thử lại", "Đăng nhập lại" → `/login?reauth=`) / empty / data; keeps stale data visible with a compact error row |
| `ErrorView(error:, onRetry:, puuid:, compact:)`, `describeError(e)`, `showAppSnackBar(context, msg)` | errors |
| `EmptyView(message:, title:, icon:, action:, color:)`, `StateIcon` | empty states (icon in a tinted disc, bold title, muted copy, action) |
| `Skeleton(width:, height:, radius:)`, `SkeletonShimmer`, `SkeletonList`, `SkeletonGrid` | loading |
| `CountdownText(expiresAt:, builder: (t) => …, onExpired:, format:)` | live `11:54:37` / `2 ngày 15:09:24` |
| `CurrencyAmount(currencyId:, amount:)`, `.vp(n)`, `.kc(n)`, `.rp(n)` (`estimate`, `strikethrough`, `showLabel`) | amount with valorant-api icon |
| `NetImage(url, width:, height:, fit:, borderRadius:)`, `valMediaCache`, `clearMediaCache()` | cached images (30-day cache) |
| `RankBadge(tier:, seasonId:, size:, showName:, rr:)` | rank icon + vi name in the act's table |
| `ContentTierBadge(contentTierUuid:, showName:, fullName:)`, `contentTierTint(ref, uuid)` | rarity |
| `SectionHeader(title, trailing:, onTap:, uppercase:)` | section titles |
| `TabPageScaffold(title:, actions:, onRefresh:, header:, headerHeight:, slivers:/body:)` | tab roots: large Anton title, `AccountChip`, maintenance banner, adaptive pull-to-refresh, frosted pinned header |
| `SegmentedTabs<T>(tabs: [SegmentedTab(value:, label:, showDot:, icon:)], selected:, onChanged:, expand:)` | "glass capsule" segmented control; the red highlight slides between segments, selection haptic; `expand: true` = equal widths |
| `GlassCapsule`, `GlassBar`, `GlassHeaderDelegate(child:, height:)` | translucent pill track; frosted strip for small pinned chrome only (never over a whole list) |
| `adaptive.dart`: `isCupertino(context)`, `Haptics.selection/light/medium/heavy()`, `showConfirmDialog(context, title:, message:, confirmLabel:, destructive:, icon:)` → `bool`, `showActionSheet<T>(context, actions: [SheetAction(value:, label:, icon:, destructive:)])`, `AdaptiveRefresh(onRefresh:, child:)` | Cupertino dialogs / action sheets / refresh spinner on iOS, Material 3 on Android |
| `filter_bar.dart`: `GlassSearchField`, `ValFilterChip(label:, selected:, onSelected:, dotColor:)`, `SortButton<T>(options: [(value:, label:)], selected:, onSelected:)`, `FilterChipBar(children:, onClear:)` | search / multi-filter chips / sort on every list screen |
| `CountdownRing(expiresAt:, period:)`, `CountdownPill(expiresAt:, period:, builder:)` | ring of the time left in a cycle (store reset, Night Market, act end); only the ring/text rebuild each second |
| `SkinArtCard(imageUrl:, name:, tierColor:, footer:, topStart:, topEnd:, dimmed:, selected:)`, `TierTag(label:, color:)` | image-forward grid card with rarity glow and edge |
| `ValCard`, `SectionLabel`, `GroupedSection`/`GroupedRow`, `IconTile`, `ValProgressBar` (animated), `DiamondPip`, `StatusPill`, `ValBadge`, `CurrencyPill` | Figma design-system pieces (`val_widgets.dart`) |
| `MaintenanceBanner({region})` | X-1 notice (vi) |
| `sub_page.dart`: `SubPageScaffold(title:, subtitle:, actions:, onRefresh:, hero:/heroImage:, heroHeight:, showLargeTitle:, header:, slivers:/body:, bottomBar:)`, `LargeTitle`, `HeroBackdrop(imageUrl:, child:, tint:)`, `SubPageBottomBar` | **every screen pushed from a tab**: large title that hands over to a small bar title on scroll, optional collapsing hero with a gradient scrim (no Opacity/blur over content), pinned glass header, pull-to-refresh |
| `showValSheet(context, title:, subtitle:, actions:, builder: (ctx, controller) => …, scrollable:)`, `SheetHeader`, `SheetCloseButton` | **every modal sheet**: drag handle + bold title + round close button (ValBuddy "Game Details"); fits content or draggable with a controller |
| `price_estimate.dart`: `PriceEstimate(vp)`, `priceEstimateText(ref, vp)`, `showPriceEstimateInfoSheet`, `showVpPriceOverrideSheet` | "≈ 268.000 ₫" / "≈ $16.10" next to VP prices, in the user's currency: their own pack price ("Giá gói VP của bạn") if entered, else the verified table of the device's country (remote config `vpPrices`); hidden when neither exists or the user turns it off. Providers in `core/config/local_price.dart` (`localPriceProvider`, `vpPriceOverrideProvider`, `deviceCountryProvider`) |

Theme: `ValColors` (red `#FF4655`, navy, teal …), `valColorsOf(context)` →
`ValThemeColors(win, loss, draw, warning, muted, …)`, `AppFonts.body` (Be Vietnam Pro),
`AppFonts.display` (Anton, used by `displayX/headlineLarge/headlineMedium`),
`parseRgba('RRGGBBAA')`, `opaqueRgba(hex)`. Tokens: `ValRadius` (card 16, small 12, pill),
`ValSpace` (4-pt scale, gutter 16), `ValMotion` (fast 150 / medium 250 / slow 400 ms,
`easeOutCubic`), `ValText` (screen title, display, label). Content colors used as text
(rarity, rank) go through `legibleAccent(context, color)` / `legibleOn(color, bg)` so
they keep ≥ 4.5:1 on the light theme; the light palette itself is WCAG AA
(`test/core/theme/contrast_test.dart`).

Remembered UI choices: `ref.read(uiMemoryProvider)` → `UiMemory` (`read/write`,
`readEnum/writeEnum`, `readBool/writeBool`) under `ui.<screen>.<name>` prefs keys
(app-wide, survive sign-out). Every segment / filter / sort a user picks should be
restored the next time the screen opens (deep links still win).

### 5.11 Utilities — `core/util/`

- `json.dart`: `JsonMap`, `asMap`, `asList`, `asMapList`, `asStringList`, `asString`,
  `asNonEmptyString`, `asInt`, `asDouble`, `asNum`, `asBool`, `lowerUuid`, `asDateTime`,
  `pick(root, ['a', 0, 'b'])`, `tryDecodeJson`, `vapiData`; extension on `JsonMap`:
  `obj`, `list`, `maps`, `strings`, `str`, `text`, `integer`, `dbl`, `number`, `boolean`,
  `uuid`, `dateTime`.
- `format.dart`: `formatNumber` (1.162.500), `formatVp/Kc/Rp`, `formatEstimatedVp`,
  `formatSigned`, `formatSignedRr` (+24 RR / −17 RR), `formatDiscountPercent` (-32%),
  `formatPercent`, `formatCountdown`, `formatMinutesSeconds`, `formatDurationCoarse`,
  `formatRelative` (vừa xong / 18 giờ trước / hôm qua / 3 ngày trước), `formatDate`,
  `formatDayMonth`, `formatTime`, `formatDateTime`, `formatWeekday`, `formatWeekdayDate`
  (Thứ Hai, 22/09), `formatDayHeader` (Hôm nay / Hôm qua / …), `formatUpdatedAt`,
  `viTitleCase`, `cleanDisplayText`, `isRawLocKey`, `firstLine`, `restLines`.
- `search_text.dart`: `foldForSearch` — language-independent folding for every VALORANT
  language (lowercase, canonical decomposition with combining marks dropped via the generated
  `search_fold_table.dart`, đ/ß/æ/œ/ø/ł/ı/İ, Arabic harakat + tatweel, full-width ASCII; kana,
  Hangul and CJK untouched), `matchesSearch(query, candidates)`, `searchTokens`, `matchesTokens`,
  `compareNames`, `SearchIndex<T>` — **every search box** goes through these. Regenerate the
  table with `python tool/gen_search_fold_table.py`.
- `format.dart` is locale-aware: numbers, dates, times, weekdays and percents take an optional
  `locale` (default `currentIntlLocale()`: the UI locale, Vietnamese today); instants are shown in
  the device time zone. Also `formatCurrency(amount, currency)` / `formatEstimatedPrice`
  (`≈ 268.000 ₫`), `currencyDecimalDigits`, `formatWallTime(at, now)` (`07:00 ngày mai`,
  `23:59 thứ Hai 06/10`), `formatWeekdayLower`.
- `clock.dart`: `Clock`, `FixedClock` (tests), `clockProvider`.
- `countdown.dart`: `expiresAtFrom(seconds, receivedAt)`, `remainingUntil`, `Deadline`
  (`fromSeconds`, `remaining(now)`, `isExpired(now)`), `earliest(deadlines)`.

### 5.12 Config and logging

- `AppConstants` (`maxAccounts = 10`, timeouts, URLs), `AuthConstants`,
  `RiotClientConstants` (client platform, UAs, fallback version, `maxPageSize = 20`).
- `remoteConfigProvider` → `RemoteConfig { flags, webViewUserAgent, apiUserAgent,
  clientVersionOverride, communityBaseUrl, vpPrices }`, `flag(RemoteFlags.liveScore)`.
  `vpPrices` (`VpPriceCatalog`): ISO 3166-1 alpha-2 country → `{currency, packs: [{vp, price}],
  source, updated}` — only countries whose prices were verified from an official or reputable
  source (today VN and US). Estimates use the best-value pack, rounded to 3 significant digits
  (never finer than the currency's minor unit). Flags: `social_login_hint`,
  `reauth_post_first`, `use_offers_endpoint`, `nm_next_date_source`, `live_score`,
  `party_accept_invite`, `console_support`.
- `clientVersionRepositoryProvider` → `current` (`riotClientVersion`, `riotClientBuild`,
  `manifestId`), `apiUserAgent`, `refresh()`.
- `sessionLogProvider` → `SessionLog` (`ChangeNotifier`): `entries`, `add(event, uri:,
  status:, elapsed:, detail:)`, `http(...)`, `exportText(header:)`, `clear()`, `flush()`;
  static `scrubUri`, `scrubText`. Every HTTP call through core dios is logged
  automatically.

### 5.13 Community — `lib/features/community/`

- **Session and consent:** everyone can browse (feed, posts + comments, skin leaderboard, review pages,
  countries) **anonymously**: no consent, no token, no `Authorization` header, scope defaults as the
  server does when unauthenticated (feed → global) and a banner offers to join. Only actions that need
  a session (post / comment / review / like / vote / report, all of Tìm đồng đội) require consent: the
  consent sheet opens at that moment and the action continues after "Đồng ý"
  (`promptConsentFromContext`). The Riot access token goes to `POST /v1/auth/riot` only after the
  account agreed once (`communityConsentProvider(puuid)`, pref `acct.<puuid>.community.consent`, wiped
  with the account); `CommunityAuth` throws `consentRequired` before touching Riot or the network, and
  optional-auth reads stay anonymous without it. "Để sau" never hides browsing. Home previews never ask
  and never sign in.
- **Scopes (v3):** feed and skin leaderboard default to the viewer's country
  (`communityScopeProvider(ScopedSection)` remembered in `UiMemory`, resolved by
  `resolvedScopeProvider`; no country → the viewer's shard), LFG always shows one shard.
  `GET /v1/communities` feeds the country picker.
- **Translation:** on-device only (`CommunityTranslator`, ML Kit `google_mlkit_translation` on
  Android / iOS, download confirmed with its size, Google attribution shown). **iOS needs
  CocoaPods for this plugin**: `ios/Podfile` (iOS 15.5) is checked in and the deployment target is
  15.5; to drop translation remove the package, `ios/Podfile` and use
  `UnsupportedCommunityTranslator`.
- Public entry points for other screens: `community_previews.dart`
  (`matchingLfgPreviewProvider`, `trendingSkinsProvider`, `LfgPreviewCard`, `TrendingSkinsCard`),
  `openSkinReview(context, skinUuid)`.

---

## 6. Recipes

**A PUUID-keyed data provider (storefront of the active account):**

```dart
// lib/features/store/providers/storefront_provider.dart
final storefrontProvider = FutureProvider.autoDispose.family<Storefront, String>((ref, puuid) async {
  ref.watch(accountProvider(puuid).select((a) => a?.needsLogin)); // refetch after re-login
  final receivedAt = ref.read(clockProvider).now();
  final json = await ref.watch(pvpApiProvider).storefront(puuid);
  return Storefront.fromJson(json, receivedAt: receivedAt);       // feature-owned parser
});

// UI
final account = ref.watch(activeAccountProvider);
if (account == null) return const EmptyView(message: CommonStrings.errorNoAccount);
return AsyncValueView(
  value: ref.watch(storefrontProvider(account.puuid)),
  puuid: account.puuid,
  onRetry: () => ref.invalidate(storefrontProvider(account.puuid)),
  data: (store) => StoreGrid(store),
);
// pull-to-refresh: TabPageScaffold(onRefresh: () => ref.refresh(storefrontProvider(puuid).future), …)
```

**Resolving content:**

```dart
final db = ref.watch(contentProvider).value ?? ContentDb.empty();
final skin = db.skinByLevelUuid(offerId);                  // store offers are level-1 uuids
final tier = db.contentTier(skin?.contentTierUuid);
final rank = db.tier(competitiveTier, seasonUuid: seasonId)?.displayName;   // "Kim Cương 1"
final queue = db.queueName(match.queueId);                  // "Thi đấu xếp hạng"
final map = db.mapByUrl(match.mapId)?.displayName;
```

**Showing errors:** throw/let through `RiotException`s from providers and render with
`AsyncValueView` or `ErrorView`. Never catch `NeedsLoginException` to hide it.

**Offline cache (X4):** after a successful fetch,
`ref.read(jsonFileCacheProvider).write(JsonFileCache.accountKey(puuid, 'storefront'), json)`; on a
`TransientException` show the cached copy with `formatUpdatedAt(savedAt, now)`.

**Countdown:** `Deadline.fromSeconds(json.integer('SingleItemOffersRemainingDurationInSeconds'),
receivedAt: receivedAt)` → `CountdownText(expiresAt: d.expiresAt, builder: StoreStrings.resetsIn,
onExpired: () => ref.invalidate(storefrontProvider(puuid)))`.

**Tests:**

```dart
final prefs = await createTestPrefs();
final container = ProviderContainer.test(overrides: [
  prefsProvider.overrideWithValue(prefs),
  pvpApiProvider.overrideWithValue(mockApi),        // class MockApi extends Mock implements PvpApi {}
  contentProvider.overrideWith((ref) async => ContentDb.parse(loadContentFixtures())),
  clockProvider.overrideWithValue(FixedClock(DateTime(2026, 9, 28, 12))),
]);
```

---

## 7. Deviations from the research docs

- **Strings:** Dart `*_strings.dart` classes instead of gen-l10n ARB files (CLAUDE.md rule).
  Only `GlobalMaterialLocalizations.delegates` (material_ui) are registered.
- **Rate limiter:** bursts of 8, 2 req/s, ≤ 3 in flight per host (SUMMARY U17 suggests ≈ 1
  req/s, bursts ≤ 5) so match lists stay responsive; a 429 puts the host in cooldown.
- **Android namespace** stays `vn.valvn.valvn` (Kotlin package of the generated
  `MainActivity`); `applicationId` and the iOS bundle id are `vn.valvn.app`.
- **Wishlist storage** and **app settings** live in `core/` because several features share
  them.
- **Session keep-alive** (SUMMARY §3.4 "re-auth dormant accounts") runs in the same periodic
  task before the wishlist check.
