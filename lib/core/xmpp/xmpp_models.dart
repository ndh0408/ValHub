import 'package:flutter/foundation.dart';

import '../domain/competitive/names.dart';
import '../network/riot_exception.dart';

/// A Jabber ID `local@domain/resource`. Riot JIDs use the PUUID as the local
/// part (`{puuid}@jp1.pvp.net/RC-…`). Contains a PUUID: never log it.
@immutable
class Jid {
  const Jid({required this.local, required this.domain, this.resource});

  /// Parses `local@domain[/resource]`; `null` for anything else.
  static Jid? parse(String? raw) {
    final s = raw?.trim() ?? '';
    if (s.isEmpty) return null;
    final slash = s.indexOf('/');
    final bare = slash < 0 ? s : s.substring(0, slash);
    final resource = slash < 0 ? null : s.substring(slash + 1);
    final at = bare.indexOf('@');
    if (at <= 0 || at == bare.length - 1) return null;
    return Jid(
      local: bare.substring(0, at).toLowerCase(),
      domain: bare.substring(at + 1).toLowerCase(),
      resource: (resource == null || resource.isEmpty) ? null : resource,
    );
  }

  final String local;
  final String domain;
  final String? resource;

  /// `local@domain`.
  String get bare => '$local@$domain';

  /// The PUUID of a Riot JID (lowercase local part).
  String get puuid => local;

  @override
  bool operator ==(Object other) =>
      other is Jid &&
      other.local == local &&
      other.domain == domain &&
      other.resource == resource;

  @override
  int get hashCode => Object.hash(local, domain, resource);

  @override
  String toString() => resource == null ? bare : '$bare/$resource';
}

// ------------------------------------------------------------------ roster

/// One friend of the roster (`jabber:iq:riotgames:roster`).
@immutable
class RosterEntry {
  const RosterEntry({
    required this.puuid,
    required this.jid,
    this.name,
    this.subscription,
    this.lastOnline,
    this.state,
    this.note,
    this.group,
  });

  /// Lowercase PUUID (`puuid` attribute, else the JID local part).
  final String puuid;

  /// Bare JID (`{puuid}@{domain}.pvp.net`).
  final String jid;

  /// Riot ID from `<id name tagline/>` / `<platforms><riot …/>`; `null`
  /// when missing (resolve through name-service, SUMMARY U10).
  final RiotName? name;

  /// `both` for friends; `pending_in` / `pending_out` for requests;
  /// `remove` in a roster push that deletes the entry.
  final String? subscription;

  /// `<last_online>` (UTC); `null` when missing.
  final DateTime? lastOnline;

  /// `<state>` (`online`, `offline`, `mobile`, …) from the roster query.
  final String? state;
  final String? note;
  final String? group;

  /// True for accepted friends (requests and removals are not listed).
  bool get isFriend {
    final s = subscription?.toLowerCase();
    return s == null || s.isEmpty || s == 'both' || s == 'to' || s == 'from';
  }

  bool get isRemoval => subscription?.toLowerCase() == 'remove';

  RosterEntry copyWith({RiotName? name, DateTime? lastOnline}) => RosterEntry(
    puuid: puuid,
    jid: jid,
    name: name ?? this.name,
    subscription: subscription,
    lastOnline: lastOnline ?? this.lastOnline,
    state: state,
    note: note,
    group: group,
  );

  @override
  bool operator ==(Object other) =>
      other is RosterEntry &&
      other.puuid == puuid &&
      other.jid == jid &&
      other.name == name &&
      other.subscription == subscription &&
      other.lastOnline == lastOnline &&
      other.state == state &&
      other.note == note &&
      other.group == group;

  @override
  int get hashCode => Object.hash(
    puuid,
    jid,
    name,
    subscription,
    lastOnline,
    state,
    note,
    group,
  );
}

// ---------------------------------------------------------------- presence

/// `sessionLoopState` of a Valorant presence.
enum LoopState {
  menus,
  pregame,
  ingame,
  unknown;

  static LoopState parse(String? raw) => switch (raw?.trim().toUpperCase()) {
    'MENUS' => menus,
    'PREGAME' => pregame,
    'INGAME' => ingame,
    _ => unknown,
  };
}

/// Decoded Valorant private presence (`<games><valorant><p>` base64 JSON,
/// SUMMARY §6.5). Nested 2024+ format first, old flat format as a fallback.
@immutable
class PresenceSnapshot {
  const PresenceSnapshot({
    this.isIdle = false,
    this.isValid = true,
    this.loopState = LoopState.unknown,
    this.matchMap,
    this.queueId,
    this.provisioningFlow,
    this.partyId,
    this.partyState,
    this.partySize,
    this.maxPartySize,
    this.partyAccessibility,
    this.queueEntryTime,
    this.isPartyOwner = false,
    this.allyScore,
    this.enemyScore,
    this.playerCardId,
    this.playerTitleId,
    this.accountLevel,
    this.competitiveTier,
    this.leaderboardPosition,
    this.customGameName,
  });

  final bool isIdle;
  final bool isValid;
  final LoopState loopState;

  /// Map path (`/Game/Maps/Ascent/Ascent`) → `ContentDb.mapByUrl`.
  final String? matchMap;

  /// Queue id (`competitive`, `""` = custom / none).
  final String? queueId;

  /// `Matchmaking`, `CustomGame`, `ShootingRange`, `Invalid`, …
  final String? provisioningFlow;
  final String? partyId;

  /// `DEFAULT`, `MATCHMAKING`, `MATCHMADE_GAME_STARTING`, …
  final String? partyState;
  final int? partySize;
  final int? maxPartySize;
  final String? partyAccessibility;

  /// When the party entered the queue (UTC), `null` when not queueing.
  final DateTime? queueEntryTime;
  final bool isPartyOwner;

  /// Live round score of the party owner's match (G7, U9).
  final int? allyScore;
  final int? enemyScore;
  final String? playerCardId;
  final String? playerTitleId;
  final int? accountLevel;
  final int? competitiveTier;
  final int? leaderboardPosition;
  final String? customGameName;

  bool get isMatchmaking => partyState?.toUpperCase() == 'MATCHMAKING';

  bool get isCustomGame => provisioningFlow?.toLowerCase() == 'customgame';

  bool get isShootingRange =>
      provisioningFlow?.toLowerCase() == 'shootingrange';

  /// Score worth showing: in a match and not the uninitialised `0 – 0`
  /// (SUMMARY U9).
  bool get hasScore =>
      loopState == LoopState.ingame &&
      allyScore != null &&
      enemyScore != null &&
      (allyScore! > 0 || enemyScore! > 0);

  @override
  bool operator ==(Object other) =>
      other is PresenceSnapshot &&
      other.isIdle == isIdle &&
      other.isValid == isValid &&
      other.loopState == loopState &&
      other.matchMap == matchMap &&
      other.queueId == queueId &&
      other.provisioningFlow == provisioningFlow &&
      other.partyId == partyId &&
      other.partyState == partyState &&
      other.partySize == partySize &&
      other.maxPartySize == maxPartySize &&
      other.partyAccessibility == partyAccessibility &&
      other.queueEntryTime == queueEntryTime &&
      other.isPartyOwner == isPartyOwner &&
      other.allyScore == allyScore &&
      other.enemyScore == enemyScore &&
      other.playerCardId == playerCardId &&
      other.playerTitleId == playerTitleId &&
      other.accountLevel == accountLevel &&
      other.competitiveTier == competitiveTier &&
      other.leaderboardPosition == leaderboardPosition &&
      other.customGameName == customGameName;

  @override
  int get hashCode => Object.hashAll([
    isIdle,
    isValid,
    loopState,
    matchMap,
    queueId,
    provisioningFlow,
    partyId,
    partyState,
    partySize,
    maxPartySize,
    partyAccessibility,
    queueEntryTime,
    isPartyOwner,
    allyScore,
    enemyScore,
    playerCardId,
    playerTitleId,
    accountLevel,
    competitiveTier,
    leaderboardPosition,
    customGameName,
  ]);
}

/// `<show>` of a presence.
enum PresenceShow {
  chat,
  away,
  dnd,
  mobile,
  unknown;

  static PresenceShow parse(String? raw) => switch (raw?.trim().toLowerCase()) {
    'chat' || 'online' || '' || null => chat,
    'away' || 'xa' => away,
    'dnd' => dnd,
    'mobile' => mobile,
    _ => unknown,
  };
}

/// One `<presence>` of one resource of a user.
@immutable
class FriendPresence {
  const FriendPresence({
    required this.puuid,
    required this.receivedAt,
    this.resource,
    this.available = true,
    this.show = PresenceShow.chat,
    this.status,
    this.product,
    this.platform,
    this.valorant,
    this.timestamp,
  });

  /// Lowercase PUUID of the sender.
  final String puuid;
  final String? resource;

  /// False for `type="unavailable"` (that resource went offline).
  final bool available;
  final PresenceShow show;

  /// `<status>` text (user-written; UGC).
  final String? status;

  /// Game element under `<games>` that carried the presence (`valorant`,
  /// `league_of_legends`, `keystone` = Riot Client, …), `null` for a bare
  /// chat presence.
  final String? product;

  /// `<s.r>` (`PC`, console names…).
  final String? platform;

  /// Decoded Valorant presence (only when [product] is `valorant`).
  final PresenceSnapshot? valorant;

  /// `<s.t>` (sender clock, UTC).
  final DateTime? timestamp;
  final DateTime receivedAt;

  bool get inValorant => valorant != null;

  /// "Vắng mặt" rule (SUMMARY §9.9): `<show>away` or `isIdle`.
  bool get isAway => show == PresenceShow.away || (valorant?.isIdle ?? false);

  @override
  bool operator ==(Object other) =>
      other is FriendPresence &&
      other.puuid == puuid &&
      other.resource == resource &&
      other.available == available &&
      other.show == show &&
      other.status == status &&
      other.product == product &&
      other.platform == platform &&
      other.valorant == valorant &&
      other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(
    puuid,
    resource,
    available,
    show,
    status,
    product,
    platform,
    valorant,
    timestamp,
  );
}

// -------------------------------------------------------------------- chat

enum ChatMessageStatus { received, sending, sent, failed }

/// One direct message (live or from the archive). The body is user content:
/// never log it.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.friendPuuid,
    required this.outgoing,
    required this.body,
    required this.at,
    this.status = ChatMessageStatus.received,
  });

  final String id;

  /// The other participant (lowercase PUUID).
  final String friendPuuid;
  final bool outgoing;
  final String body;

  /// Server stamp (UTC) or local send time.
  final DateTime at;
  final ChatMessageStatus status;

  ChatMessage copyWith({ChatMessageStatus? status, DateTime? at, String? id}) =>
      ChatMessage(
        id: id ?? this.id,
        friendPuuid: friendPuuid,
        outgoing: outgoing,
        body: body,
        at: at ?? this.at,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      other is ChatMessage &&
      other.id == id &&
      other.friendPuuid == friendPuuid &&
      other.outgoing == outgoing &&
      other.body == body &&
      other.at == at &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, friendPuuid, outgoing, body, at, status);
}

/// Messages with one friend, oldest first.
@immutable
class Conversation {
  const Conversation({
    required this.friendPuuid,
    this.messages = const [],
    this.historyLoaded = false,
    this.loadingHistory = false,
    this.historyError,
  });

  final String friendPuuid;
  final List<ChatMessage> messages;

  /// The archive was fetched at least once on this connection.
  final bool historyLoaded;
  final bool loadingHistory;

  /// Last archive failure (messages stay visible).
  final RiotException? historyError;

  bool get isEmpty => messages.isEmpty;

  Conversation copyWith({
    List<ChatMessage>? messages,
    bool? historyLoaded,
    bool? loadingHistory,
    RiotException? historyError,
    bool clearError = false,
  }) => Conversation(
    friendPuuid: friendPuuid,
    messages: messages ?? this.messages,
    historyLoaded: historyLoaded ?? this.historyLoaded,
    loadingHistory: loadingHistory ?? this.loadingHistory,
    historyError: clearError ? null : (historyError ?? this.historyError),
  );
}

// -------------------------------------------------------------- connection

enum XmppStatus {
  /// Not connected and not trying (app in background, no listener).
  idle,
  connecting,
  connected,

  /// Lost the connection; retrying with backoff.
  reconnecting,

  /// Gave up for now (see [XmppConnectionState.error]); retry manually.
  failed,

  /// The account must sign in again (never retried automatically).
  needsLogin,
}

@immutable
class XmppConnectionState {
  const XmppConnectionState(this.status, {this.error, this.attempt = 0});

  static const idle = XmppConnectionState(XmppStatus.idle);

  final XmppStatus status;

  /// Why the last attempt failed (a [RiotException] for `describeError`).
  final RiotException? error;

  /// Consecutive failed attempts.
  final int attempt;

  bool get isConnected => status == XmppStatus.connected;

  bool get isBusy =>
      status == XmppStatus.connecting || status == XmppStatus.reconnecting;

  @override
  bool operator ==(Object other) =>
      other is XmppConnectionState &&
      other.status == status &&
      other.error == error &&
      other.attempt == attempt;

  @override
  int get hashCode => Object.hash(status, error, attempt);

  @override
  String toString() => 'XmppConnectionState($status, attempt $attempt)';
}
