/// "Battle Pass" (docs/design/HOME.md §5.4): level, XP needed per day, days
/// left, the weekly missions closest to done and today's checkpoints. When
/// the Battle Pass is complete the card follows the active event pass. A
/// core card: it shows a skeleton while loading.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../../battlepass/battlepass_routes.dart';
import '../../../battlepass/battlepass_strings.dart';
import '../../../battlepass/data/battlepass_models.dart';
import '../../../battlepass/data/daily_ticket.dart';
import '../../../battlepass/providers/battlepass_providers.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../data/home_battlepass.dart';
import '../../data/home_card.dart';
import '../../home_strings.dart';
import '../../providers/home_card_providers.dart';
import '../home_card_frame.dart';

class BattlePassHomeCard extends ConsumerWidget {
  const BattlePassHomeCard({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeBattlePassSnapshotProvider(puuid));
    if (async.hasValue) {
      final snap = async.value;
      if (snap == null) return const SizedBox.shrink();
      return HomeCardFrame(
        card: HomeCardId.battlePass,
        title: snap.isEvent
            ? [
                BattlePassStrings.eventPass,
                ?snap.eventName,
              ].join(HomeStrings.dot)
            : null,
        onTap: () => unawaited(context.push<Object?>(BattlePassRoutes.root)),
        child: _BpBody(snap: snap, puuid: puuid),
      );
    }
    if (async.hasError) {
      return HomeCardFrame(
        card: HomeCardId.battlePass,
        child: HomeCardError(
          error: async.error!,
          puuid: puuid,
          onRetry: () => retryBattlePass(ref, puuid),
        ),
      );
    }
    return const HomeCardSkeleton(kind: HomeSkeletonKind.battlePass);
  }
}

class _BpBody extends ConsumerWidget {
  const _BpBody({required this.snap, required this.puuid});

  final HomeBpSnapshot snap;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final pass = snap.pass;
    final pace = snap.pace;
    final event = snap.eventLine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              BattlePassStrings.levelOf(
                formatNumber(pass.level),
                formatNumber(pass.levelCount),
              ),
              style: ValText.display(22, color: theme.colorScheme.onSurface),
            ),
            if (snap.daysLeft != null)
              StatusPill(
                label: BattlePassStrings.daysLeft(snap.daysLeft!),
                color: muted,
                showDot: false,
                icon: Icons.schedule_rounded,
              ),
          ],
        ),
        const SizedBox(height: 8),
        ValProgressBar(
          value: pass.levelFraction,
          height: 6,
          complete: pass.isComplete,
          semanticsLabel: BattlePassStrings.levelOf(
            formatNumber(pass.level),
            formatNumber(pass.levelCount),
          ),
        ),
        if (pace != null) ...[
          const SizedBox(height: 10),
          Text(
            BattlePassStrings.xpPerDay(formatNumber(pace.xpPerDay)),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            BattlePassStrings.xpPerDayCaption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        for (final m in snap.nearlyDone) ...[
          const SizedBox(height: 12),
          _MissionRow(mission: m),
        ],
        if (snap.checkpointsDone != null || snap.allMissionsDone) ...[
          const SizedBox(height: 12),
          _FooterRow(snap: snap, puuid: puuid),
        ],
        if (event != null) ...[
          const SizedBox(height: 8),
          _EventLine(event: event),
        ],
        if (snap.isFromCache)
          HomeCardFootnote(
            CommonStrings.updatedAt(formatTime(snap.receivedAt)),
          ),
      ],
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.mission});

  final WeeklyMissionView mission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final title = mission.title ?? BattlePassStrings.unknownMission;
    final progress = BattlePassStrings.missionProgress(
      formatNumber(mission.progress),
      formatNumber(mission.target),
    );
    return Semantics(
      container: true,
      label: '$title, $progress',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (mission.xpGrant > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    BattlePassStrings.xpReward(formatNumber(mission.xpGrant)),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: legibleAccent(context, theme.colorScheme.primary),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ValProgressBar(value: mission.fraction, height: 4),
                ),
                const SizedBox(width: 10),
                Text(
                  progress,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Four diamonds for the daily checkpoints, or the countdown to the next
/// weekly missions once all are done.
class _FooterRow extends ConsumerWidget {
  const _FooterRow({required this.snap, required this.puuid});

  final HomeBpSnapshot snap;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final done = snap.checkpointsDone;
    final refill = snap.missionsRefillAt;
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (done != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < kDailyCheckpointCount; i++)
                      DiamondPip(size: 18, filled: i < done),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  BattlePassStrings.checkpointsDone(
                    done,
                    kDailyCheckpointCount,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        if (snap.allMissionsDone && refill != null)
          ExcludeSemantics(
            child: CountdownText(
              expiresAt: refill,
              builder: BattlePassStrings.newMissionsIn,
              onExpired: () => ref.invalidate(playerContractsProvider(puuid)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class _EventLine extends StatelessWidget {
  const _EventLine({required this.event});

  final EventPassInfo event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = event.progress;
    final text = [
      BattlePassStrings.eventPass,
      ?event.eventName,
      BattlePassStrings.levelOf(
        formatNumber(p.level),
        formatNumber(p.levelCount),
      ),
    ].join(HomeStrings.dot);
    return InkWell(
      onTap: () => unawaited(
        context.push<Object?>(BattlePassRoutes.rewardsFor(p.contract.uuid)),
      ),
      borderRadius: BorderRadius.circular(ValRadius.small),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
