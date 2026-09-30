import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/scoreboard_order.dart';

import '../../../core/domain/competitive/competitive_test_utils.dart';

MatchDetails _load(String name) =>
    MatchDetails.fromJson(competitiveFixture(name));

void main() {
  group('team matches', () {
    late MatchDetails d;
    setUp(() => d = _load('match_competitive'));

    test('your team first, then the enemy, best player first', () {
      final sides = scoreboardOrder(d, me);
      expect(sides.map((s) => s.relation), [
        SideRelation.yours,
        SideRelation.enemy,
      ]);
      expect(sides.map((s) => s.teamId), ['Blue', 'Red']);
      expect(sides[0].players.map((p) => p.subject), [me, mate]);
      expect(sides[1].players.map((p) => p.subject), [enemy1, enemy2]);
      expect(sides.map((s) => s.freeForAll), [false, false]);
    });

    test('scores and outcomes of each team', () {
      final sides = scoreboardOrder(d, me);
      expect((sides[0].score, sides[0].outcome), (2, MatchOutcome.win));
      expect((sides[1].score, sides[1].outcome), (1, MatchOutcome.loss));
    });

    test('from the other team the order flips', () {
      final sides = scoreboardOrder(d, enemy2);
      expect(sides.map((s) => s.teamId), ['Red', 'Blue']);
      expect(sides.map((s) => s.relation), [
        SideRelation.yours,
        SideRelation.enemy,
      ]);
      expect(sides[0].outcome, MatchOutcome.loss);
    });

    test('a spectator or a stranger sees both teams as neutral', () {
      for (final who in [observer, friend, null]) {
        final sides = scoreboardOrder(d, who);
        expect(sides.map((s) => s.relation), [
          SideRelation.neutral,
          SideRelation.neutral,
        ]);
        expect(sides.map((s) => s.teamId), ['Blue', 'Red']);
      }
    });

    test('observers are not listed', () {
      final all = [
        for (final s in scoreboardOrder(d, me))
          ...s.players.map((p) => p.subject),
      ];
      expect(all, isNot(contains(observer)));
      expect(all, hasLength(4));
    });

    test('a surrender shows the rounds actually won, like the hero', () {
      final json = competitiveFixtureMap('match_competitive');
      (json['matchInfo'] as Map<String, dynamic>)['completionState'] =
          'Surrendered';
      json['teams'] = [
        {
          'teamId': 'Blue',
          'won': true,
          'roundsPlayed': 4,
          'roundsWon': 13, // includes the rounds awarded to the winner
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
      final s = MatchDetails.fromJson(json);
      final sides = scoreboardOrder(s, me);
      expect(sides[0].score, 2);
      expect(sides[0].score, s.resultFor(me).myScore);
      expect(sides[1].score, s.resultFor(me).otherScore);
    });

    test('nobody won (a draw): no outcome on either side', () {
      final json = competitiveFixtureMap('match_competitive');
      json['teams'] = [
        {'teamId': 'Blue', 'won': false, 'roundsWon': 12},
        {'teamId': 'Red', 'won': false, 'roundsWon': 12},
      ];
      final sides = scoreboardOrder(MatchDetails.fromJson(json), me);
      expect(sides.map((s) => s.outcome), [null, null]);
      expect(sides.map((s) => s.score), [12, 12]);
    });

    test('a team without a teams[] entry has no score or outcome', () {
      final json = competitiveFixtureMap('match_competitive')..['teams'] = null;
      final sides = scoreboardOrder(MatchDetails.fromJson(json), me);
      expect(sides, hasLength(2));
      expect(sides.map((s) => s.outcome), [null, null]);
      expect(sides.map((s) => s.score), [null, null]);
    });
  });

  test('Team Deathmatch scores are the team points', () {
    final sides = scoreboardOrder(_load('match_tdm'), me);
    expect(sides, hasLength(2));
    expect(sides.map((s) => s.score).toList()..sort(), [87, 100]);
    expect(sides.first.relation, SideRelation.yours);
    expect(sides.first.outcome, MatchOutcome.loss);
  });

  group('Deathmatch', () {
    test('one lobby ranked by kills, then score', () {
      final sides = scoreboardOrder(_load('match_deathmatch'), me);
      expect(sides, hasLength(1));
      final lobby = sides.single;
      expect(lobby.freeForAll, isTrue);
      expect(lobby.teamId, isNull);
      expect(lobby.relation, SideRelation.neutral);
      expect(lobby.score, isNull);
      expect(lobby.outcome, isNull);
      // 40 kills before my 25.
      expect(
        lobby.players.first.subject,
        'dddddddd-0000-4000-8000-000000000002',
      );
      expect(lobby.players.map((p) => p.subject), contains(me));
    });

    test('equal kills are ordered by score', () {
      final json = competitiveFixtureMap('match_deathmatch');
      final players = (json['players'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final p in players) {
        (p['stats'] as Map<String, dynamic>)['kills'] = 30;
      }
      (players[0]['stats'] as Map<String, dynamic>)['score'] = 100;
      (players[1]['stats'] as Map<String, dynamic>)['score'] = 900;
      final lobby = scoreboardOrder(MatchDetails.fromJson(json), me).single;
      final scores = [for (final p in lobby.players) p.stats?.score ?? 0];
      expect(scores, [...scores]..sort((a, b) => b.compareTo(a)));
    });
  });

  test('a match without participants has no blocks', () {
    final d = MatchDetails.fromJson({
      'matchInfo': {'matchId': 'x'},
      'players': <Object>[],
    });
    expect(scoreboardOrder(d, me), isEmpty);
  });
}
