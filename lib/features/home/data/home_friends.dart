/// "Bạn bè đang chơi" card model (docs/design/HOME.md §5.5). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/xmpp/friends.dart';
import '../../social/data/friend_sections.dart' show isPlaying;

/// Avatars in the strip.
const kHomeMaxPlayingFriends = 8;

/// Friends who are in a match, in agent select or in a queue right now.
@immutable
class HomeFriendsSnapshot {
  const HomeFriendsSnapshot({required this.playing, required this.total});

  /// At most [kHomeMaxPlayingFriends], in activity order, then by name.
  final List<Friend> playing;

  /// How many friends are playing (may exceed [playing]).
  final int total;

  int get hidden => total - playing.length;
}

/// Friends playing now, or `null` when nobody is. Shooting range, away,
/// lobby and other games do not count. [view] is already sorted by
/// activity, then by name.
HomeFriendsSnapshot? playingFriendsOf(
  FriendsView view, {
  int max = kHomeMaxPlayingFriends,
}) {
  final all =
      [
        for (final f in view.online)
          if (isPlaying(f)) f,
      ]..sort((a, b) {
        final c = a.activity.index.compareTo(b.activity.index);
        return c != 0 ? c : a.sortKey.compareTo(b.sortKey);
      });
  if (all.isEmpty) return null;
  return HomeFriendsSnapshot(
    playing: List.unmodifiable(all.take(max)),
    total: all.length,
  );
}
