import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';
import 'package:valvn/features/wishlist/ui/catalog_screen.dart';
import 'package:valvn/features/wishlist/ui/wishlist_screen.dart';
import 'package:valvn/features/wishlist/wishlist_routes.dart';
import 'package:valvn/features/wishlist/wishlist_strings.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../helpers/test_prefs.dart';
import '../wishlist_test_harness.dart';

const _all = [
  Fx.aresSentinels,
  Fx.reaverVandal,
  Fx.knifeCafe,
  Fx.ghostThinhLang,
];

Future<Prefs> _prefs([List<String> wishlist = _all]) =>
    createTestPrefs({WishlistRepository.key(Fx.puuid): wishlist});

Future<void> _pump(
  WidgetTester tester, {
  required Prefs prefs,
  MockPvpApi? api,
  FakeNotificationService? notifications,
  Future<ContentDb> Function()? loadContent,
  MissCounter? misses,
  String? initialSkin,
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    testApp(
      overrides: wishlistOverrides(
        api: api ?? fixtureApi(),
        prefs: prefs,
        notifications: notifications,
        loadContent: loadContent,
        misses: misses,
      ),
      home: WishlistScreen(initialSkinUuid: initialSkin),
    ),
  );
  await settle(tester);
}

Finder get _mainScrollable => find
    .descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    )
    .first;

void main() {
  testWidgets('empty wishlist: hint, account subtitle, link to the catalog', (
    tester,
  ) async {
    await _pump(tester, prefs: await _prefs(const []));
    expect(find.text(WishlistStrings.title), findsOneWidget);
    expect(
      find.text(WishlistStrings.ofAccount('Người Chơi#VN2')),
      findsOneWidget,
    );
    expect(find.text(WishlistStrings.empty), findsOneWidget);
    expect(find.text(WishlistStrings.browseCatalog), findsOneWidget);
    expect(find.text(WishlistStrings.notifToggle), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('rows, availability highlight, banner and total value', (
    tester,
  ) async {
    await _pump(tester, prefs: await _prefs());
    expect(find.text(WishlistStrings.onSaleBanner(2)), findsOneWidget);
    expect(find.text(WishlistStrings.totalValue), findsOneWidget);
    expect(find.text(WishlistStrings.skinCount('4')), findsOneWidget);

    // On-sale skins come first.
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    expect(
      find.text(EconomyStrings.availableNow(EconomyStrings.placeDaily)),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text(EconomyStrings.availableNow(EconomyStrings.placeNightMarket)),
      200,
      scrollable: _mainScrollable,
    );
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.textContaining('Kết thúc sau'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Ghost Thinh Lặng'),
      200,
      scrollable: _mainScrollable,
    );
    expect(find.text('Dao Đầu Bếp Cafe Xanh Mát'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('search, no-match state and "Xóa bộ lọc"', (tester) async {
    await _pump(tester, prefs: await _prefs());
    await tester.enterText(find.byType(TextField), 'dau bep');
    await settle(tester);
    expect(find.text('Dao Đầu Bếp Cafe Xanh Mát'), findsOneWidget);
    expect(find.text('Ares Sentinels of Light'), findsNothing);
    expect(find.textContaining('Đang lọc: 1 skin'), findsOneWidget);
    expect(find.text(WishlistStrings.onSaleBanner(2)), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await settle(tester);
    expect(find.text(WishlistStrings.noMatch), findsOneWidget);
    await tester.tap(find.text(WishlistStrings.clearFilters));
    await settle(tester);
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    await unmount(tester);
  });

  testWidgets('edition filter and sort menu', (tester) async {
    await _pump(tester, prefs: await _prefs());
    await tester.tap(
      find.text(WishlistStrings.sortLabel(WishlistStrings.sortRarity)),
    );
    await settle(tester);
    await tester.tap(find.text(WishlistStrings.sortName).last);
    await settle(tester);
    expect(
      find.text(WishlistStrings.sortLabel(WishlistStrings.sortName)),
      findsOneWidget,
    );

    // Select edition ("Tuyển Chọn") → only Ghost Thinh Lặng.
    await tester.ensureVisible(find.text('Tuyển Chọn'));
    await settle(tester);
    await tester.tap(find.text('Tuyển Chọn'));
    await settle(tester);
    expect(find.text('Ghost Thinh Lặng'), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsNothing);
    expect(find.textContaining('Đang lọc: 1 skin'), findsOneWidget);
    await tester.tap(find.text('Tuyển Chọn'));
    await settle(tester);
    expect(find.textContaining('Đang lọc'), findsNothing);
    await unmount(tester);
  });

  testWidgets('swipe removes with undo', (tester) async {
    final prefs = await _prefs();
    await _pump(tester, prefs: prefs);
    await tester.drag(
      find.text('Ares Sentinels of Light'),
      const Offset(-600, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    final repo = WishlistRepository(prefs);
    expect(repo.read(Fx.puuid), isNot(contains(Fx.aresSentinels)));
    expect(find.text('Ares Sentinels of Light'), findsNothing);
    expect(
      find.text(WishlistStrings.removed('Ares Sentinels of Light')),
      findsOneWidget,
    );

    await tester.tap(find.text(WishlistStrings.undo));
    await settle(tester);
    expect(repo.read(Fx.puuid), contains(Fx.aresSentinels));
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('storefront needs login: rows stay, compact re-login row', (
    tester,
  ) async {
    await _pump(
      tester,
      prefs: await _prefs(),
      api: fixtureApi(
        storefrontError: const NeedsLoginException(puuid: Fx.puuid),
      ),
    );
    expect(find.text(CommonStrings.signInAgain), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ares Sentinels of Light'),
      200,
      scrollable: _mainScrollable,
    );
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    expect(find.text(WishlistStrings.onSaleBanner(2)), findsNothing);
    await unmount(tester);
  });

  testWidgets('content error → "Thử lại" reloads', (tester) async {
    var calls = 0;
    await _pump(
      tester,
      prefs: await _prefs(),
      loadContent: () async {
        calls++;
        if (calls == 1) throw const TransientException();
        return economyContent();
      },
    );
    expect(find.text(CommonStrings.retry), findsOneWidget);
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('unknown skins are listed and reported once', (tester) async {
    final misses = MissCounter();
    await _pump(
      tester,
      prefs: await _prefs(const [Fx.unknownLevel, Fx.knifeCafe]),
      misses: misses,
    );
    expect(find.text(CommonStrings.unknownItem), findsOneWidget);
    expect(misses.count, 1);
    await tester.pump();
    expect(misses.count, 1);
    await unmount(tester);
  });

  testWidgets('notification switch primes and persists the setting', (
    tester,
  ) async {
    final prefs = await _prefs();
    await _pump(tester, prefs: prefs);
    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(readAppSettings(prefs).wishlistNotifications, isTrue);
    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(readAppSettings(prefs).wishlistNotifications, isFalse);
    await unmount(tester);
  });

  testWidgets('notification switch without permission stays off', (
    tester,
  ) async {
    final prefs = await _prefs();
    final notifications = FakeNotificationService(enabled: false);
    await _pump(tester, prefs: prefs, notifications: notifications);
    await tester.tap(find.byType(Switch));
    await settle(tester);
    await tester.tap(find.text('Bật thông báo').last);
    await settle(tester);
    expect(notifications.permissionRequests, 1);
    expect(readAppSettings(prefs).wishlistNotifications, isFalse);
    expect(find.text(WishlistStrings.notifPermissionMissing), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('long names and large text do not overflow on 360 dp', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, prefs: await _prefs());
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Ghost Thinh Lặng'),
      200,
      scrollable: _mainScrollable,
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  group('with the router', () {
    Future<void> pumpRouter(
      WidgetTester tester,
      String location,
      Prefs prefs,
    ) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        routerTestApp(
          overrides: wishlistOverrides(api: fixtureApi(), prefs: prefs),
          initialLocation: location,
        ),
      );
      await settle(tester);
    }

    testWidgets('"+" opens the catalog', (tester) async {
      await pumpRouter(tester, WishlistRoutes.wishlist, await _prefs());
      await tester.tap(find.byTooltip(WishlistStrings.addSkins));
      await settle(tester);
      expect(find.byType(CatalogScreen), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('availability bar opens the store place', (tester) async {
      await _prefs();
      await pumpRouter(tester, WishlistRoutes.wishlist, await _prefs());
      await tester.tap(
        find.text(EconomyStrings.availableNow(EconomyStrings.placeDaily)),
      );
      await settle(tester);
      expect(find.text('STORE /store?segment=daily'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('?skin= deep link opens the skin sheet', (tester) async {
      await pumpRouter(
        tester,
        WishlistRoutes.skin(Fx.aresSentinels),
        await _prefs(),
      );
      await settle(tester);
      expect(find.byType(SkinDetailSheet), findsOneWidget);
      await unmount(tester);
    });
  });
}
