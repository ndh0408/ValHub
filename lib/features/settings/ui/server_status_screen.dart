import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../data/server_status.dart';
import '../providers/server_status_provider.dart';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/account_labels.dart';

/// "Trạng thái máy chủ" (ValHub extra, X-1): maintenances and incidents that
/// Riot publishes for a region, in Vietnamese when Riot provides it, with
/// every update and its local time (device time zone, 24 h). Regions: those
/// of the signed-in accounts (active one first). Route `/settings/status`.
class ServerStatusScreen extends ConsumerStatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  ConsumerState<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends ConsumerState<ServerStatusScreen> {
  String? _picked;

  /// Regions of the signed-in accounts, the active account's first; `ap`
  /// (Vietnam) when no account is signed in.
  List<String> _regions() {
    final active = ref.watch(activeAccountProvider)?.region.toLowerCase();
    final all = ref.watch(
      accountsProvider.select(
        (list) => [for (final a in list) a.region.toLowerCase()],
      ),
    );
    final out = <String>[?active];
    for (final r in all) {
      if (r.isNotEmpty && !out.contains(r)) out.add(r);
    }
    return out.isEmpty ? const ['ap'] : out;
  }

  Future<void> _refresh(String region) async {
    try {
      ref.invalidate(serverStatusProvider(region));
      await ref.read(serverStatusProvider(region).future);
    } on Object {
      // The error state (with "Thử lại") is rendered from the provider.
    }
  }

  @override
  Widget build(BuildContext context) {
    final regions = _regions();
    final region = regions.contains(_picked) ? _picked! : regions.first;
    final async = ref.watch(serverStatusProvider(region));
    final now = ref.watch(clockProvider).now();
    final report = async.value;
    final regionName = context.l10n.riotRegionName(region);
    return SubPageScaffold(
      title: context.l10n.settingsServerStatus,
      subtitle: report == null || report.region != region
          ? regionName
          : '$regionName · ${formatUpdatedAt(report.fetchedAt, now)}',
      onRefresh: () => _refresh(region),
      header: regions.length < 2
          ? null
          : SegmentedTabs<String>(
              tabs: [
                for (final r in regions)
                  SegmentedTab(value: r, label: context.l10n.riotRegionName(r)),
              ],
              selected: region,
              onChanged: (r) => setState(() => _picked = r),
            ),
      slivers: [
        switch (async) {
          AsyncValue(:final value?) when value.region == region =>
            _ReportSliver(report: value, now: now),
          AsyncError(:final error) => SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              error: error,
              onRetry: () => ref.invalidate(serverStatusProvider(region)),
            ),
          ),
          _ => const SliverToBoxAdapter(child: _StatusSkeleton()),
        },
      ],
    );
  }
}

class _ReportSliver extends StatelessWidget {
  const _ReportSliver({required this.report, required this.now});

  final ServerStatusReport report;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverList.list(
        children: [
          _Summary(report: report),
          for (final n in report.notices) ...[
            const SizedBox(height: 12),
            _NoticeCard(key: ValueKey(n.id), notice: n, now: now),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.settingsStatusSourceNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Accent color of a notice: amber for maintenance and warnings, red for
/// critical incidents, blue for information and scheduled work.
Color _noticeColor(BuildContext context, ServerNotice n) {
  final colors = valColorsOf(context);
  if (n.isMaintenance) {
    return n.phase == MaintenancePhase.scheduled ||
            n.phase == MaintenancePhase.complete
        ? TierColors.select
        : colors.warning;
  }
  return switch (n.severity) {
    ServerSeverity.critical => Theme.of(context).colorScheme.error,
    ServerSeverity.warning => colors.warning,
    _ => TierColors.select,
  };
}

/// Headline card: all good (green), maintenance under way (amber), open
/// incidents (red / amber) or only scheduled maintenance (blue).
class _Summary extends StatelessWidget {
  const _Summary({required this.report});

  final ServerStatusReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final notices = report.notices;
    final regionName = context.l10n.riotRegionName(report.region);
    final (
      IconData icon,
      Color color,
      String title,
      String body,
    ) = switch (notices) {
      [] => (
        Icons.check_circle_outline,
        colors.win,
        context.l10n.settingsStatusAllGood,
        context.l10n.settingsStatusAllGoodBody(regionName),
      ),
      _ when notices.any((n) => n.isActiveMaintenance) => (
        Icons.construction_outlined,
        colors.warning,
        context.l10n.settingsStatusMaintenanceNow,
        context.l10n.settingsStatusMaintenanceNowBody,
      ),
      _
          when notices.every(
            (n) => n.isMaintenance && n.phase == MaintenancePhase.scheduled,
          ) =>
        (
          Icons.event_outlined,
          TierColors.select,
          context.l10n.settingsStatusScheduled,
          context.l10n.settingsStatusScheduledBody(notices.length),
        ),
      _ => (
        Icons.warning_amber_rounded,
        notices.any((n) => n.severity == ServerSeverity.critical)
            ? theme.colorScheme.error
            : colors.warning,
        context.l10n.settingsStatusIssues,
        context.l10n.settingsStatusIssuesBody(notices.length),
      ),
    };
    return ValCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.35),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.02)],
      ),
      child: Row(
        children: [
          StateIcon(icon: icon, color: color, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ValText.sectionTitle.copyWith(
                    fontSize: 17,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatefulWidget {
  const _NoticeCard({super.key, required this.notice, required this.now});

  final ServerNotice notice;
  final DateTime now;

  @override
  State<_NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<_NoticeCard> {
  static const _collapsedUpdates = 2;
  bool _expanded = false;

  String? _chipLabel(ServerNotice n) {
    if (n.isMaintenance) {
      return switch (n.phase) {
        MaintenancePhase.scheduled => context.l10n.settingsPhaseScheduled,
        MaintenancePhase.inProgress => context.l10n.settingsPhaseInProgress,
        MaintenancePhase.complete => context.l10n.settingsPhaseComplete,
        null => null,
      };
    }
    return switch (n.severity) {
      ServerSeverity.info => context.l10n.settingsSeverityInfo,
      ServerSeverity.warning => context.l10n.settingsSeverityWarning,
      ServerSeverity.critical => context.l10n.settingsSeverityCritical,
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notice;
    final now = widget.now;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = _noticeColor(context, n);
    final chip = _chipLabel(n);
    final platforms = {
      for (final p in n.platforms) context.l10n.statusPlatformName(p),
    }.join(' · ');
    final times = [
      if (n.createdAt case final at?)
        context.l10n.settingsStatusStarted(formatStatusTime(at, now)),
      if (n.lastChange case final at? when at != n.createdAt)
        context.l10n.settingsStatusUpdated(formatStatusTime(at, now)),
    ];
    final updates = _expanded
        ? n.updates
        : n.updates.take(_collapsedUpdates).toList();
    final hidden = n.updates.length - updates.length;
    return ValCard(
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusPill(
                    label: n.isMaintenance
                        ? context.l10n.settingsStatusKindMaintenance
                        : context.l10n.settingsStatusKindIncident,
                    color: color,
                    icon: n.isMaintenance
                        ? Icons.construction_outlined
                        : Icons.warning_amber_rounded,
                  ),
                  if (chip != null)
                    StatusPill(label: chip, color: color, showDot: false),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                n.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (platforms.isNotEmpty) ...[
                const SizedBox(height: 6),
                _MetaLine(icon: Icons.devices_outlined, text: platforms),
              ],
              for (final t in times) ...[
                const SizedBox(height: 4),
                _MetaLine(icon: Icons.schedule, text: t),
              ],
              if (updates.isNotEmpty) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: valColorsOf(context).hairline),
                const SizedBox(height: 10),
                Text(
                  context.l10n.settingsStatusUpdatesHeader,
                  style: ValText.label.copyWith(color: muted),
                ),
                for (final u in updates)
                  _UpdateRow(update: u, now: now, color: color),
                if (n.updates.length > _collapsedUpdates)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded
                            ? context.l10n.settingsStatusFewerUpdates
                            : context.l10n.settingsStatusMoreUpdates(hidden),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: muted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}

/// One published update: a colored timeline dot, its local time and text.
class _UpdateRow extends StatelessWidget {
  const _UpdateRow({
    required this.update,
    required this.now,
    required this.color,
  });

  final ServerNoticeUpdate update;
  final DateTime now;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = update.at;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (at != null)
                  Text(
                    formatStatusTime(at, now),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  update.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the final layout: summary card, then two notice cards.
class _StatusSkeleton extends StatelessWidget {
  const _StatusSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget card(double height) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Skeleton(height: height, radius: ValRadius.card, shimmer: false),
    );
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          children: [
            const Skeleton(height: 88, radius: ValRadius.card, shimmer: false),
            card(150),
            card(150),
          ],
        ),
      ),
    );
  }
}
