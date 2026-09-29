import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/riot/riot_ids.dart';

import '../economy/economy_fixtures.dart';
import 'loadout_fixtures.dart';

Map<String, dynamic> socket(String id, String item, String type) => {
  'ID': id,
  'Item': {'ID': item, 'TypeID': type},
};

/// G-10 shape (EP §7.4) with uppercase ids like some Riot payloads.
Map<String, dynamic> coreGameLoadouts() => {
  'Loadouts': [
    {
      'CharacterID': Fx.jett.toUpperCase(),
      'Loadout': {
        'Subject': 'AAAA0000-0000-4000-8000-000000000001',
        'Sprays': {'SpraySelections': <Object?>[]},
        'Expressions': {
          'AESSelections': [
            {
              'SocketID': 's1',
              'AssetID': Lx.sprayA,
              'TypeID': ItemTypeIds.spray,
            },
            {
              'SocketID': 's2',
              'AssetID': Fx.flexOra,
              'TypeID': ItemTypeIds.flex,
            },
            {
              'SocketID': 's3',
              'AssetID': SpecialIds.nullSpray,
              'TypeID': ItemTypeIds.spray,
            },
            'garbage',
          ],
        },
        'Items': {
          Lx.vandal.toUpperCase(): {
            'ID': Lx.vandal.toUpperCase(),
            'TypeID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
            'Sockets': {
              LoadoutSocketIds.skin: socket(
                LoadoutSocketIds.skin,
                Fx.reaverVandal.toUpperCase(),
                'x',
              ),
              ItemTypeIds.skinLevel: socket(
                ItemTypeIds.skinLevel,
                Fx.reaverL3,
                'x',
              ),
              ItemTypeIds.skinChroma: socket(
                ItemTypeIds.skinChroma,
                Fx.reaverChroma2,
                'x',
              ),
              LoadoutSocketIds.buddy: socket(
                LoadoutSocketIds.buddy,
                Fx.neoFrontierBuddy,
                'x',
              ),
              ItemTypeIds.buddyLevel: socket(
                ItemTypeIds.buddyLevel,
                Fx.neoFrontierBuddyL1,
                'x',
              ),
            },
          },
          Lx.melee: {
            'ID': Lx.melee,
            'Sockets': {
              LoadoutSocketIds.skin: socket(
                LoadoutSocketIds.skin,
                Lx.meleeStandard,
                'x',
              ),
              'broken': 'x',
            },
          },
          'bad': 'value',
        },
      },
    },
    {'Loadout': 'nope'},
    null,
  ],
};

void main() {
  test('parses core-game sockets, expressions and agent', () {
    final m = MatchLoadouts.parse(coreGameLoadouts());
    expect(m.players, hasLength(1));
    final p = m.player('aaaa0000-0000-4000-8000-000000000001')!;
    expect(p.characterId, Fx.jett);
    final vandal = p.gun(Lx.vandal)!;
    expect(vandal.skinId, Fx.reaverVandal);
    expect(vandal.skinLevelId, Fx.reaverL3);
    expect(vandal.chromaId, Fx.reaverChroma2);
    expect(vandal.buddyId, Fx.neoFrontierBuddy);
    expect(vandal.buddyLevelId, Fx.neoFrontierBuddyL1);
    expect(vandal.hasBuddy, isTrue);
    final melee = p.gun(Lx.melee)!;
    expect(melee.skinId, Lx.meleeStandard);
    expect(melee.hasBuddy, isFalse);
    expect(p.sprayIds, [Lx.sprayA]);
    expect(p.flexIds, [Fx.flexOra]);
    expect(p.expressions, hasLength(3));
    expect(p.identity, isNull);
  });

  test('pregame shape (loadout objects) and old SpraySelections', () {
    final m = MatchLoadouts.parse({
      'Loadouts': [
        {
          'Subject': 'p1',
          'Sprays': {
            'SpraySelections': [
              {'SocketID': 'a', 'SprayID': Lx.sprayB, 'LevelID': 'l'},
            ],
          },
          'Items': <String, dynamic>{},
        },
      ],
    });
    expect(m.player('P1')!.sprayIds, [Lx.sprayB]);
  });

  test('merges identities from pregame and core-game matches', () {
    final pregame = MatchLoadouts.parseIdentities({
      'AllyTeam': {
        'TeamID': 'Red',
        'Players': [
          {
            'Subject': 'P1',
            'CharacterID': '',
            'PlayerIdentity': {
              'PlayerCardID': 'CARD1',
              'PlayerTitleID': 'TITLE1',
              'AccountLevel': '120',
              'PreferredLevelBorderID': '',
              'Incognito': true,
              'HideAccountLevel': true,
            },
          },
        ],
      },
      'EnemyTeam': null,
      'Teams': [
        {
          'TeamID': 'Red',
          'Players': [
            {'Subject': 'p1'},
          ],
        },
      ],
    });
    final p1 = pregame['p1']!;
    expect(p1.teamId, 'Red');
    expect(p1.characterId, isNull);
    expect(p1.identity.playerCardId, 'card1');
    expect(p1.identity.accountLevel, 120);
    expect(p1.identity.hideAccountLevel, isTrue);
    expect(p1.identity.isAutoLevelBorder, isTrue);
    expect(p1.incognito, isTrue);

    final core = MatchLoadouts.parse(
      {
        'Loadouts': [
          {
            'CharacterID': 'a1',
            'Loadout': {'Subject': 'p9'},
          },
        ],
      },
      matchJson: {
        'Players': [
          {
            'Subject': 'P9',
            'TeamID': 'Blue',
            'CharacterID': 'a1',
            'PlayerIdentity': {'PlayerCardID': 'c9', 'PlayerTitleID': 't9'},
          },
        ],
      },
    );
    final p9 = core.player('p9')!;
    expect(p9.teamId, 'Blue');
    expect(p9.playerCardId, 'c9');
    expect(p9.playerTitleId, 't9');
    expect(p9.incognito, isFalse);
  });

  test('never throws on garbage', () {
    expect(MatchLoadouts.parse(null).isEmpty, isTrue);
    expect(MatchLoadouts.parse('<html>').isEmpty, isTrue);
    expect(MatchLoadouts.parse({'Loadouts': 'x'}).isEmpty, isTrue);
    expect(MatchLoadouts.parseIdentities([1, 2]), isEmpty);
    expect(MatchLoadouts.empty.player('x'), isNull);
  });
}
