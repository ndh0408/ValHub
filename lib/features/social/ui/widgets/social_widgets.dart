import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/xmpp/xmpp_models.dart';
import '../../data/friend_status.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Colour of a status line / presence dot.
Color statusColor(BuildContext context, StatusTone tone) {
  final colors = valColorsOf(context);
  return switch (tone) {
    StatusTone.inMatch => Theme.of(context).colorScheme.primary,
    StatusTone.busy => colors.warning,
    StatusTone.active => colors.win,
    StatusTone.online => colors.win,
    StatusTone.away => colors.away,
    StatusTone.offline => colors.muted,
  };
}

/// Round player-card avatar (S5) with an optional presence dot; initials
/// when the card is unknown. [dimmed] fades the art while painting (offline
/// friends) instead of an `Opacity` layer.
class FriendAvatar extends ConsumerWidget {
  const FriendAvatar({
    super.key,
    this.playerCardId,
    this.name,
    this.tone,
    this.size = 44,
    this.dimmed = false,
  });

  final bool dimmed;

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
        shape: BoxShape.circle,
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
            borderRadius: BorderRadius.circular(size / 2),
            opacity: dimmed ? 0.5 : null,
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
      label: context.l10n.socialUnread(count),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          context.fmt.unreadBadge(count),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Rounded notice while the chat socket is not connected (data stays
/// visible under it): a spinner while (re)connecting, a cloud and "Thử lại"
/// once it gave up.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    required this.state,
    this.onRetry,
    this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 4),
  });

  final XmppConnectionState state;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    if (state.isConnected) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final busy = state.isBusy || state.status == XmppStatus.idle;
    final tint = busy ? valColorsOf(context).warning : theme.colorScheme.error;
    final text = switch (state.status) {
      XmppStatus.connecting || XmppStatus.idle => context.l10n.socialConnecting,
      XmppStatus.reconnecting => context.l10n.socialReconnecting,
      _ => context.l10n.socialChatUnavailable,
    };
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(ValRadius.small),
          border: Border.all(color: tint.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          child: Row(
            children: [
              if (busy)
                SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: legibleAccent(context, tint, min: 3),
                  ),
                )
              else
                Icon(Icons.cloud_off_outlined, size: 18, color: tint),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!busy && onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.commonRetry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A lazy [GroupedSection]: the rows of one rounded `s1` card built on
/// demand (long friend lists), with hairlines between rows, ink clipped to
/// the card corners and a hairline edge on the light theme.
class GroupedSliverList extends StatelessWidget {
  const GroupedSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hairline = valColorsOf(context).hairline;
    const radius = Radius.circular(ValRadius.card);
    return SliverPadding(
      padding: margin,
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.all(radius),
          border: theme.brightness == Brightness.light
              ? Border.all(color: hairline)
              : null,
        ),
        sliver: SliverList.builder(
          itemCount: itemCount,
          itemBuilder: (context, i) {
            final first = i == 0;
            final last = i == itemCount - 1;
            // Own ink layer above the card color.
            Widget row = Material(
              type: MaterialType.transparency,
              child: itemBuilder(context, i),
            );
            if (first || last) {
              row = ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: first ? radius : Radius.zero,
                  bottom: last ? radius : Radius.zero,
                ),
                child: row,
              );
            }
            if (first) return row;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(height: 1, thickness: 1, color: hairline),
                row,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Confirmation dialog for account-changing actions; `true` = confirmed.
/// Cupertino alert on iOS, Material alert elsewhere.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) => showConfirmDialog(
  context,
  title: title,
  message: body,
  confirmLabel: confirmLabel,
  destructive: destructive,
);
