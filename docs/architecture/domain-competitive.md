# Competitive domain: `lib/core/domain/competitive/`

Shared, UI-free layer for the **profile**, **live game** and **social** features:
MMR / rank / peak, local RR history, Daily RR, the Rank-Up Calculator, match
history, match details and scoreboard statistics, name-service and account XP.
It sits on top of the core APIs (`PvpApi`, `ContentDb`, `Prefs`, `JsonFileCache`,
`clockProvider`, `RiotException`) and changes none of them.

```dart
import 'package:valvn/core/domain/competitive/competitive.dart';   // everything below
```

References: SUMMARY §6.2, §7.4–§7.5, §9.5–§9.8, §10, U12, U15, U16;
EP §8–§11; CA §9–§10; VF §2.6, §6.5, §8.8.

| File | Contents |
|---|---|
| `viewer.dart` | `watchViewer`, `watchIsConsole`, `cacheFor`, `queueForPlatform`, `baseQueueId` |
| `paging.dart` | `PagedState<T>`, `kRiotPageSize`, `isPastEndError` |
| `rank_models.dart` | P-11 / P-12 models: `PlayerMmr`, `QueueSkill`, `SeasonalInfo`, `CompetitiveUpdate`, `CompetitiveUpdatesPage`, `kCompetitiveQueue` |
| `rank_calc.dart` | pure logic: `normalizeTier`, `RankInfo`, `currentRankOf`, `PeakRank`/`peakRankOf`, `ActRank`/`actHistoryOf`, `RankSummary`/`buildRankSummary`, `DailyRr`/`groupDailyRr`, `RankUpForm`, `RankUpEstimate`, `estimateRankUp`, `rankUpTargets` |
| `rr_history.dart` | `RrHistory`, `RrHistoryStore` (on-device P-12 rows + outcomes), `rrHistoryStoreProvider` |
| `rank.dart` | providers: `mmrProvider`, `rrHistoryProvider`, `rankSummaryProvider`, `competitiveUpdatesProvider`, `rrHistorySyncProvider`, `dailyRrProvider`, `rankUpFormProvider`, `rankUpEstimateProvider` |
| `match_models.dart` | P-14 models + stats: `MatchDetails`, `MatchInfo`, `MatchPlayer`, `MatchTeam`, `RoundResult`, `Kill`, `ScoreboardStats`, `MatchResult`, `MatchPlayerSummary`, enums |
| `matches.dart` | P-13 models, `MatchDetailsCache`, `MatchRepository`, `matchHistoryProvider`, `matchDetailsProvider`, `matchSummaryProvider` |
| `names.dart` | `RiotName`, `NameResolver` (batched P-10), `playerNameProvider`, incognito helpers |
| `account_xp.dart` | `AccountXp` (P-9), `accountXpProvider` |
| `competitive_strings.dart` | `CompetitiveStrings` (outcome labels, placeholders, round-end types, sides) |

All parsers are pure, never throw, lowercase every uuid and read numbers as `num`
(`"22"` parses as 22). Every provider only throws `RiotException` subtypes (plus
`StateError` from `accountXpProvider` for a PUUID that is not signed in).

---

## 1. Whose session? (`viewer.dart`)

MMR, competitive updates, match history, match details and name-service are
"any player" endpoints. Every provider is keyed by the **subject's PUUID** and picks
the session with `watchViewer(ref, subject)`:

- subject is a signed-in account → that account's session (its shard, its
  `needsLogin`);
- anyone else (friend, match participant, live-game player) → the **active** account.

`watchViewer` throws `NeedsLoginException(reason: 'no_account')` when nobody is signed
in and watches the viewer's `needsLogin`, so providers refetch after a re-login.

Console (SUMMARY U12): `watchIsConsole(ref, viewer)` is true when the account's
platform is a console **and** the remote flag `console_support` is on. Then
`queueForPlatform('competitive', console: true)` → `console_competitive`, and
`PlayerMmr.skill()` prefers `console_<queue>`. `baseQueueId('console_hurm')` → `hurm`.

`cacheFor(ref, d)` keeps an auto-dispose provider alive for `d` after it was built
(SUMMARY §10 TTLs). `ref.refresh(p)` / `ref.invalidate(p)` still refetch at once.

---

## 2. Providers at a glance

| Provider | Type | Notes |
|---|---|---|
| `mmrProvider(puuid)` | `FutureProvider.autoDispose.family<PlayerMmr, String>` | P-11, kept 3 min. Own accounts: `LatestCompetitiveUpdate` is merged into the RR history |
| `rrHistoryProvider(puuid)` | `FutureProvider.autoDispose.family<RrHistory, String>` | device-stored rows, newest first; rebuilds whenever the store changes |
| `rankSummaryProvider(puuid)` | `FutureProvider.autoDispose.family<RankSummary, String>` | current + peak (true-peak RR from the history) + act stats; caches `rankTier` / `rankSeasonId` on own `Account` (A4) |
| `competitiveUpdatesProvider(puuid)` | `AsyncNotifierProvider.autoDispose.family<CompetitiveUpdatesNotifier, PagedState<CompetitiveUpdate>, String>` | P-12 `queue=competitive`, 20 per page, kept 3 min; `.notifier.loadMore()`; every page is stored in the RR history (for any PUUID) |
| `rrHistorySyncProvider(puuid)` | `FutureProvider.autoDispose.family<int, String>` | backfill: when page 1 was entirely new, fetches up to `kRrHistoryBackfillPages` (4) older pages until one overlaps; best effort, returns rows added |
| `dailyRrProvider(puuid)` | `FutureProvider.autoDispose.family<List<DailyRr>, String>` | S42 groups, newest day first; keeps page 1 + backfill running (show *their* errors from `competitiveUpdatesProvider`) |
| `rankUpFormProvider(puuid)` | `FutureProvider.autoDispose.family<RankUpForm, String>` | G / L / p from page 1 (last 20 updates) |
| `rankUpEstimateProvider((puuid:, targetTier:))` | `FutureProvider.autoDispose.family<RankUpEstimate?, RankUpQuery>` | S41; `targetTier: null` = next tier (profile hint); `null` result = unranked, placements, Immortal+ or invalid target |
| `matchHistoryProvider((puuid:, queue:))` | `AsyncNotifierProvider.autoDispose.family<MatchHistoryNotifier, PagedState<MatchHistoryEntry>, MatchHistoryQuery>` | P-13, 20 per page, kept 3 min; `queue` is a PC id or `null` (all); `.notifier.loadMore()` |
| `matchDetailsProvider(matchId)` | `FutureProvider.autoDispose.family<MatchDetails, String>` | P-14 via disk cache (completed matches, LRU 200) + 10 min in memory; blank names resolved; records outcomes of signed-in participants for Daily RR. Uses the **active** account's session |
| `matchSummaryProvider((matchId:, puuid:))` | `FutureProvider.autoDispose.family<MatchPlayerSummary?, MatchSummaryQuery>` | one player's card line; `null` when not in the match |
| `playerNameProvider(puuid)` | `FutureProvider.autoDispose.family<RiotName?, String>` | own accounts from prefs, others through the batched `NameResolver`; `null` = unknown PUUID |
| `accountXpProvider(puuid)` | `FutureProvider.autoDispose.family<AccountXp, String>` | P-9, own accounts only, kept 5 min; caches `level` on the `Account` |
| `nameResolverProvider` | `Provider<NameResolver>` | app-wide resolver (prefs-backed cache `f.competitive.names`) |
| `rrHistoryStoreProvider` | `Provider<RrHistoryStore>` | `<appSupport>/history`, survives sign-out and "Xóa bộ nhớ đệm" |
| `matchRepositoryProvider`, `matchDetailsCacheProvider` | `Provider` | low level (no Riverpod needed in `MatchRepository`) |

Paged lists (`PagedState<T>`): `items`, `hasMore`, `isLoadingMore`, `loadMoreError`,
`total` (P-13 `Total`), `isEmpty`. Errors of the **first** page are the provider's
`AsyncError`; errors of later pages land in `loadMoreError` next to the loaded items.
`400 BAD_PARAMETER` past the end ends pagination silently (`isPastEndError`).

```dart
final q = (puuid: account.puuid, queue: 'competitive');      // null = every queue
final history = ref.watch(matchHistoryProvider(q));
AsyncValueView(
  value: history,
  puuid: account.puuid,
  onRetry: () => ref.invalidate(matchHistoryProvider(q)),
  isEmpty: (s) => s.isEmpty,
  data: (s) => MatchList(s.items, footer: s.hasMore ? LoadMore(onTap: () =>
      ref.read(matchHistoryProvider(q).notifier).loadMore()) : null),
);
// pull-to-refresh
onRefresh: () => ref.refresh(matchHistoryProvider(q).future),
```

---

## 3. Rank (`rank_models.dart`, `rank_calc.dart`)

### 3.1 Models

- `PlayerMmr { subject, version, queueSkills (lowercase id → QueueSkill),
  latestCompetitiveUpdate, newPlayerExperienceFinished, isLeaderboardAnonymized,
  isActRankBadgeHidden; skill(queue, {console}), competitive({console}) }`
- `QueueSkill { queueId, totalGamesNeededForRating, currentSeasonGamesNeededForRating
  (> 0 = placements), seasons (act uuid → SeasonalInfo); season(actUuid) }`
- `SeasonalInfo { seasonId, numberOfWins, numberOfGames, rank (act badge tier),
  leaderboardRank (0 = none), competitiveTier, rankedRating, winsByTier,
  gamesNeededForRating; winRate }`
- `CompetitiveUpdate { matchId, mapId (path → ContentDb.mapByUrl), seasonId,
  matchStartTime (UTC), tierBefore/After, rrBefore/After, rrEarned, performanceBonus,
  movement, afkPenalty; isPromotion, isDemotion; toJson() }` — P-12 row; also
  `compareUpdatesNewestFirst`.

### 3.2 Tiers across tables

Tier numbers mean different ranks in pre-Episode-5 tables. **Always compare with
`normalizeTier(tier, table)` / `normalizeTierForSeason(db, tier, seasonId)`**, which
map any table to Episode-5 numbering (E4 Immortal 1 = 21 → 24, E4 Radiant = 24 → 27;
unranked → 0).

`RankInfo.resolve(db, tier:, rr:, actUuid:, gamesNeeded:)` → a displayable rank:
`tier` (raw, in the act's table), `tierName` ("Kim Cương 1" / "Radiant" /
"Chưa xếp hạng", fallback names before content loads), `normalizedTier`, `rr`,
`actUuid`, `icon`, `largeIcon`, `colorHex`/`color`, `isPlacement`, `gamesNeeded`,
`placementText` ("Còn 3 trận phân hạng"), `isUnranked`, `compareTo`.

### 3.3 Current, peak, acts

- `currentRankOf(db, mmr, now:, console:)` — `SeasonalInfoBySeasonID[currentAct]`
  (act from `ContentDb.currentAct(now)`, else `LatestCompetitiveUpdate.SeasonID`);
  placements when `CurrentSeasonGamesNeededForRating > 0`.
- `peakRankOf(db, mmr, history:, console:) → PeakRank?` — max over acts of
  `CompetitiveTier`, `Rank`, `WinsByTier` keys, the latest update and stored rows,
  each normalized in its own act's table; ties go to the newest act.
  `PeakRank { rank (RankInfo; rank.rr = true peak or 0), truePeakRr (null = unknown),
  truePeakFromLocalHistory (label it "trên thiết bị"), actUuid }`.
- `actHistoryOf(db, mmr) → List<ActRank>` newest first: `ActRank { actUuid, act,
  title ("V26 // PHẦN V"), rank, badge, info, wins, games }`.
- `RankSummary { current, peak, currentAct, currentActInfo, latestUpdate, acts; wins,
  games, winRate, leaderboardRank }` from `buildRankSummary(db, mmr, now:, history:)`.

Peak act title for "Cao nhất · V26 // Phần I":

```dart
final act = summary.peak?.actUuid == null ? null : db.season(summary.peak!.actUuid!);
final title = act == null ? null : db.actTitle(act);
```

### 3.4 Local RR history (`rr_history.dart`)

`RrHistory { puuid, rows (newest first, unique by match), outcomes (match id →
MatchOutcome from P-14); forMatch(matchId) → CompetitiveUpdate? }` — use
`forMatch` for "+24 RR" on match cards and in match details.

`RrHistoryStore`: `read(puuid)`, `merge(puuid, rows) → new ids`, `recordOutcomes(puuid,
outcomes, {force})`, `delete(puuid)`, `clear()`, `changes` stream; ≤ 5000 rows per
player; writes serialised per PUUID; storage errors degrade to memory. Features
normally only read it through `rrHistoryProvider`.

### 3.5 Daily RR (SUMMARY §9.6)

`groupDailyRr(rows, outcomes:, toLocal:) → List<DailyRr>` (newest day first). `DailyRr
{ date (local midnight), matches (oldest first), netRr, wins, losses, draws;
startTier/startRr/startSeasonId, endTier/endRr/endSeasonId, first, last }`. Wins and
losses come from P-14 outcomes when known, else from the RR sign (0 → draw/remake).

### 3.6 Rank-Up Calculator (SUMMARY §9.7)

Tiers are Episode-5 tiers (`RankInfo.normalizedTier`); targets go up to
`kRankUpMaxTier` = 24 (Bất Tử 1); `kRrPerTier` = 100; win-rate table
`kRankUpWinRates` = 45 … 65 %.

- `rankUpTargets(currentTier)` → selectable targets (empty when unranked / Immortal+).
- `rankUpFormOf(updates, window: 20) → RankUpForm { avgGain (G), avgLoss (L), wins,
  losses, sampleSize, winRate (p, null without decided matches),
  expectedRrPerMatch(p) }`.
- `rrNeededFor(tier:, rr:, targetTier:)`, `matchesNeeded(rrNeeded:, winRate:, avgGain:,
  avgLoss:) → int?` (`null` = "Không ước tính được").
- `estimateRankUp(currentTier:, currentRr:, targetTier:, form:) → RankUpEstimate?
  { currentTier, currentRr, targetTier, rrNeeded, form, matchesAtCurrentForm,
  bestCaseWins, byWinRate [(winRate, matches)], alreadyReached }`.

---

## 4. Matches (`matches.dart`, `match_models.dart`)

### 4.1 History (P-13)

`MatchHistoryEntry { matchId, startTime, queueId ("" = custom) }`,
`MatchHistoryPage { subject, beginIndex, endIndex, total, entries; hasMoreAfter(start) }`.
The map filter is not server-side: resolve each entry's details (cached) and filter
on `info.mapId`.

### 4.2 Details (P-14)

`MatchDetails.fromJson(json, matchId:)` never throws. Fields: `info`, `players`,
`teams`, `rounds` (sorted), `kills` (sorted; rebuilt from per-round kills when the
top-level list is empty, as in 2026), `matchMvp`.

- `MatchInfo { matchId, mapId, gameMode, queueId, startTime, gameLength, isCompleted,
  provisioningFlowId, customGameName, isRanked, seasonId (tier table of
  players[].competitiveTier), completionState; isCustom, modeKind, isVoteDraw,
  isSurrendered }`.
- `MatchPlayer { subject, name (RiotName?, filled by the provider), teamId (`Red`/`Blue`;
  own PUUID in DM), partyId, characterId (agent), stats, competitiveTier (at match
  time), isObserver, playerCard, playerTitle, preferredLevelBorder, accountLevel,
  platformType, roundDamage }`.
- `MatchTeam { teamId, won, roundsPlayed, roundsWon, numPoints, mvp }`.
- `RoundResult { roundNum (0-based), roundResult, roundResultCode, ceremony
  ("CeremonyAce" → ContentDb.ceremony), winningTeam, winningTeamRole, bombPlanter,
  bombDefuser, plantSite, firstBloodPlayer, playerStats, playerEconomies; endType,
  statsFor, economyFor, roleOf(teamId) }`.
- `Kill { round, killer, victim, roundTime, assistants, damageType, damageItem;
  weaponId, abilitySlot }`.
- Enums: `MatchOutcome { win, loss, draw, unknown; label ("Thắng"/"Thua"/"Hòa"/"–"),
  fromRr }`, `MatchModeKind { standard, deathmatch, teamDeathmatch, escalation;
  isRoundBased; classify(queueId, gameModePath) }`, `RoundEndType { elimination,
  detonate, defuse, timeExpired, surrendered, unknown; label }`, `TeamRole { attacker,
  defender; label ("Tấn công"/"Phòng thủ"), opposite }`.

Queries: `participants` (no observers), `player(puuid)`, `team(id)`, `sideIds` (team ids
in display order), `playersOfTeam(teamId)` (best ACS first), `playedRounds` (without
rounds awarded by a surrender), `killsInRound(n)`, `unnamedSubjects`, `withNames(map)`.

### 4.3 Stats and result (SUMMARY §9.8, VF R12)

- `statsFor(puuid) → ScoreboardStats?` / `scoreboard` (best first):
  `kills, deaths, assists, score, roundsPlayed, acs, adr (null outside round modes),
  headshotRate (null without hit data → show "–"), damage, headshots/bodyshots/legshots,
  firstBloods, firstDeaths, kast, placement (1 = best), isMatchMvp, isTeamMvp;
  plusMinus, kd, hasHitData`.
- `resultFor(puuid) → MatchResult { outcome, myScore, otherScore, placement (DM);
  hasScore }` — team modes: rounds (team points in TDM / Escalation, `numPoints` after
  a surrender); Deathmatch: your kills vs the best other player's kills.
- `summaryFor(puuid) → MatchPlayerSummary { info, player, result, stats; matchId,
  agentId }` (what a match card needs).

Errors: `matchDetailsProvider` throws `NotFoundException` while Riot is still
processing a just-finished match — show `CompetitiveStrings.matchPending` with
"Thử lại".

---

## 5. Names and incognito (`names.dart`)

2026 match details arrive with blank `gameName`/`tagLine`; `matchDetailsProvider`
fills them via name-service. For single players use `playerNameProvider(puuid)`.

`NameResolver`: `peek`, `remember(puuid, name)`, `resolve(viewer, puuids, {refresh})`,
`resolveOne`; coalesces requests (20 ms window, ≤ 50 per call, U15), caches in prefs
(fresh 1 day, stale served on failure).

Display rules (SUMMARY U16):

```dart
final hidden = isIdentityHidden(incognito: p.incognito, isSelf: me, isPartyMember: party);
final label = playerDisplayName(name, hidden: hidden, fallback: agent?.displayName);
// "Người chơi ẩn danh" / "Tên#TAG" / agent name / "Người chơi"
final level = visibleAccountLevel(p.level, hideAccountLevel: p.hideLevel, isSelf: me);
```

---

## 6. Account XP (`account_xp.dart`)

`AccountXp { level ("Cấp 222"), xp (inside the level), history [XpHistoryEntry],
lastTimeGrantedFirstWin, nextTimeFirstWinAvailable; xpPerLevel (5000), progress
(0–1), xpToNextLevel, isFirstWinAvailable(now) }`. Own accounts only; other players'
levels come from `MatchPlayer.accountLevel` / live-game identities.

---

## 7. Strings (`competitive_strings.dart`)

`CompetitiveStrings`: `incognitoPlayer`, `unknownPlayer`, `victory`/`defeat`/`draw`,
`noValue` ("–"), `cannotEstimate`, `matchPending`, `placementsLeft(n)`, round-end
labels, `attack`/`defense`, `fallbackTierName(tier)`. Screen copy stays in each
feature's `<f>_strings.dart`.

---

## 8. Screens built on this domain (profile feature)

Other features open them through `lib/features/profile/profile_routes.dart`:

| Helper | Location | Screen |
|---|---|---|
| `ProfileRoutes.player(puuid, hidden: incognito)` | `/player/:puuid[?hidden=1]` (above the tab bar) | S44 player profile; `hidden` keeps the name "Người chơi ẩn danh" |
| `ProfileRoutes.matchFullScreen(matchId, player: puuid)` | `/match/:id[?player=]` (above the tab bar) | S43 match detail from `player`'s point of view |
| `ProfileRoutes.match(matchId, player: puuid)` | `/profile/match/:id[?player=]` (inside the profile tab) | S43 |
| `ProfileRoutes.rankUp`, `ProfileRoutes.dailyRr` | `/profile/rankup`, `/profile/daily-rr` | S41, S42 |

Reusable widgets (import from `lib/features/profile/ui/widgets/`): `RankCard(puuid:)`
(current / peak / RR trend), `RrTrendChart(changes:)` (fl_chart), `MatchCard`.

---

## 9. Testing

Build containers with `ProviderContainer.test(...)` and override `pvpApiProvider`
(`MockPvpApi`), `prefsProvider`, `jsonFileCacheProvider`, `rrHistoryStoreProvider`
(`RrHistoryStore(JsonFileCache(...))` or an in-memory `JsonFileCache` subclass in
widget tests), `contentProvider`, `clockProvider`, `remoteConfigProvider`,
`sessionManagerProvider`. Fixtures: `test/fixtures/competitive/*.json`, helpers in
`test/core/domain/competitive/competitive_test_utils.dart`.

Widget tests can instead override the high-level providers directly:

```dart
rankSummaryProvider.overrideWith((ref, puuid) async => buildRankSummary(db, mmr, now: now)),
dailyRrProvider.overrideWith((ref, puuid) async => groupDailyRr(rows)),
matchDetailsProvider.overrideWith((ref, id) async => MatchDetails.fromJson(json)),
```

Keep auto-dispose providers listened while awaiting them in unit tests
(`container.listen(p.future, (_, _) {})`).
