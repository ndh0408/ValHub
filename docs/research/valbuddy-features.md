# ValBuddy: feature and screen inventory, ValVN screen map and Vietnamese UI glossary

> Research date: **2026-09-28**. Target: clone every user-facing feature of **ValBuddy 2.1.2**
> (App Store id6757810434, released 2026-09-24) in Flutter, with a Vietnamese (vi-VN) UI.
> Valorant client today: `release-13.06-shipping-13-5435758` (valorant-api.com `/v1/version`).
> Patch 13.06 went live on 2026-09-22 (see §7.3; ValBuddy has not caught up with it yet).
>
> This file covers **what** to build and **what to call it**. For **how** (endpoints and auth), see
> `docs/research/riot-endpoints.md` and `docs/research/riot-auth.md`. Section references like "EP §5.1"
> point into `riot-endpoints.md`.
>
> Method: primary sources only for ValBuddy (App Store listing + iTunes lookup API, the 11 App Store
> screenshots viewed image by image, valbuddy.app home/changelog/privacy/terms). We did **not**
> decompile ValBuddy's public APK: its Terms (§4) forbid reverse engineering. Vietnamese terms come from
> valorant-api.com with `language=vi-VN` (the game's own localisation), the Vietnamese patch notes of
> the VN publisher VNGGames, and two open-source Vietnamese translations (SkinPeek `vi.json`, VShop `vi.json`).

---

## 0. TL;DR

- ValBuddy is a free, **iOS-first** Valorant companion by Patrick Bender. v1.0 shipped 2026-01-16 and v2.1.2 on
  2026-09-24. It is English-only and has no servers ("0 servers"): tokens stay on the device and game data
  comes straight from Riot plus valorant-api.com. It has 328 US ratings at 4.8★ and is in the Lifestyle
  category. The iOS app shows AdMob banner ads. An Android APK (v2.1.0) is sideload-only, has no ads, and
  "Google Play in preparation".
- **Five bottom tabs** (screenshots): **Store · Battle Pass · Collection · Profile · Settings**. A
  full-screen **Game Details** sheet opens on top when a match is found. Profile holds the sub-screens
  **Friends & Chat**, **Party / Remote Queue**, **Daily RR** and the **Rank-Up Calculator**.
- **Confirmed feature areas** (§2, 70+ items):
  - Store: daily store, Night Market, accessory store, bundles, wallet.
  - Skin detail: video, chromas, levels.
  - Per-account **wishlist** with background local notifications across all accounts.
  - Store-reset notification.
  - Collection browser: filters, sort, collection value.
  - Full loadout editing: card, title, weapons, expressions, presets.
  - Battle pass level/XP and weekly missions with a countdown.
  - Rank/peak/true peak, Daily RR, Rank-Up Calculator.
  - Match history with mode/map filters, scoreboard with ranks.
  - Live game: agent select hover/lock, teams with ranks and peak, everyone's loadout, live round score,
    final scoreboard, quit match.
  - Party and remote queue, friends with presence, Riot chat.
  - Up to **10 accounts**; console platform switch; session-log export; clear cache.
- **ValBuddy does not have:** home-screen widgets, Live Activities, store history or statistics,
  leaderboard, player search, crosshairs, a light theme (UNCONFIRMED) or localisation. Competitors do
  (§4), and some make cheap ValVN differentiators.
- **Vietnamese naming.** The in-game vi-VN client uses these terms:
  - **Cửa Hàng Phụ Kiện**, **Chợ Đêm**, **Bộ Sưu Tập**, **Thẻ Người Chơi**, **Hình Phun Sơn**,
    **Danh Hiệu**, **Phụ Kiện Súng** (gun buddy), **Tổ Hợp Cảm Xúc** (expressions).
  - Queues: **Thi đấu xếp hạng / Đấu Xếp Hạng**, **Đấu thường**, **Siêu Tốc**, **Đặt Spike Nhanh**,
    **Sinh Tử**.
  - **Phần** = Act, **Mùa** = Season, **ĐXH** = RR.
  - Content tiers are **Phiên Bản Tuyển Chọn / Sang Chảnh / Cao Cấp / Độc Quyền / Siêu Cấp**.
  - Ranks are **Sắt … Bất Tử, Radiant**.

  Vietnamese players keep VP, RR, K/D/A, ACS, HS%, skin, bundle, Battle Pass, rank, wishlist and
  Night Market in English (§8).

---

## 1. ValBuddy at a glance

| Field | Value | Source |
|---|---|---|
| Name / bundle id | ValBuddy / `com.valbuddy.app` | [AS] |
| Developer | Patrick Bender (EU; ToS governed by EU law, € pricing) | [AS] [TOS] |
| Current version | 2.1.2 (2026-09-24). First release 1.0 on 2026-01-16 | [AS] [CL] |
| Platforms | iPhone and iPad (iOS/iPadOS 16.4+), Mac with Apple M1+ ("Designed for iPad. Not verified for macOS"), visionOS 1.0+. Android: APK `https://builds.valbuddy.app/ValBuddy%20v2.1.0.apk`; "Android release is in preparation", Google Play button pending | [AS] [WEB] |
| Size | 65.3 MB | [AS] |
| Category / age | Lifestyle (genres Lifestyle, Casual, Games) / 4+, "Contains Messaging and Chat" | [AS] |
| Ratings | 4.75 avg, 328 ratings (US). mwm.ai claims "#1 US Free Lifestyle", "50,000+ downloads", "2,100+ ratings" (UNVERIFIED, likely global or estimated) | [AS] [MWM] |
| Languages | English only | [AS] |
| Price | Free, no IAP, no subscription. iOS shows Google AdMob **banner ads** (UMP consent + ATT). Android has no ads. Older snippets said "no ads"; that changed around 2026-09 | [WEB] [PP] [TOS] |
| Privacy model | No backend. Riot tokens and cookies live in Keychain/Keystore, scoped per account. Game data is fetched directly from Riot and cached locally. Notifications are **local** (no push tokens). Only third parties: Riot, valorant-api.com, AdMob (iOS) | [PP] |
| Login | In-app web view on Riot's official page (`auth.riotgames.com`); Google sign-in supported | [PP] [CL 1.2.0] |
| Accounts | Up to 5 (site, privacy policy and App Store description still say 5), raised to **10** in 2.1.0 | [CL] |
| Community | Discord (`valbuddy.app/discord`), public changelog, contact e-mail | [WEB] |

### Evidence codes

| Code | Source (all read 2026-09-28) |
|---|---|
| [AS] | App Store page `apps.apple.com/us/app/valbuddy/id6757810434` + `itunes.apple.com/lookup?id=6757810434` (description, full version history, privacy labels) |
| [SS-n] | App Store iPhone screenshot n (0–6, taken around v2.0.0, June 2026; Settings shows "Version 2.0.0") |
| [SSiPad-n] | App Store iPad screenshot n (0–3, simulator shots dated 2026-01-14, i.e. v1.0) |
| [CL] | `valbuddy.app/changelog` (last updated 2026-09-24; same text as App Store "What's New") |
| [WEB] | `valbuddy.app` home page (features, pricing, FAQ) |
| [PP] / [TOS] | `valbuddy.app/privacy` (2026-09-23) / `valbuddy.app/terms` (2026-09-25) |
| [MWM] | mwm.ai app listing (secondary; numbers not trusted) |
| [VAPI-VI] | valorant-api.com `?language=vi-VN` vs `en-US` (currencies, contenttiers, competitivetiers, gamemodes, gamemodes/queues, agents, weapons, contracts, events, seasons, ceremonies, gear, buddies, sprays, playercards, playertitles, flex, levelborders, bundles, missions) |
| [VNG] | VALORANT Vietnam publisher VNGGames: `valorant.vnggames.com/vi-vn/news/game-updates/valorant-patch-notes-7-0/`, `…-10-00/`, `…-12-00/`; `community.vnggames.com/news/val/…` (Night Market 7/2025, V26 Act 3 article) |
| [PV] | playvalorant.com: vi-vn "Cửa hàng VALORANT và Vật Phẩm Trang Trí" (2020); en-us "Patch Notes 13.06" (2026-09-22) |
| [SP-VI] | github.com/giorgi-o/SkinPeek `languages/vi.json` (by Mistral & VanhDeepTryy) + README |
| [VS-VI] | github.com/GinzaTech/Vshop `assets/i18n/vi.json` + README (Vietnamese-authored RN companion, 2026-09) |
| [COMP] | Competitor listings: see §4 |

---

## 2. Confirmed ValBuddy features

"Since" is the first version that shipped the feature (per [CL]). IDs are stable, so use them in tickets.

### 2.1 Account, sign-in, sessions

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| A1 | Riot sign-in in an in-app web view | Official Riot page (`auth.riotgames.com`); the app never sees the password | 1.0 | [WEB] [PP] |
| A2 | Sign in with Google | "Sign in with Google for a faster login experience" (a social provider on Riot's page) | 1.2.0 | [CL] [AS] |
| A3 | Multi-account | "Switch Riot accounts in two taps. Sessions stay separate". Limit 5, then **10** from 2.1.0. Settings header shows "ACCOUNTS (5/5)" | 1.0 / 2.1.0 | [WEB] [CL] [SS-6] |
| A4 | Account list row | Player-card avatar, name (Riot ID), region + level subtitle, rank icon ("?" when unranked), red active-account marker, red trash (remove) button, "+ Add Account" | 2.0.0 | [SS-6] |
| A5 | Robust session keep-alive | Connection drops or timeouts do not sign you out; "only Riot actually asking for your password does". Full login (cookies) is stored, so sessions last "weeks rather than days" | 2.0.3 | [CL] |
| A6 | Safe account switch | Failed switch → "asked to try again instead of being sent to the login screen" | 2.0.3 | [CL] |
| A7 | Auto-restore wrongly signed-out accounts | Accounts restored on app open | 2.0.3 | [CL] |
| A8 | Console platform | Settings switch **PC / PlayStation / Xbox** so match history and stats come from the right platform | 2.0.2 | [CL] |
| A9 | Request timeout and retry | Riot requests time out after 30 s and show retry instead of an endless "Loading…" | 2.1.0 | [CL] |
| A10 | Export session log | Settings → share a technical log of session events and failed requests. No passwords, tokens or account IDs | 2.0.3 / 2.1.0 | [CL] |
| A11 | Sign-out wipes data | Removing an account deletes its tokens and cache | 1.0 | [PP] |

### 2.2 Store

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| B1 | Daily store | 4 weapon skins. Each card has a render on a tier-tinted gradient, the tier icon, name and VP price. Header countdown "Resets in 11:54:37" (reset is 00:00 UTC = **07:00 in Vietnam**; the screenshots' local time plus the countdown match this) | 1.0 | [WEB] [SS-0] [SSiPad-0] |
| B2 | Wallet bar | VP · Kingdom Credits · Radianite (e.g. "2.440 · 2.113 · 40") in a pill under the title | 1.0 | [SS-0] |
| B3 | Accessory store | Weekly KC rotation (cards, sprays, buddies, titles). Each row shows a type label ("Spray", "Buddy") and KC price. Countdown shown in hours ("150:03:46") | 1.0 | [SSiPad-1] [SS-0] |
| B4 | Featured bundles | Banner art, name, total VP price, countdown ("8d 01:03:40") | 1.0 | [SSiPad-2] [AS] |
| B5 | Night Market tab | "Check your exclusive offers directly in the app when it's available" (tab appears only while active). Shows your personal discounts | 1.1.3 | [CL] [WEB] |
| B6 | Store segmented control | Daily · (Night Market) · Accessories · Bundles. v2.1.2 made "every tab fit its full name (no more 'Night …')" | 1.0 / 2.1.2 | [SS-0] [CL] |
| B7 | Skin detail sheet | Title and close button. Preview image with **▶ video** button. Edition row (tier icon + "Exclusive Edition") + price. **Variants** (chroma swatches). **Upgrades** chips Lv1…Lv5, each with ▶ (level video); selected chip in red. Opened from the ↗ button on each card | 1.0 | [SSiPad-3] |
| B8 | Store reset notification | "Get a push the moment your daily store refreshes, even with the app closed". Local notification; toggle "Store Reset Notification" | 2.0.0 | [CL] [SS-6] [PP] |
| B9 | Correct skin prices | Exclusive bundles are priced per bundle (e.g. Kuronami Vandal 2,375 VP; Champions/Spectrum 2,675). Prices come from ValBuddy's own website list, so fixes don't need an app update | 2.1.1 | [CL] |
| B10 | Compact cards, faster images | Denser layout; improved image caching | 2.0.0 | [CL] |

### 2.3 Wishlist and notifications

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| W1 | Skin wishlist | "Mark any weapon skin you are after" | 2.0.3 | [CL] |
| W2 | Wishlist alerts | Notified when a wishlisted skin appears in the **daily shop, the Night Market or a featured bundle**. "Switch on the background check in Settings" to get alerts while the app is closed (local notifications) | 2.0.3 | [CL] [PP] |
| W3 | Per-account wishlists | Each account keeps its own list; switching accounts doesn't mix them | 2.0.4 | [CL] |
| W4 | All-accounts background check | The background job walks every added account. The notification says **which account** the skin is waiting in | 2.0.4 | [CL] |
| W5 | Deep link to account | Tapping a wishlist notification switches to that account and shows the item | 2.0.4 | [CL] |
| W6 | Sticky picks | Skins aren't dropped when another account owns them. The list survives sign-out and re-add | 2.0.4 | [CL] |
| W7 | Wishlist filter, sort, search and value | Same tier filter and sort as the collection; wishlist total value | 2.1.0 | [CL] |

### 2.4 Collection and loadout (Collection tab)

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| C1 | Collection tab | "Customize your loadout and view your inventory" | 1.1.0 | [CL] |
| C2 | Hub header | Equipped player card (wide art) with its name as a caption | 1.1.0 | [SS-2] |
| C3 | Loadout section | Rows: **Change Banner** (value = current card name), **Change Title** (value = current title text), **Weapon Loadout**, **Expressions**, **Loadout Presets** | 1.1.0+ | [SS-2] |
| C4 | Weapon customisation | "Customize your loadout with skins, chromas & buddies" | 1.1.0 | [AS] |
| C5 | Browse section | **Skins, Buddies, Sprays, Player Cards, Titles**, plus more rows cut off by the tab bar in the screenshot (see U-list) | 1.1.0 | [SS-2] |
| C6 | Rarity sort | Weapon skins always rarest-first (later made configurable by C7) | 2.0.2 | [CL] |
| C7 | Skin filters everywhere | Pick content tiers; sort by **rarity, name, weapon or price** from a sort menu next to the search bar. Applies to the collection browser, the weapon skin picker and the wishlist | 2.1.0 | [CL] |
| C8 | Collection value | "What your skins are worth at store prices", for the whole collection, the filtered subset and the wishlist. Per skin: edition list price, or the exact shop/bundle price when known | 2.1.0 | [CL] |
| C9 | Reward skins labelled | Never-sold skins show their source (**Battle Pass, agent contract, event pass**) instead of a price, and are excluded from value | 2.1.0 | [CL] |
| C10 | Glass search bars | In the collection browser, weapon picker, **banners** (cards), **expressions** and wishlist | 2.1.0 | [CL] |

### 2.5 Battle Pass tab

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| P1 | Current pass card | "Season 2026 // Act III". "Level 46 / 55". Red progress bar. Level XP "7.966 / 35.750 XP" and total XP "840.466 / 1.162.500 XP" (1,162,500 = the real total for a 55-level 2026 pass per valorant-api) | 1.0 | [SS-1] [VAPI] |
| P2 | View All Rewards | Row with gift icon: "46/55 unlocked ›" opens the reward track | 1.0 | [SS-1] |
| P3 | Weekly missions | Header "Weekly Missions" with a reset countdown ("2d 15:09:24"). Each row: status circle, title ("Use Your Ultimate"), red progress bar, "8 / 15", "+38.400 XP". Done: green check with struck-through title | 1.0 | [SS-1] |
| P4 | Daily missions | "Daily & weekly missions" (description). In today's game these are the **Daily checkpoints** (EP §12.2) | 1.0 | [AS] |
| P5 | "All Missions Completed" state | A clear state once dailies and weeklies are done | 2.0.0 | [CL] |

### 2.6 Profile, rank and match history (Profile tab)

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| R1 | Identity header | Player card banner, Riot name, "Level 222", account-XP bar "184 / 5.000 XP" | 1.2.0 | [SS-3] |
| R2 | Rank card | Two columns: **Current** (icon, "Diamond 1", "6 RR") and **Peak – V26 – ACT I** (icon, "Diamond 2", "0 RR") | 1.2.0 | [SS-3] |
| R3 | True Peak Rank | Peak shows the highest RR ever held in that tier, from **on-device ranked history** | 2.1.0 | [CL] |
| R4 | MMR / RR tracking | "Track your rank, MMR, and RR changes after every match". The site mock shows "+24 RR" / "-17 RR" per match | 1.2.0 | [AS] [WEB] |
| R5 | Daily RR screen | Per ranked session day: net RR, W/L, start and end rank, every match in between. Days cut at **local midnight**; history kept on device | 2.1.0 | [CL] |
| R6 | Rank-Up Calculator | Under Profile › Rank. Pick a target rank (up to **Immortal 1**) and see RR left, matches needed "at your current form", best case in straight wins, and how the count changes at **45–65 %** win rate. The profile hints "≈ 9 matches to Gold 3" | 2.1.2 | [CL] |
| R7 | Current Game card | "Not in a game" with a live-signal icon and a **refresh countdown ring**. Shows live round score "8 – 4" while in game (R-G7) | 1.2.0 | [SS-3] [CL] |
| R8 | Match history list | Filter chips **All · Competitive · Unrated · Swiftplay · Spike Rush · …** (horizontal scroll). Card: map splash, "Icebox 4 - 5 **Defeat**", "K/D/A: 5/9/1 · 18h ago", mode label ("Swiftplay") | 1.2.0 | [SS-3] |
| R9 | Mode and map filters | "Filter your Match History by game mode and map" | 2.0.0 | [CL] |
| R10 | Match detail | "Full Match History with K/D/A stats, RR changes, and round details"; "round breakdowns" | 1.2.0 | [CL] [AS] |
| R11 | Ranks on scoreboard | Every player's competitive rank next to their agent | 2.0.3 | [CL] |
| R12 | Mode-correct stats | Deathmatch score = your kills vs the best of the rest ("17 - 40" loss, "40 - 37" win). Team Deathmatch uses the real team score. HS rate "–" in no-hit-data modes (Skirmish, DM). Combat score (ACS) shown there too | 2.1.1 | [CL] |
| R13 | Friends' profiles | From a chat's top-right profile button: friend's rank, peak rank, match history | 2.1.2 | [CL] |
| R14 | Other players' stats | "Track other players live and view their stats" (from the live game roster) | 1.2.0 | [CL] |

### 2.7 Live game ("Game Details" sheet)

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| G1 | Live game detection | "See your current match and team composition in real time"; "See who you're playing with from agent select on" | 1.2.0 | [CL] [WEB] |
| G2 | Auto-open | Sheet opens automatically when a match is found. Toggle "Open Game Automatically" | 2.0.0 | [CL] [SS-6] |
| G3 | Sheet header | "Game Details" + ✕. Map splash, map name + mode ("Ascent / Competitive"), refresh button, status pill (**Agent Select** amber / **In Progress** green) | 1.2.0 | [SS-4] [SS-5] |
| G4 | Agent select | Tabs **Agents · Your Team**. Hint "**Tap to hover an agent, hold to lock.**" Circular portrait grid, 5 per row, all 29 agents incl. Miks, Tejo, Veto, Waylay | 1.2.0 / 2.0.0 | [SS-4] |
| G5 | Rosters | In progress: tabs **Your Team · Enemy Team**. Row: agent portrait, name, "Level N · Agent", rank icon + tier name, chevron | 1.2.0 | [SS-5] |
| G6 | Peak rank in roster | "See the highest rank every player has ever reached". Toggle "Show Peak Rank in Game Details" | 2.0.0 | [CL] [SS-6] |
| G7 | Live match score | Current round score on Profile and in the sheet, centred above the roster, updated each round. Toggle **Settings › Live Match Score** | 2.1.0 | [CL] |
| G8 | Everyone's skins | Tap a player to see their full equipped loadout | 2.1.0 | [CL] |
| G9 | Refresh with countdown ring | Header refresh button with a ring. All modes show proper names (Escalation, Replication, Knockout, Retake, Skirmish, …) | 2.1.0 | [CL] |
| G10 | Quit match | Red "Quit Match" button at the bottom in agent select **and** in a running match, with a confirmation | 1.2.0 / 2.1.1 | [SS-4] [CL] |
| G11 | Final scoreboard | When the match ends the sheet turns into the finished scoreboard (K/D/A for all) once Riot publishes it. The profile picks up the new RR and match | 2.1.2 | [CL] |

### 2.8 Party and social

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| S1 | Party and remote queue | Pick the queue, start or leave matchmaking, ready up, accept invites, share a party code or join with one, "while VALORANT runs on your PC or console" | 2.1.0 | [CL] |
| S2 | Member ranks | Every member's current rank + RR in any queue | 2.1.0 | [CL] |
| S3 | One-tap invites | Strip of online friends' avatars; tap to invite. Members and already-invited friends are ticked | 2.1.0 | [CL] |
| S4 | Smart party screen | Limited-time modes by real name. Competitive stays selectable and explains why the party can't queue. A countdown ring shows the next refresh. **Swipe left on a member → Remove**. Queue changes are locked during a match. Code fields scroll above the keyboard | 2.1.0 | [CL] |
| S5 | Friends list | Profile › **Friends & Chat**. Shows the Riot friends list with what each friend is doing: in a match + map, in queue, in the lobby, away, or last online. Avatar = their player card while in VALORANT. Unread counts | 2.1.0 | [CL] |
| S6 | Chat | Message any friend. History loads from Riot chat and new messages arrive live | 2.1.0 | [CL] [AS age label] |
| S7 | Chat header | Friend name + status next to the back button. Profile button top right (→ R13) | 2.1.2 | [CL] |

### 2.9 App, settings and platform

| ID | Feature | Details | Since | Source |
|---|---|---|---|---|
| X1 | Settings: Preferences | Toggles: **Open Game Automatically**, **Show Peak Rank in Game Details**, **Store Reset Notification**. Added later: **Live Match Score**, wishlist **background check**, **platform** PC/PS/Xbox | 2.0.0–2.1.0 | [SS-6] [CL] |
| X2 | Settings: App | **Version** (e.g. "2.0.0"), **Clear cache** ("Storage" option since 1.1.0), **Export Session Log** | 1.1.0 / 2.0.3 | [SS-6] [CL] |
| X3 | Settings: Privacy | "Settings → Privacy → **Ad Privacy Choices**" (Google UMP, iOS only) | ~2.1.x | [PP] |
| X4 | Smart caching / offline | "Smart caching for fast loading and offline access" | 1.2.0 | [AS] [CL] |
| X5 | Visual style | Dark UI (black background, dark-grey rounded cards, **red accent**). Floating glass tab bar; iOS large titles | 1.0 | [SS-*] |
| X6 | Sliding tabs | Every segmented control is one glass capsule with a red highlight that slides | 2.1.2 | [CL] |
| X7 | App icon styles | Light / dark / tinted iOS icon following the Home Screen appearance | 2.1.2 | [CL] |
| X8 | iPad layout (v1.0) | Top floating segmented nav "Store · Settings"; list cards full width | 1.0 | [SSiPad-*] |
| X9 | Number format | Locale-formatted numbers ("2.440", "1.162.500"; the shots use a German locale) | 1.0 | [SS-*] |

---

## 3. Version history (condensed, from [CL] = App Store "What's New")

| Version | Date | Headline changes |
|---|---|---|
| 1.0 | 2026-01-16 | Initial: Store (Skins / Accessory / Bundle), Settings |
| 1.1.0 | 2026-01-18 | Collection tab (loadout + inventory); Storage → clear cache |
| 1.1.1 | 2026-01-20 | Multi-account fix (cookies wrongly stored in Keychain) |
| 1.1.2 | 2026-01-26 | Session refresh fix |
| 1.1.3 | 2026-02-13 | Night Market tab |
| 1.2.0 | 2026-02-24 | Google sign-in, MMR tracking, full match history (K/D/A, RR, rounds), live game detection, instant agent lock, other players' stats, caching |
| 1.2.1 | 2026-02-28 | Match filters (mode/map), store reset notifications, redesigned agent select grid, peak rank in game details, "all missions completed", auto-open game details, compact cards, image caching (same notes re-used for 2.0.0) |
| 2.0.0 | 2026-06-19 | Same feature list as 1.2.1 (major redesign release) |
| 2.0.1 | 2026-07-02 | Rank/rank icons fixed after a Valorant patch; battle pass fixed |
| 2.0.2 | 2026-07-10 | Rarity sort; stay-signed-in fix; console support (PC/PS/Xbox) |
| 2.0.3 | 2026-09-02 | Skin wishlist + background alerts; ranks on scoreboard; rebuilt session keep-alive; account restore; export session log |
| 2.0.4 | 2026-09-06 | Per-account wishlists, all-accounts background check, notification → account switch |
| 2.1.0 | 2026-09-19 | Live match score, Daily RR, true peak, party and remote queue, friends, chat, one-tap invites, everyone's skins, refresh ring, skin filters, collection value, reward-skin labels, glass search, **10 accounts**, 30 s timeouts |
| 2.1.1 | 2026-09-21 | DM/TDM scores, HS-rate dash, leave running match, prices from website |
| 2.1.2 | 2026-09-24 | Rank-Up Calculator, final scoreboard, friends' profiles, chat header, icon styles, sliding glass tabs |

Takeaway: the developer ships every few days. Features cluster around **store/wishlist** (Jan–Sep),
**live game** (Feb–Jun) and **social/party** (Sep). ValVN should plan the same three pillars.

---

## 4. Competitor survey (expected features in the category)

| App | Platform / status (2026-09) | Features beyond ValBuddy | Monetisation | vi? |
|---|---|---|---|---|
| **ValPal Companion** (`com.lonitys.valpal.companion`) | Android, Google Play, updated 2026-09-10 | Push alert for **favorite skins**; Night Market with **% off**; stats (K/D, HS%, ADR, win rate, **RR progress bar**); **strongest agents/maps, best teammates**; "no 10-match limit", full-season history; **round-by-round + kill feed**; **player search + leaderboard position** (Immortal+); party + chat with **background notifications**; **4 color themes** (Crimson, Amethyst, Emerald, Amber) | Free (Play: "no data collected") | EN/DE |
| **ValoShopTracker (VST)** (id6778869939) | iOS, released 2026-09-17 | Wishlist with **chosen level + chroma**; **store history calendar**, "frequently appearing skins", wishlist appearance stats; **VP top-up planner** (balance vs needed, top-up combos); **share store link** with friends; skin search without login; battle pass (1.9.1) | Ads | **yes (VI)** |
| **Revamped for Valorant** (id6761351068) | iOS, 2026-08 | Live scoreboard through a **desktop companion**; performance **heatmaps**; store + NM **across all accounts**; **crosshair** gallery/editor/push to game; agent suggestions; **settings presets**; Party/Team/All chat; **home-screen widgets** (light/dark); **Spending Insights** (purchase history) | Pro €3.99/mo, €39.99/yr, €89.99 lifetime; free tier limits accounts | **yes (VI)** |
| **SpikeHub** (id6775566544) | iOS, 2026-07 | Shop/NM/accessories; **LFG duo finder**; stats (rank, peak, KDA, HS%, ACS, duels); community feed; voice/text rooms | Pro: ad-free, **multiple accounts**, video posts | EN |
| **VALPAW** (valpaw.com; App Store id6476132885 **no longer returned by the lookup API**, probably delisted) | iOS | Party: start/stop queue, invites/requests, **server and mode settings, party codes**; missions: daily checkpoints, weekly, **"Queued Up Weeklies"**, **"Future Weeklies"** (preview by date); loadout (card, title, skins with colour and variant + buddy, sprays); profiles of any player with filters | n/a | EN |
| **ValoStore** (id6761961323) | iOS, open source (MIT) | Minimal daily-store viewer | Ads (native ads removed in 2.81) | EN |
| **SkinPeek** (Discord bot, giorgi-o) | Discord | Shop/bundles/NM; skin alerts; **auto-post daily shop**; **10 accounts**; **shop statistics** (which skins appear most); **view friends' shops**; **battle pass calculator** (games needed with/without weeklies); **collection value**; maintenance/incident status; hide IGN; **skin level videos** | Free, OSS | **yes (vi.json)** |
| **VShop** (GinzaTech/Vshop, fork of VShopApp) | Android APK (React Native/Expo) | Loadout editor; "Rare+" collection **image export**; animated Act record; match history with **season metrics, daily summaries, landscape scoreboard, economy, weapon stats, opponent matchups, round timeline**; pregame/live; party mgmt incl. "silent leave party"; friends + XMPP chat + **party chat**; skin gallery, **crosshair codes, leaderboard**; wishlist notifications (**donor perk**); Android **battery-optimisation warning** for background alerts | Donations | **yes (18 languages incl. vi)** |
| **Riot Mobile** (official, id1077150310) | iOS/Android | Cross-game **chat**, news, esports, match history/stats. **No store** | Free | **yes (VI)** |
| **Valking.gg**, **Spike Stats**, **Tracker Network** | iOS/Android | Stats trackers: player search, leaderboards, agent/weapon/map stats, "coach" tips, performance graphs | Ads/Pro | Spike Stats: VI |

### 4.1 Checklist of "expected" features against ValBuddy

| Expected feature | In ValBuddy? | Evidence / note |
|---|---|---|
| Wishlist + notify when the skin appears in the shop | **Yes** (daily, NM, bundles; all accounts) | W1–W6 |
| Home-screen widgets | **No evidence** (none in 15 releases) | Revamped has them. ValVN stretch: shop widget |
| Shop reset notification | **Yes** | B8 |
| Skin video preview | **Yes** (▶ on preview) | B7 |
| Chroma preview | **Yes** ("Variants") | B7 |
| Skin level preview | **Yes** ("Upgrades" Lv1..Lv5 ▶) | B7 |
| Price totals: bundle | **Yes** (bundle price) | B4 |
| Price totals: collection value | **Yes** | C8 |
| Price totals: daily-shop total | **UNCONFIRMED** | Not seen in screenshots |
| Match detail scoreboard | **Yes** (ranks, K/D/A, rounds) | R10–R12, G11 |
| Rank history chart | **No evidence of a chart**; Daily RR is a list | R5. ValVN stretch: RR line chart |
| Mission reset timers | **Yes** (weekly countdown) | P3 |
| Multi-account switching | **Yes** (10) | A3 |
| Account overview / player card | **Yes** | R1, C2 |
| Dark theme | **Yes** (dark only seen) | X5 |
| Light theme / theme picker | **UNCONFIRMED** ("follows the app theme", 2.1.0) | See U12 |
| Settings | **Yes** | X1–X3 |
| Store history / appearance stats | No | VST, SkinPeek |
| Leaderboard / player search | No (only friends' and live-roster profiles) | ValPal, Valking |
| Crosshair codes | No | Revamped, VShop |
| Localisation | No (EN only) | **ValVN's core differentiator** |

---

## 5. Likely but unconfirmed ValBuddy behaviour (U-list)

These are **UNCONFIRMED**: implied by the evidence but not shown directly. Build them the obvious
way unless new evidence appears.

| ID | Assumption | Why we think so | Risk if wrong |
|---|---|---|---|
| U1 | Store cards show a wishlist marker (heart/star), and the skin sheet has an "Add to wishlist" toggle | W1 says "mark any weapon skin"; no screenshot after 2.0.3 | Low |
| U2 | A **Wishlist** row sits in Collection › Browse Collection (below Titles, hidden behind the tab bar in SS-2), plus a catalog of *all* skins to add from | 2.1.0 mentions "the wishlist" next to the browser; you must be able to add skins you don't own | Low |
| U3 | Browse Collection also has **Flex** and maybe **Level Borders**/"Expressions" | The in-game Collection has Flex since patch 10.00 ([VNG]); the list continues below the fold | Low |
| U4 | Night Market shows base price struck through, discount % and final price for 6 cards, plus an end countdown. No "flip card" animation (the game has one) | Store is VP-centric; competitors (ValPal) show "% off" | Low |
| U5 | Tapping a bundle opens its items with per-item prices | Standard. Not in screenshots | Low |
| U6 | **Loadout Presets** are stored locally and applied with the loadout PUT (Riot has no preset API as of 13.06) | We found no Riot preset feature in patch notes | Medium: check if Riot adds server presets |
| U7 | Expressions editor edits the 4-slot "Tổ Hợp Cảm Xúc" wheel with sprays and Flex | Patch 10.00 renamed the spray wheel to the expressions wheel, which holds Flex | Low |
| U8 | The Battle Pass tab shows only the current **season** pass. Event passes and agent contracts are not listed (only used as "reward source" labels) | SS-1 shows one pass | Medium: show event pass too (cheap) |
| U9 | "Daily missions" = the 4 **daily checkpoints** (Daily Ticket), shown as a small progress section | Riot replaced daily missions in Ep 7 (EP §12.2) | Low |
| U10 | Region/shard is detected automatically (no region picker) | Nothing in screenshots. Sessions per account | Low (EP §1) |
| U11 | Rank-Up Calculator's "current form" = average RR gained per win and lost per loss over recent competitive updates | Wording in [CL] | Low |
| U12 | A light theme exists or follows iOS appearance | "glass search bar that follows the app theme" (2.1.0) | Low: ValVN can ship dark only first |
| U13 | Match detail shows a **round timeline** (win-type icons per round) | "round breakdowns" / "round details" | Low |
| U14 | Background checks use iOS BGAppRefresh (best effort, not exact times) | "background check" + local notifications only | High for UX: iOS timing isn't guaranteed |
| U15 | The friend profile and roster profile (R13/R14) show rank, peak and recent matches, and the loadout only in live games | 2.1.0/2.1.2 wording | Low |
| U16 | Price source = a static JSON on valbuddy.app, keyed by skin id, holding edition list prices with overrides | 2.1.1 "Prices now come from the website" | ValVN must host its own table (§9 risk R3) |

---

## 6. Proposed ValVN screen map

Principles:

- **Parity first:** same 5 tabs and the same sheet model as ValBuddy.
- **Vietnamese labels:** use the in-game vi-VN term where players see it in the client; keep the
  community's English words (§8).
- **Every screen has a loading skeleton, an empty state, an error state with "Thử lại", and
  pull-to-refresh.**
- Suggested `go_router` paths are given; "sheet" means a modal bottom sheet or full-height sheet.

```
App shell
├─ /welcome ............ S01 Chào mừng (not signed in)
├─ /login .............. S02 WebView đăng nhập Riot (also used by "Thêm tài khoản")
└─ Tab shell (floating bottom bar, 5 tabs)
   ├─ /store ........... TAB 1 "Cửa hàng"
   │   ├─ segments: Hằng ngày | Chợ Đêm* | Phụ kiện | Bundle      (*only while active)
   │   ├─ /store/bundle/:id ............ S14 Chi tiết bundle
   │   └─ sheet: skin/:id .............. S15 Chi tiết skin → S16 video
   ├─ /battlepass ...... TAB 2 "Battle Pass"
   │   └─ /battlepass/rewards .......... S21 Phần thưởng Battle Pass
   ├─ /collection ...... TAB 3 "Bộ sưu tập"
   │   ├─ /collection/card ............. S31 Chọn thẻ người chơi
   │   ├─ /collection/title ............ S32 Chọn danh hiệu
   │   ├─ /collection/weapons .......... S33 Trang bị vũ khí → S34 Chọn skin → S35 Tùy chỉnh skin → S36 Chọn phụ kiện súng
   │   ├─ /collection/expressions ...... S37 Tổ hợp cảm xúc
   │   ├─ /collection/presets .......... S38 Bộ trang bị đã lưu
   │   ├─ /collection/browse/:type ..... S39 Duyệt bộ sưu tập (skin|buddy|spray|card|title|flex)
   │   ├─ /collection/wishlist ......... S3A Wishlist
   │   └─ /collection/catalog .......... S3B Tất cả skin (to add to wishlist)
   ├─ /profile ......... TAB 4 "Hồ sơ"
   │   ├─ /profile/rankup .............. S41 Tính toán lên hạng
   │   ├─ /profile/daily-rr ............ S42 RR theo ngày
   │   ├─ /profile/match/:id ........... S43 Chi tiết trận đấu
   │   ├─ /player/:puuid ............... S44 Hồ sơ người chơi
   │   ├─ /profile/party ............... S55 Tổ đội & hàng chờ
   │   ├─ /profile/friends ............. S60 Bạn bè & trò chuyện
   │   └─ /profile/friends/:puuid/chat . S61 Trò chuyện
   └─ /settings ........ TAB 5 "Cài đặt"
       ├─ /settings/log ................ S71 Nhật ký phiên
       └─ /settings/about .............. S72 Giới thiệu & pháp lý
Global overlays
├─ S50 "Trận hiện tại" (Game Details) full-height sheet, auto-opens on match found
├─ S51 Trang bị của người chơi (sheet from S50 roster)
├─ S05 Account switcher sheet (tap the account chip in any tab header)
└─ Local notifications → deep links: /store?account=… , /store/nightmarket , skin/:id
```

### 6.1 Onboarding and auth

**S01 Chào mừng**
- Logo "ValVN" (not ValBuddy branding), tagline "Trợ thủ Valorant của bạn".
- Three feature bullets:
  - "Cửa hàng, Chợ Đêm, Bundle mỗi ngày"
  - "Rank, lịch sử đấu, trận đang diễn ra"
  - "Wishlist & thông báo".
- Primary button "Đăng nhập bằng tài khoản Riot".
- Footnote: "Bạn đăng nhập trên trang chính thức của Riot. ValVN không bao giờ thấy mật khẩu của bạn."
- Riot disclaimer link.
- Data shown: none.

**S02 WebView đăng nhập Riot**
- App bar: "Đăng nhập Riot", ✕, linear progress.
- Riot's page does the rest: Riot ID / Google / Apple / Xbox / PlayStation, hCaptcha, MFA.
- On success: "Đang tải tài khoản…" then the Store tab.
- Errors:
  - "Không thể hoàn tất đăng nhập" + "Thử lại".
  - "Tài khoản này đã được thêm".
  - "Đã đạt tối đa 10 tài khoản".
- See riot-auth.md §1 and the Google-in-WebView risk (§9).

**S03 (optional first run) Nền tảng.** Segmented control "PC · PlayStation · Xbox" with a hint:
"Người chơi console chọn đúng nền tảng để xem lịch sử đấu chính xác." ValBuddy keeps this in Settings
only; ValVN can do the same.

**S04 Xin quyền thông báo.** A priming card before the OS prompt: "Bật thông báo để biết khi cửa hàng
làm mới và khi skin trong wishlist xuất hiện." Buttons "Bật thông báo" and "Để sau".

**S05 Account switcher (sheet)**
- List of accounts: card avatar, Riot ID, "AP · Cấp 222", rank icon, ✓ on the active one.
- "Thêm tài khoản (3/10)" at the bottom.
- Switch failure: "Không thể chuyển tài khoản. Thử lại?" (A6).

### 6.2 TAB 1: Cửa hàng

**Common header**
- Large title "Cửa hàng".
- Account chip (avatar) → S05.
- Wallet pill: VP icon + "2.440", KC icon + "2.113", RP icon + "40".
- Sliding segmented control: **Hằng ngày · Chợ Đêm · Phụ kiện · Bundle**. The "Chợ Đêm" segment appears
  only while the Night Market is active, with a red dot until the user has seen it.

**S10 Hằng ngày**
- Row: clock icon + "Làm mới sau 11:54:37" (live countdown).
- Optional right side: "Tổng 7.775 VP".
- 4 cards. Each card has:
  - A skin render on a gradient tinted with the tier colour (valorant-api `contenttiers.highlightColor`).
  - Tier icon + skin name (vi-VN name, e.g. "Vandal Reaver").
  - VP price.
  - Badges: "Đã sở hữu" (should not happen for store items), "♥ Wishlist".
  - Tap → S15.
- Data: storefront v3 `SkinsPanelLayout` (EP §5.1), wallet (EP §5.2), valorant-api weapons/contenttiers (vi-VN).

**S11 Chợ Đêm**
- "Kết thúc sau 5 ngày 03:12:44".
- Up to 6 cards: skin, **giá gốc** struck through, **giá giảm**, red badge "-32%".
- Footer: "Tiết kiệm tổng cộng 4.120 VP".
- Info note: "Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn và không thể làm mới."
- Data: storefront `BonusStore` (EP §5.1).

**S12 Phụ kiện**
- "Làm mới sau 6 ngày 06:03:46".
- 4 rows: image, name, type label (Thẻ người chơi / Hình phun sơn / Phụ kiện súng / Danh hiệu / Flex),
  KC price. Optional "Từ: Battle Pass Mùa 2025 // Phần IV" (ContractID).
- Data: storefront `AccessoryStore` (EP §5.1).

**S13 Bundle (list)**
- One banner card per featured bundle: art, name, price, countdown "Còn 8 ngày 01:03:40".
- Tap → S14.

**S14 Chi tiết bundle**
- Hero banner.
- Name + description (vi-VN from valorant-api bundles).
- Countdown.
- **Items grid:** skins, buddy, card, spray, title. Each item shows its individual price. Discounted
  prices show the old price struck through.
- Summary box: "Giá bundle 9.500 VP · Mua lẻ 12.345 VP · Tiết kiệm 2.845 VP".
- Tap a skin → S15.

**S15 Chi tiết skin (sheet)**
- Title (skin name) and ✕.
- Media: render, or video with ▶ (the level/chroma `streamedVideo`).
- Row: tier icon + "Phiên bản Độc quyền" + price "2.175 VP", or "Phần thưởng Battle Pass / Hợp đồng
  đặc vụ / Vé sự kiện" for reward skins (C9).
- **Biến thể** (chroma swatches; tap to switch the render).
- **Nâng cấp** chips "Cấp 1 … Cấp 5" with ▶ and a caption for the level type (e.g. "Cấp 4 · Đòn kết
  liễu"; mapping in §8.4).
- Wishlist button: "♡ Thêm vào wishlist" / "♥ Đã có trong wishlist".
- State "Đã sở hữu" (if owned).
- Optional "Có trong cửa hàng của: Tài khoản 2".

**S16 Video.** Full-screen player; loop; mute toggle.

### 6.3 TAB 2: Battle Pass

**S20 Battle Pass**
- **Pass card:**
  - "Mùa 2026 // Phần V" (vi-VN contract name).
  - "Cấp 46 / 55".
  - Red progress bar.
  - Left "7.966 / 35.750 XP", right "840.466 / 1.162.500 XP".
  - Badge "Premium" or "Miễn phí".
  - "Phần kết thúc sau 16 ngày".
- **Row** (gift icon) "Xem tất cả phần thưởng", right "46/55 đã mở khóa ›".
- **Nhiệm vụ hằng ngày** (Daily checkpoints):
  - 4 checkpoint pips + progress to the next one.
  - "Làm mới sau 11:54:37".
  - Rewards "+XP, +KC".
- **Nhiệm vụ hằng tuần**, header countdown "2 ngày 15:09:24". Rows:
  - Status circle or ✓, title (vi-VN mission title from valorant-api, e.g. "Sử dụng chiêu cuối của bạn").
  - Progress bar, "8 / 15", "+38.400 XP".
  - Completed rows are greyed with the title struck through.
- **Completed state:** a card with a trophy icon, "Đã hoàn thành tất cả nhiệm vụ", and "Nhiệm vụ mới sau 2
  ngày 15:09:24".
- **Optional (ValVN extra):**
  - "Còn cần 321.034 XP ≈ 45 trận Đấu thường" (SkinPeek-style calculator).
  - Event pass card if an event is active.
- Data: contracts (EP §12.1), daily ticket (EP §12.2), valorant-api contracts/missions (vi-VN).

**S21 Phần thưởng Battle Pass**
- Grouped by chapter "Chương 1 … Chương 10" + "Phần mở rộng" (epilogue).
- Each tier tile: level number, reward image, type (Skin / Phụ kiện súng / Thẻ người chơi / Hình phun
  sơn / Danh hiệu / Flex / Radianite / Kingdom Credit), a lock or ✓, and a "Miễn phí" tag.
- Tap a skin → S15.

### 6.4 TAB 3: Bộ sưu tập

**S30 Bộ sưu tập (hub)**
- Header: equipped card (wide art) + caption with the card name.
- **Trang bị** section (rows with a current value and ›):
  - "Thẻ người chơi" · <card name>
  - "Danh hiệu" · <title>
  - "Trang bị vũ khí"
  - "Tổ hợp cảm xúc"
  - "Bộ trang bị đã lưu"
- **Duyệt bộ sưu tập** section: "Skin", "Phụ kiện súng", "Hình phun sơn", "Thẻ người chơi",
  "Danh hiệu", "Flex", "Wishlist".
- Footer card: "Giá trị bộ sưu tập: 123.456 VP" (C8), subline "Không tính skin phần thưởng".

**S31 Chọn thẻ người chơi.** Search bar; grid of owned cards; equipped one ticked; tap → preview →
"Trang bị". Writes the loadout (EP §7.2).

**S32 Chọn danh hiệu.** Search bar and list; "Không có danh hiệu" option.

**S33 Trang bị vũ khí**
- Sections by category (app-owned vi labels keyed by the weapon `category` enum, **not** `shopData.categoryText`, whose Shotgun value is broken; see `content-api.md` §3.1):
  - Súng phụ
  - SMG
  - Shotgun
  - Súng trường
  - Súng bắn tỉa
  - Vũ khí hạng nặng
  - Cận chiến
- Tile: weapon name + equipped skin render + buddy icon.

**S34 Chọn skin (per weapon).** Search + tier filter chips + sort menu (**Độ hiếm · Tên · Giá**); list
of owned skins incl. "Mặc định"; tap → S35.

**S35 Tùy chỉnh skin**
- Preview with ▶.
- "Biến thể" (owned chromas; locked ones greyed with a lock icon).
- "Cấp độ" (owned levels).
- "Phụ kiện súng" slot → S36.
- Primary button "Trang bị".

**S36 Chọn phụ kiện súng.** Grid with counts "Còn 2/3" (buddy instances); "Gỡ phụ kiện".

**S37 Tổ hợp cảm xúc.** Wheel of 4 slots (top/right/bottom/left); tap a slot → picker (Hình phun sơn |
Flex tabs) with search.

**S38 Bộ trang bị đã lưu (presets, local per account)**
- "Lưu trang bị hiện tại" → name dialog "Tên bộ trang bị".
- List rows: name, date, thumbnail of the Vandal/Phantom skins.
- Actions: "Áp dụng", "Đổi tên", "Xóa" (swipe).

**S39 Duyệt bộ sưu tập (:type)**
- Search; filter chips by tier (5 edition icons); sort menu **Độ hiếm / Tên / Vũ khí / Giá**.
- Summary strip: "142 skin · 98.765 VP" (or "Đang lọc: 12 skin · 23.400 VP").
- Grid; each tile shows price or source ("Battle Pass").
- Tap → S15 (owned mode).

**S3A Wishlist**
- Per active account; subtitle "Wishlist của <RiotID>".
- Same search/filter/sort; total value.
- Row: skin, price, where it's currently available ("Đang có trong Chợ Đêm!" highlight).
- Swipe → "Xóa khỏi wishlist". "+" → S3B.
- Toggle row "Thông báo wishlist" (shortcut to settings).

**S3B Tất cả skin.** Catalog of every weapon skin (valorant-api), search + filters; tap the heart to add.

### 6.5 TAB 4: Hồ sơ

**S40 Hồ sơ**
1. **Header:** card banner, Riot ID "Tên#TAG" (tap → "Đã sao chép Riot ID"), "Cấp 222", account XP bar
   "184 / 5.000 XP".
2. **Rank card:** "Hiện tại" (icon, "Kim Cương 1", "6 RR") | "Cao nhất · V26 // Phần I" (icon, "Kim
   Cương 2", "37 RR" true-peak). Hint line "≈ 9 trận để lên Kim Cương 2 ›" → S41.
3. **Row** "RR theo ngày ›" → S42 (shows today's "+18 RR").
4. **Current game card** ("Trận hiện tại"):
   - States: "Không trong trận", "Đang ở sảnh chờ", "Đang tìm trận · 01:32", "Đang chọn đặc vụ ·
     Ascent", "Đang đấu · Lotus · **8 – 4**".
   - Refresh ring. Tap → S50.
5. **Rows:** "Tổ đội & hàng chờ ›" (S55), "Bạn bè & trò chuyện ›" (S60, unread badge).
6. **Lịch sử đấu:**
   - Chips: Tất cả · Thi đấu xếp hạng · Đấu thường · Siêu Tốc · Đặt Spike Nhanh · Sinh Tử · Sinh Tử Đội
     · Tăng Tiến · Premier · …
   - Map filter button "Bản đồ: Tất cả ▾".
   - Card: map splash, map name, score "13–7", result tag "**Thắng**"/"**Thua**"/"**Hòa**", agent icon,
     "K/D/A 5/9/1", "+24 RR", mode, "18 giờ trước".
   - Infinite scroll with a "Tải thêm" footer.
- Data: account-xp (EP §8), mmr + competitiveupdates (EP §10), match history/details (EP §11), session
  and presence (EP §15/16).

**S41 Tính toán lên hạng**
- Target rank picker (grid of rank icons up to Bất Tử 1).
- Result cards:
  - "Còn thiếu 164 RR"
  - "Với phong độ hiện tại (+19 / −16 mỗi trận): ≈ 9 trận"
  - "Tốt nhất: 7 trận thắng liên tiếp"
- Table "Tỉ lệ thắng 45% · 50% · 55% · 60% · 65%" → matches needed.
- Footnote: "Ước tính dựa trên các trận xếp hạng gần đây."

**S42 RR theo ngày**
- List grouped by local date ("Hôm nay", "Hôm qua", "Thứ Hai, 22/09").
- Each: net "+32 RR" (green) / "−18 RR" (red), "4 thắng – 2 thua", "Vàng 2 → Vàng 3", expandable match list.
- Stored on device.

**S43 Chi tiết trận đấu**
- Header: map splash, mode, "13 – 7", "Thắng", date, duration "38 phút".
- **Your summary:** agent, K/D/A, ACS (or "Performance Score" after 13.06; §7.3), HS%, ADR, first
  bloods, "+24 RR".
- **Tabs:** "Bảng điểm" | "Diễn biến vòng đấu".
- Scoreboard for both teams: agent, name, rank icon (+peak), ACS, K, D, A, +/−, HS%.
- Round timeline: round icons (Hạ toàn đội / Spike phát nổ / Gỡ Spike / Hết giờ / Đầu hàng), side.
- DM variant: "40 – 37" as in R12.
- Tap a player → S44.

**S44 Hồ sơ người chơi**
- Card, name (or "Người chơi ẩn danh"), level, current and peak rank, recent matches (if available).
- In a live game: "Trang bị" (S51).

### 6.6 Live game (global sheet)

**S50 Trận hiện tại**
- **Header:** "Chi tiết trận", ✕, map splash, map name + mode, refresh button with countdown ring, status
  pill:
  - "Đang chọn đặc vụ" (amber)
  - "Đang diễn ra" (green)
  - "Đã kết thúc" (grey)
- Centred live score "8 – 4".
- **Agent select:**
  - Tabs "Đặc vụ" | "Đội của bạn".
  - Hint "Chạm để chọn, giữ để khóa đặc vụ".
  - 5-column agent grid; unowned or taken agents dimmed.
  - Locked: toast "Đã khóa Jett".
  - Pregame timer "Còn 0:42".
- **In progress:** tabs "Đội của bạn" | "Đội địch". Row:
  - Agent portrait.
  - Name (or "Ẩn danh"), "Cấp 120 · Jett".
  - Rank icon + "Bạc 1", with "Cao nhất: Vàng 3" if the peak toggle is on.
  - Party badge.
  - "BẠN" tag for self.
  - Chevron → S51.
- **Bottom:** red outline button "Rời trận", with a confirm dialog "Rời trận đấu? Bạn có thể bị phạt
  vì rời trận." [Hủy] [Rời trận].
- **Ended:** final scoreboard (K/D/A) and "Xem chi tiết trận ›" → S43.
- Data: session/pregame/core-game (EP §15), mmr for each player (EP §10), names via name-service (EP §9),
  loadouts via `…/loadouts` (EP §7.4), live score from your own XMPP presence (EP §16), final scoreboard from
  match-details once it stops returning 404 (EP §11.2). Quit = pregame `quit` / core-game `disassociate`
  (EP §15.2–15.3).

**S51 Trang bị của người chơi.** Weapon skins grid (equipped skins/chromas), buddy per weapon, card,
title, sprays.

### 6.7 Party and social

**S55 Tổ đội & hàng chờ**
- **Header:** "Tổ đội" + refresh ring.
- **Queue picker:** chips or list using vi-VN names (§8.9). Disabled with a reason, e.g. "Chênh lệch rank
  quá lớn để đấu xếp hạng".
- **Members:** card, Riot ID, rank + RR, "Sẵn sàng ✓", "Chủ tổ đội" crown. Swipe → "Xóa".
- **Online friends strip** "Mời bạn bè" (tap = invite; ✓ if invited).
- **Party code:** "Mã tổ đội: ABC123" [Sao chép] [Tắt mã] or [Tạo mã]. Field "Nhập mã để tham gia" +
  [Tham gia].
- **Invites received:** "Lời mời từ X" [Chấp nhận] [Từ chối].
- **Primary button:**
  - "Bắt đầu tìm trận" / "Hủy tìm trận · 01:32".
  - Toggle "Sẵn sàng".
  - Disabled while in a match: "Không thể đổi hàng chờ khi đang trong trận".
- Data: GLZ party endpoints (EP §15.4: party player → party; queue, matchmaking join/leave, setReady, invite by
  Riot ID, invite code, join by code, kick), member ranks from party `Members[].CompetitiveTier` or MMR, online
  friends from XMPP presence (EP §16). Queue timer from party `QueueEntryTime`; blocked-queue reason from
  `QueueIneligibilities`. *(Added by SUMMARY review.)*

**S60 Bạn bè**
- Search "Tìm theo Riot ID…".
- Sections "Trực tuyến (12)" / "Ngoại tuyến (40)".
- Row: avatar (card), name, status line:
  - "Đang đấu · Ascent · 8 – 4"
  - "Đang tìm trận"
  - "Trong sảnh chờ"
  - "Đang chọn đặc vụ"
  - "Vắng mặt"
  - "Hoạt động 2 giờ trước"
- Unread badge. Tap → S61.
- Data: XMPP roster (`jabber:iq:riotgames:roster`, incl. `last_online`) + presence (`<games><valorant><p>` base64
  JSON: `sessionLoopState`, `matchMap`, `queueId`, scores, `playerCardId`, `isIdle`) + name-service (EP §16, §9).
  *(Added by SUMMARY review.)*

**S61 Trò chuyện**
- Header: ‹ back, name + status beside it; profile icon button → S44.
- Message bubbles with timestamps, grouped by day.
- Input "Nhập tin nhắn…" + send.
- Empty state: "Chưa có tin nhắn. Hãy gửi lời chào!".

### 6.8 TAB 5: Cài đặt

**S70 Cài đặt**
- **TÀI KHOẢN (3/10):** account rows (A4) with an active marker, tap to switch, trash icon with a confirm dialog
  "Xóa tài khoản <X> khỏi thiết bị?". "+ Thêm tài khoản".
- **TÙY CHỌN:**
  - "Tự động mở chi tiết trận"
  - "Hiện rank cao nhất trong chi tiết trận"
  - "Hiện tỉ số trực tiếp"
  - "Nền tảng: PC ▾"
- **THÔNG BÁO:**
  - "Khi cửa hàng làm mới" (07:00 hằng ngày)
  - "Wishlist (kiểm tra nền cho tất cả tài khoản)"
  - (ValVN extra) "Khi Chợ Đêm mở"
- **GIAO DIỆN** (ValVN extra):
  - "Chủ đề: Tối / Sáng / Theo hệ thống"
  - "Tên vật phẩm: Tiếng Việt / Tiếng Anh" (valorant-api language)
- **ỨNG DỤNG:**
  - "Phiên bản 1.0.0"
  - "Xóa bộ nhớ đệm (32 MB)"
  - "Xuất nhật ký phiên"
- **THÔNG TIN:**
  - "Chính sách quyền riêng tư"
  - "Điều khoản sử dụng"
  - "Góp ý / Discord"
  - "Giấy phép mã nguồn mở"
  - Riot disclaimer text
- Destructive button "Đăng xuất tất cả tài khoản".
- (No "Ad Privacy Choices" unless ValVN ships ads.)

**S71 Nhật ký phiên.** Scrollable log (timestamps, request name, HTTP status, no tokens). Buttons "Sao
chép", "Chia sẻ".

**S72 Giới thiệu & pháp lý.** Version, credits (valorant-api.com, techchrism docs), legal notice.

### 6.9 Local notifications (copy)

| Trigger | Title | Body | Deep link |
|---|---|---|---|
| Daily reset (07:00 VN) | "Cửa hàng đã làm mới" | "Xem 4 skin mới hôm nay của {account}." | /store?account= |
| Wishlist hit (daily shop) | "Skin trong wishlist đã xuất hiện!" | "{skin} đang có trong cửa hàng của {account} — còn {h} giờ." | skin sheet, switch account |
| Wishlist hit (Night Market) | "Chợ Đêm có skin bạn thích!" | "{skin} giảm {pct}% còn {price} VP ({account})." | /store/nightmarket |
| Wishlist hit (bundle) | "Bundle mới có skin trong wishlist" | "{skin} nằm trong bundle {bundle}." | /store/bundle/:id |
| Night Market opens (extra) | "Chợ Đêm đã mở!" | "Lật 6 thẻ ưu đãi của {account} ngay." | /store/nightmarket |
| Session expired (bg check) | "Cần đăng nhập lại" | "Phiên của {account} đã hết hạn, thông báo wishlist tạm dừng." | /settings |

---

## 7. Official vi-VN client terminology (what the Vietnamese game itself says)

VALORANT in Vietnam is published by **VNGGames** (`valorant.vnggames.com/vi-vn`). VN accounts play on
the **AP shard** and have VN-specific store currencies and payment methods (Riot support "Player Location
Update for Vietnam"). The texts below come from the client's own localisation: valorant-api.com
`language=vi-VN` (live 2026-09-28), plus VNG patch notes 7.0, 10.00 and 12.00.

### 7.1 From valorant-api `language=vi-VN` [VAPI-VI]

| Domain | en-US → vi-VN |
|---|---|
| Currencies | VALORANT Points → **VALORANT POINT**; Kingdom Credits → **Kingdom Credit**; RADIANITE Points → **RADIANITE Point**; Agent Tokens → **Huy Hiệu Đặc Vụ** |
| Content tiers | Select → **Phiên Bản Tuyển Chọn**; Deluxe → **Phiên Bản Sang Chảnh**; Premium → **Phiên Bản Cao Cấp**; Exclusive → **Phiên Bản Độc Quyền**; Ultra → **Phiên Bản Siêu Cấp** |
| Ranks | Unranked → **CHƯA XẾP HẠNG**; Iron **SẮT**; Bronze **ĐỒNG**; Silver **BẠC**; Gold **VÀNG**; Platinum **BẠCH KIM**; Diamond **KIM CƯƠNG**; Ascendant **THƯỢNG NHÂN**; Immortal **BẤT TỬ**; Radiant **RADIANT** (divisions 1–3 as digits) |
| Queues (`/gamemodes/queues` dropdownText) | Competitive → **Thi đấu xếp hạng**; Unrated → **Đấu thường**; Swiftplay → **Siêu Tốc**; Spike Rush → **Đặt Spike Nhanh**; Deathmatch → **Sinh Tử**; Team Deathmatch → **Sinh Tử Đội**; Escalation → **Tăng Tiến**; Replication → **Nhân bản**; Custom Game → **Chơi tự do**; Snowball Fight → **Trận Chiến Cầu Tuyết**; All Random One Site → **Tất Cả Ngẫu Nhiên Một Khu Đặt Spike**; Skirmish: Ascension → **Skirmish: Thăng Hoa**; unchanged: **Premier, Knockout, Retake, Skirmish: 2v2, Gauntlet: Glitched**. Console queues (`console_*`) use the same names |
| Game modes | Standard → **Thông thường**; Bot Match → **Đấu Với Máy**; The Range → **Trường Bắn**; Basic Training → **Tập Luyện Cơ Bản**; Onboarding → **Tân Thủ** |
| Agent roles | Duelist → **Đối đầu**; Initiator → **Khởi tranh**; Controller → **Kiểm soát**; Sentinel → **Hộ vệ**. Agent names are untranslated |
| Weapons | Names stay English **except** Warden → **Quản Đốc** (new rifle, 13.06) and Melee → **Cận Chiến**. Categories: **Súng phụ, SMG, Shotgun, Súng Trường, Súng bắn tỉa, Vũ Khí Hạng Nặng** |
| Skins | Weapon name first: "Reaver Vandal" → **Vandal Reaver**; "Prime Vandal" → **Vandal Hoàng Gia**; "Spectrum Guardian" → **Guardian Quang Phổ**; "Immortalized Vandal" → **Vandal Trường Tồn**. Chromas: "(Variant 1 Orange)" → **(Dạng 1 Ánh Cam)**. Levels: "Level 4" → **Cấp 4** |
| Cosmetics | Buddy → **Phụ Kiện …** (e.g. "Phụ Kiện RGX 11z Pro"); Spray → **Hình Phun Sơn …**; Card → **Thẻ …**; Flex → **Flex …**; Level Border → **Khung Cấp N** |
| Seasons | "Season 2026 // Act V" → **Mùa 2026 // Phần V**; act short "V26 // ACT V" → **V26 // PHẦN V** |
| Passes | Event Pass → **Vé Sự Kiện …** (e.g. "Vé Sự Kiện Tết Nguyên Đán 2026"); older → "BattlePass …"; agent contract → **Trang Bị <Agent>** ("Gekko Gear" → "Trang Bị Gekko") |
| Maps | Names untranslated; "A/B Sites" → **Khu A/B** |
| Gear | Light Armor → **Giáp Hạng Nhẹ**; Heavy Armor → **Giáp Hạng Nặng**; Regen Shield → **Khiên Hồi Phục** |
| Ceremonies | ACE → **QUÉT SẠCH**; TEAM ACE → **QUÉT SẠCH TOÀN ĐỘI**; CLUTCH → **XUẤT THẦN**; FLAWLESS → **HOÀN HẢO**; CLOSER → **NGƯỜI HẠ MÀN**; THRIFTY → **CẦN KIỆM** |
| Missions | "Use Your Ultimate" → **Sử dụng chiêu cuối của bạn**; "Get Headshots" → **Đạt được Headshot**; "Kill Enemies" → **Hạ gục đối thủ**; "Purchase Items from the Armory" → **Mua Vật phẩm từ Kho vũ khí** |

### 7.2 From VNG vi-VN patch notes [VNG]

| English | vi-VN client term | Where |
|---|---|---|
| Accessory Store | **Cửa Hàng Phụ Kiện** | 7.0 |
| Agent Store | **Cửa Hàng Đặc Vụ** | 7.0 |
| Player Card / Spray / Title / Gun Buddy | **Thẻ Người Chơi / Hình Phun Sơn / Danh Hiệu / Phụ Kiện Súng** | 7.0 |
| Agent Gear | **Trang Bị Đặc Vụ** (10 "Cấp Trang Bị Đặc Vụ") | 7.0 |
| Daily Rewards / checkpoint | **Phần Thưởng Ngày** / **Cột Mốc Tiến Trình** | 7.0 |
| Agent Recruitment event / token | **Sự Kiện Chiêu Mộ Đặc Vụ** / **Kỉ Vật Chiêu Mộ** | 7.0 |
| Collection (page) / inventory | **Bộ Sưu Tập** / **kho đồ** | 10.00 |
| Expressions wheel (spray wheel) | **Tổ Hợp Cảm Xúc** (formerly "Tổ Hợp Hình Phun Sơn") | 10.00 |
| Competitive (queue) / RR | **Đấu Xếp Hạng** / **ĐXH** (Điểm Xếp Hạng) | 12.00 |
| Custom game | **Chơi Tùy Chọn** (patch notes) vs "Chơi tự do" (queue list) | 12.00 |
| Agent / Lobby / Home screen / Social panel | **Đặc Vụ / Sảnh Chờ / Màn Hình Chính / Bảng Giao Tiếp** | 12.00 |
| Chat / Replay / queue / party leader | **Trò Chuyện / Bản Xem Lại / hàng chờ / Trưởng nhóm** | 12.00 |
| Credits (in-match money) | **Credit** | 12.00 |
| Night Market | **Chợ Đêm** (flip "thẻ" to reveal) | community.vnggames.com |
| Store sections (2020) | **Nổi bật** (Featured) / **Ưu đãi** (Offers) | [PV] vi-vn 2020 |

Note: 2020 texts use **"Điệp viên"** for agent and **"Giao kèo"** for contract. Current texts use **Đặc
Vụ** and "Trang Bị Đặc Vụ". Don't use the outdated terms.

### 7.3 Patch 13.06 (2026-09-22) changes that affect labels [PV]

- **Performance Score replaces ACS.** It is a 0–500 score that sets MVP and scoreboard order in
  Competitive, Unrated, Swiftplay and Premier.
  - The vi-VN client string is **UNVERIFIED**; use "Điểm hiệu suất" with the tooltip "Performance Score".
  - Whether match-details JSON exposes it is **UNVERIFIED**. Keep ACS computed from `stats.score / rounds`
    as a fallback and label it "ACS".
- **Agent Mastery.** Per-agent Act levels and Lifetime levels powered by Mastery Points (MP), with a
  Reward Track bought with KC and **Agent ID** cosmetics.
  - This replaces the Agent Gear shown as "agent contract" reward source.
  - vi-VN strings are UNVERIFIED (proposed: "Thông thạo đặc vụ", "Điểm thông thạo (MP)", "Thẻ định danh
    đặc vụ").
- **Accolades** and **Rank Legacy** in a new Career / Competitive Hub. Proposed "Thành tích" and "Lịch
  sử rank". API is UNVERIFIED.
- New rifle **Warden** ("Quản Đốc" in vi-VN), so it needs a loadout slot.
- The Collection shows "new" indicators.
- ValBuddy 2.1.2 (2026-09-24) mentions none of these, which is an opportunity for ValVN.

---

## 8. Vietnamese UI copy glossary (ValVN)

### 8.0 Style rules

1. **Sentence case** for UI labels ("Cửa hàng phụ kiện", "Lịch sử đấu"). Proper nouns and game-data names
   come verbatim from valorant-api vi-VN (they are Title Case or UPPERCASE; render ranks in Title Case,
   e.g. "Kim Cương 1").
2. **Address the user as "bạn"**; friendly but not slangy. No "ae", "bro", etc.
3. **Keep in English** (VN players say these in English, and SkinPeek-vi, VShop-vi and VNG community
   posts use them): **VP, KC, RP, RR, XP, K/D/A, KDA, K/D, ACS, ADR, HS%, KAST, MVP, skin, bundle,
   Battle Pass, rank, wishlist, spray (in casual text), buddy (casual), Flex, Premier, Radiant, Act (in
   casual text), round (mix with "vòng"), agent names, map names, weapon names (except Warden/Melee per
   vi-VN data), Riot ID, Night Market (as a secondary label)**.
4. **Use the in-game Vietnamese term** for concepts players see in the vi-VN client: Chợ Đêm, Bộ sưu
   tập, Thẻ người chơi, Danh hiệu, Hình phun sơn, Phụ kiện súng, Tổ hợp cảm xúc, Đặc vụ, queue names
   (§7.1), rank tiers, content tiers, "Mùa/Phần".
5. "**hằng ngày / hằng tuần**" (dictionary form), used consistently. Never mix with "hàng ngày".
6. **Numbers:** `NumberFormat.decimalPattern('vi_VN')` gives "1.775", "1.162.500". Percent "-32%". Signed
   RR "+24 RR" / "−17 RR" (U+2212 minus). Currency label after the number: "2.175 VP".
7. **Time:**
   - Countdown "11:54:37"; ≥ 1 day → "2 ngày 15:09:24".
   - Relative: "vừa xong", "5 phút trước", "18 giờ trước", "hôm qua", "3 ngày trước".
   - Dates "22/09/2026"; weekdays "Thứ Hai … Chủ Nhật"; 24-hour time.
8. **ARB:** keys lowerCamelCase in `lib/l10n/app_vi.arb`. Vietnamese has no plural inflection; still use
   ICU `{count, plural, other{…}}` for future locales.
9. Don't translate the official Riot disclaimer's legal meaning. A Vietnamese rendering is in §8.13.

### 8.1 Navigation and tabs

| Key | English (ValBuddy) | ValVN (vi) | Note |
|---|---|---|---|
| tabStore | Store | **Cửa hàng** | Client: "Cửa Hàng" |
| tabBattlePass | Battle Pass | **Battle Pass** | Kept in English as in client/VNG. Alternative "Tiến trình" if the tab also shows event passes |
| tabCollection | Collection | **Bộ sưu tập** | Client: "Bộ Sưu Tập" |
| tabProfile | Profile | **Hồ sơ** | VShop-vi: "Hồ sơ" |
| tabSettings | Settings | **Cài đặt** | |
| gameDetailsTitle | Game Details | **Chi tiết trận** | Sheet title |
| currentGame | Current Game | **Trận hiện tại** | |
| friendsAndChat | Friends & Chat | **Bạn bè & trò chuyện** | Client: "Trò Chuyện" |
| party | Party | **Tổ đội** | Casual "party" also OK |

### 8.2 Store

| Key | English | ValVN (vi) | Note |
|---|---|---|---|
| storeDaily | Daily / Today's offers | **Hằng ngày** / "Cửa hàng hằng ngày" | Segment label short form |
| storeNightMarket | Night Market | **Chợ Đêm** | Client + community |
| storeAccessories | Accessories | **Phụ kiện** / "Cửa hàng phụ kiện" | Client: "Cửa Hàng Phụ Kiện" |
| storeBundles | Bundles / Featured bundles | **Bundle** / "Bundle nổi bật" | Community keeps "bundle"; client calls bundle collections "Bộ sưu tập …", which clashes with the Collection tab |
| storeFeaturedBundle | Featured bundle | **Gói nổi bật** | Use as a heading variant if "Bundle" feels too English |
| storeResetsIn | Resets in {time} | **Làm mới sau {time}** | |
| storeEndsIn | Ends in {time} | **Kết thúc sau {time}** | Night Market / bundle |
| storeRemaining | {time} left | **Còn {time}** | |
| wallet | Wallet / Balances | **Ví** / "Số dư" | SkinPeek-vi: "Ví của …" |
| priceOriginal | Original price | **Giá gốc** | |
| priceDiscounted | Discounted price | **Giá ưu đãi** | |
| discountBadge | -{pct}% | **-{pct}%** | |
| bundlePrice | Bundle price | **Giá bundle** | |
| bundleItemsTotal | Items bought separately | **Mua lẻ** | |
| youSave | You save {vp} VP | **Tiết kiệm {vp} VP** | |
| storeTotal | Total | **Tổng** | |
| owned | Owned | **Đã sở hữu** | |
| notForSale | Not for sale | **Không bán** | SkinPeek-vi: "Skin không mở bán" |
| free | Free | **Miễn phí** | |
| nmEmpty | No Night Market right now | **Hiện chưa có Chợ Đêm** | |
| nmNext | Next Night Market … | **Chợ Đêm tiếp theo: {date}** | Date source UNVERIFIED (EP §5.1) |
| nmPersonalNote | Offers are unique to your account | **Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn.** | |
| accessoryFrom | From {pass} | **Từ {pass}** | |
| itemTypeSkin | Skin | **Skin** | |
| itemTypeBuddy | Buddy | **Phụ kiện súng** | Client. Casual: "móc súng", "buddy" |
| itemTypeSpray | Spray | **Hình phun sơn** | Client. Casual "spray" |
| itemTypeCard | Player Card | **Thẻ người chơi** | |
| itemTypeTitle | Title | **Danh hiệu** | |
| itemTypeFlex | Flex | **Flex** | |
| itemTypeLevelBorder | Level Border | **Khung cấp** | |

### 8.3 Currencies and editions

| Key | English | ValVN (vi) | Note |
|---|---|---|---|
| currencyVP | VALORANT Points (VP) | **VP** (full: "VALORANT Point") | |
| currencyKC | Kingdom Credits | **KC** (full: "Kingdom Credit") | |
| currencyRP | Radianite Points | **RP** (full: "Radianite Point") | Don't confuse with LoL's RP. Tooltip "Radianite" |
| currencyAgentTokens | Agent Tokens | **Huy hiệu đặc vụ** | |
| tierSelect | Select Edition | **Phiên bản Tuyển chọn** | Name from vi-VN data |
| tierDeluxe | Deluxe Edition | **Phiên bản Sang chảnh** | |
| tierPremium | Premium Edition | **Phiên bản Cao cấp** | |
| tierExclusive | Exclusive Edition | **Phiên bản Độc quyền** | |
| tierUltra | Ultra Edition | **Phiên bản Siêu cấp** | |
| rewardSourceBP | Battle Pass reward | **Phần thưởng Battle Pass** | C9 |
| rewardSourceAgent | Agent contract | **Hợp đồng đặc vụ** / "Trang bị đặc vụ" | Client 7.0: "Trang Bị Đặc Vụ"; after 13.06: Agent Mastery |
| rewardSourceEvent | Event pass | **Vé sự kiện** | Client |

### 8.4 Skin detail

| Key | English | ValVN (vi) |
|---|---|---|
| variants | Variants | **Biến thể** |
| upgrades | Upgrades | **Nâng cấp** |
| levelN | Lv{n} | **Cấp {n}** |
| playVideo | Play | **Xem video** |
| addToWishlist | Add to wishlist | **Thêm vào wishlist** |
| removeFromWishlist | Remove from wishlist | **Xóa khỏi wishlist** |
| inWishlist | In wishlist | **Đã có trong wishlist** |
| upgradeCost | {n} RP | **{n} RP** |
| locked | Locked | **Chưa mở khóa** |

Level-type captions: valorant-api `levelItem` isn't localised, so these are ValVN's own translations.

| levelItem | vi |
|---|---|
| VFX | Hiệu ứng hình ảnh |
| Animation | Hoạt ảnh |
| Finisher | Đòn kết liễu |
| KillCounter | Bộ đếm hạ gục |
| SoundEffects | Hiệu ứng âm thanh |
| Transformation | Biến hình |
| KillBanner | Biểu ngữ hạ gục |
| KillEffect | Hiệu ứng hạ gục |
| InspectAndKill | Hiệu ứng ngắm súng & hạ gục |
| Voiceover | Lồng tiếng |
| SongShuffle | Đổi bài nhạc |
| Randomizer | Ngẫu nhiên hóa |
| AttackerDefenderSwap | Đổi theo phe công/thủ |
| TopFrag | Hiệu ứng top frag |
| HeartbeatAndMapSensor | Cảm biến nhịp tim & bản đồ |
| FishAnimation | Hoạt ảnh cá |
| (null) | Cơ bản |

### 8.5 Wishlist and notifications

| Key | English | ValVN (vi) |
|---|---|---|
| wishlist | Wishlist | **Wishlist** (subtitle "Skin bạn đang săn") |
| wishlistOfAccount | {account}'s wishlist | **Wishlist của {account}** |
| wishlistEmpty | Empty | **Wishlist trống. Nhấn ♡ ở bất kỳ skin nào để thêm.** |
| wishlistValue | Wishlist value | **Tổng giá trị wishlist** |
| wishlistAvailableNow | Available now in … | **Đang có trong {place}!** |
| placeDaily / placeNM / placeBundle | daily shop / Night Market / bundle | **cửa hàng hằng ngày / Chợ Đêm / bundle {name}** |
| notifStoreReset | Store reset notification | **Thông báo khi cửa hàng làm mới** |
| notifWishlistBg | Background check | **Kiểm tra wishlist trong nền** (subtitle "Cho tất cả tài khoản") |
| notifPermissionMissing | No permission | **Ứng dụng chưa có quyền gửi thông báo.** [Mở cài đặt] |
| batteryOptWarning (Android) | Battery optimisation | **Tối ưu pin đang bật, thông báo wishlist có thể bị trễ.** [Tắt tối ưu pin] |

### 8.6 Collection and loadout

| Key | English (ValBuddy) | ValVN (vi) |
|---|---|---|
| loadout | Loadout | **Trang bị** |
| changeBanner | Change Banner | **Thẻ người chơi** (row) / "Đổi thẻ người chơi" (screen) |
| changeTitle | Change Title | **Danh hiệu** / "Đổi danh hiệu" |
| weaponLoadout | Weapon Loadout | **Trang bị vũ khí** |
| expressions | Expressions | **Tổ hợp cảm xúc** |
| loadoutPresets | Loadout Presets | **Bộ trang bị đã lưu** |
| savePreset | Save current | **Lưu trang bị hiện tại** |
| applyPreset | Apply | **Áp dụng** |
| browseCollection | Browse Collection | **Duyệt bộ sưu tập** |
| skins | Skins | **Skin** |
| buddies | Buddies | **Phụ kiện súng** |
| sprays | Sprays | **Hình phun sơn** |
| playerCards | Player Cards | **Thẻ người chơi** |
| titles | Titles | **Danh hiệu** |
| flex | Flex | **Flex** |
| equip | Equip | **Trang bị** |
| equipped | Equipped | **Đang dùng** |
| noTitle | No title | **Không có danh hiệu** |
| defaultSkin | Standard | **Mặc định** |
| removeBuddy | Remove buddy | **Gỡ phụ kiện** |
| buddyCount | {n}/{m} available | **Còn {n}/{m}** |
| collectionValue | Collection value | **Giá trị bộ sưu tập** |
| filteredValue | Filtered | **Đang lọc: {count} skin · {vp} VP** |
| excludedRewards | Reward skins excluded | **Không tính skin phần thưởng** |
| sortBy | Sort | **Sắp xếp** |
| sortRarity / sortName / sortWeapon / sortPrice | Rarity / Name / Weapon / Price | **Độ hiếm / Tên / Vũ khí / Giá** |
| filterTiers | Content tiers | **Phiên bản** |
| searchSkins | Search | **Tìm skin…** / "Tìm kiếm…" |
| weaponCategories | Sidearms / SMGs / Shotguns / Rifles / Snipers / Heavy / Melee | **Súng phụ / SMG / Shotgun / Súng trường / Súng bắn tỉa / Vũ khí hạng nặng / Cận chiến** |
| newItemBadge | New | **Mới** |

### 8.7 Battle Pass and missions

| Key | English | ValVN (vi) | Note |
|---|---|---|---|
| battlePass | Battle Pass | **Battle Pass** | |
| seasonAct | Season 2026 // Act V | **Mùa 2026 // Phần V** | Use vi-VN contract name as is |
| levelOf | Level {a} / {b} | **Cấp {a} / {b}** | |
| viewAllRewards | View All Rewards | **Xem tất cả phần thưởng** | |
| unlockedCount | {a}/{b} unlocked | **{a}/{b} đã mở khóa** | |
| chapterN | Chapter {n} | **Chương {n}** | |
| epilogue | Epilogue | **Phần mở rộng** | UNVERIFIED client term |
| premiumTrack / freeTrack | Premium / Free | **Premium / Miễn phí** | |
| dailyMissions | Daily missions | **Nhiệm vụ hằng ngày** | Sub-caption "Phần thưởng ngày" (client 7.0) |
| dailyCheckpoint | Checkpoint | **Cột mốc** | Client: "Cột Mốc Tiến Trình" |
| weeklyMissions | Weekly Missions | **Nhiệm vụ hằng tuần** | |
| missionsReset | Resets in | **Làm mới sau {time}** | |
| allMissionsDone | All Missions Completed | **Đã hoàn thành tất cả nhiệm vụ** | |
| newMissionsIn | New missions in {time} | **Nhiệm vụ mới sau {time}** | |
| xpReward | +{xp} XP | **+{xp} XP** | |
| xpToFinish | XP left | **Còn cần {xp} XP** | |
| matchesEstimate | ≈ {n} matches | **≈ {n} trận** | |
| actEndsIn | Act ends in {d} days | **Phần kết thúc sau {d} ngày** | SkinPeek-vi: "Mùa sẽ kết thúc trong {d} ngày" |
| eventPass | Event Pass | **Vé sự kiện** | Client |
| agentContract | Agent contract | **Hợp đồng đặc vụ** | See §7.3 (Agent Mastery) |

### 8.8 Profile, rank, match history

| Key | English | ValVN (vi) | Note |
|---|---|---|---|
| level | Level | **Cấp** | "Cấp 222" |
| accountXp | XP | **XP** | |
| rank | Rank | **Rank** / "Hạng" | Community says "rank"; labels "Hạng hiện tại" |
| currentRank | Current | **Hiện tại** | |
| peakRank | Peak | **Cao nhất** | "Rank cao nhất" |
| unranked | Unranked | **Chưa xếp hạng** | Client |
| rr | RR | **RR** | Client patch notes: "ĐXH". Keep RR |
| rrLeft | RR left | **Còn thiếu {n} RR** | |
| rankUpCalculator | Rank-Up Calculator | **Tính toán lên hạng** | |
| rankUpHint | ≈ 9 matches to Gold 3 | **≈ {n} trận để lên {rank}** | |
| targetRank | Target rank | **Hạng mục tiêu** | |
| atCurrentForm | At your current form | **Với phong độ hiện tại** | |
| bestCase | Best case (straight wins) | **Tốt nhất: {n} trận thắng liên tiếp** | |
| winRate | Win rate | **Tỉ lệ thắng** | |
| dailyRr | Daily RR | **RR theo ngày** | |
| today / yesterday | Today / Yesterday | **Hôm nay / Hôm qua** | |
| winsLosses | {w}W – {l}L | **{w} thắng – {l} thua** | |
| matchHistory | Match History | **Lịch sử đấu** | Task wording "Lịch sử trận đấu" is fine for the screen title; the short form fits chips |
| filterAll | All | **Tất cả** | |
| filterMap | Map | **Bản đồ** | |
| victory / defeat / draw | Victory / Defeat / Draw | **Thắng / Thua / Hòa** | |
| kda | K/D/A | **K/D/A** | |
| acs | ACS | **ACS** | Tooltip "Điểm chiến đấu trung bình" |
| performanceScore | Performance Score | **Điểm hiệu suất** | UNVERIFIED client string (13.06) |
| hsRate | HS% | **HS%** | "–" when no data (R12) |
| adr | ADR | **ADR** | |
| firstBloods | First bloods | **First blood** | Community English |
| mvp | MVP / Team MVP | **MVP / MVP đội** | |
| scoreboard | Scoreboard | **Bảng điểm** | |
| roundTimeline | Rounds | **Diễn biến vòng đấu** | |
| roundN | Round {n} | **Vòng {n}** | "Round" acceptable in casual text |
| attack / defense | Attack / Defense | **Tấn công / Phòng thủ** | |
| outcomeElim / Detonate / Defuse / Time / Surrender | … | **Hạ toàn đội / Spike phát nổ / Gỡ Spike / Hết giờ / Đầu hàng** | VShop-vi |
| kills / deaths / assists | Kills / Deaths / Assists | **Hạ gục / Bị hạ / Hỗ trợ** | Column headers use K / D / A |
| duration | Duration | **Thời lượng** | |
| loadMore | Load more | **Tải thêm** | |
| agents / maps | Agents / Maps | **Đặc vụ / Bản đồ** | |
| matchPending | Processing match | **Riot đang xử lý trận đấu…** | |
| incognito | Hidden name | **Người chơi ẩn danh** | Respect incognito |

### 8.9 Queues and modes (use vi-VN data; keep as a fallback table)

| queueId | vi |
|---|---|
| competitive | **Thi đấu xếp hạng** (short chip: "Xếp hạng") |
| unrated | **Đấu thường** |
| swiftplay | **Siêu Tốc** |
| spikerush | **Đặt Spike Nhanh** |
| deathmatch | **Sinh Tử** |
| hurm | **Sinh Tử Đội** |
| ggteam | **Tăng Tiến** |
| onefa | **Nhân bản** |
| premier | **Premier** |
| custom | **Chơi tự do** |
| dodgeball / fortcollins / skirmish2v2 | **Knockout / Retake / Skirmish: 2v2** |
| skirmishascension1v1 / 2v2 | **Skirmish: Thăng Hoa 1v1 / 2v2** |
| valaram | **Tất Cả Ngẫu Nhiên Một Khu Đặt Spike** (chip "Ngẫu nhiên 1 khu") |
| abilitydraftarena | **Gauntlet: Glitched** |
| snowball | **Trận Chiến Cầu Tuyết** |
| newmap | **Summit** (map-preview queue) |

### 8.10 Live game and agent select

| Key | English (ValBuddy) | ValVN (vi) |
|---|---|---|
| agentSelect | Agent Select | **Đang chọn đặc vụ** (casual "chọn tướng" is common but LoL-derived; avoid) |
| inProgress | In Progress | **Đang diễn ra** |
| matchEnded | Ended | **Đã kết thúc** |
| notInGame | Not in a game | **Không trong trận** |
| inLobby | In lobby | **Đang ở sảnh chờ** |
| inQueue | In queue | **Đang tìm trận** |
| tabAgents | Agents | **Đặc vụ** |
| tabYourTeam | Your Team | **Đội của bạn** |
| tabEnemyTeam | Enemy Team | **Đội địch** |
| hoverLockHint | Tap to hover an agent, hold to lock. | **Chạm để chọn, giữ để khóa đặc vụ.** |
| lockedAgent | Locked {agent} | **Đã khóa {agent}** |
| lockFailed | Lock failed | **Không thể khóa đặc vụ này.** |
| quitMatch | Quit Match | **Rời trận** |
| quitConfirmTitle | Leave match? | **Rời trận đấu?** |
| quitConfirmBody | … | **Rời trận có thể khiến bạn bị phạt (mất RR, khóa hàng chờ).** |
| liveScore | Live Match Score | **Tỉ số trực tiếp** |
| you | You | **BẠN** |
| peakShort | Peak | **Cao nhất** |
| refresh | Refresh | **Làm mới** |
| finalScoreboard | Final scoreboard | **Bảng điểm cuối trận** |
| viewMatchDetails | View details | **Xem chi tiết trận** |
| playerLoadout | Loadout | **Trang bị của {name}** |

### 8.11 Party, friends and chat

| Key | English | ValVN (vi) |
|---|---|---|
| partyTitle | Party | **Tổ đội** |
| partyAndQueue | Party & Remote Queue | **Tổ đội & hàng chờ** |
| queue | Queue | **Hàng chờ** |
| startQueue / cancelQueue | Start / Leave matchmaking | **Bắt đầu tìm trận / Hủy tìm trận** |
| ready / unready | Ready / Unready | **Sẵn sàng / Bỏ sẵn sàng** |
| partyLeader | Leader | **Trưởng nhóm** |
| partyCode | Party code | **Mã tổ đội** |
| generateCode / copyCode / disableCode | Generate / Copy / Disable | **Tạo mã / Sao chép / Tắt mã** |
| joinWithCode | Join with code | **Nhập mã để tham gia** / [Tham gia] |
| inviteFriends | Invite | **Mời bạn bè** |
| invited | Invited | **Đã mời** |
| inviteFrom | Invite from {name} | **Lời mời từ {name}** |
| accept / decline | Accept / Decline | **Chấp nhận / Từ chối** |
| removeMember | Remove | **Xóa khỏi tổ đội** |
| leaveParty | Leave party | **Rời tổ đội** |
| cantQueueComp | Party can't queue Competitive | **Tổ đội chưa thể vào Thi đấu xếp hạng: {reason}** |
| queueLocked | Locked during match | **Không thể đổi hàng chờ khi đang trong trận.** |
| friends | Friends | **Bạn bè** |
| online / offline | Online / Offline | **Trực tuyến / Ngoại tuyến** |
| away | Away | **Vắng mặt** |
| inMatchOnMap | In a match on {map} | **Đang đấu · {map}** |
| lastOnline | Last online {time} | **Hoạt động {time}** |
| chat | Chat | **Trò chuyện** |
| messagePlaceholder | Message | **Nhập tin nhắn…** |
| send | Send | **Gửi** |
| unread | {n} unread | **{n} tin chưa đọc** |
| viewProfile | Profile | **Xem hồ sơ** |
| searchFriends | Search | **Tìm theo Riot ID…** |

### 8.12 Settings and accounts

| Key | English (ValBuddy) | ValVN (vi) |
|---|---|---|
| accountsHeader | ACCOUNTS (5/5) | **TÀI KHOẢN ({n}/{max})** |
| addAccount | Add Account | **Thêm tài khoản** |
| removeAccount | Remove | **Xóa tài khoản** |
| removeAccountConfirm | … | **Xóa {account} khỏi thiết bị này? Wishlist của tài khoản vẫn được giữ lại.** |
| switchAccount | Switch | **Chuyển sang {account}** |
| switchFailed | Couldn't switch | **Không thể chuyển tài khoản. Thử lại?** |
| reloginRequired | Sign in again | **Cần đăng nhập lại** |
| maxAccounts | Limit reached | **Đã đạt tối đa {n} tài khoản.** |
| preferences | PREFERENCES | **TÙY CHỌN** |
| openGameAuto | Open Game Automatically | **Tự động mở chi tiết trận** |
| showPeakInGame | Show Peak Rank in Game Details | **Hiện rank cao nhất trong chi tiết trận** |
| storeResetNotif | Store Reset Notification | **Thông báo khi cửa hàng làm mới** |
| liveMatchScore | Live Match Score | **Hiện tỉ số trực tiếp** |
| platform | Platform | **Nền tảng** (PC / PlayStation / Xbox) |
| theme | Theme | **Giao diện** (Tối / Sáng / Theo hệ thống) |
| itemLanguage | Item names | **Tên vật phẩm** (Tiếng Việt / Tiếng Anh) |
| app | APP | **ỨNG DỤNG** |
| version | Version | **Phiên bản** |
| clearCache | Clear cache | **Xóa bộ nhớ đệm** |
| cacheCleared | Cleared | **Đã xóa {size}** |
| exportLog | Export Session Log | **Xuất nhật ký phiên** |
| exportLogNote | … | **Nhật ký không chứa mật khẩu, token hay ID tài khoản.** |
| privacyPolicy / terms | Privacy Policy / Terms | **Chính sách quyền riêng tư / Điều khoản sử dụng** |
| logoutAll | Log out of all | **Đăng xuất tất cả tài khoản** |
| region | Region | **Khu vực** (AP = "Châu Á - Thái Bình Dương") |

### 8.13 Common actions, states, errors, legal

| Key | vi |
|---|---|
| loading | **Đang tải…** |
| retry | **Thử lại** |
| cancel / ok / close / done / back | **Hủy / OK / Đóng / Xong / Quay lại** |
| pullToRefresh | **Kéo để làm mới** |
| updatedAgo | **Cập nhật {time}** |
| offlineCached | **Đang ngoại tuyến — hiển thị dữ liệu đã lưu ({time}).** |
| timeoutError | **Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại.** |
| genericError | **Đã xảy ra lỗi. Vui lòng thử lại.** |
| maintenance | **Máy chủ VALORANT đang bảo trì. Vui lòng thử lại sau.** |
| sessionExpired | **Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.** |
| emptyGeneric | **Chưa có dữ liệu.** |
| copied | **Đã sao chép!** |
| signInCta | **Đăng nhập bằng tài khoản Riot** |
| signInNote | **Bạn đăng nhập trên trang chính thức của Riot. ValVN không lưu mật khẩu; token chỉ nằm trên thiết bị của bạn.** |
| riotDisclaimer | **ValVN không được Riot Games xác nhận và không phản ánh quan điểm của Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý các sản phẩm của Riot Games. Riot Games và mọi tài sản liên quan là thương hiệu hoặc thương hiệu đã đăng ký của Riot Games, Inc.** |

### 8.14 Terms NOT to use

| Avoid | Use instead | Why |
|---|---|---|
| Điệp viên | Đặc vụ | Outdated (2020) |
| Giao kèo | Hợp đồng / Trang bị đặc vụ | Outdated |
| Trang phục (for skins) | Skin | Nobody says it |
| Điểm VALORANT | VP | SkinPeek-vi uses it, but VP is universal |
| hàng ngày (mixed with hằng tuần) | hằng ngày / hằng tuần | Consistency |
| chọn tướng | chọn đặc vụ | LoL term. Fine in casual speech, not in UI |
| Bộ sưu tập (for store bundles) | Bundle / Gói | Clashes with the Collection tab |

---

## 9. Open risks and UNVERIFIED items

| # | Risk | Impact | Mitigation |
|---|---|---|---|
| R1 | **Google/Apple sign-in inside an embedded WebView**: Google blocks OAuth in embedded webviews (`disallowed_useragent`). ValBuddy advertises Google login, but *how* it works (UA tweak, ASWebAuthenticationSession?) is UNVERIFIED | Many VN players use Google/Facebook login | See riot-auth.md §1.5; test on device early; fall back to Riot ID + password |
| R2 | **Background wishlist checks for up to 10 accounts** need silent re-auth from stored cookies in iOS BGAppRefresh / Android WorkManager. Timing isn't guaranteed (iOS), and Android OEM battery killers interfere | W2/W4 can fail or arrive late | Local notifications only; run at reset time + opportunistic checks; Android battery-optimisation prompt (VShop does this); show "last checked" time |
| R3 | **Price source.** ValBuddy uses its own web price list (2.1.1). Riot's global offers endpoint is LEGACY/UNVERIFIED (EP §5.3). Exclusive/Champions prices vary per bundle | Wrong collection value | Ship a bundled `prices.json` (edition list prices + overrides), with an optional remote override from a static file (GitHub Pages, no user data). Mark estimated prices "≈" |
| R4 | **Patch 13.06** (Performance Score, Agent Mastery, Accolades, Rank Legacy, Agent ID, Warden) changes labels and maybe API fields. None verified in API responses yet | Stale ACS label; loadout missing Warden or Agent ID | Data-driven weapon list from valorant-api; keep ACS as a fallback; track EP Appendix F |
| R5 | **Night Market dates** have no official API while it's closed. Third-party gist is UNVERIFIED | "Next Night Market" line may be wrong | Show it only when the source is confirmed; otherwise hide |
| R6 | **Agent lock, remote queue, quit match** are account-state mutations through undocumented APIs. Riot's stance on third-party instalock is UNVERIFIED; penalties apply to quitting | Account risk for users | Keep all mutations user-initiated (hold to lock, confirm dialogs); never automate; show penalty warning copy (§8.10) |
| R7 | **Chat / UGC**: App Store age label "Contains Messaging and Chat". Apple guideline 1.2 may require report/block for UGC | App review rejection | Plan "Chặn / Báo cáo" via Riot's mechanisms or disclaimers; can ship chat after v1 |
| R8 | **Console accounts** (PC/PS/Xbox switch): platform headers and console queue keys are UNVERIFIED (EP §2, App. C) | Wrong history for console users (fewer in VN) | Default PC; console behind a setting, as in ValBuddy |
| R9 | **VN-specific**: VN accounts are on the AP shard, published by VNG, with local store currency. We found no evidence that VN accounts need a different login, but none was tested | Blocking if VN auth differs | Test with a real VN account early |
| R10 | **Branding/IP**: don't copy ValBuddy's name, icon, screenshots or marketing text (their ToS §8 claims design and code). Riot assets are allowed under Riot's "Legal Jibber Jabber" with the disclaimer | Legal and store rejection | Original ValVN branding; disclaimer in S72 |
| R11 | **App Store description vs changelog drift**: listing and privacy policy say "5 accounts"; changelog says 10. Site said "no ads" earlier, now iOS ads | Parity target ambiguity | Target 10 accounts (latest behaviour) |
| R12 | vi-VN client strings for newer UI (Performance Score, Agent Mastery, Epilogue "Phần mở rộng", loadout presets) are **UNVERIFIED** | Terminology mismatch | Verify against the VN client (screenshots from a VN player) before release |
| R13 | ValBuddy's collection-browser rows below the fold, Night Market UI, bundle detail and wishlist entry points are **not in any screenshot** (U-list §5) | Minor parity gaps | Build per U-list; revisit if new screenshots appear |

---

## 10. Sources

**ValBuddy (primary)**
- App Store: https://apps.apple.com/us/app/valbuddy/id6757810434 and https://itunes.apple.com/lookup?id=6757810434&country=us
- Screenshots (mzstatic URLs from the lookup API, 7 iPhone + 4 iPad), viewed 2026-09-28
- https://valbuddy.app/ · https://valbuddy.app/changelog · https://valbuddy.app/privacy · https://valbuddy.app/terms · https://valbuddy.app/sitemap-0.xml
- Secondary: https://mwm.ai/apps/valbuddy/6757810434 (metrics UNVERIFIED); TikTok discover pages (no readable content)

**Game data and Vietnamese terminology**
- https://valorant-api.com/v1/version and `/v1/{currencies,contenttiers,competitivetiers,gamemodes,gamemodes/queues,agents,weapons,contracts,events,seasons,ceremonies,gear,buddies,sprays,playercards,playertitles,flex,levelborders,bundles,missions}?language=vi-VN|en-US`
- https://valorant.vnggames.com/vi-vn/news/game-updates/valorant-patch-notes-7-0/ · …-10-00/ · …-12-00/
- https://community.vnggames.com/news/val/valorant-s-kien-cho-dem-thang-7-2025.html · https://community.vnggames.com/news/val/v26-act-3-lo-dien-bundle-kuronami-2-0-c-c-hot-battle-pass-moi.html
- https://playvalorant.com/vi-vn/news/dev/cua-hang-valorant-va-vat-pham-trang-tri/ (2020)
- https://playvalorant.com/en-us/news/game-updates/valorant-patch-notes-13-06/ (2026-09-22)
- https://support.riotgames.com/en-us/valorant/account/player-location-update-for-vietnam
- https://raw.githubusercontent.com/giorgi-o/SkinPeek/master/languages/vi.json · SkinPeek README
- https://raw.githubusercontent.com/GinzaTech/Vshop/main/assets/i18n/vi.json (and en.json, README)

**Competitors**
- https://play.google.com/store/apps/details?id=com.lonitys.valpal.companion (ValPal Companion)
- iTunes lookup: 6778869939 (ValoShopTracker), 6761351068 (Revamped), 6775566544 (SpikeHub), 6761961323 (ValoStore), 1077150310 (Riot Mobile), 1555939999 (Valking.gg), 1541123839 (Spike Stats); 6476132885 (VALPAW, no result)
- https://valpaw.com
