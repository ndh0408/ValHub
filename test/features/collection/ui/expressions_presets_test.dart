import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/expressions_screen.dart';
import 'package:valvn/features/collection/ui/loadout_presets_screen.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../core/domain/loadout/loadout_fixtures.dart';
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

  group('S37 expressions', () {
    testWidgets('wheel slots and the Flex / spray picker', (tester) async {
      await pumpCollection(
        tester,
        const ExpressionsScreen(),
        riot: riot,
        prefs: prefs,
      );
      for (var i = 0; i < 4; i++) {
        expect(find.text(CollectionStrings.slotTitle(i)), findsOneWidget);
      }
      expect(find.text('Flex ORA by OneTap'), findsOneWidget);
      expect(find.text(CollectionStrings.emptySlot), findsOneWidget);

      // Slot 0 holds a Flex → the picker opens on the Flex tab.
      await tester.tap(find.text(CollectionStrings.slotTitle(0)));
      await settle(tester);
      expect(find.text('Flex STAT-COM'), findsOneWidget);
      await tester.tap(find.text('Flex STAT-COM'));
      await settle(tester);
      expect(asMapList(riot.lastPut['ActiveExpressions'])[0], {
        'TypeID': ItemTypeIds.flex,
        'AssetID': 'af52b5a0-4a4c-03b2-c9d7-8187a08a2675',
      });

      // Slot 1 (spray) → spray tab, switch to the owned default spray.
      await tester.tap(find.text(CollectionStrings.slotTitle(1)));
      await settle(tester);
      expect(find.text(CollectionStrings.tabSprays), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(ExpressionPickerSheet),
          matching: find.text('Hình Phun Sơn VALORANT'),
        ),
      );
      await settle(tester);
      final list = asMapList(riot.lastPut['ActiveExpressions']);
      expect(list, hasLength(4));
      expect(list[1], {
        'TypeID': ItemTypeIds.spray,
        'AssetID': '0a6db78c-48b9-a32d-c47a-82be597584c1',
      });
      expect(list[3]['AssetID'], Lx.sprayB, reason: 'other slots kept');
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  });

  group('S38 presets', () {
    testWidgets('save, apply (one PUT), rename, delete + undo', (tester) async {
      await pumpCollection(
        tester,
        const LoadoutPresetsScreen(),
        riot: riot,
        prefs: prefs,
      );
      expect(find.text(CollectionStrings.presetsEmpty), findsOneWidget);

      await tester.tap(find.text(CollectionStrings.savePreset));
      await settle(tester);
      expect(find.text(CollectionStrings.presetNameTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Leo rank ');
      await tester.tap(find.text('Lưu'));
      await settle(tester);
      expect(find.text('Leo rank'), findsOneWidget);
      expect(find.text('Đã lưu “Leo rank”'), findsOneWidget);
      expect(find.text('Lưu ngày 29/09/2026'), findsOneWidget);

      // The game changed the loadout since.
      riot.server = LoadoutChange.all([
        const EquipSkin(
          weaponId: Lx.vandal,
          skinId: Fx.reaverVandal,
          skinLevelId: Fx.reaverL1,
          chromaId: Fx.reaverBaseChroma,
        ),
        const SetPlayerCard(Lx.cardDefault),
      ]).appliedTo(loadoutJson(version: 40));

      // A quiet outlined "Áp dụng" on the card; the red fill stays for
      // "Lưu trang bị hiện tại".
      expect(
        find.widgetWithText(OutlinedButton, tl.collectionApplyPreset),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, tl.collectionApplyPreset),
        findsNothing,
      );
      await tester.tap(find.text(CollectionStrings.applyPreset));
      await settle(tester);
      expect(
        find.text(CollectionStrings.applyPresetTitle('Leo rank')),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(CollectionStrings.applyPreset),
        ),
      );
      await settle(tester);
      expect(riot.puts, hasLength(1));
      final vandal = asMapList(riot.lastPut['Guns'])
          .firstWhere((g) => lowerUuid(g['ID']) == Lx.vandal);
      expect(vandal['SkinID'], Fx.vandalStandard);
      expect(asMap(riot.lastPut['Identity'])!['PlayerCardID'], Fx.cardNgoiSang);
      expect(find.textContaining('Đã áp dụng “Leo rank”'), findsOneWidget);
      // The Cypher spray is not owned: left out of the PUT.
      expect(find.textContaining('Bỏ qua 1 vật phẩm'), findsOneWidget);

      // Rename.
      await tester.tap(find.byTooltip(CollectionStrings.presetActions));
      await settle(tester);
      await tester.tap(find.text(CollectionStrings.renamePreset));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Đấu thường');
      await tester.tap(find.text('Lưu'));
      await settle(tester);
      expect(find.text('Đấu thường'), findsOneWidget);

      // Delete, then undo.
      await tester.tap(find.byTooltip(CollectionStrings.presetActions));
      await settle(tester);
      await tester.tap(find.text(CollectionStrings.deletePreset));
      await settle(tester);
      expect(find.text(CollectionStrings.presetsEmpty), findsOneWidget);
      expect(find.text(CollectionStrings.undo), findsOneWidget);
      tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
      await settle(tester);
      expect(find.text('Đấu thường'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  });
}
