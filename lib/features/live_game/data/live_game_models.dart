/// Typed views of the live-game endpoints (SUMMARY §6.4 G-1…G-13, EP §15):
/// session loop state, the pregame (G-3) and core-game (G-9) matches, and
/// the party (G-13) used for the "Đang tìm trận" timer.
///
/// Every parser is pure and never throws: fields are nullable, arrays may be
/// `null`, uuids are lowercased and numbers are read as `num`.
library;

import 'package:flutter/foundation.dart';

import '../../../core/util/json.dart';
import '../../../core/xmpp/xmpp_parsers.dart' show parseQueueEntryTime;

/// Where the signed-in player is (G1 detection).
enum LivePhase {
  /// G-1 returned 404: the game is not running.
  notRunning,

  /// Game running, in the menus (`loopState` MENUS).
  lobby,

  /// In the menus while the party is matchmaking (`State == MATCHMAKING`).
  queueing,

  /// Agent select (G-2 / G-3).
  pregame,

  /// Running match (G-8 / G-9).
  ingame;

  bool get inMatch => this == pregame || this == ingame;
}

/// `CharacterSelectionState` of a pregame player.
enum AgentSelection {
  none,
  selected,
  locked;

  static AgentSelection parse(Object? raw) =>
      switch (asString(raw)?.trim().toLowerCase()) {
        'selected' => selected,
        'locked' => locked,
        _ => none,
      };
}

/// One player of a live match (pregame `AllyTeam.Players[]` / core-game
/// `Players[]`).
@immutable
class LivePlayer {
  const LivePlayer({
    required this.subject,
    this.teamId,
    this.characterId,
    this.selection = AgentSelection.none,
    this.competitiveTier = 0,
    this.accountLevel,
    this.hideAccountLevel = false,
    this.incognito = false,
    this.playerCardId,
    this.playerTitleId,
    this.isCaptain = false,
    this.isCoach = false,
  });

  /// `null` without a `Subject`.
  static LivePlayer? fromJson(Object? json, {String? teamId}) {
    final m = asMap(json);
    final subject = _id(m?['Subject']);
    if (m == null || subject == null) return null;
    final identity = asMap(m['PlayerIdentity']) ?? const <String, dynamic>{};
    final level = asInt(identity['AccountLevel']);
    return LivePlayer(
      subject: subject,
      teamId: asNonEmptyString(m['TeamID'])?.trim() ?? teamId,
      characterId: _id(m['CharacterID']),
      selection: AgentSelection.parse(m['CharacterSelectionState']),
      competitiveTier: asInt(m['CompetitiveTier']) ?? 0,
      accountLevel: level == null || level <= 0 ? null : level,
      hideAccountLevel: asBool(identity['HideAccountLevel']) ?? false,
      incognito: asBool(identity['Incognito']) ?? false,
      playerCardId: _id(identity['PlayerCardID']),
      playerTitleId: _id(identity['PlayerTitleID']),
      isCaptain: asBool(m['IsCaptain']) ?? false,
      isCoach: asBool(m['IsCoach']) ?? false,
    );
  }

  /// Lowercase PUUID.
  final String subject;

  /// `Red` / `Blue` (a PUUID-like id in free-for-all modes).
  final String? teamId;

  /// Agent uuid (`null` before hovering in agent select).
  final String? characterId;
  final AgentSelection selection;

  /// Often 0 in pregame: use MMR (P-11) for the real rank (G5).
  final int competitiveTier;

  /// `null` when unknown or 0.
  final int? accountLevel;
  final bool hideAccountLevel;

  /// Streamer mode: hide the name unless self / party (SUMMARY U16).
  final bool incognito;
  final String? playerCardId;
  final String? playerTitleId;
  final bool isCaptain;
  final bool isCoach;

  bool get isLocked => selection == AgentSelection.locked;

  LivePlayer copyWith({String? characterId, AgentSelection? selection}) =>
      LivePlayer(
        subject: subject,
        teamId: teamId,
        characterId: characterId ?? this.characterId,
        selection: selection ?? this.selection,
        competitiveTier: competitiveTier,
        accountLevel: accountLevel,
        hideAccountLevel: hideAccountLevel,
        incognito: incognito,
        playerCardId: playerCardId,
        playerTitleId: playerTitleId,
        isCaptain: isCaptain,
        isCoach: isCoach,
      );

  @override
  bool operator ==(Object other) =>
      other is LivePlayer &&
      other.subject == subject &&
      other.teamId == teamId &&
      other.characterId == characterId &&
      other.selection == selection &&
      other.competitiveTier == competitiveTier &&
      other.accountLevel == accountLevel &&
      other.hideAccountLevel == hideAccountLevel &&
      other.incognito == incognito &&
      other.playerCardId == playerCardId &&
      other.playerTitleId == playerTitleId &&
      other.isCaptain == isCaptain &&
      other.isCoach == isCoach;

  @override
  int get hashCode => Object.hash(
    subject,
    teamId,
    characterId,
    selection,
    competitiveTier,
    accountLevel,
    hideAccountLevel,
    incognito,
    playerCardId,
    playerTitleId,
    isCaptain,
    isCoach,
  );
}

/// Core-game `State` values meaning the match is over.
const kFinishedCoreGameStates = {'POST_GAME', 'CLOSED'};

/// A pregame (G-3) or running (G-9) match.
@immutable
class LiveMatch {
  const LiveMatch({
    required this.matchId,
    required this.isPregame,
    required this.receivedAt,
    this.mapId,
    this.modeId,
    this.queueId,
    this.provisioningFlow,
    this.isRanked = false,
    this.state,
    this.phaseTimeRemaining,
    this.allyTeamId,
    this.players = const [],
    this.enemyTeamSize,
    this.enemyTeamLockCount,
  });

  /// G-3 body. [fallbackMatchId] is the G-2 `MatchID` (used when the body
  /// has no `ID`). `null` when no match id is known.
  static LiveMatch? fromPregame(
    Object? json, {
    String? fallbackMatchId,
    required DateTime receivedAt,
  }) {
    final m = asMap(json);
    final id = _id(m?['ID']) ?? _id(fallbackMatchId);
    if (m == null || id == null) return null;
    final ally = asMap(m['AllyTeam']);
    final allyTeamId = asNonEmptyString(ally?['TeamID'])?.trim();
    final players = <String, LivePlayer>{};
    void add(Object? list, String? teamId) {
      for (final raw in asList(list)) {
        final p = LivePlayer.fromJson(raw, teamId: teamId);
        if (p == null || p.isCoach) continue;
        // `Teams[]` repeats the ally players: keep the first (richer) copy.
        players.putIfAbsent(p.subject, () => p);
      }
    }

    add(ally?['Players'], allyTeamId);
    final enemy = asMap(m['EnemyTeam']);
    add(enemy?['Players'], asNonEmptyString(enemy?['TeamID'])?.trim());
    for (final team in asMapList(m['Teams'])) {
      add(team['Players'], asNonEmptyString(team['TeamID'])?.trim());
    }
    final ns = asNum(m['PhaseTimeRemainingNS']);
    return LiveMatch(
      matchId: id,
      isPregame: true,
      receivedAt: receivedAt,
      mapId: asNonEmptyString(m['MapID']),
      modeId: asNonEmptyString(m['Mode']) ?? asNonEmptyString(m['ModeID']),
      queueId: asString(m['QueueID'])?.trim().toLowerCase(),
      provisioningFlow: asNonEmptyString(m['ProvisioningFlowID']),
      isRanked: asBool(m['IsRanked']) ?? false,
      state: asNonEmptyString(m['PregameState']),
      phaseTimeRemaining: ns == null || !ns.isFinite || ns < 0
          ? null
          : Duration(microseconds: (ns / 1000).round()),
      allyTeamId: allyTeamId,
      players: List.unmodifiable(players.values),
      enemyTeamSize: asInt(m['EnemyTeamSize']),
      enemyTeamLockCount: asInt(m['EnemyTeamLockCount']),
    );
  }

  /// G-9 body. [selfPuuid] identifies the ally team. `null` when no match
  /// id is known.
  static LiveMatch? fromCoreGame(
    Object? json, {
    String? fallbackMatchId,
    required String selfPuuid,
    required DateTime receivedAt,
  }) {
    final m = asMap(json);
    final id = _id(m?['MatchID']) ?? _id(fallbackMatchId);
    if (m == null || id == null) return null;
    final players = <String, LivePlayer>{};
    for (final raw in asList(m['Players'])) {
      final p = LivePlayer.fromJson(raw);
      if (p == null || p.isCoach) continue;
      players.putIfAbsent(p.subject, () => p);
    }
    final self = players[selfPuuid.trim().toLowerCase()];
    final queue = asString(asMap(m['MatchmakingData'])?['QueueID']);
    return LiveMatch(
      matchId: id,
      isPregame: false,
      receivedAt: receivedAt,
      mapId: asNonEmptyString(m['MapID']),
      modeId: asNonEmptyString(m['ModeID']),
      queueId: queue?.trim().toLowerCase(),
      provisioningFlow:
          asNonEmptyString(m['ProvisioningFlow']) ??
          asNonEmptyString(m['ProvisioningFlowID']),
      state: asNonEmptyString(m['State'])?.trim().toUpperCase(),
      allyTeamId: self?.teamId,
      players: List.unmodifiable(players.values),
    );
  }

  final String matchId;
  final bool isPregame;
  final DateTime receivedAt;

  /// Map path (`/Game/Maps/Ascent/Ascent`) → `ContentDb.mapByUrl`.
  final String? mapId;

  /// Game-mode path → `ContentDb.gameModeByPath`.
  final String? modeId;

  /// Lowercase queue id; `""` / `null` for custom games.
  final String? queueId;
  final String? provisioningFlow;
  final bool isRanked;

  /// `PregameState` (pregame) or `State` (core game, upper case).
  final String? state;

  /// Agent-select timer at [receivedAt].
  final Duration? phaseTimeRemaining;

  /// Team of the signed-in player.
  final String? allyTeamId;
  final List<LivePlayer> players;
  final int? enemyTeamSize;
  final int? enemyTeamLockCount;

  /// When the agent-select phase ends (local clock).
  DateTime? get phaseEndsAt {
    final r = phaseTimeRemaining;
    return r == null ? null : receivedAt.add(r);
  }

  /// POST_GAME / CLOSED core game (G11: show the final scoreboard).
  bool get isFinished =>
      !isPregame && kFinishedCoreGameStates.contains(state?.toUpperCase());

  bool get isCustomGame =>
      provisioningFlow?.toLowerCase() == 'customgame' ||
      (queueId ?? '').isEmpty;

  LivePlayer? player(String puuid) {
    final id = puuid.trim().toLowerCase();
    for (final p in players) {
      if (p.subject == id) return p;
    }
    return null;
  }

  /// Returns a copy where [puuid] hovers / locks [agentId] (optimistic
  /// update after G-4 / G-5 when Riot's answer is not a match body).
  LiveMatch withSelection(
    String puuid,
    String agentId,
    AgentSelection selection,
  ) {
    final id = puuid.trim().toLowerCase();
    return LiveMatch(
      matchId: matchId,
      isPregame: isPregame,
      receivedAt: receivedAt,
      mapId: mapId,
      modeId: modeId,
      queueId: queueId,
      provisioningFlow: provisioningFlow,
      isRanked: isRanked,
      state: state,
      phaseTimeRemaining: phaseTimeRemaining,
      allyTeamId: allyTeamId,
      players: List.unmodifiable([
        for (final p in players)
          p.subject == id
              ? p.copyWith(
                  characterId: agentId.toLowerCase(),
                  selection: selection,
                )
              : p,
      ]),
      enemyTeamSize: enemyTeamSize,
      enemyTeamLockCount: enemyTeamLockCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiveMatch &&
      other.matchId == matchId &&
      other.isPregame == isPregame &&
      other.receivedAt == receivedAt &&
      other.mapId == mapId &&
      other.modeId == modeId &&
      other.queueId == queueId &&
      other.provisioningFlow == provisioningFlow &&
      other.isRanked == isRanked &&
      other.state == state &&
      other.phaseTimeRemaining == phaseTimeRemaining &&
      other.allyTeamId == allyTeamId &&
      listEquals(other.players, players) &&
      other.enemyTeamSize == enemyTeamSize &&
      other.enemyTeamLockCount == enemyTeamLockCount;

  @override
  int get hashCode => Object.hash(
    matchId,
    isPregame,
    receivedAt,
    mapId,
    modeId,
    queueId,
    state,
    Object.hashAll(players),
  );
}

/// The signed-in player's party (G-12 / G-13), read in the menus for the
/// queue timer and during a match for party badges.
@immutable
class LiveParty {
  const LiveParty({
    required this.partyId,
    this.members = const {},
    this.state,
    this.queueId,
    this.queueEntryTime,
  });

  /// G-13 body; `null` without an `ID`.
  static LiveParty? fromJson(Object? json) {
    final m = asMap(json);
    final id = _id(m?['ID']);
    if (m == null || id == null) return null;
    return LiveParty(
      partyId: id,
      members: {
        for (final member in asMapList(m['Members'])) ?_id(member['Subject']),
      },
      state: asNonEmptyString(m['State'])?.trim().toUpperCase(),
      queueId: asString(asMap(m['MatchmakingData'])?['QueueID'])
          ?.trim()
          .toLowerCase(),
      queueEntryTime: parseQueueEntryTime(m['QueueEntryTime']),
    );
  }

  final String partyId;

  /// Lowercase PUUIDs of the members.
  final Set<String> members;

  /// `DEFAULT`, `MATCHMAKING`, `MATCHMADE_GAME_STARTING`, …
  final String? state;
  final String? queueId;

  /// When the party entered the queue (UTC).
  final DateTime? queueEntryTime;

  bool get isMatchmaking => state == 'MATCHMAKING';

  bool get isMatchFound => state == 'MATCHMADE_GAME_STARTING';

  @override
  bool operator ==(Object other) =>
      other is LiveParty &&
      other.partyId == partyId &&
      setEquals(other.members, members) &&
      other.state == state &&
      other.queueId == queueId &&
      other.queueEntryTime == queueEntryTime;

  @override
  int get hashCode => Object.hash(
    partyId,
    Object.hashAllUnordered(members),
    state,
    queueId,
    queueEntryTime,
  );
}

/// The last match that finished while the app watched it (G11).
@immutable
class LiveEndedMatch {
  const LiveEndedMatch({
    required this.matchId,
    required this.endedAt,
    this.mapId,
    this.modeId,
    this.queueId,
  });

  factory LiveEndedMatch.of(LiveMatch match, DateTime endedAt) =>
      LiveEndedMatch(
        matchId: match.matchId,
        endedAt: endedAt,
        mapId: match.mapId,
        modeId: match.modeId,
        queueId: match.queueId,
      );

  final String matchId;
  final DateTime endedAt;
  final String? mapId;
  final String? modeId;
  final String? queueId;

  @override
  bool operator ==(Object other) =>
      other is LiveEndedMatch &&
      other.matchId == matchId &&
      other.endedAt == endedAt &&
      other.mapId == mapId &&
      other.modeId == modeId &&
      other.queueId == queueId;

  @override
  int get hashCode => Object.hash(matchId, endedAt, mapId, modeId, queueId);
}

/// One poll of the live-game endpoints.
@immutable
class LiveGameState {
  const LiveGameState({
    required this.phase,
    required this.receivedAt,
    this.match,
    this.party,
    this.ended,
  });

  final LivePhase phase;
  final DateTime receivedAt;

  /// Set in [LivePhase.pregame] / [LivePhase.ingame].
  final LiveMatch? match;

  /// Best effort, in the menus only.
  final LiveParty? party;

  /// Last finished match (kept for [kEndedMatchRetention]; cleared when a
  /// new match starts).
  final LiveEndedMatch? ended;

  String? get matchId => match?.matchId;

  /// When the party entered the queue ([LivePhase.queueing] only).
  DateTime? get queueEntryTime =>
      phase == LivePhase.queueing ? party?.queueEntryTime : null;

  LiveGameState copyWith({LiveMatch? match}) => LiveGameState(
    phase: phase,
    receivedAt: receivedAt,
    match: match ?? this.match,
    party: party,
    ended: ended,
  );

  @override
  bool operator ==(Object other) =>
      other is LiveGameState &&
      other.phase == phase &&
      other.receivedAt == receivedAt &&
      other.match == match &&
      other.party == party &&
      other.ended == ended;

  @override
  int get hashCode => Object.hash(phase, receivedAt, match, party, ended);
}

/// How long the final scoreboard of a finished match stays available.
const kEndedMatchRetention = Duration(hours: 1);

String? _id(Object? value) {
  final id = lowerUuid(value)?.trim();
  return id == null || id.isEmpty ? null : id;
}
