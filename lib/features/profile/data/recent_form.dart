import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';
import 'match_filter.dart';

// `StreakKind` moved to the shared competitive domain (one streak rule for
// Profile and Home, PR-19).
export '../../../core/domain/competitive/streak.dart' show Streak, StreakKind;

/// How many of the newest listed matches the form card summarises.
const kRecentFormMatches = 10;

/// Form stats derived from the most recent matches (newest first).
///
/// Two scopes, never mixed (PR-02):
/// - **Results** (record, win rate, streak, the W/L strip) count every
///   decided match, whatever its mode;
/// - **Per-round stats** (K/D, ACS, ADR, HS%, first bloods) count only
///   round-based matches (competitive, unrated, Swiftplay…). Deathmatch,
///   Team Deathmatch and Escalation have no comparable rounds (a Deathmatch
///   "ACS" is the total score), so they are left out of those numbers.
///   ACS is Σ score / Σ rounds, not a mean of per-match values.
///
/// [hasRoundStats] is false when no match qualifies: the UI then hides the
/// stat tiles instead of showing a wrong number.
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
    this.roundGames = 0,
    this.rounds = 0,
    this.kd,
    this.acs,
    this.adr,
    this.headshotRate,
    this.firstBloods = 0,
    this.firstDeaths = 0,
  });

  /// Builds the form from [summaries], newest first. Matches with an unknown
  /// outcome (customs without teams, aborted) are left out.
  factory RecentForm.from(Iterable<MatchPlayerSummary> summaries) =>
      RecentForm.fromLines([
        for (final s in summaries) ?MatchStatLine.fromSummary(s),
      ]);

  /// Builds the form from stat [lines], newest first (the caller decides the
  /// window: the newest 10 matches of a queue or of a map).
  factory RecentForm.fromLines(Iterable<MatchStatLine> lines) {
    final decided = [
      for (final l in lines)
        if (l.outcome != MatchOutcome.unknown) l,
    ];
    final agg = PerfAggregate.of(decided);
    final outcomes = [for (final l in decided) l.outcome];
    final streak = currentStreak(outcomes);
    return RecentForm(
      games: decided.length,
      wins: agg.wins,
      losses: agg.losses,
      draws: agg.draws,
      outcomes: List.unmodifiable(outcomes),
      streakKind: streak?.kind,
      streak: streak?.count ?? 0,
      roundGames: agg.roundGames,
      rounds: agg.rounds,
      kd: agg.kd,
      acs: agg.acs,
      adr: agg.adr,
      headshotRate: agg.headshotRate,
      firstBloods: agg.firstBloods,
      firstDeaths: agg.firstDeaths,
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

  /// Round-based matches behind [kd], [acs], [adr], [headshotRate] and the
  /// first-blood counts.
  final int roundGames;
  final int rounds;

  /// Total kills / total deaths over the round-based matches.
  final double? kd;

  /// Σ score / Σ rounds over the round-based matches.
  final double? acs;

  /// Σ enemy damage / Σ rounds of the matches that have damage data.
  final double? adr;

  /// Headshots / all hits.
  final double? headshotRate;
  final int firstBloods;
  final int firstDeaths;

  bool get isEmpty => games == 0;

  /// Whether any round-based match feeds the per-round stats.
  bool get hasRoundStats => roundGames > 0;

  /// Some of the window's matches (Deathmatch…) are not in the per-round
  /// stats: say so next to them.
  bool get roundStatsArePartial => hasRoundStats && roundGames < games;

  /// Wins / decided games (draws excluded); `null` without decided games.
  double? get winRate {
    final decided = wins + losses;
    return decided == 0 ? null : wins / decided;
  }
}

/// The matches a form card summarises, and how many listed matches could not
/// be looked at yet.
@immutable
class FormWindow {
  const FormWindow(this.lines, {this.unresolved = 0});

  /// At most [kRecentFormMatches] lines, newest first.
  final List<MatchStatLine> lines;

  /// Listed matches (before the window filled) whose details are not known
  /// yet, so their map could not be checked. Never fetched from here.
  final int unresolved;
}

/// Picks the window of the form card (PR-15, PR-26): walks [entries] newest
/// first, asks [resolve] for the stat line of each (`null` = not known yet;
/// the callback must not start a request) and keeps the first [limit] whose
/// map passes [filter].
///
/// With a map filter this is what stops the card from fetching dozens of
/// match details: only lines already known (the ledger, or cards on screen)
/// are used.
FormWindow selectFormWindow(
  Iterable<MatchHistoryEntry> entries, {
  required MatchStatLine? Function(MatchHistoryEntry entry) resolve,
  MatchFilter filter = const MatchFilter(),
  int limit = kRecentFormMatches,
}) {
  final picked = <MatchStatLine>[];
  var unresolved = 0;
  for (final e in entries) {
    if (picked.length >= limit) break;
    final line = resolve(e);
    if (line == null) {
      unresolved++;
      continue;
    }
    if (filter.acceptsMap(line.mapId)) picked.add(line);
  }
  return FormWindow(List.unmodifiable(picked), unresolved: unresolved);
}
