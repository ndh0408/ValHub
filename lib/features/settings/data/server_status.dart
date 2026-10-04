import 'package:flutter/foundation.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../core/riot/platform_status.dart';
import '../../../core/util/format.dart';
import '../../../core/util/json.dart';

/// Kind of a status notice.
enum ServerNoticeKind { maintenance, incident }

/// Severity of an incident (`incident_severity`).
enum ServerSeverity {
  info,
  warning,
  critical;

  static ServerSeverity? parse(Object? v) => switch (asString(v)) {
    'info' => info,
    'warning' => warning,
    'critical' => critical,
    _ => null,
  };
}

/// Phase of a maintenance (`maintenance_status`).
enum MaintenancePhase {
  scheduled,
  inProgress,
  complete;

  static MaintenancePhase? parse(Object? v) => switch (asString(v)) {
    'scheduled' => scheduled,
    'in_progress' => inProgress,
    'complete' => complete,
    _ => null,
  };
}

/// One published update of a notice (newest first in [ServerNotice]).
@immutable
class ServerNoticeUpdate {
  const ServerNoticeUpdate({required this.text, this.at});

  /// Vietnamese text when Riot provides it (`vi_VN`), else English.
  final String text;
  final DateTime? at;
}

/// A maintenance or incident of the public VALORANT status page (X-1),
/// with every update and its time. Parsed defensively: unknown fields are
/// ignored, a notice without any title is skipped.
@immutable
class ServerNotice {
  const ServerNotice({
    required this.id,
    required this.kind,
    required this.title,
    this.severity,
    this.phase,
    this.platforms = const [],
    this.createdAt,
    this.updatedAt,
    this.updates = const [],
  });

  static ServerNotice? fromJson(Object? json, ServerNoticeKind kind) {
    final m = asMap(json);
    if (m == null) return null;
    final title = StatusNotice.localized(m['titles']);
    if (title == null) return null;
    final updates = <ServerNoticeUpdate>[
      for (final u in asMapList(m['updates']))
        if (asBool(u['publish']) ?? true)
          if (StatusNotice.localized(u['translations']) case final text?)
            ServerNoticeUpdate(
              text: text,
              at: asDateTime(u['updated_at']) ?? asDateTime(u['created_at']),
            ),
    ]..sort((a, b) => _newestFirst(a.at, b.at));
    return ServerNotice(
      id: asString(m['id']) ?? title,
      kind: kind,
      title: title,
      severity: ServerSeverity.parse(m['incident_severity']),
      phase: MaintenancePhase.parse(m['maintenance_status']),
      platforms: asStringList(m['platforms']),
      createdAt: asDateTime(m['created_at']),
      updatedAt: asDateTime(m['updated_at']),
      updates: List.unmodifiable(updates),
    );
  }

  final String id;
  final ServerNoticeKind kind;

  /// Vietnamese title when available ("Máy Chủ Trò Chơi không khả dụng").
  final String title;
  final ServerSeverity? severity;
  final MaintenancePhase? phase;

  /// `windows`, `ps5`, `xbox`, `macos`, `android`, `ios`…
  final List<String> platforms;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Published updates, newest first.
  final List<ServerNoticeUpdate> updates;

  bool get isMaintenance => kind == ServerNoticeKind.maintenance;

  /// Maintenance under way now (scheduled or finished ones are not).
  bool get isActiveMaintenance =>
      isMaintenance &&
      phase != MaintenancePhase.scheduled &&
      phase != MaintenancePhase.complete;

  /// The latest moment Riot touched this notice.
  DateTime? get lastChange => [
    updatedAt,
    updates.firstOrNull?.at,
    createdAt,
  ].nonNulls.fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

  /// Sorting weight: active maintenance, critical, warning, the rest.
  int get priority {
    if (isActiveMaintenance) return 0;
    return switch (severity) {
      ServerSeverity.critical => 1,
      ServerSeverity.warning => 2,
      _ when isMaintenance && phase == MaintenancePhase.scheduled => 3,
      _ => 4,
    };
  }
}

int _newestFirst(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

/// The full X-1 status of one region, as shown by "Trạng thái máy chủ".
@immutable
class ServerStatusReport {
  const ServerStatusReport({
    required this.region,
    required this.notices,
    required this.fetchedAt,
  });

  factory ServerStatusReport.fromJson(
    Object? json, {
    required String region,
    required DateTime fetchedAt,
  }) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final notices =
        <ServerNotice>[
          for (final x in asList(m['maintenances']))
            ?ServerNotice.fromJson(x, ServerNoticeKind.maintenance),
          for (final x in asList(m['incidents']))
            ?ServerNotice.fromJson(x, ServerNoticeKind.incident),
        ]..sort((a, b) {
          final p = a.priority.compareTo(b.priority);
          return p != 0 ? p : _newestFirst(a.lastChange, b.lastChange);
        });
    return ServerStatusReport(
      region: region,
      notices: List.unmodifiable(notices),
      fetchedAt: fetchedAt,
    );
  }

  /// Lowercase region id (`ap`).
  final String region;

  /// Most important first (active maintenance, critical, warning, …).
  final List<ServerNotice> notices;
  final DateTime fetchedAt;

  bool get isEmpty => notices.isEmpty;
}

/// Local wall time of a status event (device time zone, 24 h):
/// `08:20 hôm nay`, `23:00 ngày mai`, `21:05 hôm qua`, `08:20 thứ Hai 02/03`
/// within a week, else `02/03/2026 08:20`.
String formatStatusTime(
  DateTime at,
  DateTime now, {
  required AppLocalizations messages,
}) {
  final l = at.toLocal();
  final n = now.toLocal();
  final dayDiff = DateTime(
    l.year,
    l.month,
    l.day,
  ).difference(DateTime(n.year, n.month, n.day)).inDays;
  if (dayDiff == -1) {
    return messages.commonWallTime(formatTime(l), messages.commonYesterday);
  }
  if (dayDiff.abs() < 7) return formatWallTime(l, n, messages: messages);
  return formatDateTime(l);
}
