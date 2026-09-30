import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../config/app_constants.dart';
import '../../riot/pvp_api.dart';
import '../../storage/prefs.dart';
import '../../storage/json_file_cache.dart';
import '../../util/clock.dart';
import '../../util/json.dart';
import 'competitive_strings.dart';
import 'viewer.dart';

/// A Riot ID (`gameName#tagLine`). Never holds the PUUID, so it is safe to
/// log or display.
@immutable
class RiotName {
  const RiotName({required this.gameName, this.tagLine = ''});

  /// A name from two possibly blank strings (match details, presence…);
  /// `null` when [gameName] is blank.
  static RiotName? of(String? gameName, String? tagLine) {
    final game = gameName?.trim() ?? '';
    if (game.isEmpty) return null;
    return RiotName(gameName: game, tagLine: tagLine?.trim() ?? '');
  }

  /// A P-10 name-service row `{Subject, GameName, TagLine, DisplayName}`.
  /// Falls back to the legacy `DisplayName` when `GameName` is blank.
  static RiotName? fromNameService(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    return of(m.text('GameName') ?? m.text('DisplayName'), m.text('TagLine'));
  }

  final String gameName;
  final String tagLine;

  /// `Tên#TAG` (just the name when the tag is unknown).
  String get riotId => tagLine.isEmpty ? gameName : '$gameName#$tagLine';

  bool get isBlank => gameName.trim().isEmpty;

  @override
  bool operator ==(Object other) =>
      other is RiotName &&
      other.gameName == gameName &&
      other.tagLine == tagLine;

  @override
  int get hashCode => Object.hash(gameName, tagLine);

  @override
  String toString() => 'RiotName($riotId)';
}

// ------------------------------------------------------------ incognito (U16)

/// Whether a player's identity must be hidden (SUMMARY U16): Riot's
/// `PlayerIdentity.Incognito` is set and the player is neither the viewer
/// nor in the viewer's party. Use the same rule with `HideAccountLevel` for
/// account levels.
bool isIdentityHidden({
  required bool incognito,
  bool isSelf = false,
  bool isPartyMember = false,
}) => incognito && !isSelf && !isPartyMember;

/// Text to show for a player:
/// - [hidden] → "Người chơi ẩn danh";
/// - a known name → `Tên#TAG` (or just `Tên` with `withTag: false`);
/// - otherwise [fallback] (e.g. the agent name), else "Người chơi".
String playerDisplayName(
  RiotName? name, {
  bool hidden = false,
  bool withTag = true,
  String? fallback,
}) {
  if (hidden) return CompetitiveStrings.incognitoPlayer;
  if (name != null && !name.isBlank) {
    return withTag ? name.riotId : name.gameName;
  }
  final f = fallback?.trim();
  return (f == null || f.isEmpty) ? CompetitiveStrings.unknownPlayer : f;
}

/// Account level to show, or `null` when `HideAccountLevel` applies.
int? visibleAccountLevel(
  int? level, {
  required bool hideAccountLevel,
  bool isSelf = false,
  bool isPartyMember = false,
}) =>
    isIdentityHidden(
      incognito: hideAccountLevel,
      isSelf: isSelf,
      isPartyMember: isPartyMember,
    )
    ? null
    : level;

// ------------------------------------------------------------ resolver

class _Entry {
  const _Entry(this.name, this.savedAt);

  final RiotName name;
  final DateTime savedAt;
}

typedef _Outcome = ({RiotName? name, Object? error, StackTrace? stack});

/// Resolves PUUIDs to Riot IDs through P-10 name-service (SUMMARY §6.2,
/// EP §9), which is required because 2026 match details arrive with blank
/// `gameName`/`tagLine`.
///
/// - Requests made within [batchWindow] of each other are coalesced; each
///   network call carries at most 50 PUUIDs (U15) and calls run one after
///   another per viewer to stay under Cloudflare's burst limits.
/// - Concurrent requests for the same PUUID share one call.
/// - Results are cached in memory and `cache/names` for at most [retention],
///   bounded to [maxEntries]; entries younger than [freshFor] are served
///   without a call, older ones are refreshed but still returned if the
///   refresh fails.
class NameResolver {
  NameResolver({
    required this._api,
    this._prefs,
    this._files,
    this._clock = const Clock(),
    this.batchWindow = const Duration(milliseconds: 20),
    this.freshFor = const Duration(days: 1),
    this.maxEntries = 1000,
  });

  static const prefsKey = 'f.competitive.names';
  static const batchSize = RiotClientConstants.nameServiceBatch;

  final PvpApi _api;
  final Prefs? _prefs;
  final JsonFileCache? _files;
  static const fileKey = 'names';
  static const retention = Duration(days: 30);
  final Clock _clock;
  final Duration batchWindow;
  final Duration freshFor;
  final int maxEntries;

  final Map<String, _Entry> _cache = {};
  final Map<String, Future<RiotName?>> _inFlight = {};
  Map<String, Map<String, Completer<RiotName?>>> _pending = {};
  Timer? _timer;
  Future<void>? _loading;
  Timer? _persistTimer;
  Future<void> _writes = Future.value();
  bool _disposed = false;
  int _generation = 0;

  static String _key(String puuid) => puuid.trim().toLowerCase();

  /// Cached name (fresh or stale) without any network call.
  RiotName? peek(String puuid) {
    unawaited(_load());
    _prune();
    return _cache[_key(puuid)]?.name;
  }

  /// Seeds the cache with a name learnt elsewhere (non-blank match data,
  /// XMPP roster, the signed-in account's own Riot ID).
  void remember(String puuid, RiotName name) {
    final id = _key(puuid);
    if (_disposed || id.isEmpty || name.isBlank) return;
    unawaited(_load());
    final previous = _cache[id]?.name;
    _cache[id] = _Entry(name, _clock.now());
    if (previous != name) _persist();
  }

  /// Names for [puuids] (lowercase keys), using [viewer]'s session for the
  /// calls. PUUIDs Riot does not know are left out. Throws the
  /// `RiotException` of a failed call only when nothing could be resolved.
  Future<Map<String, RiotName>> resolve(
    String viewer,
    Iterable<String> puuids, {
    bool refresh = false,
  }) async {
    await _load();
    if (_disposed) return const {};
    _prune();
    final now = _clock.now();
    final out = <String, RiotName>{};
    final waits = <String, Future<_Outcome>>{};
    for (final raw in puuids) {
      final id = _key(raw);
      if (id.isEmpty || out.containsKey(id) || waits.containsKey(id)) {
        continue;
      }
      final cached = _cache[id];
      if (!refresh &&
          cached != null &&
          now.difference(cached.savedAt) < freshFor) {
        out[id] = cached.name;
        continue;
      }
      waits[id] = _capture(_inFlight[id] ?? _enqueue(_key(viewer), id));
    }
    Object? error;
    StackTrace? stack;
    for (final MapEntry(key: id, value: wait) in waits.entries) {
      final result = await wait;
      final name = result.name ?? _cache[id]?.name;
      if (name != null) {
        out[id] = name;
      } else if (result.error != null) {
        error ??= result.error;
        stack ??= result.stack;
      }
    }
    if (out.isEmpty && error != null) {
      Error.throwWithStackTrace(error, stack ?? StackTrace.current);
    }
    return out;
  }

  /// One name (see [resolve]).
  Future<RiotName?> resolveOne(String viewer, String puuid) async =>
      (await resolve(viewer, [puuid]))[_key(puuid)];

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _persistTimer?.cancel();
    // Callers still waiting get "unknown" rather than hanging forever.
    for (final byId in _pending.values) {
      for (final c in byId.values) {
        if (!c.isCompleted) c.complete(null);
      }
    }
    _pending = {};
  }

  static Future<_Outcome> _capture(Future<RiotName?> f) => f.then(
    (name) => (name: name, error: null, stack: null),
    onError: (Object e, StackTrace s) => (name: null, error: e, stack: s),
  );

  Future<RiotName?> _enqueue(String viewer, String id) {
    final completer = Completer<RiotName?>();
    if (_disposed) {
      completer.complete(null);
      return completer.future;
    }
    (_pending[viewer] ??= {})[id] = completer;
    final future = completer.future;
    _inFlight[id] = future;
    _timer ??= Timer(batchWindow, _flush);
    return future;
  }

  void _flush() {
    _timer = null;
    final batches = _pending;
    _pending = {};
    for (final MapEntry(key: viewer, value: byId) in batches.entries) {
      unawaited(_fetchAll(viewer, byId));
    }
  }

  Future<void> _fetchAll(
    String viewer,
    Map<String, Completer<RiotName?>> byId,
  ) async {
    final generation = _generation;
    final ids = byId.keys.toList();
    for (var i = 0; i < ids.length; i += batchSize) {
      final chunk = ids.sublist(
        i,
        i + batchSize > ids.length ? ids.length : i + batchSize,
      );
      try {
        if (_disposed || generation != _generation) {
          for (final id in chunk) {
            if (!byId[id]!.isCompleted) byId[id]!.complete(null);
          }
          continue;
        }
        final rows = await _api.names(viewer, chunk);
        if (_disposed || generation != _generation) {
          for (final id in chunk) {
            if (!byId[id]!.isCompleted) byId[id]!.complete(null);
          }
          continue;
        }
        final found = <String, RiotName>{};
        for (final row in rows) {
          final subject = lowerUuid(row['Subject']);
          final name = RiotName.fromNameService(row);
          if (subject != null && name != null) found[subject] = name;
        }
        final now = _clock.now();
        _forget(chunk);
        for (final id in chunk) {
          final name = found[id];
          if (name != null) _cache[id] = _Entry(name, now);
          byId[id]?.complete(name);
        }
        if (found.isNotEmpty) _persist();
      } on Object catch (e, s) {
        if (_disposed || generation != _generation) {
          for (final id in chunk) {
            if (!byId[id]!.isCompleted) byId[id]!.complete(null);
          }
          continue;
        }
        _forget(chunk);
        for (final id in chunk) {
          byId[id]?.completeError(e, s);
        }
      }
    }
  }

  void _forget(List<String> ids) {
    final set = ids.toSet();
    _inFlight.removeWhere((id, _) => set.contains(id));
  }

  Future<void> _load() => _loading ??= _loadFile();

  Future<void> _loadFile() async {
    final generation = _generation;
    final legacy = asMap(_prefs?.getJson(prefsKey));
    final stored = asMap((await _files?.read(fileKey))?.data) ?? legacy;
    if (_prefs != null) await _prefs.remove(prefsKey);
    if (stored == null || _disposed || generation != _generation) return;
    for (final MapEntry(:key, :value) in stored.entries) {
      final m = asMap(value);
      final name = RiotName.of(asString(m?['n']), asString(m?['t']));
      final at = asInt(m?['at']);
      final id = _key(key);
      if (name == null || at == null || id.isEmpty) continue;
      _cache.putIfAbsent(
        id,
        () => _Entry(name, DateTime.fromMillisecondsSinceEpoch(at)),
      );
    }
    _prune();
    _persist(); // expires old file entries as well as migrating preferences
  }

  void _prune() {
    final cutoff = _clock.now().subtract(retention);
    _cache.removeWhere((_, e) => e.savedAt.isBefore(cutoff));
    if (_cache.length > maxEntries) {
      final oldest = _cache.entries.toList()
        ..sort((a, b) => a.value.savedAt.compareTo(b.value.savedAt));
      for (final e in oldest.take(_cache.length - maxEntries)) {
        _cache.remove(e.key);
      }
    }
  }

  void _persist() {
    _prune();
    if (_disposed || _files == null) return;
    _persistTimer?.cancel();
    _persistTimer = Timer(
      const Duration(milliseconds: 100),
      () => unawaited(flush()),
    );
  }

  /// Debounced persistence, with serial writes and a bounded lifetime.
  Future<void> flush() {
    _persistTimer?.cancel();
    _persistTimer = null;
    _writes = _writes
        .then((_) async {
          await _load();
          _prune();
          final json = {
            for (final MapEntry(:key, :value) in _cache.entries)
              key: {
                'n': value.name.gameName,
                't': value.name.tagLine,
                'at': value.savedAt.millisecondsSinceEpoch,
              },
          };
          await _files?.write(fileKey, json);
        })
        .catchError((Object _) {});
    return _writes;
  }

  Future<void> clear() async {
    _generation++;
    _timer?.cancel();
    _timer = null;
    for (final byId in _pending.values) {
      for (final completion in byId.values) {
        if (!completion.isCompleted) completion.complete(null);
      }
    }
    _pending.clear();
    _inFlight.clear();
    await _load();
    _persistTimer?.cancel();
    _cache.clear();
    await _writes;
    await _files?.delete(fileKey);
    await _prefs?.remove(prefsKey);
  }
}

/// App-wide [NameResolver].
final nameResolverProvider = Provider<NameResolver>((ref) {
  final resolver = NameResolver(
    api: ref.watch(pvpApiProvider),
    prefs: ref.watch(prefsProvider),
    files: ref.watch(jsonFileCacheProvider),
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(resolver.dispose);
  ref.listen(accountsProvider, (_, accounts) {
    if (accounts.isEmpty) unawaited(resolver.clear());
  });
  return resolver;
});

/// Riot ID of any player (family key = PUUID). Signed-in accounts use their
/// stored Riot ID; everyone else goes through the batched [NameResolver], so
/// ten scoreboard rows watching this provider cost one network call.
/// `null` when Riot does not know the PUUID.
///
/// Apply [isIdentityHidden] / [playerDisplayName] before showing it.
final playerNameProvider = FutureProvider.autoDispose.family<RiotName?, String>(
  (ref, puuid) async {
    final id = puuid.trim().toLowerCase();
    final own = ref.watch(
      accountProvider(id)
          .select((a) => a == null ? null : RiotName.of(a.gameName, a.tagLine)),
    );
    if (own != null) return own;
    final viewer = watchViewer(ref, id);
    final resolver = ref.watch(nameResolverProvider);
    return resolver.resolveOne(viewer, id);
  },
);
