import 'package:valvn/core/l10n/labels/competitive_labels.dart';
import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/network/riot_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../profile_routes.dart';
import 'widgets/profile_widgets.dart';
import '../data/hit_distribution.dart';
import 'widgets/round_timeline_view.dart';
import 'widgets/scoreboard_view.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S43 "Chi tiết trận đấu". Routes `/profile/match/:id` (inside the tab)
/// and `/match/:id` (above the tab bar); `?player=<puuid>` picks whose
/// summary is shown (default: the active account).
///
/// Layout: the map splash as a collapsing hero (map name, mode, local
/// time, duration, result and the big score; the image flies in from the
/// match card), the player's performance card, then the pinned "Bảng điểm ·
/// Diễn biến vòng đấu" segments over the scoreboard or the round list
/// (each round opens its kill feed).
class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId, this.playerPuuid});

  final String matchId;

  /// Point of view (the "your summary" card and highlighted row).
  final String? playerPuuid;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

/// Hero height (below the status bar) for the current text scale, so the
/// map name, meta line and score never collide with the back button.
double _heroHeight(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
  return 236 + (scale - 1).clamp(0.0, 1.5) * 120;
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  bool _roundsExpanded = false;

  String get _id => widget.matchId.trim().toLowerCase();

  Future<void> _refresh() => ref
      .refresh(matchDetailsProvider(_id).future)
      .then<void>((_) {}, onError: (Object _) {});

  @override
  void didUpdateWidget(covariant MatchDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchId != widget.matchId) _roundsExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(matchDetailsProvider(_id));
    final active = ref.watch(activePuuidProvider);
    final perspective = (widget.playerPuuid ?? active)?.trim().toLowerCase();
    final value = details.value;
    if (value != null) return _loaded(value, perspective);
    if (details.hasError && !details.isLoading) {
      final error = details.error!;
      return SubPageScaffold(
        title: context.l10n.profileMatchDetailTitle,
        onRefresh: _refresh,
        body: error is NotFoundException
            ? EmptyView(
                icon: Icons.hourglass_top_rounded,
                color: valColorsOf(context).warning,
                message: context.l10n.competitiveMatchPending,
                action: OutlinedButton.icon(
                  onPressed: () => ref.invalidate(matchDetailsProvider(_id)),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.commonRetry),
                ),
              )
            : ErrorView(
                error: error,
                puuid: active,
                onRetry: () => ref.invalidate(matchDetailsProvider(_id)),
              ),
      );
    }
    return SubPageScaffold(
      title: context.l10n.profileMatchDetailTitle,
      showLargeTitle: false,
      heroHeight: _heroHeight(context),
      hero: const _HeroSkeleton(),
      slivers: const [SliverToBoxAdapter(child: _DetailSkeleton())],
    );
  }

  Widget _loaded(MatchDetails d, String? perspective) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final map = db.mapByUrl(d.info.mapId);
    final result = d.resultFor(perspective);
    final me = d.player(perspective);
    final inMatch = me != null && !me.isObserver;
    final hasRounds = d.modeKind.isRoundBased && d.playedRounds.isNotEmpty;
    final ranked = baseQueueId(d.info.queueId) == kCompetitiveQueue;
    // Incognito players seen during the live match stay anonymous here and
    // on their profile (SUMMARY U16).
    final hidden = ref
        .watch(matchPrivacyProvider(_id))
        .hiddenIn(d, ref.read(activePuuidProvider));
    void openPlayer(String puuid) => unawaited(
      context.push(ProfileRoutes.player(puuid, hidden: hidden.contains(puuid))),
    );
    final score = result.hasScore
        ? context.l10n.profileScore(result.myScore!, result.otherScore!)
        : null;
    return SubPageScaffold(
      // Bar title once the hero has collapsed: "Sunset · 4 – 13".
      title: context.fmt.inlineFacts([
        map?.displayName ?? context.l10n.profileMatchDetailTitle,
        ?score,
      ]),
      showLargeTitle: false,
      heroHeight: _heroHeight(context),
      hero: _MatchHero(details: d, map: map, result: result),
      onRefresh: _refresh,
      slivers: [
        if (inMatch)
          SliverToBoxAdapter(
            child: _PlayerSummary(
              details: d,
              player: me,
              hidden: hidden.contains(me.subject),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Text(
              ranked
                  ? context.l10n.profileRankedScoreboard
                  : context.l10n.profileScoreboard,
              style: ValText.sectionTitle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        ScoreboardSliver(
          details: d,
          perspective: perspective,
          onOpenPlayer: openPlayer,
          hidden: hidden,
        ),
        // The scoreboard stays on screen; the round list opens under it.
        if (hasRounds)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: GroupedSection(
                children: [
                  // Screen readers announce "expanded / collapsed".
                  Semantics(
                    expanded: _roundsExpanded,
                    child: GroupedRow(
                      icon: Icons.timeline_rounded,
                      title: context.l10n.profileRoundTimeline,
                      trailing: Icon(
                        _roundsExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () =>
                          setState(() => _roundsExpanded = !_roundsExpanded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (hasRounds && _roundsExpanded)
          RoundTimelineSliver(
            details: d,
            perspective: perspective,
            hidden: hidden,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }
}

/// The collapsing header: map splash (a [Hero] from the match card) under
/// a dark scrim, the mode / result chips, the map name in Anton, local day
/// and time · duration, and the big score colored by the result. Always
/// dark (the image), so it uses the dark palette in both themes.
class _MatchHero extends ConsumerWidget {
  const _MatchHero({
    required this.details,
    required this.map,
    required this.result,
  });

  final MatchDetails details;
  final GameMap? map;
  final MatchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final info = details.info;
    final queue = db.queueName(context.l10n, info.isCustom ? '' : info.queueId);
    final start = info.startTime;
    final length = info.gameLength;
    final meta = context.fmt.inlineFacts([
      if (start != null)
        context.l10n.playedAt(
          context.fmt.dayHeader(start, now),
          formatTime(start),
        ),
      if (length != null) context.fmt.durationCoarse(length),
    ]);
    const dark = ValThemeColors.dark;
    final known = result.outcome != MatchOutcome.unknown;
    final resultColor = switch (result.outcome) {
      MatchOutcome.win => dark.win,
      MatchOutcome.loss => dark.loss,
      _ => Colors.white,
    };
    final mapName = map?.displayName ?? context.l10n.commonDash;
    final score = result.hasScore
        ? context.l10n.profileScore(result.myScore!, result.otherScore!)
        : null;
    final white70 = Colors.white.withValues(alpha: 0.78);
    return Semantics(
      container: true,
      label: context.l10n.matchFacts(
        mapName,
        context.l10n.matchOutcome(result.outcome),
        score,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: ValColors.nearBlack),
          Hero(
            tag: matchMapHeroTag(details.matchId),
            child: MapArtImage(map: map, tint: resultColor),
          ),
          // Top scrim for the status bar / back button, bottom scrim for
          // the text: a gradient over the image, never an Opacity layer.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.3, 0.45, 1],
                colors: [
                  Color(0x80000000),
                  Color(0x00000000),
                  Color(0x14000000),
                  Color(0xE6000000),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 3,
            child: ColoredBox(color: known ? resultColor : Colors.transparent),
          ),
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 16,
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _HeroChip(label: queue),
                            if (known)
                              _HeroChip(
                                label: context.l10n.matchOutcome(
                                  result.outcome,
                                ),
                                color: resultColor,
                              ),
                            if (result.placement case final p?)
                              _HeroChip(
                                label: context.l10n.profilePlacement(p),
                                color: dark.gold,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            mapName.toUpperCase(),
                            maxLines: 1,
                            style: ValText.display(40, color: Colors.white),
                          ),
                        ),
                        if (meta.isNotEmpty)
                          Text(
                            meta,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (score != null) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomRight,
                        child: Text(
                          score,
                          maxLines: 1,
                          style: ValText.display(48, color: resultColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent chip on the dark hero ("Thi đấu xếp hạng", "Thắng").
class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return DecoratedBox(
      decoration: BoxDecoration(
        // A dark base keeps the result chip legible over bright map art.
        color: c == null
            ? Colors.black.withValues(alpha: 0.35)
            : Color.alphaBlend(
                c.withValues(alpha: 0.28),
                const Color(0xB3000000),
              ),
        borderRadius: BorderRadius.circular(ValRadius.pill),
        border: c == null ? null : Border.all(color: c.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: c ?? Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Loading hero: the same dark frame with text-shaped bars.
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final bar = Colors.white.withValues(alpha: 0.12);
    Widget block(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: bar,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    return ColoredBox(
      color: ValColors.surfaceHigh,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        block(96, 20),
                        const SizedBox(width: 6),
                        block(52, 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    block(150, 34),
                    const SizedBox(height: 8),
                    block(170, 12),
                  ],
                ),
              ),
              block(84, 44),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton of the body under the hero: performance card, segments, one
/// team of the scoreboard.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.card),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Skeleton(
                          width: 52,
                          height: 52,
                          radius: 26,
                          shimmer: false,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(width: 110, height: 10, shimmer: false),
                              SizedBox(height: 8),
                              Skeleton(width: 160, height: 14, shimmer: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: Skeleton(height: 52, shimmer: false)),
                        SizedBox(width: 8),
                        Expanded(child: Skeleton(height: 52, shimmer: false)),
                        SizedBox(width: 8),
                        Expanded(child: Skeleton(height: 52, shimmer: false)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Skeleton(height: 52, shimmer: false)),
                        SizedBox(width: 8),
                        Expanded(child: Skeleton(height: 52, shimmer: false)),
                        SizedBox(width: 8),
                        Expanded(child: Skeleton(height: 52, shimmer: false)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Skeleton(height: 44, radius: ValRadius.pill, shimmer: false),
          const SizedBox(height: 20),
          const Skeleton(width: 140, height: 16, shimmer: false),
          const SizedBox(height: 10),
          for (var i = 0; i < 5; i++) ...[
            const Skeleton(height: 48, radius: ValRadius.small, shimmer: false),
            const SizedBox(height: 6),
          ],
        ],
      ),
    ),
  );
}

/// "Thành tích của bạn": agent, name, MVP, ±RR, the stat grid and the hit
/// distribution (head / body / legs).
class _PlayerSummary extends ConsumerWidget {
  const _PlayerSummary({
    required this.details,
    required this.player,
    this.hidden = false,
  });

  final MatchDetails details;
  final MatchPlayer player;
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final agent = player.characterId == null
        ? null
        : db.agent(player.characterId!);
    final s =
        details.statsFor(player.subject) ??
        ScoreboardStats(subject: player.subject);
    final isOwn = ref.watch(
      accountProvider(player.subject).select((a) => a != null),
    );
    final competitive = baseQueueId(details.info.queueId) == kCompetitiveQueue;
    final rr = competitive
        ? ref
              .watch(rrHistoryProvider(player.subject))
              .value
              ?.forMatch(details.matchId)
              ?.rrEarned
        : null;
    final outcome = details.resultFor(player.subject).outcome;
    final ring = outcome == MatchOutcome.unknown
        ? theme.colorScheme.outline
        : outcomeColor(context, outcome);
    final roundBased = details.modeKind.isRoundBased;
    String fmt(double? v) =>
        v == null ? context.l10n.competitiveNoValue : formatNumber(v.round());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ValCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHigh,
                    border: Border.all(color: ring, width: 2),
                  ),
                  child: ClipOval(
                    child: NetImage(
                      agent?.displayIconSmall ?? agent?.displayIcon,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOwn
                            ? context.l10n.profileYourSummary
                            : context.l10n.profilePlayerSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                      Text(
                        context.fmt.inlineFacts([
                          playerDisplayName(
                            context.l10n,
                            player.name,
                            hidden: hidden,
                            withTag: false,
                          ),
                          ?agent?.displayName,
                        ]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (s.isMatchMvp || s.isTeamMvp)
                      _MvpBadge(match: s.isMatchMvp),
                    if (rr != null) ...[
                      if (s.isMatchMvp || s.isTeamMvp)
                        const SizedBox(height: 6),
                      RrPill(rr),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            StatGrid(
              tiles: [
                StatTile(
                  label: context.l10n.profileKdaLabel,
                  value: context.l10n.profileKdaValue(
                    s.kills,
                    s.deaths,
                    s.assists,
                  ),
                ),
                StatTile(
                  label: context.l10n.profileAcs,
                  value: fmt(s.acs),
                  tooltip: context.l10n.profileAcsHint,
                ),
                StatTile(
                  label: context.l10n.profileHs,
                  value: s.headshotRate == null
                      ? context.l10n.competitiveNoValue
                      : formatPercent(s.headshotRate!),
                ),
                StatTile(label: context.l10n.profileAdr, value: fmt(s.adr)),
                StatTile(label: context.l10n.profileKd, value: fmt(s.kd)),
                StatTile(
                  label: context.l10n.profileFirstDeaths,
                  value: roundBased
                      ? formatNumber(s.firstDeaths)
                      : context.l10n.competitiveNoValue,
                ),
                StatTile(
                  label: context.l10n.profileKast,
                  value: s.kast == null
                      ? context.l10n.competitiveNoValue
                      : formatPercent(s.kast!),
                  tooltip: context.l10n.profileKastHint,
                ),
                StatTile(
                  label: context.l10n.profileFirstBloods,
                  value: roundBased
                      ? formatNumber(s.firstBloods)
                      : context.l10n.competitiveNoValue,
                ),
              ],
            ),
            if (s.hasHitData) ...[
              const SizedBox(height: 14),
              _HitDistribution(stats: s),
            ],
          ],
        ),
      ),
    );
  }
}

/// Head / body / legs share of the hits: one segmented bar + legend.
class _HitDistribution extends StatelessWidget {
  const _HitDistribution({required this.stats});

  final ScoreboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final shares = hitDistribution(
      stats.headshots,
      stats.bodyshots,
      stats.legshots,
    );
    final parts = [
      (
        label: context.l10n.profileHitHead,
        n: stats.headshots,
        share: shares.head,
        color: theme.colorScheme.primary,
      ),
      (
        label: context.l10n.profileHitBody,
        n: stats.bodyshots,
        share: shares.body,
        color: legibleAccent(context, ValColors.muted, min: 3),
      ),
      (
        label: context.l10n.profileHitLegs,
        n: stats.legshots,
        share: shares.legs,
        color: valColorsOf(context).track,
      ),
    ];
    final legend = [
      for (final p in parts)
        context.l10n.profileHitShare(
          p.label,
          p.share == null ? context.l10n.commonDash : formatPercent(p.share!),
        ),
    ];
    return Semantics(
      label: context.fmt.inlineFacts([
        context.l10n.profileHitDistribution,
        ...legend,
      ]),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.profileHitDistribution,
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (final p in parts)
                    if (p.n > 0)
                      Expanded(
                        flex: p.n,
                        child: ColoredBox(color: p.color),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (var i = 0; i < parts.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: parts[i].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      legend[i],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MvpBadge extends StatelessWidget {
  const _MvpBadge({required this.match});

  final bool match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = match
        ? valColorsOf(context).gold
        : legibleAccent(context, theme.colorScheme.secondary, min: 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            match ? context.l10n.profileMvp : context.l10n.profileTeamMvp,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
