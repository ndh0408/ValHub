import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/util/format.dart';
import '../../battlepass_strings.dart';
import '../../data/battlepass_models.dart';

/// P2 row: gift icon, "Xem tất cả phần thưởng", "46/55 đã mở khóa ›".
class ViewRewardsRow extends StatelessWidget {
  const ViewRewardsRow({
    super.key,
    required this.progress,
    required this.onTap,
  });

  final PassProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: ValColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 20,
                  color: ValColors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BattlePassStrings.viewAllRewards,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      BattlePassStrings.unlockedCount(
                        formatNumber(progress.unlockedLevels),
                        formatNumber(progress.levelCount),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// ValVN extra: "Còn cần 321.034 XP" + "≈ 81 trận Đấu thường".
class XpEstimateCard extends StatelessWidget {
  const XpEstimateCard({
    super.key,
    required this.progress,
    required this.queueName,
  });

  final PassProgress progress;

  /// vi name of the Unrated queue (from the content, "Đấu thường").
  final String queueName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final matches = progress.estimatedMatches();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.insights, color: valColorsOf(context).win, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BattlePassStrings.xpToFinish(
                      formatNumber(progress.xpRemaining),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    BattlePassStrings.matchesEstimate(
                      formatNumber(matches),
                      queueName,
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    BattlePassStrings.estimateNote,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton of S20 (pass card, rewards row, missions).
class BattlePassSkeleton extends StatelessWidget {
  const BattlePassSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Skeleton(height: 176, shimmer: false),
            SizedBox(height: 12),
            Skeleton(height: 60, shimmer: false),
            SizedBox(height: 28),
            Skeleton(width: 180, height: 18, shimmer: false),
            SizedBox(height: 12),
            Skeleton(height: 128, shimmer: false),
            SizedBox(height: 28),
            Skeleton(width: 200, height: 18, shimmer: false),
            SizedBox(height: 12),
            Skeleton(height: 84, shimmer: false),
            SizedBox(height: 8),
            Skeleton(height: 84, shimmer: false),
            SizedBox(height: 8),
            Skeleton(height: 84, shimmer: false),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton of S21 (chapter header + reward grid).
class RewardsSkeleton extends StatelessWidget {
  const RewardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Skeleton(height: 72, shimmer: false),
            const SizedBox(height: 24),
            for (var c = 0; c < 2; c++) ...[
              const Skeleton(width: 120, height: 18, shimmer: false),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: Skeleton(height: 150, shimmer: false)),
                  SizedBox(width: 8),
                  Expanded(child: Skeleton(height: 150, shimmer: false)),
                  SizedBox(width: 8),
                  Expanded(child: Skeleton(height: 150, shimmer: false)),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
