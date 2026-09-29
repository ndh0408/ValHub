/// Battle Pass card model (docs/design/HOME.md §5.4). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../battlepass/data/battlepass_models.dart';
import '../../battlepass/data/daily_ticket.dart';
import '../../battlepass/data/xp_pace.dart';

/// Weekly missions listed on the card, the closest to done first.
const kHomeMaxMissions = 2;

/// What the Battle Pass card shows.
@immutable
class HomeBpSnapshot {
  const HomeBpSnapshot({
    required this.pass,
    required this.isEvent,
    required this.nearlyDone,
    required this.allMissionsDone,
    required this.isFromCache,
    required this.receivedAt,
    this.eventName,
    this.endsAt,
    this.pace,
    this.daysLeft,
    this.missionsRefillAt,
    this.checkpointsDone,
    this.eventLine,
    this.contractId,
  });

  /// The pass on the card: the current Battle Pass, or an event pass once
  /// the Battle Pass is complete.
  final PassProgress pass;
  final bool isEvent;
  final String? eventName;

  /// When the pass ends (act end / event end).
  final DateTime? endsAt;

  /// XP needed per remaining day; `null` when it cannot be computed.
  final XpPace? pace;

  /// Whole days left (the last partial day counts as one).
  final int? daysLeft;

  /// Incomplete weekly missions, the closest to done first (≤ 2).
  final List<WeeklyMissionView> nearlyDone;
  final DateTime? missionsRefillAt;
  final bool allMissionsDone;

  /// Daily checkpoints reached today (only with a valid, unexpired ticket).
  final int? checkpointsDone;

  /// An active, incomplete event pass shown under the Battle Pass.
  final EventPassInfo? eventLine;

  /// Contract uuid of [pass] (the rewards page of an event pass).
  final String? contractId;
  final bool isFromCache;
  final DateTime receivedAt;
}

/// The Battle Pass card from [overview]. The current Battle Pass is primary
/// while it is incomplete; otherwise the first active incomplete event pass
/// (`isEvent`); otherwise `null` (the card is hidden).
HomeBpSnapshot? buildHomeBpSnapshot(
  BattlePassOverview overview, {
  DailyTicket? ticket,
  required DateTime now,
}) {
  final bp = overview.battlePass;
  final events = [
    for (final e in overview.eventPasses)
      if (!e.progress.isComplete) e,
  ];

  PassProgress? pass;
  DateTime? endsAt;
  String? eventName;
  var isEvent = false;
  EventPassInfo? eventLine;
  if (bp != null && !bp.isComplete) {
    pass = bp;
    endsAt = overview.actEndsAt;
    eventLine = events.firstOrNull;
  } else if (events.isNotEmpty) {
    final e = events.first;
    pass = e.progress;
    endsAt = e.endsAt;
    eventName = e.eventName;
    isEvent = true;
  }
  if (pass == null) return null;

  final pace = xpPaceOf(pass, endsAt, now);
  int? daysLeft = pace?.daysLeft;
  if (daysLeft == null && endsAt != null && endsAt.isAfter(now)) {
    final d = (endsAt.difference(now).inMinutes / Duration.minutesPerDay)
        .ceil();
    daysLeft = d < 1 ? 1 : d;
  }

  final open =
      [
        for (final m in overview.weekly.missions)
          if (!m.isComplete) m,
      ]..sort((a, b) {
        final byFraction = b.fraction.compareTo(a.fraction);
        return byFraction != 0 ? byFraction : b.xpGrant.compareTo(a.xpGrant);
      });

  final validTicket =
      ticket != null && ticket.hasMilestones && !ticket.isExpired(now)
      ? ticket
      : null;
  return HomeBpSnapshot(
    pass: pass,
    isEvent: isEvent,
    eventName: eventName,
    endsAt: endsAt,
    pace: pace,
    daysLeft: daysLeft,
    nearlyDone: List.unmodifiable(open.take(kHomeMaxMissions)),
    missionsRefillAt: overview.weekly.refillAt,
    allMissionsDone: overview.weekly.isAllComplete,
    checkpointsDone: validTicket?.completedCount,
    eventLine: eventLine,
    contractId: pass.contract.uuid,
    isFromCache: overview.contracts.isFromCache,
    receivedAt: overview.contracts.receivedAt,
  );
}
