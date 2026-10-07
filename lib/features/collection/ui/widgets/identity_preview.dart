import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';

/// Aspect ratio of the wide player-card art (the in-game lobby banner).
const kWideCardRatio = 452 / 128;

/// The in-game lobby banner: the wide card art with the player's name and
/// title over a dark left scrim (a gradient, no `Opacity` layer). Grows
/// taller than the art ratio when large text needs it.
///
/// Wrapped in a [Hero] when [heroTag] is set (the hub banner flies into
/// "Đổi thẻ người chơi").
class IdentityPreview extends StatelessWidget {
  const IdentityPreview({
    super.key,
    required this.cardArt,
    required this.name,
    this.title,
    this.badge,
    this.heroTag,
    this.onTap,
    this.semanticsLabel,
  });

  final String? cardArt;
  final String name;

  /// Equipped title text; hidden when `null` ("Không có danh hiệu").
  final String? title;

  /// Small pill above the name ("Đang dùng", "Xem trước").
  final Widget? badge;
  final Object? heroTag;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const shadow = [Shadow(color: Color(0xAA000000), blurRadius: 6)];
    return LayoutBuilder(
      builder: (context, c) {
        final minHeight = c.maxWidth / kWideCardRatio;
        Widget banner = Material(
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ValRadius.card),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.45),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(minHeight, 72)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NetImage(
                      cardArt,
                      fit: BoxFit.cover,
                      error: Icon(
                        Icons.badge_outlined,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: AlignmentDirectional.centerStart,
                          end: AlignmentDirectional.centerEnd,
                          stops: [0, 0.55, 0.9],
                          colors: [
                            Color(0xB3000000),
                            Color(0x59000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (badge != null) ...[
                            badge!,
                            const SizedBox(height: 6),
                          ],
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              shadows: shadow,
                            ),
                          ),
                          if (title != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              title!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFF5D98B),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                shadows: shadow,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        banner = Semantics(
          button: onTap != null,
          label: semanticsLabel,
          child: banner,
        );
        final tag = heroTag;
        if (tag == null) return banner;
        return Hero(
          tag: tag,
          child: Material(type: MaterialType.transparency, child: banner),
        );
      },
    );
  }
}

/// Translucent dark pill for text over card art ("Đang dùng").
class ArtPill extends StatelessWidget {
  const ArtPill({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(ValRadius.pill),
      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}
