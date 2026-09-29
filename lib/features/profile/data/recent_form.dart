import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';

/// Kind of the current result streak.
enum StreakKind { win, loss }

/// Cheap form stats derived from the already-loaded summaries of the most
/// recent matches (newest first): record, win rate, current streak and
/// per-match averages (K/D, ACS, HS%).
@immutable
class RecentForm {
  const RecentForm({
    required this.games,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.outcomes,
    this.streakKind,
    this.streak = 0,
    this.kd,
    this.acs,
    this.headshotRate,
  });

  /// Builds the form from [summaries], newest first. Matches with an unknown
  /// outcome (customs without teams, aborted) are left out.
  factory RecentForm.from(Iterable<MatchPlayerSummary> summaries) {
    var wins = 0, losses = 0, draws = 0;
    var kills = 0, deaths = 0;
    var acsSum = 0.0, acsCount = 0;
    var head = 0, hits = 0;
    final outcomes = <MatchOutcome>[];
    for (final s in summaries) {
      final o = s.result.outcome;
      if (o == MatchOutcome.unknown) continue;
      outcomes.add(o);
      switch (o) {
        case MatchOutcome.win:
          wins++;
        case MatchOutcome.loss:
          losses++;
        case MatchOutcome.draw:
          draws++;
        case MatchOutcome.unknown:
          break;
      }
      final st = s.stats;
      kills += st.kills;
      deaths += st.deaths;
      if (st.acs case final a?) {
        acsSum += a;
        acsCount++;
      }
      head += st.headshots;
      hits += st.headshots + st.bodyshots + st.legshots;
    }

    StreakKind? kind;
    var streak = 0;
    for (final o in outcomes) {
      final k = switch (o) {
        MatchOutcome.win => StreakKind.win,
        MatchOutcome.loss => StreakKind.loss,
        _ => null,
      };
      if (k == null) break;
      if (kind == null) {
        kind = k;
        streak = 1;
      } else if (k == kind) {
        streak++;
      } else {
        break;
      }
    }

    final games = outcomes.length;
    return RecentForm(
      games: games,
      wins: wins,
      losses: losses,
      draws: draws,
      outcomes: List.unmodifiable(outcomes),
      streakKind: kind,
      streak: streak,
      kd: games == 0 ? null : kills / (deaths == 0 ? 1 : deaths),
      acs: acsCount == 0 ? null : acsSum / acsCount,
      headshotRate: hits == 0 ? null : head / hits,
    );
  }

  final int games;
  final int wins;
  final int losses;
  final int draws;

  /// Outcomes newest first (for the W/L strip).
  final List<MatchOutcome> outcomes;

  /// Kind of the streak running up to the newest match (`null` when the
  /// newest match was a draw or there are no matches).
  final StreakKind? streakKind;
  final int streak;

  /// Total kills / total deaths.
  final double? kd;

  /// Mean ACS of the matches that have one.
  final double? acs;

  /// Headshots / all hits.
  final double? headshotRate;

  bool get isEmpty => games == 0;

  /// Wins / decided games (draws excluded); `null` without decided games.
  double? get winRate {
    final decided = wins + losses;
    return decided == 0 ? null : wins / decided;
  }
}
