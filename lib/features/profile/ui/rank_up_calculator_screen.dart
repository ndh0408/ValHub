import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../profile_strings.dart';
import 'widgets/rank_card.dart' show formatRr;

/// S41 "Tính toán lên hạng". Route `/profile/rankup`.
///
/// Your rank (with the RR bar to the next tier), a grid of target ranks up
/// to Bất Tử 1, then the estimate: RR left with a progress bar, matches at
/// your recent form, the best case, and matches by win rate.
class RankUpCalculatorScreen extends ConsumerStatefulWidget {
  const RankUpCalculatorScreen({super.key});

  @override
  ConsumerState<RankUpCalculatorScreen> createState() =>
      _RankUpCalculatorScreenState();
}

class _RankUpCalculatorScreenState
    extends ConsumerState<RankUpCalculatorScreen> {
  /// Episode-5 target tier; `null` = the next tier.
  int? _target;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const SubPageScaffold(
        title: ProfileStrings.rankUpTitle,
        body: EmptyView(message: CommonStrings.errorNoAccount),
      );
    }
    final puuid = account.puuid;
    return SubPageScaffold(
      title: ProfileStrings.rankUpTitle,
      onRefresh: () async {
        ref.invalidate(competitiveUpdatesProvider(puuid));
        await ref
            .refresh(mmrProvider(puuid).future)
            .then<void>((_) {}, onError: (Object _) {});
      },
      slivers: _slivers(puuid),
    );
  }

  List<Widget> _slivers(String puuid) {
    final summary = ref.watch(rankSummaryProvider(puuid));
    final value = summary.value;
    void retry() => ref.invalidate(mmrProvider(puuid));
    if (value == null) {
      if (summary.hasError && !summary.isLoading) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              error: summary.error!,
              puuid: puuid,
              onRetry: retry,
            ),
          ),
        ];
      }
      return const [SliverToBoxAdapter(child: _CalculatorSkeleton())];
    }
    return [
      if (summary.hasError && !summary.isLoading)
        SliverToBoxAdapter(
          child: ErrorView(
            error: summary.error!,
            puuid: puuid,
            compact: true,
            onRetry: retry,
          ),
        ),
      ..._content(puuid, value.current),
    ];
  }

  List<Widget> _content(String puuid, RankInfo current) {
    if (current.isUnranked) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.military_tech_outlined,
            message: ProfileStrings.rankUpUnranked,
          ),
        ),
      ];
    }
    if (current.normalizedTier >= kRankUpMaxTier) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.emoji_events_outlined,
            message: ProfileStrings.rankUpImmortal,
          ),
        ),
      ];
    }
    final targets = rankUpTargets(current.normalizedTier);
    final target = _target != null && targets.contains(_target)
        ? _target!
        : targets.first;
    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionLabel(
              ProfileStrings.yourRank,
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CurrentRankCard(rank: current),
            ),
            const SectionLabel(ProfileStrings.targetRank),
            _TargetPicker(
              targets: targets,
              actUuid: current.actUuid,
              selected: target,
              onSelected: (t) => setState(() => _target = t),
            ),
            const SizedBox(height: 16),
            _Results(puuid: puuid, target: target, current: current),
          ],
        ),
      ),
    ];
  }
}

class _CalculatorSkeleton extends StatelessWidget {
  const _CalculatorSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget tiles() => const Row(
      children: [
        Expanded(child: Skeleton(height: 72, radius: 16, shimmer: false)),
        SizedBox(width: 8),
        Expanded(child: Skeleton(height: 72, radius: 16, shimmer: false)),
        SizedBox(width: 8),
        Expanded(child: Skeleton(height: 72, radius: 16, shimmer: false)),
      ],
    );
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Skeleton(width: 110, height: 12, shimmer: false),
            const SizedBox(height: 10),
            const Skeleton(height: 96, radius: ValRadius.card, shimmer: false),
            const SizedBox(height: 24),
            const Skeleton(width: 120, height: 12, shimmer: false),
            const SizedBox(height: 10),
            tiles(),
            const SizedBox(height: 8),
            tiles(),
            const SizedBox(height: 20),
            const Skeleton(height: 132, radius: ValRadius.card, shimmer: false),
            const SizedBox(height: 8),
            const Skeleton(height: 150, radius: ValRadius.card, shimmer: false),
          ],
        ),
      ),
    );
  }
}

/// Big rank icon on a soft glow, the tier name in its color, the RR and a
/// bar to the next tier.
class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard({required this.rank});

  final RankInfo rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = rank.color;
    final showBar = rank.rr >= 0 && rank.rr <= 100;
    return ValCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.35),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: NetImage(rank.largeIcon, width: 56, height: 56),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.tierName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: legibleAccent(context, color, min: 3.5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRr(rank.rr),
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                if (showBar) ...[
                  const SizedBox(height: 8),
                  ValProgressBar(
                    value: rank.rr / 100,
                    height: 5,
                    semanticsLabel: ProfileStrings.rrToNext(rank.rr),
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

/// Grid of rank icons from the next tier up to Bất Tử 1.
class _TargetPicker extends ConsumerWidget {
  const _TargetPicker({
    required this.targets,
    required this.actUuid,
    required this.selected,
    required this.onSelected,
  });

  final List<int> targets;
  final String? actUuid;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 8.0;
          final columns = (constraints.maxWidth / 84).floor().clamp(3, 6);
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final t in targets)
                () {
                  final rank = RankInfo.resolve(db, tier: t, actUuid: actUuid);
                  final isSelected = t == selected;
                  final accent = theme.colorScheme.primary;
                  return SizedBox(
                    width: width,
                    child: Semantics(
                      selected: isSelected,
                      button: true,
                      label: rank.tierName,
                      excludeSemantics: true,
                      child: Material(
                        color: isSelected
                            ? accent.withValues(alpha: 0.14)
                            : theme.colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? accent
                                : valColorsOf(context).hairline,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            if (t != selected) Haptics.selection();
                            onSelected(t);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Column(
                              children: [
                                NetImage(rank.icon, width: 36, height: 36),
                                const SizedBox(height: 4),
                                Text(
                                  rank.tierName,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }(),
            ],
          );
        },
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.puuid,
    required this.target,
    required this.current,
  });

  final String puuid;
  final int target;
  final RankInfo current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref.watch(
      rankUpEstimateProvider((puuid: puuid, targetTier: target)),
    );
    final value = estimate.value;
    if (value == null) {
      if (estimate.hasError && !estimate.isLoading) {
        return ErrorView(
          error: estimate.error!,
          puuid: puuid,
          onRetry: () => ref.invalidate(competitiveUpdatesProvider(puuid)),
        );
      }
      if (estimate.isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonShimmer(
            child: Column(
              children: [
                Skeleton(height: 132, radius: ValRadius.card, shimmer: false),
                SizedBox(height: 8),
                Skeleton(height: 150, radius: ValRadius.card, shimmer: false),
              ],
            ),
          ),
        );
      }
      return const EmptyView(message: CommonStrings.emptyGeneric);
    }
    return _ResultCards(estimate: value, current: current);
  }
}

class _ResultCards extends ConsumerWidget {
  const _ResultCards({required this.estimate, required this.current});

  final RankUpEstimate estimate;
  final RankInfo current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final muted = theme.colorScheme.onSurfaceVariant;
    final colors = valColorsOf(context);
    final form = estimate.form;
    final matches = estimate.matchesAtCurrentForm;
    final best = estimate.bestCaseWins;
    final hasForm = form.sampleSize > 0;
    final target = RankInfo.resolve(
      db,
      tier: estimate.targetTier,
      actUuid: current.actUuid,
    );
    final progress = estimate.progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // RR left + progress from the current tier to the target.
          ValCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    NetImage(current.icon, width: 28, height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: muted,
                      ),
                    ),
                    NetImage(target.icon, width: 28, height: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ProfileStrings.progressTo(target.tierName),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  estimate.alreadyReached
                      ? ProfileStrings.alreadyReached
                      : ProfileStrings.rrLeft(formatNumber(estimate.rrNeeded)),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ValProgressBar(
                  value: progress,
                  height: 6,
                  color: estimate.alreadyReached ? colors.win : null,
                  semanticsLabel: ProfileStrings.progressToTarget,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Matches at the recent form + best case.
          ValCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasForm
                      ? ProfileStrings.atCurrentFormWith(
                          formatSigned(form.avgGain.round()),
                          formatSigned(-form.avgLoss.round()),
                        )
                      : ProfileStrings.atCurrentForm,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: 4),
                Text(
                  !hasForm
                      ? ProfileStrings.rankUpNoForm
                      : matches == null
                      ? CompetitiveStrings.cannotEstimate
                      : ProfileStrings.aboutMatches(matches),
                  style: hasForm
                      ? theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        )
                      : theme.textTheme.bodyMedium,
                ),
                if (hasForm) ...[
                  const SizedBox(height: 4),
                  Text(
                    ProfileStrings.recentForm(form.wins, form.losses),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
                if (best != null && best > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.win.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ValRadius.small),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: colors.win, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ProfileStrings.bestCase(best),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SectionLabel(
            ProfileStrings.byWinRateTitle,
            padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
          ),
          GroupedSection(
            margin: EdgeInsets.zero,
            children: [
              _TableRow(
                left: ProfileStrings.winRate,
                right: ProfileStrings.matchesNeeded,
                header: true,
              ),
              for (final row in estimate.byWinRate)
                _TableRow(
                  left: formatPercent(row.winRate),
                  right: row.matches == null
                      ? CompetitiveStrings.noValue
                      : ProfileStrings.aboutMatches(row.matches!),
                  highlighted: estimate.isNearestWinRate(row.winRate),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ProfileStrings.rankUpFootnote,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.left,
    required this.right,
    this.header = false,
    this.highlighted = false,
  });

  final String left;
  final String right;
  final bool header;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final style = header
        ? theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          );
    return Semantics(
      selected: highlighted,
      hint: highlighted ? ProfileStrings.yourWinRate : null,
      child: Container(
        decoration: BoxDecoration(
          color: highlighted
              ? accent.withValues(alpha: 0.12)
              : header
              ? theme.colorScheme.surfaceContainerHigh
              : null,
          border: highlighted
              ? Border(left: BorderSide(color: accent, width: 3))
              : null,
        ),
        padding: EdgeInsets.fromLTRB(highlighted ? 13 : 16, 11, 16, 11),
        child: Row(
          children: [
            Expanded(child: Text(left, style: style)),
            Flexible(
              child: Text(right, style: style, textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
