import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/util/format.dart';
import '../../battlepass_strings.dart';
import '../../data/battlepass_models.dart';
import 'bp_ui_bits.dart';

/// P3 "Nhiệm vụ hằng tuần" (S20) with the P5 completed state.
class WeeklyMissionsSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final refill = weekly.refillAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BpSectionTitle(
          title: BattlePassStrings.weeklyMissions,
          subtitle: weekly.isEmpty
              ? null
              : BattlePassStrings.missionsCompleted(
                  weekly.completedCount,
                  weekly.missions.length,
                ),
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
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < weekly.missions.length; i++) ...[
                        if (i > 0) const Divider(indent: 52),
                        WeeklyMissionTile(mission: weekly.missions[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One weekly mission row: status circle, title, bar, "8 / 15", "+XP".
class WeeklyMissionTile extends StatelessWidget {
  const WeeklyMissionTile({super.key, required this.mission});

  final WeeklyMissionView mission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = mission.isComplete;
    final win = valColorsOf(context).win;
    final muted = scheme.onSurfaceVariant;
    final title = mission.title ?? BattlePassStrings.unknownMission;
    final small = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Opacity(
      opacity: done ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: done ? win : muted,
                semanticLabel: done ? BattlePassStrings.missionDone : null,
              ),
            ),
            const SizedBox(width: 16),
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
                    height: 4,
                    color: done ? win : ValColors.red,
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
                        Text(
                          BattlePassStrings.xpReward(
                            formatNumber(mission.xpGrant),
                          ),
                          style: small?.copyWith(
                            color: done ? muted : scheme.onSurface,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

/// P5: trophy card "Đã hoàn thành tất cả nhiệm vụ" + "Nhiệm vụ mới sau …".
class MissionsDoneCard extends StatelessWidget {
  const MissionsDoneCard({super.key, required this.title, this.refillAt});

  final String title;
  final DateTime? refillAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = valColorsOf(context).warning;
    final refill = refillAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: gold, size: 32),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.assignment_outlined, color: muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BattlePassStrings.noWeeklyMissions,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (refill != null)
                    CountdownText(
                      expiresAt: refill,
                      builder: BattlePassStrings.newMissionsIn,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
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
