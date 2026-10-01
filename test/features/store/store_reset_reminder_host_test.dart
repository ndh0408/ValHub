import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/features/home/ui/home_screen.dart';
import 'package:valvn/features/store/store_reset_reminder_host.dart';
import 'package:valvn/features/store/store_routes.dart';
import 'package:valvn/features/store/store_strings.dart';
import 'package:valvn/features/store/ui/store_screen.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import 'store_test_harness.dart';

const _a = Account(
  puuid: Fx.puuid,
  gameName: 'Người Chơi',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

const _b = Account(
  puuid: 'aaaaaaaa-0000-4000-8000-000000000002',
  gameName: 'Tài Khoản Hai',
  tagLine: 'VN3',
  region: 'ap',
  shard: 'ap',
);

class _Env {
  _Env._(this.prefs, this.api, this.notifications, this.cache);

  static Future<_Env> create({
    bool on = true,
    List<Account> accounts = const [_a],
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    await prefs.setString(PrefKeys.activePuuid, accounts.first.puuid);
    if (on) {
      await prefs.setJson(
        PrefKeys.appSettings,
        const AppSettings(storeResetNotifications: true).toJson(),
      );
    }
    return _Env._(
      prefs,
      fixtureApi(),
      RecordingNotificationService(),
      MemoryJsonCache(),
    );
  }

  final Prefs prefs;
  final MockPvpApi api;
  final RecordingNotificationService notifications;
  final MemoryJsonCache cache;

  List<Override> get overrides => [
    pvpApiProvider.overrideWithValue(api),
    prefsProvider.overrideWithValue(prefs),
    jsonFileCacheProvider.overrideWithValue(cache),
    clockProvider.overrideWithValue(FixedClock(t0)),
    notificationServiceProvider.overrideWithValue(notifications),
    contentProvider.overrideWith((ref) async => economyContent()),
    priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
  ];
}

Future<ProviderContainer> _pumpHost(WidgetTester tester, _Env env) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: const MaterialApp(home: StoreResetReminderHost(child: SizedBox())),
    ),
  );
  await settle(tester);
  return ProviderScope.containerOf(
    tester.element(find.byType(StoreResetReminderHost)),
  );
}

void main() {
  testWidgets('scheduled at the reset time when the setting is on', (
    tester,
  ) async {
    final env = await _Env.create();
    await _pumpHost(tester, env);

    expect(env.notifications.calls, hasLength(5));
    final call = env.notifications.calls.first;
    expect(call.id, NotificationIds.storeReset(Fx.puuid));
    expect(call.at, t0.add(const Duration(seconds: 17401, minutes: 1)));
    expect(call.title, StoreStrings.resetNotificationTitle);
    expect(call.body, 'Skin mới đang chờ bạn trong cửa hàng.');
    expect(call.channel, NotificationChannel.storeReset);
    expect(call.payload, '${StoreRoutes.root}?account=${Fx.puuid}');
    expect(call.accountPuuid, Fx.puuid);

    // Rebuilds with the same storefront do not reschedule.
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(env.notifications.calls, hasLength(5));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('not scheduled when the setting is off (and no fetch)', (
    tester,
  ) async {
    final env = await _Env.create(on: false);
    await _pumpHost(tester, env);
    expect(env.notifications.calls, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('rescheduled once per new storefront, not on rebuilds', (
    tester,
  ) async {
    final env = await _Env.create();
    final container = await _pumpHost(tester, env);
    expect(env.notifications.calls, hasLength(5));

    // The storefront refetches (e.g. at the daily reset): one more.
    container.invalidate(storefrontProvider(Fx.puuid));
    await settle(tester);
    expect(env.notifications.calls, hasLength(10));
    await settle(tester);
    expect(env.notifications.calls, hasLength(10));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('switching the account schedules it for the new account', (
    tester,
  ) async {
    final env = await _Env.create(accounts: const [_a, _b]);
    final container = await _pumpHost(tester, env);
    expect(
      env.notifications.calls.map((c) => c.accountPuuid),
      contains(_a.puuid),
    );

    container.read(activePuuidProvider.notifier).select(_b.puuid);
    await settle(tester);
    final call = env.notifications.calls.firstWhere(
      (c) => c.accountPuuid == _b.puuid,
    );
    expect(call.id, NotificationIds.storeReset(_b.puuid));
    expect(call.payload, '${StoreRoutes.root}?account=${_b.puuid}');
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
    'other accounts are scheduled from their saved storefront, no network',
    (tester) async {
      final env = await _Env.create(accounts: const [_a, _b]);
      // B's storefront was saved an hour ago: its reset is still ahead.
      env.cache.entries[JsonFileCache.accountKey(
        _b.puuid,
        'economy_storefront',
      )] = CachedJson(
        economyFixture('storefront.json'),
        t0.subtract(const Duration(hours: 1)),
      );
      await _pumpHost(tester, env);
      await settle(tester);

      final forB = env.notifications.calls.where(
        (c) => c.accountPuuid == _b.puuid,
      );
      expect(forB, hasLength(5));
      expect(
        forB.first.at,
        t0
            .subtract(const Duration(hours: 1))
            .add(const Duration(seconds: 17401, minutes: 1)),
      );
      // The network was used for the active account only.
      verify(() => env.api.storefront(_a.puuid)).called(1);
      verifyNever(() => env.api.storefront(_b.puuid));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  testWidgets('an expired saved storefront advances to the next reset', (
    tester,
  ) async {
    final env = await _Env.create(accounts: const [_a, _b]);
    env.cache.entries[JsonFileCache.accountKey(
      _b.puuid,
      'economy_storefront',
    )] = CachedJson(
      economyFixture('storefront.json'),
      t0.subtract(const Duration(days: 3)),
    );
    await _pumpHost(tester, env);
    await settle(tester);
    expect(
      env.notifications.calls.where((c) => c.accountPuuid == _b.puuid),
      hasLength(5),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('an account that must sign in again gets no reminder', (
    tester,
  ) async {
    final env = await _Env.create(accounts: [_a.copyWith(needsLogin: true)]);
    await _pumpHost(tester, env);
    expect(env.notifications.calls, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
    'the app schedules it with Trang chủ as landing tab and no Store tab',
    (tester) async {
      final env = await _Env.create();
      usePhoneViewport(tester);
      final router = createAppRouter(
        hasAccounts: ValueNotifier(true),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: env.overrides,
          retry: (_, _) => null,
          child: MaterialApp.router(
            theme: buildDarkTheme(),
            routerConfig: router,
          ),
        ),
      );
      await settle(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      // The Store branch is not built until it is opened.
      expect(find.byType(StoreScreen), findsNothing);
      expect(env.notifications.calls, hasLength(5));
      expect(
        env.notifications.calls.first.at,
        t0.add(const Duration(seconds: 17401, minutes: 1)),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 6));
    },
  );
}
