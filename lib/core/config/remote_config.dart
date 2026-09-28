import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';
import '../util/json.dart';
import 'app_constants.dart';

/// Remotely overridable knobs (SUMMARY §13 "Remote config"). The bundled
/// default lives in `assets/config/remote_config.json`; an optional static
/// JSON at [AppConstants.remoteConfigUrl] (no user data is ever sent) is
/// fetched in the background and applied on the next launch.
@immutable
class RemoteConfig {
  const RemoteConfig({
    this.flags = const {},
    this.webViewUserAgent,
    this.apiUserAgent,
    this.clientVersionOverride,
  });

  static const defaults = RemoteConfig();

  factory RemoteConfig.fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final flags = <String, bool>{
      for (final e in (asMap(m['flags']) ?? const <String, dynamic>{}).entries)
        e.key: ?asBool(e.value),
    };
    return RemoteConfig(
      flags: flags,
      webViewUserAgent: asNonEmptyString(m['webViewUserAgent']),
      apiUserAgent: asNonEmptyString(m['apiUserAgent']),
      clientVersionOverride: asNonEmptyString(m['clientVersionOverride']),
    );
  }

  /// Feature flags (SUMMARY §13): `social_login_hint`, `reauth_post_first`,
  /// `use_offers_endpoint`, `nm_next_date_source`, `live_score`,
  /// `party_accept_invite`, `console_support`.
  final Map<String, bool> flags;

  /// Replaces the login WebView's mobile-browser UA.
  final String? webViewUserAgent;

  /// Replaces the Riot-client UA sent to auth / PD / GLZ.
  final String? apiUserAgent;

  /// Replaces `X-Riot-ClientVersion`.
  final String? clientVersionOverride;

  bool flag(String name, {bool fallback = false}) => flags[name] ?? fallback;

  /// [other]'s non-null values win.
  RemoteConfig merge(RemoteConfig other) => RemoteConfig(
    flags: {...flags, ...other.flags},
    webViewUserAgent: other.webViewUserAgent ?? webViewUserAgent,
    apiUserAgent: other.apiUserAgent ?? apiUserAgent,
    clientVersionOverride: other.clientVersionOverride ?? clientVersionOverride,
  );

  JsonMap toJson() => {
    'flags': flags,
    'webViewUserAgent': webViewUserAgent,
    'apiUserAgent': apiUserAgent,
    'clientVersionOverride': clientVersionOverride,
  };
}

/// Well-known flag names.
abstract final class RemoteFlags {
  static const socialLoginHint = 'social_login_hint';
  static const reauthPostFirst = 'reauth_post_first';
  static const useOffersEndpoint = 'use_offers_endpoint';
  static const nmNextDateSource = 'nm_next_date_source';
  static const liveScore = 'live_score';
  static const partyAcceptInvite = 'party_accept_invite';
  static const consoleSupport = 'console_support';
}

/// Loads the bundled config merged with the last fetched remote copy.
class RemoteConfigLoader {
  RemoteConfigLoader(
    this._prefs, {
    this._dio,
    this._url = AppConstants.remoteConfigUrl,
  });

  final Prefs _prefs;
  final Dio? _dio;
  final String _url;

  static const assetPath = 'assets/config/remote_config.json';

  /// Bundled defaults + cached remote copy. Never throws.
  Future<RemoteConfig> load() async {
    var config = RemoteConfig.defaults;
    try {
      config = RemoteConfig.fromJson(
        tryDecodeJson(await rootBundle.loadString(assetPath)),
      );
    } on Object {
      // Missing asset (tests) → defaults.
    }
    final cached = _prefs.getJson(PrefKeys.remoteConfig);
    if (cached != null) config = config.merge(RemoteConfig.fromJson(cached));
    return config;
  }

  /// Fetches the remote copy (if a URL is configured) and caches it for the
  /// next launch. Never throws.
  Future<void> refresh() async {
    if (_url.isEmpty) return;
    try {
      final dio =
          _dio ?? Dio(BaseOptions(receiveTimeout: const Duration(seconds: 10)));
      final res = await dio.get<String>(
        _url,
        options: Options(responseType: ResponseType.plain),
      );
      final json = tryDecodeJson(res.data);
      if (asMap(json) != null) {
        await _prefs.setJson(PrefKeys.remoteConfig, json);
      }
    } on Object {
      // Remote config is optional.
    }
  }
}

/// Effective remote config. `main()` overrides it with the loaded value.
final remoteConfigProvider = Provider<RemoteConfig>(
  (ref) => RemoteConfig.defaults,
);
