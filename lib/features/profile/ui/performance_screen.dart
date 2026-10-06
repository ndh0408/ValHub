import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/filter_bar.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../data/performance_view.dart';
import '../profile_routes.dart';
import 'widgets/performance_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// "Hiệu suất": own-account analytics over the on-device ledger.
///
/// Reading the page never requests anything; only "Phân tích thêm trận cũ"
/// opens older matches (see `ledgerBackfillProvider`). Tapping an agent, map
/// or queue narrows every card to it (agent → its maps, map → its agents
/// and sides), and a bar of the per-match chart opens that match.
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  final _scroll = ScrollController();
  PerfPeriod _period = PerfPeriod.all;
  PerfSegment _segment = PerfSegment.agents;
  PerfMatchMetric _metric = PerfMatchMetric.acs;
  String? _queue;
  String? _agent;
  String? _map;
  String? _account;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _pick(PerfSegment segment, String key) {
    setState(() {
      switch (segment) {
        case PerfSegment.agents:
          _agent = key;
          _segment = PerfSegment.maps;
        case PerfSegment.maps:
          _map = key;
          _segment = _agent == null ? PerfSegment.agents : PerfSegment.queues;
        case PerfSegment.queues:
          _queue = key;
      }
    });
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          0,
          duration: ValMotion.medium,
          curve: ValMotion.curve,
        ),
      );
    }
  }

  void _clearFilters() => setState(() {
    _queue = null;
    _agent = null;
    _map = null;
  });

  /// The tables that still compare something (one already filtered to a
  /// single value is left out).
  List<PerfSegment> get _segments => [
    if (_agent == null) PerfSegment.agents,
    if (_map == null) PerfSegment.maps,
    if (_queue == null) PerfSegment.queues,
  ];

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(activePuuidProvider);
    if (_account != id) {
      // Another account: its own filters (ids differ per ledger).
      _account = id;
      _queue = null;
      _agent = null;
      _map = null;
    }
    final ledger = id == null ? null : ref.watch(matchLedgerProvider(id)).value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final view = ledger == null
        ? null
        : buildPerformanceView(
            ledger,
            now: ref.watch(clockProvider).now(),
            period: _period,
            queueId: _queue,
            agentId: _agent,
            mapId: _map,
          );
    final segments = _segments;
    final segment = segments.contains(_segment)
        ? _segment
        : segments.isEmpty
        ? PerfSegment.queues
        : segments.first;
    return SubPageScaffold(
      title: context.l10n.profilePerformanceTitle,
      subtitle: view?.oldest == null
          ? null
          : context.l10n.profilePerformanceSince(
              formatDate(view!.oldest!.toLocal()),
            ),
      controller: _scroll,
      slivers: [
        if (id == null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(message: context.l10n.commonErrorNoAccount),
          )
        else if (view == null)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (view.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmptyView(
                    icon: Icons.insights_outlined,
                    message: context.l10n.profilePerformanceEmpty,
                  ),
                  PerfBackfillTile(puuid: id),
                ],
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: _Filters(
              view: view,
              db: db,
              period: _period,
              queue: _queue,
              agent: _agent,
              map: _map,
              onPeriod: (p) => setState(() => _period = p),
              onQueue: (q) => setState(() => _queue = q),
              onClearAgent: () => setState(() => _agent = null),
              onClearMap: () => setState(() => _map = null),
              onClear: _queue != null || _agent != null || _map != null
                  ? _clearFilters
                  : null,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverList.list(
              children: view.filteredOut
                  ? [
                      EmptyView(
                        icon: Icons.filter_alt_off_outlined,
                        message: context.l10n.profilePerformanceNoMatches,
                        action: FilledButton.tonal(
                          onPressed: () => setState(() {
                            _clearFilters();
                            _period = PerfPeriod.all;
                          }),
                          child: Text(context.l10n.commonClearFilters),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PerfBackfillTile(puuid: id),
                    ]
                  : [
                      PerfOverviewCard(stats: view.overall),
                      const SizedBox(height: 12),
                      PerfMatchChartCard(
                        view: view,
                        metric: _metric,
                        onMetric: (m) => setState(() => _metric = m),
                        onOpenMatch: (matchId) => unawaited(
                          context.push(ProfileRoutes.match(matchId)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PerfOpeningsCard(stats: view.overall),
                      if (view.overall.hasSides) ...[
                        const SizedBox(height: 12),
                        PerfSidesCard(view: view),
                      ],
                      if (segments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        PerfBreakdownCard(
                          view: view,
                          db: db,
                          segment: segment,
                          segments: segments,
                          onSegment: (s) => setState(() => _segment = s),
                          onPick: _pick,
                        ),
                      ],
                      const SizedBox(height: 12),
                      PerfBackfillTile(puuid: id),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.profilePerformanceSample,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Period pills, then the queue picker and the agent / map the screen is
/// narrowed to (each removable), with "Bỏ lọc".
class _Filters extends StatelessWidget {
  const _Filters({
    required this.view,
    required this.db,
    required this.period,
    required this.queue,
    required this.agent,
    required this.map,
    required this.onPeriod,
    required this.onQueue,
    required this.onClearAgent,
    required this.onClearMap,
    required this.onClear,
  });

  final PerformanceView view;
  final ContentDb db;
  final PerfPeriod period;
  final String? queue;
  final String? agent;
  final String? map;
  final ValueChanged<PerfPeriod> onPeriod;
  final ValueChanged<String?> onQueue;
  final VoidCallback onClearAgent;
  final VoidCallback onClearMap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final agentContent = agent == null ? null : db.agent(agent!);
    final mapContent = map == null ? null : db.mapByUrl(map);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedTabs<PerfPeriod>(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          tabs: [
            for (final p in PerfPeriod.values)
              SegmentedTab(
                value: p,
                label: context.l10n.profilePerformancePeriodLabel(p.name),
              ),
          ],
          selected: period,
          onChanged: onPeriod,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FilterChipBar(
            onClear: onClear,
            children: [
              ActionChip(
                avatar: Icon(
                  Icons.sports_esports_outlined,
                  size: 18,
                  color: queue == null ? null : accent,
                ),
                shape: const StadiumBorder(),
                visualDensity: VisualDensity.compact,
                backgroundColor: queue == null
                    ? theme.colorScheme.surfaceContainer
                    : accent.withValues(alpha: 0.14),
                side: BorderSide(
                  color: queue == null
                      ? valColorsOf(context).hairline
                      : accent.withValues(alpha: 0.7),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.profilePerformanceQueueChip(
                          queue == null
                              ? context.l10n.profileFilterAll
                              : db.queueName(context.l10n, queue!),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
                onPressed: () => unawaited(_pickQueue(context)),
              ),
              if (agent != null)
                InputChip(
                  avatar: ClipOval(
                    child: NetImage(
                      agentContent?.displayIconSmall ??
                          agentContent?.displayIcon,
                      width: 24,
                      height: 24,
                      showSkeleton: false,
                    ),
                  ),
                  label: Text(
                    agentContent?.displayName ?? context.l10n.commonUnknownItem,
                  ),
                  shape: const StadiumBorder(),
                  visualDensity: VisualDensity.compact,
                  selected: true,
                  showCheckmark: false,
                  onDeleted: onClearAgent,
                ),
              if (map != null)
                InputChip(
                  avatar: const Icon(Icons.map_outlined, size: 18),
                  label: Text(
                    mapContent?.displayName ?? context.l10n.commonUnknownItem,
                  ),
                  shape: const StadiumBorder(),
                  visualDensity: VisualDensity.compact,
                  selected: true,
                  showCheckmark: false,
                  onDeleted: onClearMap,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickQueue(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showValSheet<({String? queue})>(
      context,
      title: l10n.profilePerformanceChooseQueue,
      builder: (context, _) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          GroupedSection(
            children: [
              for (final q in [null, ...view.queues])
                GroupedRow(
                  title: q == null
                      ? context.l10n.profileFilterAll
                      : db.queueName(context.l10n, q),
                  trailing: q == queue
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop((queue: q)),
                ),
            ],
          ),
        ],
      ),
    );
    if (picked != null) onQueue(picked.queue);
  }
}
