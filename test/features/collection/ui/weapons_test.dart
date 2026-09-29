import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/buddy_picker_sheet.dart';
import 'package:valvn/features/collection/ui/skin_customize_screen.dart';
import 'package:valvn/features/collection/ui/weapon_loadout_screen.dart';
import 'package:valvn/features/collection/ui/weapon_skins_screen.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../core/domain/loadout/loadout_fixtures.dart';
import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

JsonMap gunOf(JsonMap raw, String weaponId) =>
    asMapList(raw['Guns']).firstWhere((g) => lowerUuid(g['ID']) == weaponId);

class _BuddyHost extends StatelessWidget {
  const _BuddyHost({required this.weaponId});

  final String weaponId;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              unawaited(showBuddyPickerSheet(context, weaponId: weaponId)),
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
    await unmount(tester);
  });

  testWidgets('S36 buddy picker: "Còn 1/2", equip a free copy', (tester) async {
    await pumpCollection(
      tester,
      const _BuddyHost(weaponId: Lx.phantom),
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
    final phantom = gunOf(riot.lastPut, Lx.phantom);
    expect(phantom['CharmInstanceID'], Lx.buddyInstanceB);
    expect(
      gunOf(riot.lastPut, Lx.vandal)['CharmInstanceID'],
      Lx.buddyInstanceA,
    );
    expect(find.text(CollectionStrings.buddyPickerTitle), findsNothing);
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
    await pumpCollection(
      tester,
      const _BuddyHost(weaponId: Lx.ghost),
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
    expect(riot.puts, hasLength(1));
    expect(gunOf(riot.lastPut, Lx.ghost)['CharmInstanceID'], isNotNull);
    await unmount(tester);

    // Remove from the Vandal.
    riot = FakeRiot();
    await pumpCollection(
      tester,
      const _BuddyHost(weaponId: Lx.vandal),
      riot: riot,
      prefs: prefs,
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.removeBuddy));
    await settle(tester);
    expect(
      gunOf(riot.lastPut, Lx.vandal).containsKey('CharmInstanceID'),
      isFalse,
    );
    expect(find.text(CollectionStrings.buddyRemoved), findsOneWidget);
    await unmount(tester);
  });
}
