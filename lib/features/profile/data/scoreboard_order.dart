import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';

/// How a scoreboard block relates to the viewer (the widget turns it into a
/// title: "Đội của bạn", "Đội địch", or the team's own name).
enum SideRelation { yours, enemy, neutral }

/// One block of the scoreboard: a team (or the whole Deathmatch lobby) with
/// its players already in display order.
@immutable
class ScoreboardSide {
  const ScoreboardSide({
    required this.relation,
    required this.players,
    this.teamId,
    this.score,
    this.outcome,
    this.freeForAll = false,
  });

  /// `null` for the free-for-all lobby of Deathmatch.
  final String? teamId;
  final SideRelation relation;
  final List<MatchPlayer> players;

  /// Rounds won (points in Team Deathmatch / Escalation, and after a
  /// surrender the rounds actually won); `null` when the team is unknown.
  final int? score;

  /// `win` for the winning team, `loss` when the other team won, `null`
  /// when nobody won (draw, unfinished).
  final MatchOutcome? outcome;

  /// Deathmatch: one list ranked by kills, no teams.
  final bool freeForAll;
}

/// The scoreboard's blocks from [perspective]'s point of view (PR-15): the
/// viewer's team first, then the other; Deathmatch is one lobby ranked by
/// kills, then score. Spectators and unknown viewers see the teams in
/// `teams[]` order. Empty for a match without participants.
List<ScoreboardSide> scoreboardOrder(
  MatchDetails details,
  String? perspective,
) {
  final players = details.participants;
  if (players.isEmpty) return const [];
  if (details.modeKind == MatchModeKind.deathmatch) {
    final ranked = [...players]
      ..sort((a, b) {
        final ka = details.statsFor(a.subject)?.kills ?? 0;
        final kb = details.statsFor(b.subject)?.kills ?? 0;
        final c = kb.compareTo(ka);
        return c != 0
            ? c
            : (details.statsFor(b.subject)?.score ?? 0).compareTo(
                details.statsFor(a.subject)?.score ?? 0,
              );
      });
    return [
      ScoreboardSide(
        relation: SideRelation.neutral,
        players: List.unmodifiable(ranked),
        freeForAll: true,
      ),
    ];
  }

  final me = details.player(perspective);
  final myTeam = me == null || me.isObserver ? null : me.teamId;
  final ids = details.sideIds;
  final ordered = [
    if (myTeam != null && ids.contains(myTeam)) myTeam,
    for (final id in ids)
      if (id != myTeam) id,
  ];
  final anyWinner = details.teams.any((t) => t.won);
  final out = <ScoreboardSide>[];
  for (final id in ordered) {
    final teamPlayers = details.playersOfTeam(id);
    if (teamPlayers.isEmpty) continue;
    final team = details.team(id);
    out.add(
      ScoreboardSide(
        teamId: id,
        relation: myTeam == null
            ? SideRelation.neutral
            : id == myTeam
            ? SideRelation.yours
            : SideRelation.enemy,
        players: List.unmodifiable(teamPlayers),
        score: team == null ? null : details.teamScore(id),
        outcome: team == null
            ? null
            : team.won
            ? MatchOutcome.win
            : anyWinner
            ? MatchOutcome.loss
            : null,
      ),
    );
  }
  return out;
}
