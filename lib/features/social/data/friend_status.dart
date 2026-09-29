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

/// Muted second line of a friend in VALORANT, with what the status line
/// does not already say: the queue of their match, the party size outside
/// the lobby, the leaderboard position ("Thi đấu xếp hạng · Tổ đội 3/5 ·
/// Top 120"). `null` when there is nothing to add.
String? friendDetail(Friend friend, {required ContentDb db}) {
  final v = friend.valorant;
  if (!friend.isOnline || v == null) return null;
  final activity = friend.activity;
  final parts = <String>[];
  final queue = (v.queueId ?? '').trim();
  if ((activity == FriendActivity.inMatch ||
          activity == FriendActivity.agentSelect) &&
      queue.isNotEmpty &&
      !v.isCustomGame) {
    final name = db.queueName(queue).trim();
    if (name.isNotEmpty) parts.add(name);
  }
  final size = v.partySize;
  if (activity != FriendActivity.inLobby && size != null && size > 1) {
    parts.add(SocialStrings.partyOf(size, v.maxPartySize ?? 5));
  }
  final top = v.leaderboardPosition;
  if (top != null && top > 0) {
    parts.add(SocialStrings.leaderboardTop(formatNumber(top)));
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Competitive tier shown next to a friend in VALORANT (`null` when
/// unranked or unknown).
int? friendRankTier(Friend friend) {
  final tier = friend.isOnline ? friend.valorant?.competitiveTier : null;
  return tier != null && tier > 2 ? tier : null;
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
