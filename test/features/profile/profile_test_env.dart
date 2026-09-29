import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_prefs.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MockSessionManager extends Mock implements SessionManager {}

/// PUUIDs of `test/fixtures/competitive/*.json`.
const me = 'aaaaaaaa-0000-4000-8000-000000000001';
const mate = 'aaaaaaaa-0000-4000-8000-000000000002';
const enemy1 = 'bbbbbbbb-0000-4000-8000-000000000003';
const stranger = 'eeeeeeee-0000-4000-8000-00000000000e';

/// Match ids of the fixtures.
const compMatch = 'd1000000-0000-4000-8000-000000000001';
const dmMatch = 'd2000000-0000-4000-8000-000000000002';
const customMatch = 'd3000000-0000-4000-8000-000000000003';
const tdmMatch = 'd4000000-0000-4000-8000-000000000004';

/// Acts of the content fixtures.
const actV = '8102cd81-43a0-d0d7-bd59-47b8fe9bed1b'; // V26 // PHẦN V
const actI = '3f61c772-4560-cd3f-5d3f-a7ab5abda6b3'; // HỒI 1 // PHẦN I

/// A player card of the content fixtures.
const cardId = '1711d20d-4b1c-c64a-14be-d4ae58a457c6';

const myAccount = Account(
  puuid: me,
  gameName: 'Tôi',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
  level: 200,
);

Object? competitiveFixture(String name) =>
    jsonDecode(File('test/fixtures/competitive/$name.json').readAsStringSync());

JsonMap competitiveFixtureMap(String name) => asMap(competitiveFixture(name))!;

final ContentDb _content = ContentDb.parse(loadContentFixtures());

ContentDb testContent() => _content;

/// In-memory [JsonFileCache] (no `dart:io` inside fake-async widget tests).
class MemoryJsonFileCache extends JsonFileCache {
  MemoryJsonFileCache() : super(() => throw UnimplementedError());

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

/// One P-12 row.
JsonMap updateRow(
  String matchId, {
  required DateTime start,
  int tierBefore = 17,
  int tierAfter = 17,
  int rrBefore = 50,
  int rrAfter = 50,
  int earned = 0,
  String map = '/Game/Maps/Ascent/Ascent',
  String season = actV,
}) => {
  'MatchID': matchId,
  'MapID': map,
  'SeasonID': season,
  'MatchStartTime': start.millisecondsSinceEpoch,
  'TierBeforeUpdate': tierBefore,
  'TierAfterUpdate': tierAfter,
  'RankedRatingBeforeUpdate': rrBefore,
  'RankedRatingAfterUpdate': rrAfter,
  'RankedRatingEarned': earned,
};

/// Default P-12 page: the competitive fixture match (+24 today) and two
/// older matches.
JsonMap defaultUpdates() => {
  'Subject': me,
  'Matches': [
    updateRow(
      compMatch,
      start: DateTime.utc(2026, 9, 28, 4),
      tierBefore: 17,
      tierAfter: 18,
      rrBefore: 82,
      rrAfter: 6,
      earned: 24,
    ),
    updateRow(
      'e2000000-0000-4000-8000-000000000002',
      start: DateTime.utc(2026, 9, 27, 18),
      rrBefore: 100,
      rrAfter: 82,
      earned: -18,
    ),
    updateRow(
      'e1000000-0000-4000-8000-000000000001',
      start: DateTime.utc(2026, 9, 27, 17),
      rrBefore: 80,
      rrAfter: 100,
      earned: 20,
    ),
  ],
};

/// Every override the profile screens need: no plugins, no network.
class ProfileTestEnv {
  ProfileTestEnv._(this.prefs);

  static Future<ProfileTestEnv> create({
    List<Account> accounts = const [myAccount],
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    if (accounts.isNotEmpty) {
      await prefs.setString(PrefKeys.activePuuid, accounts.first.puuid);
    }
    final env = ProfileTestEnv._(prefs).._stubDefaults();
    return env;
  }

  final Prefs prefs;
  final api = MockPvpApi();
  final sessions = MockSessionManager();
  final files = MemoryJsonFileCache();
  late final history = RrHistoryStore(MemoryJsonFileCache());
  final clock = FixedClock(DateTime.utc(2026, 9, 28, 12));

  /// Match details by id (lowercase) served by [api].
  final matches = <String, Object?>{
    compMatch: competitiveFixture('match_competitive'),
    dmMatch: competitiveFixture('match_deathmatch'),
    customMatch: competitiveFixture('match_custom'),
    tdmMatch: competitiveFixture('match_tdm'),
  };

  /// Match history pages by queue (`null` = all).
  final Map<String?, JsonMap> historyByQueue = {
    null: competitiveFixtureMap('match_history'),
  };

  JsonMap updates = defaultUpdates();
  JsonMap mmr = competitiveFixtureMap('mmr');

  List<Override> get overrides => [
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(MemorySecureStore()),
    sessionManagerProvider.overrideWithValue(sessions),
    jsonFileCacheProvider.overrideWithValue(files),
    rrHistoryStoreProvider.overrideWithValue(history),
    pvpApiProvider.overrideWithValue(api),
    contentProvider.overrideWith((ref) async => testContent()),
    clockProvider.overrideWithValue(clock),
    remoteConfigProvider.overrideWithValue(const RemoteConfig()),
  ];

  void _stubDefaults() {
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => api.platformStatus(any()))
        .thenAnswer((_) async => <String, dynamic>{});
    when(() => api.mmr(any(), subject: any(named: 'subject')))
        .thenAnswer((_) async => mmr);
    when(
      () => api.competitiveUpdates(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
      ),
    ).thenAnswer((inv) async {
      final start = inv.namedArguments[#startIndex] as int;
      return start == 0 ? updates : {'Subject': me, 'Matches': <Object>[]};
    });
    when(
      () => api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
      ),
    ).thenAnswer((inv) async {
      final queue = inv.namedArguments[#queue] as String?;
      final start = inv.namedArguments[#startIndex] as int;
      final page =
          historyByQueue[queue] ??
          {'Subject': me, 'Total': 0, 'History': <Object>[]};
      return start == 0
          ? page
          : {'Subject': me, 'Total': 0, 'History': <Object>[]};
    });
    when(() => api.matchDetails(any(), any())).thenAnswer((inv) async {
      final id = (inv.positionalArguments[1] as String).toLowerCase();
      final json = matches[id];
      if (json == null) {
        throw StateError('no fixture for $id');
      }
      return asMap(json)!;
    });
    when(() => api.names(any(), any()))
        .thenAnswer((_) async => asMapList(competitiveFixture('name_service')));
    when(() => api.accountXp(any()))
        .thenAnswer((_) async => competitiveFixtureMap('account_xp'));
    when(() => api.playerLoadout(any())).thenAnswer(
      (_) async => {
        'Subject': me,
        'Identity': {
          'PlayerCardID': cardId.toUpperCase(),
          'PlayerTitleID': '00000000-0000-0000-0000-000000000000',
          'PreferredLevelBorderID': '00000000-0000-0000-0000-000000000000',
          'HideAccountLevel': false,
        },
        'Incognito': false,
      },
    );
  }
}

/// Registers mocktail fallback values (call from `setUpAll`).
void registerProfileFallbacks() {
  registerFallbackValue(<String>[]);
}

/// Pumps [child] at phone size (360 × [height] dp) with the dark theme.
Future<void> pumpProfile(
  WidgetTester tester,
  ProfileTestEnv env,
  Widget child, {
  double height = 1400,
}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp(theme: buildDarkTheme(), home: child),
    ),
  );
}

/// Pumps a [GoRouter] app (for navigation tests).
Future<GoRouter> pumpProfileRouter(
  WidgetTester tester,
  ProfileTestEnv env, {
  required List<RouteBase> routes,
  required String initialLocation,
  double height = 1400,
}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp.router(theme: buildDarkTheme(), routerConfig: router),
    ),
  );
  return router;
}

/// Lets futures, the 20 ms name-service batch window and frames run.
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
