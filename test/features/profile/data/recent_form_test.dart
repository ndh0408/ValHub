import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/match_filter.dart';
import 'package:valvn/features/profile/data/recent_form.dart';

import '../../../core/domain/competitive/competitive_test_utils.dart';

/// A summary of a round-based (competitive) match unless [queue] says
/// otherwise. ACS is score / rounds, so it is given as [score] and [rounds].
MatchPlayerSummary _m(
  MatchOutcome outcome, {
  int k = 10,
  int d = 10,
  int score = 4000,
  int rounds = 20,
  int? damage,
  int head = 0,
  int body = 0,
  int leg = 0,
  int fb = 0,
  int fd = 0,
  String queue = 'competitive',
  String? gameMode,
  String? map,
  String id = 'x',
}) => MatchPlayerSummary(
  info: MatchInfo(matchId: id, queueId: queue, gameMode: gameMode, mapId: map),
  player: const MatchPlayer(subject: 'me'),
  result: MatchResult(outcome: outcome),
  stats: ScoreboardStats(
    subject: 'me',
    kills: k,
    deaths: d,
    score: score,
    roundsPlayed: rounds,
    acs: rounds > 0 ? score / rounds : null,
    adr: damage == null ? null : damage / rounds,
    damage: damage ?? 0,
    headshots: head,
    bodyshots: body,
    legshots: leg,
    firstBloods: fb,
    firstDeaths: fd,
  ),
);

/// A Deathmatch: one "round", the whole score is the ACS the old code
/// averaged in (fixture: 6000).
MatchPlayerSummary _dm(MatchOutcome outcome, {int score = 6000}) =>
    _m(outcome, k: 25, d: 20, score: score, rounds: 1, queue: 'deathmatch');

MatchPlayerSummary _tdm(MatchOutcome outcome) =>
    _m(outcome, k: 40, d: 35, score: 9000, rounds: 1, queue: 'hurm');

MatchPlayerSummary _escalation(MatchOutcome outcome) =>
    _m(outcome, k: 14, d: 12, score: 3000, rounds: 1, queue: 'ggteam');

void main() {
  test('empty input has no rates and no streak', () {
    final f = RecentForm.from(const []);
    expect(f.isEmpty, isTrue);
    expect(f.winRate, isNull);
    expect(f.kd, isNull);
    expect(f.acs, isNull);
    expect(f.hasRoundStats, isFalse);
    expect(f.streakKind, isNull);
  });

  test('record, win rate and the streak up to the newest match', () {
    final f = RecentForm.from([
      _m(MatchOutcome.win),
      _m(MatchOutcome.win),
      _m(MatchOutcome.win),
      _m(MatchOutcome.loss),
      _m(MatchOutcome.draw),
      _m(MatchOutcome.unknown),
    ]);
    expect(f.games, 5); // unknown is left out
    expect((f.wins, f.losses, f.draws), (3, 1, 1));
    expect(f.winRate, 0.75); // draws excluded
    expect(f.streakKind, StreakKind.win);
    expect(f.streak, 3);
    expect(f.outcomes.first, MatchOutcome.win);
  });

  test('a loss streak; a draw as newest match breaks the streak', () {
    final losing = RecentForm.from([
      _m(MatchOutcome.loss),
      _m(MatchOutcome.loss),
      _m(MatchOutcome.win),
    ]);
    expect(losing.streakKind, StreakKind.loss);
    expect(losing.streak, 2);

    final drawn = RecentForm.from([
      _m(MatchOutcome.draw),
      _m(MatchOutcome.win),
    ]);
    expect(drawn.streakKind, isNull);
    expect(drawn.streak, 0);
  });

  test('K/D over totals, ACS = Σ score / Σ rounds, HS% over all hits', () {
    final f = RecentForm.from([
      // 6000 over 20 rounds = 300 ACS; 20/10 kills.
      _m(
        MatchOutcome.win,
        k: 20,
        d: 10,
        score: 6000,
        rounds: 20,
        head: 10,
        body: 30,
      ),
      // 2000 over 10 rounds = 200 ACS; 10/20 kills.
      _m(
        MatchOutcome.loss,
        k: 10,
        d: 20,
        score: 2000,
        rounds: 10,
        head: 0,
        body: 10,
      ),
    ]);
    expect(f.kd, 1.0);
    // Weighted: 8000 / 30 = 266.67, not the mean of 300 and 200 (250).
    expect(f.acs, closeTo(8000 / 30, 1e-9));
    expect(f.headshotRate, closeTo(10 / 50, 1e-9));
    expect(f.roundGames, 2);
    expect(f.rounds, 30);
  });

  test('ADR: Σ damage / Σ rounds of the matches that have damage data', () {
    final f = RecentForm.from([
      _m(MatchOutcome.win, rounds: 20, damage: 3200),
      _m(MatchOutcome.win, rounds: 10, damage: 1000),
      // No damage data (older payload): out of the ADR, still in the rest.
      _m(MatchOutcome.loss, rounds: 30),
    ]);
    expect(f.adr, closeTo(4200 / 30, 1e-9));
    expect(f.roundGames, 3);
    expect(f.acs, closeTo((4000 + 4000 + 4000) / 60, 1e-9));
  });

  test('first bloods and first deaths are summed over round-based matches', () {
    final f = RecentForm.from([
      _m(MatchOutcome.win, fb: 4, fd: 2),
      _m(MatchOutcome.loss, fb: 1, fd: 5),
      _dm(MatchOutcome.win),
    ]);
    expect((f.firstBloods, f.firstDeaths), (5, 7));
  });

  test('zero deaths counts as one for K/D; no hits means no HS%', () {
    final f = RecentForm.from([_m(MatchOutcome.win, k: 7, d: 0)]);
    expect(f.kd, 7);
    expect(f.headshotRate, isNull);
    expect(f.adr, isNull);
  });

  group('PR-02: Deathmatch and other round-less modes', () {
    test('one Deathmatch does not turn ACS into thousands', () {
      final f = RecentForm.from([
        _dm(MatchOutcome.win),
        _m(MatchOutcome.win, score: 5000, rounds: 20), // 250 ACS
        _m(MatchOutcome.loss, score: 5000, rounds: 20),
      ]);
      // The old mean-of-values gave (6000 + 250 + 250) / 3 ≈ 2166.
      expect(f.acs, 250);
      expect(f.roundGames, 2);
      expect(f.games, 3);
      // Results still count the Deathmatch.
      expect((f.wins, f.losses), (2, 1));
      expect(f.roundStatsArePartial, isTrue);
    });

    test('K/D excludes Deathmatch, Team Deathmatch and Escalation', () {
      final f = RecentForm.from([
        _dm(MatchOutcome.win), // 25 / 20
        _tdm(MatchOutcome.loss), // 40 / 35
        _escalation(MatchOutcome.win), // 14 / 12
        _m(MatchOutcome.win, k: 20, d: 10),
        _m(MatchOutcome.loss, k: 10, d: 20),
      ]);
      expect(f.kd, 1.0); // only the two competitive matches
      expect(f.games, 5);
      expect(f.roundGames, 2);
      expect((f.wins, f.losses), (3, 2));
    });

    test('only round-less matches: results yes, per-round stats hidden', () {
      final f = RecentForm.from([
        _dm(MatchOutcome.win),
        _tdm(MatchOutcome.loss),
        _escalation(MatchOutcome.win),
      ]);
      expect(f.games, 3);
      expect(f.winRate, closeTo(2 / 3, 1e-9));
      expect(f.hasRoundStats, isFalse);
      expect(f.roundStatsArePartial, isFalse);
      expect(f.kd, isNull);
      expect(f.acs, isNull);
      expect(f.adr, isNull);
      expect(f.headshotRate, isNull);
      expect(f.firstBloods, 0);
    });

    test(
      'game mode path alone marks Team Deathmatch when the queue is empty',
      () {
        final f = RecentForm.from([
          _m(
            MatchOutcome.win,
            queue: '',
            gameMode: '/Game/GameModes/HURM/HURMGameMode.HURMGameMode_C',
            score: 9000,
            rounds: 1,
          ),
          _m(MatchOutcome.win, score: 4000, rounds: 20),
        ]);
        expect(f.acs, 200);
        expect(f.roundGames, 1);
      },
    );

    test(
      'a round-based match without rounds played has no per-round stats',
      () {
        final f = RecentForm.from([_m(MatchOutcome.win, rounds: 0, score: 0)]);
        expect(f.games, 1);
        expect(f.roundGames, 0);
        expect(f.acs, isNull);
        expect(f.kd, isNull);
      },
    );

    test(
      'real fixtures: a Deathmatch (ACS 6000) next to a competitive win',
      () {
        MatchPlayerSummary fromFixture(String name) =>
            MatchDetails.fromJson(competitiveFixture(name)).summaryFor(me)!;
        final comp = fromFixture('match_competitive');
        final dm = fromFixture('match_deathmatch');
        expect(dm.stats.acs, 6000); // what the old aggregate averaged in
        final mixed = RecentForm.from([dm, comp]);
        expect(mixed.games, 2);
        expect(mixed.acs, comp.stats.acs); // 200, the Deathmatch is left out
        expect(mixed.roundGames, 1);
        expect(mixed.kd, comp.stats.kd);
      },
    );
  });

  group('selectFormWindow (PR-15, PR-26)', () {
    MatchHistoryEntry entry(String id) => MatchHistoryEntry(matchId: id);
    MatchStatLine line(String id, {String? map, MatchOutcome? outcome}) =>
        MatchStatLine(
          matchId: id,
          startedAt: DateTime.utc(2026, 9, 28),
          outcome: outcome ?? MatchOutcome.win,
          mapId: map,
        );

    test('takes the newest matches up to the limit, in order', () {
      final entries = [for (var i = 0; i < 15; i++) entry('m$i')];
      final w = selectFormWindow(entries, resolve: (e) => line(e.matchId));
      expect(w.lines.map((l) => l.matchId), [
        for (var i = 0; i < 10; i++) 'm$i',
      ]);
      expect(w.unresolved, 0);
    });

    test('a map filter keeps only that map and asks for nothing else', () {
      final maps = {
        'a': '/Game/Maps/Ascent/Ascent',
        'b': '/Game/Maps/Bonsai/Bonsai',
        'c': '/Game/Maps/Ascent/Ascent',
        'd': '/Game/Maps/Ascent/Ascent',
      };
      final asked = <String>[];
      final w = selectFormWindow(
        [for (final id in maps.keys) entry(id)],
        resolve: (e) {
          asked.add(e.matchId);
          return line(e.matchId, map: maps[e.matchId]);
        },
        filter: const MatchFilter(mapUrl: '/game/maps/ascent/ascent'),
        limit: 2,
      );
      expect(w.lines.map((l) => l.matchId), ['a', 'c']);
      // It stops once the window is full: 'd' is never resolved.
      expect(asked, ['a', 'b', 'c']);
    });

    test('unknown matches are counted, never fetched, and skipped', () {
      final known = {'a': line('a', map: 'm1'), 'c': line('c', map: 'm1')};
      final w = selectFormWindow(
        [entry('a'), entry('b'), entry('c'), entry('d')],
        resolve: (e) => known[e.matchId],
        filter: const MatchFilter(mapUrl: 'm1'),
      );
      expect(w.lines.map((l) => l.matchId), ['a', 'c']);
      expect(w.unresolved, 2);
    });

    test('countMapFilter separates visible from unknown', () {
      final maps = <String, String?>{'a': 'm1', 'b': 'm2', 'c': null};
      final counts = countMapFilter(
        ['a', 'b', 'c', 'z'],
        filter: const MatchFilter(mapUrl: 'm1'),
        mapOf: (id) => maps.containsKey(id) ? (map: maps[id]) : null,
      );
      // 'a' passes; 'b' has another map; 'c' is known without a map (never
      // passes); 'z' has not been looked at.
      expect(counts.visible, 1);
      expect(counts.unknown, 1);
    });
  });

  test('the form can be built from ledger lines too', () {
    final lines = [
      MatchStatLine(
        matchId: 'a',
        startedAt: DateTime.utc(2026, 9, 28, 12),
        outcome: MatchOutcome.win,
        queueId: 'competitive',
        kills: 20,
        deaths: 10,
        score: 5000,
        rounds: 20,
      ),
      MatchStatLine(
        matchId: 'b',
        startedAt: DateTime.utc(2026, 9, 28, 10),
        outcome: MatchOutcome.loss,
        queueId: 'deathmatch',
        mode: MatchModeKind.deathmatch,
        kills: 30,
        deaths: 25,
        score: 6000,
        rounds: 1,
      ),
    ];
    final f = RecentForm.fromLines(lines);
    expect(f.games, 2);
    expect(f.acs, 250);
    expect(f.kd, 2.0);
    expect(f.roundGames, 1);
  });
}
