import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';
import 'round_timeline.dart';

/// How a team bought in one round.
enum BuyType { pistol, eco, semiEco, semiBuy, fullBuy }

/// Credits per player that separate the buy types: the community convention
/// (vlr.gg) for a five-player team — eco under 5,000, semi-eco under 10,000,
/// semi-buy under 20,000, full buy from 20,000 — divided by five so a team
/// that is a player short is judged by what each player carries.
const kEcoPerPlayer = 1000;
const kSemiEcoPerPlayer = 2000;
const kSemiBuyPerPlayer = 4000;

/// The buy type of a team whose [players] carried [loadout] credits of gear
/// in total; [pistol] for the first round of each half.
BuyType buyTypeOf({
  required int loadout,
  required int players,
  bool pistol = false,
}) {
  if (pistol) return BuyType.pistol;
  final perPlayer = players <= 0 ? 0 : loadout / players;
  if (perPlayer < kEcoPerPlayer) return BuyType.eco;
  if (perPlayer < kSemiEcoPerPlayer) return BuyType.semiEco;
  if (perPlayer < kSemiBuyPerPlayer) return BuyType.semiBuy;
  return BuyType.fullBuy;
}

/// One team's gear in one round (the loadout values Riot reports for its
/// players at the end of the buy phase).
@immutable
class TeamBuy {
  const TeamBuy({
    required this.loadout,
    required this.players,
    required this.type,
  });

  /// Total loadout value of the team's players.
  final int loadout;
  final int players;
  final BuyType type;
}

/// Both teams' buys in one round, the perspective team first.
@immutable
class RoundBuys {
  const RoundBuys({required this.mine, required this.theirs});

  final TeamBuy? mine;
  final TeamBuy? theirs;
}

/// Queues with a buy phase whose economy means something (Spike Rush hands
/// out random weapons; round-less modes have no economy).
bool hasBuyPhase(MatchDetails details) {
  if (!details.modeKind.isRoundBased) return false;
  final queue = baseQueueId(details.info.queueId);
  return queue != 'spikerush' && roundsPerHalf(details.info.queueId) != null;
}

/// Whether [round] (0-based) opens a half: rounds 1 and 13 in a 12-round
/// half. Overtime rounds are not pistol rounds.
bool isPistolRound(int round, int? perHalf) =>
    round == 0 || (perHalf != null && round == perHalf);

/// The buys of [round] for [myTeam] and the other side, or `null` per team
/// when Riot reported no loadout for any of its players.
RoundBuys roundBuysOf(
  MatchDetails details,
  RoundResult round, {
  required String? myTeam,
}) {
  final perHalf = roundsPerHalf(details.info.queueId);
  final pistol = isPistolRound(round.roundNum, perHalf);
  TeamBuy? team(bool mine) {
    var loadout = 0;
    var players = 0;
    var seen = false;
    for (final p in details.participants) {
      final isMine = p.teamId == myTeam;
      if (isMine != mine || p.teamId == null) continue;
      final economy = round.economyFor(p.subject);
      if (economy == null) continue;
      seen = true;
      players++;
      loadout += economy.loadoutValue;
    }
    if (!seen) return null;
    return TeamBuy(
      loadout: loadout,
      players: players,
      type: buyTypeOf(loadout: loadout, players: players, pistol: pistol),
    );
  }

  return RoundBuys(mine: team(true), theirs: team(false));
}

/// Rounds the perspective team played and won with one buy type.
@immutable
class BuyRecord {
  const BuyRecord({this.played = 0, this.won = 0});

  final int played;
  final int won;

  double? get winRate => played == 0 ? null : won / played;

  BuyRecord add({required bool won}) =>
      BuyRecord(played: played + 1, won: this.won + (won ? 1 : 0));
}

/// The perspective team's record by its own buy type over the match, in
/// [BuyType] order; empty when the match has no usable economy.
Map<BuyType, BuyRecord> economyRecordOf(
  MatchDetails details, {
  required String? puuid,
}) {
  if (!hasBuyPhase(details)) return const {};
  final me = details.player(puuid);
  final myTeam = me != null && !me.isObserver ? me.teamId : null;
  if (myTeam == null) return const {};
  final records = <BuyType, BuyRecord>{};
  for (final round in details.playedRounds) {
    final winner = round.winningTeam;
    if (winner == null) continue;
    final mine = roundBuysOf(details, round, myTeam: myTeam).mine;
    if (mine == null) continue;
    records[mine.type] = (records[mine.type] ?? const BuyRecord()).add(
      won: winner == myTeam,
    );
  }
  return {for (final type in BuyType.values) type: ?records[type]};
}
