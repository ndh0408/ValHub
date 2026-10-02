import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Design-system building blocks shared by every feature (Figma
/// `docs/design/DESIGN.md`): cards, uppercase section labels, grouped list
/// rows, progress bar, diamond pips, pills and badges.

/// Rounded card on the `s1` surface (radius 16). Optional [gradient],
/// [borderColor] and tap handling (ink clipped to the shape).
class ValCard extends StatelessWidget {
  const ValCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = ValRadius.card,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    // On the light theme a white card on the pale background needs a
    // hairline edge to read as a card.
    final light = Theme.of(context).brightness == Brightness.light;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor != null
          ? BorderSide(color: borderColor!)
          : light
          ? BorderSide(color: valColorsOf(context).hairline)
          : BorderSide.none,
    );
    final bg = color ?? Theme.of(context).colorScheme.surfaceContainer;
    Widget content = Padding(padding: padding, child: child);
    if (gradient != null) {
      content = Ink(
        decoration: BoxDecoration(gradient: gradient),
        child: content,
      );
    }
    final card = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}

/// Small uppercase, letter-spaced muted label ("TRANG BỊ", "TÙY CHỌN").
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 8),
    this.color,
    this.trailing,
  });

  final String text;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: ValText.label.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    return Padding(
      padding: padding,
      child: trailing == null
          ? Align(alignment: AlignmentDirectional.centerStart, child: label)
          : Row(
              children: [
                Expanded(child: label),
                trailing!,
              ],
            ),
    );
  }
}

/// A group of rows on one `s1` card, separated by 6% hairlines (settings,
/// collection "TRANG BỊ").
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final hairline = valColorsOf(context).hairline;
    final rows = children;
    return Padding(
      padding: margin,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.card),
          side: Theme.of(context).brightness == Brightness.light
              ? BorderSide(color: hairline)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: hairline),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One row of a [GroupedSection]: optional colored leading, title,
/// subtitle, trailing value and "›".
class GroupedRow extends StatelessWidget {
  const GroupedRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron,
    this.accentStrip,
    this.titleColor,
    this.dense = false,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// ValBuddy-style red outline icon before the title (used when [leading]
  /// is null).
  final IconData? icon;

  /// Muted current value before the chevron ("Reaver", "PC").
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to `onTap != null && trailing == null`.
  final bool? showChevron;

  /// 4 px colored strip on the left edge (active account).
  final Color? accentStrip;
  final Color? titleColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final chevron = showChevron ?? (onTap != null && trailing == null);
    final tap = onTap;
    final strip = accentStrip;
    Widget row = Padding(
      padding: EdgeInsets.fromLTRB(16, dense ? 10 : 14, 12, dense ? 10 : 14),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 14),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 22,
              color: legibleAccent(context, ValColors.red, min: 3),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (chevron) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: muted),
          ],
        ],
      ),
    );
    if (strip != null) {
      row = DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: strip, width: 4)),
        ),
        child: row,
      );
    }
    if (tap == null) return row;
    return InkWell(
      onTap: tap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: row,
      ),
    );
  }
}

/// Rounded square icon tile tinted with [color] (collection rows).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 36,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}

/// Design-system progress bar: 6 px, track `#2E3F4E`, red fill (muted when
/// [complete]).
class ValProgressBar extends StatelessWidget {
  const ValProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.trackColor,
    this.complete = false,
    this.semanticsLabel,
  });

  /// 0–1 (clamped).
  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final bool complete;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final v = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    final extras = valColorsOf(context);
    final fill = complete ? extras.muted : (color ?? ValColors.red);
    return Semantics(
      label: semanticsLabel,
      value: '${(v * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: trackColor ?? extras.track),
              TweenAnimationBuilder<double>(
                tween: Tween(end: v),
                duration: ValMotion.slow,
                curve: ValMotion.curve,
                builder: (context, t, _) => FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: t,
                  child: ColoredBox(color: fill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rotated-square "diamond": daily checkpoints, tier tags, browse tiles.
class DiamondPip extends StatelessWidget {
  const DiamondPip({super.key, this.size = 20, this.color, this.filled = true});

  final double size;

  /// Defaults to red when [filled], the track color otherwise.
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? (filled ? ValColors.red : valColorsOf(context).track);
    // The rotated square's diagonal equals [size].
    final side = size / math.sqrt2;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(side * 0.12),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded pill with an optional leading dot ("● Đang diễn ra").
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
    this.icon,
  });

  final String label;
  final Color color;
  final bool showDot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ] else if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: legibleAccent(context, color, min: 3.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small solid badge: "BẠN" (red), "PREMIUM" (gold), "Đăng nhập lại"
/// (amber, [soft]).
class ValBadge extends StatelessWidget {
  const ValBadge(
    this.text, {
    super.key,
    required this.color,
    this.soft = false,
    this.uppercase = false,
  });

  final String text;
  final Color color;

  /// Tinted background + colored text instead of a solid fill.
  final bool soft;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final fg = soft
        ? legibleAccent(context, color, min: 3.5)
        : readableOn(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: soft ? color.withValues(alpha: 0.18) : color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        uppercase ? text.toUpperCase() : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: uppercase ? 0.6 : null,
        ),
      ),
    );
  }
}

/// Wallet balance pill: `s1` background, colored dot, bold amount and a
/// muted currency code ("● 2.440 VP").
class CurrencyPill extends StatelessWidget {
  const CurrencyPill({
    super.key,
    required this.dotColor,
    required this.amount,
    required this.code,
  });

  final Color dotColor;
  final String amount;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            amount,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            code,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular avatar placeholder with the red gradient of the Figma account
/// chip (used when no card art is available).
BoxDecoration redAvatarGradient() => const BoxDecoration(
  shape: BoxShape.circle,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4655), Color(0xFF8A1E2A)],
  ),
);

/// Currency dot colors for the wallet pills.
abstract final class CurrencyColors {
  static const vp = ValColors.red;
  static const kc = Color(0xFFF5C451);
  static const rp = Color(0xFF4FC3E8);
}
