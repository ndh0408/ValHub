import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../profile_strings.dart';
import 'widgets/rank_card.dart' show formatRr;

/// S41 "Tính toán lên hạng". Route `/profile/rankup`.
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
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.rankUpTitle)),
      body: account == null
          ? const EmptyView(message: CommonStrings.errorNoAccount)
          : _body(account.puuid),
    );
  }

  Widget _body(String puuid) {
    final summary = ref.watch(rankSummaryProvider(puuid));
    return AdaptiveRefresh(
      onRefresh: () async {
        ref.invalidate(competitiveUpdatesProvider(puuid));
        await ref
            .refresh(mmrProvider(puuid).future)
            .then<void>((_) {}, onError: (Object _) {});
      },
      child: AsyncValueView(
        value: summary,
        puuid: puuid,
        onRetry: () => ref.invalidate(mmrProvider(puuid)),
        loading: const _CalculatorSkeleton(),
        data: (s) => _content(puuid, s.current),
      ),
    );
  }

  Widget _content(String puuid, RankInfo current) {
    final Widget child;
    if (current.isUnranked) {
      child = const EmptyView(
        icon: Icons.military_tech_outlined,
        message: ProfileStrings.rankUpUnranked,
      );
    } else if (current.normalizedTier >= kRankUpMaxTier) {
      child = const EmptyView(
        icon: Icons.emoji_events_outlined,
        message: ProfileStrings.rankUpImmortal,
      );
    } else {
      final targets = rankUpTargets(current.normalizedTier);
      final target = _target != null && targets.contains(_target)
          ? _target!
          : targets.first;
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(ProfileStrings.yourRank),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CurrentRankTile(rank: current),
          ),
          const SectionHeader(ProfileStrings.targetRank),
          _TargetPicker(
            targets: targets,
            actUuid: current.actUuid,
            selected: target,
            onSelected: (t) => setState(() => _target = t),
          ),
          const SizedBox(height: 8),
          _Results(puuid: puuid, target: target, actUuid: current.actUuid),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [child],
    );
  }
}

class _CalculatorSkeleton extends StatelessWidget {
  const _CalculatorSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Skeleton(height: 72, shimmer: false),
          SizedBox(height: 16),
          Skeleton(height: 160, shimmer: false),
          SizedBox(height: 16),
          Skeleton(height: 120, shimmer: false),
        ],
      ),
    ),
  );
}

class _CurrentRankTile extends StatelessWidget {
  const _CurrentRankTile({required this.rank});

  final RankInfo rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            NetImage(rank.largeIcon, width: 48, height: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                rank.tierName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: legibleAccent(context, rank.color, min: 3.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(formatRr(rank.rr), style: theme.textTheme.titleSmall),
          ],
        ),
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
                  return SizedBox(
                    width: width,
                    child: Semantics(
                      selected: isSelected,
                      button: true,
                      label: rank.tierName,
                      child: InkWell(
                        onTap: () {
                          if (t != selected) Haptics.selection();
                          onSelected(t);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.14,
                                  )
                                : theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
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
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
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
    required this.actUuid,
  });

  final String puuid;
  final int target;
  final String? actUuid;

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
          padding: EdgeInsets.all(16),
          child: Skeleton(height: 200),
        );
      }
      return const EmptyView(message: CommonStrings.emptyGeneric);
    }
    return _ResultCards(estimate: value);
  }
}

class _ResultCards extends StatelessWidget {
  const _ResultCards({required this.estimate});

  final RankUpEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final form = estimate.form;
    final matches = estimate.matchesAtCurrentForm;
    final best = estimate.bestCaseWins;
    final hasForm = form.sampleSize > 0;
    final p = form.winRate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValCard(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                estimate.alreadyReached
                    ? ProfileStrings.alreadyReached
                    : ProfileStrings.rrLeft(formatNumber(estimate.rrNeeded)),
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ValCard(
            padding: EdgeInsets.zero,
            child: Padding(
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
                        ? theme.textTheme.headlineSmall
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
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: valColorsOf(context).win,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ProfileStrings.bestCase(best),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ValCard(
            padding: EdgeInsets.zero,
            child: Column(
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
                    highlighted: p != null && (p - row.winRate).abs() < 0.025,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ProfileStrings.rankUpFootnote,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
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
    final style = header
        ? theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            fontWeight: highlighted ? FontWeight.w700 : null,
          );
    return Container(
      color: highlighted
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : header
          ? theme.colorScheme.surfaceContainerHigh
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Flexible(
            child: Text(right, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
