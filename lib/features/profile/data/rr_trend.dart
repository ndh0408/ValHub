import '../../../core/domain/competitive/competitive.dart';

// `dailyRrOn` moved to the shared competitive domain (Home uses it too).
export '../../../core/domain/competitive/rank_calc.dart' show dailyRrOn;

/// RR changes of the newest [limit] competitive updates, oldest first (for
/// the trend chart). [updates] may be in any order; duplicates are dropped.
List<int> recentRrChanges(
  Iterable<CompetitiveUpdate> updates, {
  int limit = kRiotPageSize,
}) {
  final seen = <String>{};
  final newest = [
    for (final u in updates)
      if (seen.add(u.matchId)) u,
  ]..sort(compareUpdatesNewestFirst);
  return [for (final u in newest.take(limit)) u.rrEarned].reversed.toList();
}

/// Running total of [changes], starting at 0 (so `n` changes give `n + 1`
/// points): `[+20, −15]` → `[0, 20, 5]`.
List<int> cumulativeRr(List<int> changes) {
  var total = 0;
  return [0, for (final c in changes) total += c];
}
