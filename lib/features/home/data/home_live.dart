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

  /// The match is over: the card shows "Trận vừa rồi" for
  /// [kHomeEndedShownFor] after it (the player is back in the lobby or
  /// closed the game).
  bool get isEnded => phase == LivePhase.lobby || phase == LivePhase.notRunning;

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

/// How long Home keeps "Trận vừa rồi" after a match ended.
const kHomeEndedShownFor = Duration(minutes: 20);

/// The live card's snapshot: queueing, agent select, a running match, or
/// the match that just ended (for [kHomeEndedShownFor], given [now]);
/// `null` otherwise. Never throws: an unknown map or agent just leaves the
/// field empty.
HomeLiveSnapshot? homeLiveSnapshotOf(
  LiveGameState state,
  ContentDb db, {
  required String self,
  DateTime? now,
}) {
  final match = state.match;
  switch (state.phase) {
    case LivePhase.notRunning || LivePhase.lobby:
      final ended = state.ended;
      if (ended == null ||
          now == null ||
          now.difference(ended.endedAt) > kHomeEndedShownFor) {
        return null;
      }
      return HomeLiveSnapshot(
        phase: state.phase,
        queueId: ended.queueId,
        modeId: ended.modeId,
        mapName: liveMapName(db, ended.mapId),
        mapSplash: db.mapByUrl(ended.mapId)?.splash,
        matchId: ended.matchId,
      );
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
