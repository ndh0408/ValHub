# ValVN: device-class and accessibility audit, with implementation plan

Read-only task: nothing in the repo was changed. I could not run Flutter, so items I could not prove statically are marked **verify**. Baseline is the code at HEAD `5196414`. `lib/app/shell.dart` still has 6 tabs; the 5-tab shell exists only in `docs/design/IA.md` and `docs/design/HOME.md`. This plan builds on that 5-tab target and lists the conflicts with HOME.md in section 4.

## 0. TL;DR

- **The app is phone-portrait only.** The shell always renders a bottom `FloatingNavBar`, and there is no `NavigationRail`, no master-detail and no shared breakpoint. The only shell rule is `width < 420`, which hides unselected labels.
- **Nothing locks orientation.** iPad has all 4 orientations and no `UIRequiresFullScreen`, so multitasking already works at the OS level. Android has no `screenOrientation` and has the right `configChanges`. Platform config is in good shape.
- **The landscape phone is the worst case.** The pinned app bar (72 dp), the pinned segment strip (60 dp) and the bottom bar (80 dp or more) take about 60% of a 360 dp height.
- **Most fixes are mechanical.** Coverage is good in places: every `IconButton` has a tooltip, win/loss has a text label, and grids use `maxCrossAxisExtent`.
- **Correctness risks to fix first:**
  1. About 30 `Semantics(button: true, excludeSemantics: true)` wrappers never expose a tap action to assistive tech (**verify**).
  2. Dark-theme white text on `#FF4655` is about 3.4:1, below WCAG AA.
  3. Nothing reads reduced motion (`SkeletonShimmer` loops forever, the skin video autoplays and loops).
  4. Some fixed-height rows will overflow at large text.
- **RTL is the big i18n-coupled debt.** There are about 320 physical-direction usages against 18 directional ones.
- **Plan:** one `WindowInfo` foundation, an adaptive shell, list-detail driven by URL query parameters, a `SemanticButton` helper, and a device-matrix test harness. Section 4 says what can ship now and what belongs to the i18n phase.

## 1. Findings

### 1.1 Shell, layout and breakpoints

- **`lib/app/shell.dart:54-68`.** `AppShell` always uses `bottomNavigationBar: FloatingNavBar`. The only responsive rule is `compact = width < compactWidth (420)`, which only hides unselected labels. It has 6 destinations (lines 15-46), against 5 in IA.md, and HOME.md wants `compactWidth = 360`.
- **`lib/core/ui/floating_nav_bar.dart`.**
  - The capsule stretches to the full window width, so on a 1024 dp window it is a 1000 dp bar.
  - It applies only the bottom inset (line 41); left and right landscape insets are ignored.
  - `_barHeight = 64` (line 32), text clamp `1.15` (line 52) and a hard-coded `fontSize: 10.5` (line 160).
- **No rail or split view exists.** The grep for `NavigationRail|SplitView|MasterDetail|TwoPane|ListDetail` only hits `navigationBarTheme` (`app_theme.dart:405`) and doc comments.
- **Ad-hoc thresholds, no shared breakpoints.**
  - Width: `store_screen.dart:187` (360), `weapon_skins_screen.dart:206` (360), `battlepass_screen.dart:44` (400), `shell.dart` (420).
  - Height: `live_game_header.dart:21` (720 dp), and sheet heights `live_game_sheet.dart:54` (0.92) and `player_loadout_sheet.dart:65` (0.85).
- **Nothing in `lib/` uses** `OrientationBuilder`, `MediaQuery.displayFeaturesOf`, `shortestSide` or a window-size class.
- **No content-width cap on tab screens.** Only `legal_document_screen.dart:114` (720) and `error_view.dart:173` / `empty_view.dart:40` (360) cap width.
  - Full-width `AspectRatio` cards will grow without bound on wide windows, for example about 990×350 dp on a 1024 dp window. Sites: `daily_offer_card.dart:67` (2.8:1), `night_market_card.dart:108`, `bundle_banner.dart:49`, `collection_screen.dart:118/185` (452:128 banner), `live_game_header.dart:143`, `bundle_detail_screen.dart:153/382/473`.
  - Full-width lists: `feed_section.dart:76-78` (community feed), `profile_screen.dart:54-90` (Profile) and `settings_screen.dart:35-53` (Settings).
  - Grids are already good and adapt by width: `catalog_screen.dart:143` (200), `browse_collection_screen.dart:310` (220), `weapon_loadout_screen.dart:77` (220), and the pickers (120/130).
- **`TabPageScaffold` chrome (`lib/core/ui/tab_page_scaffold.dart`).**
  - `SliverAppBar(pinned: true, toolbarHeight: 72)` (line 62-63), a pinned `GlassHeaderDelegate` of 60 (lines 82-88), plus the bottom bar (6 + 64 + max(inset, 10) = 80-91).
  - On a 360 dp-high landscape phone that is 212-223 dp of chrome and about 140 dp of content.
  - The `SliverPadding` and `SliverList` children (for example the Profile list in `profile_screen.dart`) have no horizontal safe-area handling (only `settings_screen.dart:36` uses `SliverSafeArea`), so a landscape notch overlaps content.
- **Detail navigation is always full-screen push.**
  - Top-level `/post/:id` and `/compose` (`community_routes.dart`), and `/player/:puuid` and `/match/:id` (`profile_routes.dart`).
  - Nested `/profile/match/:id` and `/profile/friends/:puuid/chat` (`social_routes.dart`).
  - Sheets are `showModalBottomSheet`. M3 should cap them at 640 dp (**verify** on a tablet).
- **Pushed routes hide the shell.** Full-screen routes such as `/post/:id`, `/compose` and `/player/:puuid` sit above the shell and hide the bar or rail, which is fine on compact but wrong on expanded.
- **Rotation and fold hazard.** `navigationShell` is a `StatefulNavigationShell`, so it holds per-branch Navigators. Any rail/bar switch that re-parents it without a `GlobalKey` would reset the user's stack on rotate or fold.

### 1.2 Platform configuration

- **iOS**
  - `ios/Runner.xcodeproj/project.pbxproj:369,496,550`: `TARGETED_DEVICE_FAMILY = "1,2"` (universal).
  - `Info.plist:73-85`: iPhone gets portrait + landscape left/right; iPad (`~ipad`) gets all 4 orientations.
  - No `UIRequiresFullScreen`, so Split View, Slide Over and Stage Manager are on by default. Keep it that way; it is deprecated and iPadOS 26 windows can be any size.
  - `UIApplicationSupportsMultipleScenes = false` (line 35-36): correct for now, because one process holds session, XMPP and polling state.
  - `SceneDelegate.swift` is an empty `FlutterSceneDelegate` subclass, so there is no minimum window size. Deployment target is 15.0 (`pbxproj:364`), so any `sizeRestrictions` API (iOS 16+) needs an availability guard.
  - i18n-coupled: `CFBundleDevelopmentRegion = vi` and `CFBundleLocalizations = [vi]` (lines 7-12), `knownRegions = en, vi, Base` (`pbxproj:198-202`), and a Vietnamese-only `NSPhotoLibraryUsageDescription` (line 65-66).
- **Android** (`AndroidManifest.xml:23-31`, `build.gradle.kts:38`)
  - No `screenOrientation`, `resizeableActivity` or aspect-ratio attributes. Android 16 ignores those on windows of 600 dp or more anyway, and API 37 removes the opt-out.
  - `configChanges` covers orientation, screenSize, smallestScreenSize, screenLayout, density, uiMode, layoutDirection, fontScale and locale, which is right for foldables.
  - `targetSdk` is 36, so edge-to-edge is enforced. There is no `SystemChrome` call in `lib/`, and `res/values/styles.xml` sets no cutout mode. Landscape cutout behaviour is **verify**.
  - No `android:localeConfig` and no `res/xml/locales_config.xml` (i18n).
- **Dart.** No `SystemChrome.setPreferredOrientations` anywhere, so nothing locks orientation.

### 1.3 Text scaling

- **Only two clamps exist:** `floating_nav_bar.dart:51-52` (1.15) and `segmented_tabs.dart:211-213` (1.25). There is no global upper bound. iOS accessibility sizes reach about 3.1×; Android reaches about 2.0×.
- **Good pattern:** grid tiles scale their extent with the text scale (`collection_widgets.dart:636-661`, clamped to 2.0; `catalog_screen.dart:104-105`, unclamped; `agent_select_view.dart:123`). Above 2.0 the clamped ones overflow.
- **Fixed-height rows containing text (likely overflow at 2.0 or more, verify):**
  - `top_skins_section.dart:332`: `SizedBox(height: 84)` holding a 2-line name, a weapon line and a heart button.
  - `tab_page_scaffold.dart:62-71`: `toolbarHeight: 72` with the 32 sp title. At 2.0× it is about 74 dp and clips.
  - `friends_screen.dart:88`: `SizedBox(height: 52)` for the chip bar.
  - `floating_nav_bar.dart:32`: nav bar of 64.
- **Small fixed fonts (10-11 sp):** `floating_nav_bar.dart:160` (10.5), `skin_art_card.dart:214`, `reward_tile.dart:202`, `live_roster.dart:371`, `weapon_loadout_screen.dart:180`, `profile_widgets.dart:137`, `rank_card.dart:211`.
- **Tests:** 1.3× and 2.0× exist for store, wishlist, collection, battlepass, profile, settings and `adaptive_test.dart` (320×640 at 2.0×). None goes to 3.0×.

### 1.4 Reduced motion

- **Zero reads** of `disableAnimations`, `accessibleNavigation` or `highContrast` in `lib/`.
- **Finite animations are probably fine.** The framework shortens finite `AnimationController` runs to about 5% when the platform flag is on (**verify**). That covers `AnimatedContainer`, `AnimatedSwitcher`, the `TweenAnimationBuilder` rings, `Scrollable.ensureVisible` and route/Hero transitions.
- **Real leaks:**
  - `skeleton.dart:17-20`: `SkeletonShimmer` runs `..repeat()` forever. It is used by about 15 skeleton composites.
  - `skin_video_view.dart:77-81`: `setLooping(true)` then `play()` autoplays and loops. There is a tap-to-pause (line 123), but nothing checks reduced motion.
  - `community_widgets.dart:514-532`: the `elasticOut` like-bounce is finite; low risk.
  - `media_grid.dart:132,222`: Hero flights, finite.

### 1.5 Semantics and screen readers

- **Good coverage:** 87 `Semantics`-family usages across 59 files, and all 29 `IconButton` sites have `tooltip:`.
- **About 30 `excludeSemantics: true` wrappers likely expose no tap action (verify with TalkBack and VoiceOver).**
  - The pattern is `Semantics(button: true, label:…, excludeSemantics: true, child: InkWell(onTap: …))`. The `onTap` lives inside the excluded subtree and none of the 30 passes `onTap` to `Semantics`.
  - Examples: `floating_nav_bar.dart:124-131`, `segmented_tabs.dart:365-376`, `store_ui_bits.dart:103-113` (`WishlistHeartButton`), `community_widgets.dart:170-176,585-594`, `wishlist_row.dart:215`, `preferences_sections.dart:279-285`, `social_widgets.dart:121`.
  - Existing tests do not catch it. They pointer-tap a semantics label (`shell_test.dart:86`) and only check flags (`adaptive_test.dart:200-203`, `isSemantics(isSelected:, isButton:)`).
- **`AccountChip`** (`account_widgets.dart:90-97`): the label is the generic `switcherTitle`. It omits the active account and the "needs re-login" state, which is shown only as a `Badge` dot (line 104).
- **Segment dot** (`segmented_tabs.dart:342-349`, used by `store_screen.dart:174`): the "new Night Market" dot has no semantics.
- **`NetImage`** (`lib/core/ui/net_image.dart`): no `semanticLabel` and no decorative flag, so every image is an unlabeled "image" node.
- **No live announcements anywhere.** There is no `liveRegion` and no `SemanticsService.announce`, apart from `SnackBar`s.
- **Headings:** `Semantics(header: true)` appears in a few places (`collection_screen.dart:80`, `match_history_sliver.dart:243`, `round_timeline_view.dart:146`). `SectionLabel` (`val_widgets.dart:83`) and the `TabPageScaffold` title (`tab_page_scaffold.dart:65`) are not marked headers.
- **Nav semantics** (`floating_nav_bar.dart:124-129`): no "tab i of n" and no tab role.
- **Keyboard and pointer:**
  - No `FocusTraversalGroup` or `Shortcuts` in `lib/`, and no `sortKey`.
  - `GestureDetector`-only tappables are not focusable: `preferences_sections.dart:284` (theme tiles), `skin_video_view.dart:145`, `media_grid.dart:315`.
  - This matters for an iPad with Magic Keyboard, and for Android tablets and Switch Access.

### 1.6 Touch targets

- **`_Segment`** (`segmented_tabs.dart:355`): `minHeight: 40`, below 44 pt on iOS and 48 dp on Android.
- **`AccountChip`** (`account_widgets.dart:99-100`): 4 + 30 + 4 = 38 dp high.
- **`catalog_tile.dart:175`** heart button: 44 dp minimum; passes iOS, not Android's 48.
- **Fine:** `WishlistHeartButton` (48), the account-list `IconButton` (`Size.square(38)` plus `tapTargetSize: padded`), `ActionChip`s (padded to 48 on mobile), and nav items (about 54 dp tall; 47 dp wide at 320 dp with 6 tabs).
- **`HeartButton`** with `dense: true` (`community_widgets.dart:585-…`): **verify** size.

### 1.7 Contrast and colour-only signals

- **Dark-theme filled red.** `onPrimary = white` on `#FF4655` (`app_theme.dart:441-449, 580-598`) is about 3.4:1 by hand calculation (confirm with `contrastRatio`).
  - It hits `FilledButton` (15 sp w700), the selected segment pill (`segmented_tabs.dart:325`), the community FAB (`community_screen.dart:149-155`) and the send button (`post_detail_screen.dart:263-270`).
  - `contrast_test.dart:22-23` accepts it as a "bold label, ≥ 3:1". WCAG "large text" starts at 14 pt bold (about 18.7 px), and these labels are smaller.
  - The dark theme has no contrast test at all; the light theme is tested to 4.4-4.5 and `legibleAccent` handles rarity/rank text.
- **Colour-only signals:**
  - `recent_form_card.dart:160-187` (`_OutcomeStrip`): 14×14 green/red/grey squares; only an aggregate semantic label exists.
  - `round_timeline_view.dart:103-123`: won/lost is colour plus a coloured bottom border only. The icon shows the end type, not the outcome. The tooltip has words but is touch-hostile.
  - `round_timeline_view.dart:201-224` (`_RoundLine`): a 3 dp coloured stripe, and the row text has no won/lost word.
  - `content_tier_badge.dart:44` (rarity icon with tooltip only) and `TierCard` tint (`store_ui_bits.dart:381-441`): rarity is colour-coded where the name is not shown. **Verify** whether Riot tier icons differ in shape or only in colour.
  - Presence dot in `social_widgets.dart:93-105`, the re-login `Badge` and the Night Market dot. The friend tile does show status text (`friend_tile.dart:91-102`).
- **Already fine:** match result text and score (`match_card.dart:371-378`), signed RR pill, win-rate ring with %, checkpoint diamonds with `n/3` and a check icon, `TierTag` (diamond + name), and the wishlist heart (shape plus toggled semantics).

### 1.8 RTL and script readiness

- **Physical-direction usage** across `lib/`:

| Pattern | Count |
|---|---|
| `EdgeInsets.fromLTRB` | 223 |
| `Alignment.centerLeft`, `topRight`, etc. | 49 |
| `left:` / `right:` (mostly `Positioned`) | 54 |
| `Positioned(` | 29 |
| `EdgeInsets.only(left/right)` | 8 |
| Directional variants (`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`) | 18 |

  Examples: `match_card.dart:229-233` (agent avatar left, RR pill right), `collection_screen.dart:208-212`, `account_widgets.dart:100`.
- **Custom-painted or physical gradients will not mirror:** `_DiamondPainter`, the ring painters, `LinearGradient(begin: Alignment.topLeft…)` in `TierCard`, and `_DiagonalClipper` (`preferences_sections.dart:311-323`). Material `Icons.chevron_right`, `send` and `logout` are flagged `matchTextDirection` and mirror automatically (**verify** in the RTL test).
- **Casing and spacing:** 51 `toUpperCase()` sites (`SectionLabel` at `val_widgets.dart:84`, `TierTag`, and others) and 24 `letterSpacing` uses (`ValText.label` has 0.8). Arabic needs `letterSpacing: 0`, and Turkish needs a locale-aware `i`/`İ`.
- **Locale and fonts:** `app.dart:81-82` pins `locale`/`supportedLocales` to `vi`. Only `BeVietnamPro` and `Anton` ship (13 `AppFonts.` uses), so ar, ja, ko, th, zh and ru rely on platform fallback.

### 1.9 Test coverage today

- **Present:** sized pumps at 320-360 wide (`shell_test.dart:22-23`, `adaptive_test.dart:207-208`), a 600×900 "all labels" test (`shell_test.dart:112-126`), and text scale 1.3/2.0 across features.
- **Absent (0 matches in `test/`):** landscape sizes, widths of 768 or more, `displayFeatures` (foldables), `TextDirection.rtl`, reduced motion, `meetsGuideline`, semantics tap actions, and static platform-config checks.

## 2. Plan

### 2.1 Foundation: window size classes

Add `lib/core/ui/layout/`. Do not put it in `lib/core/ui/adaptive.dart`, which already holds Cupertino/Material dialog adapters.

- **`window_size.dart`.** Everything is classified by **window** size, not device, so Split View, Stage Manager, Android multi-window and unfolded foldables all work.
  - `WidthClass { compact, medium, expanded, large }` and `HeightClass { compact, medium, expanded }`.
  - `WindowInfo.of(context)` uses `MediaQuery.sizeOf` and `displayFeaturesOf` (aspect-scoped so it does not rebuild on keyboard changes). It exposes `useRail`, `useTwoPane(contentWidth)`, `hinge` (a `Rect?` plus its axis) and `gutter`.
- **Breakpoints (dp):**

| Class | Width | Typical | Shell nav | Content | Detail |
|---|---|---|---|---|---|
| compact | < 600 | phones portrait | floating bottom bar | 1 column, gutter 16 | push |
| medium | 600-839 | 7-8" tablets, iPad mini, Split View halves, foldable inner (portrait) | rail | up to 2 columns, gutter 24 | push, unless two-pane conditions below |
| expanded | 840-1199 | iPad 11-13" portrait, tablets landscape, unfolded foldables | rail | 2-3 columns, gutter 24 | list-detail |
| large | ≥ 1200 | iPad Pro 13" landscape (1366) | rail | up to 3 columns, centred at 1280 max | list-detail |

- **Height classes:** compact < 480, medium 480-899, expanded ≥ 900.
- **Rail rule:** `useRail = widthClass != compact || heightClass == compact`. So an 800×360 landscape phone gets the rail, and a phone-portrait Split View window at 500 wide gets the bar.
- **Two-pane rule:** `useTwoPane = contentWidth ≥ 720 && heightClass != compact`. On an iPad 11" portrait (834 wide) that gives 834 - 80 = 754, so two panes. An 800×360 landscape phone stays single-pane.

### 2.2 Adaptive shell

- **`lib/app/shell.dart`** keeps one `Scaffold` and switches by `WindowInfo`:
  - Compact: `bottomNavigationBar: FloatingNavBar` (as today, 5 destinations, `compactWidth = 360`).
  - Otherwise: `Row(children: [FloatingNavRail, Expanded(body)])`, with the rail inside `SafeArea` on the start edge (which is the right edge in RTL).
- **Keep the `navigationShell` widget alive across the switch** by giving it a `GlobalKey` and reusing the same `KeyedSubtree` in both branches. Otherwise rotating a tablet or folding a phone resets each tab's navigation stack.
- **`FloatingNavRail`** in `lib/core/ui/floating_nav_bar.dart` (or a sibling file). It is the vertical capsule already specified in HOME.md §2.7, so no new visual design.
  - 72-80 dp wide, destinations vertically centred, labels under icons (11 sp minimum, 2 lines allowed, text clamp 1.3). At scale ≥ 1.5, show icons only with tooltips.
  - Extract the `_NavItem` core into a shared `NavItemButton(axis, …)` so semantics, focus and colours stay identical between bar and rail.
  - Community item keeps the emphasized style (`emphasizedIndex`).
  - The frosted `BackdropFilter` is fine on a narrow rail; keep it small, since iPad blur cost scales with area.
- **Shell semantics and focus** (both bar and rail):
  - Fix the tap-action gap (A1 below).
  - Wrap the group as a tab bar (`role: SemanticsRole.tabBar` / `tab` if 3.47 exposes it, **verify**) with a localized "i of n" hint.
  - Put the group in a `FocusTraversalGroup` and add Cmd/Ctrl+1..5 through `CallbackShortcuts` (P2).
- **Landscape phone chrome.** With the rail there is no bottom bar. In `TabPageScaffold`, when `heightClass == compact`:
  - Use a floating (non-pinned) `SliverAppBar` at `toolbarHeight: 56` with a 24 sp title.
  - Reduce the pinned header strip from 60 to 48.
  - Add side safe-area padding for both the notch and the rail.

### 2.3 Content layout rules

- **Central place: `TabPageScaffold`** (`lib/core/ui/tab_page_scaffold.dart`).
  - Add `contentMaxWidth` (default 720, or `null` for pages that manage their own columns) and wrap `slivers` in one `SliverLayoutBuilder` that centres the content and adds the horizontal gutter plus safe-area inset. Features get it for free.
  - Also add the `controller` parameter HOME.md already requires.
- **Per tab at medium and above:**
  - **Home:** `HomeColumns` per HOME.md §9.1 (2 columns from 568 dp content, 3 from 1000, cap 1280). It should read `WindowInfo`, not its own `MediaQuery` maths.
  - **Store:** daily offers become a 2-column grid from 568 dp content (change the card aspect from 2.8 to about 1.6 in grid mode). Night Market is 3 columns; accessories and bundles use `maxCrossAxisExtent`. `WalletPill` and the countdown stay above the grid.
  - **Community:** feed and skins are capped at 640-720 dp on medium, and list-detail on expanded. `/compose` becomes a centred modal dialog (max 640 wide) from medium up instead of a full-screen route.
  - **Collection:** cap the banner and loadout rows at 720 dp (loadout rows become 2 columns at 840 dp or more). Weapon grids already adapt.
  - **Profile:** see list-detail below.
  - **Settings, About, Welcome, login note, rank-up, daily RR:** cap at 720 dp centred; two-pane Settings is optional (P2).
- **Sheets** (`live_game_sheet.dart`, `skin_detail_sheet.dart`, pickers): keep the 640 dp cap on medium. On expanded, present skin detail as a right-hand side sheet or a centred dialog (max 560 wide) instead of a full-width bottom sheet (P1).

### 2.4 Master-detail on expanded widths

**Screens (P1 unless stated):**
1. Profile: match history list (left) with `MatchDetailScreen` content (right).
2. Friends list with chat (`/profile/friends` and `…/:puuid/chat`).
3. Community feed with post detail (`/post/:id`).
4. Collection weapons list with weapon skins (P2).
5. Wishlist with skin detail (P2).

**Mechanism.**
- New `lib/core/ui/layout/list_detail.dart`:
  - `ListDetailScaffold({master, detail, emptyDetail})`, master width 360 (clamped 320-440 by text scale).
  - Pane header without a back button.
  - Two `FocusTraversalGroup`s, master first, plus a11y focus and an announcement on selection.
- Selection lives **in the URL** as a query parameter on the master route, the same pattern as `?segment=` and `?section=`:
  - `/profile?match=<id>[&player=<puuid>]`
  - `/profile/friends?chat=<puuid>`
  - `/community?section=feed&post=<id>`
- `openDetail(context, {compact: push(existingRoute), expanded: go(masterWithSelection)})`. Existing detail routes and constants stay unchanged for compact and for notification and deep links.
- **Resize handling.** Each legacy detail route builder wraps its screen in a guard.
  - If `useTwoPane` becomes true (rotation, unfold), the guard does a post-frame `go(master?…=id)`.
  - If the master has a selection and the window becomes compact, it does `go(master)` then `push(detail)` so Back still works.
  - Guard against loops by comparing locations.
- **Refactor.** Extract `MatchDetailView`, `ChatView` and `PostDetailView` (body without `Scaffold`/`AppBar`). The existing screens become `Scaffold + AppBar + View`.
- **Selection UI.** Add a `selected` state to `MatchCard`, `FriendTile` and `PostCard`, both visual and `Semantics(selected: true)`.
- **Defaults.** Profile auto-selects the newest match once loaded (summaries are already cached). Friends and the feed start with an empty state ("choose a friend / post"), because opening a chat marks messages read and connects XMPP.
- Providers are keyed by id, so state survives; add `PageStorageKey`s for scroll positions.

**Alternative rejected:** a nested Navigator inside the detail pane. It is more robust but heavy, and it duplicates the branch navigators.

### 2.5 Landscape rules (phones)

- Rail instead of the bottom bar; rail and content respect start and end safe insets (notch, Dynamic Island).
- Collapsing app bar (56 dp, floating), 48 dp pinned strips; content gets at least 60% of the height at 360 dp.
- Single-pane detail (push); list grids follow `maxCrossAxisExtent`. Store daily is 2 columns from 568 dp content.
- Sheets: `live_game_sheet.dart` (0.92 of 360 = 331 dp) already switches to the compact header below 720 dp of height. Add a test at 800×360.
- Never lock orientation. Skin video can go immersive in landscape (P2).

### 2.6 Foldables

- `WindowInfo.hinge` comes from `MediaQuery.displayFeaturesOf`, filtered to `hinge` or `fold` features that cross the window (Android only).
- In `ListDetailScaffold`, a vertical hinge splits the panes at the hinge bounds, with the gap equal to the hinge width, so nothing sits under it. `HomeColumns` does the same with 2 columns, per HOME.md.
- Tabletop posture (horizontal hinge, half-open): top and bottom split for the live-game sheet and skin video (P2).
- `configChanges` already avoids activity restarts on fold and unfold. Cover the rail-to-bar switch with the `GlobalKey` rule above.

### 2.7 iPad and Android platform config

**iOS**
- Change nothing for Split View, Slide Over or Stage Manager. Keep 4 iPad orientations, no `UIRequiresFullScreen`, `TARGETED_DEVICE_FAMILY "1,2"`, and `UIApplicationSupportsMultipleScenes = false` (revisit multiple windows later).
- `SceneDelegate.swift`: override `scene(_:willConnectTo:options:)` (call `super`) and set `windowScene.sizeRestrictions?.minimumSize` to about 320×400 inside `#available(iOS 16, *)`. This stops iPadOS 26 free-form windows from going below the layout's minimum.
- **i18n phase:**
  - `CFBundleLocalizations` for the 18 locales in Apple codes: `ar, de, en, es, es-MX, fr, id, it, ja, ko, pl, pt-BR, ru, th, tr, vi, zh-Hans, zh-Hant`.
  - `CFBundleDevelopmentRegion = en` (a Vietnamese fallback is wrong for a global app), matching `knownRegions`.
  - Per-language `InfoPlist.strings` for `NSPhotoLibraryUsageDescription`.

**Android**
- Keep `AndroidManifest.xml` free of `screenOrientation`, `resizeableActivity="false"` and aspect-ratio attributes (static test below).
- Edge-to-edge under `targetSdk 36`: **verify** inset handling with 3-button navigation on Android 15 and 16, and landscape cutouts; consider an explicit `SystemChrome.setEnabledSystemUIMode(edgeToEdge)`.
- **i18n phase:** `android:localeConfig="@xml/locales_config"` and `res/xml/locales_config.xml` with the 18 tags (`ar-AE`, `zh-CN`, `zh-TW`, `es-MX`, `pt-BR`, …).

### 2.8 Accessibility fix list

**P0 (correctness)**
- **A1. Tap actions.**
  - New `lib/core/ui/a11y/semantic_button.dart`: `SemanticButton` = `Semantics(button, label, selected, toggled, onTap, onLongPress, excludeSemantics)` around its child.
  - Migrate the 30 `excludeSemantics: true` sites, prioritising `floating_nav_bar.dart`, `segmented_tabs.dart`, `store_ui_bits.dart`, `community_widgets.dart` and `wishlist_row.dart`.
  - Test with `isSemantics(hasTapAction: true)`.
- **A2. Dark contrast.** Owner decision: either a fill no lighter than about `#D93A48` (white text about 4.5:1) or ink text on the brand red (about 5.6-6.3:1). Then add a dark-theme contrast test and update `contrast_test.dart:22-23`.
- **A3. Reduced motion.**
  - `SkeletonShimmer` renders static boxes when `MediaQuery.disableAnimationsOf(context)` is true.
  - `SkinVideoView` does not autoplay under reduced motion (show a poster and play button) and pauses when the app is backgrounded.
  - Add `ValMotion.resolve(context, d)` for any custom delay or pulse (HOME.md's focus pulse).
  - Keep countdown rings; they are information.
- **A4. Text scale.**
  - Global safety net in `MaterialApp.builder`: `MediaQuery.withClampedTextScaling(maxScaleFactor: 3.0)`.
  - Fix the fixed-height rows in 1.3: `top_skins_section.dart:332`, the `TabPageScaffold` toolbar, `friends_screen.dart:88`.
  - Raise chrome clamps to about 1.3, with a taller bar or a 2-line rail label.
  - Raise nav and small-caption fonts to at least 11 sp.
- **A5. Touch targets.** `_Segment` hit area at least 48 dp (keep the 40 dp pill visually, enlarge the hit area outside the `Ink`), `AccountChip` hit area at least 48 dp, `catalog_tile.dart:175` to 48.

**P1**
- **A6. Non-colour cues.**
  - Add a glyph (check, cross, dash) inside the form-strip squares (enlarge to about 18 dp).
  - Add a won/lost glyph or word in `_RoundLine` and on the round strip.
  - Add a rarity name or a pip count where only the icon shows, once the tier-icon shape question in 1.7 is answered.
- **A7. `AccountChip` semantics.** Label "Tài khoản: {name}, đổi tài khoản[, cần đăng nhập lại]". Add a semantic "new" on the segment dot.
- **A8. `NetImage`.** Optional `semanticLabel`; default to `ExcludeSemantics` for decorative images. Pass names where the image is the only content.
- **A9. Headings.** `SectionLabel` and the `TabPageScaffold` title get `Semantics(header: true)`.
- **A10. Announcements.** `SemanticsService.announce` after mutations (wishlist toggle, equip, agent lock) and on list-detail selection. Do not announce refreshes.
- **A11. Keyboard and pointer.**
  - Replace `GestureDetector` tappables with `InkWell` (`preferences_sections.dart:284`, `skin_video_view.dart:145`, `media_grid.dart:315`).
  - Add `FocusTraversalGroup` per pane and the rail.
  - Add Cmd/Ctrl+1..5 and Esc to close a detail pane.
  - Hover tooltips on the rail.
  - `Scrollbar` on wide windows.
- **A12. Traversal order.** `OrdinalSortKey`, master before detail, rail first (start edge). HOME.md already specifies this for `HomeColumns`.

**P2**
- High-contrast theme variant (`MediaQuery.highContrast`), a colour-vision-assist palette toggle, and an audit of Voice Control (visible label equals semantic label).

### 2.9 Tests to add

All golden-free: assert on rects, finders, semantics and `tester.takeException()`.

**Harness: `test/helpers/device_matrix.dart`**
- `enum TestDevice { phone(360, 800), tablet7(600, 960), ipad(1024, 1366), phoneLandscape(800, 360), foldInner(…) }`.
- `pumpAt(tester, widget, {device, textScale = 1, TextDirection dir, bool reduceMotion, EdgeInsets padding, List<DisplayFeature> features, Brightness})`. Reduced motion is set through `tester.platformDispatcher.accessibilityFeaturesTestValue` (the framework's own check) plus the `MediaQuery` value; **verify** the fake-features API name in flutter_test.
- `forEachDevice(...)` helper so per-feature tests stay short.

**Unit and widget tests**
1. `test/core/ui/layout/window_size_test.dart` (pure): class boundaries (599/600, 839/840, 1199/1200; heights 479/480 and 899/900), `useRail`, `useTwoPane`, hinge filtering.
2. `test/app/shell_adaptive_test.dart`:
   - 360×800: bar, no rail, 5 destinations.
   - 600×960: rail, no bar, all labels.
   - 1024×1366: rail, content capped.
   - 800×360: rail, no bar, chrome at most 40% of the height.
   - Text 2.0× at 360×800: no overflow, single-line label.
   - RTL: rail on the right edge, first destination at the top; bar order reversed.
   - Rotate 360×800 to 800×360 with a pushed detail: the branch stack survives (`GlobalKey`).
   - Semantics: `isSemantics(isButton, isSelected, hasTapAction: true)`.
3. `test/core/ui/layout/list_detail_test.dart`: panes at 1024×1366 and 840 wide; single pane at 600×960 and 800×360; hinge splits at the fold; selection round trips through the URL; compact to expanded and back (profile to match, friends to chat, feed to post).
4. Per tab (`test/features/<f>/ui/<f>_adaptive_test.dart`) using `forEachDevice` at the required sizes:
   - Home, Store, Community (3 sections), Collection, Profile, Settings.
   - Assert no exceptions, column counts (Store daily 1 versus 2), the widest card is at most its cap, side insets respected (`padding: EdgeInsets.only(left: 47)`).
5. `test/a11y/guidelines_test.dart`: `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` for the shell plus each tab root at 360×800, 800×360 and 1024×1366. `textContrastGuideline` in light and dark on a few deterministic screens only (it is slow), tagged `a11y`.
6. `test/a11y/reduced_motion_test.dart`: with reduced motion on, `pumpAndSettle` completes on a skeleton screen (a running shimmer would time out); `SkinVideoView` (it has a `controllerFactory`) never calls `play`.
7. `test/a11y/text_scale_test.dart`: tab roots at 2.0 and 3.0, plus `TopSkinRow` and the `TabPageScaffold` title.
8. `test/a11y/rtl_test.dart`: `locale: ar` plus `Directionality.rtl`; no overflow; strips start on the right; match-card avatar is on the right half; overlays mirrored.
9. `test/platform_config_test.dart` (reads files as text): no `UIRequiresFullScreen`; 4 iPad orientations; `TARGETED_DEVICE_FAMILY` contains 2; the manifest has no `screenOrientation` or `resizeableActivity="false"`. Added in the i18n phase: 18 `CFBundleLocalizations` and a `locales_config.xml` with 18 tags.
10. `test/tool/a11y_lint_test.dart` (regex): every `IconButton(` has `tooltip:`; no `Semantics(... excludeSemantics: true` without `onTap:` (with an allow-list of decorative ones); no `setPreferredOrientations`; the count of physical-direction patterns must not exceed a shrinking baseline.

The existing `test/app/shell_test.dart` (6 tabs, `compact` below 420) is rewritten by HOME.md's M1. Do the adaptive shell tests on top of that rewrite rather than twice.

## 3. Sequencing

1. **S1, foundation:** `WindowInfo`, breakpoints, device-matrix harness, the static config test, `SemanticButton` and its migration, the contrast decision (A1, A2).
2. **S2, adaptive shell:** `FloatingNavRail`, the shell switch with `GlobalKey`, `TabPageScaffold` (side insets, max width, landscape chrome), per-tab column rules (2.3). Land together with, or straight after, HOME.md M1.
3. **S3, list-detail and foldables:** the `ListDetailScaffold`, URL selection, view extraction, hinge handling (2.4, 2.6).
4. **S4, remaining a11y P0 and P1:** reduced motion, text scale, touch targets, non-colour cues, `NetImage`, headings, keyboard (2.8).
5. **S5, tests:** fill the matrix per feature as each slice lands, not at the end.

## 4. What goes in the i18n phase versus separately

| Item | Phase | Reason |
|---|---|---|
| `WindowInfo`, breakpoints, rail, content caps, list-detail, hinge | **Separate, now** | Layout only, no strings. |
| `SemanticButton` migration (A1), touch targets (A5), reduced motion (A3), contrast fix (A2), `SkeletonShimmer`/video | **Separate, now** | Independent of language. |
| Landscape chrome, side safe areas, text-scale fixes and the 3.0× cap (A4) | **Separate, now** | Test at 2.0× and 3.0× in Vietnamese first. |
| iPad `SceneDelegate` minimum size, platform-config tests | **Separate, now** | No localization involved. |
| Non-colour cues (A6), `AccountChip`/dot semantics (A7), announcements (A10), nav "i of n" hint | **Now, but create the new strings in the i18n system**, or as `XStrings` functions ready for ICU | Avoids migrating them twice. |
| Directional codemod (`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`; about 320 sites) | **Start now (mechanical, safe); finish and verify in the i18n phase** | RTL cannot be verified until `ar-AE` is selectable. |
| RTL tests and mirrored custom painters and gradients | **i18n phase** | Needs the `ar` locale and strings. |
| Locale-aware uppercase (`SectionLabel`, `TierTag`, 51 sites), `letterSpacing` per script, font fallback (Anton has no Cyrillic; no bundled Arabic, CJK or Thai) | **i18n phase** | HOME.md §9.6 already assumes this. |
| Longest-string nav and chip label tests in 18 languages (pseudo-locale at 360 dp, 1.3× and 2.0×) | **i18n phase** | Needs real translations. |
| `CFBundleLocalizations`, `CFBundleDevelopmentRegion = en`, `InfoPlist.strings`, `locales_config.xml`, `MaterialApp` locale and delegates | **i18n phase** | Platform localization. |

## 5. Conflicts with HOME.md and open decisions

- **Rail threshold.** HOME.md §2.7 puts the rail at width 840 or more, or landscape phone. This plan uses 600 (medium) to match "rail on medium and expanded". Update HOME.md §2.7 and §9.1. HOME.md's `HomeColumns` thresholds (568 and 1000 dp of content) stay, but should consume `WindowInfo`.
- **Shared pieces.** `TabPageScaffold.controller` (HOME.md) and `contentMaxWidth` (this plan) land in one edit. The reduced-motion helper in HOME.md §9.3 should be this plan's A3 helper. HOME.md's a11y test list (§12.4) should reuse the device-matrix harness.
- **Owner decisions:**
  1. Brand-red fill versus ink text (A2).
  2. Auto-select the newest match on expanded Profile.
  3. Extended rail (labels beside icons) at 1200 dp or more: optional.
  4. Multiple iPad windows: keep off for now.
- **Verify on device or in a test before relying on it:**
  1. Missing tap action for the `excludeSemantics` wrappers (TalkBack, VoiceOver).
  2. The framework's 5% shortening of finite animations under reduced motion.
  3. The 640 dp M3 bottom-sheet cap on tablets.
  4. Whether Riot tier icons differ only by colour.
  5. The 3.4:1 red contrast (`contrastRatio(ValColors.red, Colors.white)`).
  6. go_router keeps branch stacks when the `GlobalKey`'d shell re-parents on rotate or fold.
  7. `SemanticsRole` availability in Flutter 3.47.
  8. Edge-to-edge and cutout behaviour on Android 15 and 16.

## 6. Key files

- Shell and chrome: `D:\ValVN\lib\app\shell.dart`, `D:\ValVN\lib\core\ui\floating_nav_bar.dart`, `D:\ValVN\lib\core\ui\tab_page_scaffold.dart`, `D:\ValVN\lib\core\ui\segmented_tabs.dart`
- Routes for list-detail: `D:\ValVN\lib\features\profile\profile_routes.dart`, `D:\ValVN\lib\features\social\social_routes.dart`, `D:\ValVN\lib\features\community\community_routes.dart`
- A11y and motion: `D:\ValVN\lib\core\ui\skeleton.dart`, `D:\ValVN\lib\features\skin_detail\skin_video_view.dart`, `D:\ValVN\lib\core\ui\net_image.dart`, `D:\ValVN\lib\core\accounts\account_widgets.dart`
- Theme and contrast: `D:\ValVN\lib\core\theme\app_theme.dart`, `D:\ValVN\test\core\theme\contrast_test.dart`
- Platform: `D:\ValVN\ios\Runner\Info.plist`, `D:\ValVN\ios\Runner\SceneDelegate.swift`, `D:\ValVN\android\app\src\main\AndroidManifest.xml`
- Existing specs to keep aligned: `D:\ValVN\docs\design\HOME.md` (§2.7, §9), `D:\ValVN\docs\design\IA.md`
