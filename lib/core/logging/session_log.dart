import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_constants.dart';
import '../util/clock.dart';
import '../util/format.dart';
import '../util/json.dart';

/// One session-log line (A10). Never contains tokens, cookies, PUUIDs or
/// Riot IDs: [target] is `host + path template`, [detail] is scrubbed.
@immutable
class SessionLogEntry {
  const SessionLogEntry({
    required this.time,
    required this.event,
    this.target,
    this.status,
    this.ms,
    this.detail,
  });

  final DateTime time;

  /// Short event name, e.g. `http`, `reauth.ok`, `reauth.needsLogin`.
  final String event;

  /// `host/path/{id}` template (see [SessionLog.scrubUri]).
  final String? target;
  final int? status;
  final int? ms;
  final String? detail;

  JsonMap toJson() => {
    't': time.millisecondsSinceEpoch,
    'e': event,
    if (target != null) 'u': target,
    if (status != null) 's': status,
    if (ms != null) 'ms': ms,
    if (detail != null) 'd': detail,
  };

  static SessionLogEntry? fromJson(Object? json) {
    final m = asMap(json);
    final t = asInt(m?['t']);
    final e = asString(m?['e']);
    if (m == null || t == null || e == null) return null;
    return SessionLogEntry(
      time: DateTime.fromMillisecondsSinceEpoch(t),
      event: e,
      target: asString(m['u']),
      status: asInt(m['s']),
      ms: asInt(m['ms']),
      detail: asString(m['d']),
    );
  }

  /// `2026-09-28 14:05:09  http  200  312ms  pd.ap.a.pvp.net/store/v3/storefront/{id}`
  String toLine() {
    final l = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final ts =
        '${l.year}-${two(l.month)}-${two(l.day)} '
        '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
    return [
      ts,
      event,
      if (status != null) '$status',
      if (ms != null) '${ms}ms',
      ?target,
      ?detail,
    ].join('  ');
  }
}

/// In-memory + on-disk ring buffer of session events (A10, SUMMARY §8.1).
///
/// Everything passed in is scrubbed: UUIDs, JWTs, cookie values, long
/// secrets and query values outside a small allowlist never reach the log.
class SessionLog extends ChangeNotifier {
  SessionLog({
    this._file,
    this.capacity = AppConstants.sessionLogCapacity,
    this._clock = const Clock(),
  });

  /// A log persisted to `<appSupport>/logs/session_log.jsonl`.
  factory SessionLog.persistent({Clock clock = const Clock()}) => SessionLog(
    clock: clock,
    file: () async {
      try {
        final base = await getApplicationSupportDirectory();
        return File('${base.path}/logs/session_log.jsonl');
      } on Object {
        return null;
      }
    },
  );

  final Future<File?> Function()? _file;
  final Clock _clock;
  final int capacity;
  final List<SessionLogEntry> _entries = [];
  Timer? _flushTimer;
  bool _loaded = false;

  List<SessionLogEntry> get entries => List.unmodifiable(_entries);

  /// Loads persisted entries (call once at startup).
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final file = await _file?.call();
    if (file == null || !file.existsSync()) return;
    try {
      final lines = await file.readAsLines();
      final loaded = [
        for (final line in lines)
          ?SessionLogEntry.fromJson(tryDecodeJson(line)),
      ];
      _entries.insertAll(0, loaded);
      _trim();
      notifyListeners();
    } on Object {
      // A corrupt log is not worth crashing for.
    }
  }

  /// Records an event. [uri] is reduced to a path template; [detail] is
  /// scrubbed.
  void add(
    String event, {
    Uri? uri,
    int? status,
    Duration? elapsed,
    String? detail,
  }) {
    _entries.add(
      SessionLogEntry(
        time: _clock.now(),
        event: event,
        target: uri == null ? null : scrubUri(uri),
        status: status,
        ms: elapsed?.inMilliseconds,
        detail: detail == null ? null : scrubText(detail),
      ),
    );
    _trim();
    notifyListeners();
    _scheduleFlush();
  }

  /// Shorthand for an HTTP request line.
  void http(String method, Uri uri, {int? status, Duration? elapsed}) => add(
    'http.${method.toLowerCase()}',
    uri: uri,
    status: status,
    elapsed: elapsed,
  );

  void _trim() {
    final excess = _entries.length - capacity;
    if (excess > 0) _entries.removeRange(0, excess);
  }

  void _scheduleFlush() {
    if (_file == null) return;
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(seconds: 2), () => unawaited(flush()));
  }

  /// Writes the buffer to disk now.
  Future<void> flush() async {
    _flushTimer?.cancel();
    final file = await _file?.call();
    if (file == null) return;
    try {
      await file.parent.create(recursive: true);
      final text = _entries.map((e) => jsonEncode(e.toJson())).join('\n');
      await file.writeAsString(text, flush: true);
    } on Object {
      // Logging must never break the app.
    }
  }

  Future<void> clear() async {
    _entries.clear();
    notifyListeners();
    await flush();
  }

  /// Plain-text export ("Xuất nhật ký phiên").
  String exportText({String? header}) {
    final buffer = StringBuffer();
    if (header != null) buffer.writeln(header);
    for (final e in _entries) {
      buffer.writeln(e.toLine());
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------- scrubbing

  static final RegExp _uuid = RegExp(
    r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
  );
  static final RegExp _jwt = RegExp(
    r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.?[A-Za-z0-9_-]*',
  );
  static final RegExp _secretKv = RegExp(
    r'(ssid|clid|csid|tdid|asid|ccid|sub|access_token|id_token|entitlements_token|token|cookie|authorization)(\s*[=:]\s*)[^;&\s,]+',
    caseSensitive: false,
  );
  static final RegExp _longSecret = RegExp(r'[A-Za-z0-9+/_=-]{32,}');
  static final RegExp _riotId = RegExp(r'[^\s#/]{2,}#[A-Za-z0-9]{2,6}');
  static const _queryAllowlist = {
    'startIndex',
    'endIndex',
    'queue',
    'language',
    'isPlayableCharacter',
    'size',
    'app',
  };

  /// `https://pd.ap.a.pvp.net/store/v3/storefront/<puuid>` →
  /// `pd.ap.a.pvp.net/store/v3/storefront/{id}`.
  static String scrubUri(Uri uri) {
    final segments = uri.pathSegments;
    final out = <String>[];
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final prev = i > 0 ? segments[i - 1] : '';
      if (prev == 'name' || prev == 'tag' || prev == 'joinbycode') {
        out.add('{${prev == 'joinbycode' ? 'code' : prev}}');
      } else if (_uuid.hasMatch(seg) ||
          RegExp(r'^[0-9a-fA-F]{16,}$').hasMatch(seg)) {
        out.add('{id}');
      } else if (seg.length > 40 || seg.contains('@') || seg.contains('#')) {
        out.add('{x}');
      } else {
        out.add(seg);
      }
    }
    final query = [
      for (final entry in uri.queryParameters.entries)
        if (_queryAllowlist.contains(entry.key))
          '${entry.key}=${entry.value.length <= 24 ? entry.value : '{x}'}',
    ];
    final path = out.isEmpty ? '' : '/${out.join('/')}';
    return '${uri.host}$path${query.isEmpty ? '' : '?${query.join('&')}'}';
  }

  /// Removes anything secret-looking from free text.
  static String scrubText(String input) {
    var s = input.replaceAll(_jwt, '{jwt}');
    s = s.replaceAllMapped(_secretKv, (m) => '${m[1]}${m[2]}{redacted}');
    s = s.replaceAll(_uuid, '{id}');
    s = s.replaceAll(_riotId, '{riotId}');
    s = s.replaceAll(_longSecret, '{secret}');
    final clean = cleanDisplayText(s) ?? '';
    return clean.length > 200 ? '${clean.substring(0, 200)}…' : clean;
  }
}

/// App-wide session log. `main()` calls `load()` once at startup. Widgets
/// listen with `ListenableBuilder(listenable: ref.watch(sessionLogProvider))`.
final sessionLogProvider = Provider<SessionLog>((ref) {
  final log = SessionLog.persistent();
  ref.onDispose(log.dispose);
  return log;
});
