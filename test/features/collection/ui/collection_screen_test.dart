import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/collection_screen.dart';

import '../../../core/domain/loadout/loadout_fixtures.dart';
import '../../../helpers/l10n.dart';
import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pump();
}

void main() {
  late Prefs prefs;
  late FakeRiot riot;

  setUp(() async {
    prefs = await createTestPrefs();
    riot = FakeRiot();
  });

  testWidgets('hub: card header, loadout rows, browse rows, value footer', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
    );

    expect(find.text('Bộ sưu tập'), findsOneWidget);
    // The card's name once: the "Đổi thẻ người chơi" row value (no caption
    // under the banner).
    expect(find.text('Thẻ Bộ Đôi Ngời Sáng'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(CollectionStrings.equippedCard)),
      findsOneWidget,
    );
    expect(find.text(CollectionStrings.playerTitleTitle), findsOneWidget);
    expect(find.text('Tài Lộc'), findsOneWidget);
    expect(find.text(CollectionStrings.rowWeapons), findsOneWidget);
    expect(find.text(CollectionStrings.rowExpressions), findsOneWidget);
    expect(find.text(CollectionStrings.rowPresets), findsOneWidget);
    expect(find.text('Chưa có'), findsOneWidget);

    await scrollTo(tester, find.text(CollectionStrings.rowWishlist));
    expect(find.text(CollectionStrings.sectionBrowse), findsOneWidget);
    expect(find.text('Phụ kiện súng'), findsOneWidget);
    // Browse has no player-card row: the loadout row opens the same grid.
    expect(find.text(tl.collectionBrowseCards), findsNothing);
    expect(find.text('Trống'), findsOneWidget); // empty wishlist

    final valueLabel = tl.collectionCollectionValue.toUpperCase();
    await scrollTo(tester, find.text(valueLabel));
    expect(find.text(valueLabel), findsOneWidget);
    // One line of fine print: store prices + the two reward skins left out
    // (no owned-skin count, no "includes estimates" next to the "≈").
    expect(
      find.text(
        tf.inlineFacts([
          tl.collectionValueAtStorePrices,
          tl.collectionValueRewardCount(2),
        ]),
      ),
      findsOneWidget,
    );
    expect(find.text(CollectionStrings.excludedRewards), findsNothing);
    expect(find.textContaining(tl.collectionValueHasEstimates), findsNothing);
    expect(find.textContaining('VP'), findsWidgets);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('no skins: no "0 VP" value card', (tester) async {
    when(() => riot.api.entitlements(any(), any())).thenAnswer((inv) async {
      final type = inv.positionalArguments[1] as String;
      if (type == ItemTypeIds.skinLevel) {
        return {'ItemTypeID': type, 'Entitlements': <Object?>[]};
      }
      return entitlementsFor(type) ?? (throw const NotFoundException());
    });
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
    );
    final incognito = find.widgetWithText(
      SwitchListTile,
      CollectionStrings.incognito,
    );
    await scrollTo(tester, incognito);
    expect(
      find.text(tl.collectionCollectionValue.toUpperCase()),
      findsNothing,
    );
    expect(find.text(tl.collectionValueAtStorePrices), findsNothing);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('incognito switch saves through a fresh GET + PUT', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
    );
    final tile = find.widgetWithText(
      SwitchListTile,
      CollectionStrings.incognito,
    );
    await scrollTo(tester, tile);
    await tester.tap(tile);
    await settle(tester);

    expect(riot.puts, hasLength(1));
    expect(riot.lastPut['Incognito'], isTrue);
    expect(
      riot.lastPut['AgentMasteryCosmetics'],
      isNotNull,
      reason: 'unknown keys round-trip',
    );
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
    await unmount(tester);
  });

  testWidgets('failed save rolls back and says "Không thể lưu trang bị"', (
    tester,
  ) async {
    riot.putError = const RiotApiException(400);
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
    );
    final tile = find.widgetWithText(
      SwitchListTile,
      CollectionStrings.hideAccountLevel,
    );
    await scrollTo(tester, tile);
    await tester.tap(tile);
    await settle(tester);

    expect(find.textContaining('Không thể lưu trang bị'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    expect(asMap(riot.server['Identity'])!['HideAccountLevel'], isFalse);
    await unmount(tester);
  });

  testWidgets('loadout / entitlement errors show "Thử lại"', (tester) async {
    riot.loadoutError = const TransientException(status: 503);
    riot.entitlementsError = const MaintenanceException();
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text('Thử lại'), findsWidgets);

    riot.loadoutError = null;
    await tester.tap(find.text('Thử lại').first);
    await settle(tester);
    expect(find.text('Thẻ Bộ Đôi Ngời Sáng'), findsWidgets);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('hub opens the weapon loadout', (tester) async {
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text(CollectionStrings.rowWeapons));
    await settle(tester);
    expect(find.text('SÚNG TRƯỜNG'), findsOneWidget);
    await unmount(tester);
  });
}
