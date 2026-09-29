import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/riot/riot_ids.dart';

import '../economy/economy_fixtures.dart';
import 'loadout_fixtures.dart';

void main() {
  group('Loadout.fromJson', () {
    test('reads guns, identity, expressions and flags (ids lowercased)', () {
      final l = Loadout.fromJson(loadoutJson(incognito: true));
      expect(l.subject, Lx.puuid);
      expect(l.version, 25);
      expect(l.guns, hasLength(4));
      final vandal = l.gun(Lx.vandal.toUpperCase())!;
      expect(vandal.weaponId, Lx.vandal);
      expect(vandal.skinId, Fx.vandalStandard);
      expect(vandal.charmInstanceId, Lx.buddyInstanceA);
      expect(vandal.charmId, Fx.neoFrontierBuddy);
      expect(vandal.hasBuddy, isTrue);
      expect(l.gun(Lx.melee)!.hasBuddy, isFalse);
      expect(l.gun(Lx.melee)!.isMelee, isTrue);

      expect(l.identity.playerCardId, Fx.cardNgoiSang);
      expect(l.identity.playerTitleId, Fx.titleTaiLoc);
      expect(l.identity.isAutoLevelBorder, isTrue);
      expect(l.identity.hideAccountLevel, isFalse);
      expect(l.incognito, isTrue);

      expect(l.expressions, hasLength(4));
      expect(l.expression(0), const Expression.flex(Fx.flexOra));
      expect(l.expression(0)!.isFlex, isTrue);
      expect(l.expression(1), const Expression.spray(Lx.sprayA));
      expect(l.expression(2)!.isEmpty, isTrue);
      expect(l.expression(4), isNull);
      expect(l.expression(-1), isNull);
    });

    test('buddy instance helpers', () {
      final l = Loadout.fromJson(loadoutJson());
      expect(l.usedBuddyInstances, {Lx.buddyInstanceA});
      expect(
        l.weaponWithBuddyInstance(Lx.buddyInstanceA.toUpperCase()),
        Lx.vandal,
      );
      expect(l.weaponWithBuddyInstance(Lx.buddyInstanceB), isNull);
    });

    test('never throws on garbage and keeps expression positions', () {
      expect(Loadout.fromJson(null).guns, isEmpty);
      expect(Loadout.fromJson('<html>Just a moment…</html>').guns, isEmpty);
      final l = Loadout.fromJson({
        'Version': '7',
        'Guns': [
          null,
          'x',
          {'SkinID': 'no-weapon-id'},
          {'ID': Lx.vandal, 'SkinID': ''},
          {'ID': Lx.vandal, 'SkinID': 'duplicate'},
        ],
        'ActiveExpressions': [
          'garbage',
          {'TypeID': ItemTypeIds.spray, 'AssetID': Lx.sprayA},
        ],
        'Identity': 'nope',
        'Incognito': 'true',
      });
      expect(l.version, 7);
      expect(l.guns, hasLength(1));
      expect(l.guns.single.skinId, isNull);
      expect(l.expressions, [null, const Expression.spray(Lx.sprayA)]);
      expect(l.identity.playerCardId, isNull);
      expect(l.identity.titleOrNone, SpecialIds.noTitle);
      expect(l.incognito, isTrue);
    });

    test('Expression parses match-loadout spray selections', () {
      expect(
        Expression.fromJson({
          'SocketID': 'x',
          'SprayID': Lx.sprayA.toUpperCase(),
        }),
        const Expression.spray(Lx.sprayA),
      );
      expect(Expression.fromJson({'TypeID': ItemTypeIds.flex}), isNull);
      expect(
        const Expression(typeId: 'other', assetId: 'a').type,
        ExpressionType.unknown,
      );
    });
  });

  group('LoadoutSnapshot', () {
    test('deep-copies the raw map', () {
      final json = loadoutJson();
      final s = LoadoutSnapshot.fromJson(json, receivedAt: DateTime(2026));
      (json['Guns'] as List<dynamic>).clear();
      expect(s.loadout.guns, hasLength(4));
      expect(s.raw['Guns'], hasLength(4));
      expect(s.isValid, isTrue);
      expect(
        LoadoutSnapshot.fromJson({'x': 1}, receivedAt: DateTime(2026)).isValid,
        isFalse,
      );
      expect(s.raw['AgentMasteryCosmetics'], {
        'Unknown': [1, 2, 3],
      });
    });

    test('copyWith keeps data', () {
      final s = LoadoutSnapshot.fromJson(
        loadoutJson(),
        receivedAt: DateTime(2026),
      );
      final p = s.copyWith(isPending: true);
      expect(p.isPending, isTrue);
      expect(p.loadout, s.loadout);
      expect(identical(p.raw, s.raw), isTrue);
    });
  });
}
