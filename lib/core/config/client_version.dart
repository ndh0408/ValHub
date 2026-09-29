import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';
import '../util/clock.dart';
import '../util/json.dart';
import 'app_constants.dart';
import 'remote_config.dart';

/// valorant-api `/v1/version` subset (SUMMARY §3.3 step d).
@immutable
class ClientVersionInfo {
  const ClientVersionInfo({
    required this.riotClientVersion,
    required this.riotClientBuild,
    this.manifestId,
    this.fetchedAt,
  });

  static const fallback = ClientVersionInfo(
    riotClientVersion: RiotClientConstants.fallbackClientVersion,
    riotClientBuild: RiotClientConstants.fallbackClientBuild,
  );

  /// Parses `/v1/version` (envelope or `data`). `null` when incomplete.
  static ClientVersionInfo? fromApi(Object? json, {DateTime? fetchedAt}) {
    final m = asMap(vapiData(json)) ?? asMap(json);
    final version = asNonEmptyString(m?['riotClientVersion']);
    final build = asNonEmptyString(m?['riotClientBuild']);
    if (version == null || build == null) return null;
    return ClientVersionInfo(
      riotClientVersion: version,
      riotClientBuild: build,
      manifestId: asNonEmptyString(m?['manifestId']),
      fetchedAt: fetchedAt ?? asDateTime(m?['fetchedAt']),
    );
  }

  /// `X-Riot-ClientVersion`, e.g. `release-13.06-shipping-13-5435758`.
  final String riotClientVersion;

  /// e.g. `111.0.0.3261.5663` (for the API User-Agent).
  final String riotClientBuild;

  /// Content cache key (valorant-api build id).
  final String? manifestId;
  final DateTime? fetchedAt;

  JsonMap toJson() => {
    'riotClientVersion': riotClientVersion,
    'riotClientBuild': riotClientBuild,
    'manifestId': manifestId,
    'fetchedAt': fetchedAt?.millisecondsSinceEpoch,
  };

  ClientVersionInfo withVersion(String version) => ClientVersionInfo(
    riotClientVersion: version,
    riotClientBuild: riotClientBuild,
    manifestId: manifestId,
    fetchedAt: fetchedAt,
  );
}

/// Caches `/v1/version` in prefs and refreshes it at most every 6 h.
/// Usable from background isolates (no Riverpod needed).
class ClientVersionRepository {
  ClientVersionRepository({
    required this._prefs,
    required RemoteConfig Function() remoteConfig,
    Dio? dio,
    this._clock = const Clock(),
  }) : _config = remoteConfig,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               // Short: every content load waits for this (black-holed
               // networks would otherwise hang on the OS TCP timeout).
               connectTimeout: versionTimeout,
               receiveTimeout: versionTimeout,
               sendTimeout: versionTimeout,
             ),
           );

  /// Timeout of the `/version` request.
  static const versionTimeout = Duration(seconds: 10);

  final Prefs _prefs;
  final RemoteConfig Function() _config;
  final Dio _dio;
  final Clock _clock;
  Future<ClientVersionInfo>? _inFlight;

  ClientVersionInfo get _stored =>
      ClientVersionInfo.fromApi(_prefs.getJson(PrefKeys.clientVersion)) ??
      ClientVersionInfo.fallback;

  /// Effective version (remote-config override applied). Synchronous.
  ClientVersionInfo get current {
    final override = _config().clientVersionOverride;
    final stored = _stored;
    return override == null ? stored : stored.withVersion(override);
  }

  /// `RiotClient/{build} rso-auth (Windows;10;;Professional, x64)` or the
  /// remote-config override.
  String get apiUserAgent =>
      _config().apiUserAgent ??
      RiotClientConstants.apiUserAgent(current.riotClientBuild);

  /// Fetches `/v1/version` when the cached copy is older than 6 h (or
  /// [force]). Never throws; returns [current] on failure.
  Future<ClientVersionInfo> refresh({bool force = false}) {
    final fetchedAt = _stored.fetchedAt;
    final fresh =
        fetchedAt != null &&
        _clock.now().difference(fetchedAt) < AppConstants.versionCheckInterval;
    if (fresh && !force) return Future.value(current);
    return _inFlight ??= _fetch().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<ClientVersionInfo> _fetch() async {
    try {
      final res = await _dio.get<Object?>(
        '${AppConstants.contentApiBase}/version',
      );
      final info = ClientVersionInfo.fromApi(res.data, fetchedAt: _clock.now());
      if (info != null) {
        await _prefs.setJson(PrefKeys.clientVersion, info.toJson());
      }
    } on Object {
      // Offline or valorant-api down: keep the cached / fallback version.
    }
    return current;
  }
}

/// App-wide client version repository.
final clientVersionRepositoryProvider = Provider<ClientVersionRepository>(
  (ref) => ClientVersionRepository(
    prefs: ref.watch(prefsProvider),
    remoteConfig: () => ref.read(remoteConfigProvider),
    clock: ref.watch(clockProvider),
  ),
);
