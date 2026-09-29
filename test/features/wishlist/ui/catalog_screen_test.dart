import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/skeleton.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';
import 'package:valvn/features/wishlist/ui/catalog_screen.dart';
import 'package:valvn/features/wishlist/ui/widgets/catalog_tile.dart';
import 'package:valvn/features/wishlist/wishlist_strings.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../helpers/test_prefs.dart';
import '../wishlist_test_harness.dart';

Future<void> _pump(
  WidgetTester tester, {
  required Prefs prefs,
  Future<ContentDb> Function()? loadContent,
  bool signedIn = true,
  ThemeData? theme,
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    testApp(
      theme: theme,
      overrides: wishlistOverrides(
        api: fixtureApi(),
        prefs: prefs,
        loadContent: loadContent,
        account: signedIn ? testAccount : null,
      ),
      home: const CatalogScreen(),
    ),
  );
  await settle(tester);
}

Finder get _grid => find
    .descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    )
    .first;

void main() {
  testWidgets('lists every collectible skin with a lazy grid', (tester) async {
    await _pump(tester, prefs: await createTestPrefs());
    expect(find.text(WishlistStrings.catalogTitle), findsOneWidget);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);
    expect(find.byType(SliverGrid), findsOneWidget);
    // Rarity sort: an Exclusive skin first; Standard skins never listed.
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    expect(find.text('Vandal Thông Thường'), findsNothing);
    // Lazy: far tiles are not built yet.
    expect(find.text('Ghost Thinh Lặng'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Ghost Thinh Lặng'),
      300,
      scrollable: _grid,
    );
    expect(find.text('Ghost Thinh Lặng'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('accent-insensitive search and no-match state', (tester) async {
    await _pump(tester, prefs: await createTestPrefs());
    await tester.enterText(find.byType(TextField), 'vo cuc');
    await settle(tester);
    expect(find.text('Bulldog Vô Cực'), findsOneWidget);
    expect(find.text(WishlistStrings.catalogCount('1')), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'khong co skin nay');
    await settle(tester);
    expect(find.text(WishlistStrings.noMatch), findsOneWidget);
    await tester.tap(find.text(WishlistStrings.clearFilters));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('heart adds to and removes from the wishlist', (tester) async {
    final prefs = await createTestPrefs();
    await _pump(tester, prefs: prefs);
    final repo = WishlistRepository(prefs);
    await tester.enterText(find.byType(TextField), 'reaver vandal');
    await settle(tester);
    expect(find.text('Vandal Reaver'), findsOneWidget);

    await tester.tap(find.byTooltip(WishlistStrings.addToWishlist));
    await settle(tester);
    expect(repo.read(Fx.puuid), {Fx.reaverVandal});
    expect(find.byTooltip(WishlistStrings.removeFromWishlist), findsOneWidget);
    expect(find.text(WishlistStrings.catalogInWishlist('1')), findsOneWidget);

    await tester.tap(find.byTooltip(WishlistStrings.removeFromWishlist));
    await settle(tester);
    expect(repo.read(Fx.puuid), isEmpty);
    await unmount(tester);
  });

  testWidgets('weapon picker and edition filter', (tester) async {
    await _pump(tester, prefs: await createTestPrefs());
    await tester.ensureVisible(find.text(WishlistStrings.allWeapons));
    await settle(tester);
    await tester.tap(find.text(WishlistStrings.allWeapons));
    await settle(tester);
    expect(find.text(WishlistStrings.chooseWeapon), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Vandal'));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('2')), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text('Vandal Cafe Xanh Mát'), findsOneWidget);

    // "Vandal" chip now shows the pick; back to every weapon.
    await tester.tap(find.text('Vandal').first);
    await settle(tester);
    await tester.tap(find.widgetWithText(ListTile, WishlistStrings.allWeapons));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);

    await tester.ensureVisible(find.text('Tuyển Chọn'));
    await settle(tester);
    await tester.tap(find.text('Tuyển Chọn'));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('2')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tapping a tile opens the skin sheet', (tester) async {
    await _pump(tester, prefs: await createTestPrefs());
    await tester.tap(find.text('Ares Sentinels of Light'));
    await settle(tester);
    expect(find.byType(SkinDetailSheet), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no account: browse only, no hearts', (tester) async {
    await _pump(tester, prefs: await createTestPrefs(), signedIn: false);
    expect(find.text('Ares Sentinels of Light'), findsOneWidget);
    expect(find.byTooltip(WishlistStrings.addToWishlist), findsNothing);
    await unmount(tester);
  });

  testWidgets('content error → "Thử lại"', (tester) async {
    var calls = 0;
    await _pump(
      tester,
      prefs: await createTestPrefs(),
      loadContent: () async {
        calls++;
        if (calls == 1) throw const TransientException();
        return economyContent();
      },
    );
    expect(find.text(CommonStrings.retry), findsOneWidget);
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('loading skeleton while the content loads', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      testApp(
        overrides: wishlistOverrides(
          api: fixtureApi(),
          prefs: await createTestPrefs(),
          loadContent: () =>
              Future.delayed(const Duration(seconds: 5), economyContent),
        ),
        home: const CatalogScreen(),
      ),
    );
    await tester.pump();
    expect(find.byType(SkeletonGrid), findsOneWidget);
    expect(find.byType(CatalogSkinTile), findsNothing);
    expect(find.text(WishlistStrings.catalogCount('12')), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('sort, weapon and edition filters are remembered', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pump(tester, prefs: prefs);
    // Sort by name.
    await tester.tap(find.text(WishlistStrings.sortRarity));
    await settle(tester, 30);
    await tester.tap(find.text(WishlistStrings.sortName).last);
    await settle(tester, 30);
    // Weapon: Vandal.
    await tester.tap(find.text(WishlistStrings.allWeapons));
    await settle(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Vandal'));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('2')), findsOneWidget);
    // Search text is not remembered.
    await tester.enterText(find.byType(TextField), 'reaver');
    await settle(tester);
    await unmount(tester);

    await _pump(tester, prefs: prefs);
    expect(find.text(WishlistStrings.sortName), findsOneWidget);
    expect(find.text('Vandal'), findsWidgets);
    expect(find.text(WishlistStrings.catalogCount('2')), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );

    // "Bỏ lọc" clears the filters (and the remembered ones).
    // At the end of the chip row: scroll it into view first.
    await tester.ensureVisible(find.text(CommonStrings.clearFilters));
    await settle(tester);
    await tester.tap(find.text(CommonStrings.clearFilters));
    await settle(tester);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);
    await unmount(tester);
    await _pump(tester, prefs: prefs);
    expect(find.text(WishlistStrings.catalogCount('12')), findsOneWidget);
    expect(find.text(WishlistStrings.sortName), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('light theme at 200 % text on 360 dp: no overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      prefs: await createTestPrefs(),
      theme: buildLightTheme(),
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Ghost Thinh Lặng'),
      300,
      scrollable: _grid,
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('large text on a small phone does not overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, prefs: await createTestPrefs());
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Ghost Thinh Lặng'),
      300,
      scrollable: _grid,
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
