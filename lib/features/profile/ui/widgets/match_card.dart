import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/network/riot_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../data/match_filter.dart';
import '../../profile_strings.dart';
import 'profile_widgets.dart';

/// Match-history card (R8, S40.6): map banner, map name, score, result,
/// agent, K/D/A, ±RR, mode and relative time. Resolves the match details
/// itself (cached on disk); hides itself when [filter]'s map does not match.
class MatchCard extends ConsumerWidget {
  const MatchCard({
    super.key,
    required this.entry,
    required this.puuid,
    required this.onTap,
    this.filter = const MatchFilter(),
  });

  final MatchHistoryEntry entry;

  /// Whose line of the match to show.
  final String puuid;
  final MatchFilter filter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = (matchId: entry.matchId, puuid: puuid);
    final summary = ref.watch(matchSummaryProvider(q));
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final value = summary.value;
    if (value != null && !filter.acceptsMap(value.info.mapId)) {
      return const SizedBox.shrink();
    }
    if (value == null && filter.hasMap && !summary.hasError) {
      return const MatchCardSkeleton();
    }

    final queue = db.queueShortName(value?.info.queueId ?? entry.queueId);
    final started = value?.info.startTime ?? entry.startTime;
    final when = started == null ? null : formatRelative(started, now);

    if (value == null) {
      final error = summary.hasError ? summary.error : null;
      if (error == null) return const MatchCardSkeleton();
      if (filter.hasMap) return const SizedBox.shrink();
      return _CardShell(
        onTap: error is NotFoundException
            ? () => ref.invalidate(matchDetailsProvider(entry.matchId))
            : onTap,
        accent: Theme.of(context).colorScheme.outline,
        map: null,
        child: _FallbackBody(
          title: error is NotFoundException
              ? CompetitiveStrings.matchPending
              : ProfileStrings.matchUnavailable,
          subtitle: ProfileStrings.joined([queue, ?when]),
          onRetry: () => ref.invalidate(matchDetailsProvider(entry.matchId)),
        ),
      );
    }

    final rrRow = ref
        .watch(rrHistoryProvider(puuid))
        .value
        ?.forMatch(entry.matchId);
    final map = db.mapByUrl(value.info.mapId);
    return _CardShell(
      onTap: onTap,
      accent: outcomeColor(context, value.result.outcome),
      map: map?.listViewIcon ?? map?.splash,
      child: _SummaryBody(
        summary: value,
        mapName: map?.displayName ?? CommonStrings.dash,
        agentIcon: value.agentId == null
            ? null
            : db.agent(value.agentId!)?.displayIconSmall ??
                  db.agent(value.agentId!)?.displayIcon,
        meta: ProfileStrings.joined([queue, ?when]),
        rr: baseQueueId(value.info.queueId) == kCompetitiveQueue
            ? rrRow?.rrEarned
            : null,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.onTap,
    required this.accent,
    required this.map,
    required this.child,
  });

  final VoidCallback onTap;
  final Color accent;
  final String? map;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (map != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.18,
                    child: NetImage(
                      map,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      showSkeleton: false,
                      error: const SizedBox.shrink(),
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.surfaceContainer,
                        scheme.surfaceContainer.withValues(alpha: 0.85),
                        scheme.surfaceContainer.withValues(alpha: 0.35),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 72),
                  child: Align(alignment: Alignment.centerLeft, child: child),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: ColoredBox(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.summary,
    required this.mapName,
    required this.agentIcon,
    required this.meta,
    required this.rr,
  });

  final MatchPlayerSummary summary;
  final String mapName;
  final String? agentIcon;
  final String meta;
  final int? rr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final result = summary.result;
    final s = summary.stats;
    final color = outcomeColor(context, result.outcome);
    final score = result.hasScore
        ? ProfileStrings.score(result.myScore!, result.otherScore!)
        : null;
    final place = result.placement;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 42,
              height: 42,
              color: color.withValues(alpha: 0.22),
              child: NetImage(agentIcon, width: 42, height: 42),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mapName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      ProfileStrings.separator,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        result.outcome.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (score != null)
                Text(
                  score,
                  maxLines: 1,
                  style: ValText.display(20, color: color),
                )
              else if (place != null)
                Text(
                  ProfileStrings.placement(place),
                  maxLines: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                ProfileStrings.kda(s.kills, s.deaths, s.assists),
                maxLines: 1,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
              if (rr != null)
                SignedRrText(rr!, style: theme.textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackBody extends StatelessWidget {
  const _FallbackBody({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: CommonStrings.retry,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
