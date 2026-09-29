import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';
import 'package:valvn/features/store/store_strings.dart';
import 'package:valvn/features/store/ui/bundle_detail_screen.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import 'store_test_harness.dart';

Future<void> _pump(
  WidgetTester tester, {
  required MockPvpApi api,
  String bundleId = Fx.bundleId,
}) async {
  usePhoneViewport(tester);
  final prefs = await createTestPrefs();
  await tester.pumpWidget(
    testApp(
      overrides: storeOverrides(api: api, prefs: prefs),
      home: BundleDetailScreen(bundleId: bundleId),
    ),
  );
  await settle(tester);
}

void main() {
  testWidgets('shows name, countdown, price summary and items', (tester) async {
    await _pump(tester, api: fixtureApi());

    expect(find.text('Neo Frontier'), findsWidgets, reason: 'app bar');
    expect(find.text('NEO FRONTIER'), findsOneWidget);
    // 1821001 s = 21 d 01:50:01.
    expect(
      find.text(StoreStrings.bundleEndsIn('21 ngày 01:50:01')),
      findsOneWidget,
    );
    // Giá bundle 1.457 · Mua lẻ 3.350 · Tiết kiệm 1.893.
    expect(find.text(StoreStrings.bundlePriceLabel), findsOneWidget);
    expect(find.text(StoreStrings.bundleBuySeparateLabel), findsOneWidget);
    expect(find.text(StoreStrings.bundleSavingsLabel), findsOneWidget);
    expect(find.text('3.350'), findsOneWidget);
    expect(find.text('1.893'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(StoreStrings.bundleItemsTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(StoreStrings.bundleItemCount(4)), findsOneWidget);
    expect(find.text('Odin Neo Frontier'), findsOneWidget);
    // Buddy ×2, card and spray are free; the Odin is discounted to 1.457.
    await tester.scrollUntilVisible(
      find.text(StoreStrings.bundleItemFree).last,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(StoreStrings.bundleItemFree), findsNWidgets(3));
    expect(find.textContaining(StoreStrings.quantity(2)), findsOneWidget);
    expect(find.text('-33%'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('tapping a skin item opens the skin sheet', (tester) async {
    await _pump(tester, api: fixtureApi());

    await tester.scrollUntilVisible(
      find.text('Odin Neo Frontier'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Odin Neo Frontier'));
    await settle(tester);
    expect(find.byType(SkinDetailSheet), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('wholesale-only bundle shows the note; unknown art still works', (
    tester,
  ) async {
    await _pump(tester, api: fixtureApi(), bundleId: Fx.bundle2Id);

    expect(find.text(StoreStrings.bundleWholesaleOnly), findsOneWidget);
    expect(find.text(StoreStrings.bundleDetailTitle), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('an id that is not in the storefront shows the empty state', (
    tester,
  ) async {
    await _pump(tester, api: fixtureApi(), bundleId: 'not-a-bundle');

    expect(find.text(StoreStrings.bundleNotFound), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('an error shows "Thử lại", which refetches', (tester) async {
    final api = fixtureApi(storefrontError: const TransientException());
    await _pump(tester, api: api);

    expect(find.text(CommonStrings.retry), findsOneWidget);
    when(() => api.storefront(any()))
        .thenAnswer((_) async => economyFixture('storefront.json'));
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text('NEO FRONTIER'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('no overflow on a 320 dp phone with 130 % text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    usePhoneViewport(tester, size: const Size(320, 640));
    final prefs = await createTestPrefs();
    await tester.pumpWidget(
      testApp(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const BundleDetailScreen(bundleId: Fx.bundleId),
      ),
    );
    await settle(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await settle(tester);
    expect(tester.takeException(), isNull);

    await unmount(tester);
  });
}
