import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/competitive/names.dart';
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
            style: base?.copyWith(fontWeight: FontWeight.w600),
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

/// One row of the friends list (S60): card avatar, Riot ID, status line,
/// unread badge.
class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.friend,
    required this.status,
    required this.unknownName,
    this.onTap,
  });

  final Friend friend;
  final FriendStatus status;
  final String unknownName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = statusColor(context, status.tone);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Opacity(
                opacity: friend.isOnline ? 1 : 0.55,
                child: FriendAvatar(
                  playerCardId: friend.playerCardId,
                  name: friend.name?.gameName,
                  tone: friend.isOnline ? status.tone : null,
                ),
              ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.tone == StatusTone.offline
                            ? theme.colorScheme.onSurfaceVariant
                            : color,
                      ),
                    ),
                  ],
                ),
              ),
              if (friend.unread > 0) ...[
                const SizedBox(width: 8),
                UnreadBadge(friend.unread),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
