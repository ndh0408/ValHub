import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/json_file_cache.dart';
import '../../accounts/account_providers.dart';
import '../../util/json.dart';
import 'match_models.dart' show MatchModeKind, MatchOutcome;
import 'performance.dart';

/// Every match of one own account that this device has seen, as compact
/// [MatchStatLine]s (PR-01). Newest first, unique by match id.
@immutable
class MatchLedger {
  MatchLedger({required this.puuid, Iterable<MatchStatLine> lines = const []})
    : lines = List.unmodifiable(sortedNewestFirst(lines)),
      _byId = {for (final l in lines) l.matchId: l};

  final String puuid;
  final List<MatchStatLine> lines;
  final Map<String, MatchStatLine> _byId;

  bool get isEmpty => lines.isEmpty;
  int get length => lines.length;

  /// The line of a match, or `null` when this device never saw it.
  MatchStatLine? byMatch(String? matchId) =>
      matchId == null ? null : _byId[matchId.trim().toLowerCase()];

  /// Start of the oldest / newest stored match ("trên thiết bị, từ dd/MM").
  DateTime? get oldest => lines.isEmpty ? null : lines.last.startedAt;
  DateTime? get newest => lines.isEmpty ? null : lines.first.startedAt;
}

/// Persists [MatchLedger]s per PUUID.
///
/// Stored under `keep/<puuid>/match_stats` in the `history` namespace, next
/// to the RR history: neither "Xóa bộ nhớ đệm" nor sign-out erases it by
/// itself (sign-out decides through [delete]). Only own accounts are ever
/// recorded (the caller checks); rows are de-duplicated by match id and
/// capped at [maxRows] (newest kept). Writes for one PUUID are serialised
/// and coalesced, and storage failures degrade to in-memory data.
///
/// File format (schema [schema]): `{"v":1,"queues":[…],"maps":[…],
/// "agents":[…],"rows":[[matchId, startSec, queue, map, agent, mode, outcome,
/// k, d, a, score, rounds, damage, hs, bs, ls, fb, fd, attack ×6,
/// defense ×6, m2, m3, m4, m5], …]}` with `-1` for "unknown"; queue, map and
/// agent are indexes into the dictionaries. About 130 bytes per match.
class MatchStatsStore {
  MatchStatsStore(this._files, {this.maxRows = 5000, this.canRecord});

  final Future<bool> Function(String id)? canRecord;

  final JsonFileCache _files;
  final int maxRows;

  final Map<String, MatchLedger> _memory = {};
  final Map<String, Future<void>> _locks = {};
  final Set<String> _dirty = {};
  final StreamController<String> _changes = StreamController.broadcast();
  Future<void> _writer = Future<void>.value();
  bool _flushQueued = false;

  static const schema = 1;

  static String key(String puuid) =>
      'keep/${puuid.trim().toLowerCase()}/match_stats';

  /// Emits the PUUID whose ledger changed.
  Stream<String> get changes => _changes.stream;

  /// The ledger of [puuid] (empty when nothing was stored).
  Future<MatchLedger> read(String puuid) {
    final id = _id(puuid);
    return _locked(id, () => _load(id));
  }

  /// Adds [lines] to the ledger of [puuid] (a changed copy of a known match
  /// replaces it). Returns how many match ids were new.
  Future<int> record(String puuid, Iterable<MatchStatLine> lines) {
    final id = _id(puuid);
    final incoming = lines.toList();
    if (id.isEmpty || incoming.isEmpty) return Future.value(0);
    return _locked(id, () async {
      if (canRecord != null && !await canRecord!(id)) return 0;
      final current = await _load(id);
      if (canRecord != null && !await canRecord!(id)) return 0;
      final byId = {for (final l in current.lines) l.matchId: l};
      var added = 0;
      var changed = false;
      for (final l in incoming) {
        final old = byId[l.matchId];
        if (old == null) added++;
        if (old != l) {
          byId[l.matchId] = l;
          changed = true;
        }
      }
      if (!changed) return 0;
      final all = sortedNewestFirst(byId.values);
      final kept = all.length > maxRows ? all.sublist(0, maxRows) : all;
      _memory[id] = MatchLedger(puuid: id, lines: kept);
      _dirty.add(id);
      _scheduleFlush();
      _emit(id);
      return added;
    });
  }

  /// Waits until everything recorded so far is on disk.
  Future<void> flush() async {
    await _writer;
    while (_dirty.isNotEmpty) {
      _scheduleFlush();
      await _writer;
    }
  }

  /// Erases the ledger of [puuid] (Settings "Xóa lịch sử", sign-out).
  Future<void> delete(String puuid) {
    final id = _id(puuid);
    return _locked(id, () async {
      _memory.remove(id);
      _dirty.remove(id);
      // A write already in flight finishes first, so it cannot bring the
      // file back after it was deleted.
      await _writer;
      try {
        await _files.delete(key(id));
      } on Object {
        // Nothing stored or storage unavailable.
      }
      _emit(id);
    });
  }

  void dispose() {
    unawaited(flush().whenComplete(_changes.close));
  }

  // ---------------------------------------------------------------- internals

  static String _id(String puuid) => puuid.trim().toLowerCase();

  Future<T> _locked<T>(String id, Future<T> Function() body) async {
    final previous = _locks[id];
    final done = Completer<void>();
    _locks[id] = done.future;
    try {
      if (previous != null) await previous;
      return await body();
    } finally {
      done.complete();
      _locks.removeWhere((k, f) => k == id && identical(f, done.future));
    }
  }

  Future<MatchLedger> _load(String id) async {
    final cached = _memory[id];
    if (cached != null) return cached;
    MatchLedger ledger;
    try {
      ledger = decode(id, (await _files.read(key(id)))?.data);
    } on Object {
      ledger = MatchLedger(puuid: id);
    }
    return _memory[id] = ledger;
  }

  /// One write at a time; records that arrive meanwhile share the next one
  /// (no timers, so nothing lingers in widget tests).
  void _scheduleFlush() {
    if (_flushQueued) return;
    _flushQueued = true;
    _writer = _writer
        .then((_) async {
          _flushQueued = false;
          final ids = _dirty.toList();
          _dirty.clear();
          for (final id in ids) {
            final ledger = _memory[id];
            if (ledger == null) continue;
            try {
              await _files.write(key(id), encode(ledger));
            } on Object {
              // Keep the in-memory copy; the next record retries.
            }
          }
        })
        .catchError((Object _) {});
  }

  void _emit(String id) {
    if (!_changes.isClosed) _changes.add(id);
  }

  // ------------------------------------------------------------------ codec

  static const _unknown = -1;

  /// Serialised form of [ledger] (see the class comment).
  @visibleForTesting
  static JsonMap encode(MatchLedger ledger) {
    final queues = <String>[];
    final maps = <String>[];
    final agents = <String>[];
    int index(List<String> dict, String? value) {
      if (value == null) return _unknown;
      final i = dict.indexOf(value);
      if (i >= 0) return i;
      dict.add(value);
      return dict.length - 1;
    }

    List<int> side(SideLine s) => [
      s.rounds,
      s.won,
      s.kills ?? _unknown,
      s.deaths ?? _unknown,
      s.firstBloods,
      s.firstDeaths,
    ];

    final rows = <List<Object?>>[];
    for (final l in ledger.lines) {
      final multi = l.multiKills;
      rows.add([
        l.matchId,
        l.startedAt.millisecondsSinceEpoch ~/ 1000,
        index(queues, l.queueId),
        index(maps, l.mapId),
        index(agents, l.agentId),
        _modeCode(l.mode),
        _outcomeCode(l.outcome),
        l.kills,
        l.deaths,
        l.assists,
        l.score,
        l.rounds,
        l.damage ?? _unknown,
        l.headshots,
        l.bodyshots,
        l.legshots,
        l.firstBloods,
        l.firstDeaths,
        ...side(l.attack),
        ...side(l.defense),
        if (multi != null && multi.length >= 4)
          ...multi.take(4)
        else ...const [_unknown, 0, 0, 0],
      ]);
    }
    return {
      'v': schema,
      'queues': queues,
      'maps': maps,
      'agents': agents,
      'rows': rows,
    };
  }

  /// Parses [encode]'s output; corrupt input gives an empty ledger and rows
  /// that do not parse are dropped (never throws).
  @visibleForTesting
  static MatchLedger decode(String puuid, Object? json) {
    final m = asMap(json);
    if (m == null || asInt(m['v']) != schema) {
      return MatchLedger(puuid: puuid);
    }
    final queues = asList(m['queues']);
    final maps = asList(m['maps']);
    final agents = asList(m['agents']);
    String? at(List<Object?> dict, int i) =>
        i >= 0 && i < dict.length ? asString(dict[i]) : null;

    final seen = <String>{};
    final lines = <MatchStatLine>[];
    for (final raw in asList(m['rows'])) {
      final r = asList(raw);
      final id = r.isEmpty ? null : lowerUuid(r[0]);
      if (id == null || !seen.add(id)) continue;
      int v(int i, [int def = 0]) => i < r.length ? asInt(r[i]) ?? def : def;
      final start = v(1);
      final outcome = _outcomeOf(v(6));
      if (start <= 0 || outcome == null) continue;
      SideLine side(int from) {
        final rounds = v(from);
        if (rounds <= 0) return SideLine.none;
        final kills = v(from + 2, _unknown);
        final deaths = v(from + 3, _unknown);
        return SideLine(
          rounds: rounds,
          won: v(from + 1).clamp(0, rounds),
          kills: kills < 0 || deaths < 0 ? null : kills,
          deaths: kills < 0 || deaths < 0 ? null : deaths,
          firstBloods: v(from + 4),
          firstDeaths: v(from + 5),
        );
      }

      final damage = v(12, _unknown);
      lines.add(
        MatchStatLine(
          matchId: id,
          startedAt: DateTime.fromMillisecondsSinceEpoch(
            start * 1000,
            isUtc: true,
          ),
          outcome: outcome,
          queueId: at(queues, v(2, _unknown)) ?? '',
          mapId: at(maps, v(3, _unknown)),
          agentId: at(agents, v(4, _unknown)),
          mode: _modeOf(v(5)),
          kills: v(7),
          deaths: v(8),
          assists: v(9),
          score: v(10),
          rounds: v(11),
          damage: damage < 0 ? null : damage,
          headshots: v(13),
          bodyshots: v(14),
          legshots: v(15),
          firstBloods: v(16),
          firstDeaths: v(17),
          attack: side(18),
          defense: side(24),
          multiKills: v(30, _unknown) < 0
              ? null
              : List.unmodifiable([v(30), v(31), v(32), v(33)]),
        ),
      );
    }
    return MatchLedger(puuid: puuid, lines: lines);
  }

  // Explicit codes: the file never depends on enum declaration order.
  static int _outcomeCode(MatchOutcome o) => switch (o) {
    MatchOutcome.win => 1,
    MatchOutcome.loss => 2,
    MatchOutcome.draw => 3,
    MatchOutcome.unknown => 0,
  };

  static MatchOutcome? _outcomeOf(int code) => switch (code) {
    1 => MatchOutcome.win,
    2 => MatchOutcome.loss,
    3 => MatchOutcome.draw,
    _ => null,
  };

  static int _modeCode(MatchModeKind m) => switch (m) {
    MatchModeKind.standard => 0,
    MatchModeKind.deathmatch => 1,
    MatchModeKind.teamDeathmatch => 2,
    MatchModeKind.escalation => 3,
  };

  static MatchModeKind _modeOf(int code) => switch (code) {
    1 => MatchModeKind.deathmatch,
    2 => MatchModeKind.teamDeathmatch,
    3 => MatchModeKind.escalation,
    _ => MatchModeKind.standard,
  };
}

/// The app-wide [MatchStatsStore] (`<appSupport>/history`).
final matchStatsStoreProvider = Provider<MatchStatsStore>((ref) {
  final accounts = ref.watch(accountRepositoryProvider);
  final store = MatchStatsStore(
    JsonFileCache.appSupport('history'),
    canRecord: (id) async => await accounts.findFresh(id) != null,
  );
  ref.onDispose(store.dispose);
  return store;
});

/// The ledger of an own account (family key = PUUID). Refreshes whenever a
/// match is recorded. Never calls Riot.
final matchLedgerProvider = FutureProvider.autoDispose
    .family<MatchLedger, String>((ref, puuid) {
      final id = puuid.trim().toLowerCase();
      if (ref.watch(accountProvider(id)) == null) return MatchLedger(puuid: id);
      final store = ref.watch(matchStatsStoreProvider);
      final sub = store.changes
          .where((changed) => changed == id)
          .listen((_) => ref.invalidateSelf());
      ref.onDispose(sub.cancel);
      return store.read(id);
    });
