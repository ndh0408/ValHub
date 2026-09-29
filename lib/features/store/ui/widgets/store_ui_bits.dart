import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/util/format.dart';
import '../../store_strings.dart';

/// Small solid badge ("Đã sở hữu", "-32%").
class StoreBadge extends StatelessWidget {
  const StoreBadge(
    this.text, {
    super.key,
    required this.color,
    this.foreground = Colors.white,
    this.icon,
  });

  final String text;
  final Color color;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Đã sở hữu" badge in the win (teal) color.
class OwnedBadge extends StatelessWidget {
  const OwnedBadge({super.key, this.label = StoreStrings.ownedBadge});

  final String label;

  @override
  Widget build(BuildContext context) {
    final win = valColorsOf(context).win;
    return StoreBadge(
      label,
      color: win.withValues(alpha: 0.18),
      foreground: win,
      icon: Icons.check_circle,
    );
  }
}

/// Round wishlist heart toggle used on store cards.
class WishlistHeartButton extends StatelessWidget {
  const WishlistHeartButton({
    super.key,
    required this.active,
    required this.onTap,
    this.size = 18,
  });

  final bool active;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      toggled: active,
      label: active
          ? StoreStrings.removeFromWishlist
          : StoreStrings.addToWishlist,
      excludeSemantics: true,
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              active ? Icons.favorite : Icons.favorite_border,
              size: size,
              color: active ? ValColors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Clock icon + live countdown sentence, with an optional trailing widget
/// (e.g. "Tổng 7.775 VP").
class CountdownRow extends StatelessWidget {
  const CountdownRow({
    super.key,
    required this.expiresAt,
    required this.builder,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 12),
  });

  final DateTime? expiresAt;
  final String Function(String formatted) builder;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = expiresAt;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (at != null) ...[
            Icon(Icons.schedule, size: 16, color: muted),
            const SizedBox(width: 6),
            Expanded(
              child: CountdownText(
                expiresAt: at,
                builder: builder,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ] else
            const Spacer(),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// "Đang ngoại tuyến — hiển thị dữ liệu đã lưu (14:05)." (X4).
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({super.key, required this.receivedAt});

  final DateTime receivedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warning = valColorsOf(context).warning;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              CommonStrings.offlineCached(formatTime(receivedAt)),
              style: theme.textTheme.bodySmall?.copyWith(color: warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two equal-width columns whose rows take the height of their tallest
/// card, so long Vietnamese names never overflow a fixed aspect ratio.
class TwoColumnGrid extends StatelessWidget {
  const TwoColumnGrid({
    super.key,
    required this.children,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: spacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: spacing),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

/// Card surface tinted with a content-tier color (VF §6.2 S10): a vertical
/// gradient from the tier color into the card color, with a thin tier
/// accent on the left edge.
class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.tint,
    required this.child,
    this.onTap,
    this.semanticsLabel,
  });

  final Color tint;
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final solid = tint.withValues(alpha: 1);
    final radius = BorderRadius.circular(4);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  solid.withValues(alpha: 0.42),
                  solid.withValues(alpha: 0.10),
                  scheme.surfaceContainer.withValues(alpha: 0),
                ],
                stops: const [0, 0.55, 1],
              ),
              border: Border(left: BorderSide(color: solid, width: 3)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Content-tier icon + name in the tier color ("Cao Cấp" /
/// "Phiên Bản Cao Cấp"). Unlike [ContentTierBadge] with `showName`, the
/// name wraps instead of overflowing on narrow screens.
class TierLabel extends ConsumerWidget {
  const TierLabel({
    super.key,
    required this.contentTierUuid,
    this.fullName = false,
    this.iconSize = 16,
    this.style,
  });

  final String? contentTierUuid;
  final bool fullName;
  final double iconSize;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = contentTierUuid;
    if (id == null) return const SizedBox.shrink();
    final tier =
        ref.watch(contentProvider).value?.contentTier(id) ??
        ContentFallbacks.contentTier(id);
    if (tier == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentTierBadge(contentTierUuid: id, size: iconSize),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            fullName ? tier.displayName : tier.shortName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: (style ?? Theme.of(context).textTheme.labelMedium)?.copyWith(
              color: opaqueRgba(tier.highlightColor),
            ),
          ),
        ),
      ],
    );
  }
}
