import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/collection/collection_routes.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/browse_collection_screen.dart';
import 'package:valvn/features/collection/ui/skin_customize_screen.dart';

import '../../../helpers/l10n.dart';
import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

void main() {
  late Prefs prefs;
  late FakeRiot riot;

  setUp(() async {
    prefs = await createTestPrefs();
    riot = FakeRiot();
  });

  test('browse type paths', () {
    expect(CollectionBrowseType.parse('spray'), CollectionBrowseType.spray);
    expect(CollectionBrowseType.parse('???'), CollectionBrowseType.skin);
    expect(
      CollectionRoutes.browse(CollectionBrowseType.flex),
      '/collection/browse/flex',
    );
  });

  testWidgets('skins: summary strip, filtered summary, prices / sources', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
    );
    expect(find.textContaining('5 skin · '), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cafe');
    await settle(tester);
    expect(find.textContaining('Đang lọc: 1 skin · '), findsOneWidget);
    expect(find.text('Vandal Cafe Xanh Mát'), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await settle(tester);
    // Tier chip: Premium only.
    final premium = find.widgetWithText(FilterChip, 'Cao Cấp');
    await tester.ensureVisible(premium);
    await settle(tester);
    await tester.tap(premium);
    await settle(tester);
    expect(find.textContaining('Đang lọc: 1 skin · '), findsOneWidget);
    await tester.ensureVisible(find.text(CollectionStrings.clearFilters));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.clearFilters));
    await settle(tester);
    expect(find.textContaining('5 skin · '), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('an owned skin sheet leads to its customize page', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text('Vandal Reaver'));
    await settle(tester);
    final equip = find.widgetWithText(FilledButton, tl.collectionEquip);
    expect(equip, findsOneWidget);
    await tester.tap(equip);
    await settle(tester);
    // The sheet closed; "Trang bị" on the customize page saves.
    expect(find.byType(SkinCustomizeScreen), findsOneWidget);
    expect(find.text(tl.collectionVariants), findsOneWidget);
    expect(riot.puts, isEmpty);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('other types: titles, sprays, buddies, cards, flex', (
    tester,
  ) async {
    Future<void> open(CollectionBrowseType type) => pumpCollection(
      tester,
      BrowseCollectionScreen(type: type),
      riot: riot,
      prefs: prefs,
    );

    await open(CollectionBrowseType.title);
    expect(find.text('Tài Lộc'), findsOneWidget);
    expect(find.text('1 vật phẩm'), findsOneWidget);

    await open(CollectionBrowseType.spray);
    expect(find.text('Hình Phun Sơn Tình Nguyện'), findsOneWidget);
    expect(find.text('2 vật phẩm'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tinh nguyen');
    await settle(tester);
    expect(find.text('Đang lọc: 1/2 vật phẩm'), findsOneWidget);

    await open(CollectionBrowseType.buddy);
    expect(find.text('Phụ Kiện Neo Frontier'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);

    await open(CollectionBrowseType.flex);
    expect(find.text('Flex ORA by OneTap'), findsOneWidget);

    await open(CollectionBrowseType.card);
    expect(find.text('Thẻ VALORANT'), findsOneWidget);
    await tester.tap(find.text('Thẻ VALORANT'));
    await settle(tester);
    expect(find.text(CollectionStrings.equip), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('a spray opens a preview sheet with a close button', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.spray),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text('Hình Phun Sơn Tình Nguyện'));
    await settle(tester);
    // Sheet header: name (also in the grid) + type, and the round close.
    expect(find.text('Hình Phun Sơn Tình Nguyện'), findsNWidgets(2));
    expect(find.byTooltip(CommonStrings.close), findsOneWidget);
    await tester.tap(find.byTooltip(CommonStrings.close));
    await settle(tester);
    expect(find.byTooltip(CommonStrings.close), findsNothing);
    await unmount(tester);
  });

  testWidgets('each type shows its subtitle under the large title', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.title),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text(CollectionStrings.browseTitles), findsOneWidget);
    expect(
      find.text(CollectionStrings.browseSubtitle('title')),
      findsOneWidget,
    );
    await unmount(tester);
  });

  testWidgets('empty collection and entitlement errors', (tester) async {
    riot.entitlementsError = const _Boom();
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.flex),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text('Thử lại'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('large text on a small phone does not overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(ItemTypeIds.spray, isNotEmpty);
    await unmount(tester);
  });
}

class _Boom implements Exception {
  const _Boom();
}
