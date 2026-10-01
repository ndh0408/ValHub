import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../battlepass_strings.dart';
import '../../data/battlepass_models.dart';
import '../../data/xp_pace.dart';

/// P2 row (ValBuddy style): red outline gift icon, "Xem tất cả phần
/// thưởng", muted "46/55 đã mở khóa" and "›".
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
    return ValCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              BattlePassStrings.viewAllRewards,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              BattlePassStrings.unlockedCount(
                formatNumber(progress.unlockedLevels),
                formatNumber(progress.levelCount),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right, color: muted, size: 20),
        ],
      ),
    );
  }
}

/// VanHub extra: "Còn cần 321.034 XP", "≈ 81 trận Đấu thường", and — when
/// the act end is known — the XP needed per day and the days left, plus
/// the XP still available from weekly missions.
class XpEstimateCard extends StatelessWidget {
  const XpEstimateCard({
    super.key,
    required this.progress,
    required this.queueName,
    this.pace,
    this.weeklyXpLeft = 0,
  });

  final PassProgress progress;

  /// vi name of the Unrated queue (from the content, "Đấu thường").
  final String queueName;

  /// XP per day to finish before the act ends (`null` = unknown end).
  final XpPace? pace;

  /// XP of the weekly missions not completed yet.
  final int weeklyXpLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final win = valColorsOf(context).win;
    final matches = progress.estimatedMatches();
    final pace = this.pace;
    return ValCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.insights,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BattlePassStrings.xpToFinish(
                        formatNumber(progress.xpRemaining),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      BattlePassStrings.matchesEstimate(
                        formatNumber(matches),
                        queueName,
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pace != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PaceStat(
                  icon: Icons.bolt,
                  value: BattlePassStrings.xpPerDay(
                    formatNumber(pace.xpPerDay),
                  ),
                  caption: BattlePassStrings.xpPerDayCaption,
                ),
                PaceStat(
                  icon: Icons.event,
                  value: BattlePassStrings.daysLeft(pace.daysLeft),
                ),
              ],
            ),
          ],
          if (weeklyXpLeft > 0) ...[
            const SizedBox(height: 10),
            Text(
              BattlePassStrings.weeklyXpLeft(formatNumber(weeklyXpLeft)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: legibleAccent(context, win),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            BattlePassStrings.estimateNote,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// Small stat tile on the nested surface ("⚡ 21.469 XP / ngày").
class PaceStat extends StatelessWidget {
  const PaceStat({
    super.key,
    required this.icon,
    required this.value,
    this.caption,
  });

  final IconData icon;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: valColorsOf(context).surface2,
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (caption != null)
                  Text(
                    caption!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton of S20 (pass card, rewards row, estimate, missions),
/// shaped like the final layout.
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
            Skeleton(height: 132, radius: 16, shimmer: false),
            SizedBox(height: 10),
            Skeleton(height: 52, radius: 16, shimmer: false),
            SizedBox(height: 10),
            Skeleton(height: 132, radius: 16, shimmer: false),
            SizedBox(height: 28),
            Skeleton(width: 180, height: 18, shimmer: false),
            SizedBox(height: 12),
            Skeleton(height: 128, radius: 16, shimmer: false),
            SizedBox(height: 28),
            Skeleton(width: 200, height: 18, shimmer: false),
            SizedBox(height: 12),
            Skeleton(height: 84, radius: 16, shimmer: false),
            SizedBox(height: 8),
            Skeleton(height: 84, radius: 16, shimmer: false),
            SizedBox(height: 8),
            Skeleton(height: 84, radius: 16, shimmer: false),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton of S21 (summary card, filter, reward grid).
class RewardsSkeleton extends StatelessWidget {
  const RewardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pinned filter strip, then the summary card.
            const Skeleton(height: 48, radius: 24, shimmer: false),
            const SizedBox(height: 12),
            const Skeleton(height: 96, radius: 16, shimmer: false),
            for (var c = 0; c < 2; c++) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Skeleton(width: 120, height: 18, shimmer: false),
              ),
              const SizedBox(height: 8),
              const Skeleton(height: 3, radius: 2, shimmer: false),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: Skeleton(height: 150, radius: 14, shimmer: false),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Skeleton(height: 150, radius: 14, shimmer: false),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Skeleton(height: 150, radius: 14, shimmer: false),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
