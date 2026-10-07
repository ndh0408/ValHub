import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/round_economy.dart';

const _me = 'aaaaaaaa-0000-4000-8000-000000000001';

String _p(String team, int i) =>
    '${team == 'Blue' ? 'b' : 'c'}${i.toString().padLeft(7, '0')}-0000-4000-8000-000000000000';

/// A competitive match where every round lists each player's loadout
/// ([blue] / [red] per round, per player) and [blueWins] says who won.
MatchDetails _match({
  required List<int> blue,
  required List<int> red,
  required List<bool> blueWins,
  String queue = 'competitive',
  int redPlayers = 5,
}) {
  final players = [
    for (var i = 0; i < 5; i++) (i == 0 ? _me : _p('Blue', i), 'Blue'),
    for (var i = 0; i < redPlayers; i++) (_p('Red', i), 'Red'),
  ];
  return MatchDetails.fromJson({
    'matchInfo': {
      'matchId': 'eeeeeeee-0000-4000-8000-000000000001',
      'mapId': '/Game/Maps/Ascent/Ascent',
      'queueID': queue,
      'gameMode': '/Game/GameModes/Bomb/BombGameMode.BombGameMode_C',
      'isCompleted': true,
      'gameStartMillis': 1790000000000,
    },
    'players': [
      for (final (id, team) in players)
        {
          'subject': id,
          'teamId': team,
          'characterId': 'add6443a-41bd-e414-f6ad-e58d267f4e95',
          'stats': {'score': 1000, 'roundsPlayed': blue.length},
        },
    ],
    'teams': [
      {'teamId': 'Blue', 'won': true},
      {'teamId': 'Red', 'won': false},
    ],
    'roundResults': [
      for (var r = 0; r < blue.length; r++)
        {
          'roundNum': r,
          'winningTeam': blueWins[r] ? 'Blue' : 'Red',
          'roundResultCode': 'Elimination',
          'playerEconomies': [
            for (final (id, team) in players)
              {
                'subject': id,
                'loadoutValue': team == 'Blue' ? blue[r] : red[r],
              },
          ],
        },
    ],
  }, matchId: 'eeeeeeee-0000-4000-8000-000000000001');
}

void main() {
  test(
    'buy type by credits per player; the first round of a half is pistol',
    () {
      expect(buyTypeOf(loadout: 4000, players: 5), BuyType.eco);
      expect(buyTypeOf(loadout: 5000, players: 5), BuyType.semiEco);
      expect(buyTypeOf(loadout: 12000, players: 5), BuyType.semiBuy);
      expect(buyTypeOf(loadout: 20000, players: 5), BuyType.fullBuy);
      // Four players carrying 4,000 each is still a full buy.
      expect(buyTypeOf(loadout: 16000, players: 4), BuyType.fullBuy);
      expect(buyTypeOf(loadout: 0, players: 0), BuyType.eco);
      expect(
        buyTypeOf(loadout: 25000, players: 5, pistol: true),
        BuyType.pistol,
      );
      expect(isPistolRound(0, 12), isTrue);
      expect(isPistolRound(12, 12), isTrue);
      expect(isPistolRound(24, 12), isFalse, reason: 'overtime');
      expect(isPistolRound(4, 4), isTrue, reason: 'Swiftplay second half');
    },
  );

  test('round buys of both teams, the perspective team first', () {
    final m = _match(
      blue: [800, 4500],
      red: [800, 900],
      blueWins: [true, true],
      redPlayers: 4,
    );
    final second = roundBuysOf(m, m.playedRounds[1], myTeam: 'Blue');
    expect(second.mine!.loadout, 22500);
    expect(second.mine!.players, 5);
    expect(second.mine!.type, BuyType.fullBuy);
    expect(second.theirs!.loadout, 3600);
    expect(second.theirs!.players, 4);
    expect(second.theirs!.type, BuyType.eco);
    expect(
      roundBuysOf(m, m.playedRounds.first, myTeam: 'Blue').mine!.type,
      BuyType.pistol,
    );
  });

  test('the record by own buy type counts played and won rounds', () {
    final m = _match(
      blue: [800, 300, 4500, 4500, 3000],
      red: [800, 4500, 4500, 600, 4500],
      blueWins: [false, false, true, true, true],
    );
    final record = economyRecordOf(m, puuid: _me);
    expect(record.keys, [
      BuyType.pistol,
      BuyType.eco,
      BuyType.semiBuy,
      BuyType.fullBuy,
    ]);
    expect(
      (record[BuyType.pistol]!.won, record[BuyType.pistol]!.played),
      (0, 1),
    );
    expect((record[BuyType.eco]!.won, record[BuyType.eco]!.played), (0, 1));
    expect(
      (record[BuyType.fullBuy]!.won, record[BuyType.fullBuy]!.played),
      (2, 2),
    );
    expect(record[BuyType.semiBuy]!.winRate, 1);
  });

  test('no economy: Spike Rush, missing loadouts or a spectator', () {
    final rush = _match(
      blue: [800, 4500],
      red: [800, 4500],
      blueWins: [true, false],
      queue: 'spikerush',
    );
    expect(hasBuyPhase(rush), isFalse);
    expect(economyRecordOf(rush, puuid: _me), isEmpty);
    final m = _match(blue: [800], red: [800], blueWins: [true]);
    expect(economyRecordOf(m, puuid: 'not-in-the-match'), isEmpty);
    final empty = MatchDetails.fromJson({
      'matchInfo': {
        'matchId': 'x',
        'queueID': 'competitive',
        'isCompleted': true,
      },
      'players': [
        {
          'subject': _me,
          'teamId': 'Blue',
          'stats': {'roundsPlayed': 1},
        },
      ],
      'roundResults': [
        {'roundNum': 0, 'winningTeam': 'Blue'},
      ],
    });
    expect(
      roundBuysOf(empty, empty.playedRounds.single, myTeam: 'Blue').mine,
      isNull,
    );
    expect(economyRecordOf(empty, puuid: _me), isEmpty);
  });
}
