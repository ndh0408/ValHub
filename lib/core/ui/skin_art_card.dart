import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'net_image.dart';
import 'val_widgets.dart';

/// Image-forward grid card for a skin / cosmetic (store, collection,
/// wishlist catalog): a large render over a soft glow in the rarity
/// [tierColor], a colored bottom edge, the name, an optional price row and
/// corner badges.
///
/// ```dart
/// SkinArtCard(
///   imageUrl: skin.image,
///   name: skin.displayName,
///   tierColor: tierColor,
///   footer: const CurrencyAmount.vp(1775),
///   topEnd: WishlistHeartButton(...),
///   onTap: () => showSkinDetailSheet(...),
/// )
/// ```
class SkinArtCard extends StatelessWidget {
  const SkinArtCard({
    super.key,
    required this.imageUrl,
    required this.name,
    this.tierColor,
    this.subtitle,
    this.footer,
    this.topStart,
    this.topEnd,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
    this.imageFit = BoxFit.contain,
    this.dimmed = false,
    this.selected = false,
    this.imageFlex = 5,
  });

  final String? imageUrl;
  final String name;

  /// Rarity color (edge, glow, gradient). Muted when null.
  final Color? tierColor;

  /// Small muted line under the name (weapon, "Đã sở hữu 3/4 cấp").
  final String? subtitle;

  /// Bottom row (price, owned badge…).
  final Widget? footer;

  /// Corner overlays (rarity pip / owned badge, wishlist heart).
  final Widget? topStart;
  final Widget? topEnd;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticsLabel;
  final BoxFit imageFit;

  /// Not owned / unavailable: the render is faded (paint-time tint, no
  /// `Opacity` layer).
  final bool dimmed;

  /// Accent outline (equipped / picked).
  final bool selected;

  /// Share of the card height given to the render (vs. the text block).
  final int imageFlex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final tint = tierColor ?? valColorsOf(context).muted;
    final surface = scheme.surfaceContainer;
    final border = selected
        ? BorderSide(color: scheme.primary, width: 2)
        : BorderSide(color: tint.withValues(alpha: dark ? 0.35 : 0.45));

    final art = Stack(
      fit: StackFit.expand,
      children: [
        // Soft rarity glow behind the render.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.1),
              radius: 0.75,
              colors: [
                tint.withValues(alpha: dark ? 0.32 : 0.22),
                tint.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 26, 14, 6),
          child: NetImage(
            imageUrl,
            fit: imageFit,
            showSkeleton: false,
            opacity: dimmed ? 0.35 : null,
          ),
        ),
        if (topStart != null)
          PositionedDirectional(top: 8, start: 8, end: 48, child: _start()),
        if (topEnd != null)
          PositionedDirectional(top: 4, end: 4, child: topEnd!),
      ],
    );

    final text = Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: dimmed ? scheme.onSurfaceVariant : null,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (footer != null) ...[const SizedBox(height: 6), footer!],
        ],
      ),
    );

    final card = Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ValRadius.card),
        side: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: dark ? 0.22 : 0.12),
                surface.withValues(alpha: 0),
              ],
            ),
            border: Border(bottom: BorderSide(color: tint, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: imageFlex, child: art),
              Flexible(flex: 4, child: text),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      label: semanticsLabel ?? name,
      button: onTap != null,
      selected: selected,
      container: true,
      child: card,
    );
  }

  Widget _start() =>
      Align(alignment: AlignmentDirectional.topStart, child: topStart!);
}

/// Rarity diamond + short tier name ("◆ Độc Quyền") in the tier color,
/// kept legible on the light theme.
class TierTag extends StatelessWidget {
  const TierTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fg = legibleAccent(context, color, min: 3.5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DiamondPip(size: 10, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ValText.label.copyWith(
              fontSize: 10.5,
              color: fg,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
