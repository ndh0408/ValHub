import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';
import '../config/client_version.dart';
import '../logging/session_log.dart';
import '../network/dio_factory.dart';
import '../network/riot_exception.dart';
import '../settings/app_settings.dart';
import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../util/clock.dart';
import '../util/json.dart';
import 'content_db.dart';

/// Downloads, caches and parses valorant-api.com content (CA §2, SUMMARY
/// §7.9, §10).
///
/// - Cache key = `manifestId | language | schema`; refreshed when the key
///   changes or after 7 days.
/// - Raw JSON files live in `<appSupport>/content/<language>/`.
/// - Parsing runs in `Isolate.run`.
/// - Offline / valorant-api down: the last cache is used, whatever its age.
class ContentRepository {
  ContentRepository({
    required this._versions,
    Dio? dio,
    JsonFileCache? cache,
    this._prefs,
    this._clock = const Clock(),
    Future<ContentDb> Function(
      Map<String, String> raw,
      String language,
      String? manifestId,
    )?
    parser,
  }) : _dio = dio ?? createBaseDio(),
       _cache = cache ?? JsonFileCache.appSupport('content'),
       _parser = parser ?? _parseInIsolate;

  final ClientVersionRepository _versions;
  final Dio _dio;
  final JsonFileCache _cache;
  final Prefs? _prefs;
  final Clock _clock;
  final Future<ContentDb> Function(Map<String, String>, String, String?)
  _parser;

  /// Endpoint key → path (with query) under `https://valorant-api.com/v1`.
  static const endpoints = <String, String>{
    ContentEndpoints.weapons: '/weapons',
    ContentEndpoints.bundles: '/bundles',
    ContentEndpoints.buddies: '/buddies',
    ContentEndpoints.sprays: '/sprays',
    ContentEndpoints.playerCards: '/playercards',
    ContentEndpoints.playerTitles: '/playertitles',
    ContentEndpoints.flex: '/flex',
    ContentEndpoints.levelBorders: '/levelborders',
    ContentEndpoints.agents: '/agents?isPlayableCharacter=true',
    ContentEndpoints.maps: '/maps',
    ContentEndpoints.gameModes: '/gamemodes',
    ContentEndpoints.queues: '/gamemodes/queues',
    ContentEndpoints.competitiveTiers: '/competitivetiers',
    ContentEndpoints.seasons: '/seasons',
    ContentEndpoints.competitiveSeasons: '/seasons/competitive',
    ContentEndpoints.contracts: '/contracts',
    ContentEndpoints.missions: '/missions',
    ContentEndpoints.currencies: '/currencies',
    ContentEndpoints.contentTiers: '/contenttiers',
    ContentEndpoints.ceremonies: '/ceremonies',
    ContentEndpoints.gear: '/gear',
    ContentEndpoints.events: '/events',
    ContentEndpoints.equippables: '/gamemodes/equippables',
  };

  static String cacheKey(String? manifestId, String language) =>
      '${manifestId ?? 'unknown'}|$language|schema=${AppConstants.contentSchemaVersion}';

  static String _fileKey(String language, String endpoint) =>
      '$language/$endpoint';
  static String _metaKey(String language) => '$language/meta';
  static String _missKey(String language) =>
      'f.content.lastMissRefresh.$language';

  static Future<ContentDb> _parseInIsolate(
    Map<String, String> raw,
    String language,
    String? manifestId,
  ) => Isolate.run(
    () => ContentDb.parse(raw, language: language, manifestId: manifestId),
  );

  /// Loads content for [language] (`vi-VN` / `en-US`).
  ///
  /// Throws [TransientException] only when nothing is cached and the
  /// download failed.
  ///
  /// [preferCache] (background tasks, ~30 s budget): any complete cached
  /// content is returned whatever its age, without the `/version` check; a
  /// download happens only when nothing complete is cached.
  Future<ContentDb> load({
    String language = 'vi-VN',
    bool force = false,
    bool preferCache = false,
  }) async {
    if (preferCache && !force) {
      final cached = await _readAll(language);
      if (cached.length == endpoints.length) {
        return _parser(cached, language, _versions.current.manifestId);
      }
    }
    // A slow /version must never block content served from the cache.
    final version = await _versions.refresh().timeout(
      const Duration(seconds: 5),
      onTimeout: () => _versions.current,
    );
    final key = cacheKey(version.manifestId, language);
    final meta = (await _cache.read(_metaKey(language)))?.map;
    final cachedKey = asString(meta?['key']);
    final fetchedAt = asDateTime(meta?['fetchedAt']);
    final age = fetchedAt == null ? null : _clock.now().difference(fetchedAt);
    final fresh =
        cachedKey != null &&
        (version.manifestId == null || cachedKey == key) &&
        age != null &&
        age < AppConstants.contentMaxAge;

    if (fresh && !force) {
      final cached = await _readAll(language);
      if (cached.length == endpoints.length) {
        return _parser(cached, language, version.manifestId);
      }
    }

    final downloaded = await _downloadAll(language);
    final cached = await _readAll(language);
    final merged = {...cached, ...downloaded};
    if (!merged.containsKey(ContentEndpoints.weapons)) {
      throw const TransientException(reason: 'content_unavailable');
    }
    for (final e in downloaded.entries) {
      await _cache.writeRaw(_fileKey(language, e.key), e.value);
    }
    if (downloaded.length == endpoints.length) {
      await _cache.write(_metaKey(language), {
        'key': key,
        'fetchedAt': _clock.now().toUtc().toIso8601String(),
      });
    }
    return _parser(merged, language, version.manifestId);
  }

  /// Whether a refresh after a content miss (a Riot UUID not in the cache)
  /// is allowed now — at most once every 6 h (CA §2.2 step 3). Records the
  /// attempt when it returns true.
  Future<bool> allowMissRefresh(String language) async {
    final prefs = _prefs;
    if (prefs == null) return false;
    final last = prefs.getDateTime(_missKey(language));
    final now = _clock.now();
    if (last != null &&
        now.difference(last) < AppConstants.versionCheckInterval) {
      return false;
    }
    await prefs.setDateTime(_missKey(language), now);
    return true;
  }

  /// Deletes every cached content file ("Xóa bộ nhớ đệm").
  Future<void> clear() => _cache.clear();

  /// Size of the content cache in bytes.
  Future<int> sizeBytes() => _cache.sizeBytes();

  Future<Map<String, String>> _readAll(String language) async {
    final out = <String, String>{};
    for (final name in endpoints.keys) {
      final raw = await _cache.readRaw(_fileKey(language, name));
      if (raw != null && raw.isNotEmpty) out[name] = raw;
    }
    return out;
  }

  Future<Map<String, String>> _downloadAll(String language) async {
    final out = <String, String>{};
    final entries = endpoints.entries.toList();
    // Four at a time: ~1 MB gzip in total.
    for (var i = 0; i < entries.length; i += 4) {
      final batch = entries.skip(i).take(4);
      await Future.wait([
        for (final e in batch)
          _download(e.value, language).then((raw) {
            if (raw != null) out[e.key] = raw;
          }),
      ]);
    }
    return out;
  }

  Future<String?> _download(String path, String language) async {
    final sep = path.contains('?') ? '&' : '?';
    try {
      final res = await _dio.get<String>(
        '${AppConstants.contentApiBase}$path${sep}language=$language',
        options: Options(responseType: ResponseType.plain),
      );
      final body = res.data;
      final decoded = asMap(tryDecodeJson(body));
      if (body == null || decoded == null || decoded['data'] == null) {
        return null;
      }
      return body;
    } on Object {
      return null;
    }
  }
}

/// App-wide content repository.
final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(
    versions: ref.watch(clientVersionRepositoryProvider),
    dio: createBaseDio(log: ref.watch(sessionLogProvider)),
    prefs: ref.watch(prefsProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The parsed content in the user's item-name language (VF §6.8). Kept alive
/// for the app's lifetime; re-evaluates when the language setting changes.
///
/// ```dart
/// final content = ref.watch(contentProvider);          // AsyncValue<ContentDb>
/// final db = ref.watch(contentProvider).value ?? ContentDb.empty();
/// ```
final contentProvider = FutureProvider<ContentDb>((ref) {
  final language = ref.watch(appSettingsProvider.select((s) => s.itemLanguage));
  return ref.watch(contentRepositoryProvider).load(language: language.apiCode);
});

/// Re-runs [contentProvider] when it is in error (it is kept alive, so a
/// failed first load would otherwise stay failed until restart). Call from
/// refresh / retry handlers and on app resume.
extension ContentRetry on WidgetRef {
  void retryContentIfFailed() {
    if (read(contentProvider).hasError) invalidate(contentProvider);
  }
}

/// Call when a Riot UUID is missing from [ContentDb] (new patch content):
/// re-downloads content at most once every 6 h.
final contentMissReporterProvider = Provider<ContentMissReporter>(
  (ref) => ContentMissReporter(ref),
);

class ContentMissReporter {
  ContentMissReporter(this._ref);

  final Ref _ref;
  bool _pending = false;

  Future<void> report() async {
    if (_pending) return;
    _pending = true;
    try {
      final language = _ref.read(appSettingsProvider).itemLanguage.apiCode;
      final repo = _ref.read(contentRepositoryProvider);
      if (await repo.allowMissRefresh(language)) {
        await repo.load(language: language, force: true);
        _ref.invalidate(contentProvider);
      }
    } on Object {
      // A miss refresh is best effort.
    } finally {
      _pending = false;
    }
  }
}
