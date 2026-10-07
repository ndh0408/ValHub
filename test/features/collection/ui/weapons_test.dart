import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/data/buddy_options.dart';
import 'package:valvn/features/collection/ui/buddy_picker_sheet.dart';
import 'package:valvn/features/collection/ui/skin_customize_screen.dart';
import 'package:valvn/features/collection/ui/weapon_loadout_screen.dart';
import 'package:valvn/features/collection/ui/weapon_skins_screen.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../core/domain/loadout/loadout_fixtures.dart';
import '../../../helpers/l10n.dart';
import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

JsonMap gunOf(JsonMap raw, String weaponId) =>
    asMapList(raw['Guns']).firstWhere((g) => lowerUuid(g['ID']) == weaponId);

class _BuddyHost extends StatelessWidget {
  const _BuddyHost({required this.weaponId, required this.picks});

  final String weaponId;

  /// What each opening of the sheet returned.
  final List<BuddyPick?> picks;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => unawaited(
            showBuddyPickerSheet(context, weaponId: weaponId).then(picks.add),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

/// The page's own scrollable (the pinned search field has one too).
Finder get _mainScrollable => find
    .descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    )
    .first;

void main() {
  late Prefs prefs;
  late FakeRiot riot;

  setUp(() async {
    prefs = await createTestPrefs();
    riot = FakeRiot();
  });

  testWidgets('S33 weapons by category with the equipped skin', (tester) async {
    await pumpCollection(
      tester,
      const WeaponLoadoutScreen(),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text('SÚNG PHỤ'), findsOneWidget);
    expect(find.text('SÚNG TRƯỜNG'), findsOneWidget);
    expect(find.text('VANDAL'), findsOneWidget);
    expect(find.text('PHANTOM'), findsOneWidget);
    expect(find.text('Mặc định'), findsWidgets);
    // Section header and the melee tile share the uppercase name.
    await tester.scrollUntilVisible(
      find.text('CẬN CHIẾN').first,
      200,
      scrollable: _mainScrollable,
    );
    expect(find.text('CẬN CHIẾN'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('VANDAL'),
      -200,
      scrollable: _mainScrollable,
    );
    await tester.tap(find.text('VANDAL'));
    await settle(tester);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('S34 skin picker: "Mặc định" first, sort, tier filter', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const WeaponSkinsScreen(weaponId: Lx.vandal),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text('Vandal'), findsOneWidget); // app bar
    double y(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text(CollectionStrings.equipped), findsOneWidget);
    expect(y('Mặc định'), lessThan(y('Vandal Reaver')));
    // Rarity: Premium Reaver before Deluxe Cafe.
    expect(y('Vandal Reaver'), lessThan(y('Vandal Cafe Xanh Mát')));
    expect(find.text('Cấp 3/4'), findsOneWidget);

    await tester.tap(find.text(CollectionStrings.sortRarity));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.sortName).last);
    await settle(tester);
    expect(y('Vandal Cafe Xanh Mát'), lessThan(y('Vandal Reaver')));

    await tester.enterText(find.byType(TextField), 'reaver');
    await settle(tester);
    expect(find.text('Mặc định'), findsNothing);
    expect(find.text('Vandal Cafe Xanh Mát'), findsNothing);
    expect(find.text('Vandal Reaver'), findsOneWidget);

    await tester.tap(find.text('Vandal Reaver'));
    await settle(tester);
    expect(find.text(CollectionStrings.variants), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('S35 customize: locked level greyed, "Trang bị" saves', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const SkinCustomizeScreen(weaponId: Lx.vandal, skinId: Fx.reaverVandal),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text('Vandal Reaver'), findsWidgets);
    expect(find.text(CollectionStrings.variants), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(CollectionStrings.buddySlot),
      200,
      scrollable: _mainScrollable,
    );
    expect(find.text(CollectionStrings.levels), findsOneWidget);
    expect(find.text(CollectionStrings.locked), findsOneWidget); // level 4
    await tester.scrollUntilVisible(
      find.text('Phụ Kiện Neo Frontier'),
      200,
      scrollable: _mainScrollable,
    );
    expect(find.text('Phụ Kiện Neo Frontier'), findsOneWidget);

    await tester.tap(find.text(CollectionStrings.equip));
    await settle(tester);
    expect(riot.puts, hasLength(1));
    final vandal = gunOf(riot.lastPut, Lx.vandal);
    expect(vandal['SkinID'], Fx.reaverVandal);
    expect(vandal['SkinLevelID'], Fx.reaverL3); // best owned level
    expect(vandal['ChromaID'], Fx.reaverBaseChroma);
    expect(vandal['CharmInstanceID'], Lx.buddyInstanceA, reason: 'kept');
    expect(find.text(CollectionStrings.equipped), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('S35 unowned skin cannot be equipped', (tester) async {
    await pumpCollection(
      tester,
      const SkinCustomizeScreen(
        weaponId: Lx.phantom,
        skinId: Fx.phantomTocChien,
      ),
      riot: riot,
      prefs: prefs,
    );
    expect(find.text(CollectionStrings.skinNotOwned), findsOneWidget);
    await tester.tap(find.text(CollectionStrings.equip));
    await settle(tester);
    expect(riot.puts, isEmpty);
    // Nothing to save the buddy with: the slot does not open the picker.
    final row = find.text(tl.collectionChangeBuddy);
    await tester.scrollUntilVisible(row, 200, scrollable: _mainScrollable);
    await tester.tap(row);
    await settle(tester);
    expect(find.text(tl.collectionBuddyPickerTitle), findsNothing);
    await unmount(tester);
  });

  testWidgets('S36 buddy picker: "Còn 1/2", a pick is returned, not saved', (
    tester,
  ) async {
    final picks = <BuddyPick?>[];
    await pumpCollection(
      tester,
      _BuddyHost(weaponId: Lx.phantom, picks: picks),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    expect(find.text(CollectionStrings.buddyPickerTitle), findsOneWidget);
    expect(find.text('Phụ Kiện Neo Frontier'), findsOneWidget);
    expect(find.text('Còn 1/2'), findsOneWidget);
    expect(find.text(CollectionStrings.removeBuddy), findsNothing);

    await tester.tap(find.text('Phụ Kiện Neo Frontier'));
    await settle(tester);
    expect(find.text(CollectionStrings.buddyPickerTitle), findsNothing);
    expect(riot.puts, isEmpty);
    final pick = picks.single! as BuddyPickEquip;
    expect(pick.copy.instanceId, Lx.buddyInstanceB); // the free copy
    final change = pick.changeFor(Lx.phantom) as EquipBuddy;
    expect(change.weaponId, Lx.phantom);
    await unmount(tester);
  });

  testWidgets('S36 moving the last copy asks first; "Gỡ phụ kiện"', (
    tester,
  ) async {
    riot.server = asMap({...loadoutJson()})!;
    // Both copies in use: A on the Vandal, B on the Phantom.
    gunOf(riot.server, Lx.phantom)
      ..['CharmInstanceID'] = Lx.buddyInstanceB
      ..['CharmID'] = Fx.neoFrontierBuddy
      ..['CharmLevelID'] = Fx.neoFrontierBuddyL1;
    final picks = <BuddyPick?>[];
    await pumpCollection(
      tester,
      _BuddyHost(weaponId: Lx.ghost, picks: picks),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    expect(find.text('Còn 0/2'), findsOneWidget);
    await tester.tap(find.text('Phụ Kiện Neo Frontier'));
    await settle(tester);
    expect(find.text(CollectionStrings.moveBuddyTitle), findsOneWidget);
    await tester.tap(find.text(CollectionStrings.move));
    await settle(tester);
    expect(riot.puts, isEmpty);
    expect((picks.single! as BuddyPickEquip).copy.equippedOn, isNotNull);
    await unmount(tester);

    // Remove from the Vandal.
    riot = FakeRiot();
    picks.clear();
    await pumpCollection(
      tester,
      _BuddyHost(weaponId: Lx.vandal, picks: picks),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.removeBuddy));
    await settle(tester);
    expect(riot.puts, isEmpty);
    expect(picks.single, isA<BuddyPickRemove>());
    await unmount(tester);
  });

  testWidgets('S35 buddy waits for "Trang bị", like the variant and level', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const SkinCustomizeScreen(weaponId: Lx.vandal, skinId: Fx.reaverVandal),
      riot: riot,
      prefs: prefs,
    );
    Future<void> openBuddy() async {
      // Let a "Đã trang bị" snackbar leave the slot uncovered.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .hideCurrentSnackBar();
      await settle(tester);
      final row = find.text(tl.collectionChangeBuddy);
      await tester.scrollUntilVisible(row, 200, scrollable: _mainScrollable);
      await tester.tap(row);
      await settle(tester);
    }

    // Take the buddy off: shown at once, saved only by "Trang bị".
    await openBuddy();
    await tester.tap(find.text(tl.collectionRemoveBuddy));
    await settle(tester);
    expect(riot.puts, isEmpty);
    expect(find.text(tl.collectionNoBuddy), findsOneWidget);
    await tester.tap(find.text(tl.collectionEquip));
    await settle(tester);
    expect(riot.puts, hasLength(1));
    var vandal = gunOf(riot.lastPut, Lx.vandal);
    expect(vandal['SkinID'], Fx.reaverVandal);
    expect(vandal.containsKey('CharmInstanceID'), isFalse);
    expect(find.text(tl.collectionEquipped), findsOneWidget);

    // Skin already on: a buddy pick alone turns "Trang bị" back on.
    await openBuddy();
    await tester.tap(find.text('Phụ Kiện Neo Frontier'));
    await settle(tester);
    expect(riot.puts, hasLength(1));
    expect(find.text(tl.collectionEquip), findsOneWidget);
    await tester.tap(find.text(tl.collectionEquip));
    await settle(tester);
    expect(riot.puts, hasLength(2));
    vandal = gunOf(riot.lastPut, Lx.vandal);
    expect(vandal['CharmInstanceID'], isNotNull);
    expect(
      find.text(tl.collectionEquippedItem('Phụ Kiện Neo Frontier')),
      findsOneWidget,
    );
    expect(find.text(tl.collectionEquipped), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
