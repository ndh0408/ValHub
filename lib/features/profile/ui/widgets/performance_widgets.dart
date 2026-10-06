import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/labels/content_labels.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/segmented_tabs.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../data/performance_view.dart';
import '../../providers/ledger_backfill.dart';
import 'profile_widgets.dart';

/// A rate or average, or the dash when the sample cannot prove it.
String perfValue(
  BuildContext context,
  double? value, {
  bool allowed = true,
  int decimals = 0,
}) {
  if (!allowed || value == null) return context.l10n.competitiveNoValue;
  return decimals == 0
      ? formatNumber(value.round())
      : formatNumber(double.parse(value.toStringAsFixed(decimals)));
}

/// A share (0–1) as a percentage, or the dash.
String perfPercent(
  BuildContext context,
  double? value, {
  bool allowed = true,
}) => !allowed || value == null
    ? context.l10n.competitiveNoValue
    : formatPercent(value);

/// Win rate, record and the four per-round stats of the filtered matches.
class PerfOverviewCard extends StatelessWidget {
  const PerfOverviewCard({super.key, required this.stats});

  final PerfAggregate stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final rounds = stats.hasRoundSample;
    final kd = stats.kd;
    return ValCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              WinRateRing(rate: stats.hasWinRateSample ? stats.winRate : null),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileWinRate.toUpperCase(),
                      style: ValText.label.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.profileMatchCount(stats.games),
                      style: ValText.display(
                        26,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      context.l10n.profileRecordShort(
                        stats.wins,
                        stats.losses,
                        stats.draws,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatGrid(
            columns: 4,
            tiles: [
              StatTile(
                label: context.l10n.profileKd,
                value: perfValue(context, kd, allowed: rounds, decimals: 2),
                valueColor: !rounds || kd == null
                    ? null
                    : kd >= 1
                    ? colors.win
                    : colors.loss,
              ),
              StatTile(
                label: context.l10n.profileAcs,
                value: perfValue(context, stats.acs, allowed: rounds),
                tooltip: context.l10n.profileAcsHint,
              ),
              StatTile(
                label: context.l10n.profileAdr,
                value: perfValue(
                  context,
                  stats.adr,
                  allowed: stats.hasDamageSample,
                ),
              ),
              StatTile(
                label: context.l10n.profileHs,
                value: perfPercent(
                  context,
                  stats.headshotRate,
                  allowed: stats.hasHitSample,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String perfMetricLabel(BuildContext context, PerfMatchMetric metric) =>
    switch (metric) {
      PerfMatchMetric.acs => context.l10n.profileAcs,
      PerfMatchMetric.kd => context.l10n.profileKd,
      PerfMatchMetric.adr => context.l10n.profileAdr,
      PerfMatchMetric.headshotRate => context.l10n.profileHs,
    };

String _metricText(BuildContext context, PerfMatchMetric metric, double v) =>
    switch (metric) {
      PerfMatchMetric.headshotRate => formatPercent(v),
      PerfMatchMetric.kd => perfValue(context, v, decimals: 2),
      _ => perfValue(context, v),
    };

/// "Từng trận": one bar per recent match for the chosen stat, colored by the
/// result (the result is also in the semantics label, never colour only),
/// with the average of the same matches as a dashed line. Tapping a bar
/// opens the match.
class PerfMatchChartCard extends StatelessWidget {
  const PerfMatchChartCard({
    super.key,
    required this.view,
    required this.metric,
    required this.onMetric,
    required this.onOpenMatch,
  });

  final PerformanceView view;
  final PerfMatchMetric metric;
  final ValueChanged<PerfMatchMetric> onMetric;
  final ValueChanged<String> onOpenMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final chart = view.chart(metric);
    final average = chart.average;
    return ValCard(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      context.l10n.profilePerformancePerMatchTitle,
                      style: ValText.sectionTitle.copyWith(
                        fontSize: 17,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                if (!chart.isEmpty && average != null)
                  Text(
                    context.l10n.profilePerformanceAverage(
                      _metricText(context, metric, average),
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SegmentedTabs<PerfMatchMetric>(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: [
              for (final m in PerfMatchMetric.values)
                SegmentedTab(value: m, label: perfMetricLabel(context, m)),
            ],
            selected: metric,
            onChanged: onMetric,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: chart.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      context.l10n.profilePerformanceChartEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  )
                : _Bars(chart: chart, metric: metric, onOpenMatch: onOpenMatch),
          ),
          if (!chart.isEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    formatDayMonth(chart.points.first.line.startedAt.toLocal()),
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.profilePerformancePerMatchHint,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                  ),
                  Text(
                    formatDayMonth(chart.points.last.line.startedAt.toLocal()),
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({
    required this.chart,
    required this.metric,
    required this.onOpenMatch,
  });

  final PerfMatchChart chart;
  final PerfMatchMetric metric;
  final ValueChanged<String> onOpenMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final points = chart.points;
    final top = points.map((p) => p.value).reduce(math.max);
    final average = chart.average;
    final maxY = math.max(top, average ?? 0) * 1.15;
    final colors = valColorsOf(context);
    return Semantics(
      label: context.fmt.inlineFacts([
        context.l10n.profilePerformancePerMatchTitle,
        perfMetricLabel(context, metric),
        context.l10n.profileLastMatches(points.length),
        context.l10n.profileRecordShort(
          points.where((p) => p.line.outcome == MatchOutcome.win).length,
          points.where((p) => p.line.outcome == MatchOutcome.loss).length,
          points.where((p) => p.line.outcome == MatchOutcome.draw).length,
        ),
        if (average != null)
          context.l10n.profilePerformanceAverage(
            _metricText(context, metric, average),
          ),
      ]),
      child: SizedBox(
        height: 132,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / math.max(points.length, 1);
            final width = (slot * 0.62).clamp(4.0, 18.0);
            return BarChart(
              duration: Duration.zero,
              BarChartData(
                maxY: maxY <= 0 ? 1 : maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (average != null)
                      HorizontalLine(
                        y: average,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: dark ? 0.55 : 0.7,
                        ),
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                  ],
                ),
                // The whole column of a match is its tap target (a bar
                // can be a few pixels wide and short).
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  allowTouchBarBackDraw: true,
                  touchExtraThreshold: EdgeInsets.symmetric(
                    horizontal: math.max(0, (slot - width) / 2),
                  ),
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final i = response?.spot?.touchedBarGroupIndex;
                    if (i == null || i < 0 || i >= points.length) return;
                    onOpenMatch(points[i].line.matchId);
                  },
                ),
                barGroups: [
                  for (var i = 0; i < points.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: points[i].value,
                          width: width,
                          color: switch (points[i].line.outcome) {
                            MatchOutcome.win => colors.win,
                            MatchOutcome.loss => colors.loss,
                            _ => colors.draw,
                          },
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY <= 0 ? 1 : maxY,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Opening duels (first bloods vs first deaths) and multi-kill rounds.
class PerfOpeningsCard extends StatelessWidget {
  const PerfOpeningsCard({super.key, required this.stats});

  final PerfAggregate stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final rounds = stats.hasRoundSample;
    final opening = openingWinRate(stats);
    return ValCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardTitle(context.l10n.profilePerformanceOpeningsTitle),
          const SizedBox(height: 10),
          StatGrid(
            tiles: [
              StatTile(
                label: context.l10n.profilePerformanceOpeningWin,
                value: perfPercent(context, opening),
                tooltip: context.l10n.profilePerformanceOpeningWinHint,
                valueColor: opening == null
                    ? null
                    : opening >= 0.5
                    ? colors.win
                    : colors.loss,
              ),
              StatTile(
                label: context.l10n.profilePerformanceFirstBloodsPerGame,
                value: perfValue(
                  context,
                  stats.firstBloodsPerGame,
                  allowed: rounds,
                  decimals: 1,
                ),
              ),
              StatTile(
                label: context.l10n.profilePerformanceFirstDeathsPerGame,
                value: perfValue(
                  context,
                  stats.firstDeathsPerGame,
                  allowed: rounds,
                  decimals: 1,
                ),
              ),
            ],
          ),
          if (stats.hasMultiKills) ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.profilePerformanceMultiKillsTitle.toUpperCase(),
              style: ValText.label.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            StatGrid(
              tiles: [
                StatTile(
                  label: context.l10n.profilePerformanceMultiKill('k3'),
                  value: formatNumber(stats.multi3),
                ),
                StatTile(
                  label: context.l10n.profilePerformanceMultiKill('k4'),
                  value: formatNumber(stats.multi4),
                ),
                StatTile(
                  label: context.l10n.profilePerformanceMultiKill('ace'),
                  value: formatNumber(stats.multi5),
                  valueColor: stats.multi5 > 0 ? colors.gold : null,
                ),
              ],
            ),
            const SizedBox(height: 6),
            _Note(
              context.l10n.profilePerformanceMultiKillsNote(stats.multiGames),
            ),
          ],
        ],
      ),
    );
  }
}

/// Attack vs defense: round win rate, K/D and rounds counted per side.
class PerfSidesCard extends StatelessWidget {
  const PerfSidesCard({super.key, required this.view});

  final PerformanceView view;

  @override
  Widget build(BuildContext context) {
    final overall = view.overall;
    return ValCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardTitle(context.l10n.profilePerformanceSegmentLabel('sides')),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SideColumn(
                    title: context.l10n.profilePerformanceAttack,
                    icon: Icons.bolt_rounded,
                    stats: overall.attack,
                    qualifies: view.attackQualifies,
                  ),
                ),
                VerticalDivider(
                  width: 24,
                  color: valColorsOf(context).hairline,
                ),
                Expanded(
                  child: _SideColumn(
                    title: context.l10n.profilePerformanceDefense,
                    icon: Icons.shield_outlined,
                    stats: overall.defense,
                    qualifies: view.defenseQualifies,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Note(
            context.l10n.profilePerformanceSideCoverage(
              view.roundsWithSide,
              view.roundsTotal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({
    required this.title,
    required this.icon,
    required this.stats,
    required this.qualifies,
  });

  final String title;
  final IconData icon;
  final SideTotals stats;
  final bool qualifies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final rate = qualifies ? stats.winRate : null;
    final kd = qualifies ? stats.kd : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          perfPercent(context, rate),
          style: ValText.display(
            28,
            color: rate == null
                ? theme.colorScheme.onSurfaceVariant
                : rate >= 0.5
                ? colors.win
                : colors.loss,
          ),
        ),
        Text(
          context.l10n.profilePerformanceRoundWin,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.fmt.inlineFacts([
            '${context.l10n.profileKd} ${perfValue(context, kd, decimals: 2)}',
            context.l10n.profilePerformanceRounds(stats.rounds),
          ]),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The agents / maps / queues table. A row narrows the whole screen to it.
class PerfBreakdownCard extends StatelessWidget {
  const PerfBreakdownCard({
    super.key,
    required this.view,
    required this.db,
    required this.segment,
    required this.segments,
    required this.onSegment,
    required this.onPick,
  });

  final PerformanceView view;
  final ContentDb db;
  final PerfSegment segment;

  /// The tables worth showing (a dimension already filtered to one value
  /// is left out).
  final List<PerfSegment> segments;
  final ValueChanged<PerfSegment> onSegment;
  final void Function(PerfSegment segment, String key) onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = switch (segment) {
      PerfSegment.agents => view.byAgent,
      PerfSegment.maps => view.byMap,
      PerfSegment.queues => view.byQueue,
    };
    final hairline = valColorsOf(context).hairline;
    final label = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.4,
    );
    return ValCard(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (segments.length > 1) ...[
            SegmentedTabs<PerfSegment>(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: [
                for (final s in segments)
                  SegmentedTab(
                    value: s,
                    label: context.l10n.profilePerformanceSegmentLabel(s.name),
                  ),
              ],
              selected: segment,
              onChanged: onSegment,
            ),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: _wRate,
                  child: Text(
                    context.l10n.profileWinRate,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: label,
                  ),
                ),
                SizedBox(
                  width: _wStat,
                  child: Text(
                    context.l10n.profileKd,
                    textAlign: TextAlign.end,
                    style: label,
                  ),
                ),
                SizedBox(
                  width: _wStat,
                  child: Text(
                    context.l10n.profileAcs,
                    textAlign: TextAlign.end,
                    style: label,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: hairline),
            _BreakdownRow(
              segment: segment,
              group: groups[i],
              db: db,
              onTap: () => onPick(segment, groups[i].key),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _Note(context.l10n.profilePerformanceDrillHint),
          ),
        ],
      ),
    );
  }
}

const double _wRate = 64;
const double _wStat = 52;

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.segment,
    required this.group,
    required this.db,
    required this.onTap,
  });

  final PerfSegment segment;
  final PerfGroup group;
  final ContentDb db;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final a = group.aggregate;
    final rate = a.hasWinRateSample ? a.winRate : null;
    final num = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final (name, image) = switch (segment) {
      PerfSegment.agents => (
        db.agent(group.key)?.displayName ?? context.l10n.commonUnknownItem,
        db.agent(group.key)?.displayIconSmall ??
            db.agent(group.key)?.displayIcon,
      ),
      PerfSegment.maps => (
        db.mapByUrl(group.key)?.displayName ?? context.l10n.commonUnknownItem,
        db.mapByUrl(group.key)?.listViewIcon,
      ),
      PerfSegment.queues => (db.queueName(context.l10n, group.key), null),
    };
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _RowArt(segment: segment, image: image),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.l10n.profileMatchCount(a.games),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _wRate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      perfPercent(context, rate),
                      style: num?.copyWith(
                        color: rate == null
                            ? null
                            : rate >= 0.5
                            ? colors.win
                            : colors.loss,
                      ),
                    ),
                    if (rate != null) ...[
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          width: 44,
                          height: 3,
                          child: LinearProgressIndicator(
                            value: rate,
                            color: rate >= 0.5 ? colors.win : colors.loss,
                            backgroundColor: colors.track,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: _wStat,
                child: Text(
                  perfValue(
                    context,
                    a.kd,
                    allowed: a.hasRoundSample,
                    decimals: 2,
                  ),
                  textAlign: TextAlign.end,
                  style: num,
                ),
              ),
              SizedBox(
                width: _wStat,
                child: Text(
                  perfValue(context, a.acs, allowed: a.hasRoundSample),
                  textAlign: TextAlign.end,
                  style: num,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowArt extends StatelessWidget {
  const _RowArt({required this.segment, required this.image});

  final PerfSegment segment;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wide = segment == PerfSegment.maps;
    return ClipRRect(
      borderRadius: BorderRadius.circular(wide ? 6 : 18),
      child: Container(
        width: wide ? 56 : 36,
        height: 36,
        color: scheme.surfaceContainerHigh,
        child: image == null
            ? Icon(
                Icons.sports_esports_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              )
            : NetImage(
                image,
                width: wide ? 56 : 36,
                height: 36,
                fit: BoxFit.cover,
                showSkeleton: false,
              ),
      ),
    );
  }
}

/// "Phân tích thêm trận cũ": why the analysis only covers some matches and
/// the button that adds older ones, with progress and the outcome.
class PerfBackfillTile extends ConsumerWidget {
  const PerfBackfillTile({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(ledgerBackfillProvider(puuid));
    final notifier = ref.read(ledgerBackfillProvider(puuid).notifier);
    final muted = theme.colorScheme.onSurfaceVariant;
    final String? status = state.running
        ? state.target == 0
              ? context.l10n.profilePerformanceSearchingOlder
              : context.l10n.profilePerformanceLoadingOlder(
                  state.done,
                  state.target,
                )
        : state.exhausted
        ? context.l10n.profilePerformanceNoOlder
        : state.lastAdded == null
        ? null
        : context.l10n.profilePerformanceAddedOlder(state.lastAdded!);
    return ValCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.profilePerformanceLoadOlderHint(kBackfillBatch),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 12),
          if (state.error != null && !state.running) ...[
            ErrorView(
              error: state.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => notifier.run(),
            ),
            const SizedBox(height: 8),
          ],
          if (state.running) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: state.target == 0 ? null : state.done / state.target,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (status != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                status,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (!state.exhausted)
            FilledButton.tonalIcon(
              onPressed: state.running ? null : () => notifier.run(),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: Text(context.l10n.profilePerformanceLoadOlder),
            ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: ValText.sectionTitle.copyWith(
        fontSize: 17,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
