import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/app/deep_links.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/app/shell.dart';
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
import 'package:valvn/core/ui/floating_nav_bar.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/battlepass/ui/battlepass_screen.dart';
import 'package:valvn/features/collection/ui/collection_screen.dart';
import 'package:valvn/features/community/data/community_http.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/ui/community_screen.dart';
import 'package:valvn/features/home/ui/home_screen.dart';
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

/// The community server is unreachable too.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => Future.error(
    DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    ),
  );

  @override
  void close({bool force = false}) {}
}

/// A notification service whose taps the test drives.
class _TapService extends NotificationService {
  _TapService({super.prefs});

  final controller = StreamController<String>.broadcast();

  @override
  Stream<String> get taps => controller.stream;

  @override
  Future<void> dispose() => controller.close();
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

/// Taps the destination labelled [label]. On narrow phones only the
/// selected tab shows its label, so tap the destination, not the text.
Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FloatingNavBar),
      matching: find.bySemanticsLabel(label),
    ),
  );
  await _settle(tester);
}

/// Taps the back arrow of the header (the tooltip is localized, so look for
/// the button itself).
Future<void> _back(WidgetTester tester) async {
  final button = find.byType(BackButton);
  expect(button, findsOneWidget, reason: 'one back arrow expected');
  await tester.tap(button);
  await _settle(tester);
}

int _selectedTab(WidgetTester tester) =>
    tester.widget<FloatingNavBar>(find.byType(FloatingNavBar)).selectedIndex;

/// Integration smoke test: the signed-in app with every real feature
/// wired through the router, the tab shell and the live-game overlay.
void main() {
  late Prefs prefs;
  late _TapService notifications;

  setUp(() async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [_first.toJson(), _second.toJson()]);
    await prefs.setString(PrefKeys.activePuuid, _first.puuid);
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    notifications = _TapService(prefs: prefs);
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
          notificationServiceProvider.overrideWithValue(notifications),
          pvpApiProvider.overrideWithValue(_OfflinePvpApi()),
          jsonFileCacheProvider.overrideWithValue(_MemoryJsonCache()),
          contentProvider.overrideWith((ref) async => economyContent()),
          priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
          contentMissReporterProvider.overrideWith(_NoopMissReporter.new),
          xmppServiceProvider.overrideWith((ref) => null),
          communityHttpProvider.overrideWithValue(
            CommunityHttp(
              dio: Dio()..httpClientAdapter = _OfflineAdapter(),
              baseUrl: 'https://community.test',
            ),
          ),
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

  testWidgets('the app starts on Trang chủ; every tab builds offline', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(_selectedTab(tester), AppTab.home.index);
    // Core cards (store, rank, Battle Pass) show a compact error with a
    // retry button instead of an empty page.
    expect(find.text(CommonStrings.retry), findsWidgets);

    await _tapTab(tester, CommonStrings.tabStore);
    expect(find.byType(StoreScreen), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsWidgets);

    await _tapTab(tester, CommonStrings.tabCommunity);
    expect(find.byType(CommunityScreen), findsOneWidget);

    await _tapTab(tester, CommonStrings.tabCollection);
    expect(find.byType(CollectionScreen), findsOneWidget);

    await _tapTab(tester, CommonStrings.tabProfile);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsWidgets);

    // Back to the first tab: its state was kept by the indexed stack.
    await _tapTab(tester, CommonStrings.tabHome);
    expect(find.byType(HomeScreen), findsOneWidget);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('Battle Pass opens from the Hồ sơ row and by its route', (
    tester,
  ) async {
    await pumpApp(tester);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(ValVnApp)),
    ).read(routerProvider);

    await _tapTab(tester, CommonStrings.tabProfile);
    final row = find.text(CommonStrings.tabBattlePass);
    await tester.ensureVisible(row);
    await tester.tap(row);
    await _settle(tester);
    expect(find.byType(BattlePassScreen), findsOneWidget);
    expect(_selectedTab(tester), AppTab.profile.index);

    // Back returns to Hồ sơ.
    await _back(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);

    router.go('/battlepass');
    await _settle(tester);
    expect(find.byType(BattlePassScreen), findsOneWidget);
    expect(_selectedTab(tester), AppTab.profile.index);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('Cài đặt opens from the ⚙ of Trang chủ and of Hồ sơ', (
    tester,
  ) async {
    await pumpApp(tester);

    // From Trang chủ: pushed inside the Home tab, Back returns to it.
    await tester.tap(find.byTooltip(CommonStrings.tabSettings));
    await _settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(_selectedTab(tester), AppTab.home.index);
    expect(find.textContaining(_second.gameName), findsWidgets);
    await _back(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    // From Hồ sơ.
    await _tapTab(tester, CommonStrings.tabProfile);
    await tester.tap(find.byTooltip(CommonStrings.tabSettings));
    await _settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(_selectedTab(tester), AppTab.profile.index);
    await _back(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('a /settings link opens Hồ sơ with Cài đặt on top of it', (
    tester,
  ) async {
    await pumpApp(tester);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(ValVnApp)),
    ).read(routerProvider);

    openAppLink(router, parseDeepLink('/settings'));
    await _settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(_selectedTab(tester), AppTab.profile.index);

    await _back(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('a store notification switches the account and the segment', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    expect(container.read(activeAccountProvider)?.puuid, _first.puuid);

    notifications.controller.add(
      '/store?segment=nightmarket&account=${_second.puuid}',
    );
    await _settle(tester);

    expect(container.read(activeAccountProvider)?.puuid, _second.puuid);
    expect(_selectedTab(tester), AppTab.store.index);
    final store = tester.widget<StoreScreen>(find.byType(StoreScreen));
    expect(store.initialSegment, StoreSegment.nightMarket);

    // A malformed payload lands on the default tab: Trang chủ.
    notifications.controller.add('https://evil.example/x');
    await _settle(tester);
    expect(_selectedTab(tester), AppTab.home.index);

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
    expect(find.byType(FloatingNavBar), findsOneWidget);

    router.go('/profile/friends');
    await _settle(tester);
    expect(find.byType(FriendsScreen), findsOneWidget);

    router.go(ProfileRoutes.rankUp);
    await _settle(tester);
    expect(find.byType(RankUpCalculatorScreen), findsOneWidget);

    router.go('/settings/about/terms');
    await _settle(tester);
    expect(_selectedTab(tester), AppTab.profile.index);

    router.go('/does-not-exist');
    await _settle(tester);
    expect(find.text(CommonStrings.pageNotFound), findsOneWidget);
    // "Về trang chính" goes to the default tab.
    await tester.tap(find.text(CommonStrings.goHome));
    await _settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('switching the active account rebuilds the tabs', (tester) async {
    final container = await pumpApp(tester);
    expect(container.read(activeAccountProvider)?.puuid, _first.puuid);
    expect(find.textContaining(_first.gameName), findsWidgets);

    container.read(activePuuidProvider.notifier).select(_second.puuid);
    await _settle(tester);
    expect(container.read(activeAccountProvider)?.puuid, _second.puuid);
    expect(find.byType(HomeScreen), findsOneWidget);
    // The account chip in the Home header follows the switch.
    expect(find.textContaining(_second.gameName), findsWidgets);

    await _tapTab(tester, CommonStrings.tabStore);
    expect(find.byType(StoreScreen), findsOneWidget);

    await _tapTab(tester, CommonStrings.tabProfile);
    expect(find.byType(ProfileScreen), findsOneWidget);

    expect(tester.takeException(), isNull);
    expect(
      GoRouter.maybeOf(tester.element(find.byType(ProfileScreen))),
      isNotNull,
    );
    await unmount(tester);
  });
}
