import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/features/wishlist/data/skin_query.dart';

import '../../../core/domain/economy/economy_fixtures.dart';

const ghostMagepunk = '33824a13-453b-0636-4ec4-e19708aa934e';
const operatorThanRung = '83b49f36-4085-8179-6896-1a99f2d2d1d8';
const vandalWeapon = Fx.vandal;

void main() {
  late ContentDb db;
  late SkinCatalog catalog;

  setUp(() {
    db = economyContent();
    catalog = SkinCatalog.build(db, PriceService(db: db));
  });

  List<String> names(List<SkinFacts> list) => [for (final f in list) f.name];

  group('SkinCatalog', () {
    test('lists every collectible skin, without Standard / random', () {
      expect(catalog.skins, hasLength(12));
      final all = names(catalog.skins);
      expect(all, isNot(contains('Vandal Thông Thường')));
      expect(all, isNot(contains('Skin Yêu Thích Ngẫu Nhiên')));
      expect(all.first, 'Ghost Thinh Lặng', reason: 'sidearms come first');
      expect(catalog.weapons.map((w) => w.displayName), [
        'Ghost',
        'Bulldog',
        'Phantom',
        'Vandal',
        'Operator',
        'Ares',
        'Odin',
        'Cận Chiến',
      ]);
      expect(catalog.tiers.map((t) => t.devName), [
        'Select',
        'Deluxe',
        'Premium',
        'Exclusive',
        'Ultra',
      ]);
    });

    test('factsFor resolves skin, level and chroma uuids', () {
      expect(catalog.factsFor(Fx.reaverL3)?.uuid, Fx.reaverVandal);
      expect(catalog.factsFor(Fx.reaverChroma2)?.uuid, Fx.reaverVandal);
      expect(
        catalog.factsFor(Fx.reaverVandal.toUpperCase())?.uuid,
        Fx.reaverVandal,
      );
      expect(catalog.factsFor(Fx.unknownLevel), isNull);
      final standard = catalog.factsFor(Fx.vandalStandard);
      expect(standard?.weapon?.displayName, 'Vandal');
      expect(standard?.quote.source, PriceSource.notForSale);
    });

    test('facts carry tier, weapon and price', () {
      final reaver = catalog.factsFor(Fx.reaverVandal)!;
      expect(reaver.tier?.devName, 'Premium');
      expect(reaver.tierRank, 2);
      expect(reaver.weapon?.uuid, vandalWeapon);
      expect(reaver.quote.hasPrice, isTrue);
      expect(reaver.sortPrice, reaver.quote.vp);
    });
  });

  group('applySkinQuery', () {
    test('rarity: highest edition first, then name', () {
      final list = applySkinQuery(catalog.skins, const SkinQuery());
      expect(names(list).take(4), [
        'Ares Sentinels of Light',
        'Dao Đầu Bếp Cafe Xanh Mát',
        'Dao Reaver',
        'Odin Neo Frontier',
      ]);
      final ranks = [for (final f in list) f.tierRank];
      for (var i = 1; i < ranks.length; i++) {
        expect(ranks[i] <= ranks[i - 1], isTrue);
      }
    });

    test('name: A → Z, accent-insensitive', () {
      final list = applySkinQuery(
        catalog.skins,
        const SkinQuery(sort: SkinSort.name),
      );
      expect(names(list).first, 'Ares Prism');
      expect(names(list).last, 'Vandal Reaver');
      final keys = [for (final f in list) f.nameKey];
      expect(keys, [...keys]..sort());
    });

    test('weapon: loadout order', () {
      final list = applySkinQuery(
        catalog.skins,
        const SkinQuery(sort: SkinSort.weapon),
      );
      expect(names(list).take(2), ['Ghost Magepunk', 'Ghost Thinh Lặng']);
      expect(list.last.weapon?.displayName, 'Cận Chiến');
    });

    test('price: most expensive first, unpriced last', () {
      final prices = PriceService(
        db: db,
        observed: {Fx.odinNeoFrontierL1: 9999},
      );
      final withObserved = SkinCatalog.build(db, prices);
      final list = applySkinQuery(
        withObserved.skins,
        const SkinQuery(sort: SkinSort.price),
      );
      expect(list.first.name, 'Odin Neo Frontier');
      final vps = [for (final f in list) f.sortPrice];
      final priced = vps.whereType<int>().toList();
      expect(priced, [...priced]..sort((a, b) => b.compareTo(a)));
      final firstNull = vps.indexOf(null);
      if (firstNull >= 0) {
        expect(vps.skip(firstNull).every((v) => v == null), isTrue);
      }
    });

    test('search matches skin and weapon names without accents', () {
      expect(
        names(applySkinQuery(catalog.skins, const SkinQuery(text: 'vo cuc'))),
        ['Bulldog Vô Cực'],
      );
      expect(
        names(
          applySkinQuery(
            catalog.skins,
            const SkinQuery(text: 'can chien', sort: SkinSort.name),
          ),
        ),
        ['Dao Đầu Bếp Cafe Xanh Mát', 'Dao Reaver'],
      );
      expect(
        applySkinQuery(catalog.skins, const SkinQuery(text: 'zzz')),
        isEmpty,
      );
    });

    test('tier and weapon filters', () {
      final select = applySkinQuery(
        catalog.skins,
        const SkinQuery(tiers: {ContentTierIds.select}, sort: SkinSort.name),
      );
      expect(names(select), ['Ghost Thinh Lặng', 'Phantom Tốc Chiến']);

      final vandal = applySkinQuery(
        catalog.skins,
        const SkinQuery(weaponUuid: vandalWeapon, sort: SkinSort.name),
      );
      expect(names(vandal), ['Vandal Cafe Xanh Mát', 'Vandal Reaver']);

      final both = applySkinQuery(
        catalog.skins,
        const SkinQuery(
          weaponUuid: vandalWeapon,
          tiers: {ContentTierIds.premium},
        ),
      );
      expect(names(both), ['Vandal Reaver']);
    });
  });

  group('SkinQuery', () {
    test('value semantics and helpers', () {
      const q = SkinQuery(text: 'a', tiers: {'x', 'y'}, sort: SkinSort.name);
      expect(
        q,
        const SkinQuery(text: 'a', tiers: {'y', 'x'}, sort: SkinSort.name),
      );
      expect(
        q.hashCode,
        const SkinQuery(
          text: 'a',
          tiers: {'y', 'x'},
          sort: SkinSort.name,
        ).hashCode,
      );
      expect(q.isFiltering, isTrue);
      expect(const SkinQuery(text: '  ').isFiltering, isFalse);
      expect(q.toggleTier('x').tiers, {'y'});
      expect(q.toggleTier('z').tiers, {'x', 'y', 'z'});
      expect(q.cleared(), const SkinQuery(sort: SkinSort.name));
      final w = q.copyWith(weaponUuid: 'w');
      expect(w.weaponUuid, 'w');
      expect(w.copyWith(clearWeapon: true).weaponUuid, isNull);
      expect(w.copyWith(text: 'b').weaponUuid, 'w');
    });

    test('sort labels are Vietnamese', () {
      expect(SkinSort.values.map((s) => s.label), [
        'Độ hiếm',
        'Tên',
        'Vũ khí',
        'Giá',
      ]);
    });
  });

  test('ids used by the fixtures exist', () {
    expect(db.skin(ghostMagepunk)?.displayName, 'Ghost Magepunk');
    expect(db.skin(operatorThanRung)?.displayName, 'Operator Thần Rừng');
  });
}
