import 'package:flutter/foundation.dart';

import '../../../core/util/countdown.dart';
import '../../../core/util/json.dart';

/// Number of daily checkpoints (EP §12.2).
const kDailyCheckpointCount = 4;

/// Charges needed to complete one checkpoint.
const kChargesPerCheckpoint = 4;

/// One daily checkpoint ("Cột mốc").
@immutable
class DailyMilestone {
  const DailyMilestone({this.progress = 0, this.bonusApplied = false});

  static DailyMilestone fromJson(Object? json) {
    final m = asMap(json);
    final p = asInt(m?['Progress']) ?? 0;
    return DailyMilestone(
      progress: p.clamp(0, kChargesPerCheckpoint),
      bonusApplied: asBool(m?['BonusApplied']) ?? false,
    );
  }

  /// Charges 0…4 (clamped).
  final int progress;

  /// The 2× catch-up bonus was applied to this checkpoint.
  final bool bonusApplied;

  bool get isComplete => progress >= kChargesPerCheckpoint;

  /// Fill of this checkpoint, 0–1.
  double get fraction => progress / kChargesPerCheckpoint;
}

/// Typed P-16 `GET /daily-ticket/v1/{puuid}` (SUMMARY §8.4 P4, U6).
///
/// The wrapper key is UNVERIFIED, so this reads `DailyRewards ?? root`.
/// `Milestones` is padded / truncated to exactly four checkpoints.
@immutable
class DailyTicket {
  const DailyTicket({
    required this.milestones,
    required this.receivedAt,
    this.expiresAt,
    this.bonusMilestonesPending = 0,
    this.hasMilestones = true,
  });

  factory DailyTicket.fromJson(Object? json, {required DateTime receivedAt}) {
    final root = asMap(json) ?? const <String, dynamic>{};
    final m = root.obj('DailyRewards') ?? root;
    final raw = m.list('Milestones');
    final parsed = [for (final x in raw) DailyMilestone.fromJson(x)];
    final milestones = <DailyMilestone>[
      for (var i = 0; i < kDailyCheckpointCount; i++)
        i < parsed.length ? parsed[i] : const DailyMilestone(),
    ];
    final bonus = m.integer('BonusMilestonesPending') ?? 0;
    return DailyTicket(
      milestones: List.unmodifiable(milestones),
      receivedAt: receivedAt,
      expiresAt: Deadline.fromSeconds(
        m['RemainingLifetimeSeconds'],
        receivedAt: receivedAt,
      )?.expiresAt,
      bonusMilestonesPending: bonus < 0 ? 0 : bonus,
      hasMilestones: raw.isNotEmpty,
    );
  }

  /// Always [kDailyCheckpointCount] entries.
  final List<DailyMilestone> milestones;
  final DateTime receivedAt;

  /// When today's ticket expires (`receivedAt + RemainingLifetimeSeconds`).
  /// `null` when the field was missing.
  final DateTime? expiresAt;

  /// Pending 2× catch-up bonuses.
  final int bonusMilestonesPending;

  /// `false` when the payload carried no `Milestones` at all.
  final bool hasMilestones;

  /// Completed checkpoints, 0…4.
  int get completedCount => milestones.where((m) => m.isComplete).length;

  bool get isAllComplete => completedCount >= kDailyCheckpointCount;

  /// Index of the checkpoint being filled (`null` when all are complete).
  int? get currentIndex {
    for (var i = 0; i < milestones.length; i++) {
      if (!milestones[i].isComplete) return i;
    }
    return null;
  }

  /// Charges in the checkpoint being filled (0 when all are complete).
  int get currentCharges {
    final i = currentIndex;
    return i == null ? 0 : milestones[i].progress;
  }

  /// The ticket ran out (`RemainingLifetimeSeconds <= 0`), so it shows the
  /// previous day until the game (or a user-initiated renew) creates a new
  /// one.
  bool isExpired(DateTime now) {
    final e = expiresAt;
    return e != null && !now.isBefore(e);
  }
}

/// SUMMARY U6: `renew` only when the GET 404s or the ticket expired, and at
/// most once per day. [lastRenewAt] is the previous renew on this device.
bool canRenewDailyTicket({
  required DailyTicket? ticket,
  required DateTime now,
  DateTime? lastRenewAt,
}) {
  final needed = ticket == null || ticket.isExpired(now);
  if (!needed) return false;
  if (lastRenewAt == null) return true;
  return now.difference(lastRenewAt) >= kDailyTicketRenewInterval;
}

/// Minimum time between two renews (once per daily reset).
const kDailyTicketRenewInterval = Duration(hours: 20);
