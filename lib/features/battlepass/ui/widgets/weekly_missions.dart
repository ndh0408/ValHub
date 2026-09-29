import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../battlepass_strings.dart';
import '../../data/battlepass_models.dart';
import 'bp_ui_bits.dart';

/// P3 "Nhiệm vụ hằng tuần" (S20) with the P5 completed state: header with
/// the refill countdown and "1/3 hoàn thành", then one card per mission.
class WeeklyMissionsSection extends ConsumerWidget {
  const WeeklyMissionsSection({
    super.key,
    required this.weekly,
    this.dailyAllComplete = false,
    this.onRefill,
  });

  final WeeklyMissions weekly;

  /// All four daily checkpoints are done too ("Đã hoàn thành tất cả nhiệm
  /// vụ" instead of "… hằng tuần").
  final bool dailyAllComplete;

  /// Called when the weekly countdown reaches zero (refetch).
  final VoidCallback? onRefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refill = weekly.refillAt;
    final total = weekly.missions.length;
    final now = ref.watch(clockProvider).now();
    final done = weekly.isEmpty
        ? null
        : BattlePassStrings.missionsCompleted(weekly.completedCount, total);
    final reset = refill == null
        ? null
        : BattlePassStrings.resetsAtWall(formatWallTime(refill, now));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BpSectionTitle(
          title: BattlePassStrings.weeklyMissions,
          subtitle: done == null && reset == null
              ? null
              : [?done, ?reset].join(BattlePassStrings.dot),
          trailing: refill == null
              ? null
              : BpHeaderCountdown(expiresAt: refill, onExpired: onRefill),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (weekly.isEmpty)
                _NoMissionsCard(refillAt: refill)
              else ...[
                if (weekly.isAllComplete) ...[
                  MissionsDoneCard(
                    title: dailyAllComplete
                        ? BattlePassStrings.allMissionsDone
                        : BattlePassStrings.allWeeklyDone,
                    refillAt: refill,
                  ),
                  const SizedBox(height: 8),
                ],
                for (var i = 0; i < total; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  ValCard(
                    padding: EdgeInsets.zero,
                    child: WeeklyMissionTile(mission: weekly.missions[i]),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One weekly mission (ValBuddy style): empty ring / green check, title
/// (struck through when done), thin bar, "8 / 15" left and red "+XP"
/// right. Completed rows are muted by color (no `Opacity` layer).
class WeeklyMissionTile extends StatelessWidget {
  const WeeklyMissionTile({super.key, required this.mission});

  final WeeklyMissionView mission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = mission.isComplete;
    final colors = valColorsOf(context);
    final win = colors.win;
    final muted = scheme.onSurfaceVariant;
    final title = mission.title ?? BattlePassStrings.unknownMission;
    final small = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: done
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: win,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 15,
                      color: readableOn(win),
                      semanticLabel: BattlePassStrings.missionDone,
                    ),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: muted, width: 1.6),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: muted,
                    color: done ? muted : null,
                  ),
                ),
                const SizedBox(height: 8),
                BpProgressBar(
                  value: mission.fraction,
                  color: done ? colors.muted : null,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        BattlePassStrings.missionProgress(
                          formatNumber(mission.progress),
                          formatNumber(mission.target),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: small,
                      ),
                    ),
                    if (mission.xpGrant > 0) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          BattlePassStrings.xpReward(
                            formatNumber(mission.xpGrant),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small?.copyWith(
                            color: legibleAccent(context, scheme.primary),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// P5: trophy card "Đã hoàn thành tất cả nhiệm vụ" + "Nhiệm vụ mới sau …",
/// on a warm gold gradient.
class MissionsDoneCard extends StatelessWidget {
  const MissionsDoneCard({super.key, required this.title, this.refillAt});

  final String title;
  final DateTime? refillAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = valColorsOf(context).gold;
    final refill = refillAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ValRadius.card),
        border: Border.all(color: gold.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.22),
            theme.colorScheme.surfaceContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.emoji_events, color: gold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (refill != null) ...[
                  const SizedBox(height: 2),
                  CountdownText(
                    expiresAt: refill,
                    builder: BattlePassStrings.newMissionsIn,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  BpWallTimeText(
                    at: refill,
                    builder: BattlePassStrings.newMissionsAtWall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMissionsCard extends StatelessWidget {
  const _NoMissionsCard({this.refillAt});

  final DateTime? refillAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final refill = refillAt;
    return ValCard(
      child: Row(
        children: [
          IconTile(icon: Icons.assignment_outlined, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BattlePassStrings.noWeeklyMissions,
                  style: theme.textTheme.bodyMedium,
                ),
                if (refill != null) ...[
                  CountdownText(
                    expiresAt: refill,
                    builder: BattlePassStrings.newMissionsIn,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  BpWallTimeText(
                    at: refill,
                    builder: BattlePassStrings.newMissionsAtWall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
