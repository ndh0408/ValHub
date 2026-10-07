import 'package:valvn/features/collection/ui/collection_labels.dart';

import '../../../helpers/l10n.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/features/collection/data/buddy_options.dart';
import 'package:valvn/features/collection/data/collection_items.dart';
import 'package:valvn/features/collection/data/collection_search.dart';
import 'package:valvn/features/collection/data/loadout_view.dart';
import 'package:valvn/features/collection/data/skin_query.dart';
import 'package:valvn/features/collection/data/weapon_sections.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../core/domain/loadout/loadout_fixtures.dart';

OwnedItems fixtureOwned(ContentDb db) => OwnedItems.resolve(
  Entitlements.fromTypeResponses({
    for (final type in ItemTypeIds.collectionTypes) type: entitlementsFor(type),
  }, receivedAt: DateTime(2026)),
  db,
);

void main() {
  final db = economyContent();
  final owned = fixtureOwned(db);
  final prices = PriceService(db: db);

  group('search', () {
    test('folds Vietnamese diacritics and case', () {
      expect(foldForSearch('Vandal Cafe Xanh Mát'), 'vandal cafe xanh mat');
      expect(foldForSearch('  ĐỘC   Quyền '), 'doc quyen');
      expect(matchesSearch('cafe mat', ['Vandal Cafe Xanh Mát']), isTrue);
      expect(matchesSearch('XANH', ['vandal cafe xanh mát']), isTrue);
      expect(matchesSearch('reaver', ['Vandal Cafe', null, 'Vandal']), isFalse);
      expect(matchesSearch('  ', ['x']), isTrue);
      expect(matchesSearch('vandal reaver', ['Reaver', 'Vandal']), isTrue);
      expect(compareNames('Ánh', 'Bạc'), lessThan(0));
    });
  });

  group('querySkins', () {
    final skins = owned.ownedCollectibleSkins;

    test('owned fixture skins', () {
      expect(
        skins.map((s) => s.uuid),
        containsAll([
          Fx.reaverVandal,
          Fx.vandalCafe,
          Fx.bulldogVoCuc,
          Fx.daoReaver,
          Fx.ghostThinhLang,
        ]),
      );
      expect(skins, hasLength(5));
    });

    test('rarity: rarest first, then name', () {
      final out = querySkins(skins, const SkinQuery(), db: db);
      final ranks = [
        for (final s in out) db.contentTier(s.contentTierUuid)?.rank ?? -1,
      ];
      expect(ranks, [...ranks]..sort((a, b) => b.compareTo(a)));
      expect(out.first.uuid, Fx.daoReaver); // Exclusive
      expect(out.last.uuid, Fx.ghostThinhLang); // Select
    });

    test('name, weapon and price sorts', () {
      final byName = querySkins(
        skins,
        const SkinQuery(sort: SkinSort.name),
        db: db,
      );
      expect(byName.map((s) => s.displayName).toList(), [
        'Bulldog Vô Cực',
        'Dao Reaver',
        'Ghost Thinh Lặng',
        'Vandal Cafe Xanh Mát',
        'Vandal Reaver',
      ]);
      final byWeapon = querySkins(
        skins,
        const SkinQuery(sort: SkinSort.weapon),
        db: db,
      );
      expect(byWeapon.first.uuid, Fx.ghostThinhLang); // sidearm first
      expect(byWeapon.last.uuid, Fx.daoReaver); // melee last
      final byPrice = querySkins(
        skins,
        const SkinQuery(sort: SkinSort.price),
        db: db,
        prices: prices,
      );
      final vps = [
        for (final s in byPrice) prices.priceForSkin(s.uuid).vp ?? -1,
      ];
      expect(vps, [...vps]..sort((a, b) => b.compareTo(a)));
    });

    test('search and tier filter', () {
      final cafe = querySkins(skins, const SkinQuery(search: 'cafe'), db: db);
      expect(cafe.single.uuid, Fx.vandalCafe);
      final byWeaponName = querySkins(
        skins,
        const SkinQuery(search: 'ghost'),
        db: db,
      );
      expect(byWeaponName.single.uuid, Fx.ghostThinhLang);
      final q = const SkinQuery().toggleTier(ContentTierIds.premium);
      expect(q.isFiltering, isTrue);
      expect(querySkins(skins, q, db: db).single.uuid, Fx.reaverVandal);
      expect(q.toggleTier(ContentTierIds.premium).isFiltering, isFalse);
      expect(const SkinQuery(search: 'a'), const SkinQuery(search: 'a'));
    });

    test('valueOf skips Standard skins', () {
      final standard = db.skin(Fx.vandalStandard)!;
      expect(valueOf([standard], prices).skinCount, 0);
      expect(valueOf(skins, prices).skinCount, 5);
    });
  });

  group('weapon sections', () {
    test('category order, cheapest first, only loadout guns', () {
      final sections = weaponSections(db.weapons);
      expect(sections.map((s) => s.category.name).toList(), [
        'sidearm',
        'rifle',
        'sniper',
        'heavy',
        'melee',
      ]);
      final rifles = sections.firstWhere((s) => s.category.name == 'rifle');
      final costs = [for (final w in rifles.weapons) w.shopCost ?? 0];
      expect(costs, [...costs]..sort());
      final only = weaponSections(db.weapons, onlyIds: {Lx.vandal, Lx.melee});
      expect(only.expand((s) => s.weapons).map((w) => w.uuid), [
        Lx.vandal,
        Lx.melee,
      ]);
      expect(orderedWeapons(db.weapons).last.uuid, Lx.melee);
    });
  });

  group('buddy options', () {
    final loadout = Loadout.fromJson(loadoutJson());

    test('copies, "Còn n/m" and the copy to equip', () {
      final options = buddyOptions(owned, db, loadout);
      final neo = options.firstWhere(
        (o) => o.buddy.uuid == Fx.neoFrontierBuddy,
      );
      expect(neo.total, 2);
      expect(neo.free, 1);
      expect(neo.isOn(Lx.vandal), isTrue);
      expect(neo.copyFor(Lx.vandal)!.instanceId, Lx.buddyInstanceA);
      final forPhantom = neo.copyFor(Lx.phantom)!;
      expect(forPhantom.instanceId, Lx.buddyInstanceB);
      expect(forPhantom.isFree, isTrue);
      final change = neo.equipOn(Lx.phantom, forPhantom);
      expect(change.instanceId, Lx.buddyInstanceB);
      expect(change.buddyId, Fx.neoFrontierBuddy);
      expect(change.buddyLevelId, Fx.neoFrontierBuddyL1);

      // Gourmand: owned without an InstanceID → cannot be equipped.
      final gourmand = options.firstWhere(
        (o) => o.buddy.levels.any((l) => l.uuid == Fx.gourmandBuddyL1),
      );
      expect(gourmand.canEquip, isFalse);
      expect(gourmand.total, 1);
      expect(gourmand.copyFor(Lx.phantom), isNull);
    });

    test('all copies used → move one from another gun', () {
      final raw = const EquipBuddy(
        weaponId: Lx.phantom,
        buddyId: Fx.neoFrontierBuddy,
        buddyLevelId: Fx.neoFrontierBuddyL1,
        instanceId: Lx.buddyInstanceB,
      ).appliedTo(loadoutJson());
      final neo = buddyOptions(
        owned,
        db,
        Loadout.fromJson(raw),
      ).firstWhere((o) => o.buddy.uuid == Fx.neoFrontierBuddy);
      expect(neo.free, 0);
      final copy = neo.copyFor(Lx.ghost)!;
      expect(copy.equippedOn, isNotNull);
    });

    test(
      'a pending pick: its change, and whether the gun already shows it',
      () {
        final neo = buddyOptions(
          owned,
          db,
          loadout,
        ).firstWhere((o) => o.buddy.uuid == Fx.neoFrontierBuddy);
        final vandal = loadout.gun(Lx.vandal);
        final phantom = loadout.gun(Lx.phantom);

        final onVandal = BuddyPickEquip(neo, neo.copyFor(Lx.vandal)!);
        expect(onVandal.isSavedOn(vandal), isTrue);
        final toPhantom = BuddyPickEquip(neo, neo.copyFor(Lx.phantom)!);
        expect(toPhantom.isSavedOn(phantom), isFalse);
        expect(
          (toPhantom.changeFor(Lx.phantom) as EquipBuddy).instanceId,
          Lx.buddyInstanceB,
        );

        const remove = BuddyPickRemove();
        expect(remove.isSavedOn(vandal), isFalse);
        expect(remove.isSavedOn(phantom), isTrue);
        expect(remove.changeFor(Lx.vandal), isA<RemoveBuddy>());
      },
    );
  });

  group('owned cosmetics', () {
    test('defaults included, empties excluded, sorted', () {
      expect(ownedCards(owned, db).map((c) => c.uuid), [
        Fx.cardNgoiSang,
        Lx.cardDefault,
      ]);
      expect(ownedTitles(owned, db).single.uuid, Fx.titleTaiLoc);
      expect(ownedSprays(owned, db).map((s) => s.uuid), [
        Fx.sprayTinhNguyen,
        '0a6db78c-48b9-a32d-c47a-82be597584c1',
      ]);
      expect(ownedFlex(owned, db).map((f) => f.uuid), [
        Fx.flexOra,
        'af52b5a0-4a4c-03b2-c9d7-8187a08a2675',
      ]);
    });
  });

  group('loadout view', () {
    test('equipped skin, render and buddy', () {
      final loadout = Loadout.fromJson(loadoutJson());
      final vandal = loadout.gun(Lx.vandal);
      expect(equippedSkin(vandal, db)!.uuid, Fx.vandalStandard);
      expect(equippedSkin(vandal, db)!.equippedLabel(tl), 'Mặc định');
      expect(gunRender(vandal, db), isNotNull);
      expect(equippedBuddy(vandal, db)!.uuid, Fx.neoFrontierBuddy);
      expect(equippedBuddy(loadout.gun(Lx.phantom), db), isNull);
      expect(gunRender(null, db, weapon: db.weapon(Lx.vandal)), isNotNull);
      expect(equippedSkin(null, db), isNull);
    });
  });
}
