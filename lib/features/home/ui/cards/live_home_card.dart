/// "Trận hiện tại" (docs/design/HOME.md §5.1): shown, and pinned to the top,
/// only while the player queues, picks an agent or plays. Home only watches
/// the poller `LiveGameOverlayHost` owns, so the card costs no request.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../../../core/xmpp/xmpp_providers.dart';
import '../../../live_game/data/live_game_logic.dart';
import '../../../live_game/data/live_game_models.dart';
import '../../../live_game/live_game_sheet.dart';
import '../../../live_game/live_game_strings.dart';
import '../../../live_game/providers/live_game_providers.dart';
import '../../../live_game/ui/live_widgets.dart';
import '../../data/home_card.dart';
import '../../data/home_live.dart';
import '../../providers/home_card_providers.dart';
import '../home_card_frame.dart';

import 'package:valvn/core/l10n/l10n.dart';

class LiveHomeCard extends ConsumerWidget {
  const LiveHomeCard({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(homeLiveSnapshotProvider(puuid));
    if (snap == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final surface = theme.colorScheme.surfaceContainer;
    final phaseText = switch (snap.phase) {
      LivePhase.queueing => context.l10n.liveGameInQueue,
      LivePhase.pregame => context.l10n.liveGameAgentSelect,
      _ => context.l10n.liveGameInMatch,
    };
    final summary = LiveGameStrings.joinParts([
      phaseText,
      ?snap.mapName,
      snap.modeLabel,
    ]);
    return HomeCardFrame(
      card: HomeCardId.live,
      semanticsLabel: summary,
      onTap: () => unawaited(showLiveGameSheet(context)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveRefreshRing(puuid: puuid, size: 48),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
      // In a match the map splash shows through on the right; a surface
      // gradient over it keeps the text on the left readable (a gradient,
      // never an Opacity layer).
      background: snap.mapSplash == null
          ? null
          : Stack(
              fit: StackFit.expand,
              children: [
                NetImage(
                  snap.mapSplash,
                  fit: BoxFit.cover,
                  showSkeleton: false,
                  error: const SizedBox.shrink(),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      stops: const [0, 0.5, 1],
                      colors: [
                        surface,
                        surface.withValues(alpha: 0.92),
                        surface.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      child: switch (snap.phase) {
        LivePhase.queueing => _QueueBody(snap: snap),
        LivePhase.pregame => _PregameBody(snap: snap, db: db),
        _ => _InGameBody(snap: snap),
      },
    );
  }
}

/// The map / mode lines under the header.
class _MatchTitle extends StatelessWidget {
  const _MatchTitle({required this.snap});

  final HomeLiveSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final map = snap.mapName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (map != null)
          Text(
            map,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ValText.display(24, color: theme.colorScheme.onSurface),
          ),
        Text(
          snap.modeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QueueBody extends ConsumerWidget {
  const _QueueBody({required this.snap});

  final HomeLiveSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final warning = valColorsOf(context).warning;
    final entry = snap.queueEntryTime;
    final style = theme.textTheme.titleMedium?.copyWith(
      color: legibleAccent(context, warning, min: 4.5),
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final now = ref.watch(clockProvider).now();
    final waited = entry == null ? null : now.toUtc().difference(entry.toUtc());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.radar, color: legibleAccent(context, warning, min: 3)),
            const SizedBox(width: 10),
            Expanded(
              // Only this text ticks; screen readers get a coarse, static
              // value instead of a new announcement every second.
              child: Semantics(
                liveRegion: true,
                label: waited == null
                    ? context.l10n.liveGameInQueue
                    : context.l10n.homeLiveQueueSemantics(
                        formatDurationCoarse(waited),
                      ),
                child: ExcludeSemantics(
                  child: entry == null
                      ? Text(context.l10n.liveGameInQueue, style: style)
                      : TickingBuilder(
                          builder: (context, now) => Text(
                            context.l10n.liveGameInQueueFor(
                              formatMinutesSeconds(
                                now.toUtc().difference(entry.toUtc()),
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          snap.modeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PregameBody extends StatelessWidget {
  const _PregameBody({required this.snap, required this.db});

  final HomeLiveSnapshot snap;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agentId = snap.myAgentId;
    final agent = agentId == null ? null : db.agent(agentId);
    final agentName = agent?.displayName.trim() ?? '';
    final ends = snap.phaseEndsAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: const LiveStatusPill(LiveStatus.agentSelect),
        ),
        const SizedBox(height: 8),
        _MatchTitle(snap: snap),
        if (agentName.isNotEmpty || ends != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (agent?.displayIcon != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(ValRadius.small),
                  child: NetImage(
                    agent!.displayIcon,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    showSkeleton: false,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (agentName.isNotEmpty)
                      Text(
                        snap.myAgentLocked
                            ? context.l10n.liveGameYouLocked(agentName)
                            : context.l10n.liveGameYouHover(agentName),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (ends != null)
                      ExcludeSemantics(
                        child: CountdownText(
                          expiresAt: ends,
                          format: (d) =>
                              formatMinutesSeconds(d, padMinutes: false),
                          builder: context.l10n.liveGameTimeLeft,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: valColorsOf(context).warning,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InGameBody extends ConsumerWidget {
  const _InGameBody({required this.snap});

  final HomeLiveSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showScore = ref.watch(liveScoreEnabledProvider);
    LiveScore? score;
    if (showScore) {
      final presence = ref.watch(ownPresenceProvider).value;
      score = liveScoreOf(presence, now: ref.watch(clockProvider).now());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: const LiveStatusPill(LiveStatus.inProgress),
        ),
        const SizedBox(height: 8),
        _MatchTitle(snap: snap),
        if (score != null) ...[
          const SizedBox(height: 10),
          Semantics(
            label: context.l10n.homeLiveScoreSemantics(score.ally, score.enemy),
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ScoreColumn(
                  value: score.ally,
                  label: context.l10n.homeLiveAllyLabel,
                  color: valColorsOf(context).win,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    context.l10n.commonDash,
                    style: ValText.display(
                      26,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _ScoreColumn(
                  value: score.enemy,
                  label: context.l10n.homeLiveEnemyLabel,
                  color: valColorsOf(context).loss,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatNumber(value),
          style: ValText.display(30, color: legibleAccent(context, color)),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
