import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/store_history.dart';

/// A skin and how many recorded daily rotations offered it.
@immutable
class OfferedSkin {
  const OfferedSkin({
    required this.levelUuid,
    required this.times,
    required this.lastSeen,
    this.vp,
  });

  /// Level-1 uuid as the store sells it (opens the skin sheet).
  final String levelUuid;
  final int times;
  final DateTime lastSeen;

  /// Price of the newest of those rotations.
  final int? vp;
}

/// The skins the user's own daily shop offered most often in the recorded
/// rotations, most often first (ties: seen most recently). Only skins seen
/// at least [minTimes] times: one appearance says nothing about frequency.
List<OfferedSkin> mostOfferedSkins(
  StoreHistory history,
  ContentDb db, {
  int limit = 3,
  int minTimes = 2,
}) {
  final byKey = <String, ({String level, int times, DateTime last, int? vp})>{};
  for (final day in history.days) {
    for (final offer in day.daily) {
      // Group by skin, not level: any level of the skin is the same skin.
      final key =
          db.skinByLevelUuid(offer.skinLevelUuid)?.uuid ?? offer.skinLevelUuid;
      final prior = byKey[key];
      final newer = prior == null || day.lastSeen.isAfter(prior.last);
      byKey[key] = (
        level: newer ? offer.skinLevelUuid : prior.level,
        times: (prior?.times ?? 0) + 1,
        last: newer ? day.lastSeen : prior.last,
        vp: newer ? offer.vp : prior.vp,
      );
    }
  }
  final list = [
    for (final e in byKey.values)
      if (e.times >= minTimes)
        OfferedSkin(
          levelUuid: e.level,
          times: e.times,
          lastSeen: e.last,
          vp: e.vp,
        ),
  ];
  list.sort((a, b) {
    final c = b.times.compareTo(a.times);
    if (c != 0) return c;
    final d = b.lastSeen.compareTo(a.lastSeen);
    return d != 0 ? d : a.levelUuid.compareTo(b.levelUuid);
  });
  return list.length <= limit ? list : list.sublist(0, limit);
}

/// Total VP of a recorded daily rotation (`null` when a price is missing).
int? dailyTotalVp(StoreHistoryDay day) {
  var total = 0;
  for (final o in day.daily) {
    final vp = o.vp;
    if (vp == null) return null;
    total += vp;
  }
  return day.daily.isEmpty ? null : total;
}

/// The best Night Market discount of a recorded rotation (whole percent),
/// `null` without a Night Market or a known discount.
int? bestNightDiscount(StoreHistoryDay day) {
  int? best;
  for (final o in day.nightMarket) {
    if (o.percent <= 0) continue;
    if (best == null || o.percent > best) best = o.percent;
  }
  return best;
}
