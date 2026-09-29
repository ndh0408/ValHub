/// "Rank & phong độ" card model (docs/design/HOME.md §5.3). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../profile/data/recent_form.dart' show StreakKind;

/// A ranked streak older than this is not shown.
const kHomeStreakMaxAge = Duration(days: 7);

/// "Hôm qua …" is shown instead of "Hôm nay" up to this many days back.
const kHomeRecentRrDays = 7;

/// Fewer decided games than this is not a streak.
const kHomeMinStreak = 2;

/// The current run of wins or losses in ranked.
@immutable
class RankedStreak {
  const RankedStreak(this.kind, this.count);

  final StreakKind kind;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is RankedStreak && other.kind == kind && other.count == count;

  @override
  int get hashCode => Object.hash(kind, count);
}

/// The ranked streak of [history] (newest row first). Each row's outcome is
/// the known match outcome, else the sign of its RR; a draw, a remake (0 RR)
/// or an unknown outcome ends the walk (same semantics as Profile's recent
/// form). `null` for fewer than [kHomeMinStreak] games, or when the newest
/// game is older than [kHomeStreakMaxAge].
RankedStreak? rankedStreakOf(RrHistory history, {required DateTime now}) {
  final rows = history.rows;
  if (rows.isEmpty) return null;
  final newest = rows.first.matchStartTime;
  if (newest == null || now.difference(newest) > kHomeStreakMaxAge) return null;
  StreakKind? kind;
  var count = 0;
  for (final u in rows) {
    final known = history.outcomes[u.matchId];
    final outcome = known == null || known == MatchOutcome.unknown
        ? MatchOutcome.fromRr(u.rrEarned)
        : known;
    final k = switch (outcome) {
      MatchOutcome.win => StreakKind.win,
      MatchOutcome.loss => StreakKind.loss,
      _ => null,
    };
    if (k == null) break;
    if (kind == null) {
      kind = k;
    } else if (k != kind) {
      break;
    }
    count++;
  }
  if (kind == null || count < kHomeMinStreak) return null;
  return RankedStreak(kind, count);
}

/// What the rank card shows.
@immutable
class HomeRankSnapshot {
  const HomeRankSnapshot({
    required this.current,
    this.progress,
    this.rrToNext,
    this.today,
    this.lastDay,
    this.streak,
    this.matchesToNext,
    this.nextTierName,
    this.leaderboard,
    this.previousAct,
  });

  final RankInfo current;

  /// `rr / 100`, only below Immortal and while ranked.
  final double? progress;
  final int? rrToNext;

  /// Ranked games played today (local day).
  final DailyRr? today;

  /// The newest day within [kHomeRecentRrDays] when there is no [today].
  final DailyRr? lastDay;
  final RankedStreak? streak;

  /// Games to the next tier at the recent form ("≈ 9 trận").
  final int? matchesToNext;
  final String? nextTierName;

  /// Leaderboard position (Immortal and above).
  final int? leaderboard;

  /// The newest other act the player has games in (shown when unranked in
  /// the current act).
  final RankInfo? previousAct;
}

/// Builds the rank card from [summary] (P-11) and the device's RR
/// [history]; [estimate] is the rank-up calculator's answer for the next
/// tier. `null` ("never ranked") when the account has no rank, no
/// placements and no ranked act.
HomeRankSnapshot? buildHomeRankSnapshot(
  RankSummary summary, {
  required ContentDb db,
  required DateTime now,
  RrHistory? history,
  RankUpEstimate? estimate,
  DateTime Function(DateTime utc)? toLocal,
}) {
  final current = summary.current;
  if (current.isUnranked &&
      !current.isPlacement &&
      summary.peak == null &&
      summary.acts.isEmpty) {
    return null;
  }

  final ranked = !current.isUnranked;
  final belowImmortal = ranked && current.normalizedTier < kRankUpMaxTier;

  DailyRr? today;
  DailyRr? lastDay;
  RankedStreak? streak;
  if (history != null && !history.isEmpty) {
    final days = groupDailyRr(
      history.rows,
      outcomes: history.outcomes,
      toLocal: toLocal,
    );
    today = dailyRrOn(days, now);
    if (today == null && days.isNotEmpty) {
      final local = now.toLocal();
      final midnight = DateTime(local.year, local.month, local.day);
      final newest = days.first;
      if (midnight.difference(newest.date).inDays <= kHomeRecentRrDays &&
          !newest.date.isAfter(midnight)) {
        lastDay = newest;
      }
    }
    streak = rankedStreakOf(history, now: now);
  }

  final matches = estimate?.matchesAtCurrentForm;
  final RankInfo? next = belowImmortal
      ? RankInfo.resolve(
          db,
          tier: current.normalizedTier + 1,
          actUuid: current.actUuid,
        )
      : null;

  // The newest other act with games, for "Phần trước: …".
  RankInfo? previous;
  if (!ranked && !current.isPlacement) {
    for (final a in summary.acts) {
      if (a.actUuid != current.actUuid && !a.rank.isUnranked) {
        previous = a.rank;
        break;
      }
    }
  }

  return HomeRankSnapshot(
    current: current,
    progress: belowImmortal && !current.isPlacement
        ? (current.rr / kRrPerTier).clamp(0.0, 1.0)
        : null,
    rrToNext: belowImmortal && !current.isPlacement
        ? (kRrPerTier - current.rr).clamp(0, kRrPerTier)
        : null,
    today: today,
    lastDay: lastDay,
    streak: streak,
    matchesToNext: belowImmortal && matches != null && matches > 0
        ? matches
        : null,
    nextTierName: next?.tierName,
    leaderboard: ranked && !belowImmortal ? summary.leaderboardRank : null,
    previousAct: previous,
  );
}
