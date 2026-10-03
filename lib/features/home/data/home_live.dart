/// "Trận hiện tại" card model (docs/design/HOME.md §5.1). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../live_game/data/live_game_logic.dart';
import '../../live_game/data/live_game_models.dart';

/// What the live card shows while the player queues, picks an agent or plays.
@immutable
class HomeLiveSnapshot {
  const HomeLiveSnapshot({
    required this.phase,
    this.queueId,
    this.modeId,
    this.mapName,
    this.mapSplash,
    this.queueEntryTime,
    this.phaseEndsAt,
    this.myAgentId,
    this.myAgentLocked = false,
    this.matchId,
  });

  /// [LivePhase.queueing], [LivePhase.pregame] or [LivePhase.ingame].
  final LivePhase phase;
  final String? queueId;
  final String? modeId;
  final String? mapName;
  final String? mapSplash;

  /// When the party entered the queue (queueing only).
  final DateTime? queueEntryTime;

  /// When agent select ends (pregame only).
  final DateTime? phaseEndsAt;

  /// The agent the player hovers / locked (pregame only).
  final String? myAgentId;
  final bool myAgentLocked;
  final String? matchId;

  @override
  bool operator ==(Object other) =>
      other is HomeLiveSnapshot &&
      other.phase == phase &&
      other.queueId == queueId &&
      other.modeId == modeId &&
      other.mapName == mapName &&
      other.mapSplash == mapSplash &&
      other.queueEntryTime == queueEntryTime &&
      other.phaseEndsAt == phaseEndsAt &&
      other.myAgentId == myAgentId &&
      other.myAgentLocked == myAgentLocked &&
      other.matchId == matchId;

  @override
  int get hashCode => Object.hash(
    phase,
    queueId,
    modeId,
    mapName,
    mapSplash,
    queueEntryTime,
    phaseEndsAt,
    myAgentId,
    myAgentLocked,
    matchId,
  );
}

/// The live card's snapshot; `null` unless the phase is queueing, pregame or
/// ingame (lobby and "game not running" show nothing on Home). Never throws:
/// an unknown map or agent just leaves the field empty.
HomeLiveSnapshot? homeLiveSnapshotOf(
  LiveGameState state,
  ContentDb db, {
  required String self,
}) {
  final match = state.match;
  switch (state.phase) {
    case LivePhase.notRunning || LivePhase.lobby:
      return null;
    case LivePhase.queueing:
      return HomeLiveSnapshot(
        phase: LivePhase.queueing,
        queueId: state.party?.queueId,
        queueEntryTime: state.queueEntryTime,
      );
    case LivePhase.pregame || LivePhase.ingame:
      if (match == null || match.isFinished) return null;
      final me = match.player(self);
      final pregame = state.phase == LivePhase.pregame;
      return HomeLiveSnapshot(
        phase: state.phase,
        queueId: match.queueId,
        modeId: match.modeId,
        mapName: liveMapName(db, match.mapId),
        mapSplash: db.mapByUrl(match.mapId)?.splash,
        phaseEndsAt: pregame ? match.phaseEndsAt : null,
        myAgentId: pregame ? me?.characterId : null,
        myAgentLocked: pregame && (me?.isLocked ?? false),
        matchId: match.matchId,
      );
  }
}
