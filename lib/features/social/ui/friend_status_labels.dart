import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/formats.dart';
import '../../../core/content/content_db.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_models.dart';
import '../data/friend_status.dart';

/// Muted second line of a friend in VALORANT, with what the status line
/// does not already say: the queue of their match, the party size outside
/// the lobby, the leaderboard position ("Thi đấu xếp hạng · Tổ đội 3/5 ·
/// Top 120"). `null` when there is nothing to add.
String? friendDetail(
  AppLocalizations l10n,
  AppFormats formats,
  Friend friend, {
  required ContentDb db,
}) {
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
    parts.add(l10n.socialPartyOf(size, v.maxPartySize ?? 5));
  }
  final top = v.leaderboardPosition;
  if (top != null && top > 0) {
    parts.add(l10n.socialLeaderboardTop(formats.number(top)));
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Render-time localized status line of a friend (SUMMARY §9.9, VF S60):
/// "Đang đấu · Ascent · 8 – 4", "Đang chọn đặc vụ · Bind",
/// "Đang tìm trận · Thi đấu xếp hạng", "Đang ở sảnh chờ", "Vắng mặt",
/// "Hoạt động 2 giờ trước".
FriendStatus friendStatus(
  AppLocalizations l10n,
  AppFormats formats,
  Friend friend, {
  required ContentDb db,
  required DateTime now,
}) => presenceStatus(
  l10n,
  formats,
  friend.presence,
  lastOnline: friend.lastOnline,
  db: db,
  now: now,
);

/// [friendStatus] for a bare presence (chat header, own status).
FriendStatus presenceStatus(
  AppLocalizations l10n,
  AppFormats formats,
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
          l10n.socialCustomGame(mapName()),
          StatusTone.inMatch,
        );
      }
      final score = v != null && v.hasScore;
      return FriendStatus(
        l10n.socialInMatch(
          mapName(),
          ally: score ? v.allyScore : null,
          enemy: score ? v.enemyScore : null,
        ),
        StatusTone.inMatch,
      );
    case FriendActivity.agentSelect:
      return FriendStatus(l10n.socialAgentSelect(mapName()), StatusTone.busy);
    case FriendActivity.inQueue:
      return FriendStatus(l10n.socialInQueue(queueName()), StatusTone.busy);
    case FriendActivity.inLobby:
      return FriendStatus(
        l10n.socialInLobby(
          partySize: v?.partySize,
          maxPartySize: v?.maxPartySize,
        ),
        StatusTone.active,
      );
    case FriendActivity.shootingRange:
      return FriendStatus(l10n.socialShootingRange, StatusTone.active);
    case FriendActivity.inValorant:
      return FriendStatus(l10n.socialInValorant, StatusTone.active);
    case FriendActivity.away:
      return FriendStatus(l10n.socialAway, StatusTone.away);
    case FriendActivity.otherGame:
      final game = l10n.socialOtherGame(presence?.product);
      return FriendStatus(
        game == null ? l10n.socialOnlineStatus : l10n.socialPlayingOther(game),
        StatusTone.online,
      );
    case FriendActivity.online:
      return FriendStatus(
        presence?.show == PresenceShow.mobile
            ? l10n.socialOnlineMobile
            : l10n.socialOnlineStatus,
        StatusTone.online,
      );
    case FriendActivity.offline:
      return FriendStatus(
        lastOnline == null
            ? l10n.socialOfflineStatus
            : l10n.socialLastOnline(formats.relative(lastOnline, now)),
        StatusTone.offline,
      );
  }
}

extension SocialStatusLabels on AppLocalizations {
  String socialInMatch(String? map, {int? ally, int? enemy}) => [
    socialPresenceInMatch,
    ?map,
    if (ally != null && enemy != null) liveGameScore(ally, enemy),
  ].join(' · ');
  String socialAgentSelect(String? map) => map == null
      ? socialPresenceAgentSelect
      : socialPresenceDetails(socialPresenceAgentSelect, map);
  String socialInQueue(String? queue) => queue == null
      ? socialPresenceQueue
      : socialPresenceDetails(socialPresenceQueue, queue);
  String socialInLobby({int? partySize, int? maxPartySize}) =>
      partySize != null && partySize > 1
      ? socialPresenceDetails(
          socialPresenceLobby,
          socialPartyOf(partySize, maxPartySize ?? 5),
        )
      : socialPresenceLobby;
  String socialCustomGame(String? map) => map == null
      ? socialPresenceCustom
      : socialPresenceDetails(socialPresenceCustom, map);
  String? socialOtherGame(String? product) => switch (product) {
    'league_of_legends' => socialOtherGamesLeagueOfLegends,
    'bacon' => socialOtherGamesBacon,
    'lion' => socialOtherGamesLion,
    _ => null,
  };
}
