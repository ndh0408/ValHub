import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/json.dart';
import 'pvp_api.dart';

/// One maintenance or incident from the public status JSON (X-1).
@immutable
class StatusNotice {
  const StatusNotice({
    required this.id,
    required this.isMaintenance,
    required this.title,
    this.message,
    this.severity,
    this.status,
    this.platforms = const [],
    this.createdAt,
  });

  static StatusNotice? fromJson(Object? json, {required bool isMaintenance}) {
    final m = asMap(json);
    if (m == null) return null;
    final title = localized(m['titles']);
    if (title == null) return null;
    final updates = asMapList(m['updates']);
    return StatusNotice(
      id: asString(m['id']) ?? title,
      isMaintenance: isMaintenance,
      title: title,
      message: updates.isEmpty
          ? null
          : localized(updates.first['translations']),
      severity: asString(m['incident_severity']),
      status: asString(m['maintenance_status']),
      platforms: asStringList(m['platforms']),
      createdAt: asDateTime(m['created_at']),
    );
  }

  /// Picks `vi_VN`, then `en_US`, then the first translation.
  static String? localized(Object? translations, {String locale = 'vi_VN'}) {
    final list = asMapList(translations);
    String? find(String l) {
      for (final t in list) {
        if (asString(t['locale']) == l) return asNonEmptyString(t['content']);
      }
      return null;
    }

    return find(locale) ??
        find('en_US') ??
        (list.isEmpty ? null : asNonEmptyString(list.first['content']));
  }

  final String id;
  final bool isMaintenance;

  /// Vietnamese title when available.
  final String title;

  /// Latest update text (vi when available).
  final String? message;

  /// `info` / `warning` / `critical` (incidents).
  final String? severity;

  /// `scheduled` / `in_progress` / `complete` (maintenances).
  final String? status;
  final List<String> platforms;
  final DateTime? createdAt;
}

/// Parsed X-1 status for one region.
@immutable
class PlatformStatus {
  const PlatformStatus({
    this.maintenances = const [],
    this.incidents = const [],
  });

  factory PlatformStatus.fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    return PlatformStatus(
      maintenances: [
        for (final x in asList(m['maintenances']))
          ?StatusNotice.fromJson(x, isMaintenance: true),
      ],
      incidents: [
        for (final x in asList(m['incidents']))
          ?StatusNotice.fromJson(x, isMaintenance: false),
      ],
    );
  }

  final List<StatusNotice> maintenances;
  final List<StatusNotice> incidents;

  /// Maintenances in progress (scheduled ones are not blocking yet).
  List<StatusNotice> get activeMaintenances => maintenances
      .where((m) => m.status != 'scheduled' && m.status != 'complete')
      .toList();

  bool get isEmpty => maintenances.isEmpty && incidents.isEmpty;

  /// Most important notice to show in a banner, if any.
  StatusNotice? get headline =>
      activeMaintenances.firstOrNull ??
      incidents.where((i) => i.severity == 'critical').firstOrNull ??
      maintenances.firstOrNull ??
      incidents.firstOrNull;
}

/// X-1 status for a region (`ap`, `na`, `eu`…), cached for the provider's
/// lifetime (refresh with `ref.invalidate`). Failures (some regions answer
/// 403) yield an empty status rather than an error.
final platformStatusProvider = FutureProvider.autoDispose
    .family<PlatformStatus, String>((ref, region) async {
      try {
        return PlatformStatus.fromJson(
          await ref.watch(pvpApiProvider).platformStatus(region),
        );
      } on Object {
        return const PlatformStatus();
      }
    });
