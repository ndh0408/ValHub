import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
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
import '../profile_strings.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/rr_trend_chart.dart';

/// S42 "RR theo ngày". Route `/profile/daily-rr`.
///
/// A 7-day summary (net RR, record, RR trend), then one card per local day
/// (newest first; days cut at midnight in the device's time zone) that
/// expands to its ranked matches.
class DailyRrScreen extends ConsumerWidget {
  const DailyRrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    final now = ref.watch(clockProvider).now();
    final zone = ProfileStrings.dayBoundary(
      ProfileStrings.timeZoneLabel(now.timeZoneOffset),
    );
    if (account == null) {
      return const SubPageScaffold(
        title: ProfileStrings.dailyRrTitle,
        body: EmptyView(message: CommonStrings.errorNoAccount),
      );
    }
    final puuid = account.puuid;
    return SubPageScaffold(
      title: ProfileStrings.dailyRrTitle,
      subtitle: zone,
      onRefresh: () => ref
          .refresh(competitiveUpdatesProvider(puuid).future)
          .then<void>((_) {}, onError: (Object _) {}),
      slivers: _slivers(context, ref, puuid, now),
    );
  }

  List<Widget> _slivers(
    BuildContext context,
    WidgetRef ref,
    String puuid,
    DateTime now,
  ) {
    final days = ref.watch(dailyRrProvider(puuid));
    final updates = ref.watch(competitiveUpdatesProvider(puuid));
    final list = days.value;
    final updatesError = updates.hasError && !updates.isLoading
        ? updates.error
        : null;

    final slivers = <Widget>[
      if (updatesError != null)
        SliverToBoxAdapter(
          child: ErrorView(
            error: updatesError,
            puuid: puuid,
            compact: list != null && list.isNotEmpty,
            onRetry: () => ref.invalidate(competitiveUpdatesProvider(puuid)),
          ),
        ),
    ];
    if (list == null) {
      if (days.hasError && !days.isLoading) {
        slivers.add(
          SliverToBoxAdapter(
            child: ErrorView(
              error: days.error!,
              puuid: puuid,
              onRetry: () => ref.invalidate(dailyRrProvider(puuid)),
            ),
          ),
        );
      } else if (updatesError == null) {
        slivers.add(const SliverToBoxAdapter(child: _DaysSkeleton()));
      }
      return slivers;
    }
    if (list.isEmpty) {
      if (updatesError == null) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: updates.isLoading
                ? const _DaysSkeleton()
                : const EmptyView(
                    icon: Icons.calendar_month_outlined,
                    message: ProfileStrings.dailyRrEmpty,
                  ),
          ),
        );
      }
      return slivers;
    }
    return slivers
      ..add(
        SliverToBoxAdapter(child: _WeekCard(summary: weekSummary(list, now))),
      )
      ..add(const SliverToBoxAdapter(child: SizedBox(height: 4)))
      ..add(
        SliverList.builder(
          itemCount: list.length,
          itemBuilder: (context, i) => _DayCard(
            key: ValueKey(list[i].date),
            day: list[i],
            initiallyExpanded: i == 0,
          ),
        ),
      )
      ..add(
        SliverToBoxAdapter(
          child: _Footer(puuid: puuid, state: updates.value),
        ),
      );
  }
}

/// Loading skeleton shaped like the summary card and three day cards.
class _DaysSkeleton extends StatelessWidget {
  const _DaysSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Skeleton(height: 168, radius: ValRadius.card, shimmer: false),
          SizedBox(height: 16),
          Skeleton(height: 92, radius: ValRadius.card, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 92, radius: ValRadius.card, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 92, radius: ValRadius.card, shimmer: false),
        ],
      ),
    ),
  );
}

/// "7 ngày qua": net RR, record and matches over the last seven local days,
/// plus the RR trend of the listed days.
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.summary});

  /// Computed by the pure [weekSummary] (unit-tested).
  final WeekSummary summary;

  static const _window = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final net = summary.netRr;
    final trend = summary.trend;
    final trendNet = summary.trendNet;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ValCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ProfileStrings.lastDays(_window).toUpperCase(),
                        style: ValText.label.copyWith(color: muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.isEmpty
                            ? ProfileStrings.todayNone
                            : ProfileStrings.joined([
                                ProfileStrings.winsLosses(
                                  summary.wins,
                                  summary.losses,
                                  summary.draws,
                                  summary.unknown,
                                ),
                                ProfileStrings.matchCount(summary.matches),
                                ProfileStrings.daysPlayed(summary.daysPlayed),
                              ]),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatSignedRr(net),
                  maxLines: 1,
                  style: ValText.display(30, color: rrColor(context, net)),
                ),
              ],
            ),
            if (trend.length >= 2) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: valColorsOf(context).hairline),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ProfileStrings.rrTrendTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                      ),
                    ),
                  ),
                  SignedRrText(trendNet, style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 6),
              RrTrendChart(changes: trend, height: 80),
            ],
          ],
        ),
      ),
    );
  }
}

/// Calendar-style badge of a day: short weekday over the day number.
class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.date, required this.accent});

  final DateTime date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ValRadius.small),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ProfileStrings.weekdayShort[date.weekday - 1],
            maxLines: 1,
            style: ValText.label.copyWith(
              fontSize: 10,
              color: legibleAccent(context, accent, min: 3.5),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              date.day.toString().padLeft(2, '0'),
              maxLines: 1,
              style: ValText.display(20, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({
    super.key,
    required this.day,
    required this.initiallyExpanded,
  });

  final DailyRr day;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final start = RankInfo.resolve(
      db,
      tier: day.startTier,
      rr: day.startRr,
      actUuid: day.startSeasonId,
    );
    final end = RankInfo.resolve(
      db,
      tier: day.endTier,
      rr: day.endRr,
      actUuid: day.endSeasonId,
    );
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ValCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.fromLTRB(12, 6, 10, 6),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            shape: const Border(),
            collapsedShape: const Border(),
            leading: _DayBadge(
              date: day.date,
              accent: rrColor(context, day.netRr),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    formatDayHeader(day.date, now),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                RrPill(day.netRr),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  ProfileStrings.joined([
                    ProfileStrings.winsLosses(
                      day.wins,
                      day.losses,
                      day.draws,
                      day.unknown,
                    ),
                    ProfileStrings.matchCount(day.matches.length),
                  ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(height: 4),
                Semantics(
                  label: ProfileStrings.rankChange(
                    start.tierName,
                    end.tierName,
                  ),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      NetImage(start.icon, width: 20, height: 20),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          start.tierName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: muted,
                        ),
                      ),
                      NetImage(end.icon, width: 20, height: 20),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          end.tierName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: end.isUnranked
                                ? null
                                : legibleAccent(context, end.color, min: 3.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: valColorsOf(context).hairline,
              ),
              const SizedBox(height: 4),
              for (final u in day.matches.reversed) _MatchRow(update: u),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchRow extends ConsumerWidget {
  const _MatchRow({required this.update});

  final CompetitiveUpdate update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final map = db.mapByUrl(update.mapId);
    final after = RankInfo.resolve(
      db,
      tier: update.tierAfter,
      rr: update.rrAfter,
      actUuid: update.seasonId,
    );
    final start = update.matchStartTime;
    return InkWell(
      onTap: () => unawaited(context.push(ProfileRoutes.match(update.matchId))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 36,
                child: Hero(
                  tag: matchMapHeroTag(update.matchId),
                  child: MapArtImage(
                    map: map,
                    tint: rrColor(context, update.rrEarned),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    map?.displayName ?? CommonStrings.dash,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ProfileStrings.joined([
                      if (start != null) formatTime(start),
                      ProfileStrings.rankWithRr(
                        after.tierName,
                        formatNumber(after.rr),
                      ),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SignedRrText(update.rrEarned),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Tải thêm" (older competitive updates) + storage footnote.
class _Footer extends ConsumerWidget {
  const _Footer({required this.puuid, required this.state});

  final String puuid;
  final PagedState<CompetitiveUpdate>? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = state;
    final error = s?.loadMoreError;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null)
            ErrorView(
              error: error,
              puuid: puuid,
              compact: true,
              onRetry: () => unawaited(
                ref.read(competitiveUpdatesProvider(puuid).notifier).loadMore(),
              ),
            )
          else if (s != null && s.isLoadingMore)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                ),
              ),
            )
          else if (s != null && s.hasMore)
            OutlinedButton.icon(
              onPressed: () => unawaited(
                ref.read(competitiveUpdatesProvider(puuid).notifier).loadMore(),
              ),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text(CommonStrings.loadMore),
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.phone_android_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ProfileStrings.dailyRrFootnote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
