import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/json_file_cache.dart';
import '../../storage/prefs.dart';
import '../../accounts/account_providers.dart';
import '../../util/json.dart';
import 'match_models.dart' show MatchOutcome;
import 'rank_models.dart';

/// Every competitive update seen on this device for one player, plus known
/// match outcomes (R3 true peak, R4 RR per match, R5 Daily RR).
@immutable
class RrHistory {
  RrHistory({
    required this.puuid,
    List<CompetitiveUpdate> rows = const [],
    Map<String, MatchOutcome> outcomes = const {},
  }) : rows = List.unmodifiable(rows),
       outcomes = Map.unmodifiable(outcomes),
       _byMatch = {for (final r in rows) r.matchId: r};

  final String puuid;

  /// Newest first, unique by match id.
  final List<CompetitiveUpdate> rows;

  /// Match id → outcome from P-14 (`teams[].won`), when details were seen.
  final Map<String, MatchOutcome> outcomes;
  final Map<String, CompetitiveUpdate> _byMatch;

  bool get isEmpty => rows.isEmpty;

  /// The RR row of a match ("+24 RR" on match cards).
  CompetitiveUpdate? forMatch(String? matchId) =>
      matchId == null ? null : _byMatch[matchId.trim().toLowerCase()];
}

/// Persists [RrHistory] per PUUID as JSON files.
///
/// Stored under `keep/<puuid>/rr_history` in its own `history` namespace, so
/// "Xóa bộ nhớ đệm" leaves it intact. Account removal must call [delete]
/// unless the user chose to keep local data (WP-CORE owns that flow). Rows are
/// de-duplicated by `MatchID` and capped at [maxRows] (newest kept). Writes
/// for one PUUID are serialised; storage failures degrade to in-memory data.
class RrHistoryStore {
  RrHistoryStore(this._files, {this.maxRows = 5000, this.canRecord});

  final Future<bool> Function(String id)? canRecord;

  final JsonFileCache _files;
  final int maxRows;

  final Map<String, RrHistory> _memory = {};
  final Map<String, RrHistory> _visitors = {};
  final Map<String, Future<void>> _locks = {};
  final StreamController<String> _changes = StreamController.broadcast();

  static const _schema = 1;

  static String key(String puuid) =>
      'keep/${puuid.trim().toLowerCase()}/rr_history';

  /// Remove legacy third-party files, retaining signed-in accounts and
  /// accounts identified by their own kept preferences (wishlist/presets).
  Future<void> pruneUnowned(Set<String> ownAccounts) async {
    final retained = {for (final id in ownAccounts) id.trim().toLowerCase()};
    final directory = (await _files.fileFor('keep/index')).parent;
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final id = entity.path
          .replaceAll('\\', '/')
          .split('/')
          .last
          .toLowerCase();
      if (!retained.contains(id)) await delete(id);
    }
  }

  /// Emits the PUUID whose history changed.
  Stream<String> get changes => _changes.stream;

  /// Other players never create files. LRU: 20 players, 200 rows each.
  RrHistory readVisitor(String puuid) {
    final id = puuid.trim().toLowerCase();
    final history = _visitors.remove(id) ?? RrHistory(puuid: id);
    _visitors[id] = history;
    while (_visitors.length > 20) {
      _visitors.remove(_visitors.keys.first);
    }
    return history;
  }

  int mergeVisitor(String puuid, Iterable<CompetitiveUpdate> incoming) {
    final current = readVisitor(puuid);
    final rows = {for (final r in current.rows) r.matchId: r};
    var added = 0;
    for (final r in incoming) {
      if (!rows.containsKey(r.matchId)) added++;
      rows[r.matchId] = r;
    }
    final sorted = rows.values.toList()..sort(compareUpdatesNewestFirst);
    _visitors[current.puuid] = RrHistory(
      puuid: current.puuid,
      rows: sorted.take(200).toList(),
    );
    _emit(current.puuid);
    return added;
  }

  /// Stored history of [puuid] (empty when nothing was stored).
  Future<RrHistory> read(String puuid) {
    final id = puuid.trim().toLowerCase();
    return _locked(id, () => _load(id));
  }

  /// Adds [rows] (dedup by match id; a newer copy of a known row replaces
  /// it). Returns how many match ids were new.
  Future<int> merge(String puuid, Iterable<CompetitiveUpdate> rows) {
    final id = puuid.trim().toLowerCase();
    final incoming = rows.toList();
    if (id.isEmpty || incoming.isEmpty) return Future.value(0);
    return _locked(id, () async {
      final current = await _load(id);
      final byId = {for (final r in current.rows) r.matchId: r};
      var added = 0;
      var changed = false;
      for (final r in incoming) {
        final old = byId[r.matchId];
        if (old == null) added++;
        if (old != r) {
          byId[r.matchId] = r;
          changed = true;
        }
      }
      if (!changed) return 0;
      final merged = byId.values.toList()..sort(compareUpdatesNewestFirst);
      final kept = merged.length > maxRows
          ? merged.sublist(0, maxRows)
          : merged;
      final keptIds = {for (final r in kept) r.matchId};
      await _save(
        RrHistory(
          puuid: id,
          rows: kept,
          outcomes: {
            for (final MapEntry(:key, :value) in current.outcomes.entries)
              if (keptIds.contains(key)) key: value,
          },
        ),
      );
      return added;
    });
  }

  /// Records match outcomes for [puuid] (only for matches already in the
  /// history, or [force] to keep them for rows that may arrive later).
  Future<void> recordOutcomes(
    String puuid,
    Map<String, MatchOutcome> outcomes, {
    bool force = false,
  }) {
    final id = puuid.trim().toLowerCase();
    if (id.isEmpty || outcomes.isEmpty) return Future.value();
    return _locked(id, () async {
      final current = await _load(id);
      final next = {...current.outcomes};
      var changed = false;
      for (final MapEntry(:key, :value) in outcomes.entries) {
        final match = key.trim().toLowerCase();
        if (value == MatchOutcome.unknown) continue;
        if (!force && current.forMatch(match) == null) continue;
        if (next[match] != value) {
          next[match] = value;
          changed = true;
        }
      }
      if (!changed) return;
      while (next.length > maxRows) {
        next.remove(next.keys.first);
      }
      await _save(RrHistory(puuid: id, rows: current.rows, outcomes: next));
    });
  }

  /// Erases the history of [puuid].
  Future<void> delete(String puuid) {
    final id = puuid.trim().toLowerCase();
    return _locked(id, () async {
      _memory.remove(id);
      _visitors.remove(id);
      try {
        await _files.delete(key(id));
      } on Object {
        // Nothing stored or storage unavailable.
      }
      _emit(id);
    });
  }

  /// Erases every stored history.
  Future<void> clear() async {
    final ids = _memory.keys.toList();
    _memory.clear();
    _visitors.clear();
    try {
      await _files.deletePrefix('keep');
    } on Object {
      // Storage unavailable.
    }
    ids.forEach(_emit);
  }

  void dispose() => unawaited(_changes.close());

  // ---------------------------------------------------------------- internals

  /// Runs [body] after every earlier operation on [id] finished.
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

  Future<RrHistory> _load(String id) async {
    final cached = _memory[id];
    if (cached != null) return cached;
    RrHistory history;
    try {
      history = decode(id, (await _files.read(key(id)))?.data);
    } on Object {
      history = RrHistory(puuid: id);
    }
    _remember(history);
    return history;
  }

  Future<void> _save(RrHistory history) async {
    if (canRecord != null && !await canRecord!(history.puuid)) return;
    _remember(history);
    try {
      await _files.write(key(history.puuid), encode(history));
    } on Object {
      // Keep the in-memory copy; the next write retries.
    }
    _emit(history.puuid);
  }

  void _emit(String id) {
    if (!_changes.isClosed) _changes.add(id);
  }

  void _remember(RrHistory history) {
    _memory.remove(history.puuid);
    _memory[history.puuid] = history;
    while (_memory.length > 20) {
      _memory.remove(_memory.keys.first);
    }
  }

  /// Serialised form: `{"v":1,"rows":[<P-12 rows>],"outcomes":{id:"win"}}`.
  @visibleForTesting
  static JsonMap encode(RrHistory h) => {
    'v': _schema,
    'rows': [for (final r in h.rows) r.toJson()],
    'outcomes': {
      for (final MapEntry(:key, :value) in h.outcomes.entries) key: value.name,
    },
  };

  /// Parses [encode]'s output (corrupt input → empty history).
  @visibleForTesting
  static RrHistory decode(String puuid, Object? json) {
    final m = asMap(json);
    final seen = <String>{};
    final rows = [
      for (final r in asList(m?['rows']))
        if (CompetitiveUpdate.fromJson(r) case final u?
            when seen.add(u.matchId))
          u,
    ]..sort(compareUpdatesNewestFirst);
    final outcomes = <String, MatchOutcome>{};
    for (final MapEntry(:key, :value)
        in (asMap(m?['outcomes']) ?? {}).entries) {
      final o = MatchOutcome.fromName(asString(value));
      if (o != null) outcomes[key.toLowerCase()] = o;
    }
    return RrHistory(puuid: puuid, rows: rows, outcomes: outcomes);
  }
}

/// The app-wide [RrHistoryStore] (`<appSupport>/history`).
final rrHistoryStoreProvider = Provider<RrHistoryStore>((ref) {
  final accounts = ref.watch(accountRepositoryProvider);
  final store = RrHistoryStore(
    JsonFileCache.appSupport('history'),
    canRecord: (id) async => await accounts.findFresh(id) != null,
  );
  final retained = {
    for (final a in ref.read(accountsProvider)) a.puuid,
    for (final key in ref.read(prefsProvider).keys)
      if (RegExp(r'^keep\.([^\.]+)\.').firstMatch(key) case final match?)
        match.group(1)!,
  };
  unawaited(store.pruneUnowned(retained).catchError((Object _) {}));
  ref.onDispose(store.dispose);
  return store;
});
