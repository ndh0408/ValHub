import 'package:flutter/foundation.dart';

import '../../../core/util/json.dart';
import '../../../core/xmpp/xmpp_models.dart' show LoopState;
import '../../../core/xmpp/xmpp_parsers.dart' show parseRiotTimestamp;

// Party service payloads (EP §15.4, SUMMARY §6.4 G-12…G-24). Every field is
// optional; nothing here throws.

/// One member of `Members[]` (G-13).
@immutable
class PartyMember {
  const PartyMember({
    required this.puuid,
    this.competitiveTier = 0,
    this.playerCardId,
    this.playerTitleId,
    this.accountLevel,
    this.incognito = false,
    this.hideAccountLevel = false,
    this.isOwner = false,
    this.isReady = false,
    this.platformType,
    this.remainingAccountLevels = 0,
    this.ping,
  });

  static PartyMember? fromJson(Object? json) {
    final m = asMap(json);
    final identity = asMap(m?['PlayerIdentity']);
    final puuid = lowerUuid(m?['Subject']) ?? lowerUuid(identity?['Subject']);
    if (m == null || puuid == null) return null;
    final pings = asMapList(m['Pings'])
        .map((p) => asInt(p['Ping']))
        .whereType<int>()
        .where((p) => p > 0)
        .toList();
    return PartyMember(
      puuid: puuid,
      competitiveTier: asInt(m['CompetitiveTier']) ?? 0,
      playerCardId: _uuid(identity?['PlayerCardID']),
      playerTitleId: _uuid(identity?['PlayerTitleID']),
      accountLevel: asInt(identity?['AccountLevel']),
      incognito: asBool(identity?['Incognito']) ?? false,
      hideAccountLevel: asBool(identity?['HideAccountLevel']) ?? false,
      isOwner: asBool(m['IsOwner']) ?? false,
      isReady: asBool(m['IsReady']) ?? false,
      platformType: asNonEmptyString(m['PlatformType']),
      remainingAccountLevels:
          asInt(m['QueueEligibleRemainingAccountLevels']) ?? 0,
      ping: pings.isEmpty ? null : pings.reduce((a, b) => a < b ? a : b),
    );
  }

  final String puuid;

  /// Current tier (0 = unranked / unknown).
  final int competitiveTier;
  final String? playerCardId;
  final String? playerTitleId;
  final int? accountLevel;
  final bool incognito;
  final bool hideAccountLevel;
  final bool isOwner;
  final bool isReady;
  final String? platformType;

  /// Account levels still missing for competitive (> 0 = not eligible).
  final int remainingAccountLevels;

  /// Best ping (ms) to any game pod.
  final int? ping;
}

String? _uuid(Object? v) {
  final id = lowerUuid(v);
  return (id == null || id == '00000000-0000-0000-0000-000000000000')
      ? null
      : id;
}

/// An invitation to join someone else's party (G-12 `Invites`, shape
/// UNVERIFIED: parsed defensively, U11).
@immutable
class PartyInvite {
  const PartyInvite({required this.partyId, this.invitedBy, this.id});

  static PartyInvite? fromJson(Object? json) {
    final m = asMap(json);
    final partyId = lowerUuid(m?['PartyID']) ?? lowerUuid(m?['PartyId']);
    if (m == null || partyId == null) return null;
    return PartyInvite(
      partyId: partyId,
      invitedBy:
          lowerUuid(m['InvitedBySubject']) ??
          lowerUuid(m['RequestedBySubject']) ??
          lowerUuid(m['Subject']),
      id: asNonEmptyString(m['ID']),
    );
  }

  final String partyId;

  /// Who invited (PUUID) when the payload says so.
  final String? invitedBy;
  final String? id;
}

/// A request to join the viewer's party (G-13 `Requests`), declinable via
/// G-21.
@immutable
class PartyRequest {
  const PartyRequest({required this.id, this.requestedBy});

  static PartyRequest? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['ID']);
    if (m == null || id == null) return null;
    return PartyRequest(
      id: id,
      requestedBy:
          lowerUuid(m['RequestedBySubject']) ??
          asStringList(m['Subjects']).map((s) => s.toLowerCase()).firstOrNull,
    );
  }

  final String id;
  final String? requestedBy;
}

/// G-13 party.
@immutable
class Party {
  const Party({
    required this.id,
    this.members = const [],
    this.state,
    this.accessibility,
    this.queueId,
    this.queueEntryTime,
    this.eligibleQueues,
    this.ineligibleQueues = const {},
    this.inviteCode,
    this.requests = const [],
    this.invitedPuuids = const {},
    this.restrictedSeconds = 0,
    this.version,
  });

  static Party? fromJson(Object? json) {
    final m = asMap(json);
    final id = lowerUuid(m?['ID']);
    if (m == null || id == null) return null;
    final eligibleRaw = m['EligibleQueues'];
    return Party(
      id: id,
      members: [for (final e in asList(m['Members'])) ?PartyMember.fromJson(e)],
      state: asNonEmptyString(m['State'])?.toUpperCase(),
      accessibility: asNonEmptyString(m['Accessibility'])?.toUpperCase(),
      queueId: asString(asMap(m['MatchmakingData'])?['QueueID'])
          ?.trim()
          .toLowerCase(),
      queueEntryTime: parseRiotTimestamp(m['QueueEntryTime']),
      eligibleQueues: eligibleRaw is List
          ? {for (final q in asStringList(eligibleRaw)) q.toLowerCase()}
          : null,
      ineligibleQueues: _ineligible(m['QueueIneligibilities']),
      inviteCode: asNonEmptyString(m['InviteCode']),
      requests: [
        for (final r in asList(m['Requests'])) ?PartyRequest.fromJson(r),
      ],
      invitedPuuids: {
        for (final i in asMapList(m['Invites'])) ?lowerUuid(i['Subject']),
      },
      restrictedSeconds: asInt(m['RestrictedSeconds']) ?? 0,
      version: asInt(m['Version']),
    );
  }

  /// `QueueIneligibilities`: strings (queue ids) or objects with a queue id
  /// and a reason; queue id → raw reason (may be empty).
  static Map<String, String> _ineligible(Object? raw) {
    final out = <String, String>{};
    for (final e in asList(raw)) {
      if (e is String && e.trim().isNotEmpty) {
        out[e.trim().toLowerCase()] = '';
        continue;
      }
      final m = asMap(e);
      final q = asNonEmptyString(m?['QueueID'] ?? m?['queueId'] ?? m?['Queue']);
      if (q == null) continue;
      out[q.toLowerCase()] =
          asNonEmptyString(m?['Reason'] ?? m?['reason']) ?? '';
    }
    return out;
  }

  final String id;
  final List<PartyMember> members;

  /// `DEFAULT`, `MATCHMAKING`, `MATCHMADE_GAME_STARTING`,
  /// `CUSTOM_GAME_SETUP`, …
  final String? state;

  /// `OPEN` / `CLOSED`.
  final String? accessibility;
  final String? queueId;

  /// Start of matchmaking (queue timer), UTC.
  final DateTime? queueEntryTime;

  /// `null` when the payload did not say (then every queue is offered).
  final Set<String>? eligibleQueues;
  final Map<String, String> ineligibleQueues;

  /// `null` = no code.
  final String? inviteCode;
  final List<PartyRequest> requests;

  /// Players with a pending invite from this party.
  final Set<String> invitedPuuids;
  final int restrictedSeconds;
  final int? version;

  bool get isMatchmaking => state == 'MATCHMAKING';

  bool get isMatchFound => state == 'MATCHMADE_GAME_STARTING';

  bool get isCustomGame => state?.startsWith('CUSTOM_GAME') ?? false;

  bool get isOpen => accessibility == 'OPEN';

  int get size => members.length;

  PartyMember? member(String puuid) {
    final id = puuid.toLowerCase();
    for (final m in members) {
      if (m.puuid == id) return m;
    }
    return null;
  }

  PartyMember? get owner => members.where((m) => m.isOwner).firstOrNull;

  bool isOwner(String puuid) => member(puuid)?.isOwner ?? false;
}

/// Everything the party screen shows (S55).
@immutable
class PartyView {
  const PartyView({
    required this.gameRunning,
    required this.fetchedAt,
    this.party,
    this.invites = const [],
    this.loopState = LoopState.unknown,
  });

  /// G-12 answered 404: VALORANT is not running on PC/console.
  const PartyView.notRunning({required this.fetchedAt})
    : gameRunning = false,
      party = null,
      invites = const [],
      loopState = LoopState.unknown;

  final bool gameRunning;
  final Party? party;

  /// Incoming invites (G-12).
  final List<PartyInvite> invites;

  /// Game session state (G-1): queue changes are locked in a match.
  final LoopState loopState;
  final DateTime fetchedAt;

  bool get inMatch =>
      loopState == LoopState.pregame || loopState == LoopState.ingame;

  PartyView copyWith({Party? party, List<PartyInvite>? invites}) => PartyView(
    gameRunning: gameRunning,
    fetchedAt: fetchedAt,
    party: party ?? this.party,
    invites: invites ?? this.invites,
    loopState: loopState,
  );
}

// ------------------------------------------------------------ queue picker

/// Maximum party size per queue (default 5).
const kQueuePartyLimits = <String, int>{
  'deathmatch': 1,
  'skirmishascension1v1': 1,
  'skirmish2v2': 2,
  'skirmishascension2v2': 2,
};

/// Preferred display order of queues (others follow alphabetically).
const kQueueOrder = [
  'competitive',
  'unrated',
  'swiftplay',
  'spikerush',
  'deathmatch',
  'hurm',
  'ggteam',
  'onefa',
  'premier',
];

/// Queues offered when the party does not list eligible ones.
const kDefaultQueues = [
  'competitive',
  'unrated',
  'swiftplay',
  'spikerush',
  'deathmatch',
  'hurm',
];

/// Why a queue cannot be joined.
enum QueueBlock {
  partyTooLarge,
  accountLevel,
  rankDisparity,
  restricted,
  other,
}

@immutable
class QueueChoice {
  const QueueChoice(this.queueId, {this.block, this.maxPartySize});

  final String queueId;

  /// `null` = the party can queue it.
  final QueueBlock? block;

  /// For [QueueBlock.partyTooLarge].
  final int? maxPartySize;

  bool get eligible => block == null;

  /// Competitive stays selectable and explains why it is blocked (VF S4).
  bool get selectable => eligible || _base(queueId) == 'competitive';
}

String _base(String q) => q.startsWith('console_') ? q.substring(8) : q;

/// The queue picker of [party]: eligible queues, the current queue and
/// competitive (always shown), each with the reason it is blocked.
List<QueueChoice> queueChoices(Party party) {
  final eligible = party.eligibleQueues;
  final ids = <String>{
    ...?eligible,
    ...party.ineligibleQueues.keys,
    if (eligible == null) ...kDefaultQueues,
    ?party.queueId,
  };
  final console = ids.any((q) => q.startsWith('console_'));
  ids.add(console ? 'console_competitive' : 'competitive');
  ids.removeWhere((q) => q.isEmpty || _base(q) == 'custom');
  // Premier needs a roster: only offer it when Riot says it is eligible.
  ids.removeWhere(
    (q) => _base(q) == 'premier' && !(eligible?.contains(q) ?? false),
  );

  int rank(String q) {
    final i = kQueueOrder.indexOf(_base(q));
    return i < 0 ? kQueueOrder.length : i;
  }

  final sorted = ids.toList()
    ..sort((a, b) {
      final c = rank(a).compareTo(rank(b));
      return c != 0 ? c : a.compareTo(b);
    });
  return [
    for (final q in sorted)
      (eligible == null && !party.ineligibleQueues.containsKey(q)) ||
              (eligible?.contains(q) ?? false)
          ? QueueChoice(q)
          : _blocked(party, q),
  ];
}

QueueChoice _blocked(Party party, String queueId) {
  final base = _base(queueId);
  if (party.restrictedSeconds > 0) {
    return QueueChoice(queueId, block: QueueBlock.restricted);
  }
  final max = kQueuePartyLimits[base] ?? 5;
  if (party.size > max) {
    return QueueChoice(
      queueId,
      block: QueueBlock.partyTooLarge,
      maxPartySize: max,
    );
  }
  if (base == 'competitive') {
    if (party.members.any((m) => m.remainingAccountLevels > 0)) {
      return QueueChoice(queueId, block: QueueBlock.accountLevel);
    }
    final tiers = party.members
        .map((m) => m.competitiveTier)
        .where((t) => t > 2)
        .toList();
    if (party.size > 1 && party.size < 5 && tiers.length > 1) {
      final spread =
          tiers.reduce((a, b) => a > b ? a : b) -
          tiers.reduce((a, b) => a < b ? a : b);
      if (spread > 5) {
        return QueueChoice(queueId, block: QueueBlock.rankDisparity);
      }
    }
  }
  return QueueChoice(queueId, block: QueueBlock.other);
}
