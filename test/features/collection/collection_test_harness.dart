import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/account_xp.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/collection/collection_routes.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../core/domain/loadout/loadout_fixtures.dart';

/// Shared fakes for the collection widget tests.

class MockPvpApi extends Mock implements PvpApi {}

/// In-memory [JsonFileCache] (no path_provider in widget tests).
class MemoryJsonCache extends JsonFileCache {
  MemoryJsonCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime(2026));
}

class _NoopMissReporter extends ContentMissReporter {
  _NoopMissReporter(super.ref);

  @override
  Future<void> report() async {}
}

final t0 = DateTime(2026, 9, 29, 12);

const testAccount = Account(
  puuid: Lx.puuid,
  gameName: 'Người Chơi',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

/// A fake Riot: serves [server] as the loadout (PUT replaces it and bumps
/// `Version`) and the economy entitlement fixtures. Records PUT bodies.
class FakeRiot {
  FakeRiot({JsonMap? loadout}) : server = loadout ?? loadoutJson() {
    registerFallbackValue(<String, dynamic>{});
    when(() => api.playerLoadout(any())).thenAnswer((_) async {
      if (loadoutError case final e?) throw e;
      return server;
    });
    when(() => api.putPlayerLoadout(any(), any())).thenAnswer((inv) async {
      if (putError case final e?) throw e;
      final body = inv.positionalArguments[1] as JsonMap;
      puts.add(body);
      server = {...body, 'Version': (asInt(body['Version']) ?? 0) + 1};
      return server;
    });
    when(() => api.entitlements(any(), any())).thenAnswer((inv) async {
      if (entitlementsError case final e?) throw e;
      final type = inv.positionalArguments[1] as String;
      return entitlementsFor(type) ?? (throw const NotFoundException());
    });
    when(() => api.platformStatus(any())).thenAnswer((_) async => {});
  }

  final api = MockPvpApi();
  JsonMap server;
  final puts = <JsonMap>[];
  Object? loadoutError;
  Object? putError;
  Object? entitlementsError;

  JsonMap get lastPut => puts.last;
}

/// Provider overrides for [testAccount] with the fixtures.
List<Override> collectionOverrides({
  required FakeRiot riot,
  required Prefs prefs,
  MemoryJsonCache? cache,
  int accountLevel = 120,
}) => [
  pvpApiProvider.overrideWithValue(riot.api),
  prefsProvider.overrideWithValue(prefs),
  jsonFileCacheProvider.overrideWithValue(cache ?? MemoryJsonCache()),
  clockProvider.overrideWithValue(FixedClock(t0)),
  accountProvider.overrideWith((ref, puuid) => null),
  activeAccountProvider.overrideWithValue(testAccount),
  contentProvider.overrideWith((ref) async => economyContent()),
  priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
  contentMissReporterProvider.overrideWith(_NoopMissReporter.new),
  accountXpProvider.overrideWith(
    (ref, puuid) async => AccountXp(level: accountLevel),
  ),
];

/// App with the real dark theme; [home] is shown inside a router that also
/// knows the collection routes (so `context.push` works).
Widget collectionApp({
  required List<Override> overrides,
  required Widget home,
  ThemeData? theme,
}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, _) => home),
      ...collectionBranchRoutes(
        nested: [
          GoRoute(
            path: 'wishlist',
            builder: (_, _) => const Scaffold(body: Text('wishlist')),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Text('login')),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    retry: (_, _) => null,
    child: MaterialApp.router(
      theme: theme ?? buildDarkTheme(),
      routerConfig: router,
    ),
  );
}

/// Small-phone viewport (360×740 dp).
void usePhoneViewport(WidgetTester tester, {Size size = const Size(360, 740)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Pumps a few frames, then lets route / sheet / menu animations finish
/// (skeleton shimmers never settle, so no `pumpAndSettle`).
Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 16));
}

/// Pumps [screen] at phone size and lets the fakes answer.
Future<void> pumpCollection(
  WidgetTester tester,
  Widget screen, {
  required FakeRiot riot,
  required Prefs prefs,
  MemoryJsonCache? cache,
  ThemeData? theme,
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    collectionApp(
      overrides: collectionOverrides(riot: riot, prefs: prefs, cache: cache),
      home: screen,
      theme: theme,
    ),
  );
  await settle(tester);
}

/// Unmounts the tree so provider keep-alive timers are cancelled.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 11));
}
