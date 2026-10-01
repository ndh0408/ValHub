import 'package:valvn/core/l10n/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/features/wishlist/wishlist_routes.dart';

import '../../core/domain/economy/economy_fixtures.dart';

/// Shared fakes for the wishlist widget tests.

class MockPvpApi extends Mock implements PvpApi {}

/// In-memory [JsonFileCache] (no path_provider in widget tests).
class MemoryJsonCache extends JsonFileCache {
  MemoryJsonCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime.now());
}

/// Notification service that never touches the platform plugin.
class FakeNotificationService extends NotificationService {
  FakeNotificationService({this.enabled = true});

  bool enabled;
  int permissionRequests = 0;
  int settingsOpened = 0;

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return enabled;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async {}

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async {}
}

final t0 = DateTime(2026, 9, 28, 12);

const testAccount = Account(
  puuid: Fx.puuid,
  gameName: 'Người Chơi',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

/// A [PvpApi] serving the economy fixtures (storefront, wallet, skin-level
/// entitlements; other entitlement types answer 404 = empty).
MockPvpApi fixtureApi({Object? storefrontError, Object? entitlementsError}) {
  final api = MockPvpApi();
  if (storefrontError != null) {
    when(() => api.storefront(any())).thenThrow(storefrontError);
  } else {
    when(() => api.storefront(any()))
        .thenAnswer((_) async => economyFixture('storefront.json'));
  }
  when(() => api.wallet(any()))
      .thenAnswer((_) async => economyFixture('wallet.json'));
  when(() => api.entitlements(any(), any())).thenAnswer((inv) async {
    if (entitlementsError != null) throw entitlementsError;
    final type = inv.positionalArguments[1] as String;
    if (type == ItemTypeIds.skinLevel) {
      return economyFixture('entitlements_skin_levels.json');
    }
    throw const NotFoundException();
  });
  when(() => api.platformStatus(any())).thenAnswer((_) async => {});
  return api;
}

/// Counts content-miss reports (no content re-download in tests).
class MissCounter {
  int count = 0;
}

class CountingMissReporter extends ContentMissReporter {
  CountingMissReporter(super.ref, this.counter);

  final MissCounter counter;

  @override
  Future<void> report() async => counter.count++;
}

/// Fixed account list, bypassing the repository.
class FixedAccountsNotifier extends AccountsNotifier {
  FixedAccountsNotifier(this._fixed);

  final List<Account> _fixed;

  @override
  List<Account> build() => _fixed;
}

/// Provider overrides for a signed-in [account] with the economy fixtures.
List<Override> wishlistOverrides({
  required PvpApi api,
  required Prefs prefs,
  Account? account = testAccount,
  NotificationService? notifications,
  Future<ContentDb> Function()? loadContent,
  MissCounter? misses,
}) => [
  pvpApiProvider.overrideWithValue(api),
  prefsProvider.overrideWithValue(prefs),
  jsonFileCacheProvider.overrideWithValue(MemoryJsonCache()),
  clockProvider.overrideWithValue(FixedClock(t0)),
  accountProvider.overrideWith((ref, puuid) => null),
  activeAccountProvider.overrideWithValue(account),
  accountsProvider.overrideWith(() => FixedAccountsNotifier([?account])),
  contentProvider.overrideWith(
    (ref) async => loadContent != null ? await loadContent() : economyContent(),
  ),
  priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
  notificationServiceProvider.overrideWithValue(
    notifications ?? FakeNotificationService(),
  ),
  contentMissReporterProvider.overrideWith(
    (ref) => CountingMissReporter(ref, misses ?? MissCounter()),
  ),
];

/// App wrapper with the real dark theme and no provider retries.
Widget testApp({
  required List<Override> overrides,
  required Widget home,
  ThemeData? theme,
}) => ProviderScope(
  overrides: overrides,
  retry: (_, _) => null,
  child: MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? buildDarkTheme(),
    home: home,
  ),
);

/// Router app: `/collection` + the wishlist routes, and stub `/store`
/// pages that print their location.
Widget routerTestApp({
  required List<Override> overrides,
  required String initialLocation,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/collection',
        builder: (context, state) => const Scaffold(body: Text('HUB')),
        routes: wishlistRoutes,
      ),
      GoRoute(
        path: '/store',
        builder: (context, state) => Scaffold(body: Text('STORE ${state.uri}')),
        routes: [
          GoRoute(
            path: 'bundle/:id',
            builder: (context, state) =>
                Scaffold(body: Text('BUNDLE ${state.pathParameters['id']}')),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    retry: (_, _) => null,
    child: MaterialApp.router(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildDarkTheme(),
      routerConfig: router,
    ),
  );
}

/// Uses a small-phone viewport (360×740 dp) for the rest of the test.
void usePhoneViewport(WidgetTester tester, {Size size = const Size(360, 740)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Lets pending futures settle without `pumpAndSettle` (countdowns and
/// shimmers tick forever).
Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Unmounts the tree so countdown and provider-refresh timers are
/// cancelled before the test ends.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}
