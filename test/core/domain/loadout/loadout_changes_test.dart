import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/util/json.dart';

import '../economy/economy_fixtures.dart';
import 'loadout_fixtures.dart';

JsonMap gunRaw(JsonMap raw, String weaponId) =>
    asMapList(raw['Guns']).firstWhere((g) => lowerUuid(g['ID']) == weaponId);

void main() {
  late JsonMap raw;

  setUp(() => raw = loadoutJson());

  test('EquipSkin changes only the three skin keys of one gun', () {
    const change = EquipSkin(
      weaponId: Lx.vandal,
      skinId: Fx.reaverVandal,
      skinLevelId: Fx.reaverL3,
      chromaId: Fx.reaverChroma2,
    );
    final out = change.appliedTo(raw);
    final vandal = gunRaw(out, Lx.vandal);
    expect(vandal['SkinID'], Fx.reaverVandal);
    expect(vandal['SkinLevelID'], Fx.reaverL3);
    expect(vandal['ChromaID'], Fx.reaverChroma2);
    // Everything else round-trips.
    expect(vandal['CharmInstanceID'], Lx.buddyInstanceA);
    expect(vandal['Attachments'], isEmpty);
    expect(vandal['ID'], Lx.vandal.toUpperCase());
    expect(out['AgentMasteryCosmetics'], raw['AgentMasteryCosmetics']);
    expect(out['DynamicOptions'], <String, dynamic>{});
    expect(out['Version'], 25);
    expect(gunRaw(out, Lx.phantom), gunRaw(raw, Lx.phantom));
    // The input is untouched.
    expect(gunRaw(raw, Lx.vandal)['SkinID'], Fx.vandalStandard);

    expect(change.isReflectedIn(Loadout.fromJson(out)), isTrue);
    expect(change.isReflectedIn(Loadout.fromJson(raw)), isFalse);
  });

  test('unknown weapon and empty ids are rejected', () {
    expect(
      () => const EquipSkin(
        weaponId: 'ffffffff-ffff-4fff-8fff-ffffffffffff',
        skinId: 'a',
        skinLevelId: 'b',
        chromaId: 'c',
      ).appliedTo(raw),
      throwsA(
        isA<LoadoutEditException>().having(
          (e) => e.error,
          'error',
          LoadoutEditError.unknownWeapon,
        ),
      ),
    );
    expect(
      () => const SetPlayerCard(' ').appliedTo(raw),
      throwsA(isA<LoadoutEditException>()),
    );
  });

  group('buddies', () {
    test(
      'EquipBuddy moves a copy off the other gun (one instance per gun)',
      () {
        const change = EquipBuddy(
          weaponId: Lx.phantom,
          buddyId: Fx.neoFrontierBuddy,
          buddyLevelId: Fx.neoFrontierBuddyL1,
          instanceId: '90431B40-A439-410F-8C51-765452353200',
        );
        final out = change.appliedTo(raw);
        final phantom = gunRaw(out, Lx.phantom);
        expect(phantom['CharmInstanceID'], Lx.buddyInstanceA);
        expect(phantom['CharmID'], Fx.neoFrontierBuddy);
        expect(phantom['CharmLevelID'], Fx.neoFrontierBuddyL1);
        final vandal = gunRaw(out, Lx.vandal);
        expect(vandal.containsKey('CharmInstanceID'), isFalse);
        expect(vandal.containsKey('CharmID'), isFalse);
        expect(vandal.containsKey('CharmLevelID'), isFalse);
        expect(vandal['SkinID'], Fx.vandalStandard);

        final loadout = Loadout.fromJson(out);
        expect(change.isReflectedIn(loadout), isTrue);
        expect(loadout.usedBuddyInstances, {Lx.buddyInstanceA});
      },
    );

    test('a second copy leaves the first gun alone', () {
      final out = const EquipBuddy(
        weaponId: Lx.phantom,
        buddyId: Fx.neoFrontierBuddy,
        buddyLevelId: Fx.neoFrontierBuddyL1,
        instanceId: Lx.buddyInstanceB,
      ).appliedTo(raw);
      expect(gunRaw(out, Lx.vandal)['CharmInstanceID'], Lx.buddyInstanceA);
      expect(gunRaw(out, Lx.phantom)['CharmInstanceID'], Lx.buddyInstanceB);
    });

    test('melee never takes a buddy', () {
      expect(
        () => const EquipBuddy(
          weaponId: Lx.melee,
          buddyId: Fx.neoFrontierBuddy,
          buddyLevelId: Fx.neoFrontierBuddyL1,
          instanceId: Lx.buddyInstanceB,
        ).appliedTo(raw),
        throwsA(
          isA<LoadoutEditException>().having(
            (e) => e.error,
            'error',
            LoadoutEditError.meleeBuddy,
          ),
        ),
      );
    });

    test('RemoveBuddy deletes the three Charm keys', () {
      const change = RemoveBuddy(weaponId: Lx.vandal);
      final out = change.appliedTo(raw);
      final vandal = gunRaw(out, Lx.vandal);
      for (final key in LoadoutKeys.charmKeys) {
        expect(vandal.containsKey(key), isFalse);
      }
      expect(vandal['Attachments'], isEmpty);
      expect(change.isReflectedIn(Loadout.fromJson(out)), isTrue);
    });
  });

  group('identity', () {
    test('card, title, border, hide level, incognito', () {
      final out = LoadoutChange.all(const [
        SetPlayerCard(Lx.cardDefault),
        SetPlayerTitle.none(),
        SetLevelBorder('ABC'),
        SetHideAccountLevel(true),
        SetIncognito(true),
      ]).appliedTo(raw);
      final id = asMap(out['Identity'])!;
      expect(id['PlayerCardID'], Lx.cardDefault);
      expect(id['PlayerTitleID'], SpecialIds.noTitle);
      expect(id['PreferredLevelBorderID'], 'abc');
      expect(id['HideAccountLevel'], isTrue);
      expect(id['AccountLevel'], 0, reason: 'unknown identity keys kept');
      expect(out['Incognito'], isTrue);

      final auto = const SetLevelBorder.auto().appliedTo(out);
      expect(
        asMap(auto['Identity'])!['PreferredLevelBorderID'],
        SpecialIds.autoLevelBorder,
      );
      expect(
        const SetLevelBorder.auto().isReflectedIn(Loadout.fromJson(auto)),
        isTrue,
      );
    });

    test('creates Identity when missing', () {
      final out = const SetPlayerCard(Lx.cardDefault)
          .appliedTo({'Guns': <Object?>[]});
      expect(asMap(out['Identity'])!['PlayerCardID'], Lx.cardDefault);
    });
  });

  group('expressions', () {
    test('sets one slot and keeps the order of the others', () {
      final change = SetExpression.spray(0, Lx.sprayB);
      final out = change.appliedTo(raw);
      final list = asMapList(out['ActiveExpressions']);
      expect(list, hasLength(4));
      expect(list[0], {'TypeID': ItemTypeIds.spray, 'AssetID': Lx.sprayB});
      expect(list[1]['AssetID'], Lx.sprayA);
      expect(list[3]['AssetID'], Lx.sprayB);
      expect(change.isReflectedIn(Loadout.fromJson(out)), isTrue);

      final flex = SetExpression.flex(3, Fx.flexOra).appliedTo(out);
      expect(asMapList(flex['ActiveExpressions'])[3], {
        'TypeID': ItemTypeIds.flex,
        'AssetID': Fx.flexOra,
      });
    });

    test('pads missing slots with the null spray', () {
      final out = SetExpression.spray(
        2,
        Lx.sprayA,
      ).appliedTo({'Guns': <Object?>[], 'ActiveExpressions': null});
      final list = asMapList(out['ActiveExpressions']);
      expect(list, hasLength(3));
      expect(list[0]['AssetID'], SpecialIds.nullSpray);
      expect(list[1]['AssetID'], SpecialIds.nullSpray);
      expect(list[2]['AssetID'], Lx.sprayA);
    });

    test('rejects slots outside the wheel', () {
      expect(
        () => SetExpression.spray(4, Lx.sprayA).appliedTo(raw),
        throwsA(isA<LoadoutEditException>()),
      );
      expect(
        () => SetExpression.spray(-1, Lx.sprayA).appliedTo(raw),
        throwsA(isA<LoadoutEditException>()),
      );
    });
  });

  group('composite', () {
    test('strict: one failure fails the batch', () {
      expect(
        () => LoadoutChange.all(const [
          SetPlayerCard(Lx.cardDefault),
          RemoveBuddy(weaponId: 'unknown'),
        ]).appliedTo(raw),
        throwsA(isA<LoadoutEditException>()),
      );
    });

    test('lenient: inapplicable changes are skipped without residue', () {
      const change = CompositeChange([
        SetPlayerCard(Lx.cardDefault),
        RemoveBuddy(weaponId: 'unknown'),
        EquipBuddy(
          weaponId: Lx.melee,
          buddyId: 'b',
          buddyLevelId: 'bl',
          instanceId: 'i',
        ),
        SetIncognito(true),
      ], skipInapplicable: true);
      final out = change.appliedTo(raw);
      expect(asMap(out['Identity'])!['PlayerCardID'], Lx.cardDefault);
      expect(out['Incognito'], isTrue);
      expect(gunRaw(out, Lx.melee).containsKey('CharmID'), isFalse);
      expect(change.isReflectedIn(Loadout.fromJson(out)), isTrue);
    });
  });
}
