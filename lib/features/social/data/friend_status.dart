import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/util/format.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_models.dart';
import '../social_strings.dart';

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

/// Vietnamese status line of a friend (SUMMARY §9.9, VF S60):
/// "Đang đấu · Ascent · 8 – 4", "Đang chọn đặc vụ · Bind",
/// "Đang tìm trận · Thi đấu xếp hạng", "Đang ở sảnh chờ", "Vắng mặt",
/// "Hoạt động 2 giờ trước".
FriendStatus friendStatus(
  Friend friend, {
  required ContentDb db,
  required DateTime now,
}) => presenceStatus(
  friend.presence,
  lastOnline: friend.lastOnline,
  db: db,
  now: now,
);

/// [friendStatus] for a bare presence (chat header, own status).
FriendStatus presenceStatus(
  FriendPresence? presence, {
  DateTime? lastOnline,
  required ContentDb db,
  required DateTime now,
}) {
  final activity = friendActivity(presence);
  final v = presence?.valorant;
  String? mapName() {
    final name = db.mapByUrl(v?.matchMap)?.displayName.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  String? queueName() {
    final id = v?.queueId;
    if (id == null || id.isEmpty) return null;
    final name = db.queueName(id).trim();
    return name.isEmpty ? null : name;
  }

  switch (activity) {
    case FriendActivity.inMatch:
      if (v != null && v.isCustomGame) {
        return FriendStatus(
          SocialStrings.customGame(mapName()),
          StatusTone.inMatch,
        );
      }
      final score = v != null && v.hasScore;
      return FriendStatus(
        SocialStrings.inMatch(
          mapName(),
          ally: score ? v.allyScore : null,
          enemy: score ? v.enemyScore : null,
        ),
        StatusTone.inMatch,
      );
    case FriendActivity.agentSelect:
      return FriendStatus(
        SocialStrings.agentSelect(mapName()),
        StatusTone.busy,
      );
    case FriendActivity.inQueue:
      return FriendStatus(SocialStrings.inQueue(queueName()), StatusTone.busy);
    case FriendActivity.inLobby:
      return FriendStatus(
        SocialStrings.inLobby(
          partySize: v?.partySize,
          maxPartySize: v?.maxPartySize,
        ),
        StatusTone.active,
      );
    case FriendActivity.shootingRange:
      return const FriendStatus(SocialStrings.shootingRange, StatusTone.active);
    case FriendActivity.inValorant:
      return const FriendStatus(SocialStrings.inValorant, StatusTone.active);
    case FriendActivity.away:
      return const FriendStatus(SocialStrings.away, StatusTone.away);
    case FriendActivity.otherGame:
      final game = SocialStrings.otherGames[presence?.product];
      return FriendStatus(
        game == null
            ? SocialStrings.onlineStatus
            : SocialStrings.playingOther(game),
        StatusTone.online,
      );
    case FriendActivity.online:
      return FriendStatus(
        presence?.show == PresenceShow.mobile
            ? SocialStrings.onlineMobile
            : SocialStrings.onlineStatus,
        StatusTone.online,
      );
    case FriendActivity.offline:
      return FriendStatus(
        lastOnline == null
            ? SocialStrings.offlineStatus
            : SocialStrings.lastOnline(formatRelative(lastOnline, now)),
        StatusTone.offline,
      );
  }
}
