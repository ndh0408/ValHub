import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/util/format.dart';
import '../community/data/community_models.dart';
import 'providers/community_skin_stats.dart';
import 'skin_detail_strings.dart';

class CommunitySkinScore extends ConsumerWidget {
  const CommunitySkinScore({super.key, required this.skinUuid});
  final String skinUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(communitySkinStatsProvider(skinUuid)).value;
    if (stats == null || (!stats.rating.hasRatings && stats.vote.votes == 0)) {
      return const SizedBox.shrink();
    }
    return Text(SkinDetailStrings.communityScore(
      stats.rating.hasRatings ? formatRating(stats.rating.average!) : null,
      formatNumber(stats.rating.count), formatNumber(stats.vote.votes),
    ), style: Theme.of(context).textTheme.labelSmall);
  }
}
