import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/battlepass/ui/battlepass_screen.dart';
import 'package:valvn/features/collection/ui/collection_screen.dart';
import 'package:valvn/features/profile/profile_routes.dart';
import 'package:valvn/features/profile/ui/profile_screen.dart';
import 'package:valvn/features/profile/ui/rank_up_calculator_screen.dart';
import 'package:valvn/features/settings/ui/settings_screen.dart';
import 'package:valvn/features/social/ui/friends_screen.dart';
import 'package:valvn/features/store/ui/store_screen.dart';
import 'package:valvn/features/wishlist/ui/wishlist_screen.dart';

import '../core/domain/economy/economy_fixtures.dart';
import '../helpers/test_prefs.dart';

/// Riot is unreachable: every game-client call fails with a transient
/// error, so each screen must show its error state (never crash).
class _OfflinePvpApi implements PvpApi {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<Never>.error(const TransientException(reason: 'offline'));
}

/// In-memory [JsonFileCache] (no path_provider in widget tests).
class _MemoryJsonCache extends JsonFileCache {
  _MemoryJsonCache() : super(() => throw UnimplementedError());

  final _entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => _entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      _entries[key] = CachedJson(data, savedAt ?? DateTime(2026));
}

class _NoopMissReporter extends ContentMissReporter {
  _NoopMissReporter(super.ref);

  @override
  Future<void> report() async {}
}

const _first = Account(
  puuid: 'c5a5af97-d9b8-5217-9d26-1b35f93ca3d0',
  gameName: 'Người Chơi Một',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
);

const _second = Account(
  puuid: 'aaaaaaaa-0000-4000-8000-000000000002',
  gameName: 'Người Chơi Hai',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

/// Pumps frames without waiting for shimmers / countdowns to settle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await _settle(tester);
}

/// Integration smoke test: the signed-in app with every real feature
/// wired through the router, the tab shell and the live-game overlay.
void main() {
  late Prefs prefs;

  setUp(() async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [_first.toJson(), _second.toJson()]);
    await prefs.setString(PrefKeys.activePuuid, _first.puuid);
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          secureStoreProvider.overrideWithValue(MemorySecureStore()),
          sessionLogProvider.overrideWithValue(SessionLog()),
          notificationServiceProvider.overrideWithValue(
            NotificationService(prefs: prefs),
          ),
          pvpApiProvider.overrideWithValue(_OfflinePvpApi()),
          jsonFileCacheProvider.overrideWithValue(_MemoryJsonCache()),
          contentProvider.overrideWith((ref) async => economyContent()),
          priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
          contentMissReporterProvider.overrideWith(_NoopMissReporter.new),
          xmppServiceProvider.overrideWith((ref) => null),
        ],
        child: const ValVnApp(),
      ),
    );
    await _settle(tester);
    return ProviderScope.containerOf(tester.element(find.byType(ValVnApp)));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 11));
  }

  testWidgets('every tab builds and shows an error with "Thử lại" offline', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(StoreScreen), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsWidgets);

    await _tapTab(tester, CommonStrings.tabBattlePass);
    expect(find.byType(BattlePassScreen), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsWidgets);

    await _tapTab(tester, CommonStrings.tabCollection);
    expect(find.byType(CollectionScreen), findsOneWidget);

    await _tapTab(tester, CommonStrings.tabProfile);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsWidgets);

    await _tapTab(tester, CommonStrings.tabSettings);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.textContaining(_second.gameName), findsWidgets);

    // Back to the first tab: its state was kept by the indexed stack.
    await _tapTab(tester, CommonStrings.tabStore);
    expect(find.byType(StoreScreen), findsOneWidget);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('cross-feature routes open inside their tabs', (tester) async {
    await pumpApp(tester);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(ValVnApp)),
    ).read(routerProvider);

    router.go('/collection/wishlist');
    await _settle(tester);
    expect(find.byType(WishlistScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    router.go('/profile/friends');
    await _settle(tester);
    expect(find.byType(FriendsScreen), findsOneWidget);

    router.go(ProfileRoutes.rankUp);
    await _settle(tester);
    expect(find.byType(RankUpCalculatorScreen), findsOneWidget);

    router.go('/does-not-exist');
    await _settle(tester);
    expect(find.text(CommonStrings.pageNotFound), findsOneWidget);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('switching the active account rebuilds the tabs', (tester) async {
    final container = await pumpApp(tester);
    expect(container.read(activeAccountProvider)?.puuid, _first.puuid);

    container.read(activePuuidProvider.notifier).select(_second.puuid);
    await _settle(tester);
    expect(container.read(activeAccountProvider)?.puuid, _second.puuid);
    expect(find.byType(StoreScreen), findsOneWidget);

    await _tapTab(tester, CommonStrings.tabProfile);
    expect(find.byType(ProfileScreen), findsOneWidget);

    await _tapTab(tester, CommonStrings.tabSettings);
    // The switched-to account is the selected one in the account list.
    expect(find.textContaining(_second.gameName), findsWidgets);

    expect(tester.takeException(), isNull);
    expect(
      GoRouter.maybeOf(tester.element(find.byType(SettingsScreen))),
      isNotNull,
    );
    await unmount(tester);
  });
}
