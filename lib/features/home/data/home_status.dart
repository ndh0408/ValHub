/// "Trạng thái máy chủ" card model (docs/design/HOME.md §5.8). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/riot/platform_status.dart';

/// One notice of one region.
@immutable
class HomeStatusNotice {
  const HomeStatusNotice({
    required this.region,
    required this.notice,
    required this.isActiveRegion,
  });

  /// Lowercase region id (`ap`).
  final String region;
  final StatusNotice notice;
  final bool isActiveRegion;

  /// Maintenance under way now (a scheduled or finished one is not).
  bool get isInProgress =>
      notice.isMaintenance &&
      notice.status != 'scheduled' &&
      notice.status != 'complete';

  bool get isCritical => !notice.isMaintenance && notice.severity == 'critical';

  /// Sorting weight inside a region: maintenance in progress, critical
  /// incidents, scheduled maintenance, other incidents.
  int get weight {
    if (isInProgress) return 0;
    if (isCritical) return 1;
    if (notice.isMaintenance) return 2;
    return 3;
  }
}

/// The notices of every region the user has an account in.
@immutable
class HomeServerStatus {
  const HomeServerStatus({required this.notices, required this.blocking});

  /// Active region first, then the other regions; most important first
  /// inside a region.
  final List<HomeStatusNotice> notices;

  /// The active region has maintenance in progress or a critical incident:
  /// the card is pinned above everything else.
  final bool blocking;

  /// The most important notice (the card's headline).
  HomeStatusNotice get headline => notices.first;
}

/// Combines the X-1 status of each region. [byRegion] may hold `null` for a
/// region whose status is still unknown. Maintenances that are `complete`
/// are dropped, notices are deduplicated by id per region. `null` when there
/// is nothing to show.
HomeServerStatus? buildHomeServerStatus(
  Map<String, PlatformStatus?> byRegion, {
  required String? activeRegion,
}) {
  final active = activeRegion?.toLowerCase();
  final regions = [
    if (active != null && byRegion.keys.any((r) => r.toLowerCase() == active))
      active,
    for (final r in byRegion.keys)
      if (r.toLowerCase() != active) r.toLowerCase(),
  ];
  final byLower = {
    for (final e in byRegion.entries) e.key.toLowerCase(): e.value,
  };

  final notices = <HomeStatusNotice>[];
  for (final region in regions) {
    final status = byLower[region];
    if (status == null) continue;
    final seen = <String>{};
    final inRegion = <HomeStatusNotice>[
      for (final m in status.maintenances)
        if (m.status != 'complete' && seen.add(m.id))
          HomeStatusNotice(
            region: region,
            notice: m,
            isActiveRegion: region == active,
          ),
      for (final i in status.incidents)
        if (seen.add(i.id))
          HomeStatusNotice(
            region: region,
            notice: i,
            isActiveRegion: region == active,
          ),
    ];
    // Stable sort by weight.
    final indexed = [for (var i = 0; i < inRegion.length; i++) (i, inRegion[i])]
      ..sort((a, b) {
        final c = a.$2.weight.compareTo(b.$2.weight);
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });
    notices.addAll(indexed.map((e) => e.$2));
  }
  if (notices.isEmpty) return null;
  final blocking = notices.any(
    (n) => n.isActiveRegion && (n.isInProgress || n.isCritical),
  );
  return HomeServerStatus(
    notices: List.unmodifiable(notices),
    blocking: blocking,
  );
}
