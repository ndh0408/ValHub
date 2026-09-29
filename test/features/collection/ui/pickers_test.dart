import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/player_card_picker_screen.dart';
import 'package:valvn/features/collection/ui/player_title_picker_screen.dart';

import '../../../core/domain/loadout/loadout_fixtures.dart';
import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

void main() {
  late Prefs prefs;
  late FakeRiot riot;

  setUp(() async {
    prefs = await createTestPrefs();
    riot = FakeRiot();
  });

  group('S31 card picker', () {
    testWidgets('grid of owned cards, preview, "Trang bị"', (tester) async {
      await pumpCollection(
        tester,
        const PlayerCardPickerScreen(),
        riot: riot,
        prefs: prefs,
      );
      expect(find.text(CollectionStrings.playerCardTitle), findsOneWidget);
      expect(find.text('Thẻ Bộ Đôi Ngời Sáng'), findsOneWidget);
      expect(find.text('Thẻ VALORANT'), findsOneWidget);

      await tester.tap(find.text('Thẻ VALORANT'));
      await settle(tester);
      expect(find.text(CollectionStrings.equip), findsOneWidget);
      await tester.tap(find.text(CollectionStrings.equip));
      await settle(tester);

      expect(riot.puts, hasLength(1));
      expect(asMap(riot.lastPut['Identity'])!['PlayerCardID'], Lx.cardDefault);
      expect(find.text('Đã trang bị Thẻ VALORANT'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('equipped card preview is disabled; search empty state', (
      tester,
    ) async {
      await pumpCollection(
        tester,
        const PlayerCardPickerScreen(),
        riot: riot,
        prefs: prefs,
      );
      await tester.tap(find.text('Thẻ Bộ Đôi Ngời Sáng'));
      await settle(tester);
      expect(find.text(CollectionStrings.equipped), findsOneWidget);
      await tester.tap(find.text(CollectionStrings.equipped));
      await settle(tester);
      expect(riot.puts, isEmpty);
      Navigator.of(tester.element(find.text(CollectionStrings.equipped))).pop();
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'khong co the nay');
      await settle(tester);
      expect(find.text(CollectionStrings.noResults), findsOneWidget);
      await unmount(tester);
    });
  });

  group('S32 title picker', () {
    testWidgets('"Không có danh hiệu" first, equip on tap', (tester) async {
      await pumpCollection(
        tester,
        const PlayerTitlePickerScreen(),
        riot: riot,
        prefs: prefs,
      );
      expect(find.text(CollectionStrings.noTitle), findsOneWidget);
      expect(find.text('Tài Lộc'), findsOneWidget);
      final noneY = tester.getTopLeft(find.text(CollectionStrings.noTitle)).dy;
      final taiLocY = tester.getTopLeft(find.text('Tài Lộc')).dy;
      expect(noneY, lessThan(taiLocY));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Tapping the equipped title does nothing.
      await tester.tap(find.text('Tài Lộc'));
      await settle(tester);
      expect(riot.puts, isEmpty);

      await tester.tap(find.text(CollectionStrings.noTitle));
      await settle(tester);
      expect(
        asMap(riot.lastPut['Identity'])!['PlayerTitleID'],
        SpecialIds.noTitle,
      );

      await tester.enterText(find.byType(TextField), 'tai loc');
      await settle(tester);
      expect(find.text(CollectionStrings.noTitle), findsNothing);
      expect(find.text('Tài Lộc'), findsOneWidget);
      await unmount(tester);
    });
  });
}
