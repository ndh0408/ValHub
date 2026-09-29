import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/battlepass/data/battlepass_models.dart';
import 'package:valvn/features/battlepass/data/daily_ticket.dart';
import 'package:valvn/features/battlepass/data/player_contracts.dart';
import 'package:valvn/features/home/data/home_accounts.dart';
import 'package:valvn/features/home/data/home_battlepass.dart';
import 'package:valvn/features/home/data/home_community.dart';
import 'package:valvn/features/home/data/home_friends.dart';
import 'package:valvn/features/home/data/home_status.dart';
import 'package:valvn/features/home/data/home_live.dart';
import 'package:valvn/features/home/data/home_rank.dart';
import 'package:valvn/features/home/data/home_store.dart';
import 'package:valvn/features/home/providers/home_card_providers.dart';
import 'package:valvn/features/home/providers/home_layout_provider.dart';
import 'package:valvn/features/profile/data/recent_form.dart' show StreakKind;

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import '../battlepass/bp_fixtures.dart';
import 'home_test_data.dart';
import '../profile/profile_test_env.dart' show actV, testContent, updateRow;

export 'home_test_data.dart';
export 'home_test_pump.dart';
export '../battlepass/bp_fixtures.dart'
    show Bp, activeMission, bpContent, contractsJson, dailyTicketJson;
export '../../core/domain/economy/economy_fixtures.dart' show Fx;

class HomeMockApi extends Mock implements PvpApi {}

class HomeMockSessions extends Mock implements SessionManager {}

/// In-memory [JsonFileCache].
class HomeMemoryCache extends JsonFileCache {
  HomeMemoryCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(
        jsonDecode(jsonEncode(data)),
        savedAt ?? DateTime(2026),
      );

  @override
  Future<void> delete(String key) async => entries.remove(key);

  @override
  Future<void> deletePrefix(String prefix) async =>
      entries.removeWhere((k, _) => k.startsWith(prefix));

  @override
  Future<void> clear() async => entries.clear();

  @override
  Future<int> sizeBytes() async => 0;
}

/// Foreground flag tests can flip.
class HomeTestForeground extends AppForegroundNotifier {
  @override
  bool build() => true;

  set foreground(bool value) => state = value;
}

/// Counts content-miss reports (no re-download in tests).
class HomeMissCounter {
  int count = 0;
}

class _CountingMissReporter extends ContentMissReporter {
  _CountingMissReporter(super.ref, this.counter);

  final HomeMissCounter counter;

  @override
  Future<void> report() async => counter.count++;
}

const homeMe = Account(
  puuid: Fx.puuid,
  gameName: 'Tôi Là Ai',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
  level: 222,
  rankTier: 18,
);

const homeAlt1 = Account(
  puuid: 'aaaaaaaa-0000-4000-8000-000000000002',
  gameName: 'Tài Khoản Hai',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
  level: 41,
);

const homeAlt2 = Account(
  puuid: 'aaaaaaaa-0000-4000-8000-000000000003',
  gameName: 'Tài Khoản Ba',
  tagLine: 'VN3',
  region: 'ap',
  shard: 'ap',
  level: 12,
);

/// "Now" of the Home tests: local noon of 2026-09-28.
final homeNow = DateTime(2026, 9, 28, 12);

/// Everything a Home widget test needs: prefs, a mocked Riot API, fixed
/// clock, content and the recording fakes.
class HomeTestEnv {
  HomeTestEnv._(this.prefs, this.accounts);

  static Future<HomeTestEnv> create({
    List<Account> accounts = const [homeMe],
    Object? layout,
    bool? friendsConsent,
    Map<String, String> extraPrefs = const {},
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    if (accounts.isNotEmpty) {
      await prefs.setString(PrefKeys.activePuuid, accounts.first.puuid);
    }
    if (layout != null) await prefs.setJson(kHomeLayoutPrefKey, layout);
    if (friendsConsent != null) {
      await prefs.setBool(kHomeFriendsPrefKey, friendsConsent);
    }
    for (final e in extraPrefs.entries) {
      await prefs.setString(e.key, e.value);
    }
    final env = HomeTestEnv._(prefs, accounts);
    when(() => env.api.platformStatus(any())).thenAnswer((_) async => {});
    // Entitlements (skin sheets, Battle Pass premium): none.
    when(() => env.api.entitlements(any(), any()))
        .thenAnswer((_) async => throw const NotFoundException());
    when(() => env.sessions.events).thenAnswer((_) => const Stream.empty());
    return env;
  }

  final Prefs prefs;
  final List<Account> accounts;
  final api = HomeMockApi();
  final sessions = HomeMockSessions();
  final files = HomeMemoryCache();
  final clock = FixedClock(homeNow);
  final foreground = HomeTestForeground();
  final misses = HomeMissCounter();

  /// Times the chat service was created (it must stay 0 without consent).
  int xmppCreated = 0;

  ContentDb content = economyContent();

  List<Override> get overrides => [
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(MemorySecureStore()),
    sessionManagerProvider.overrideWithValue(sessions),
    sessionLogProvider.overrideWithValue(SessionLog()),
    notificationServiceProvider.overrideWithValue(
      NotificationService(prefs: prefs),
    ),
    jsonFileCacheProvider.overrideWithValue(files),
    rrHistoryStoreProvider.overrideWithValue(RrHistoryStore(HomeMemoryCache())),
    pvpApiProvider.overrideWithValue(api),
    clockProvider.overrideWithValue(clock),
    remoteConfigProvider.overrideWithValue(const RemoteConfig()),
    contentProvider.overrideWith((ref) async => content),
    priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
    contentMissReporterProvider.overrideWith(
      (ref) => _CountingMissReporter(ref, misses),
    ),
    appForegroundProvider.overrideWith(() => foreground),
    xmppServiceProvider.overrideWith((ref) {
      xmppCreated++;
      return null;
    }),
  ];
}

// -------------------------------------------------- view-model overrides

Override vmLive(HomeLiveSnapshot? v) =>
    homeLiveSnapshotProvider.overrideWith((ref, puuid) => v);

Override vmStore(AsyncValue<HomeStoreSummary?> v) =>
    homeStoreSummaryProvider.overrideWith((ref, puuid) => v);

Override vmRank(AsyncValue<HomeRankSnapshot?> v) =>
    homeRankSnapshotProvider.overrideWith((ref, puuid) => v);

Override vmBp(AsyncValue<HomeBpSnapshot?> v) =>
    homeBattlePassSnapshotProvider.overrideWith((ref, puuid) => v);

List<Override> vmFriends(AsyncValue<HomeFriendsSnapshot?> v) => [
  homeFriendsLiveProvider.overrideWith((ref) => true),
  homeFriendsSnapshotProvider.overrideWith((ref) => v),
];

Override vmCommunity(AsyncValue<HomeCommunitySnapshot?> v) =>
    homeCommunitySnapshotProvider.overrideWith((ref, puuid) => v);

Override vmOthers(HomeOtherAccounts? v) =>
    homeOtherAccountsProvider.overrideWith((ref) => v);

Override vmStatus(HomeServerStatus? v) =>
    homeServerStatusProvider.overrideWith((ref) => v);

/// View-model overrides for every card; each defaults to "no data".
List<Override> vmWith({
  HomeLiveSnapshot? live,
  AsyncValue<HomeStoreSummary?> store = const AsyncData(null),
  AsyncValue<HomeRankSnapshot?> rank = const AsyncData(null),
  AsyncValue<HomeBpSnapshot?> bp = const AsyncData(null),
  AsyncValue<HomeFriendsSnapshot?> friends = const AsyncData(null),
  AsyncValue<HomeCommunitySnapshot?> community = const AsyncData(null),
  HomeOtherAccounts? others,
  HomeServerStatus? status,

  /// Replaces [store] (a provider can only be overridden once).
  Override? storeOverride,
  Override? liveOverride,

  /// Leaves the live card to the real live-game provider.
  bool realLive = false,
}) => [
  if (!realLive) liveOverride ?? vmLive(live),
  storeOverride ?? vmStore(store),
  vmRank(rank),
  vmBp(bp),
  ...vmFriends(friends),
  vmCommunity(community),
  vmOthers(others),
  vmStatus(status),
];

/// Every card has data (the "full" dashboard).
List<Override> vmFull({
  HomeLiveSnapshot? live,
  HomeServerStatus? status,
  bool friends = true,
  Override? storeOverride,
  Override? liveOverride,
  bool realLive = false,
}) => vmWith(
  realLive: realLive,
  storeOverride: storeOverride,
  liveOverride: liveOverride,
  live: live,
  store: AsyncData(homeStoreSummary()),
  rank: AsyncData(homeRankSnapshot()),
  bp: AsyncData(homeBpSnapshot()),
  friends: AsyncData(friends ? homeFriendsSnapshot() : null),
  community: AsyncData(homeCommunitySnapshot()),
  others: homeOtherAccounts(),
  status: status,
);

/// Nothing has data (a signed-in player with an empty dashboard).
List<Override> vmEmpty() => vmWith();

// ------------------------------------------------------- data builders

Storefront homeStorefront({bool cache = false, DateTime? at}) =>
    Storefront.fromJson(
      economyFixture('storefront.json'),
      receivedAt: at ?? homeNow,
      isFromCache: cache,
    );

HomeStoreSummary homeStoreSummary({
  Set<String> wishlist = const {},
  int? wallet = 2440,
  Set<String> seen = const {},
  bool cache = false,
  ContentDb? db,
}) => buildHomeStoreSummary(
  homeStorefront(cache: cache),
  db: db ?? economyContent(),
  wishlist: wishlist,
  wallet: wallet == null
      ? null
      : Wallet.fromJson({
          'Balances': {'85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741': wallet},
        }, receivedAt: homeNow),
  nightMarketSeen: seen,
  now: homeNow,
)!;

CompetitiveUpdate _row(String id, DateTime start, int earned) =>
    CompetitiveUpdate.fromJson(
      updateRow(
        id,
        start: start,
        rrBefore: 50,
        rrAfter: 50 + earned,
        earned: earned,
      ),
    )!;

/// Kim Cương 1, 6 RR, +37 RR today (3 wins, 1 loss), a win streak.
/// [daysAgo] moves the four games back (then it is the "last day").
HomeRankSnapshot homeRankSnapshot({
  int tier = 18,
  int rr = 6,
  int daysAgo = 0,
  bool streak = true,
  bool lossStreak = false,
  bool noGames = false,
  int? matches = 9,
  int? leaderboard,
  int gamesNeeded = 0,
  RankInfo? previousAct,
}) {
  final db = testContent();
  final current = RankInfo.resolve(
    db,
    tier: tier,
    rr: rr,
    actUuid: actV,
    gamesNeeded: gamesNeeded,
  );
  DateTime at(int hoursAgo) =>
      homeNow.subtract(Duration(days: daysAgo, hours: hoursAgo));
  final rows = noGames
      ? <CompetitiveUpdate>[]
      : [
          _row('e0000000-0000-4000-8000-000000000001', at(1), 22),
          _row('e0000000-0000-4000-8000-000000000002', at(2), 20),
          _row('e0000000-0000-4000-8000-000000000003', at(3), -15),
          _row('e0000000-0000-4000-8000-000000000004', at(4), 10),
        ];
  final days = groupDailyRr(rows);
  final ranked = !current.isUnranked;
  final belowImmortal = ranked && tier < 24;
  return HomeRankSnapshot(
    current: current,
    progress: belowImmortal ? rr / 100 : null,
    rrToNext: belowImmortal ? 100 - rr : null,
    today: daysAgo == 0 ? dailyRrOn(days, homeNow) : null,
    lastDay: daysAgo == 0 || days.isEmpty ? null : days.first,
    streak: streak
        ? RankedStreak(lossStreak ? StreakKind.loss : StreakKind.win, 2)
        : null,
    matchesToNext: belowImmortal ? matches : null,
    nextTierName: belowImmortal ? 'Kim Cương 2' : null,
    leaderboard: leaderboard,
    previousAct: previousAct,
  );
}

HomeBpSnapshot homeBpSnapshot({
  bool withEvent = true,
  bool complete = false,
  bool allMissionsDone = false,
  bool cache = false,
}) {
  final overview = BattlePassOverview.build(
    db: bpContent(withEvent: withEvent),
    contracts: PlayerContracts.fromJson(
      contractsJson(
        level: complete ? 55 : 46,
        inLevel: complete ? 0 : 7966,
        total: complete ? 1162500 : 840466,
        missions: allMissionsDone
            ? [
                activeMission(Bp.missionUlt, Bp.objUlt, 15, complete: true),
                activeMission(
                  Bp.missionDamage,
                  Bp.objDamage,
                  18000,
                  complete: true,
                ),
                activeMission(
                  Bp.missionHeadshots,
                  Bp.objHeadshots,
                  40,
                  complete: true,
                ),
              ]
            : null,
      ),
      receivedAt: homeNow,
      isFromCache: cache,
    ),
    now: homeNow,
    premiumContracts: {Bp.bpId},
  );
  return buildHomeBpSnapshot(
    overview,
    ticket: DailyTicket.fromJson(dailyTicketJson(), receivedAt: homeNow),
    now: homeNow,
  )!;
}
