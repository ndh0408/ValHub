import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/match_models.dart';
import 'package:valvn/core/domain/competitive/performance.dart';
import 'package:valvn/core/domain/competitive/streak.dart';

import 'competitive_test_utils.dart';

const _ascent = '/Game/Maps/Ascent/Ascent';
const _bind = '/Game/Maps/Duality/Duality';
const _jett = 'add6443a-41bd-e414-f6ad-e58d267f4e95';
const _sova = '320b2a48-4d9b-a075-30f1-1f93a9b638fa';

MatchDetails _load(String name) =>
    MatchDetails.fromJson(competitiveFixture(name));

/// A stat line with sensible defaults; times are UTC.
MatchStatLine _line(
  String id, {
  DateTime? at,
  MatchOutcome outcome = MatchOutcome.win,
  String queue = 'competitive',
  String? map = _ascent,
  String? agent = _jett,
  MatchModeKind mode = MatchModeKind.standard,
  int k = 10,
  int d = 10,
  int a = 2,
  int score = 4000,
  int rounds = 20,
  int? damage,
  int head = 0,
  int body = 0,
  int leg = 0,
  int fb = 0,
  int fd = 0,
  SideLine attack = SideLine.none,
  SideLine defense = SideLine.none,
  List<int>? multi,
}) => MatchStatLine(
  matchId: id,
  startedAt: at ?? DateTime.utc(2026, 9, 28, 12),
  outcome: outcome,
  queueId: queue,
  mapId: map,
  agentId: agent,
  mode: mode,
  kills: k,
  deaths: d,
  assists: a,
  score: score,
  rounds: rounds,
  damage: damage,
  headshots: head,
  bodyshots: body,
  legshots: leg,
  firstBloods: fb,
  firstDeaths: fd,
  attack: attack,
  defense: defense,
  multiKills: multi,
);

// ------------------------------------------------- synthetic P-14 builders

const _blue = [me, mate, 'a3', 'a4', 'a5'];
const _red = ['b1', 'b2', 'b3', 'b4', 'b5'];

Map<String, dynamic> _kill(
  int round,
  String killer,
  String victim,
  int roundTime,
) => {
  'round': round,
  'roundTime': roundTime,
  'gameTime': roundTime + round * 100000,
  'killer': killer,
  'victim': victim,
  'assistants': <String>[],
  'finishingDamage': {
    'damageType': 'Weapon',
    'damageItem': '9C82E19D-4575-0200-1A81-3EACF00CF872',
  },
};

Map<String, dynamic> _round(
  int n,
  String winner, {
  String? role,
  String? planter,
  String? defuser,
  String code = 'Elimination',
  String? firstBlood,
}) => {
  'roundNum': n,
  'roundResult': 'x',
  'roundResultCode': code,
  'winningTeam': winner,
  'winningTeamRole': ?role,
  'bombPlanter': ?planter,
  'bombDefuser': ?defuser,
  'firstBloodPlayer': ?firstBlood,
  'playerStats': [
    for (final p in [..._blue, ..._red])
      {'subject': p, 'damage': <Object>[], 'score': 0},
  ],
};

/// A 5v5 competitive match seen by [me] (Blue). [kills] is the top-level
/// kill feed; [myKills] / [myDeaths] are the official totals.
Map<String, dynamic> _match({
  required List<Map<String, dynamic>> rounds,
  required List<Map<String, dynamic>> kills,
  required int myKills,
  required int myDeaths,
  bool blueWon = true,
}) => {
  'matchInfo': {
    'matchId': 'D5000000-0000-4000-8000-000000000005',
    'mapId': _ascent,
    'queueID': 'competitive',
    'gameMode': '/Game/GameModes/Bomb/BombGameMode.BombGameMode_C',
    'gameStartMillis': DateTime.utc(2026, 9, 28, 12).millisecondsSinceEpoch,
    'gameLengthMillis': 1200000,
    'isCompleted': true,
    'completionState': 'Completed',
    'provisioningFlowID': 'Matchmaking',
  },
  'players': [
    for (final p in _blue)
      {
        'subject': p,
        'teamId': 'Blue',
        'characterId': _jett,
        'stats': {
          'score': p == me ? 4000 : 2000,
          'roundsPlayed': rounds.length,
          'kills': p == me ? myKills : 0,
          'deaths': p == me ? myDeaths : 0,
          'assists': 0,
        },
      },
    for (final p in _red)
      {
        'subject': p,
        'teamId': 'Red',
        'characterId': _sova,
        'stats': {
          'score': 1000,
          'roundsPlayed': rounds.length,
          'kills': 0,
          'deaths': 0,
          'assists': 0,
        },
      },
  ],
  'teams': [
    {
      'teamId': 'Blue',
      'won': blueWon,
      'roundsPlayed': rounds.length,
      'roundsWon': rounds.where((r) => r['winningTeam'] == 'Blue').length,
    },
    {
      'teamId': 'Red',
      'won': !blueWon,
      'roundsPlayed': rounds.length,
      'roundsWon': rounds.where((r) => r['winningTeam'] == 'Red').length,
    },
  ],
  'roundResults': rounds,
  'kills': kills,
};

void main() {
  group('roundSideOf', () {
    test('winningTeamRole first, then the planter, then the defuser', () {
      final d = _load('match_competitive');
      // Round 0: role says Blue defended.
      expect(roundSideOf(d, d.rounds[0], 'Blue'), TeamRole.defender);
      expect(roundSideOf(d, d.rounds[0], 'Red'), TeamRole.attacker);
      // Round 1: Red won as attacker.
      expect(roundSideOf(d, d.rounds[1], 'Red'), TeamRole.attacker);
      expect(roundSideOf(d, d.rounds[1], 'Blue'), TeamRole.defender);
      // Round 2 has no role: enemy2 (Red) planted, so Red attacked.
      expect(d.rounds[2].winningTeamRole, isNull);
      expect(roundSideOf(d, d.rounds[2], 'Red'), TeamRole.attacker);
      expect(roundSideOf(d, d.rounds[2], 'Blue'), TeamRole.defender);
      expect(roundSideOf(d, d.rounds[2], null), isNull);
    });

    test('the defuser proves the defending side when nobody planted', () {
      final d = MatchDetails.fromJson(
        _match(
          rounds: [_round(0, 'Blue', defuser: me, code: 'Defuse')],
          kills: [_kill(0, me, 'b1', 1000)],
          myKills: 1,
          myDeaths: 0,
        ),
      );
      expect(roundSideOf(d, d.rounds.single, 'Blue'), TeamRole.defender);
      expect(roundSideOf(d, d.rounds.single, 'Red'), TeamRole.attacker);
    });

    test('an elimination or timer round without a role stays unknown', () {
      final d = MatchDetails.fromJson(
        _match(
          rounds: [
            _round(0, 'Blue'),
            _round(1, 'Blue', code: ''),
          ],
          kills: [_kill(0, me, 'b1', 1000)],
          myKills: 1,
          myDeaths: 0,
        ),
      );
      expect(roundSideOf(d, d.rounds[0], 'Blue'), isNull);
      expect(roundSideOf(d, d.rounds[1], 'Blue'), isNull);
    });
  });

  group('MatchStatLine.fromDetails', () {
    test('competitive fixture: stats, sides and multi-kills', () {
      final l = MatchStatLine.fromDetails(_load('match_competitive'), me)!;
      expect(l.matchId, compMatch);
      expect(l.startedAt, DateTime.utc(2026, 9, 28, 4));
      expect(l.outcome, MatchOutcome.win);
      expect(l.queueId, 'competitive');
      expect(l.mapId, _ascent);
      expect(l.agentId, _jett);
      expect(l.mode, MatchModeKind.standard);
      expect(l.isRoundBased, isTrue);
      expect((l.kills, l.deaths, l.assists), (3, 1, 0));
      expect((l.score, l.rounds), (600, 3));
      // 150 + 150 (round 0) + 150 + 60 (round 2) to enemies.
      expect(l.damage, 510);
      expect((l.headshots, l.bodyshots, l.legshots), (2, 5, 1));
      expect((l.firstBloods, l.firstDeaths), (2, 1));
      // All three rounds were played on defense (role, role, planter).
      expect(l.attack.isEmpty, isTrue);
      expect(l.defense.rounds, 3);
      expect(l.defense.won, 2);
      expect((l.defense.kills, l.defense.deaths), (3, 1));
      expect((l.defense.firstBloods, l.defense.firstDeaths), (2, 1));
      // Two kills in round 0, nothing bigger.
      expect(l.multiKills, [1, 0, 0, 0]);
    });

    test('the other team of the same match played the other side', () {
      final l = MatchStatLine.fromDetails(_load('match_competitive'), enemy1)!;
      expect(l.outcome, MatchOutcome.loss);
      expect(l.defense.isEmpty, isTrue);
      expect(l.attack.rounds, 3);
      expect(l.attack.won, 1); // only round 1
    });

    test('without winningTeamRole only planted rounds have a side', () {
      final json = competitiveFixtureMap('match_competitive');
      for (final r in json['roundResults'] as List<dynamic>) {
        (r as Map<String, dynamic>).remove('winningTeamRole');
      }
      final l = MatchStatLine.fromDetails(MatchDetails.fromJson(json), me)!;
      // Round 0 ("eliminated", no plant) is unknown; rounds 1 and 2 have a
      // planter. Unknown is never guessed.
      expect(l.defense.rounds, 2);
      expect(l.attack.rounds, 0);
      expect(l.defense.won, 1); // round 2
    });

    test('Deathmatch: no rounds, no sides, no damage', () {
      final l = MatchStatLine.fromDetails(_load('match_deathmatch'), me)!;
      expect(l.mode, MatchModeKind.deathmatch);
      expect(l.isRoundBased, isFalse);
      expect(l.queueId, 'deathmatch');
      expect(l.damage, isNull);
      expect(l.attack.isEmpty && l.defense.isEmpty, isTrue);
      expect(l.multiKills, isNull);
      expect(l.outcome, MatchOutcome.loss);
      expect(l.score, 6000); // total score, never an ACS
    });

    test('Team Deathmatch and custom games', () {
      final tdm = MatchStatLine.fromDetails(_load('match_tdm'), me)!;
      expect(tdm.mode, MatchModeKind.teamDeathmatch);
      expect(tdm.isRoundBased, isFalse);
      final custom = MatchStatLine.fromDetails(_load('match_custom'), me)!;
      expect(custom.queueId, '');
      expect(custom.mode, MatchModeKind.standard);
    });

    test('nothing to count: spectator, stranger, unfinished, no start', () {
      final d = _load('match_competitive');
      expect(MatchStatLine.fromDetails(d, observer), isNull);
      expect(MatchStatLine.fromDetails(d, friend), isNull);
      expect(MatchStatLine.fromDetails(d, null), isNull);
      final unfinished = competitiveFixtureMap('match_competitive');
      (unfinished['matchInfo'] as Map<String, dynamic>)
        ..['isCompleted'] = false
        ..['completionState'] = '';
      expect(
        MatchStatLine.fromDetails(MatchDetails.fromJson(unfinished), me),
        isNull,
      );
      final noStart = competitiveFixtureMap('match_competitive');
      (noStart['matchInfo'] as Map<String, dynamic>).remove('gameStartMillis');
      expect(
        MatchStatLine.fromDetails(MatchDetails.fromJson(noStart), me),
        isNull,
      );
    });

    test('multi-kills: an ace, a 3K and a 4K are counted per round', () {
      final kills = [
        // Round 0: five kills = ace.
        for (var i = 0; i < 5; i++) _kill(0, me, _red[i], 1000 + i * 1000),
        // Round 1: three kills.
        for (var i = 0; i < 3; i++) _kill(1, me, _red[i], 1000 + i * 1000),
        // Round 2: four kills and my death.
        for (var i = 0; i < 4; i++) _kill(2, me, _red[i], 1000 + i * 1000),
        _kill(2, 'b5', me, 20000),
        // Round 3: one kill (not a multi-kill).
        _kill(3, me, 'b1', 1000),
      ];
      final d = MatchDetails.fromJson(
        _match(
          rounds: [
            _round(0, 'Blue', role: 'Attacker'),
            _round(1, 'Blue', role: 'Attacker'),
            _round(2, 'Red', role: 'Attacker'),
            _round(3, 'Blue', role: 'Attacker'),
          ],
          kills: kills,
          myKills: 13,
          myDeaths: 1,
        ),
      );
      final l = MatchStatLine.fromDetails(d, me)!;
      expect(l.multiKills, [0, 1, 1, 1]); // 3K, 4K, ace
      expect(l.attack.rounds, 3);
      expect(l.attack.won, 3);
      expect(l.attack.kills, 9);
      expect(l.defense.rounds, 1);
      expect((l.defense.kills, l.defense.deaths), (4, 1));
    });

    test('a kill feed that does not add up is not trusted', () {
      final d = MatchDetails.fromJson(
        _match(
          rounds: [_round(0, 'Blue', role: 'Attacker')],
          kills: [_kill(0, me, 'b1', 1000), _kill(0, me, 'b2', 2000)],
          myKills: 3, // the official total says 3, the feed only shows 2
          myDeaths: 0,
        ),
      );
      final l = MatchStatLine.fromDetails(d, me)!;
      expect(l.multiKills, isNull); // unknown, not [1, 0, 0, 0]
      // Rounds and who won them come from the round results: still known.
      expect(l.attack.rounds, 1);
      expect(l.attack.won, 1);
      // Per-side kills / deaths stay unknown too.
      expect(l.attack.kills, isNull);
      expect(l.attack.deaths, isNull);
    });

    test('team kills and self kills are not multi-kills', () {
      final d = MatchDetails.fromJson(
        _match(
          rounds: [_round(0, 'Blue', role: 'Attacker')],
          kills: [
            _kill(0, me, 'b1', 1000),
            _kill(0, me, mate, 2000), // a teammate: not an enemy kill
            _kill(0, me, me, 3000), // a suicide
          ],
          myKills: 1,
          myDeaths: 1,
        ),
      );
      final l = MatchStatLine.fromDetails(d, me)!;
      expect(l.multiKills, [0, 0, 0, 0]);
      expect(l.attack.kills, 1);
    });

    test('a match without a kill feed keeps rounds but not kills', () {
      final d = MatchDetails.fromJson(
        _match(
          rounds: [_round(0, 'Blue', role: 'Attacker')],
          kills: const [],
          myKills: 2,
          myDeaths: 1,
        ),
      );
      final l = MatchStatLine.fromDetails(d, me)!;
      expect(l.multiKills, isNull);
      expect(l.attack.rounds, 1);
      expect(l.attack.kills, isNull);
    });

    test('a surrendered match counts only the rounds actually played', () {
      final json = competitiveFixtureMap('match_competitive');
      (json['matchInfo'] as Map<String, dynamic>)['completionState'] =
          'Surrendered';
      json['teams'] = [
        {
          'teamId': 'Blue',
          'won': true,
          'roundsPlayed': 4,
          'roundsWon': 13,
          'numPoints': 2,
        },
        {
          'teamId': 'Red',
          'won': false,
          'roundsPlayed': 4,
          'roundsWon': 1,
          'numPoints': 1,
        },
      ];
      (json['roundResults'] as List<dynamic>).add({
        'roundNum': 3,
        'roundResult': 'Surrendered',
        'roundResultCode': 'Surrendered',
        'winningTeam': 'Blue',
        'playerStats': [
          {'subject': me, 'damage': <Object>[], 'score': 0},
        ],
      });
      final l = MatchStatLine.fromDetails(MatchDetails.fromJson(json), me)!;
      expect(l.outcome, MatchOutcome.win);
      expect(l.defense.rounds, 3); // the awarded round is not played
    });

    test('a summary line has no sides and no multi-kills', () {
      final summary = _load('match_competitive').summaryFor(me)!;
      final l = MatchStatLine.fromSummary(summary)!;
      expect(l.matchId, compMatch);
      expect((l.kills, l.deaths, l.rounds, l.score), (3, 1, 3, 600));
      expect(l.damage, 510);
      expect(l.attack.isEmpty && l.defense.isEmpty, isTrue);
      expect(l.multiKills, isNull);
      // A spectator has no result: nothing to count.
      final spectator = _load('match_competitive').summaryFor(observer)!;
      expect(MatchStatLine.fromSummary(spectator), isNull);
    });
  });

  group('PerfAggregate', () {
    test('empty', () {
      const a = PerfAggregate.empty;
      expect(a.isEmpty, isTrue);
      expect(a.winRate, isNull);
      expect(a.kd, isNull);
      expect(a.acs, isNull);
      expect(a.adr, isNull);
      expect(a.headshotRate, isNull);
      expect(a.hasSides, isFalse);
      expect(a.hasMultiKills, isFalse);
      expect(a.qualifies(), isFalse);
    });

    test('ACS is Σ score / Σ rounds, K/D over totals, HS% over hits', () {
      final a = PerfAggregate.of([
        _line('a', k: 20, d: 10, score: 6000, rounds: 20, head: 10, body: 30),
        _line(
          'b',
          outcome: MatchOutcome.loss,
          k: 10,
          d: 20,
          score: 2000,
          rounds: 10,
          body: 10,
        ),
      ]);
      expect(a.games, 2);
      expect((a.wins, a.losses, a.draws), (1, 1, 0));
      expect(a.winRate, 0.5);
      expect(a.acs, closeTo(8000 / 30, 1e-9));
      expect(a.kd, 1.0);
      expect(a.headshotRate, closeTo(10 / 50, 1e-9));
      expect(a.rounds, 30);
    });

    test('round-less modes count for results, never for per-round stats', () {
      final a = PerfAggregate.of([
        _line('a', score: 5000, rounds: 20),
        _line(
          'dm',
          queue: 'deathmatch',
          mode: MatchModeKind.deathmatch,
          k: 40,
          d: 10,
          score: 9000,
          rounds: 1,
        ),
        _line(
          'tdm',
          outcome: MatchOutcome.loss,
          queue: 'hurm',
          mode: MatchModeKind.teamDeathmatch,
          score: 9000,
          rounds: 1,
        ),
      ]);
      expect(a.games, 3);
      expect((a.wins, a.losses), (2, 1));
      expect(a.roundGames, 1);
      expect(a.acs, 250);
      expect(a.kd, 1.0); // 10 / 10 of the competitive match only
    });

    test('ADR only over matches that have damage data', () {
      final a = PerfAggregate.of([
        _line('a', rounds: 20, damage: 3200),
        _line('b', rounds: 10, damage: 1000),
        _line('c', rounds: 30),
      ]);
      expect(a.adr, closeTo(4200 / 30, 1e-9));
      expect(a.roundGames, 3);
    });

    test('draws are results but not part of the win rate', () {
      final a = PerfAggregate.of([
        _line('a'),
        _line('b', outcome: MatchOutcome.draw),
        _line('c', outcome: MatchOutcome.loss),
      ]);
      expect((a.wins, a.losses, a.draws), (1, 1, 1));
      expect(a.winRate, 0.5);
    });

    test('sides add up; per-side K/D only from trusted kill feeds', () {
      final a = PerfAggregate.of([
        _line(
          'a',
          attack: const SideLine(
            rounds: 12,
            won: 7,
            kills: 10,
            deaths: 8,
            firstBloods: 3,
            firstDeaths: 2,
          ),
          defense: const SideLine(
            rounds: 12,
            won: 5,
            kills: 6,
            deaths: 10,
            firstBloods: 1,
            firstDeaths: 4,
          ),
        ),
        // Second match: rounds known, kill feed not trusted.
        _line(
          'b',
          attack: const SideLine(rounds: 10, won: 4),
          defense: const SideLine(rounds: 8, won: 3),
        ),
      ]);
      expect(a.attack.rounds, 22);
      expect(a.attack.won, 11);
      expect(a.attack.winRate, 0.5);
      expect(a.defense.rounds, 20);
      expect(a.defense.won, 8);
      expect(a.defense.winRate, 0.4);
      // K/D and first bloods come from the trusted match only.
      expect(a.attack.feedRounds, 12);
      expect(a.attack.kd, closeTo(10 / 8, 1e-9));
      expect(a.defense.kd, closeTo(6 / 10, 1e-9));
      expect((a.attack.firstBloods, a.attack.firstDeaths), (3, 2));
      expect(a.hasSides, isTrue);
    });

    test('a side with no data is unknown, not zero', () {
      final a = PerfAggregate.of([_line('a')]);
      expect(a.attack.winRate, isNull);
      expect(a.attack.kd, isNull);
      expect(a.hasSides, isFalse);
    });

    test('multi-kills only count matches that know them', () {
      final a = PerfAggregate.of([
        _line('a', multi: const [4, 2, 1, 0]),
        _line('b', multi: const [1, 0, 0, 1]),
        _line('c'), // unknown
      ]);
      expect(a.multiGames, 2);
      expect((a.multi2, a.multi3, a.multi4, a.multi5), (5, 2, 1, 1));
      expect(a.multiKills3Plus, 4);
      expect(a.aces, 1);
      expect(a.hasMultiKills, isTrue);
    });

    test('first bloods per match use round-based matches', () {
      final a = PerfAggregate.of([
        _line('a', fb: 4, fd: 2),
        _line('b', fb: 2, fd: 6),
        _line('dm', mode: MatchModeKind.deathmatch, rounds: 1, fb: 9),
      ]);
      expect(a.firstBloods, 6);
      expect(a.firstBloodsPerGame, 3);
      expect(a.firstDeathsPerGame, 4);
    });

    test('the minimum sample is 3 matches by default', () {
      expect(kPerfMinGames, 3);
      expect(PerfAggregate.of([_line('a'), _line('b')]).qualifies(), isFalse);
      expect(
        PerfAggregate.of([_line('a'), _line('b'), _line('c')]).qualifies(),
        isTrue,
      );
      expect(PerfAggregate.of([_line('a')]).qualifies(1), isTrue);
    });
  });

  group('grouping', () {
    final lines = [
      _line('1', agent: _jett, map: _ascent),
      _line('2', agent: _jett, map: _ascent, outcome: MatchOutcome.loss),
      _line('3', agent: _sova, map: _bind),
      _line('4', agent: _jett, map: _bind, queue: 'unrated'),
      _line('5', agent: null, map: null, queue: ''),
    ];

    test('by agent: most played first, no agent left out', () {
      final g = groupByAgent(lines);
      expect(g.map((e) => e.key), [_jett, _sova]);
      expect(g.first.games, 3);
      expect(g.first.aggregate.wins, 2);
    });

    test('by map: case-insensitive keys, ties broken by key', () {
      final g = groupByMap([...lines, _line('6', map: _ascent.toUpperCase())]);
      expect(g.map((e) => e.key), [_ascent.toLowerCase(), _bind.toLowerCase()]);
      expect(g.first.games, 3);
      expect(g.last.games, 2);
    });

    test('by queue: custom games are the empty key', () {
      final g = groupByQueue(lines);
      expect(g.map((e) => e.key), ['competitive', '', 'unrated']);
      expect(g.first.games, 3);
    });

    test('the order never depends on the input order', () {
      final a = groupByAgent(lines).map((e) => e.key).toList();
      final b = groupByAgent(lines.reversed).map((e) => e.key).toList();
      expect(b, a);
    });
  });

  group('filter and windows', () {
    final lines = [
      _line('new', at: DateTime.utc(2026, 9, 28, 12), map: _ascent),
      _line(
        'mid',
        at: DateTime.utc(2026, 9, 20, 12),
        map: _bind,
        queue: 'unrated',
      ),
      _line('old', at: DateTime.utc(2026, 8, 1, 12), agent: _sova),
    ];

    test('sortedNewestFirst breaks ties by match id', () {
      final t = DateTime.utc(2026, 9, 28);
      final sorted = sortedNewestFirst([
        _line('b', at: t),
        _line('a', at: t),
        _line('c', at: t.add(const Duration(hours: 1))),
      ]);
      expect(sorted.map((l) => l.matchId), ['c', 'a', 'b']);
    });

    test('PerfFilter combines queue, map, agent and since', () {
      expect(const PerfFilter().isEmpty, isTrue);
      expect(const PerfFilter().apply(lines), hasLength(3));
      expect(
        const PerfFilter(queueId: 'unrated').apply(lines).map((l) => l.matchId),
        ['mid'],
      );
      expect(
        const PerfFilter(mapId: '/GAME/MAPS/ASCENT/ASCENT')
            .apply(lines)
            .map((l) => l.matchId),
        ['new', 'old'],
      );
      expect(
        PerfFilter(agentId: _sova.toUpperCase()).apply(lines).single.matchId,
        'old',
      );
      expect(
        PerfFilter(since: DateTime.utc(2026, 9, 20, 12))
            .apply(lines)
            .map((l) => l.matchId),
        ['new', 'mid'],
      );
      final f = const PerfFilter().copyWith(queueId: () => 'competitive');
      expect(f.queueId, 'competitive');
      expect(f.copyWith(queueId: () => null).queueId, isNull);
    });

    test('withinLast uses instants relative to the injected now', () {
      final now = DateTime.utc(2026, 9, 29, 12);
      final week = withinLast(lines, now: now, window: const Duration(days: 7));
      expect(week.map((l) => l.matchId), ['new']);
      final month = withinLast(
        lines,
        now: now,
        window: const Duration(days: 30),
      );
      expect(month.map((l) => l.matchId), ['new', 'mid']);
      // A local now is normalised.
      expect(
        withinLast(lines, now: now.toLocal(), window: const Duration(days: 30)),
        hasLength(2),
      );
    });

    test('streakOfLines follows the newest matches in any input order', () {
      final s = streakOfLines([
        _line('c', at: DateTime.utc(2026, 9, 26), outcome: MatchOutcome.loss),
        _line('a', at: DateTime.utc(2026, 9, 28)),
        _line('b', at: DateTime.utc(2026, 9, 27)),
      ]);
      expect(s, const Streak(StreakKind.win, 2));
      expect(streakOfLines(const []), isNull);
    });
  });

  group('trends', () {
    // 2026-09-28 is a Monday.
    DateTime toLocalUtc(DateTime utc) => utc; // "the device is on UTC"

    test('day buckets by the local date, oldest first', () {
      final points = trendOf(
        [
          _line('a', at: DateTime.utc(2026, 9, 28, 9)),
          _line('b', at: DateTime.utc(2026, 9, 28, 20)),
          _line('c', at: DateTime.utc(2026, 9, 26, 9)),
        ],
        bucket: TrendBucket.day,
        toLocal: toLocalUtc,
      );
      expect(points.map((p) => p.start), [
        DateTime.utc(2026, 9, 26),
        DateTime.utc(2026, 9, 28),
      ]);
      expect(points.map((p) => p.aggregate.games), [1, 2]);
    });

    test('the injected zone decides which day a late match belongs to', () {
      final late = _line('a', at: DateTime.utc(2026, 9, 28, 22));
      DateTime plus7(DateTime utc) => utc.add(const Duration(hours: 7));
      DateTime minus5(DateTime utc) => utc.subtract(const Duration(hours: 5));
      expect(
        trendOf([late], bucket: TrendBucket.day, toLocal: plus7).single.start,
        DateTime.utc(2026, 9, 29),
      );
      expect(
        trendOf([late], bucket: TrendBucket.day, toLocal: minus5).single.start,
        DateTime.utc(2026, 9, 28),
      );
    });

    test('weeks start on Monday and months on the 1st', () {
      final lines = [
        _line('sun', at: DateTime.utc(2026, 9, 27, 12)), // Sunday
        _line('mon', at: DateTime.utc(2026, 9, 28, 12)), // Monday
        _line('tue', at: DateTime.utc(2026, 9, 29, 12)),
        _line('oct', at: DateTime.utc(2026, 10, 1, 12)),
      ];
      final weeks = trendOf(
        lines,
        bucket: TrendBucket.week,
        toLocal: toLocalUtc,
      );
      expect(weeks.map((p) => p.start), [
        DateTime.utc(2026, 9, 21),
        DateTime.utc(2026, 9, 28),
      ]);
      expect(weeks.map((p) => p.aggregate.games), [1, 3]);
      final months = trendOf(
        lines,
        bucket: TrendBucket.month,
        toLocal: toLocalUtc,
      );
      expect(months.map((p) => p.start), [
        DateTime.utc(2026, 9),
        DateTime.utc(2026, 10),
      ]);
      expect(months.map((p) => p.aggregate.games), [3, 1]);
    });

    test('a daylight-saving day is still one day (no 23 h drift)', () {
      // Europe/Berlin springs forward on 2026-03-29: model it as +1 h before
      // 01:00 UTC and +2 h after.
      DateTime berlin(DateTime utc) => utc.add(
        Duration(hours: utc.isBefore(DateTime.utc(2026, 3, 29, 1)) ? 1 : 2),
      );
      final points = trendOf(
        [
          _line(
            'a',
            at: DateTime.utc(2026, 3, 28, 23, 30),
          ), // 00:30 on the 29th
          _line('b', at: DateTime.utc(2026, 3, 29, 20)), // 22:00 on the 29th
          _line('c', at: DateTime.utc(2026, 3, 30, 5)),
        ],
        bucket: TrendBucket.day,
        toLocal: berlin,
      );
      expect(points.map((p) => p.start), [
        DateTime.utc(2026, 3, 29),
        DateTime.utc(2026, 3, 30),
      ]);
      expect(points.first.aggregate.games, 2);
    });

    test('suggestTrendBucket fits the span of the ledger', () {
      DateTime t(int days) =>
          DateTime.utc(2026, 9, 1).add(Duration(days: days));
      expect(
        suggestTrendBucket(const [], toLocal: toLocalUtc),
        TrendBucket.day,
      );
      expect(
        suggestTrendBucket([
          _line('a', at: t(0)),
          _line('b', at: t(14)),
        ], toLocal: toLocalUtc),
        TrendBucket.day,
      );
      expect(
        suggestTrendBucket([
          _line('a', at: t(0)),
          _line('b', at: t(15)),
        ], toLocal: toLocalUtc),
        TrendBucket.week,
      );
      expect(
        suggestTrendBucket([
          _line('a', at: t(0)),
          _line('b', at: t(121)),
        ], toLocal: toLocalUtc),
        TrendBucket.month,
      );
    });

    test('qualifiedPoints applies the minimum sample per bucket', () {
      final points = trendOf(
        [
          _line('a', at: DateTime.utc(2026, 9, 28, 1)),
          _line('b', at: DateTime.utc(2026, 9, 28, 2)),
          _line('c', at: DateTime.utc(2026, 9, 28, 3)),
          _line('d', at: DateTime.utc(2026, 9, 29, 3)),
        ],
        bucket: TrendBucket.day,
        toLocal: toLocalUtc,
      );
      expect(points, hasLength(2));
      expect(qualifiedPoints(points), hasLength(1));
      expect(qualifiedPoints(points, minGames: 1), hasLength(2));
    });

    test('metricOf reads each metric or null', () {
      final a = PerfAggregate.of([
        _line(
          'a',
          k: 10,
          d: 5,
          score: 4000,
          rounds: 20,
          damage: 3000,
          head: 1,
          body: 3,
        ),
      ]);
      expect(metricOf(a, PerfMetric.winRate), 1.0);
      expect(metricOf(a, PerfMetric.kd), 2.0);
      expect(metricOf(a, PerfMetric.acs), 200);
      expect(metricOf(a, PerfMetric.adr), 150);
      expect(metricOf(a, PerfMetric.headshotRate), 0.25);
      expect(metricOf(PerfAggregate.empty, PerfMetric.acs), isNull);
    });
  });

  group('currentStreak', () {
    test('runs of wins or losses from the newest match', () {
      expect(
        currentStreak(const [
          MatchOutcome.win,
          MatchOutcome.win,
          MatchOutcome.loss,
        ]),
        const Streak(StreakKind.win, 2),
      );
      expect(
        currentStreak(const [MatchOutcome.loss, MatchOutcome.win]),
        const Streak(StreakKind.loss, 1),
      );
    });

    test('a draw ends the walk; unknown results are skipped', () {
      expect(
        currentStreak(const [MatchOutcome.draw, MatchOutcome.win]),
        isNull,
      );
      expect(
        currentStreak(const [
          MatchOutcome.win,
          MatchOutcome.draw,
          MatchOutcome.win,
        ]),
        const Streak(StreakKind.win, 1),
      );
      expect(
        currentStreak(const [
          MatchOutcome.unknown,
          MatchOutcome.win,
          MatchOutcome.unknown,
          MatchOutcome.win,
        ]),
        const Streak(StreakKind.win, 2),
      );
      expect(currentStreak(const [MatchOutcome.unknown]), isNull);
      expect(currentStreak(const []), isNull);
    });

    test('value semantics', () {
      expect(const Streak(StreakKind.win, 3), const Streak(StreakKind.win, 3));
      expect(
        const Streak(StreakKind.win, 3) == const Streak(StreakKind.loss, 3),
        isFalse,
      );
      expect(const Streak(StreakKind.win, 3).toString(), contains('win'));
    });
  });
}
