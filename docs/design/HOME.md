# ValVN: "Trang chủ" (Home) smart dashboard, implementation spec

Status: ready to implement. Written against commit `2963258` (branch `claude/jolly-hawking-23o2j8`). Main sources: `docs/design/IA.md` (the decided IA), `docs/ARCHITECTURE.md`, `docs/design/DESIGN.md`, `docs/community-api.md`, `docs/PROGRESS.md`, `docs/research/SUMMARY.md` §9–§10, and the code under `lib/`.

This task was read-only: no repo file was created or changed. Every path marked **new** below still has to be created.

---

## 0. TL;DR

- **New tab 0 "Trang chủ"** at `/home`, in the new feature folder `lib/features/home/`.
- **The shell goes from 6 tabs to 5:** Trang chủ · Cửa hàng · **Cộng đồng** (middle, emphasized) · Bộ sưu tập · Hồ sơ.
- **Battle Pass and Cài đặt are no longer tabs.**
  - Their routes keep their exact paths (`/battlepass…`, `/settings…`). The **Profile branch** now hosts them.
  - Profile gets a ⚙ header button and a "Battle Pass" row. The Home header also gets ⚙.
  - Notification payloads keep working. `/settings` links open with a real back stack: Hồ sơ → Cài đặt.
- **Eight cards, in IA order.**
  - Each card reads existing providers (named with paths in §3.6) through a small Home view-model built by pure, tested functions.
  - A card with no data is not rendered: there are no empty boxes.
  - The live match and a *blocking* maintenance float to the top.
- **No new Riot polling loops.**
  - Home reuses the live-game poller (owned by `LiveGameOverlayHost`), the provider TTLs and the countdown-driven refetches.
  - Home adds only three widget-owned pollers, all gated on "tab visible" and "app in foreground":
    - LFG preview: every 60 s.
    - Server status: every 5 min.
    - Other accounts' activity: every 2 min.
- **Private by default.**
  - Home never signs in to the community server, so no Riot token leaves the device because of Home.
  - Home never connects to Riot chat without a one-time opt-in, because connecting makes you look online to friends. `PROGRESS.md` already records that the team avoids opening chat on every Profile visit.
- **Personalization.** Users can reorder and hide cards. The layout is stored in `Prefs` under the key `f.home.layout`.
- **Required regression fix.** Today only `StoreScreen` schedules the store-reset reminder. Once Home is the landing tab, the Store tab may never be built, so reminders would silently stop after one day. The scheduling moves to an always-mounted `StoreResetReminderHost`.

---

## 1. Decisions

| # | Decision | Why |
|---|---|---|
| D1 | `/battlepass…` and `/settings…` keep their paths and route files. They are composed into **branch 4 (Hồ sơ)** as extra root routes of that branch. | IA says "route giữ nguyên". There is no churn in `battlepass_routes.dart`, `settings_routes.dart` or their six test files. `push` from any tab stays in that tab, and Back returns to where the user was. A deep link gets a synthesized parent (`planLinkNavigation`, §2.4). **Rejected alternative:** nesting them under `/profile/...` with legacy redirects. That renames constants, breaks feature tests, and adds a redirect hop to every old link. |
| D2 | In core, `/` means "the default tab". The login screen, the error page and the deep-link fallback go to `/`, and `appRedirect` maps `/` to `/home`. | Core (`lib/core/auth/login_screen.dart`) must not know feature paths. It hard-codes `/store` today. |
| D3 | Home owns all Home UI. It imports other features' providers and pure helpers **read-only**. The imported symbols (§3.6) become frozen public API, listed in ARCHITECTURE §2. | One implementer, one folder. The other features only gain small, clearly scoped additions (§2.5–§2.6, §11). |
| D4 | Skeletons are shown only for the "core" cards (store, rank, Battle Pass), which are almost always present. Optional cards appear when their data arrives. | Avoids a skeleton flashing and then vanishing (layout jumps). |
| D5 | Pin order: a blocking server status first, then the live match, then the user's order. | A blocking maintenance explains why every other card is empty. IA: "Trận hiện tại … nổi lên đầu". |
| D6 | Home exposes **no mutations**: no agent lock, quit or dodge, party join, or queue. | CLAUDE.md rule. Such actions live on their own screens, with confirmations. |
| D7 | Friends' presence is opt-in. Community data is read-only and needs no sign-in. | Privacy (§5.5, §11). |
| D8 | Other accounts: wishlist status comes from **saved** storefronts (no network). Activity is polled slowly, and only for the rows shown. | Up to 9 alts could otherwise mean 9 re-auths and 9 storefront reads at every launch. |

---

## 2. Shell change (6 tabs → 5)

### 2.1 Branches

| Index | Tab (label) | Icon (outlined / selected) | Branch routes | Branch root |
|---|---|---|---|---|
| 0 | **Trang chủ** (`CommonStrings.tabHome`, **new**) | `home_outlined` / `home_rounded` | `homeBranchRoutes` (**new**) | `/home` |
| 1 | Cửa hàng | `storefront_outlined` / `storefront` | `storeBranchRoutes` | `/store` |
| 2 | **Cộng đồng** (emphasized) | `forum_outlined` / `forum` | `communityBranchRoutes` | `/community` |
| 3 | Bộ sưu tập | `inventory_2_outlined` / `inventory_2` | `collectionBranchRoutes(nested: wishlistRoutes)` | `/collection` |
| 4 | Hồ sơ | `person_outline` / `person` | `profileBranchRoutes(nested: socialRoutes)` **+ `battlepassBranchRoutes` + `settingsBranchRoutes`** | `/profile` (first route of the branch) |

Community stays at index 2, so `test/app/shell_test.dart` "`/community` is the third branch" keeps its expectation.

Add an `AppTab` enum in `lib/app/shell.dart`, so no code hard-codes a branch index:

```dart
enum AppTab {
  home(HomeRoutes.root), store(StoreRoutes.root), community(CommunityRoutes.root),
  collection(CollectionRoutes.root), profile(ProfileRoutes.root);
  const AppTab(this.root);
  final String root;
}
```

### 2.2 `lib/app/router.dart`

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, shell) => AppShell(navigationShell: shell),
  branches: [
    StatefulShellBranch(routes: homeBranchRoutes),                               // 0
    StatefulShellBranch(routes: storeBranchRoutes),                              // 1
    StatefulShellBranch(routes: communityBranchRoutes),                          // 2
    StatefulShellBranch(routes: collectionBranchRoutes(nested: wishlistRoutes)), // 3
    StatefulShellBranch(                                                         // 4
      // The first GoRoute is the branch's initial location: /profile.
      routes: [
        ...profileBranchRoutes(nested: socialRoutes),
        ...battlepassBranchRoutes, // /battlepass, /battlepass/rewards   (unchanged)
        ...settingsBranchRoutes,   // /settings, /settings/log, /settings/about[/<doc>] (unchanged)
      ],
    ),
  ],
),
```

Other changes in the router:

- `appRedirect`: signed in, `/` and `/welcome` go to `HomeRoutes.root`. The signed-out rules are unchanged.
- `createAppRouter({… String initialLocation = HomeRoutes.root …})`.
- The error page's "Về trang chính" calls `context.go('/')`.
- `lib/core/auth/login_screen.dart:225` changes `context.go('/store')` to `context.go('/')`.

**Push across branches (expected go_router 18 behavior, confirmed by test R-3).** A `context.push('/battlepass')` from the Home tab adds the page to the **Home branch's** navigator. go_router's `RouteMatchList.push` merges the imperative match into the current `ShellRouteMatch`, which keeps the current branch's navigator key. So Home stays selected and Back returns to Home.

**If R-3 shows otherwise,** add Home-branch alias routes `/home/battlepass` and `/home/settings` that build the same screens. No other part of this spec changes.

### 2.3 `/home` route: new file `lib/features/home/home_routes.dart`

```dart
abstract final class HomeRoutes {
  static const root = '/home';
  static const focusParam = 'focus';
  /// `/home?focus=battlepass` scrolls to (and briefly highlights) a card.
  static String focus(HomeCardId card) => '$root?$focusParam=${card.storageId}';
}

List<RouteBase> get homeBranchRoutes => [
  GoRoute(
    path: HomeRoutes.root,
    builder: (context, state) => HomeScreen(
      focus: HomeCardId.tryParse(state.uri.queryParameters[HomeRoutes.focusParam]),
      linkNonce: state.uri.queryParameters[AppConstants.linkNonceParam],
    ),
  ),
];
```

### 2.4 Notification and deep links

**Current payloads and where they land after the change:**

| Payload | Emitted by | Lands on |
|---|---|---|
| `/store?account=<p>` | store-reset reminder (`store_reset_reminder.dart`) | Cửa hàng tab (branch 1); account switched first |
| `/store?segment=nightmarket&account=<p>` | "Chợ Đêm đã mở!" (`wishlist_check.dart`) | Store, Night Market segment |
| `/collection/wishlist?skin=<s>&account=<p>`, `/collection/wishlist?account=<p>` | wishlist alerts (`wishlist_alerts.dart`) | Collection → Wishlist (skin sheet opens) |
| `/settings` | "Cần đăng nhập lại": `session_keep_alive.dart` (literal) and `wishlist_check.dart` (`SettingsRoutes.root`) | **Hồ sơ tab with the stack [Hồ sơ, Cài đặt]**. Back goes to Hồ sơ. |
| malformed or external payload | – | `/`, then redirected to `/home` (was `/store`) |
| (future) `/home?focus=<card>&account=<p>` | e.g. RR or Battle Pass nudges | Home, scrolled to that card |

**Changes in `lib/app/deep_links.dart`:**

```dart
/// Pages the Profile branch hosts without being children of /profile.
const kProfileHostedRoots = [BattlePassRoutes.root, SettingsRoutes.root];

@immutable
class LinkNavigation {
  const LinkNavigation(this.go, {this.push});
  final String go;      // location to `go` to (switches tab, resets that branch)
  final String? push;   // then pushed on top, so Back has somewhere to go
}

/// Pure (unit-tested).
LinkNavigation planLinkNavigation(String location) {
  final path = Uri.tryParse(location)?.path ?? '';
  final hosted = kProfileHostedRoots.any((r) => path == r || path.startsWith('$r/'));
  return hosted ? LinkNavigation(ProfileRoutes.root, push: location) : LinkNavigation(location);
}

/// Opens a parsed link (called by ValVnApp after the optional account switch).
void openAppLink(GoRouter router, DeepLink link) {
  final plan = planLinkNavigation(link.location);
  router.go(plan.go);
  if (plan.push case final child?) {
    // After the Profile page is built; `push` uses the current configuration as its base.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(router.push<void>(child)));
  }
}
```

- `parseDeepLink`'s fallback changes from `'/store'` to `'/'`.
- `ValVnApp._openDeepLink` (`lib/app/app.dart`) keeps its account switch and then calls `openAppLink(ref.read(routerProvider), link)`.
- The `nav` nonce stays in the pushed location. Routes ignore unknown query parameters.

### 2.5 Profile entry points (profile agent)

`lib/features/profile/ui/profile_screen.dart`:

- **Header ⚙.** Add `TabPageScaffold(actions: [const SettingsGearButton()], …)`.
  - `SettingsGearButton` is a **new** public widget in `lib/features/settings/ui/settings_gear_button.dart`.
  - It is an `IconButton(icon: Icon(Icons.settings_outlined), tooltip: CommonStrings.tabSettings, onPressed: () => context.push(SettingsRoutes.root))` with a 48 dp target.
  - Home uses the same widget.
- **"Battle Pass" row.** Add it to the existing group card with "Tổ đội & hàng chờ" and "Bạn bè & trò chuyện":
  - `ProfileNavRow(icon: Icons.military_tech_outlined, title: CommonStrings.tabBattlePass, subtitle: BattlePassProgressSubtitle(puuid: puuid), onTap: () => context.push(BattlePassRoutes.root))`.
  - `BattlePassProgressSubtitle` is a **new** public widget owned by the battlepass feature, in `lib/features/battlepass/ui/battlepass_entry.dart`.
  - It renders `BattlePassStrings.levelOf(level, count)` and `daysLeft(n)` from `battlePassOverviewProvider(puuid)`, or nothing while loading or on error.
- `BattlePassScreen` and `SettingsScreen` need no code change. `TabPageScaffold`'s `SliverAppBar` shows a back arrow when the route can pop. Only update the doc comments ("TAB 2"/"TAB 5" become "hosted by Hồ sơ").

### 2.6 Store-reset reminder host (store agent; required)

**New** file `lib/features/store/store_reset_reminder_host.dart`:

```dart
/// Keeps the "Cửa hàng đã làm mới" reminder scheduled for the active account
/// whether or not the Store tab was ever built (Home is now the landing tab).
class StoreResetReminderHost extends ConsumerStatefulWidget {
  const StoreResetReminderHost({super.key, required this.child});
  final Widget child;
}
// build():
//   on    = appSettingsProvider.select((s) => s.storeResetNotifications)
//   puuid = activeAccountProvider.select((a) => a == null || a.needsLogin ? null : a.puuid)
//   if (on && puuid != null) ref.listen(storefrontProvider(puuid), (_, next) {
//     final s = next.value; if (s == null || identical(s, _last)) return; _last = s;
//     post-frame: scheduleStoreResetReminder(notifications, account:, store: s, now: clock.now())
//   }, fireImmediately: true);
```

- Mount it in `AppShell`: `body: LiveGameOverlayHost(child: StoreResetReminderHost(child: navigationShell))`.
- Remove the reminder part of `StoreScreen._afterBuild`: `_remindedFor` and `remindersOn`. Keep "mark Night Market seen" and "content-miss report".
- The listener keeps `storefrontProvider(active)` alive only while the setting is on. The provider refetches at each reset (`scheduleProviderRefresh`), so the next reminder is always rescheduled.

### 2.7 `AppShell` and `FloatingNavBar`

- `lib/app/shell.dart`:
  - Five `_destinations` in the §2.1 order.
  - `compactWidth = 360.0`. Below 360 dp, only the selected tab shows its label.
  - Pass `emphasizedIndex: AppTab.community.index`.
  - Update the doc comment.
- `lib/core/ui/floating_nav_bar.dart` gets a **new** optional `int? emphasizedIndex`:
  - The emphasized item draws its icon inside a 32 dp circle: `primary` at 16% alpha with a primary icon when unselected, solid `primary` with a white icon when selected.
  - Label and semantics are unchanged.
  - The icon-on-fill contrast must be ≥ 3:1 (a graphic object).
- **Should (P1): a leading-edge rail for wide screens.**
  - When `width >= 840`, or on a landscape phone (`height < 480`), render the same destinations as a vertical floating capsule on the leading edge (`FloatingNavRail`), instead of the bottom bar.
  - Same `selectedIndex` / `onDestinationSelected` contract.
  - May ship after Home. Home's layout (§9) already works with either bar.
- **Optional (P2):** re-tapping the Home tab while it is at its root scrolls Home to the top. `AppShell` emits `tabReselectedProvider`, and `HomeScreen` listens.

### 2.8 Other call sites and docs

- `CommonStrings`: add `tabHome = 'Trang chủ'`. Keep `tabBattlePass` and `tabSettings`; they are now the row title and the gear tooltip.
- `docs/ARCHITECTURE.md`:
  - §1: the tree gets `features/home/`; tabs are renumbered.
  - §2: new owner "Home" for `lib/features/home/`, plus the new public entry points `SettingsGearButton`, `BattlePassProgressSubtitle`, `StoreResetReminderHost`, `matchingLfgPreviewProvider` and `trendingSkinsProvider`, plus the §3.6 read-only symbols.
  - §4 routing table: branches 0–4; Profile hosts `/battlepass` and `/settings`; `/home[?focus=]`; redirect `/` → `/home`.
- `docs/PROGRESS.md`: add a line under "Đã xong" once this lands.

---

## 3. Home architecture

### 3.1 Files (all **new**)

```
lib/features/home/
├─ home_routes.dart                  HomeRoutes, homeBranchRoutes
├─ home_strings.dart                 HomeStrings (§10)
├─ data/
│  ├─ home_card.dart                 HomeCardId, kDefaultHomeOrder, HomeCardPresence, HomeArrangement, arrangeHomeCards()
│  ├─ home_layout.dart               HomeLayout (JSON, merge rules, move/hide/reset)
│  ├─ home_live.dart                 HomeLiveSnapshot, homeLiveSnapshotOf()
│  ├─ home_store.dart                HomeStoreSummary, HomeSkinOffer, HomeNightMarket, buildHomeStoreSummary()
│  ├─ home_rank.dart                 HomeRankSnapshot, RankedStreak, rankedStreakOf(), buildHomeRankSnapshot()
│  ├─ home_battlepass.dart           HomeBpSnapshot, buildHomeBpSnapshot()
│  ├─ home_friends.dart              HomeFriendsSnapshot, playingFriendsOf()
│  ├─ home_community.dart            HomeCommunitySnapshot
│  ├─ home_accounts.dart             OtherAccountSummary, buildOtherAccountSummaries()
│  └─ home_status.dart               HomeServerStatus, HomeStatusNotice, buildHomeServerStatus()
├─ providers/
│  ├─ home_layout_provider.dart      homeLayoutProvider, homeFriendsConsentProvider
│  ├─ home_card_providers.dart       home*SnapshotProvider / homeStoreSummaryProvider / homeOtherAccountsProvider / homeServerStatusProvider
│  ├─ home_arrangement.dart          homeCardPresenceProvider, homeStartupGateProvider, homeArrangementProvider
│  └─ home_refresh.dart              refreshHome(), kHome* constants
└─ ui/
   ├─ home_screen.dart               HomeScreen
   ├─ home_card_frame.dart           HomeCardFrame, HomeCardSkeleton, HomeCardPoller, HomeCardMeta (title/description/icon)
   ├─ home_columns.dart              HomeColumns (adaptive, hinge-aware)
   ├─ customize_home_sheet.dart      showCustomizeHomeSheet()
   ├─ server_status_sheet.dart       showServerStatusSheet()
   └─ cards/  live_home_card.dart · store_home_card.dart · rank_home_card.dart · battlepass_home_card.dart
             friends_home_card.dart · community_home_card.dart · other_accounts_home_card.dart · server_status_home_card.dart
test/features/home/…                 (§12)
```

### 3.2 Card catalogue: `data/home_card.dart`

```dart
enum HomeCardId {
  live('live'), store('store'), rank('rank'), battlePass('battlepass'),
  friends('friends'), community('community'), otherAccounts('accounts'), serverStatus('status');

  const HomeCardId(this.storageId);
  /// Persisted in Prefs and used in `?focus=`. Never rename.
  final String storageId;
  static HomeCardId? tryParse(String? v) => values.where((c) => c.storageId == v?.trim()).firstOrNull;

  /// Nearly always has data: shows a skeleton while loading.
  bool get isCore => this == store || this == rank || this == battlePass;
  /// Needs the active account's Riot session (hidden while it needs login).
  bool get needsRiotSession => switch (this) { live || store || rank || battlePass || friends => true, _ => false };
  /// Its data is not watched before homeStartupGateProvider opens (§3.4).
  bool get isDeferred => this == friends || this == community || this == otherAccounts;
}

/// IA "Trang chủ" order 1…8.
const kDefaultHomeOrder = HomeCardId.values;
```

### 3.3 Presence, pinning and arrangement

```dart
enum HomeCardPresence { hidden, loading, visible }
typedef HomeCardKey = ({String puuid, HomeCardId card});

@immutable
class HomeArrangement {
  const HomeArrangement({this.pinned = const [], this.flow = const [], this.allUserHidden = false});
  final List<HomeCardId> pinned;   // full width, above the columns
  final List<HomeCardId> flow;     // user order
  final bool allUserHidden;        // every card switched off in "Tùy chỉnh"
  bool get isEmpty => pinned.isEmpty && flow.isEmpty;
}

/// Pure. [presenceOf] is only called for cards the user did not hide, so hidden
/// cards never watch their data.
HomeArrangement arrangeHomeCards({
  required HomeLayout layout,
  required HomeCardPresence Function(HomeCardId) presenceOf,
  required bool liveActive,       // queueing / pregame / ingame
  required bool statusBlocking,   // in-progress maintenance or critical incident, active region
});
// shown  = layout.order where !hidden && presenceOf(id) != hidden
// pinned = [if statusBlocking && shown∋status: status, if liveActive && shown∋live: live]
// flow   = shown − pinned
```

Providers, in `providers/home_arrangement.dart`:

- `homeCardPresenceProvider`: `Provider.autoDispose.family<HomeCardPresence, HomeCardKey>`. It maps each card's view-model (§5) with this rule:
  - **value** present: `null` means hidden, otherwise visible.
  - **error** with no value: visible (the card shows a compact error) if `card.isCore` and the status is not blocking. Otherwise hidden.
  - **loading** with no value: `loading` if `card.isCore`, otherwise hidden.
- `homeStartupGateProvider`: `NotifierProvider.autoDispose<HomeStartupGate, bool>` (§3.4).
- `homeArrangementProvider`: `Provider.autoDispose.family<HomeArrangement, String /*puuid*/>`. It watches `homeLayoutProvider`, the gate, the active account's `needsLogin`, and the presences of enabled cards, then calls `arrangeHomeCards`.

**Per-card presence rules:**

| Card | Hidden when | Loading (skeleton) | Pinned when |
|---|---|---|---|
| live | needs login; no state; phase `notRunning` or `lobby` | never | phase ∈ {queueing, pregame, ingame} |
| store | needs login; no daily offers and no Night Market; blocking status and no data | yes | – |
| rank | needs login; never ranked (§5.3) | yes | – |
| battlePass | needs login; no current pass; pass complete and no active event pass | yes | – |
| friends | needs login; consent `false`; consent `true` but loading, error, or nobody playing | never. Consent `null` shows the prompt immediately after the gate opens. | – |
| community | community disabled; loading; both lists empty; error | never | – |
| otherAccounts | fewer than 2 accounts | never | – |
| serverStatus | no notice in any account region | never | blocking in the active region |

### 3.4 Startup staging (request budget)

- `homeStartupGateProvider` opens at whichever comes first:
  - every enabled core card has left `loading`, or
  - `kHomeStartupDelay` = 1.5 s after Home's first frame.
- Deferred cards (friends, community, other accounts) are `hidden` and **do not watch their data** until the gate opens.
- Live and server status are not deferred:
  - live is already polled by the overlay;
  - status is one CDN GET per region and explains failures.
- Expected launch traffic (warm session):
  - by the overlay: G-1 (plus G-2/G-3 or G-12/G-13);
  - core cards: P-1 storefront, P-2 wallet, P-11 MMR, P-12 first page, P-15 contracts, P-3 premium contract, P-16 daily ticket;
  - X-1 per region.
- After the gate:
  - `GET /v1/skins/top`;
  - `GET /v1/lfg`, only when a community session is already cached;
  - G-1 for at most 3 displayed alts;
  - XMPP, only after opt-in.
- The existing limiter (bursts of 8, 2 req/s, ≤ 3 in flight per host) is enough.
- `dailyRrProvider` is deliberately **not** watched. Its `rrHistorySyncProvider` backfills up to 5 P-12 pages on a fresh install (§5.3).

### 3.5 Account state policy

- **Active account needs login** (`activeAccountProvider.select((a) => a?.needsLogin)`):
  - One banner under the app bar: `CommonStrings.errorNeedsLoginTitle`, then `HomeStrings.needsLoginBody(riotId)`, then a button "Đăng nhập lại" that pushes `AuthRoutes.loginPath(reauthPuuid: puuid)`.
  - Cards with `needsRiotSession` are hidden, so there are no five identical errors.
  - Community, other accounts and server status still render.
- **Blocking maintenance** (active region):
  - The status card is pinned.
  - Core cards with no data are hidden, since their errors would repeat the notice.
  - Cards with cached data stay visible, with "Cập nhật lúc hh:mm".
- **Offline or transient errors:**
  - `Storefront.isFromCache` and `PlayerContracts.isFromCache` show cached data plus a footnote `CommonStrings.updatedAt(formatTime(receivedAt))`.
  - Without a cache, the card body shows `ErrorView(compact: true, onRetry: …)` with "Thử lại".
- **Account switch:**
  - `HomeScreen` watches only `activeAccountProvider.select((a) => a?.puuid)` and `needsLogin`. It must not watch the whole `Account`: rank, level and card writes would rebuild all of Home.
  - The card list is keyed by PUUID, and the scroll jumps to the top.
  - Every data provider is a PUUID family, so no stale data can show.
- **No active account:** `EmptyView(message: CommonStrings.errorNoAccount)`. The router normally redirects to `/welcome` first.

### 3.6 Reused providers and helpers (read-only imports; freeze in ARCHITECTURE §2)

| Symbol | File | Card |
|---|---|---|
| `liveGameProvider`, `LiveGameController.refresh()`, `liveScoreEnabledProvider` | `lib/features/live_game/providers/live_game_providers.dart` | live |
| `LivePhase`, `LiveGameState`, `LiveMatch` | `lib/features/live_game/data/live_game_models.dart` | live |
| `currentGameStatusText`, `liveScoreOf`, `liveModeLabel`, `liveMapName` | `lib/features/live_game/data/live_game_logic.dart` | live |
| `TickingBuilder`, `LiveRefreshRing` | `lib/features/live_game/ui/live_widgets.dart` | live |
| `showLiveGameSheet` | `lib/features/live_game/live_game_sheet.dart` | live |
| `ownPresenceProvider`, `friendsProvider`, `xmppServiceProvider`, `xmppConnectionProvider`, `appForegroundProvider`, `kXmppLinger` | `lib/core/xmpp/xmpp_providers.dart` | live, friends, pollers |
| `Friend`, `FriendsView`, `FriendActivity` | `lib/core/xmpp/friends.dart` | friends |
| `isPlaying` | `lib/features/social/data/friend_sections.dart` | friends |
| `presenceStatus` | `lib/features/social/data/friend_status.dart` | friends |
| `storefrontProvider`, `walletProvider`, `Storefront`, `DailyOffer`, `NightMarket`, `Wallet` | `lib/core/domain/economy/storefront.dart` | store, accounts |
| `wishlistHitsProvider`, `findWishlistHits`, `WishlistHit`, `WishlistPlace`, `wishlistContains` | `lib/core/domain/economy/wishlist.dart` | store, accounts, community |
| `wishlistProvider` | `lib/core/wishlist/wishlist_store.dart` | store, accounts, community |
| `nightMarketSeenProvider`, `hasUnseenOffers` | `lib/features/store/providers/night_market_seen.dart` | store |
| `StoreRoutes`, `StoreSegment` | `lib/features/store/store_routes.dart`, `lib/features/store/ui/store_screen.dart` | store, accounts |
| `showSkinDetailSheet`, `SkinDetailMode` | `lib/features/skin_detail/skin_detail_sheet.dart` | store, community |
| `savedStorefrontProvider`, `storefrontSellsSkin` | `lib/features/skin_detail/providers/skin_availability.dart`. **Move** to **new** `lib/core/domain/economy/saved_storefront.dart`, exported by `economy.dart`; skin_detail re-imports. | accounts |
| `rankSummaryProvider`, `rrHistoryProvider`, `competitiveUpdatesProvider`, `mmrProvider`, `rankUpEstimateProvider`, `RankUpQuery` | `lib/core/domain/competitive/rank.dart` | rank |
| `RankInfo`, `RankSummary`, `groupDailyRr`, `DailyRr`, `kRankUpMaxTier` | `lib/core/domain/competitive/rank_calc.dart` | rank |
| `dailyRrOn` | `lib/features/profile/data/rr_trend.dart`. **Move** to `rank_calc.dart`; profile re-imports. | rank |
| `CompetitiveUpdate`, `compareUpdatesNewestFirst` / `MatchOutcome` | `rank_models.dart` / `match_models.dart` (core competitive) | rank |
| `battlePassOverviewProvider`, `dailyTicketProvider`, `playerContractsProvider`, `refreshBattlePass`, `retryBattlePass` | `lib/features/battlepass/providers/battlepass_providers.dart` | battlePass |
| `xpPaceOf`, `XpPace` | `lib/features/battlepass/data/xp_pace.dart` | battlePass |
| `BattlePassOverview`, `PassProgress`, `WeeklyMissions`, `WeeklyMissionView`, `EventPassInfo` / `DailyTicket` | `battlepass/data/battlepass_models.dart` / `daily_ticket.dart` | battlePass |
| `matchingLfgPreviewProvider`, `trendingSkinsProvider` (**new**, §11), `communityEnabledProvider`, `CommunityRoutes`, `CommunitySection`, `CommunityStrings.modeLabel`, `LfgPost`, `TopSkin` | `lib/features/community/…` | community |
| `accountsProvider`, `activePuuidProvider`, `activeAccountProvider` | `lib/core/accounts/account_providers.dart` | all |
| `accountActivityProvider`, `AccountActivity` | `lib/core/accounts/account_status.dart` | accounts |
| `AccountChip`, `AccountAvatar`, `showAccountSwitcherSheet` | `lib/core/accounts/account_widgets.dart` | header, accounts |
| `platformStatusProvider`, `PlatformStatus`, `StatusNotice` | `lib/core/riot/platform_status.dart` | status |
| `contentProvider`, `contentMissReporterProvider`, `ContentRetry.retryContentIfFailed` | `lib/core/content/content_repository.dart` | all |
| `ProfileRoutes`, `SocialRoutes`, `BattlePassRoutes`, `SettingsRoutes`, `AuthRoutes` | the `*_routes.dart` files | taps |

---

## 4. Header and scaffold (`ui/home_screen.dart`)

**`HomeScreen({HomeCardId? focus, String? linkNonce})` is a `ConsumerStatefulWidget`. It owns:**

- a `ScrollController`;
- one `GlobalKey` per card, used for `focus`;
- the startup-gate timer;
- a scroll anchor (below).

**Scaffold:**

```dart
TabPageScaffold(
  title: HomeStrings.title,
  showAccountChip: false,
  showMaintenanceBanner: false, // the server-status card replaces the banner (no duplicate)
  controller: _scroll,          // NEW optional TabPageScaffold param (core), via PrimaryScrollController so the iOS status-bar tap still scrolls to top
  actions: [AccountChip(showName: MediaQuery.sizeOf(context).width >= 360), const SettingsGearButton()],
  onRefresh: () => refreshHome(ref, puuid: puuid, shown: arrangement),
  slivers: [
    if (needsLogin) _NeedsLoginBanner(...),
    _PinnedCards(arrangement.pinned),                       // full width
    HomeColumns(cards: arrangement.flow, ...),              // 1 column → SliverList; ≥2 → columns (§9)
    if (!arrangement.isEmpty) _CustomizeButton(),           // TextButton.icon(Icons.tune_rounded, HomeStrings.customize)
    if (arrangement.allUserHidden) _AllHiddenState(),       // EmptyView + "Tùy chỉnh Trang chủ"
    else if (arrangement.isEmpty) _QuietState(),            // EmptyView(HomeStrings.quietTitle / quietBody)
    const SliverToBoxAdapter(child: SizedBox(height: 32)),
  ],
)
```

- **Header content:**
  - title "Trang chủ";
  - the account chip (avatar only below 360 dp), which opens the switcher as today;
  - the ⚙ button, which pushes `/settings` on the Home stack.
- **Scroll anchor.** A pinned card can appear or disappear while the user is scrolled down (`offset > 0`). In that case, measure the pinned region's height change after layout and `jumpTo(offset + delta)` in a post-frame callback. The visible cards do not move.
- **Focus** (`/home?focus=…`):
  - After the first frame where that card is present, call `Scrollable.ensureVisible` with alignment 0.1 and a duration of `ValMotion.medium` (zero with reduced motion).
  - Add a 1 s accent-border pulse (none with reduced motion).
  - Announce `HomeStrings.focused(title)`.
  - A new `linkNonce` re-applies the focus, the same pattern as `StoreScreen.didUpdateWidget`.
  - If the focused card is hidden (by the user or for lack of data), the scroll stays at the top and nothing is announced.
- **Card frame** (`HomeCardFrame`):
  - `ValCard` (radius 16, `s1`, 16 dp padding, 12 dp between cards).
  - A header row: 24 dp outline icon, title as a heading, an optional trailing widget (countdown pill, refresh ring or chevron), and an overflow button (48 dp, `Icons.more_horiz`, tooltip `HomeStrings.moreActions(title)`).
  - The overflow button opens `showActionSheet`: "Ẩn thẻ này" and "Tùy chỉnh Trang chủ…".
  - `onTap` of the whole card is the primary destination. Inner buttons are the secondary destinations.

---

## 5. Cards

Every card below lists: data · derived model (pure, unit-tested) · visible when · loading · layout · taps · refresh · accessibility notes · what makes it smarter.

### 5.1 Trận hiện tại (`cards/live_home_card.dart`)

**Data.**
- `liveGameProvider(puuid)`. Home only **watches** it; the poller is `LiveGameOverlayHost` (20 s, 4 s while the sheet is open, paused in the background).
- `contentProvider`: map splash and name, agent portrait, queue name.
- `liveScoreEnabledProvider` and `ownPresenceProvider`: watched **only** in `ingame` with live score on, the same rule as `CurrentGameCard`.

**Model.**
- `homeLiveSnapshotProvider(puuid)`: `Provider.autoDispose.family<HomeLiveSnapshot?, String>`, built by `homeLiveSnapshotOf(LiveGameState, ContentDb, {required String self})`.
- `HomeLiveSnapshot { LivePhase phase, String? mapName, String? mapSplash, String modeLabel, DateTime? queueEntryTime, DateTime? phaseEndsAt, String? myAgentId, bool myAgentLocked }`.
- The snapshot is `null` unless the phase is queueing, pregame or ingame.

**Visible when.** The phase is active and the account does not need login. It is **pinned** (§3.3). A poll error keeps the last state visible, because the controller keeps the previous value.

**Loading.** None. The card is hidden until the first poll says the player is in a match or a queue.

**Layout.** About 128 dp: map splash with a teal→background scrim (DESIGN "Trận hiện tại"), a status pill, the map name in Anton, and the mode.
- **Queueing:** radar icon, then "Đang tìm trận · 01:32". Only the timer text ticks, through `TickingBuilder` at 1 s.
- **Pregame:** amber pill `LiveGameStrings.statusAgentSelect`, the player's agent portrait with `youHover` / `youLocked(agent)`, and `CountdownText(expiresAt: phaseEndsAt, builder: LiveGameStrings.timeLeft)`.
- **Ingame:** green pill `statusInProgress`. The score "8 – 4" in Anton appears only when `liveScoreOf(presence, now:)` is non-null. It carries "Đội bạn"/"Đội địch" labels, so it does not rely on color alone.
- **Trailing:** `LiveRefreshRing(puuid: puuid, size: 36)` (tap to poll now) and a chevron.

**Taps.** The card opens `showLiveGameSheet(context)`. Home has no lock or quit button; those stay in the sheet, behind confirmations.

**Refresh.** Pull-to-refresh calls `ref.read(liveGameProvider(puuid).notifier).refresh()`. Home adds no timer.

**Accessibility.**
- The container label is `currentGameStatusText(...)`.
- The phase line gets `Semantics(liveRegion: true)` (TalkBack). On iOS, an announcement fires once per phase change.
- Ticking timers are wrapped in `ExcludeSemantics`, with a coarse static value (`formatDurationCoarse`), so there is no announcement every second.

**Smarter.** ValBuddy shows a static "Current Game: Not in a game" row inside Profile. This card exists only when relevant and jumps to the top. It shows the phase-specific facts (queue timer, agent-select countdown with your pick, live score) and costs zero extra requests.

### 5.2 Cửa hàng hôm nay (`cards/store_home_card.dart`)

**Data.**
- `storefrontProvider(puuid)` (required).
- `wishlistHitsProvider(puuid)` and `walletProvider(puuid)` (optional).
- `nightMarketSeenProvider(puuid)` + `hasUnseenOffers`.
- `contentProvider`: `skinByLevelUuid`, `contentTier`.

**Model.**
- `homeStoreSummaryProvider(puuid)`: `Provider.autoDispose.family<AsyncValue<HomeStoreSummary?>, String>`. It returns `storefront.whenData((s) => buildHomeStoreSummary(s, db:, hits:, wallet:, nightMarketSeen:, now:))`.
- The summary contains:
  - `List<HomeSkinOffer> daily` (≤ 4). Each offer has `levelUuid`, `WeaponSkin? skin`, `int? vp`, `tierUuid`, `inWishlist`.
  - `DateTime? resetsAt`, `int totalVp`, `int? walletVp`, `int affordableCount`.
  - `List<WishlistHit> hits`: live only, one per skin, ordered daily → Night Market → bundle.
  - `HomeNightMarket? nightMarket { int count; DateTime? expiresAt; NightMarketOffer? best; bool unseen }`. `best` is the highest `discountPercent`; ties go to the higher savings, then to the name.
  - `bool isFromCache`, `DateTime receivedAt`.
  - `bool hasContentMiss`: an offered level is not in the content.
- The summary is `null` when there are no daily offers and no Night Market.

**Visible when.** §3.3.

**Loading.** Skeleton with the same structure: a title line, four square tiles and a pill.

**Layout.**
- **Header:** "Cửa hàng hôm nay" and `CountdownPill(expiresAt: resetsAt, period: Duration(days: 1), builder: HomeStrings.storeResetsIn, dense: true)`.
- **Wishlist banner** (only when there are hits):
  - ♥ icon + `HomeStrings.storeWishlistHit`, plus `hit.placeLabel(db)` for the first hit.
  - With several hits, `HomeStrings.storeWishlistHits(n)`.
- **Skin tiles:** four compact `HomeSkinTile`s (image, rarity edge with the `TierTag` diamond, `CurrencyAmount.vp(n)`, and a ♥ when wishlisted). They sit in a row of four; at text scale ≥ 1.3 or content width < 340 they become a 2×2 grid.
- **Footer:** `HomeStrings.storeTotal(formatVp(totalVp))`. When the wallet is known, add ` · ` + `HomeStrings.storeWallet(formatVp(vp), affordableCount)`, e.g. "Ví 2.440 VP · đủ mua 1 skin".
- **Night Market row** (when it runs):
  - moon icon, "Chợ Đêm", `CountdownText` "Còn 4 ngày …".
  - While `unseen`: `HomeStrings.nightMarketWaiting(count)` ("{n} ưu đãi đang chờ bạn lật") with a red "Mới" dot. The best deal is **not revealed**, so the surprise is not spoiled.
  - After the user opened the Night Market segment once: the best deal, "−38% · {skin} · 1.100 VP", with the base price struck through.
- **Offline:** footnote "Cập nhật lúc …".

**Taps.**
- The card or header does `context.go(StoreRoutes.segment(StoreSegment.daily))`, which switches tab.
- A tile opens `showSkinDetailSheet(context, skinOrLevelUuid: levelUuid, mode: SkinDetailMode.store)`.
- The wishlist banner: daily or Night Market does `context.go(StoreRoutes.segment(daily|nightMarket))`; a bundle hit does `context.push(StoreRoutes.bundle(hit.bundleId!))`, or `go(StoreRoutes.segment(bundles))` when there is no id.
- The Night Market row does `context.go(StoreRoutes.segment(StoreSegment.nightMarket))`. The Store screen marks the offers as seen.

**Refresh.**
- **Automatic:** `storefrontProvider` refetches at its earliest deadline + 3 s. When a countdown hits 0 (`onExpired`), the card shows `HomeStrings.storeRefreshing` until new data arrives. There is no manual invalidate.
- **Pull:** invalidate `walletProvider` and `storefrontProvider`.
- Home adds no timers.

**Side effects.**
- **Allowed:** if `hasContentMiss`, call `contentMissReporterProvider.report()` post-frame, once per storefront. It is rate-limited.
- **Never:** mark the Night Market as seen, or schedule reminders (§2.6 does that).

**Smarter.** It answers "Is there anything I want today?" on the first screen:
- wishlist matches across daily, Night Market and bundles, with a one-tap jump to the exact place;
- whether the wallet can afford them;
- a Night Market summary that respects the "flip the cards" surprise;
- skin preview and video from Home, without switching tab.

ValBuddy shows four large cards only inside the Store tab.

### 5.3 Rank & phong độ (`cards/rank_home_card.dart`)

**Data.**
- `rankSummaryProvider(puuid)` (required). Its existing side effect caches `rankTier` on the `Account` for the switcher and LFG.
- `rrHistoryProvider(puuid)`: local rows plus outcomes.
- `rankUpEstimateProvider((puuid: puuid, targetTier: null))`. This also loads `competitiveUpdatesProvider(puuid)`'s first page, which merges today's rows into the history.
- `contentProvider`.
- **Not** `dailyRrProvider`. It is avoided on purpose, because it starts `rrHistorySyncProvider` backfill (up to 5 pages). Today's rows are always in the first page, so the numbers match Profile's "RR theo ngày", which reads the same `rrHistoryProvider`.

**Model.**
- `homeRankSnapshotProvider(puuid)`: `AsyncValue<HomeRankSnapshot?>`, built by `buildHomeRankSnapshot(summary, history:, estimate:, db:, now:)`.
- `HomeRankSnapshot` fields:
  - `RankInfo current`;
  - `double? progress` (`rr/100`, only below Immortal: `normalizedTier < kRankUpMaxTier`);
  - `int? rrToNext`;
  - `DailyRr? today` (`dailyRrOn(groupDailyRr(rows, outcomes:), now)`);
  - `DailyRr? lastDay` (the newest day within `kHomeRecentRrDays` = 7, only when `today` is null);
  - `RankedStreak? streak`;
  - `int? matchesToNext`;
  - `String? nextTierName` (`RankInfo.resolve(db, tier: current.normalizedTier + 1, actUuid: current.actUuid).tierName`, as in Profile's `_RankUpHint`);
  - `int? leaderboard`;
  - `RankInfo? previousAct` (the newest act other than the current one that has games).
- `rankedStreakOf(RrHistory h, {required DateTime now}) → RankedStreak? {StreakKind kind; int count}`:
  - Walk the rows newest first. The outcome is `h.outcomes[matchId]`, or else the sign of `rrEarned`.
  - A draw, a remake (0 RR) or an unknown outcome ends the walk, the same semantics as Profile's `RecentForm`.
  - Return `null` when `count < 2`, or when the newest row is older than `kHomeStreakMaxAge` = 7 days.
- The snapshot is `null` ("never ranked") when `current.isUnranked && !current.isPlacement && summary.peak == null && summary.acts.isEmpty`.

**Loading.** Skeleton: a 56 dp circle, two lines and a bar.

**Layout.**
- Rank icon (56 dp) and tier name, colored with `legibleAccent(context, current.color, min: 3.5)`.
- "74 RR" in Anton 22, with a `ValProgressBar(height: 4, semanticsLabel: HomeStrings.rankToNext(26))`.
- **Chips row:**
  - Today: ▲ or ▼ icon + `formatSignedRr(net)` + `HomeStrings.winsLosses(w, l, d)`. When there is nothing today, `HomeStrings.rrOnDay(formatDayHeader(lastDay.date, now), …)`; with no recent day either, `HomeStrings.noRankedToday`.
  - Streak: `StatusPill` with `Icons.local_fire_department_rounded` or `Icons.trending_down_rounded` and `HomeStrings.winStreak(n)` / `lossStreak(n)`.
- **Estimate row:** `HomeStrings.matchesToRankUp(n, nextTierName)` + ›. It shows only when `n > 0`.
- **Variants:**
  - Placements: `current.placementText` instead of RR and progress.
  - Unranked this act but ranked before: "Chưa xếp hạng" · `HomeStrings.previousAct(rank)`.
  - Immortal and above: no bar and no estimate; `HomeStrings.leaderboard(pos)` when `leaderboard != null`.

**Taps.**
- The card does `context.go(ProfileRoutes.root)`.
- The today chip does `context.push(ProfileRoutes.dailyRr)`.
- The estimate row does `context.push(ProfileRoutes.rankUp)`.

**Refresh.**
- **Automatic:**
  - MMR is kept 3 min (`cacheFor`).
  - When a match ends, `LiveGameController._afterPoll` already invalidates `mmrProvider`, `rankSummaryProvider` and `competitiveUpdatesProvider`, so the card updates by itself.
  - The card schedules a one-shot timer to the next local midnight (`setState`) so "Hôm nay" rolls over.
- **Pull:** `ref.invalidate(competitiveUpdatesProvider(p))`, then `await ref.refresh(mmrProvider(p).future)`.

**Smarter.** ValBuddy shows current and peak rank on Profile only. This card shows:
- RR today, or the last session when you haven't played today;
- the ranked streak;
- the number of matches to the next tier at your recent form;
- the placements count;
- a self-update seconds after a match ends, with no tap.

### 5.4 Battle Pass (`cards/battlepass_home_card.dart`)

**Data.** `battlePassOverviewProvider(puuid)` (required), `dailyTicketProvider(puuid)` (optional), `xpPaceOf`, `clockProvider`.

**Model.**
- `homeBattlePassSnapshotProvider(puuid)`: `AsyncValue<HomeBpSnapshot?>`, built by `buildHomeBpSnapshot(overview, ticket:, now:)`.
- `HomeBpSnapshot` fields:
  - `PassProgress pass`;
  - `bool isEvent`, `String? eventName`;
  - `XpPace? pace` (`xpPaceOf(pass, endsAt, now)`);
  - `int? daysLeft`;
  - `List<WeeklyMissionView> nearlyDone`: incomplete missions sorted by `fraction` descending, then `xpGrant` descending, at most `kHomeMaxMissions` = 2;
  - `DateTime? missionsRefillAt`, `bool allMissionsDone`;
  - `int? checkpointsDone` (only when the ticket exists and has not expired);
  - `EventPassInfo? eventLine`;
  - `bool isFromCache`, `DateTime receivedAt`.
- Which pass is primary:
  - the current Battle Pass if it is incomplete;
  - otherwise the first active incomplete event pass (`isEvent = true`);
  - otherwise `null`, and the card is hidden.
- When the Battle Pass is primary and an active event pass is incomplete, that event pass becomes `eventLine`.

**Loading.** Skeleton: a title line, a bar and two mission lines.

**Layout.**
- **Header:** "Battle Pass" (or "Vé sự kiện · {name}") and a `BattlePassStrings.daysLeft(n)` pill.
- `BattlePassStrings.levelOf(a, b)` and a thin level bar (`pass.levelFraction`).
- `BattlePassStrings.xpPerDay(formatNumber(pace.xpPerDay))` with the caption `xpPerDayCaption`.
- Up to 2 mission rows: title or `unknownMission`, a bar, `missionProgress(p, t)`, and `xpReward` in red.
- **Footer:**
  - 4 `DiamondPip`s + `checkpointsDone(done, 4)`.
  - When all weekly missions are done: `BattlePassStrings.newMissionsIn(countdown)`.
- The event line, when present.

**Taps.**
- The card or a mission does `context.push(BattlePassRoutes.root)`, which stays in the Home stack.
- The event line does `context.push(BattlePassRoutes.rewardsFor(id))`.

**Refresh.**
- **Automatic:** 5 min TTL (`cacheFor`). When the mission-refill countdown expires (`onExpired`), `ref.invalidate(playerContractsProvider(p))`.
- **Pull:** `refreshBattlePass(ref, puuid)` (existing helper). "Thử lại" calls `retryBattlePass`.

**Smarter.**
- XP per day needed before the act ends.
- The mission closest to completion first.
- Automatic fallback to the event pass once the Battle Pass is done.
- Daily checkpoints at a glance.

ValBuddy needs its own tab for all of this.

### 5.5 Bạn bè đang chơi (`cards/friends_home_card.dart`)

**Privacy gate.**
- `homeFriendsConsentProvider`: `NotifierProvider<…, bool?>`, backed by the Prefs key `f.home.friendsLive`.
  - `null`: not asked yet.
  - `false`: declined, and the card is hidden.
  - `true`: allowed.
- Only with `true` does the card watch `friendsProvider`. That starts `xmppServiceProvider` for the active account while Home is visible and in the foreground. It lingers `kXmppLinger` (3 min) afterwards, then disconnects.
- Rationale: the chat sends `<presence/>`, so friends see the user online. PROGRESS.md already treats opening chat per visit as a cost.

**Data.** `friendsProvider`, `xmppConnectionProvider`, `isPlaying`, `presenceStatus`, `contentProvider` (card art `db.card(id)?.smallArt`, map names).

**Model.**
- `homeFriendsSnapshotProvider`: `Provider.autoDispose<AsyncValue<HomeFriendsSnapshot?>>`. It is not a family: chat always belongs to the active account.
- The snapshot comes from `playingFriendsOf(FriendsView, {int max = kHomeMaxPlayingFriends /*8*/})`: friends in a match, in agent select or in queue, in activity order, then by name.
- `HomeFriendsSnapshot { List<Friend> playing; int totalPlaying }`. It is `null` when nobody is playing.

**Visible when.**
- Consent `null`: shows the prompt card after the startup gate.
- Consent `true`: shows when connected and at least one friend is playing.
- Hidden on error or needs-login.

**Layout.**
- **Prompt:**
  - group icon, `HomeStrings.friendsConsentTitle`, `friendsConsentBody`;
  - buttons `friendsConsentAllow` (sets `true`) and `friendsConsentDecline` (sets `false` and hides the card via the layout, with a snackbar and undo).
- **Data:**
  - title `HomeStrings.friendsPlaying(n)`;
  - a horizontal strip of 48 dp avatars with an activity-colored ring **and** a one-line status under each (`presenceStatus(...).text`, shortened: "Ascent · 8 – 4", "Chọn đặc vụ", "Tìm trận");
  - "Xem tất cả ›".

**Taps.**
- The card or "Xem tất cả" does `context.push(SocialRoutes.friends)`.
- An avatar does `context.push(SocialRoutes.chat(friend.puuid))`.

**Refresh.** Presence is pushed, so there is no polling. Pull calls `ref.read(xmppServiceProvider)?.refresh()`, only when consent is `true`.

**Smarter.** It shows who is playing *right now* (map and live score from presence) on the first screen, at zero polling cost, and privacy-first. ValBuddy only lists friends on a separate screen.

**Optional (P2).** Friends in the lobby with an open party slot, from `partySize < maxPartySize` and `partyAccessibility` = OPEN in the presence, tagged "Còn chỗ".

### 5.6 Cộng đồng (`cards/community_home_card.dart`)

**Data.**
- `communityEnabledProvider`.
- `matchingLfgPreviewProvider(puuid)` and `trendingSkinsProvider(puuid)`. Both are **new** and owned by the community feature (contract in §11). The community feature is mid-change; the names are fixed by this spec.
- `wishlistProvider(puuid)` + `wishlistContains`, and `contentProvider`.

**Model.**
- `homeCommunitySnapshotProvider(puuid)`: `AsyncValue<HomeCommunitySnapshot?>`.
- `HomeCommunitySnapshot { List<LfgPost> lfg /*≤2*/; List<TopSkin> trending /*≤3*/; Set<String> wishlist }`. It is `null` when both lists are empty.
- It stays loading until at least one of the two previews has a value.

**Visible when.** §3.3. The card is deferred (§3.4).

**Layout.**
- **Section "Tìm đồng đội hợp rank bạn":** two compact rows, each with:
  - `CommunityStrings.modeLabel(post.mode)`;
  - a rank badge for `post.rankTier ?? post.author.rankTier`, or the v2 range `rankMin–rankMax`;
  - `HomeStrings.lfgNeeds(slots)`;
  - roles and mic icons (v2, optional);
  - the time left (`expiresAt`).
- **Section "Skin hot tuần này":** three thumbnails with `HomeStrings.trendingVotes(n)`, and a ♥ badge when the skin is in the wishlist.

**Taps.**
- An LFG row or "Xem tất cả" does `context.go(CommunityRoutes.section(CommunitySection.lfg))`. There is **no join on Home**: joining a party by code is a Riot mutation behind a confirmation in the Community tab.
- A skin opens `showSkinDetailSheet(context, skinOrLevelUuid: skinUuid, mode: SkinDetailMode.catalog)`.
- "Xem bảng xếp hạng" does `context.go(CommunityRoutes.section(CommunitySection.skins))`.

**Refresh.**
- `HomeCardPoller(every: kHomeLfgRefresh /*60 s*/)` calls `ref.invalidate(matchingLfgPreviewProvider(p))`.
- Trending is cached 30 min inside its provider.
- Pull invalidates both.

**Privacy.** Home never triggers `POST /v1/auth/riot`, so no Riot token is sent to the community server because of Home.

**Smarter.**
- LFG filtered by the server to your rank and region.
- Weekly trending skins with wishlist awareness.

Neither ValBuddy nor Daily Val has a social layer on its first screen.

### 5.7 Tài khoản khác (`cards/other_accounts_home_card.dart`)

**Data.**
- `accountsProvider` and `activePuuidProvider`.
- `accountActivityProvider(p)`, only for the rows shown.
- `wishlistProvider(p)`: local.
- `savedStorefrontProvider(p)`: reads the saved storefront from disk, **no network** (to be moved to core, §3.6).
- `findWishlistHits`, `contentProvider`, `clockProvider`.

**Model.**
- `homeOtherAccountsProvider`: `Provider.autoDispose<List<OtherAccountSummary>>`.
- `OtherAccountSummary { Account account; AccountActivity? activity; List<WishlistHit> liveHits; bool storeKnown }`:
  - `liveHits` keeps the hits with `expiresAt > now`.
  - `storeKnown` means the saved daily store has not expired.
- **Order uses local signals only,** so rows never jump when activity arrives: accounts with live hits, then needs-login accounts, then the rest, in list order.
- Show `kHomeMaxOtherAccounts` = 3 rows.
- Activity is fetched **only for the rows shown** and never for needs-login accounts. It decorates a row but does not reorder it.

**Visible when.** At least 2 accounts. The card is deferred.

**Layout.**
- Title `HomeStrings.otherAccountsTitle(n)`.
- **Rows:**
  - `AccountAvatar` with a status dot (`AccountActivity.color` **and** `label` text);
  - the Riot ID;
  - a subtitle: activity label, or `REGION · Cấp n`;
  - badges: ♥ `HomeStrings.otherWishlistHit` or `AccountStrings.needsLogin`.
- **Footer:**
  - `HomeStrings.otherMore(n)` + ›, which opens `showAccountSwitcherSheet(context)`.
  - **Optional (P1):** `HomeStrings.otherCheckStores(n)`, shown only when accounts with a non-empty wishlist have no fresh saved store.
    - The check is user-initiated. It fetches sequentially (concurrency 1) by awaiting `storefrontProvider(p).future`, which writes the saved copy, then invalidates `savedStorefrontProvider(p)`.
    - The footer shows "Đang kiểm tra 2/5…".

**Taps.**
- A row does `ref.read(activePuuidProvider.notifier).select(puuid)` + `Haptics.selection()`, then jumps Home to the top.
- A needs-login row pushes `AuthRoutes.loginPath(reauthPuuid: puuid)`.
- The ♥ badge selects the account, then navigates to the hit's place (same mapping as §5.2).

**Refresh.**
- `HomeCardPoller(every: kHomeAccountsRefresh /*2 min*/)` invalidates `accountActivityProvider(p)` for the rows shown.
- Pull also invalidates `savedStorefrontProvider(p)`.

**Smarter.** It shows which of your other accounts has a wishlist skin on sale today, with **no network call**, plus whether an alt is in game. One tap switches. ValBuddy and Daily Val require switching to each account to see its store.

**Optional (P2, wishlist agent).** Let the background check (`BackgroundWishlistCheckEnv.storefront`) also write the storefront JSON to `JsonFileCache.appSupport('cache')` under `JsonFileCache.accountKey(puuid, 'economy_storefront')`. The alt hints would then appear after each daily background run.

### 5.8 Trạng thái máy chủ (`cards/server_status_home_card.dart`)

**Data.**
- `platformStatusProvider(region)` for each distinct region of all accounts, active region first.
- The region comes from `regionFor(account)`, the hook of the connection spec ("auto region from account" vs "manual override"). Until that exists, use `account.region`.

**Model.**
- `homeServerStatusProvider`: `Provider.autoDispose<HomeServerStatus?>`, built by `buildHomeServerStatus(Map<String, PlatformStatus?> byRegion, {required String? activeRegion})`.
- `HomeServerStatus { List<HomeStatusNotice> notices; bool blocking }`, where a notice is `{String region; StatusNotice notice; bool isActiveRegion}`.
  - Notices keep maintenances whose status is not `complete`, and all incidents.
  - Notices are deduplicated by `id` per region, active region first.
  - `blocking` = the active region has an entry in `activeMaintenances`, or an incident with severity `critical`.
- The model is `null` when there are no notices.

**Visible when.** At least one notice. It is **pinned** when blocking. Home sets `showMaintenanceBanner: false`.

**Layout.**
- A construction icon (maintenance) or warning icon (incident), colored amber or red **plus** the icon itself.
- The title: `HomeStrings.statusMaintenanceNow(region)`, `statusMaintenanceScheduled(region)` or `statusIncident(region)`.
- `notice.message ?? notice.title` (3 lines).
- "+{n} thông báo" when there are several.
- "Chi tiết ›".

**Taps.** The card opens `showServerStatusSheet(context, status)`, a Home-owned bottom sheet with:
- every notice with its region label and `formatRelative(createdAt)`;
- the full text;
- "Mở trang trạng thái Riot", which opens `AppConstants.riotStatusPageUrl` (**new** constant; exact URL to verify) through `url_launcher`.

**Refresh.**
- `HomeCardPoller(every: kHomeStatusRefresh /*5 min*/)` (SUMMARY §10: "Status JSON 5 min").
- On resume after 5 min or more in the background.
- On pull: invalidate each region.

**Smarter.** It checks every region you have accounts in, not only the active one. It pins itself only when it actually blocks you, and it explains why the other cards are empty.

---

## 6. Refresh policy

| Card | Automatic (provider-owned) | Widget-owned poller (gated) | Pull-to-refresh | App resume |
|---|---|---|---|---|
| live | overlay poller 20 s / 4 s | – | `liveGameProvider(p).notifier.refresh()` | controller refreshes on foreground |
| store | refetch at earliest deadline + 3 s; wallet 5 min | – | invalidate wallet + storefront, await storefront | deadlines fire on resume |
| rank | MMR 3 min; invalidated at match end | midnight rollover timer | invalidate competitiveUpdates; refresh MMR | TTL |
| battlePass | contracts / ticket 5 min | – | `refreshBattlePass(ref, p)` | TTL |
| friends | XMPP push | – | `xmppServiceProvider?.refresh()` (consent only) | socket restarts on foreground |
| community | trending 30 min, LFG 60 s cache | LFG 60 s | invalidate both previews | invalidate LFG if away ≥ 5 min |
| otherAccounts | – | activity 2 min (rows shown) | invalidate activity + saved storefronts | – |
| serverStatus | – | 5 min | invalidate each region | invalidate if away ≥ 5 min |

```dart
// providers/home_refresh.dart
const kHomeLfgRefresh = Duration(seconds: 60);
const kHomeStatusRefresh = Duration(minutes: 5);
const kHomeAccountsRefresh = Duration(minutes: 2);
const kHomeStartupDelay = Duration(milliseconds: 1500);
const kHomeRefreshTimeout = Duration(seconds: 12);
const kHomeStreakMaxAge = Duration(days: 7);
const kHomeRecentRrDays = 7;
const kHomeMaxPlayingFriends = 8;
const kHomeMaxOtherAccounts = 3;
const kHomeMaxMissions = 2;

/// Refreshes only the cards currently shown (pinned + flow), in parallel;
/// never throws; the spinner stops after kHomeRefreshTimeout at the latest.
Future<void> refreshHome(WidgetRef ref, {required String puuid, required HomeArrangement shown});
```

- **`HomeCardPoller({required Duration every, required VoidCallback onTick, required Widget child})`:**
  - A `Timer.periodic` owned by the card's `State`.
  - A tick runs only when both hold: `TickerMode.valuesOf(context).enabled` (the Home tab is visible) and `ref.read(appForegroundProvider)`.
  - Same pattern as `LfgSliver` and `AccountActivityPoller`.
  - The timer dies with the card, whether the card is hidden, the tab is left, or the account is switched.
- **Resume:**
  - `HomeScreen` listens to `appForegroundProvider` and records when the app was backgrounded.
  - When it returns after `≥ 5 min`, it invalidates the status and LFG previews.
  - Everything else already reacts through its TTL, deadlines or controller.
- **Never** poll hidden cards. Never refresh cards the user switched off.

---

## 7. Personalization

### 7.1 Storage

- Key `f.home.layout`: feature convention `f.<feature>.<name>`, app-wide.
- It is **not** per account, so it survives sign-out and is not under `acct.`.
- Example: `{"v":1,"order":["live","store","rank","battlepass","friends","community","accounts","status"],"hidden":["community"]}`.
- Key `f.home.friendsLive`: bool (§5.5).

### 7.2 `HomeLayout` (`data/home_layout.dart`, pure)

```dart
@immutable
class HomeLayout {
  const HomeLayout({required this.order, this.hidden = const {}});
  static const defaults = HomeLayout(order: kDefaultHomeOrder);
  factory HomeLayout.fromJson(Object? json);   // never throws
  JsonMap toJson();
  HomeLayout moved(int from, int to);          // ReorderableListView semantics
  HomeLayout withHidden(HomeCardId id, {required bool hidden});
  bool isHidden(HomeCardId id);
}
```

**`fromJson` merge rules:**
- A non-map or corrupt value gives `defaults`.
- Unknown ids are dropped; duplicates are dropped.
- Each id in `kDefaultHomeOrder` that is missing (a card added in a later version) is **inserted right after its closest default predecessor** that is present, or at index 0. New cards are visible by default.
- A future `v` still parses the known fields.

### 7.3 Notifier (`providers/home_layout_provider.dart`)

```dart
final homeLayoutProvider = NotifierProvider<HomeLayoutNotifier, HomeLayout>(HomeLayoutNotifier.new);
class HomeLayoutNotifier extends Notifier<HomeLayout> {
  HomeLayout build() => HomeLayout.fromJson(ref.watch(prefsProvider).getJson(kHomeLayoutPrefKey));
  Future<void> move(int from, int to);
  Future<void> setHidden(HomeCardId id, {required bool hidden});
  Future<void> reset();
}
```

- Writes go through to Prefs at once.
- A failed write keeps the in-memory state.

### 7.4 UI

- **Card overflow ⋯, "Ẩn thẻ này":**
  - Calls `setHidden(id, hidden: true)`.
  - Shows a snackbar `HomeStrings.cardHidden(title)` with `HomeStrings.undo`.
- **"Tùy chỉnh Trang chủ"** opens `showCustomizeHomeSheet(context)`. The entry points are the button at the bottom of Home and the overflow menu. The sheet contains:
  - `ReorderableListView` of all 8 cards, including those that currently have no data;
  - on each row: a drag handle (`ReorderableDragStartListener`), the icon, the title, a one-line description (`HomeStrings.card*Desc`), and `Switch.adaptive` (visible or hidden).
  - The Material reorder semantics actions (move up/down/start/end, localized by `MaterialLocalizations`) give screen-reader and switch-access users reordering without dragging.
  - A "Khôi phục mặc định" button.
- **Friends switch:**
  - Turning it on while consent is `false` or `null` first shows `showConfirmDialog` with the consent text, then sets consent to `true`.
  - Turning it off hides the card; consent is left unchanged.
- **Pinning** ignores the user's order only for live and a blocking status. A card the user hid is never shown, pinned or not. The overlay's auto-open of the live sheet is independent of Home.

---

## 8. Deep links into Home

- **Locations:**
  - `/home`.
  - `/home?focus=<storageId>&nav=<nonce>` (§4).
  - `/` and `/welcome` while signed in redirect to `/home`.
- `HomeRoutes.focus(HomeCardId)` is the only way to build a focus link. There are no string literals.
- **Account switching** uses the existing `?account=<puuid>` handling in `parseDeepLink` and `ValVnApp`.
- **Outbound links:** every Home tap uses a route helper (`StoreRoutes.segment`, `StoreRoutes.bundle`, `ProfileRoutes.dailyRr` / `rankUp`, `BattlePassRoutes.root` / `rewardsFor`, `SocialRoutes.friends` / `chat`, `CommunityRoutes.section`, `AuthRoutes.loginPath`, `SettingsRoutes.root`) or a sheet function. The rule:
  - **Tab roots** (Store, Community, Profile) use `context.go(...)`, which switches tab.
  - **Detail pages** use `context.push(...)`, which stays in the Home stack; Back returns to Home.

---

## 9. Every device, every user

### 9.1 Adaptive layout (`ui/home_columns.dart`)

- **Content width:**
  - `contentWidth = min(width − 2×16 − horizontal safe insets, 1280)`, centered.
  - `SliverSafeArea(top: false)` handles the landscape notch and the rail.
- **Columns:**
  - `contentWidth ≥ 1000` gives 3 columns; `≥ 568` gives 2; otherwise 1.
  - Then `columns = min(columns, max(1, floor(contentWidth / (300 × clamp(textScale, 1, 2)))))`, so large text means fewer columns.
- **One column:** `SliverList` with `ValueKey(cardId)` (lazy).
- **Several columns:**
  - Round-robin by flow index (`i % n`), in a `Row` of `Column`s.
  - Pinned cards span the full width above.
  - Every card is wrapped in `Semantics(sortKey: OrdinalSortKey(i))` and `FocusTraversalOrder(order: NumericFocusOrder(i))` inside `FocusTraversalGroup(policy: OrderedTraversalPolicy())`. Screen-reader and keyboard order then follow the user's order, not the visual columns.
- **Foldables:**
  - If `MediaQuery.displayFeaturesOf(context)` has a vertical `hinge` or `fold` crossing the content, and there are 2 or more columns, use exactly 2 columns aligned to the two panes.
  - The gap is the hinge's bounds.
- **Tablets / iPad:**
  - Split View and Stage Manager are handled by width.
  - The store tile row stays 4-across inside a card.
  - The rank card lays out horizontally when the card is at least 480 dp wide.
- **Landscape phones:** the same rules apply (2 columns around 740 dp). The P1 rail (§2.7) saves vertical space.

### 9.2 Text size

- Nothing has a fixed height. Every `Text` has `maxLines` + ellipsis, and the full value goes in semantics.
- At text scale ≥ 1.3:
  - the store tiles become 2×2;
  - the rank chips wrap;
  - avatars keep 48 dp, and their captions become one line with ellipsis.
- Test at 200% (IA: "không tràn ở 360 dp/chữ 200%").

### 9.3 Reduced motion

- Read `MediaQuery.disableAnimationsOf(context)`.
- When it is on:
  - `AnimatedSwitcher`, `AnimatedSize` and scroll animations use `Duration.zero`;
  - no focus pulse and no count-ups.
- `SkeletonShimmer` must render static boxes. This is a small core change in `lib/core/ui/skeleton.dart` that benefits every screen.
- Countdown rings still update once per second. That is information, not decoration.

### 9.4 Color-blind safe

These signals never rely on color alone:

| Signal | Non-color cue |
|---|---|
| RR ± | ▲ / ▼ icon and the sign |
| Streak | flame / trending-down icon and text |
| Wishlist | ♥ icon and text |
| Live phase | pill text |
| Score | "Đội bạn" / "Đội địch" labels |
| Status | icon and title |
| Activity dot | label text |

Rarity colors keep the `TierTag` diamond and name.

### 9.5 Screen readers and touch

- Each card is `Semantics(container: true)` with its title as a heading and a one-sentence summary. Its inner actions are separate buttons with explicit labels, for example `HomeStrings.skinTileSemantics(...)` and `rrTodaySemantics(net, w, l)` ("Hôm nay tăng 37 RR, 3 thắng, 1 thua").
- Countdowns and timers: `ExcludeSemantics` around the ticking text, plus a coarse semantics value.
- Touch targets are ≥ 48×48 dp (Android) and ≥ 44 pt (iOS): chips, avatars, ⋯, the ring.
- Light and dark themes use `ValCard` and tokens; content colors used as text go through `legibleAccent`.

### 9.6 18 languages and RTL (i18n readiness)

The owner decided to support all 18 VALORANT locales.

- **Strings:**
  - All Home copy is in `HomeStrings`, or in the existing strings of other features where the meaning is identical (§10).
  - Follow the pattern the i18n spec lands. If Home ships first, keep `HomeStrings` as statics, but make every message with a count or a value a **function**, ready for ICU plural/select (Arabic has 6 plural forms; ru/pl have 3–4).
  - Never concatenate translated fragments. `formatSigned…` + " hôm nay" becomes one template, `rrToday(value)`.
- **Uppercase:** do not `toUpperCase()` translated strings in Home code. Casing is `SectionLabel`'s (i18n spec) decision per locale: none for ar/ja/ko/th/zh, locale-aware for tr.
- **Content** (skin, agent, map, rank names, queue names) comes from `contentProvider` in the chosen content language. Status notices use the app locale; this needs `StatusNotice.localized(locale:)` from the i18n spec. Region display names come from the country/region spec, with the uppercase code as fallback.
- **Numbers, dates and durations** only through `core/util/format.dart`, which the i18n spec makes locale-aware.
- **RTL (ar-AE):**
  - Use `EdgeInsetsDirectional` and `AlignmentDirectional`.
  - Horizontal strips start at the leading edge.
  - Chevrons mirror.
  - Countdowns, scores, signed RR and VP amounts are wrapped in an LTR isolate (U+2066…U+2069, helper from the i18n spec).
- **Fonts:** do not hard-code `AppFonts.body` in Home `TextStyle`s; use the theme, so the i18n spec's font fallback covers CJK, Thai, Arabic and Cyrillic. Anton is for digits and map names only.
- **LFG language:** the preview maps the app language to the server's set (`vi` → `vi`, anything else → `en`; the server also returns `any` posts). Revisit when the server adds languages.

---

## 10. Strings: `lib/features/home/home_strings.dart`

Vietnamese follows VF §8: sentence case, "bạn", and VP / RR / XP / skin / wishlist / Battle Pass in English. The English column seeds the future ARB. `{n}` messages must be plural-aware.

| Key | vi | en (source for i18n) |
|---|---|---|
| title | Trang chủ | Home |
| customize | Tùy chỉnh Trang chủ | Customize Home |
| customizeHint | Kéo để sắp xếp. Tắt để ẩn thẻ. | Drag to reorder. Switch off to hide a card. |
| resetLayout | Khôi phục mặc định | Reset to default |
| hideCard | Ẩn thẻ này | Hide this card |
| cardHidden(name) | Đã ẩn "{name}" | "{name}" hidden |
| undo | Hoàn tác | Undo |
| moreActions(name) | Tùy chọn cho {name} | Options for {name} |
| allHiddenTitle / allHiddenBody | Bạn đã ẩn mọi thẻ / Mở Tùy chỉnh Trang chủ để hiện lại. | All cards are hidden / Open Customize Home to show them again. |
| quietTitle / quietBody | Chưa có gì mới / Kéo xuống để làm mới. | Nothing new yet / Pull down to refresh. |
| needsLoginBody(riotId) | Phiên của {riotId} đã hết hạn. Đăng nhập lại để xem cửa hàng, rank và Battle Pass. | {riotId}'s session expired. Sign in again to see the store, rank and Battle Pass. |
| focused(name) | Đã chuyển đến {name} | Moved to {name} |
| cardLive / cardLiveDesc | Trận hiện tại / Hiện khi bạn đang tìm trận, chọn đặc vụ hoặc trong trận. | Current match / Shown while you queue, pick an agent or play. |
| cardStore / cardStoreDesc | Cửa hàng hôm nay / Skin hằng ngày, wishlist và Chợ Đêm. | Today's store / Daily skins, wishlist matches and Night Market. |
| cardRank / cardRankDesc | Rank & phong độ / Rank, RR hôm nay, chuỗi trận và số trận lên rank. | Rank & form / Rank, today's RR, streak, games to rank up. |
| cardBattlePass / cardBattlePassDesc | Battle Pass / Cấp, XP cần mỗi ngày và nhiệm vụ tuần. | Battle Pass / Level, XP per day and weekly missions. |
| cardFriends / cardFriendsDesc | Bạn bè đang chơi / Bạn bè đang trong trận hoặc đang tìm trận. | Friends playing / Friends in a match or in queue. |
| cardCommunity / cardCommunityDesc | Cộng đồng / Tìm đồng đội hợp rank và skin hot trong tuần. | Community / Rank-matched LFG and this week's hot skins. |
| cardOtherAccounts / cardOtherAccountsDesc | Tài khoản khác / Trạng thái và wishlist của các tài khoản còn lại. | Other accounts / Status and wishlist matches of your other accounts. |
| cardServerStatus / cardServerStatusDesc | Trạng thái máy chủ / Chỉ hiện khi có bảo trì hoặc sự cố. | Server status / Only shown during maintenance or incidents. |
| liveOpen | Xem chi tiết trận | Open match details |
| liveScoreSemantics(a, e) | Đội bạn {a}, đội địch {e} | Your team {a}, enemy team {e} |
| storeResetsIn(t) | Làm mới sau {t} | Resets in {t} |
| storeRefreshing | Đang làm mới… | Refreshing… |
| storeWishlistHit | Có skin trong wishlist! | A wishlist skin is on sale! |
| storeWishlistHits(n) | {n} skin trong wishlist đang bán | {n} wishlist skins on sale |
| storeTotal(vp) | Tổng {vp} | Total {vp} |
| storeWallet(vp, n) | Ví {vp} · đủ mua {n} skin | Wallet {vp} · enough for {n} skins |
| nightMarketWaiting(n) | {n} ưu đãi đang chờ bạn lật | {n} offers waiting to be flipped |
| nightMarketBest(pct, name, price) | {pct} · {name} · {price} | {pct} · {name} · {price} |
| nightMarketNew | Mới | New |
| skinTileSemantics(name, price, tier, wished) | {name}, {price}, {tier}{wished, select, true{, trong wishlist} other{}} | {name}, {price}, {tier}{…, in wishlist} |
| rankToNext(n) | Còn {n} RR lên rank | {n} RR to next rank |
| rrToday(value) | Hôm nay {value} | Today {value} |
| rrOnDay(day, value) | {day}: {value} | {day}: {value} |
| rrTodaySemantics(n, w, l) | Hôm nay {tăng/giảm} {n} RR, {w} thắng, {l} thua | Today {up/down} {n} RR, {w} wins, {l} losses |
| winsLosses(w, l, d) | {w} thắng – {l} thua{, {d} hòa} | {w}W – {l}L{ – {d}D} |
| noRankedToday | Hôm nay chưa đấu xếp hạng | No ranked games today |
| winStreak(n) / lossStreak(n) | Chuỗi {n} trận thắng / Chuỗi {n} trận thua | {n}-game win streak / {n}-game losing streak |
| matchesToRankUp(n, rank) | ≈ {n} trận để lên {rank} | ≈ {n} games to {rank} |
| previousAct(rank) | Phần trước: {rank} | Last act: {rank} |
| leaderboard(pos) | Hạng {pos} bảng xếp hạng | Leaderboard #{pos} |
| friendsPlaying(n) | {n} bạn đang chơi | {n} friends playing |
| friendsConsentTitle | Xem bạn bè nào đang chơi? | See which friends are playing? |
| friendsConsentBody | ValVN sẽ kết nối trò chuyện Riot của tài khoản đang dùng khi bạn mở Trang chủ. Bạn bè có thể thấy bạn đang trực tuyến. Bạn có thể tắt trong Tùy chỉnh Trang chủ. | ValVN connects to Riot chat for the active account while Home is open. Friends may see you online. You can turn this off in Customize Home. |
| friendsConsentAllow / friendsConsentDecline | Bật / Không, ẩn thẻ | Turn on / No, hide card |
| lfgTitle | Tìm đồng đội hợp rank bạn | LFG for your rank |
| lfgNeeds(n) | Cần {n} người | Needs {n} |
| trendingTitle | Skin hot tuần này | Hot skins this week |
| trendingVotes(n) | {n} lượt thích | {n} votes |
| openLfg / openRanking | Xem tất cả tin tìm đồng đội / Xem bảng xếp hạng skin | See all LFG posts / See skin ranking |
| otherAccountsTitle(n) | Tài khoản khác ({n}) | Other accounts ({n}) |
| otherWishlistHit | Có skin wishlist | Wishlist skin on sale |
| otherMore(n) | +{n} tài khoản | +{n} more |
| otherCheckStores(n) | Kiểm tra cửa hàng {n} tài khoản | Check {n} stores |
| otherChecking(i, n) | Đang kiểm tra {i}/{n}… | Checking {i}/{n}… |
| statusMaintenanceNow(r) / statusMaintenanceScheduled(r) / statusIncident(r) | Đang bảo trì · {r} / Sắp bảo trì · {r} / Sự cố máy chủ · {r} | Maintenance · {r} / Scheduled maintenance · {r} / Server incident · {r} |
| statusMore(n) | +{n} thông báo | +{n} more notices |
| statusOpenRiot | Mở trang trạng thái Riot | Open Riot status page |

These existing strings are reused unchanged: `CommonStrings` (`tabHome`, `tabSettings`, `seeAll`, `retry`, `signInAgain`, `errorNeedsLoginTitle`, `updatedAt`), `LiveGameStrings` (`statusAgentSelect`, `statusInProgress`, `inQueueFor`, `timeLeft`, `youHover`, `youLocked`), `BattlePassStrings` (`levelOf`, `xpPerDay`, `xpPerDayCaption`, `daysLeft`, `missionProgress`, `xpReward`, `newMissionsIn`, `checkpointsDone`, `unknownMission`, `eventPass`), `CompetitiveStrings.placementsLeft`, `AccountStrings.needsLogin` / `switchTo`, and `CommunityStrings.modeLabel`.

---

## 11. Contract for the community feature (new `lib/features/community/providers/community_previews.dart`)

The community client is mid-change (LFG v2 and reviews landed on the server in `2963258`). Home depends only on the following. These providers are **silent and read-only**:

- they never sign in;
- they never throw;
- they return `const []` when the community is disabled, when there is no cached session (LFG only), or on any error.

```dart
const kLfgPreviewLimit = 2;
const kTrendingPreviewLimit = 5;

/// Newest open LFG posts that accept the viewer's rank, for Home.
/// region = communityRegion(regionFor(account)); rank = account.rankTier when > 2 (omit otherwise);
/// language = app language mapped to vi|en; status=open; request limit 6, then client-side:
/// drop expired (clock), drop the viewer's own post (cachedSession.user.id), drop !hasValidCode,
/// take kLfgPreviewLimit. Uses ONLY communityAuthProvider.cachedSession(puuid): if null → [].
/// cacheFor(ref, 60 s). Watches accountProvider(puuid).select(rankTier/region/needsLogin).
final matchingLfgPreviewProvider = FutureProvider.autoDispose.family<List<LfgPost>, String>(…);

/// This week's most-voted skins: GET /v1/skins/top?period=week&limit=5 (sort=votes),
/// signIn: false (a cached session only adds `voted`). cacheFor(ref, 30 min).
final trendingSkinsProvider = FutureProvider.autoDispose.family<List<TopSkin>, String?>(…);
```

**Required API additions** in `lib/features/community/data/community_api.dart`:

```dart
lfg(puuid, {required region, String? mode, int? rank, String? role, bool? mic, String? language,
    String status = 'open', String? cursor, int limit = 20})
```

`topSkins(…, String sort = 'votes')` stays as it is.

**Model.** `LfgPost` gains the v2 fields: `rankMin`, `rankMax`, `roles`, `mic`, `language`, `partySize`, `agents`, `status`, `joins`, `updatedAt`. All are nullable and parsed defensively. Home renders them when present and degrades to the v1 fields otherwise.

---

## 12. Tests

All widget tests use a phone viewport, `FixedClock`, `retry: (_, _) => null`, and `settle` rather than `pumpAndSettle` (countdowns tick forever), then unmount.

### 12.1 Harness

**New** `test/features/home/home_test_env.dart` combines the existing harnesses:
- `MockPvpApi` with the economy fixtures (`storefront.json`, `wallet.json`), the competitive fixtures (MMR and P-12 rows via `updateRow`), the Battle Pass fixtures (contracts, ticket), G-1 404 by default, and `platformStatus` returning `{}`;
- `FakeXmppService` (from `test/features/social/social_test_env.dart`);
- `FakeCommunityServer` (from `test/features/community/community_test_env.dart`), recording requests;
- `MemoryJsonFileCache`, `createTestPrefs()`, `RecordingNotificationService`;
- `pumpHomeApp(tester, {…})`, which uses the **real** `createAppRouter` so that routing behavior is tested.

### 12.2 Pure unit tests (`test/features/home/data/`)

**`home_layout_test.dart`**
- The default order equals the IA order.
- JSON round-trip.
- Corrupt or non-map input gives the defaults.
- Unknown and duplicate ids are dropped.
- A missing new id is inserted after its closest default predecessor, and at index 0 when it has none.
- `moved()`: forward, backward and edges.
- Hide/show; `reset`.

**`home_arrangement_test.dart`**
- User-hidden cards are never shown, and `presenceOf` is not called for them.
- Live is pinned only in queueing, pregame or ingame.
- A blocking status is pinned above live; a non-blocking status stays in the user's position.
- Core cards that are loading appear (skeleton); optional loading cards are hidden.
- `allUserHidden` and an empty arrangement are reported.

**`home_live_snapshot_test.dart`**
- `null` for `notRunning` and `lobby`.
- Queueing carries `queueEntryTime`.
- Pregame carries `phaseEndsAt`, my agent, and hover vs lock.
- Ingame carries the map, mode label and custom game name.
- Unknown map or agent does not crash.

**`home_store_summary_test.dart`**
- At most 4 offers; total VP.
- `affordableCount` with and without a wallet.
- Hits are live-only and deduplicated per skin, ordered daily → Night Market → bundle.
- Night Market best deal: tie-breaks, and `unseen` from the local seen set.
- Returns `null` with no offers and no Night Market.
- `hasContentMiss` is set.
- `isFromCache` passes through.

**`home_rank_snapshot_test.dart`**
- Today's RR at the local-midnight boundary (injected `toLocal`).
- `lastDay` fallback within 7 days, and none after 7.
- Streak:
  - win and loss runs;
  - a draw or a 0-RR remake ends it;
  - an outcomes map overrides the RR sign;
  - `count < 2` gives `null`;
  - a stale newest row gives `null`.
- Placements variant.
- Unranked but ranked before shows `previousAct`.
- Never ranked gives `null`.
- Immortal and above: no progress, no estimate, leaderboard shown.
- The next tier name resolves in the act's table.

**`home_bp_snapshot_test.dart`**
- Level and count; pace delegated to `xpPaceOf`.
- Missions: incomplete only, sorted by fraction then XP, at most 2.
- All missions done gives the refill time.
- Checkpoints only with a valid, unexpired ticket.
- A complete Battle Pass falls back to the event pass; with no Battle Pass it returns `null`.
- The event line.

**`home_friends_test.dart`**
- Only inMatch, agentSelect and inQueue count, ordered by activity then name.
- Capped at 8.
- Shooting range, away and lobby are excluded.
- Returns `null` when nobody is playing.

**`home_other_accounts_test.dart`**
- Excludes the active account.
- Hits come from the saved storefront only while live; an expired store is ignored.
- Ordering uses local signals; activity does not reorder rows.
- Needs-login accounts are never polled.
- At most 3 rows, plus a "more" count.

**`home_server_status_test.dart`**
- Active region first; deduplication by id.
- `complete` maintenances are excluded.
- Blocking only for an in-progress maintenance or a critical incident in the active region.
- An issue in another region is visible but not blocking.
- Returns `null` with no notices.

### 12.3 Provider tests (`test/features/home/providers/`)

**`home_layout_provider_test.dart`**
- Persists to `f.home.layout` and reloads from it.
- A failed write keeps the in-memory state.
- The consent notifier persists `f.home.friendsLive`.

**`home_presence_test.dart`**
- Presence per card from mocked dependencies: loading, error and value.
- Needs-login hides the Riot cards.
- A hidden card never calls its API: `verifyNever(api.storefront…)`; no `/v1/lfg`.
- Deferred cards are not read before the gate opens.
- With consent not `true`, `container.exists(xmppServiceProvider)` is false.
- Community previews never call `/v1/auth/riot`.

**`home_refresh_test.dart`**
- `refreshHome` invalidates only the cards shown; verified with mock call counts.
- It swallows errors.
- It completes within the timeout even if a call hangs.

### 12.4 Widget tests (`test/features/home/ui/`)

**`home_screen_test.dart`**
- Header: title, chip (name at ≥ 360 dp, avatar only at 320), ⚙.
- ⚙ pushes SettingsScreen in the Home branch (nav `selectedIndex == 0`), and Back returns to HomeScreen.
- Default order with every card's data present.
- Skeletons for core cards while loading.
- Needs-login banner: only one, the Riot cards are hidden, and the button opens `/login?reauth=`.
- Blocking maintenance: status pinned, core cards without data hidden, and no duplicate `MaintenanceBanner`.
- All hidden: the empty state with the customize button.
- Account switch: cards rebuild for the new PUUID and scroll is at the top.
- `/home?focus=battlepass`: the card is scrolled into view, and a new nonce re-applies the focus.
- The scroll anchor: a live card appearing while scrolled does not move the first visible card.

**`live_home_card_test.dart`**
- Hidden in lobby.
- Pinned on the transition lobby → pregame.
- Pregame shows the countdown and the agent.
- Ingame shows the score only when live score is on and the presence is fresh.
- The queue timer ticks.
- A tap opens `LiveGameSheet`.
- Pull calls the controller's `refresh`.

**`store_home_card_test.dart`**
- 4 tiles, the countdown, the total and the wallet line.
- Wishlist banner with its place; a bundle hit pushes `BundleDetailScreen` in Home.
- Night Market unseen: the waiting text and no best deal. After seen: the best deal.
- A tile opens `SkinDetailSheet`.
- A card tap switches to the Store tab (index 1, daily segment).
- Night Market tap opens the nightmarket segment.
- Offline copy shows "Cập nhật lúc …".
- An error without data shows "Thử lại", which refetches.
- A content miss is reported once.

**`rank_home_card_test.dart`**
- Rank name, RR and progress.
- Today's chip with ▲ and the sign; the last-day fallback.
- Streak pill.
- Estimate row pushes the rank-up calculator; today's chip pushes daily RR.
- The card goes to the Profile tab.
- Hidden when never ranked.
- Midnight rollover with an advancing `FixedClock`.

**`battlepass_home_card_test.dart`**
- "Cấp 46 / 55", XP per day, days left, 2 missions, pips.
- A tap pushes `BattlePassScreen` in Home, and Back returns to Home.
- The event-pass fallback.
- Hidden without a pass.

**`friends_home_card_test.dart`**
- The consent prompt appears once, after the gate.
- "Bật" persists and starts the fake XMPP.
- "Không, ẩn thẻ" hides the card, and undo brings it back.
- Avatars and status lines.
- Avatar goes to chat; the card goes to friends.
- Hidden when nobody is playing.

**`community_home_card_test.dart`**
- Two LFG rows and three skins with a ♥ on wishlisted ones.
- Taps: `/community?section=lfg`, `/community?section=skins`, and the skin sheet.
- Hidden when disabled or empty.
- No sign-in request is recorded.
- The 60 s poller invalidates only while visible: pause via `TickerMode(enabled: false)`.

**`other_accounts_home_card_test.dart`**
- Hidden with one account.
- The wishlist hit badge comes from the saved storefront, with no storefront API call.
- A row tap switches the active account.
- Needs-login goes to login with reauth.
- "+n" opens the switcher.
- The activity poller runs every 2 min, only for the rows shown.
- "Kiểm tra cửa hàng" fetches sequentially.

**`server_status_home_card_test.dart`**
- A scheduled maintenance shows at its position.
- An in-progress one is pinned.
- Multiple regions are shown.
- The sheet shows the full text.
- The 5-minute poller.

**`customize_home_sheet_test.dart`**
- Reorder by drag and by the semantics actions ("move up").
- A switch hides a card.
- "Khôi phục mặc định".
- Changes persist and are restored after a rebuild.
- Enabling friends shows the consent dialog.

**`home_adaptive_a11y_test.dart`**
- No overflow (`tester.takeException()` is null) for every card state at:
  - 320×640 @ 2.0 text;
  - 360×740 dark and light;
  - landscape 740×360;
  - 1024×768 (2 columns) and 1366×1024 (3 columns);
  - a foldable with a vertical hinge (`MediaQueryData(displayFeatures: …)`), where the columns avoid the hinge.
- Semantics order follows the user's order in multi-column layouts.
- `meetsGuideline(androidTapTargetGuideline)`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` and `textContrastGuideline`.
- Reduced motion (`disableAnimations: true`): no shimmer animation controller is running, and focus uses no animation.
- RTL smoke (`Directionality(textDirection: TextDirection.rtl)`): no overflow, and strips start at the right.
- Non-color cues are present (▲/▼, flame, ♥ icons).

### 12.5 Shell, routing and cross-feature tests

**Updated `test/app/shell_test.dart`**
- 5 tabs in the order [Trang chủ, Cửa hàng, Cộng đồng, Bộ sưu tập, Hồ sơ].
- Community is index 2 and emphasized.
- The bar fits 320 and 360 dp at text 1.3 and 2.0 (compact below 360).
- Wide screens show every label.
- Re-tapping the active tab pops to its root.
- The rail at ≥ 840 dp, if P1 ships.

**Updated `test/app/router_test.dart`**
- `appRedirect`: signed in, `/` and `/welcome` go to `/home`; signed-out cases are unchanged.
- The widget test lands on `HomeScreen` once `hasAccounts` becomes true.
- **R-1:** `go('/battlepass')` and `go('/settings/about/terms')` build inside the shell with `selectedIndex == 4`.
- **R-2:** tapping Hồ sơ at a hosted root returns to `/profile`.
- **R-3:** `push('/battlepass')` from Home keeps `selectedIndex == 0`, and Back shows `HomeScreen`.

**Updated `test/app/deep_links_test.dart`**
- The fallback is `/` (it was `/store`).
- `planLinkNavigation`:
  - `/settings`, `/settings?nav=1`, `/settings/about/privacy` and `/battlepass/rewards?contract=x` give go `/profile` + push;
  - `/store?segment=nightmarket` and `/home?focus=store` give go only;
  - `/settingsx` is not hosted.

**Updated `test/app/app_integration_test.dart`**
- The app starts on `HomeScreen`.
- Every tab builds offline (Home shows the compact "Thử lại" in core cards).
- Battle Pass is reachable from the Profile row and by `router.go('/battlepass')`.
- Settings is reachable from the ⚙ on Home and on Profile.
- `openAppLink(router, parseDeepLink('/settings'))` lands on Settings with Hồ sơ selected, and Back shows `ProfileScreen`.
- `/store?account=<second>&segment=nightmarket` switches the account and the segment.
- Switching the active account rebuilds Home.

**New `test/features/store/store_reset_reminder_host_test.dart`**
- The reminder is scheduled at app start with Home as the landing tab and **without** the Store tab ever being built.
- It is not scheduled when the setting is off.
- It is rescheduled once per new storefront, not on rebuilds.
- An account switch schedules it for the new account.
- The reminder group moves here from `store_screen_test.dart` (its lines 446–497), because `StoreScreen` no longer schedules.

**Other feature tests**
- **New** `test/features/community/providers/community_previews_test.dart` (community agent):
  - the query carries `rank`, `region`, `status=open`, `language` and the limit;
  - no cached session gives `[]` with no auth call;
  - own, expired and invalid-code posts are dropped;
  - errors give `[]`;
  - trending uses `period=week` and `signIn: false`, and errors give `[]`;
  - v1 and v2 `LfgPost` JSON both parse.
- **New** `test/features/profile/ui/profile_entry_points_test.dart`: ⚙ pushes Settings; the Battle Pass row shows "Cấp n / N" and pushes `BattlePassScreen`.
- `test/core/domain/competitive/rank_calc_test.dart` (moved `dailyRrOn`), `test/features/skin_detail/skin_availability_test.dart` (moved `savedStorefrontProvider`) and `test/core/ui/val_widgets_test.dart` (static skeleton under reduced motion): update the imports and add the reduced-motion case.

---

## 13. Milestones and definition of done

1. **M1, shell and routes:**
   - `/home` with `HomeScreen` showing header plus empty state;
   - 5 tabs and `AppTab`;
   - Profile hosts Battle Pass and Settings; `SettingsGearButton`, `BattlePassProgressSubtitle`, the Profile row;
   - `planLinkNavigation` and `openAppLink`; `/` redirect; login and error page go to `/`;
   - `StoreResetReminderHost`;
   - tests §12.5.
2. **M2, Home core:**
   - layout, presence, arrangement, startup gate, refresh, pollers;
   - cards live, store, rank and Battle Pass; customize sheet;
   - tests §12.2–§12.4 for these.
3. **M3, secondary cards:**
   - other accounts (after the `savedStorefrontProvider` move) and server status;
   - friends with consent;
   - community once §11 lands. Until then the card stays hidden, because `communityEnabledProvider` alone is not enough: it needs the previews.
4. **M4, polish:** adaptive columns, hinge support, reduced motion in `SkeletonShimmer`, accessibility guideline tests, RTL smoke, the P1 rail.

**Done means:**
- `flutter analyze` reports 0 issues (infos are fatal) and `dart format lib test` is clean.
- All tests pass.
- No overflow at 360 dp with 200% text, in light and dark, on iOS and Android.
- Hidden or deferred cards make no network calls.
- Home triggers no community sign-in and no chat connection without consent.
- Every notification payload in §2.4 still works.
- ARCHITECTURE §1, §2 and §4 and PROGRESS.md are updated.

---

## 14. Risks and open questions

1. **Cross-branch `push`.** The assumed go_router behavior is that the page lands in the current branch. It is verified by R-3, and the fallback is Home-branch alias routes (§2.2).
2. **Community client is mid-change.** Home only depends on the two preview providers (§11). The card stays hidden until they exist.
3. **LFG language mapping.** Everything that is not Vietnamese maps to `en`, until the server supports more languages. Decide with the community owner.
4. **Cost of other accounts' activity with 10 accounts.** It is capped to the 3 rows shown, every 2 min. The first sweep may re-auth up to 3 alts. Accept, or show activity only from warm sessions (`SessionManager.peek`).
5. **Background persistence of alt storefronts (P2).** It would make the alt wishlist hints appear without a foreground fetch. This is the wishlist agent's decision.
6. **Wording of the XMPP consent** ("you may appear online"). Confirm with the owner; it may need a line in the privacy policy.
7. **Streak semantics.** A remake (0 RR) ends the streak, consistent with Profile's `RecentForm`. Confirm with the owner.
8. **Hiding the Night Market best deal until the first visit.** The owner decides; it is one flag (`HomeNightMarket.unseen`).
9. **The URL behind `AppConstants.riotStatusPageUrl`** must be verified.
10. **The P1 rail** changes every tab's layout. Schedule it with the accessibility / every-device work, not necessarily with Home.
