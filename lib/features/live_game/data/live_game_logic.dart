/// Pure helpers of the live-game screens: team split, party groups, status
/// lines, live score freshness and agent-grid tile states.
library;

import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/util/format.dart';
import '../../../core/xmpp/xmpp_models.dart';
import '../../../core/l10n/l10n.dart';
import 'live_game_models.dart';

// ------------------------------------------------------------------ teams

/// Players of a live match split for the roster tabs (G5).
@immutable
class LiveTeams {
  const LiveTeams({
    required this.ally,
    required this.enemy,
    this.isFreeForAll = false,
  });

  /// Your team (you first); every player in free-for-all modes.
  final List<LivePlayer> ally;
  final List<LivePlayer> enemy;

  /// Deathmatch-like: every player has their own team id.
  final bool isFreeForAll;
}

/// Splits [match] into your team and the enemy team. In free-for-all modes
/// (more than two team ids) everyone is in [LiveTeams.ally].
LiveTeams splitTeams(LiveMatch match, String selfPuuid) {
  final self = selfPuuid.trim().toLowerCase();
  final teamIds = {
    for (final p in match.players)
      if (p.teamId != null) p.teamId!,
  };
  List<LivePlayer> selfFirst(Iterable<LivePlayer> players) =>
      [...players]..sort((a, b) {
        if (a.subject == self) return -1;
        if (b.subject == self) return 1;
        return 0;
      });
  if (teamIds.length > 2) {
    return LiveTeams(
      ally: selfFirst(match.players),
      enemy: const [],
      isFreeForAll: true,
    );
  }
  final allyTeam = match.allyTeamId ?? match.player(self)?.teamId;
  if (allyTeam == null) {
    return LiveTeams(ally: selfFirst(match.players), enemy: const []);
  }
  return LiveTeams(
    ally: selfFirst(match.players.where((p) => p.teamId == allyTeam)),
    enemy: [
      for (final p in match.players)
        if (p.teamId != allyTeam) p,
    ],
  );
}

// ---------------------------------------------------------------- parties

/// Party badges: group index (0, 1, …) of every player of [subjects] whose
/// party ([partyOf], PUUID → party id) has at least two players in the
/// match. Solo players get no entry. Groups are numbered in [subjects]
/// order.
Map<String, int> partyGroups({
  required Iterable<String> subjects,
  required Map<String, String> partyOf,
}) {
  final ids = [for (final s in subjects) s.trim().toLowerCase()];
  final counts = <String, int>{};
  for (final s in ids) {
    final party = partyOf[s];
    if (party != null) counts[party] = (counts[party] ?? 0) + 1;
  }
  final groupOfParty = <String, int>{};
  final out = <String, int>{};
  for (final s in ids) {
    final party = partyOf[s];
    if (party == null || (counts[party] ?? 0) < 2) continue;
    out[s] = groupOfParty.putIfAbsent(party, () => groupOfParty.length);
  }
  return out;
}

// ------------------------------------------------------------ live score

/// Round score of the running match (G7).
@immutable
class LiveScore {
  const LiveScore(this.ally, this.enemy);

  final int ally;
  final int enemy;

  String text(AppLocalizations l10n) => l10n.liveGameScore(ally, enemy);

  @override
  bool operator ==(Object other) =>
      other is LiveScore && other.ally == ally && other.enemy == enemy;

  @override
  int get hashCode => Object.hash(ally, enemy);
}

/// Presences older than this are not trusted for the live score (U9).
const kLiveScoreMaxAge = Duration(minutes: 2);

/// Live score from the player's own game-client presence (SUMMARY U9):
/// only in a match, never `0 – 0`, and only when the presence is fresh.
LiveScore? liveScoreOf(FriendPresence? presence, {required DateTime now}) {
  final v = presence?.valorant;
  if (presence == null || v == null || !v.hasScore) return null;
  final at = presence.timestamp ?? presence.receivedAt;
  if (now.toUtc().difference(at.toUtc()) > kLiveScoreMaxAge) return null;
  return LiveScore(v.allyScore!, v.enemyScore!);
}

// ----------------------------------------------------------- labels

/// "Thi đấu xếp hạng" / "Chơi tự do" / the custom game's mode name (G9).
String liveModeLabel(
  AppLocalizations l10n,
  ContentDb db, {
  String? queueId,
  String? modeId,
}) {
  final q = (queueId ?? '').trim();
  if (q.isNotEmpty) return db.queueName(l10n, q);
  final mode = db.gameModeByPath(modeId)?.displayName;
  if (mode != null && mode.trim().isNotEmpty) return mode;
  return db.queueName(l10n, '');
}

/// Map display name, `null` when unknown.
String? liveMapName(ContentDb db, String? mapId) {
  final name = db.mapByUrl(mapId)?.displayName.trim();
  return name == null || name.isEmpty ? null : name;
}

/// Status line of the "Trận hiện tại" card (SUMMARY §9.9, VF §6.5):
/// "Không trong trận", "Đang ở sảnh chờ", "Đang tìm trận · 01:32",
/// "Đang chọn đặc vụ · Ascent", "Đang đấu · Lotus · 8 – 4".
String currentGameStatusText(
  AppLocalizations l10n,
  LiveGameState state,
  ContentDb db, {
  required DateTime now,
  LiveScore? score,
}) {
  if (state.phase == LivePhase.queueing &&
      (state.party?.isMatchFound ?? false)) {
    return l10n.socialMatchFound;
  }
  final map = liveMapName(db, state.match?.mapId);
  return switch (state.phase) {
    LivePhase.notRunning => l10n.liveGameNotInGame,
    LivePhase.lobby => l10n.liveGameInLobby,
    LivePhase.queueing => switch (state.queueEntryTime) {
      final DateTime at => l10n.liveGameInQueueFor(
        formatMinutesSeconds(now.toUtc().difference(at.toUtc())),
      ),
      null => l10n.liveGameInQueue,
    },
    LivePhase.pregame => _joinStatus([l10n.liveGameAgentSelect, ?map]),
    LivePhase.ingame => _joinStatus([
      l10n.liveGameInMatch,
      ?map,
      if (score != null) score.text(l10n),
    ]),
  };
}

// ---------------------------------------------------------- agent grid

/// How one agent tile of the agent-select grid (G4) looks and reacts.
enum AgentTileState {
  /// Can be hovered / locked.
  available,

  /// Your current hover.
  hovered,

  /// Your locked agent.
  locked,

  /// Locked by a teammate (dimmed, disabled).
  taken,

  /// Not owned (dimmed, disabled).
  notOwned,

  /// You already locked another agent (disabled).
  disabled;

  bool get isEnabled => this == available || this == hovered;
  bool get isDimmed => this == taken || this == notOwned || this == disabled;
}

/// State of [agentId]'s tile for [self] in [match]. [owned] = owned agent
/// uuids (starters included); `null` while unknown (everything is allowed
/// then and Riot validates the lock).
AgentTileState agentTileState({
  required String agentId,
  required LiveMatch match,
  required String self,
  Set<String>? owned,
}) {
  final id = agentId.toLowerCase();
  final me = match.player(self);
  final mine = me?.characterId == id;
  if (me != null && me.isLocked) {
    return mine ? AgentTileState.locked : AgentTileState.disabled;
  }
  final takenByMate = match.players.any(
    (p) =>
        p.subject != me?.subject &&
        p.teamId == (me?.teamId ?? match.allyTeamId) &&
        p.isLocked &&
        p.characterId == id,
  );
  if (takenByMate) return AgentTileState.taken;
  if (owned != null && !owned.contains(id)) return AgentTileState.notOwned;
  return mine ? AgentTileState.hovered : AgentTileState.available;
}

/// Agents of the grid: playable agents (with a role) by name.
List<Agent> selectableAgents(ContentDb db) =>
    [
      for (final a in db.agents)
        if (a.role != null && a.displayName.trim().isNotEmpty) a,
    ]..sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

// Separator is neutral punctuation; wording comes from the supplied resources.
String _joinStatus(Iterable<String> parts) =>
    parts.where((s) => s.isNotEmpty).join(' · ');
