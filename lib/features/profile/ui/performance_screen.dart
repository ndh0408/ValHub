import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../data/performance_view.dart';
import '../profile_strings.dart';
import 'widgets/profile_widgets.dart';

/// Own-account analytics read the compact ledger; opening this page never
/// requests match details or reconstructs unrecorded history.
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  PerfPeriod _period = PerfPeriod.all;
  PerfSegment _segment = PerfSegment.agents;
  String? _queue;
  String? _account;

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(activePuuidProvider);
    if (_account != id) {
      _account = id;
      _queue = null;
    }
    final ledger = id == null ? null : ref.watch(matchLedgerProvider(id)).value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final view = ledger == null
        ? null
        : buildPerformanceView(
            ledger,
            now: ref.watch(clockProvider).now(),
            toLocal: (d) => d.toLocal(),
            period: _period,
            queueId: _queue,
          );
    return SubPageScaffold(
      title: ProfileStrings.performanceTitle,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (id == null)
              const Text(CommonStrings.errorNoAccount)
            else if (view == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                view.oldest == null
                    ? ProfileStrings.performanceEmpty
                    : ProfileStrings.performanceSince(
                        formatDate(view.oldest!.toLocal()),
                      ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final period in PerfPeriod.values)
                    ChoiceChip(
                      label: Text(ProfileStrings.performancePeriod(period)),
                      selected: _period == period,
                      onSelected: (_) => setState(() => _period = period),
                    ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text(ProfileStrings.filterAll),
                    selected: _queue == null,
                    onSelected: (_) => setState(() => _queue = null),
                  ),
                  for (final queue in view.queues)
                    ChoiceChip(
                      label: Text(db.queueName(queue)),
                      selected: _queue == queue,
                      onSelected: (_) => setState(() => _queue = queue),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _Summary(stats: view.overall),
              const SizedBox(height: 12),
              Text(ProfileStrings.performanceSample),
              Wrap(
                spacing: 8,
                children: [
                  for (final segment in PerfSegment.values)
                    ChoiceChip(
                      label: Text(ProfileStrings.performanceSegment(segment)),
                      selected: _segment == segment,
                      onSelected: (_) => setState(() => _segment = segment),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (view.filteredOut)
                const Text(ProfileStrings.performanceNoMatches)
              else if (_segment == PerfSegment.sides) ...[
                Text(
                  ProfileStrings.performanceSideCoverage(
                    view.roundsWithSide,
                    view.roundsTotal,
                  ),
                ),
                _Side(
                  title: ProfileStrings.performanceAttack,
                  stats: view.overall.attack,
                  qualifies: view.overall.roundGames >= kPerfMinGames,
                ),
                _Side(
                  title: ProfileStrings.performanceDefense,
                  stats: view.overall.defense,
                  qualifies: view.overall.roundGames >= kPerfMinGames,
                ),
              ] else if (_segment == PerfSegment.trend) ...[
                if (!view.hasTrend)
                  const Text(ProfileStrings.performanceTrendEmpty),
                for (final point in view.trend) ...[
                  Text(formatDate(point.start)),
                  _Summary(stats: point.aggregate),
                  const SizedBox(height: 12),
                ],
              ] else ...[
                for (final group in switch (_segment) {
                  PerfSegment.agents => view.byAgent,
                  PerfSegment.maps => view.byMap,
                  _ => view.byQueue,
                }) ...[
                  Text(switch (_segment) {
                    PerfSegment.agents =>
                      db.agent(group.key)?.displayName ??
                          CommonStrings.unknownItem,
                    PerfSegment.maps =>
                      db.mapByUrl(group.key)?.displayName ??
                          CommonStrings.unknownItem,
                    _ => db.queueName(group.key),
                  }, style: Theme.of(context).textTheme.titleMedium),
                  _Summary(stats: group.aggregate),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.stats});
  final PerfAggregate stats;

  @override
  Widget build(BuildContext context) {
    final rates = stats.qualifies();
    final roundRates = stats.roundGames >= kPerfMinGames;
    String number(double? value, bool allowed) =>
        allowed && value != null ? formatNumber(value) : CommonStrings.dash;
    return ValCard(
      child: StatGrid(
        tiles: [
          StatTile(
            label: ProfileStrings.performanceGames,
            value: formatNumber(stats.games),
          ),
          StatTile(
            label: ProfileStrings.winRate,
            value: rates && stats.winRate != null
                ? formatPercent(stats.winRate!)
                : CommonStrings.dash,
          ),
          StatTile(
            label: ProfileStrings.kd,
            value: number(stats.kd, roundRates),
          ),
          StatTile(
            label: ProfileStrings.acs,
            value: number(stats.acs, roundRates),
          ),
          StatTile(
            label: ProfileStrings.adr,
            value: number(stats.adr, roundRates),
          ),
          StatTile(
            label: ProfileStrings.hs,
            value: roundRates && stats.headshotRate != null
                ? formatPercent(stats.headshotRate!)
                : CommonStrings.dash,
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.title,
    required this.stats,
    required this.qualifies,
  });
  final String title;
  final SideTotals stats;
  final bool qualifies;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    subtitle: Text(ProfileStrings.performanceRounds(stats.rounds)),
    trailing: Text(
      qualifies && stats.winRate != null
          ? formatPercent(stats.winRate!)
          : CommonStrings.dash,
    ),
  );
}
