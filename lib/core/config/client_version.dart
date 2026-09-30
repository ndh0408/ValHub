import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';
import '../util/clock.dart';
import '../util/json.dart';
import 'app_constants.dart';
import 'remote_config.dart';

/// `release-13.06-shipping-13-5435758`: the only shape `X-Riot-ClientVersion`
/// may have. Anything else (third-party API glitch, CR/LF injection, a
/// remote-config typo) would break every PD / GLZ request.
final RegExp clientVersionPattern = RegExp(
  r'^release-\d{1,3}\.\d{1,3}-shipping-\d{1,4}-\d{4,9}$',
);

/// `111.0.0.3261.5663`: the Riot client build used in the API User-Agent.
final RegExp clientBuildPattern = RegExp(r'^\d{1,4}(\.\d{1,6}){2,5}$');

final RegExp _manifestPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

/// Whether [value] can be sent as `X-Riot-ClientVersion`.
bool isValidClientVersion(String? value) =>
    value != null && clientVersionPattern.hasMatch(value);

/// Whether [value] can be part of the API User-Agent.
bool isValidClientBuild(String? value) =>
    value != null && clientBuildPattern.hasMatch(value);

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

  /// Parses `/v1/version` (envelope or `data`). `null` when incomplete **or
  /// malformed**: the version and build must match [clientVersionPattern] /
  /// [clientBuildPattern] (a value that only looks like a string would break
  /// every request until the next refresh), so callers keep their last good
  /// value instead.
  static ClientVersionInfo? fromApi(Object? json, {DateTime? fetchedAt}) {
    final m = asMap(vapiData(json)) ?? asMap(json);
    final version = asNonEmptyString(m?['riotClientVersion'])?.trim();
    final build = asNonEmptyString(m?['riotClientBuild'])?.trim();
    if (!isValidClientVersion(version) || !isValidClientBuild(build)) {
      return null;
    }
    final manifest = asNonEmptyString(m?['manifestId'])?.trim();
    return ClientVersionInfo(
      riotClientVersion: version!,
      riotClientBuild: build!,
      manifestId: manifest != null && _manifestPattern.hasMatch(manifest)
          ? manifest
          : null,
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
  DateTime? _lastRejectedRefresh;

  ClientVersionInfo get _stored =>
      ClientVersionInfo.fromApi(_prefs.getJson(PrefKeys.clientVersion)) ??
      ClientVersionInfo.fallback;

  /// Effective version (remote-config override applied). Synchronous.
  ClientVersionInfo get current {
    final override = _config().clientVersionOverride;
    final stored = _stored;
    // A malformed override (remote-config typo) is ignored.
    return isValidClientVersion(override)
        ? stored.withVersion(override!)
        : stored;
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

  /// Minimum gap between two refreshes forced by a rejected version.
  static const rejectedRefreshGap = Duration(minutes: 10);

  /// A PD / GLZ call was refused because of the client version (see
  /// `isClientVersionRejection`): re-reads `/v1/version` now (at most once
  /// every [rejectedRefreshGap]) and reports whether the effective version
  /// changed, i.e. whether repeating the call can succeed.
  Future<bool> noteRejected() async {
    final now = _clock.now();
    final last = _lastRejectedRefresh;
    if (last != null && now.difference(last) < rejectedRefreshGap) {
      return false;
    }
    _lastRejectedRefresh = now;
    final before = current.riotClientVersion;
    final after = (await refresh(force: true)).riotClientVersion;
    return after != before;
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
