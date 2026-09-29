import 'package:flutter/foundation.dart';

import '../domain/competitive/names.dart';
import '../util/search_text.dart';
import 'xmpp_models.dart';
import 'xmpp_store.dart';

/// What a friend is doing, most "active" first (sort order of the online
/// section, S60).
enum FriendActivity {
  inMatch,
  agentSelect,
  inQueue,
  inLobby,
  shootingRange,
  inValorant,
  away,
  otherGame,
  online,
  offline,
}

/// Classifies a presence (SUMMARY §9.9): a running match or agent select
/// wins over "away"; `<show>away` / `isIdle` otherwise means away.
FriendActivity friendActivity(FriendPresence? p) {
  if (p == null || !p.available) return FriendActivity.offline;
  final v = p.valorant;
  if (v != null) {
    switch (v.loopState) {
      case LoopState.ingame:
        return v.isShootingRange
            ? FriendActivity.shootingRange
            : FriendActivity.inMatch;
      case LoopState.pregame:
        return FriendActivity.agentSelect;
      case LoopState.menus:
        if (p.isAway) return FriendActivity.away;
        return v.isMatchmaking
            ? FriendActivity.inQueue
            : FriendActivity.inLobby;
      case LoopState.unknown:
        return p.isAway ? FriendActivity.away : FriendActivity.inValorant;
    }
  }
  if (p.isAway) return FriendActivity.away;
  final product = p.product;
  if (product != null && product != 'keystone') return FriendActivity.otherGame;
  return FriendActivity.online;
}

/// One row of the friends list.
@immutable
class Friend {
  const Friend({
    required this.puuid,
    this.jid,
    this.name,
    this.presence,
    this.lastOnline,
    this.unread = 0,
    this.note,
  });

  final String puuid;
  final String? jid;

  /// Riot ID (roster, else name-service); `null` while unknown.
  final RiotName? name;

  /// Best available presence; `null` = offline.
  final FriendPresence? presence;
  final DateTime? lastOnline;
  final int unread;
  final String? note;

  bool get isOnline => presence != null;

  FriendActivity get activity => friendActivity(presence);

  PresenceSnapshot? get valorant => presence?.valorant;

  /// Player card uuid while in VALORANT (avatar, S5).
  String? get playerCardId => presence?.valorant?.playerCardId;

  /// Lowercase key for sorting and search.
  String get sortKey => (name?.riotId ?? '\u{FFFF}$puuid').toLowerCase();

  /// Case-insensitive, diacritic-insensitive Riot ID match.
  bool matches(String query) {
    final q = foldForSearch(query.trim());
    if (q.isEmpty) return true;
    final riotId = name?.riotId;
    if (riotId == null) return false;
    return foldForSearch(riotId).contains(q) ||
        (note != null && foldForSearch(note!).contains(q));
  }

  @override
  bool operator ==(Object other) =>
      other is Friend &&
      other.puuid == puuid &&
      other.jid == jid &&
      other.name == name &&
      other.presence == presence &&
      other.lastOnline == lastOnline &&
      other.unread == unread &&
      other.note == note;

  @override
  int get hashCode =>
      Object.hash(puuid, jid, name, presence, lastOnline, unread, note);
}

/// The friends list split into online / offline (S60).
@immutable
class FriendsView {
  const FriendsView({
    this.online = const [],
    this.offline = const [],
    this.connection = XmppConnectionState.idle,
  });

  /// Online friends, most active first, then by name.
  final List<Friend> online;

  /// Offline friends, most recently seen first, then by name.
  final List<Friend> offline;
  final XmppConnectionState connection;

  List<Friend> get all => [...online, ...offline];

  bool get isEmpty => online.isEmpty && offline.isEmpty;

  int get totalUnread => all.fold(0, (sum, f) => sum + f.unread);

  Friend? byPuuid(String puuid) {
    final id = puuid.toLowerCase();
    for (final f in online) {
      if (f.puuid == id) return f;
    }
    for (final f in offline) {
      if (f.puuid == id) return f;
    }
    return null;
  }

  /// Only friends whose Riot ID contains [query].
  FriendsView filter(String query) => query.trim().isEmpty
      ? this
      : FriendsView(
          online: online.where((f) => f.matches(query)).toList(),
          offline: offline.where((f) => f.matches(query)).toList(),
          connection: connection,
        );
}

/// Builds the list from a chat snapshot; [names] fills roster entries
/// without a Riot ID (name-service).
FriendsView buildFriendsView(
  XmppSnapshot s, {
  Map<String, RiotName> names = const {},
}) {
  final online = <Friend>[];
  final offline = <Friend>[];
  for (final e in s.roster.values) {
    final friend = Friend(
      puuid: e.puuid,
      jid: e.jid,
      name: e.name ?? names[e.puuid],
      presence: s.presences[e.puuid],
      lastOnline: e.lastOnline,
      unread: s.unread[e.puuid] ?? 0,
      note: e.note,
    );
    (friend.isOnline ? online : offline).add(friend);
  }
  online.sort((a, b) {
    final c = a.activity.index.compareTo(b.activity.index);
    return c != 0 ? c : a.sortKey.compareTo(b.sortKey);
  });
  offline.sort((a, b) {
    final la = a.lastOnline;
    final lb = b.lastOnline;
    if (la != null && lb != null && la != lb) return lb.compareTo(la);
    if (la != null && lb == null) return -1;
    if (la == null && lb != null) return 1;
    return a.sortKey.compareTo(b.sortKey);
  });
  return FriendsView(
    online: List.unmodifiable(online),
    offline: List.unmodifiable(offline),
    connection: s.connection,
  );
}
