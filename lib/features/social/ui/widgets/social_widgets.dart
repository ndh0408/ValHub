import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/xmpp/xmpp_models.dart';
import '../../data/friend_status.dart';
import '../../social_strings.dart';

/// Colour of a status line / presence dot.
Color statusColor(BuildContext context, StatusTone tone) {
  final colors = valColorsOf(context);
  return switch (tone) {
    StatusTone.inMatch => ValColors.red,
    StatusTone.busy => colors.warning,
    StatusTone.active => colors.win,
    StatusTone.online => colors.win,
    StatusTone.away => colors.away,
    StatusTone.offline => colors.muted,
  };
}

/// Player-card avatar (S5) with an optional presence dot; initials when the
/// card is unknown.
class FriendAvatar extends ConsumerWidget {
  const FriendAvatar({
    super.key,
    this.playerCardId,
    this.name,
    this.tone,
    this.size = 44,
  });

  final String? playerCardId;
  final String? name;

  /// Presence dot colour family; `null` hides the dot.
  final StatusTone? tone;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final card = playerCardId == null
        ? null
        : ref.watch(contentProvider).value?.card(playerCardId!);
    final initial = (name?.trim().isNotEmpty ?? false)
        ? name!.trim().characters.first.toUpperCase()
        : '?';
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final image = card?.smallArt == null
        ? fallback
        : NetImage(
            card!.smallArt,
            width: size,
            height: size,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(size * 0.22),
            error: fallback,
          );
    final t = tone;
    if (t == null) return image;
    final dot = size * 0.28;
    return SizedBox(
      width: size + 2,
      height: size + 2,
      child: Stack(
        children: [
          image,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: statusColor(context, t),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Red pill with an unread count.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Semantics(
      label: SocialStrings.unread(count),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ValColors.red,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          SocialStrings.unreadBadge(count),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Thin banner while the chat socket is not connected (data stays visible).
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.state, this.onRetry});

  final XmppConnectionState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isConnected) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final busy = state.isBusy || state.status == XmppStatus.idle;
    final text = switch (state.status) {
      XmppStatus.connecting || XmppStatus.idle => SocialStrings.connecting,
      XmppStatus.reconnecting => SocialStrings.reconnecting,
      _ => SocialStrings.chatUnavailable,
    };
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            if (busy)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.cloud_off_outlined,
                size: 18,
                color: theme.colorScheme.error,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!busy && onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text(CommonStrings.retry),
              ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation dialog for account-changing actions; `true` = confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(CommonStrings.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: ValColors.red)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}
