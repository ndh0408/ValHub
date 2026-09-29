import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../profile_routes.dart';
import '../profile_strings.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/rr_trend_chart.dart';

/// S42 "RR theo ngày". Route `/profile/daily-rr`.
class DailyRrScreen extends ConsumerWidget {
  const DailyRrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.dailyRrTitle)),
      body: account == null
          ? const EmptyView(message: CommonStrings.errorNoAccount)
          : _DailyRrBody(puuid: account.puuid),
    );
  }
}

class _DailyRrBody extends ConsumerWidget {
  const _DailyRrBody({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    } else if (list.isEmpty) {
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
    } else {
      final trend = [for (final d in list.take(14)) d.netRr].reversed.toList();
      slivers
        ..add(
          SliverToBoxAdapter(
            child: trend.length >= 2
                ? _TrendCard(changes: trend)
                : const SizedBox(height: 8),
          ),
        )
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

    return RefreshIndicator(
      onRefresh: () => ref
          .refresh(competitiveUpdatesProvider(puuid).future)
          .then<void>((_) {}, onError: (Object _) {}),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}

class _DaysSkeleton extends StatelessWidget {
  const _DaysSkeleton();

  @override
  Widget build(BuildContext context) =>
      const SkeletonList(itemCount: 4, itemHeight: 96);
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.changes});

  final List<int> changes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = changes.fold<int>(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ProfileStrings.rrTrendTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  SignedRrText(net),
                ],
              ),
              const SizedBox(height: 8),
              RrTrendChart(changes: changes, height: 80),
            ],
          ),
        ),
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
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            shape: const Border(),
            collapsedShape: const Border(),
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
                SignedRrText(day.netRr, style: theme.textTheme.titleMedium),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  ProfileStrings.joined([
                    ProfileStrings.winsLosses(day.wins, day.losses, day.draws),
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
                            color: end.isUnranked ? null : end.color,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 28,
                child: NetImage(
                  map?.listViewIcon ?? map?.splash,
                  fit: BoxFit.cover,
                  showSkeleton: false,
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
                    style: theme.textTheme.bodyMedium,
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else if (s != null && s.hasMore)
            OutlinedButton(
              onPressed: () => unawaited(
                ref.read(competitiveUpdatesProvider(puuid).notifier).loadMore(),
              ),
              child: const Text(CommonStrings.loadMore),
            ),
          const SizedBox(height: 12),
          Text(
            ProfileStrings.dailyRrFootnote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
