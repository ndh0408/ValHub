import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/home/data/home_rank.dart';
import 'package:valvn/features/profile/data/recent_form.dart' show StreakKind;

import '../../profile/profile_test_env.dart';

/// Local noon of 2026-09-28 (day-of-week independent).
final _now = DateTime(2026, 9, 28, 19);

JsonMap _mmr({
  int tier = 18,
  int rr = 6,
  int leaderboard = 0,
  int gamesNeeded = 0,
  bool withOldAct = true,
  bool noSeasons = false,
  bool neverPlayed = false,
}) {
  final base = competitiveFixtureMap('mmr');
  final competitive = asMap(asMap(base['QueueSkills'])!['competitive'])!;
  final seasons = Map<String, dynamic>.of(
    asMap(competitive['SeasonalInfoBySeasonID'])!,
  );
  final v = Map<String, dynamic>.of(asMap(seasons[actV])!)
    ..['CompetitiveTier'] = tier
    ..['Rank'] = tier
    ..['RankedRating'] = rr
    ..['LeaderboardRank'] = leaderboard
    ..['GamesNeededForRating'] = gamesNeeded;
  if (neverPlayed) {
    v
      ..['NumberOfGames'] = 0
      ..['NumberOfWins'] = 0
      ..['NumberOfWinsWithPlacements'] = 0
      ..['WinsByTier'] = <String, dynamic>{};
  }
  seasons[actV] = v;
  if (!withOldAct) {
    seasons
      ..remove(actI)
      ..remove('9999aaaa-0000-4000-8000-00000000abcd');
  }
  if (noSeasons) seasons.clear();
  final queues = Map<String, dynamic>.of(asMap(base['QueueSkills'])!);
  queues['competitive'] = {
    ...competitive,
    'SeasonalInfoBySeasonID': seasons,
    'CurrentSeasonGamesNeededForRating': gamesNeeded,
  };
  return {
    ...base,
    'QueueSkills': queues,
    // The latest update would give a rank even when the act has none.
    'LatestCompetitiveUpdate': null,
  };
}

RankSummary _summary(JsonMap mmr, {RrHistory? history}) => buildRankSummary(
  testContent(),
  PlayerMmr.fromJson(mmr),
  now: _now,
  history: history?.rows ?? const [],
);

CompetitiveUpdate _row(
  String id,
  DateTime start, {
  int earned = 0,
  int before = 50,
}) => CompetitiveUpdate.fromJson(
  updateRow(
    id,
    start: start,
    rrBefore: before,
    rrAfter: before + earned,
    earned: earned,
  ),
)!;

RrHistory _history(
  List<CompetitiveUpdate> rows, {
  Map<String, MatchOutcome> outcomes = const {},
}) => RrHistory(
  puuid: me,
  rows: [...rows]..sort(compareUpdatesNewestFirst),
  outcomes: outcomes,
);

String _id(int n) => 'e0000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

HomeRankSnapshot? _snapshot(
  JsonMap mmr, {
  RrHistory? history,
  RankUpEstimate? estimate,
  DateTime? now,
}) => buildHomeRankSnapshot(
  _summary(mmr, history: history),
  db: testContent(),
  now: now ?? _now,
  history: history,
  estimate: estimate,
);

void main() {
  group('rank, progress and next tier', () {
    test('a ranked player: RR, progress, RR to the next tier and its name', () {
      final s = _snapshot(_mmr(tier: 18, rr: 6))!;
      expect(
        s.current.tierName,
        testContent().tier(18, seasonUuid: actV)?.displayName,
      );
      expect(s.current.rr, 6);
      expect(s.progress, closeTo(0.06, 1e-9));
      expect(s.rrToNext, 94);
      expect(
        s.nextTierName,
        'Kim Cương 2',
      );
      expect(s.leaderboard, isNull);
      expect(s.previousAct, isNull);
    });

    test('games to rank up come from the estimate, only when positive', () {
      const estimate = RankUpEstimate(
        currentTier: 18,
        currentRr: 6,
        targetTier: 19,
        rrNeeded: 94,
        form: RankUpForm(avgGain: 20, avgLoss: 15, wins: 5, losses: 3),
        byWinRate: [],
        matchesAtCurrentForm: 9,
      );
      expect(_snapshot(_mmr(), estimate: estimate)!.matchesToNext, 9);
      expect(_snapshot(_mmr())!.matchesToNext, isNull);
      const zero = RankUpEstimate(
        currentTier: 18,
        currentRr: 6,
        targetTier: 19,
        rrNeeded: 94,
        form: RankUpForm(),
        byWinRate: [],
        matchesAtCurrentForm: 0,
      );
      expect(_snapshot(_mmr(), estimate: zero)!.matchesToNext, isNull);
    });

    test('Immortal and above: no bar, no estimate, the leaderboard spot', () {
      const estimate = RankUpEstimate(
        currentTier: 24,
        currentRr: 200,
        targetTier: 25,
        rrNeeded: 1,
        form: RankUpForm(),
        byWinRate: [],
        matchesAtCurrentForm: 5,
      );
      final s = _snapshot(
        _mmr(tier: 24, rr: 200, leaderboard: 123),
        estimate: estimate,
      )!;
      expect(s.progress, isNull);
      expect(s.rrToNext, isNull);
      expect(s.matchesToNext, isNull);
      expect(s.nextTierName, isNull);
      expect(s.leaderboard, 123);
    });

    test('placements: the placement text instead of RR and progress', () {
      final s = _snapshot(_mmr(tier: 0, rr: 0, gamesNeeded: 3))!;
      expect(s.current.isPlacement, isTrue);
      expect(s.current.placementText, isNotNull);
      expect(s.progress, isNull);
      expect(s.rrToNext, isNull);
    });

    test('unranked this act but ranked before: shows the previous act', () {
      final s = _snapshot(_mmr(tier: 0, rr: 0))!;
      expect(s.current.isUnranked, isTrue);
      expect(s.current.isPlacement, isFalse);
      expect(s.previousAct, isNotNull);
      expect(s.previousAct!.isUnranked, isFalse);
      expect(s.progress, isNull);
    });

    test('never ranked: no card', () {
      expect(_snapshot(_mmr(noSeasons: true)), isNull);
      expect(
        _snapshot(_mmr(tier: 0, rr: 0, withOldAct: false, neverPlayed: true)),
        isNull,
      );
    });
  });

  group('RR today', () {
    test('sums today and counts wins, losses and draws', () {
      final h = _history([
        _row(_id(1), DateTime(2026, 9, 28, 10), earned: 24),
        _row(_id(2), DateTime(2026, 9, 28, 12), earned: -18),
        _row(_id(3), DateTime(2026, 9, 28, 14), earned: 20),
        _row(_id(4), DateTime(2026, 9, 28, 16)),
        _row(_id(5), DateTime(2026, 9, 27, 22), earned: 30),
      ]);
      final s = _snapshot(_mmr(), history: h)!;
      expect(s.today, isNotNull);
      expect(s.today!.netRr, 26);
      expect((s.today!.wins, s.today!.losses, s.today!.draws), (2, 1, 1));
      expect(s.lastDay, isNull);
    });

    test('the local midnight splits the days', () {
      final h = _history([
        _row(_id(1), DateTime(2026, 9, 28, 0, 30), earned: 15),
        _row(_id(2), DateTime(2026, 9, 27, 23, 30), earned: 40),
      ]);
      final s = _snapshot(_mmr(), history: h)!;
      expect(s.today!.netRr, 15);
      expect(s.today!.matches, hasLength(1));
    });

    test('nothing today: the last day within seven days', () {
      final h = _history([
        _row(_id(1), DateTime(2026, 9, 25, 20), earned: -12),
        _row(_id(2), DateTime(2026, 9, 25, 21), earned: 22),
        _row(_id(3), DateTime(2026, 9, 20, 21), earned: 30),
      ]);
      final s = _snapshot(_mmr(), history: h)!;
      expect(s.today, isNull);
      expect(s.lastDay, isNotNull);
      expect(s.lastDay!.date, DateTime(2026, 9, 25));
      expect(s.lastDay!.netRr, 10);
    });

    test('older than seven days: neither today nor a last day', () {
      final h = _history([_row(_id(1), DateTime(2026, 9, 15, 20), earned: 20)]);
      final s = _snapshot(_mmr(), history: h)!;
      expect(s.today, isNull);
      expect(s.lastDay, isNull);
      // Exactly seven days back still counts.
      final edge = _history([
        _row(_id(2), DateTime(2026, 9, 21, 20), earned: 20),
      ]);
      expect(_snapshot(_mmr(), history: edge)!.lastDay, isNotNull);
    });

    test('without history there is no form at all', () {
      final s = _snapshot(_mmr())!;
      expect(s.today, isNull);
      expect(s.lastDay, isNull);
      expect(s.streak, isNull);
    });
  });

  group('rankedStreakOf', () {
    RrHistory h(
      List<int> earnedNewestFirst, {
      Map<String, MatchOutcome>? outcomes,
    }) => _history([
      for (var i = 0; i < earnedNewestFirst.length; i++)
        _row(
          _id(i + 1),
          _now.subtract(Duration(hours: i + 1)),
          earned: earnedNewestFirst[i],
        ),
    ], outcomes: outcomes ?? const {});

    test('a win run and a loss run', () {
      final win = rankedStreakOf(h([20, 18, 22, -15, 20]), now: _now)!;
      expect((win.kind, win.count), (StreakKind.win, 3));
      final loss = rankedStreakOf(h([-14, -17, -12, 20]), now: _now)!;
      expect((loss.kind, loss.count), (StreakKind.loss, 3));
    });

    test('a draw or a remake (0 RR) ends the run', () {
      expect(rankedStreakOf(h([20, 0, 22, 18]), now: _now), isNull);
      final s = rankedStreakOf(h([20, 18, 0, 22, 25]), now: _now)!;
      expect(s.count, 2);
    });

    test('a known outcome overrides the sign of the RR', () {
      final history = h([-5, 20, 18], outcomes: {_id(1): MatchOutcome.win});
      final s = rankedStreakOf(history, now: _now)!;
      expect((s.kind, s.count), (StreakKind.win, 3));
    });

    test('fewer than two games is not a streak', () {
      expect(rankedStreakOf(h([20]), now: _now), isNull);
      expect(rankedStreakOf(h([20, -18]), now: _now), isNull);
      expect(rankedStreakOf(h(const []), now: _now), isNull);
    });

    test('a stale newest game gives none', () {
      final old = _history([
        _row(_id(1), DateTime(2026, 9, 10, 20), earned: 20),
        _row(_id(2), DateTime(2026, 9, 10, 19), earned: 20),
      ]);
      expect(rankedStreakOf(old, now: _now), isNull);
      // Just inside the window.
      final fresh = _history([
        _row(_id(1), DateTime(2026, 9, 22, 20), earned: 20),
        _row(_id(2), DateTime(2026, 9, 22, 19), earned: 20),
      ]);
      expect(rankedStreakOf(fresh, now: _now)!.count, 2);
    });
  });
}
