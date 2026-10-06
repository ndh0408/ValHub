import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/util/format.dart';
import '../../data/community_models.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Star color (gold, darkened on light backgrounds).
Color starColor(BuildContext context) => valColorsOf(context).gold;

/// Five read-only stars filled to [value] (0–5, halves shown).
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.value, this.size = 16});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gold = starColor(context);
    final empty = valColorsOf(context).track;
    return Semantics(
      label: context.l10n.communityStarsSemantics(formatRating(value)),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              value >= i - 0.25
                  ? Icons.star_rounded
                  : value >= i - 0.75
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: value >= i - 0.75 ? gold : empty,
            ),
        ],
      ),
    );
  }
}

/// "★ 4,6 (128)" compact badge for lists; "Chưa có đánh giá" when empty.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.style});

  final SkinRating rating;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = (style ?? theme.textTheme.labelMedium)?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final avg = rating.average;
    if (avg == null || rating.count == 0) {
      return Text(
        context.l10n.communityNoRatings,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 16, color: starColor(context)),
        const SizedBox(width: 3),
        Text(formatRating(avg), style: base),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            context.l10n.communityRatingCount(rating.count),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: base?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tap-to-rate stars (1–5), 44 dp targets, haptic tick on change.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  /// 0 = not rated yet.
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gold = starColor(context);
    final empty = valColorsOf(context).track;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Semantics(
            button: true,
            selected: value == i,
            label: context.l10n.communityStarLabel(i),
            excludeSemantics: true,
            child: InkResponse(
              key: ValueKey('star-$i'),
              radius: size * 0.7,
              onTap: () {
                Haptics.selection();
                onChanged(i);
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedScale(
                  scale: value == i ? 1.15 : 1,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    i <= value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: size,
                    color: i <= value ? gold : empty,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 5 → 1 star bars with their share.
class RatingDistribution extends StatelessWidget {
  const RatingDistribution({super.key, required this.summary});

  final SkinSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final track = valColorsOf(context).track;
    final gold = starColor(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  child: Text(
                    formatNumber(stars),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star_rounded, size: 12, color: muted),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: track),
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: summary.share(stars),
                            child: ColoredBox(color: gold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
