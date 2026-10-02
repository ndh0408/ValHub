import 'package:flutter/foundation.dart';

import 'battlepass_models.dart';

/// How fast the player must earn XP to finish a pass before it ends
/// (ValHub extra, like ValBuddy's "XP/day").
@immutable
class XpPace {
  const XpPace({required this.daysLeft, required this.xpPerDay});

  /// Whole days left (the last partial day counts as one), ≥ 1.
  final int daysLeft;

  /// XP needed per remaining day (ceil).
  final int xpPerDay;
}

/// [XpPace] of [progress] for a pass ending at [endsAt]; `null` when the
/// pass is complete, has no XP left, has no end date or already ended.
XpPace? xpPaceOf(PassProgress progress, DateTime? endsAt, DateTime now) {
  final end = endsAt;
  if (end == null || progress.isComplete) return null;
  final left = progress.xpRemaining;
  if (left <= 0) return null;
  final remaining = end.difference(now);
  if (remaining <= Duration.zero) return null;
  final days = (remaining.inMinutes / Duration.minutesPerDay).ceil();
  final d = days < 1 ? 1 : days;
  return XpPace(daysLeft: d, xpPerDay: (left / d).ceil());
}
