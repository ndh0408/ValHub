import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/competitive/names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/xmpp/friends.dart';
import '../../data/friend_status.dart';
import 'social_widgets.dart';

/// "Tên#TAG" with a muted tag, on one line.
class RiotIdText extends StatelessWidget {
  const RiotIdText(this.name, {super.key, this.style, this.fallback = ''});

  final RiotName? name;
  final TextStyle? style;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.titleSmall;
    final n = name;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: n?.gameName ?? fallback,
            style: base?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (n != null && n.tagLine.isNotEmpty)
            TextSpan(
              text: ' #${n.tagLine}',
              style: base?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Hero tag of a friend's avatar (friends list → chat header).
Object friendAvatarHeroTag(String puuid) => 'friend-avatar-$puuid';

/// [avatar] flying between the friends list and the chat header: the
/// [FittedBox] scales it to the in-flight size (46 → 38 dp).
Widget friendAvatarHero(Object tag, Widget avatar) => Hero(
  tag: tag,
  child: FittedBox(child: avatar),
);

/// One row of the friends list (S60): card avatar with a presence dot,
/// Riot ID, colored status line, a muted detail line (queue, party,
/// leaderboard), the rank icon while in VALORANT and the unread badge.
class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.friend,
    required this.status,
    required this.unknownName,
    this.detail,
    this.rankTier,
    this.onTap,
    this.heroTag,
  });

  final Friend friend;
  final FriendStatus status;
  final String unknownName;

  /// Muted second line ([friendDetail]).
  final String? detail;

  /// Competitive tier from the presence ([friendRankTier]).
  final int? rankTier;
  final VoidCallback? onTap;

  /// Wraps the avatar in a [Hero] (unique per route).
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = legibleAccent(
      context,
      statusColor(context, status.tone),
      min: 3.5,
    );
    Widget avatar = FriendAvatar(
      playerCardId: friend.playerCardId,
      name: friend.name?.gameName,
      tone: friend.isOnline ? status.tone : null,
      dimmed: !friend.isOnline,
      size: 46,
    );
    final tag = heroTag;
    if (tag != null) avatar = friendAvatarHero(tag, avatar);
    final tier = rankTier;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RiotIdText(friend.name, fallback: unknownName),
                    const SizedBox(height: 3),
                    Text(
                      status.text,
                      key: ValueKey('status-${friend.puuid}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: status.tone == StatusTone.offline
                            ? null
                            : FontWeight.w600,
                        color: status.tone == StatusTone.offline
                            ? muted
                            : color,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (tier != null) ...[
                const SizedBox(width: 8),
                RankBadge(tier: tier, size: 26, showName: false),
              ],
              if (friend.unread > 0) ...[
                const SizedBox(width: 8),
                UnreadBadge(friend.unread),
              ],
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
