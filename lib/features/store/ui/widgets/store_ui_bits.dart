import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/currency_amount.dart';
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
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: valColorsOf(context).win,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
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

/// Card surface tinted with a content-tier color (Figma skin card): a
/// horizontal gradient from the tier color at 35% into the card color, a
/// 35% tier border and 16 px corners.
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
    final radius = BorderRadius.circular(ValRadius.card);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: solid.withValues(alpha: 0.35)),
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
                  solid.withValues(alpha: 0.35),
                  scheme.surfaceContainer.withValues(alpha: 0),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Rounded translucent box holding a skin render on the right of a
/// [TierCard].
class SkinRenderBox extends StatelessWidget {
  const SkinRenderBox({super.key, required this.child, this.height = 76});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: child,
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
            style: (style ?? ValText.label).copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Figma price line: red dot, amount, "VP" ("● 1.775 VP").
class VpPrice extends ConsumerWidget {
  const VpPrice(this.amount, {super.key, this.style});

  final num? amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base =
        style ??
        Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600);
    final a = amount;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: CurrencyColors.vp,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(a == null ? CommonStrings.dash : formatNumber(a), style: base),
        Text(' ${currencyOf(ref, CurrencyIds.vp)?.label ?? ''}', style: base),
      ],
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: row,
    );
  }
}
