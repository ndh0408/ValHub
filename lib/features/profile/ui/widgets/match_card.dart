import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/network/riot_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../data/match_filter.dart';
import '../../profile_strings.dart';
import 'profile_widgets.dart';

/// Match-history card (R8, S40.6), ValBuddy-style: a large map image with
/// the agent (+ rank icon) and ±RR on its corners, then "Icebox 4 – 5 Thua",
/// K/D/A · relative time and the mode. Resolves the match details
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
    final result = value.result;
    final mapName = map?.displayName ?? CommonStrings.dash;
    final competitive = baseQueueId(value.info.queueId) == kCompetitiveQueue;
    final accent = outcomeColor(context, result.outcome);
    return _CardShell(
      onTap: onTap,
      accent: accent,
      art: _MapArt(
        map: map?.splash ?? map?.listViewIcon,
        accent: accent,
        rankTier: competitive ? value.player.competitiveTier : 0,
        seasonId: value.info.seasonId,
        agentIcon: value.agentId == null
            ? null
            : db.agent(value.agentId!)?.displayIconSmall ??
                  db.agent(value.agentId!)?.displayIcon,
        rr: competitive ? rrRow?.rrEarned : null,
      ),
      semanticsLabel: ProfileStrings.matchSemantics(
        mapName,
        result.outcome.label,
        result.hasScore
            ? ProfileStrings.score(result.myScore!, result.otherScore!)
            : null,
      ),
      child: _SummaryBody(
        summary: value,
        mapName: mapName,
        mode: queue,
        when: when,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.onTap,
    required this.accent,
    required this.child,
    this.art,
    this.semanticsLabel,
  });

  final VoidCallback onTap;
  final Color accent;

  /// Large map image on top (match cards); `null` for the compact
  /// fallback card.
  final Widget? art;
  final Widget child;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: Material(
          color: theme.colorScheme.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ValRadius.card),
            side: light
                ? BorderSide(color: valColorsOf(context).hairline)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (art != null) ...[
                  art!,
                  // Result-colored seam between the art and the text.
                  SizedBox(height: 2, child: ColoredBox(color: accent)),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Map image of a match card with the agent (+ rank icon) and the RR
/// change overlaid on the top corners.
class _MapArt extends StatelessWidget {
  const _MapArt({
    required this.map,
    required this.agentIcon,
    required this.accent,
    required this.rankTier,
    required this.seasonId,
    required this.rr,
  });

  final String? map;
  final String? agentIcon;
  final Color accent;
  final int rankTier;
  final String? seasonId;
  final int? rr;

  static const height = 116.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.map_outlined,
          size: 32,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (map == null)
            fallback
          else
            NetImage(
              map,
              fit: BoxFit.cover,
              showSkeleton: false,
              error: fallback,
            ),
          // Top scrim so the overlays stay readable on bright maps.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0x73000000), Color(0x00000000)],
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x99000000),
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    child: ClipOval(
                      child: NetImage(
                        agentIcon,
                        width: 40,
                        height: 40,
                        showSkeleton: false,
                      ),
                    ),
                  ),
                  if (rankTier > 2)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: RankBadge(
                        tier: rankTier,
                        seasonId: seasonId,
                        size: 20,
                        showName: false,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (rr != null)
            Positioned(
              right: 10,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xB3000000),
                  borderRadius: BorderRadius.circular(ValRadius.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: Text(
                    formatSignedRr(rr!),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      // Dark-theme colors: the pill is always dark.
                      color: rr! > 0
                          ? ValThemeColors.dark.win
                          : rr! < 0
                          ? ValThemeColors.dark.loss
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.summary,
    required this.mapName,
    required this.mode,
    required this.when,
  });

  final MatchPlayerSummary summary;
  final String mapName;
  final String mode;
  final String? when;

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
    final mvp = s.isMatchMvp || s.isTeamMvp;
    final small = theme.textTheme.labelSmall?.copyWith(color: muted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      mapName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (score != null)
                      Text(
                        score,
                        maxLines: 1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    else if (place != null)
                      Text(
                        ProfileStrings.placement(place),
                        maxLines: 1,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Text(
                      result.outcome.label,
                      maxLines: 1,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (mvp)
                      Text(
                        s.isMatchMvp
                            ? ProfileStrings.mvp
                            : ProfileStrings.teamMvp,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: s.isMatchMvp
                              ? valColorsOf(context).gold
                              : legibleAccent(
                                  context,
                                  theme.colorScheme.secondary,
                                ),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  children: [
                    Text(
                      ProfileStrings.kda(s.kills, s.deaths, s.assists),
                      maxLines: 1,
                      style: small,
                    ),
                    if (when != null)
                      Text(
                        '${ProfileStrings.separator}$when',
                        maxLines: 1,
                        style: small,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              mode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: small,
            ),
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
