import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/currency_amount.dart';

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
    final caption = quote.caption;
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
    if (vp == null) return Text(CommonStrings.dash, style: base);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.start
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: CurrencyAmount.vp(
        vp,
        estimate: quote.isEstimate,
        iconSize: iconSize,
        style: base?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Card with a diagonal content-tier gradient (Valorant store look).
class TierGradientCard extends StatelessWidget {
  const TierGradientCard({
    super.key,
    required this.tint,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    this.radius = 6,
  });

  /// Tier highlight color (usually with alpha 0x33).
  final Color tint;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Highlight border (e.g. "on sale now").
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: borderColor ?? theme.colorScheme.outlineVariant,
        width: borderColor == null ? 1 : 1.6,
      ),
    );
    final opaque = tint.withValues(alpha: 1);
    return Material(
      color: theme.cardColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              opaque.withValues(alpha: 0.26),
              opaque.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child),
      ),
    );
  }
}

/// Small solid badge ("Đã sở hữu", "-22%").
class SmallBadge extends StatelessWidget {
  const SmallBadge(this.text, {super.key, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
