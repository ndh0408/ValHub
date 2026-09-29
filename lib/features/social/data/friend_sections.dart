import 'package:flutter/foundation.dart';

import '../../../core/xmpp/friends.dart';

/// Quick filter of the friends list (remembered per device, `UiMemory` key
/// `social.friends.filter`).
enum FriendsFilter {
  /// Everyone.
  all,

  /// Online only (hides the offline section).
  online,

  /// Only friends with unread messages.
  unread,
}

/// Sections of the friends list, most active first.
enum FriendSectionKind {
  /// In a match, in agent select or queueing.
  playing,

  /// Online (lobby, range, other games, away…).
  online,

  /// Offline, most recently seen first.
  offline,
}

@immutable
class FriendSection {
  const FriendSection(this.kind, this.friends);

  final FriendSectionKind kind;
  final List<Friend> friends;
}

/// Whether [f] is busy in VALORANT (match, agent select, queue).
bool isPlaying(Friend f) => switch (f.activity) {
  FriendActivity.inMatch ||
  FriendActivity.agentSelect ||
  FriendActivity.inQueue => true,
  _ => false,
};

/// Splits [view] (already sorted by activity / last online) into
/// "Đang chơi", "Trực tuyến" and "Ngoại tuyến" after applying [filter].
/// Within a section, friends with unread messages come first (stable, so
/// the activity / recency order is otherwise kept). Empty sections are
/// omitted.
List<FriendSection> friendSections(
  FriendsView view, {
  FriendsFilter filter = FriendsFilter.all,
}) {
  bool keep(Friend f) => filter != FriendsFilter.unread || f.unread > 0;
  List<Friend> unreadFirst(Iterable<Friend> friends) {
    final list = friends.where(keep).toList();
    final unread = list.where((f) => f.unread > 0);
    final rest = list.where((f) => f.unread <= 0);
    return [...unread, ...rest];
  }

  final playing = unreadFirst(view.online.where(isPlaying));
  final online = unreadFirst(view.online.where((f) => !isPlaying(f)));
  final offline = filter == FriendsFilter.online
      ? const <Friend>[]
      : unreadFirst(view.offline);
  return [
    if (playing.isNotEmpty) FriendSection(FriendSectionKind.playing, playing),
    if (online.isNotEmpty) FriendSection(FriendSectionKind.online, online),
    if (offline.isNotEmpty) FriendSection(FriendSectionKind.offline, offline),
  ];
}
