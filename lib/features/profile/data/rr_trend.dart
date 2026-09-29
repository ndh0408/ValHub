import '../../../core/domain/competitive/competitive.dart';

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

/// The Daily RR entry of the local day of [now] (`null` without ranked
/// matches today).
DailyRr? dailyRrOn(List<DailyRr> days, DateTime now) {
  final local = now.toLocal();
  final today = DateTime(local.year, local.month, local.day);
  for (final d in days) {
    if (d.date == today) return d;
  }
  return null;
}
