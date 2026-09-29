import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/network/riot_exception.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../profile_routes.dart';
import '../profile_strings.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/round_timeline_view.dart';
import 'widgets/scoreboard_view.dart';

/// S43 "Chi tiết trận đấu". Routes `/profile/match/:id` (inside the tab)
/// and `/match/:id` (above the tab bar); `?player=<puuid>` picks whose
/// summary is shown (default: the active account).
class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId, this.playerPuuid});

  final String matchId;

  /// Point of view (the "your summary" card and highlighted row).
  final String? playerPuuid;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

enum _Tab { scoreboard, rounds }

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  _Tab _tab = _Tab.scoreboard;

  String get _id => widget.matchId.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(matchDetailsProvider(_id));
    final active = ref.watch(activePuuidProvider);
    final perspective = (widget.playerPuuid ?? active)?.trim().toLowerCase();
    final value = details.value;

    final Widget body;
    if (value != null) {
      body = AdaptiveRefresh(
        onRefresh: () => ref
            .refresh(matchDetailsProvider(_id).future)
            .then<void>((_) {}, onError: (Object _) {}),
        child: _content(value, perspective),
      );
    } else if (details.hasError && !details.isLoading) {
      final error = details.error!;
      body = error is NotFoundException
          ? EmptyView(
              icon: Icons.hourglass_top_rounded,
              color: valColorsOf(context).warning,
              message: CompetitiveStrings.matchPending,
              action: OutlinedButton.icon(
                onPressed: () => ref.invalidate(matchDetailsProvider(_id)),
                icon: const Icon(Icons.refresh),
                label: const Text(CommonStrings.retry),
              ),
            )
          : ErrorView(
              error: error,
              puuid: active,
              onRetry: () => ref.invalidate(matchDetailsProvider(_id)),
            );
    } else {
      body = const _DetailSkeleton();
    }
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.matchDetailTitle)),
      body: body,
    );
  }

  Widget _content(MatchDetails d, String? perspective) {
    final me = d.player(perspective);
    final inMatch = me != null && !me.isObserver;
    final hasRounds = d.modeKind.isRoundBased && d.playedRounds.isNotEmpty;
    final tab = hasRounds ? _tab : _Tab.scoreboard;
    // Incognito players seen during the live match stay anonymous here and
    // on their profile (SUMMARY U16).
    final hidden = ref
        .watch(matchPrivacyProvider(_id))
        .hiddenIn(d, ref.read(activePuuidProvider));
    void openPlayer(String puuid) => unawaited(
      context.push(ProfileRoutes.player(puuid, hidden: hidden.contains(puuid))),
    );
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _MatchHeader(details: d, perspective: perspective),
        ),
        if (inMatch)
          SliverToBoxAdapter(
            child: _PlayerSummary(
              details: d,
              player: me,
              hidden: hidden.contains(me.subject),
            ),
          ),
        if (hasRounds)
          SliverToBoxAdapter(
            child: SegmentedTabs<_Tab>(
              expand: true,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              tabs: const [
                SegmentedTab(
                  value: _Tab.scoreboard,
                  label: ProfileStrings.scoreboard,
                ),
                SegmentedTab(
                  value: _Tab.rounds,
                  label: ProfileStrings.roundTimeline,
                ),
              ],
              selected: tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
        if (tab == _Tab.scoreboard)
          ScoreboardSliver(
            details: d,
            perspective: perspective,
            onOpenPlayer: openPlayer,
            hidden: hidden,
          )
        else
          RoundTimelineSliver(details: d, perspective: perspective),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Skeleton(height: 172, radius: ValRadius.card, shimmer: false),
          SizedBox(height: 12),
          Skeleton(width: 160, height: 28, shimmer: false),
          SizedBox(height: 6),
          Skeleton(width: 220, height: 12, shimmer: false),
          SizedBox(height: 16),
          Skeleton(height: 150, radius: ValRadius.card, shimmer: false),
          SizedBox(height: 16),
          Skeleton(height: 48, radius: ValRadius.pill, shimmer: false),
          SizedBox(height: 16),
          Skeleton(height: 44, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 44, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 44, shimmer: false),
        ],
      ),
    ),
  );
}

/// ValBuddy-style header: big rounded map splash (score overlaid), then
/// the map name in Anton, mode · date · duration and the result tag.
class _MatchHeader extends ConsumerWidget {
  const _MatchHeader({required this.details, required this.perspective});

  final MatchDetails details;
  final String? perspective;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final info = details.info;
    final map = db.mapByUrl(info.mapId);
    final result = details.resultFor(perspective);
    final start = info.startTime;
    final length = info.gameLength;
    final meta = ProfileStrings.joined([
      db.queueName(info.isCustom ? '' : info.queueId),
      if (start != null) formatDateTime(start),
      if (length != null)
        ProfileStrings.durationOf(formatDurationCoarse(length)),
    ]);
    final known = result.outcome != MatchOutcome.unknown;
    final color = known ? outcomeColor(context, result.outcome) : null;
    final fallback = ColoredBox(color: scheme.surfaceContainerHigh);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.card),
            child: SizedBox(
              height: 172,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(
                    map?.splash ?? map?.listViewIcon,
                    fit: BoxFit.cover,
                    showSkeleton: false,
                    error: fallback,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xB3000000)],
                      ),
                    ),
                  ),
                  if (result.hasScore)
                    Positioned(
                      right: 14,
                      bottom: 8,
                      child: Text(
                        ProfileStrings.score(
                          result.myScore!,
                          result.otherScore!,
                        ),
                        style: ValText.display(
                          40,
                          // The scrim is always dark: use the dark palette.
                          color: switch (result.outcome) {
                            MatchOutcome.win => ValThemeColors.dark.win,
                            MatchOutcome.loss => ValThemeColors.dark.loss,
                            _ => Colors.white,
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (map?.displayName ?? CommonStrings.dash).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ValText.display(28, color: scheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (result.placement case final p?)
                    Text(
                      ProfileStrings.placement(p),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  if (known) ...[
                    const SizedBox(height: 4),
                    OutcomeTag(result.outcome),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    String fmt(double? v) =>
        v == null ? CompetitiveStrings.noValue : formatNumber(v.round());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: ValCard(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surfaceContainerHigh,
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
                              ? ProfileStrings.yourSummary
                              : ProfileStrings.playerSummary,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ProfileStrings.joined([
                            playerDisplayName(
                              player.name,
                              hidden: hidden,
                              withTag: false,
                            ),
                            ?agent?.displayName,
                          ]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  if (s.isMatchMvp || s.isTeamMvp)
                    _MvpBadge(match: s.isMatchMvp),
                ],
              ),
              const SizedBox(height: 12),
              StatGrid(
                tiles: [
                  StatTile(
                    label: ProfileStrings.kdaLabel,
                    value: ProfileStrings.kdaValue(
                      s.kills,
                      s.deaths,
                      s.assists,
                    ),
                  ),
                  StatTile(
                    label: ProfileStrings.acs,
                    value: fmt(s.acs),
                    tooltip: ProfileStrings.acsHint,
                  ),
                  StatTile(
                    label: ProfileStrings.hs,
                    value: s.headshotRate == null
                        ? CompetitiveStrings.noValue
                        : formatPercent(s.headshotRate!),
                  ),
                  StatTile(label: ProfileStrings.adr, value: fmt(s.adr)),
                  StatTile(
                    label: ProfileStrings.firstBloods,
                    value: details.modeKind.isRoundBased
                        ? formatNumber(s.firstBloods)
                        : CompetitiveStrings.noValue,
                  ),
                  StatTile(
                    label: ProfileStrings.rr,
                    value: rr == null
                        ? CompetitiveStrings.noValue
                        : formatSignedRr(rr),
                    valueColor: rr == null ? null : rrColor(context, rr),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        : theme.colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        match ? ProfileStrings.mvp : ProfileStrings.teamMvp,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
