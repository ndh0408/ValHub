import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/collection/collection_routes.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/browse_collection_screen.dart';

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
    await tester.tap(
      find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Cao Cấp'),
    );
    await settle(tester);
    expect(find.textContaining('Đang lọc: 1 skin · '), findsOneWidget);
    await tester.tap(find.byTooltip(CollectionStrings.clearFilters));
    await settle(tester);
    expect(find.textContaining('5 skin · '), findsOneWidget);
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
