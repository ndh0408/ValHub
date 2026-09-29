import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoAlertDialog, CupertinoTextField;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/skin_art_card.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/collection/ui/browse_collection_screen.dart';
import 'package:valvn/features/collection/ui/collection_screen.dart';
import 'package:valvn/features/collection/ui/loadout_presets_screen.dart';
import 'package:valvn/features/collection/ui/weapon_skins_screen.dart';

import '../../../core/domain/loadout/loadout_fixtures.dart';
import '../../../helpers/test_prefs.dart';
import '../collection_test_harness.dart';

Future<void> _tapChip(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(FilterChip, label);
  await tester.ensureVisible(chip);
  await settle(tester);
  await tester.tap(chip);
  await settle(tester);
}

void main() {
  late Prefs prefs;
  late FakeRiot riot;

  setUp(() async {
    prefs = await createTestPrefs();
    riot = FakeRiot();
  });

  testWidgets('browse skins: image-forward cards with rarity tags', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
    );
    expect(find.byType(SkinArtCard), findsWidgets);
    expect(find.byType(TierTag), findsWidgets);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('browse skins remembers the tier filter and sort', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
    );
    await _tapChip(tester, 'Cao Cấp');
    expect(find.textContaining('Đang lọc: 1 skin · '), findsOneWidget);

    // Sort by name through the sort sheet.
    await tester.ensureVisible(find.text(CollectionStrings.sortRarity));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.sortRarity));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.sortName).last);
    await settle(tester);
    await unmount(tester);
    expect(prefs.getString('ui.collection.browse.skin.sort'), 'name');
    expect(prefs.getString('ui.collection.browse.skin.tiers'), isNotNull);

    // Reopened: same filter and sort, search not remembered.
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
    );
    expect(find.textContaining('Đang lọc: 1 skin · '), findsOneWidget);
    expect(find.text(CollectionStrings.sortName), findsOneWidget);

    // Clearing the tiers forgets them too.
    await tester.ensureVisible(find.text(CollectionStrings.clearFilters));
    await settle(tester);
    await tester.tap(find.text(CollectionStrings.clearFilters));
    await settle(tester);
    expect(find.textContaining('5 skin · '), findsOneWidget);
    await unmount(tester);
    expect(prefs.getString('ui.collection.browse.skin.tiers'), isNull);
  });

  testWidgets('weapon skins: filter to nothing offers "Bỏ lọc phiên bản"', (
    tester,
  ) async {
    await pumpCollection(
      tester,
      const WeaponSkinsScreen(weaponId: Lx.vandal),
      riot: riot,
      prefs: prefs,
    );
    // No Ultra Vandal skin in the fixtures.
    await _tapChip(tester, 'Siêu Cấp');
    expect(find.text(CollectionStrings.noResultsTitle), findsOneWidget);
    await tester.tap(find.text(CollectionStrings.clearTiers));
    await settle(tester);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(prefs.getString('ui.collection.weaponSkins.tiers'), isNull);
    await unmount(tester);
  });

  testWidgets('iOS: preset name + apply use Cupertino dialogs', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await pumpCollection(
        tester,
        const LoadoutPresetsScreen(),
        riot: riot,
        prefs: prefs,
      );
      await tester.tap(find.text(CollectionStrings.savePreset));
      await settle(tester);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField), 'Leo rank');
      await tester.pump();
      await tester.tap(find.text('Lưu'));
      await settle(tester);
      expect(find.text('Leo rank'), findsOneWidget);

      await tester.tap(find.text(CollectionStrings.applyPreset));
      await settle(tester);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoAlertDialog),
          matching: find.text(CollectionStrings.applyPreset),
        ),
      );
      await settle(tester);
      // Same loadout as saved: nothing to PUT, but the apply went through.
      expect(find.textContaining('Đã áp dụng “Leo rank”'), findsOneWidget);
      await unmount(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  group('no overflow at 360 dp and 200 % text', () {
    Future<void> check(WidgetTester tester, Widget screen) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpCollection(tester, screen, riot: riot, prefs: prefs);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await settle(tester);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    }

    testWidgets('collection hub', (tester) async {
      await check(tester, const CollectionScreen());
    });

    testWidgets('browse skins', (tester) async {
      await check(
        tester,
        const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      );
    });

    testWidgets('weapon skins', (tester) async {
      await check(tester, const WeaponSkinsScreen(weaponId: Lx.vandal));
    });
  });

  testWidgets('light theme: hub and browse render cleanly', (tester) async {
    await pumpCollection(
      tester,
      const CollectionScreen(),
      riot: riot,
      prefs: prefs,
      theme: buildLightTheme(),
    );
    expect(find.text(CollectionStrings.rowWeapons), findsOneWidget);
    expect(tester.takeException(), isNull);
    await pumpCollection(
      tester,
      const BrowseCollectionScreen(type: CollectionBrowseType.skin),
      riot: riot,
      prefs: prefs,
      theme: buildLightTheme(),
    );
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
