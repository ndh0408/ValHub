import 'package:flutter/foundation.dart';

import '../../../core/xmpp/friends.dart';

/// Colour family of a status line.
enum StatusTone { inMatch, busy, active, away, online, offline }

@immutable
class FriendStatus {
  const FriendStatus(this.text, this.tone);

  final String text;
  final StatusTone tone;

  @override
  bool operator ==(Object other) =>
      other is FriendStatus && other.text == text && other.tone == tone;

  @override
  int get hashCode => Object.hash(text, tone);

  @override
  String toString() => 'FriendStatus($text, $tone)';
}

/// Competitive tier shown next to a friend in VALORANT (`null` when
/// unranked or unknown).
int? friendRankTier(Friend friend) {
  final tier = friend.isOnline ? friend.valorant?.competitiveTier : null;
  return tier != null && tier > 2 ? tier : null;
}
