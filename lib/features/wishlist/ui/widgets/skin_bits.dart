import 'package:valvn/core/l10n/labels/economy_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/currency_amount.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// B9 price of a skin: "2.175 VP", "≈ 1.775 VP", or the reward / not-for-sale
/// caption ("Phần thưởng Battle Pass", "Không bán").
class SkinPriceText extends StatelessWidget {
  const SkinPriceText({
    super.key,
    required this.quote,
    this.style,
    this.iconSize = 14,
    this.textAlign = TextAlign.end,
  });

  final PriceQuote quote;
  final TextStyle? style;
  final double iconSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.labelLarge;
    final caption = quote.caption(context.l10n);
    if (caption != null) {
      return Text(
        caption,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: theme.textTheme.labelSmall?.copyWith(
          color: valColorsOf(context).muted,
        ),
      );
    }
    final vp = quote.vp;
    if (vp == null) return Text(context.l10n.commonDash, style: base);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.start
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: CurrencyAmount.vp(
        vp,
        estimate: quote.isEstimate,
        iconSize: iconSize,
        style: base?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// ValBuddy-style card: a flat fill tinted by the content tier (rarity)
/// color over the card surface, a soft glow toward the top, radius 16.
class TierGradientCard extends StatelessWidget {
  const TierGradientCard({
    super.key,
    required this.tint,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    this.radius = ValRadius.card,
  });

  /// Tier highlight color (any alpha; used opaque).
  final Color tint;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Highlight border (e.g. "on sale now", "in wishlist").
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surfaceContainer;
    final opaque = tint.withValues(alpha: 1);
    final fill = Color.alphaBlend(
      opaque.withValues(alpha: dark ? 0.16 : 0.10),
      surface,
    );
    final border = borderColor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border != null
          ? BorderSide(color: border, width: 1.6)
          : dark
          ? BorderSide.none
          : BorderSide(color: valColorsOf(context).hairline),
    );
    return Material(
      color: fill,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.1,
            colors: [
              opaque.withValues(alpha: dark ? 0.16 : 0.10),
              opaque.withValues(alpha: 0),
            ],
          ),
        ),
        child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child),
      ),
    );
  }
}

/// Small tinted badge ("Đã sở hữu", "-22%"), legible on both themes.
class SmallBadge extends StatelessWidget {
  const SmallBadge(this.text, {super.key, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = legibleAccent(context, color, min: 3.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
