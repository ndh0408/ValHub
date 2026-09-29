import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/countdown_ring.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
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
        borderRadius: BorderRadius.circular(6),
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

/// Round wishlist heart toggle used on store cards. The hit area is always
/// 48 dp; the visible disc is smaller ([subtle]: a 30 dp translucent disc).
class WishlistHeartButton extends StatelessWidget {
  const WishlistHeartButton({
    super.key,
    required this.active,
    required this.onTap,
    this.size = 18,
    this.subtle = false,
  });

  final bool active;
  final VoidCallback onTap;
  final double size;

  /// Small corner marker (daily cards) instead of a solid disc.
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final disc = size + (subtle ? 14 : 16);
    return Semantics(
      container: true,
      button: true,
      toggled: active,
      label: active
          ? StoreStrings.removeFromWishlist
          : StoreStrings.addToWishlist,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 48,
        child: InkResponse(
          radius: 24,
          onTap: () {
            Haptics.light();
            onTap();
          },
          child: Center(
            child: Container(
              width: disc,
              height: disc,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: subtle ? 0.28 : 0.38),
              ),
              child: AnimatedSwitcher(
                duration: ValMotion.fast,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  active ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(active),
                  size: size,
                  color: active
                      ? ValColors.red
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small muted countdown line under the segments: ring + "Làm mới sau
/// 11:54:37", an optional [note] under it with the local wall time
/// ("Làm mới lúc 07:00 hằng ngày"), and an optional trailing widget
/// (e.g. "Tổng 7.775 VP"). Only the ring and the text rebuild every second.
class CountdownRow extends StatelessWidget {
  const CountdownRow({
    super.key,
    required this.expiresAt,
    required this.builder,
    this.trailing,
    this.note,
    this.period = const Duration(days: 1),
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 12),
  });

  final DateTime? expiresAt;
  final String Function(String formatted) builder;
  final Widget? trailing;

  /// Second muted line: when it happens in the device's local time.
  final String? note;

  /// Full cycle length for the ring (a day for the daily shop).
  final Duration period;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final at = expiresAt;
    final note = this.note;
    return Padding(
      padding: padding,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: [
          if (at != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountdownRing(
                  expiresAt: at,
                  period: period,
                  size: 14,
                  strokeWidth: 2,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountdownText(
                        expiresAt: at,
                        builder: builder,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (note != null)
                        Text(
                          note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Tinted pill button for a segment action ("Chia sẻ ảnh"): icon + label,
/// 48 dp tap target.
class StoreActionPill extends StatelessWidget {
  const StoreActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    final fg = legibleAccent(context, c, min: 3.5);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: c.withValues(alpha: 0.14),
            shape: StadiumBorder(
              side: BorderSide(color: c.withValues(alpha: 0.35)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Haptics.light();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Summary chips on the left, one action pill on the right; wraps onto a
/// second line instead of overflowing (large text, narrow phones).
class StoreSummaryRow extends StatelessWidget {
  const StoreSummaryRow({super.key, required this.chips, required this.action});

  final List<Widget> chips;
  final Widget action;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: chips.isEmpty ? WrapAlignment.end : WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    runSpacing: 4,
    children: [
      if (chips.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        ),
      action,
    ],
  );
}

/// Small muted pill with an icon: derived facts under a section header
/// ("Đã sở hữu 1/4", "2 trong wishlist").
class StoreStatChip extends StatelessWidget {
  const StoreStatChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: legibleAccent(context, c, min: 3.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A skin render over a soft radial glow in the rarity [tint] (card art).
class SkinGlowArt extends StatelessWidget {
  const SkinGlowArt({
    super.key,
    required this.imageUrl,
    required this.tint,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 8),
  });

  final String? imageUrl;
  final Color tint;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final solid = tint.withValues(alpha: 1);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.8,
              colors: [
                solid.withValues(alpha: dark ? 0.38 : 0.26),
                solid.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: NetImage(imageUrl, fit: BoxFit.contain, showSkeleton: false),
        ),
      ],
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
        borderRadius: BorderRadius.circular(ValRadius.small),
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

/// Card surface tinted with a content-tier color: the card color with the
/// tier color blended in, a light diagonal wash, a thin tier border and
/// 16 px corners (optional 3 px tier [edge] at the bottom).
class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.tint,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.edge = false,
  });

  final Color tint;
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  /// 3 px rarity-colored bottom edge.
  final bool edge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final solid = tint.withValues(alpha: 1);
    final radius = BorderRadius.circular(ValRadius.card);
    final surface = scheme.surfaceContainer;
    // Dark card tinted by the tier color (flat, like the in-game store),
    // with a lighter wash in the top-left corner.
    final bg = Color.alphaBlend(
      solid.withValues(alpha: dark ? 0.16 : 0.10),
      surface,
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: solid.withValues(alpha: dark ? 0.22 : 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  solid.withValues(alpha: dark ? 0.16 : 0.08),
                  solid.withValues(alpha: 0),
                ],
              ),
              border: edge
                  ? Border(bottom: BorderSide(color: solid, width: 3))
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Content-tier icon + name in the tier color ("Cao Cấp" /
/// "Phiên Bản Cao Cấp"). Unlike `ContentTierBadge` with `showName`, the
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
    final color = opaqueRgba(tier.highlightColor);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DiamondPip(size: iconSize * 0.75, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            fullName ? tier.displayName : tier.shortName.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: (style ?? ValText.label).copyWith(
              color: legibleAccent(context, color, min: 3.5),
            ),
          ),
        ),
      ],
    );
  }
}
