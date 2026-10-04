/// "Rank & phong độ" card model (docs/design/HOME.md §5.3). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/competitive/competitive.dart';

/// A ranked streak older than this is not shown.
const kHomeStreakMaxAge = Duration(days: 7);

/// "Hôm qua …" is shown instead of "Hôm nay" up to this many days back.
const kHomeRecentRrDays = 7;

/// Fewer decided games than this is not a streak.
const kHomeMinStreak = 2;

/// The current run of wins or losses in **ranked** (the scope is part of the
/// number: Profile's form card counts the queue chip's matches instead).
typedef RankedStreak = Streak;

/// The ranked streak of [history] (newest row first). Each row's outcome is
/// the known match outcome, else the sign of its RR; a draw or a remake
/// (0 RR) ends the walk. The run itself is the one streak rule shared with
/// Profile's recent form ([currentStreak], PR-19). `null` for fewer than
/// [kHomeMinStreak] games, or when the newest game is older than
/// [kHomeStreakMaxAge].
RankedStreak? rankedStreakOf(RrHistory history, {required DateTime now}) {
  final rows = history.rows;
  if (rows.isEmpty) return null;
  final newest = rows.first.matchStartTime;
  if (newest == null || now.difference(newest) > kHomeStreakMaxAge) return null;
  final streak = currentStreak([
    for (final u in rows)
      switch (history.outcomes[u.matchId]) {
        final known? when known != MatchOutcome.unknown => known,
        _ => MatchOutcome.fromRr(u.rrEarned),
      },
  ]);
  if (streak == null || streak.count < kHomeMinStreak) return null;
  return streak;
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
    this.nextRank,
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
  final RankInfo? nextRank;

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
  final progress = rankProgress(current);

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
    progress: progress?.fraction,
    rrToNext: progress?.rrToNext,
    today: today,
    lastDay: lastDay,
    streak: streak,
    matchesToNext: belowImmortal && matches != null && matches > 0
        ? matches
        : null,
    nextTierName: next?.tierName,
    nextRank: next,
    leaderboard: ranked && !belowImmortal ? summary.leaderboardRank : null,
    previousAct: previous,
  );
}
