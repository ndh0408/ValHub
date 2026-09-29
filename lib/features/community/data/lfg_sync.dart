import 'package:flutter/foundation.dart';

import '../../../core/network/riot_exception.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/util/json.dart';
import '../../../core/xmpp/xmpp_models.dart' show LoopState;
import '../../social/data/party_models.dart';
import 'community_models.dart';

/// Party size limit of an LFG mode.
int lfgModeMaxParty(String? mode) => switch (mode) {
  'deathmatch' => 1,
  _ => 5,
};

/// The poster's live Riot party (G-12 / G-13 / G-1), as the LFG sync needs
/// it.
@immutable
class LfgPartySnapshot {
  const LfgPartySnapshot({
    required this.members,
    this.inviteCode,
    this.matchmaking = false,
    this.inMatch = false,
    this.isOpen = false,
  });

  /// Members (own PUUID included) with their player cards.
  final List<PartyMember> members;
  final String? inviteCode;
  final bool matchmaking;

  /// In agent select or in a match.
  final bool inMatch;
  final bool isOpen;

  int get size => members.isEmpty ? 1 : members.length;

  Set<String> get memberIds => {for (final m in members) m.puuid};
}

/// Reads the party of [puuid]; `null` when the game is not running or the
/// account has no party. Never throws for "not running" (404); other Riot
/// errors propagate.
Future<LfgPartySnapshot?> readLfgParty(PvpApi api, String puuid) async {
  final player = await api.partyPlayer(puuid).orNullIfNotFound();
  if (player == null) return null;
  final partyId = lowerUuid(player['CurrentPartyID']);
  if (partyId == null) return null;
  final party = Party.fromJson(
    await api.party(puuid, partyId).orNullIfNotFound(),
  );
  if (party == null) return null;
  var loop = LoopState.unknown;
  try {
    final session = await api.gameSession(puuid).orNullIfNotFound();
    loop = LoopState.parse(asString(session?['loopState']));
  } on RiotException {
    // Unknown loop state: rely on the party state only.
  }
  final code = asNonEmptyString(party.inviteCode)?.toUpperCase();
  return LfgPartySnapshot(
    members: party.members,
    inviteCode: code != null && partyCodePattern.hasMatch(code) ? code : null,
    matchmaking: party.isMatchmaking || party.isMatchFound,
    inMatch: loop == LoopState.pregame || loop == LoopState.ingame,
    isOpen: party.isOpen,
  );
}

/// How often an unchanged post is PATCHed to stay alive (posts expire 30
/// minutes after the last PATCH).
const kLfgHeartbeat = Duration(minutes: 10);

/// What the poster's app should send for its LFG post after reading the
/// party (pure; unit-tested).
@immutable
class LfgSyncDecision {
  const LfgSyncDecision({
    this.partySize,
    this.slots,
    this.status,
    this.heartbeat = false,
    this.newMembers = const [],
  });

  static const none = LfgSyncDecision();

  /// Fields to PATCH (`null` = unchanged).
  final int? partySize;
  final int? slots;
  final LfgStatus? status;

  /// PATCH even without changes, to extend the post.
  final bool heartbeat;

  /// PUUIDs that joined since the last read (for "… đã vào tổ đội").
  final List<String> newMembers;

  bool get shouldPatch =>
      heartbeat || partySize != null || slots != null || status != null;
}

/// Decides the PATCH for [post] given the live [party].
///
/// - Game not running (`party == null`): nothing (the post expires on its
///   own if the poster stays away).
/// - `status`: `in_game` while matchmaking / in a match, `full` at the mode
///   maximum, else `open`.
/// - `partySize` / `slots` follow the members (slots = free places, 1–4).
/// - A heartbeat is due [kLfgHeartbeat] after [lastPatchAt].
/// - [knownMembers] `null` = first read: nobody counts as new.
LfgSyncDecision decideLfgSync({
  required LfgPost post,
  required LfgPartySnapshot? party,
  required String selfPuuid,
  required DateTime now,
  Set<String>? knownMembers,
  DateTime? lastPatchAt,
}) {
  if (party == null) return LfgSyncDecision.none;
  final max = lfgModeMaxParty(post.mode);
  final size = party.size.clamp(1, max);
  final status = party.matchmaking || party.inMatch
      ? LfgStatus.inGame
      : (size >= max ? LfgStatus.full : LfgStatus.open);
  final slots = (max - size).clamp(1, 4);
  final newMembers = knownMembers == null
      ? const <String>[]
      : [
          for (final id in party.memberIds)
            if (id != selfPuuid && !knownMembers.contains(id)) id,
        ];
  final sizeChanged = size != post.currentPartySize;
  final slotsChanged = status == LfgStatus.open && slots != post.slots;
  final statusChanged = status != post.status;
  final heartbeat =
      lastPatchAt == null || now.difference(lastPatchAt) >= kLfgHeartbeat;
  return LfgSyncDecision(
    partySize: sizeChanged ? size : null,
    slots: slotsChanged ? slots : null,
    status: statusChanged ? status : null,
    heartbeat: heartbeat && status == LfgStatus.open,
    newMembers: newMembers,
  );
}

// ------------------------------------------------------ create validation

/// Why an LFG post cannot be sent yet.
enum LfgProblem { rankRange, tooManyPlayers, codeInvalid }

/// Validates the create sheet (pure; unit-tested). [code] may be empty
/// (auto-generated on submit).
LfgProblem? validateLfgForm({
  required int? rankMin,
  required int? rankMax,
  required int partySize,
  required int slots,
  required String code,
  String? mode,
}) {
  if (rankMin != null && rankMax != null && rankMin > rankMax) {
    return LfgProblem.rankRange;
  }
  if (partySize + slots > lfgModeMaxParty(mode).clamp(2, 5)) {
    return LfgProblem.tooManyPlayers;
  }
  final c = code.trim().toUpperCase();
  if (c.isNotEmpty && !partyCodePattern.hasMatch(c)) {
    return LfgProblem.codeInvalid;
  }
  return null;
}

/// Suggested rank range around [tier] (± 3 divisions, clamped to Iron 1 …
/// Radiant); `null` when the rank is unknown / unranked.
({int min, int max})? suggestedRankRange(int? tier) {
  if (tier == null || tier <= 2) return null;
  return (
    min: (tier - 3).clamp(3, kMaxRankTier),
    max: (tier + 3).clamp(3, kMaxRankTier),
  );
}
