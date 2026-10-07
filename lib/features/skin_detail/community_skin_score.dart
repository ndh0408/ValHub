import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/labels/view_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/util/format.dart';
import '../community/data/community_models.dart';
import 'providers/community_skin_stats.dart';

/// The Community's verdict on a skin as a small chip under store and
/// wishlist cards: "★ 4,6 · 👍 12" (rating, then votes; the thumb because
/// the cards' ♥ is the wishlist). Screen readers get the full sentence.
class CommunitySkinScore extends ConsumerWidget {
  const CommunitySkinScore({super.key, required this.skinUuid});
  final String skinUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(communitySkinStatsProvider(skinUuid)).value;
    if (stats == null || (!stats.rating.hasRatings && stats.vote.votes == 0)) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.labelSmall?.copyWith(
      color: muted,
      fontWeight: FontWeight.w600,
    );
    final rating = stats.rating;
    final votes = stats.vote.votes;
    return Semantics(
      label: context.l10n.skinCommunityLabel(
        rating.hasRatings ? formatRating(rating.average!) : null,
        formatNumber(rating.count),
        formatNumber(votes),
      ),
      excludeSemantics: true,
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (rating.hasRatings)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: valColorsOf(context).gold,
                ),
                const SizedBox(width: 2),
                Text(formatRating(rating.average!), style: style),
              ],
            ),
          if (votes > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thumb_up_outlined, size: 12, color: muted),
                const SizedBox(width: 3),
                Text(formatNumber(votes), style: style),
              ],
            ),
        ],
      ),
    );
  }
}
