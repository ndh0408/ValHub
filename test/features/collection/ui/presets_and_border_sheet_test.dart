import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/loadout_presets_screen.dart';
import 'package:valvn/features/collection/ui/widgets/level_border_sheet.dart';

import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

class _BorderHost extends StatelessWidget {
  const _BorderHost();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () =>
            unawaited(showLevelBorderSheet(context, account: testAccount)),
        child: const Text('open'),
      ),
    ),
  );
}

void main() {
  late Prefs prefs;
  late FakeRiot riot;

  setUp(() async {
    prefs = await createTestPrefs();
    riot = FakeRiot();
  });

  testWidgets('presets: large title, device-only note, pinned save button', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const LoadoutPresetsScreen(),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text(CollectionStrings.presetsTitle), findsOneWidget);
    expect(find.text(CollectionStrings.presetsNote), findsOneWidget);
    // Empty state with a title and the reason to save.
    expect(find.text(CollectionStrings.presetsEmptyTitle), findsOneWidget);
    expect(find.text(CollectionStrings.presetsEmpty), findsOneWidget);
    // The primary action lives in the bottom bar, above the safe area.
    final save = find.widgetWithText(
      FilledButton,
      CollectionStrings.savePreset,
    );
    expect(save, findsOneWidget);
    expect(
      tester.getBottomLeft(save).dy,
      greaterThan(tester.view.physicalSize.height * 0.8),
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('presets: saved presets show weapon names and the date', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const LoadoutPresetsScreen(),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text(CollectionStrings.savePreset));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Leo rank');
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Leo rank'), findsOneWidget);
    expect(find.text('Vandal'), findsOneWidget);
    expect(find.text('Phantom'), findsOneWidget);
    expect(find.text(CollectionStrings.presetsEmptyTitle), findsNothing);
    await unmount(tester);
  });

  testWidgets('presets fit 360 dp at 200 % text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpCollection(
      tester,
      const LoadoutPresetsScreen(),
      riot: riot,
      prefs: prefs,
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('level border sheet: header, automatic option, close button', (
    tester,
  ) async {
    await pumpCollection(tester, const _BorderHost(), riot: riot, prefs: prefs);
    await tester.tap(find.text('open'));
    await settle(tester);
    expect(find.text(CollectionStrings.levelBorderTitle), findsOneWidget);
    expect(find.text(CollectionStrings.levelBorderAuto), findsOneWidget);
    expect(find.byTooltip(CommonStrings.close), findsOneWidget);
    await tester.tap(find.byTooltip(CommonStrings.close));
    await settle(tester);
    expect(find.text(CollectionStrings.levelBorderTitle), findsNothing);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
