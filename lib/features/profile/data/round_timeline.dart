import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';

/// Which part of a match a round belongs to.
enum MatchHalf { first, second, overtime }

/// One line of the "Diễn biến vòng đấu" tab.
@immutable
class RoundRow {
  const RoundRow({
    required this.round,
    required this.number,
    required this.half,
    required this.myScore,
    required this.otherScore,
    this.won,
    this.mySide,
    this.myKills = 0,
    this.firstBloodByMe = false,
  });

  final RoundResult round;

  /// 1-based round number ("Vòng 1").
  final int number;
  final MatchHalf half;

  /// Whether the perspective team won the round (`null` when unknown, e.g.
  /// for a spectator).
  final bool? won;

  /// Running score after this round (perspective team first; the first side
  /// of the match for a spectator).
  final int myScore;
  final int otherScore;

  /// Side the perspective team played (from `winningTeamRole`).
  final TeamRole? mySide;

  /// Kills of the perspective player in this round.
  final int myKills;
  final bool firstBloodByMe;

  RoundEndType get endType => round.endType;
}

/// Rounds per half by queue (competitive-style 13-win matches: 12;
/// Swiftplay: 4; Spike Rush: 3); `null` when unknown.
int? roundsPerHalf(String? queueId) => switch (baseQueueId(queueId)) {
  'competitive' || 'unrated' || 'premier' || '' || 'custom' || 'newmap' => 12,
  'swiftplay' => 4,
  'spikerush' => 3,
  _ => null,
};

/// Round rows of a round-based match from [puuid]'s point of view (the
/// first side of the match for spectators / unknown players). Rounds a
/// surrender awarded without being played are left out.
List<RoundRow> buildRoundRows(MatchDetails details, {String? puuid}) {
  final me = details.player(puuid);
  final sides = details.sideIds;
  final myTeam = me != null && !me.isObserver
      ? me.teamId
      : (sides.isEmpty ? null : sides.first);
  final perHalf = roundsPerHalf(details.info.queueId);
  final myId = me?.subject;
  var mine = 0;
  var other = 0;
  final rows = <RoundRow>[];
  for (final r in details.playedRounds) {
    final winner = r.winningTeam;
    bool? won;
    if (winner != null && myTeam != null) {
      won = winner == myTeam;
      if (won) {
        mine++;
      } else {
        other++;
      }
    }
    final kills = details.killsInRound(r.roundNum);
    final firstKill = kills.isEmpty ? null : kills.first;
    final fb = r.firstBloodPlayer ?? firstKill?.killer;
    rows.add(
      RoundRow(
        round: r,
        number: r.roundNum + 1,
        half: perHalf == null || r.roundNum < perHalf
            ? MatchHalf.first
            : r.roundNum < perHalf * 2
            ? MatchHalf.second
            : MatchHalf.overtime,
        won: won,
        myScore: mine,
        otherScore: other,
        mySide: r.roleOf(myTeam),
        myKills: myId == null ? 0 : kills.where((k) => k.killer == myId).length,
        firstBloodByMe: myId != null && fb == myId,
      ),
    );
  }
  return rows;
}
