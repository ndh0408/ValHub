import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';

/// Collapsing header art of the weapon / skin pages: the gun [render] on a
/// glow of the rarity [tint] that fades into the page background (painted
/// gradients only — no `Opacity`, no blur). The render cross-fades when it
/// changes (variant / level picked) and flies in from the list with
/// [heroTag].
class GunHero extends StatelessWidget {
  const GunHero({
    super.key,
    required this.render,
    this.tint,
    this.heroTag,
    this.bottomStart,
    this.bottomEnd,
  });

  final String? render;

  /// Rarity color; the muted surface when `null` (Standard skin).
  final Color? tint;
  final Object? heroTag;

  /// Overlays on the lower corners (rarity badge, "Xem video").
  final Widget? bottomStart;
  final Widget? bottomEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final color = (tint ?? theme.colorScheme.surfaceContainerHigh).withValues(
      alpha: 1,
    );
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    Widget art = AnimatedSwitcher(
      duration: ValMotion.medium,
      switchInCurve: ValMotion.curve,
      child: NetImage(
        render,
        key: ValueKey(render),
        fit: BoxFit.contain,
        showSkeleton: false,
        error: const SizedBox.shrink(),
      ),
    );
    if (heroTag case final tag?) art = Hero(tag: tag, child: art);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.55, 1],
              colors: [
                Color.alphaBlend(color.withValues(alpha: dark ? 0.42 : 0.3), bg),
                Color.alphaBlend(color.withValues(alpha: dark ? 0.16 : 0.12), bg),
                bg,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.25),
              radius: 0.75,
              colors: [
                color.withValues(alpha: dark ? 0.38 : 0.26),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(32, top + 4, 32, 30),
          child: art,
        ),
        if (bottomStart != null)
          Positioned(left: 16, bottom: 10, child: bottomStart!),
        if (bottomEnd != null)
          Positioned(right: 12, bottom: 6, child: bottomEnd!),
      ],
    );
  }
}
