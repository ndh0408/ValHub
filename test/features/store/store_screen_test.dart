import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/store/providers/night_market_seen.dart';
import 'package:valvn/features/store/store_routes.dart';
import 'package:valvn/features/store/store_strings.dart';
import 'package:valvn/features/store/ui/bundle_detail_screen.dart';
import 'package:valvn/features/store/ui/store_screen.dart';
import 'package:valvn/features/store/ui/widgets/store_segment_bar.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import 'store_test_harness.dart';

Future<void> _pumpStore(
  WidgetTester tester, {
  required MockPvpApi api,
  required Prefs prefs,
  MemoryJsonCache? cache,
  RecordingNotificationService? notifications,
  StoreSegment initialSegment = StoreSegment.daily,
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    testApp(
      overrides: storeOverrides(
        api: api,
        prefs: prefs,
        cache: cache,
        notifications: notifications,
      ),
      home: StoreScreen(initialSegment: initialSegment),
    ),
  );
  await settle(tester);
}

bool _nightMarketDot(WidgetTester tester) => tester
    .widget<StoreSegmentBar<StoreSegment>>(
      find.byType(StoreSegmentBar<StoreSegment>),
    )
    .tabs
    .any((t) => t.value == StoreSegment.nightMarket && t.showDot);

void main() {
  group('StoreSegment', () {
    test('parses query values and falls back to daily', () {
      expect(StoreSegment.parse('nightmarket'), StoreSegment.nightMarket);
      expect(StoreSegment.parse('NIGHTMARKET'), StoreSegment.nightMarket);
      expect(StoreSegment.parse('accessories'), StoreSegment.accessories);
      expect(StoreSegment.parse('bundles'), StoreSegment.bundles);
      expect(StoreSegment.parse(null), StoreSegment.daily);
      expect(StoreSegment.parse('???'), StoreSegment.daily);
      for (final s in StoreSegment.values) {
        expect(StoreSegment.parse(s.queryValue), s);
      }
    });

    test('Night Market falls back to daily only once the store has none', () {
      final withNm = Storefront.fromJson(
        economyFixture('storefront.json'),
        receivedAt: t0,
      );
      final withoutNm = Storefront.fromJson(const {}, receivedAt: t0);
      expect(
        effectiveStoreSegment(StoreSegment.nightMarket, null),
        StoreSegment.nightMarket,
      );
      expect(
        effectiveStoreSegment(StoreSegment.nightMarket, withNm),
        StoreSegment.nightMarket,
      );
      expect(
        effectiveStoreSegment(StoreSegment.nightMarket, withoutNm),
        StoreSegment.daily,
      );
      expect(
        effectiveStoreSegment(StoreSegment.bundles, withoutNm),
        StoreSegment.bundles,
      );
    });
  });

  testWidgets('daily segment: header, wallet, countdown, total and 4 cards', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pumpStore(tester, api: fixtureApi(), prefs: prefs);

    expect(find.text(StoreStrings.title), findsOneWidget);
    // Wallet pill (wallet.json: 1450 VP, 11200 KC, 60 RP).
    expect(find.text('1.450'), findsOneWidget);
    expect(find.text('11.200'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    // All four segments: BonusStore is present.
    for (final label in [
      StoreStrings.segmentDaily,
      StoreStrings.segmentNightMarket,
      StoreStrings.segmentAccessories,
      StoreStrings.segmentBundles,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(_nightMarketDot(tester), isTrue, reason: 'unseen Night Market');

    // 17401 s left → "Làm mới sau 04:50:01"; total 2175+1275+1775+1275.
    expect(find.text(StoreStrings.resetsIn('04:50:01')), findsOneWidget);
    expect(find.text('6.500'), findsOneWidget);
    for (final name in [
      'Ares Sentinels of Light',
      'Ares Prism',
      'Ghost Magepunk',
      'Operator Thần Rừng',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('2.175'), findsOneWidget);
    expect(find.byTooltip(StoreStrings.addToWishlist), findsNothing);
    expect(find.bySemanticsLabel(StoreStrings.addToWishlist), findsNWidgets(4));

    await unmount(tester);
  });

  testWidgets('wishlist heart on a daily card toggles the wishlist', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pumpStore(tester, api: fixtureApi(), prefs: prefs);

    await tester.tap(find.bySemanticsLabel(StoreStrings.addToWishlist).first);
    await settle(tester, 3);
    expect(
      find.bySemanticsLabel(StoreStrings.removeFromWishlist),
      findsOneWidget,
    );

    await unmount(tester);
  });

  testWidgets('Night Market: badges, prices, savings, note; marks it seen', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pumpStore(tester, api: fixtureApi(), prefs: prefs);

    await tester.tap(find.text(StoreStrings.segmentNightMarket));
    await settle(tester);

    expect(find.text('-22%'), findsOneWidget);
    expect(find.text('-41%'), findsOneWidget);
    expect(find.text('-38%'), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    // Base 1.775 struck through, discounted 1.385.
    expect(find.text('1.775'), findsOneWidget);
    expect(find.text('1.385'), findsOneWidget);
    // 12 d 20:06:46 left.
    expect(
      find.text(StoreStrings.nightMarketEndsIn('12 ngày 20:06:46')),
      findsOneWidget,
    );
    // 390 + 1456 + 485 saved.
    expect(
      find.text(StoreStrings.nightMarketTotalSavings(formatVp(2331))),
      findsOneWidget,
    );
    expect(find.text(StoreStrings.nightMarketNote), findsOneWidget);
    // All three are owned in the entitlements fixture.
    expect(find.text(StoreStrings.ownedBadge), findsNWidgets(3));

    // Opening the segment clears the red dot and persists the rotation.
    expect(_nightMarketDot(tester), isFalse);
    expect(
      prefs.getStringList(NightMarketSeenStore.key(Fx.puuid)),
      hasLength(3),
    );

    await unmount(tester);
  });

  testWidgets('a deep-linked Night Market segment opens directly', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pumpStore(
      tester,
      api: fixtureApi(),
      prefs: prefs,
      initialSegment: StoreSegment.nightMarket,
    );

    expect(find.text(StoreStrings.nightMarketNote), findsOneWidget);
    expect(
      prefs.getStringList(NightMarketSeenStore.key(Fx.puuid)),
      hasLength(3),
    );

    await unmount(tester);
  });

  testWidgets('a new tap on the same segment link switches back to it', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    final link = ValueNotifier<String?>(null);
    addTearDown(link.dispose);
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: ValueListenableBuilder<String?>(
          valueListenable: link,
          builder: (_, nonce, _) => StoreScreen(linkNonce: nonce),
        ),
      ),
    );
    await settle(tester);
    await tester.tap(find.text(StoreStrings.segmentBundles));
    await settle(tester);
    expect(find.text('Ares Prism'), findsNothing);

    // "Cửa hàng đã làm mới" tapped: /store again (daily), new nonce.
    link.value = '1';
    await settle(tester);
    expect(find.text('Ares Prism'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('without a BonusStore the Night Market segment is hidden', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    final json = Map<String, Object?>.from(economyFixture('storefront.json'))
      ..remove('BonusStore');
    await _pumpStore(
      tester,
      api: fixtureApi(storefront: json),
      prefs: prefs,
      initialSegment: StoreSegment.nightMarket,
    );

    expect(find.text(StoreStrings.segmentNightMarket), findsNothing);
    expect(find.text('Ares Prism'), findsOneWidget, reason: 'daily fallback');

    await unmount(tester);
  });

  testWidgets('accessories: names, type labels, "Từ: …" and KC prices', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pumpStore(tester, api: fixtureApi(), prefs: prefs);

    await tester.tap(find.text(StoreStrings.segmentAccessories));
    await settle(tester);

    // 535801 s = 6 d 04:50:01.
    expect(
      find.text(StoreStrings.accessoryRefreshIn('6 ngày 04:50:01')),
      findsOneWidget,
    );
    expect(
      find.text(StoreStrings.accessoryFrom('Mùa 2026 // Phần V')),
      findsNWidgets(2),
    );
    expect(find.text('Hình phun sơn'), findsOneWidget);
    expect(find.text('Thẻ người chơi'), findsOneWidget);
    expect(find.text('Danh hiệu'), findsOneWidget);
    expect(find.text('4.000'), findsNWidgets(2));
    expect(find.text('3.000'), findsOneWidget);
    expect(find.text('Phụ kiện súng'), findsOneWidget);
    expect(find.text('4.500'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('bundles: banners open the bundle detail through the router', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    usePhoneViewport(tester);
    final router = GoRouter(
      initialLocation: StoreRoutes.segment(StoreSegment.bundles),
      routes: storeBranchRoutes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        retry: (_, _) => null,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await settle(tester);

    expect(find.text('NEO FRONTIER'), findsOneWidget);
    expect(find.text('-57%'), findsOneWidget);
    expect(find.text('1.457'), findsOneWidget);
    // Bundle 2 is not in the content: generic name, still listed.
    expect(find.text(CommonStrings.unknownItem.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('NEO FRONTIER'));
    await settle(tester);
    expect(find.byType(BundleDetailScreen), findsOneWidget);
    expect(router.state.uri.path, StoreRoutes.bundle(Fx.bundleId));

    await unmount(tester);
  });

  testWidgets('an error without data shows "Thử lại", which refetches', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    final api = fixtureApi(
      storefrontError: const TransientException(status: 503),
    );
    await _pumpStore(tester, api: api, prefs: prefs);

    expect(find.text(CommonStrings.retry), findsOneWidget);
    expect(find.text('Ares Prism'), findsNothing);

    when(() => api.storefront(any()))
        .thenAnswer((_) async => economyFixture('storefront.json'));
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text('Ares Prism'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('an empty daily shop shows the empty state', (tester) async {
    final prefs = await createTestPrefs();
    await _pumpStore(
      tester,
      api: fixtureApi(
        storefront: {
          'SkinsPanelLayout': {
            'SingleItemOffers': <String>[],
            'SingleItemOffersRemainingDurationInSeconds': 100,
          },
        },
      ),
      prefs: prefs,
    );

    expect(find.text(StoreStrings.dailyEmpty), findsOneWidget);
    expect(find.text(StoreStrings.segmentNightMarket), findsNothing);

    await tester.tap(find.text(StoreStrings.segmentBundles));
    await settle(tester);
    expect(find.text(StoreStrings.bundlesEmpty), findsOneWidget);

    await tester.tap(find.text(StoreStrings.segmentAccessories));
    await settle(tester);
    expect(find.text(StoreStrings.accessoryEmpty), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('offline: serves the saved copy with a notice', (tester) async {
    final prefs = await createTestPrefs();
    final cache = MemoryJsonCache();
    final savedAt = t0.subtract(const Duration(hours: 1));
    await cache.write(
      JsonFileCache.accountKey(Fx.puuid, 'economy_storefront'),
      economyFixture('storefront.json'),
      savedAt: savedAt,
    );
    await _pumpStore(
      tester,
      api: fixtureApi(storefrontError: const TransientException()),
      prefs: prefs,
      cache: cache,
    );

    expect(
      find.text(CommonStrings.offlineCached(formatTime(savedAt))),
      findsOneWidget,
    );
    expect(find.text('Ares Prism'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('an offer missing from the content is reported once', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    final misses = MissCounter();
    final json = jsonDecode(
      economyFixtureText('storefront.json')
          .replaceAll(Fx.aresPrismL1, Fx.unknownLevel),
    ) as Map<String, dynamic>;
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(
        overrides: storeOverrides(
          api: fixtureApi(storefront: json),
          prefs: prefs,
          misses: misses,
        ),
        home: const StoreScreen(),
      ),
    );
    await settle(tester);

    expect(find.text(CommonStrings.unknownItem), findsOneWidget);
    expect(misses.count, 1);
    await tester.tap(find.text(StoreStrings.segmentBundles));
    await settle(tester);
    expect(misses.count, 1, reason: 'same storefront, no second report');

    await unmount(tester);
  });

  testWidgets('no account: empty state', (tester) async {
    final prefs = await createTestPrefs();
    await tester.pumpWidget(
      testApp(
        overrides: storeOverrides(
          api: fixtureApi(),
          prefs: prefs,
          account: null,
        ),
        home: const StoreScreen(),
      ),
    );
    await tester.pump();

    expect(find.text(CommonStrings.errorNoAccount), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the screen itself does not schedule the reset reminder', (
    tester,
  ) async {
    // Scheduling moved to the always-mounted StoreResetReminderHost (see
    // store_reset_reminder_host_test.dart), so it works without this tab.
    final prefs = await createTestPrefs();
    await prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(storeResetNotifications: true).toJson(),
    );
    final notifications = RecordingNotificationService();
    await _pumpStore(
      tester,
      api: fixtureApi(),
      prefs: prefs,
      notifications: notifications,
    );

    expect(notifications.calls, isEmpty);
    await unmount(tester);
  });

  testWidgets('no overflow on a 320 dp phone with 130 % text', (tester) async {
    final prefs = await createTestPrefs();
    usePhoneViewport(tester, size: const Size(320, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      testApp(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const StoreScreen(),
      ),
    );
    await settle(tester);
    for (final segment in [
      StoreStrings.segmentNightMarket,
      StoreStrings.segmentAccessories,
      StoreStrings.segmentBundles,
    ]) {
      await tester.tap(find.text(segment));
      await settle(tester);
    }
    expect(tester.takeException(), isNull);

    await unmount(tester);
  });
}
