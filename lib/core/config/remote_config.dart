import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/session_log.dart';
import '../storage/prefs.dart';
import '../util/json.dart';
import 'app_constants.dart';
import 'client_version_format.dart';
import 'vp_prices.dart';

/// Remotely overridable knobs (SUMMARY §13 "Remote config"). The bundled
/// default lives in `assets/config/remote_config.json`; an optional static
/// JSON at [AppConstants.remoteConfigUrl] (no user data is ever sent) is
/// fetched in the background and applied on the next launch.
///
/// Every field is validated when parsed ([RemoteConfig.fromJson]) and the
/// whole document is checked by [sanitizeRemoteConfig] before it is stored,
/// so a bad or tampered document can neither redirect traffic nor break
/// requests (AR-009, AR-010):
///
/// - the community server is **not** configurable: the host that receives the
///   Riot access token is pinned in [AppConstants.communityHosts];
/// - User-Agents must be printable ASCII (no CR/LF), the client version must
///   have the `release-N.NN-shipping-N-NNNNNNN` shape, flags are booleans with
///   `snake_case` names.
@immutable
class RemoteConfig {
  const RemoteConfig({
    this.flags = const {},
    this.webViewUserAgent,
    this.apiUserAgent,
    this.clientVersionOverride,
    this.vpPrices = const VpPriceCatalog(),
  });

  static const defaults = RemoteConfig();

  factory RemoteConfig.fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final flags = <String, bool>{};
    for (final e in (asMap(m['flags']) ?? const <String, dynamic>{}).entries) {
      if (flags.length >= maxFlags) break;
      final value = asBool(e.value);
      if (value != null && _flagName.hasMatch(e.key)) flags[e.key] = value;
    }
    String? userAgent(Object? v) {
      final s = asNonEmptyString(v)?.trim();
      return isValidUserAgent(s) ? s : null;
    }

    final override = asNonEmptyString(m['clientVersionOverride'])?.trim();
    return RemoteConfig(
      flags: flags,
      webViewUserAgent: userAgent(m['webViewUserAgent']),
      apiUserAgent: userAgent(m['apiUserAgent']),
      clientVersionOverride: isValidClientVersion(override) ? override : null,
      vpPrices: VpPriceCatalog.fromJson(m['vpPrices']),
    );
  }

  /// Schema of the document this app understands (`"schema": 1`).
  static const schema = 1;

  /// At most this many flags are read from a document.
  static const maxFlags = 64;

  static final RegExp _flagName = RegExp(r'^[a-z][a-z0-9_]{0,63}$');

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

  /// Always `null`. The community server (which receives the Riot access
  /// token at `POST /v1/auth/riot`) is pinned in code
  /// ([AppConstants.communityBaseUrl] / [AppConstants.communityHosts]) and can
  /// no longer be replaced by remote config (AR-009, CS-28). Kept only so the
  /// community providers keep compiling.
  String? get communityBaseUrl => null;

  /// Verified VP pack prices per country (`vpPrices`: ISO 3166-1 alpha-2 →
  /// `{currency, packs: [{vp, price}], source, updated}`) for the local
  /// price estimates; a country without a verified table shows none.
  final VpPriceCatalog vpPrices;

  bool flag(String name, {bool fallback = false}) => flags[name] ?? fallback;

  /// [other]'s non-null values win.
  RemoteConfig merge(RemoteConfig other) => RemoteConfig(
    flags: {...flags, ...other.flags},
    webViewUserAgent: other.webViewUserAgent ?? webViewUserAgent,
    apiUserAgent: other.apiUserAgent ?? apiUserAgent,
    clientVersionOverride: other.clientVersionOverride ?? clientVersionOverride,
    vpPrices: vpPrices.merge(other.vpPrices),
  );

  JsonMap toJson() => {
    'schema': schema,
    'flags': flags,
    'webViewUserAgent': webViewUserAgent,
    'apiUserAgent': apiUserAgent,
    'clientVersionOverride': clientVersionOverride,
    'vpPrices': vpPrices.toJson(),
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

/// Largest remote-config document accepted (bytes of text).
const kRemoteConfigMaxBytes = 256 * 1024;

/// Checks a remote-config document and returns the sanitised JSON that may be
/// stored and applied, or `null` when it must be ignored:
///
/// - it must be a JSON object with `"schema": 1` (a different or missing
///   schema is a document this app cannot vouch for);
/// - only the known fields survive, each validated by [RemoteConfig.fromJson]
///   (flags, User-Agents, client version, VP prices); anything else, including
///   the removed `communityBaseUrl`, is dropped.
JsonMap? sanitizeRemoteConfig(Object? json) {
  final m = asMap(json);
  if (m == null || asInt(m['schema']) != RemoteConfig.schema) return null;
  return RemoteConfig.fromJson(m).toJson();
}

/// Loads the bundled config merged with the last fetched remote copy.
///
/// The fetched copy is validated before it is stored ([sanitizeRemoteConfig]);
/// the stored copy is validated again at load. When it is unusable the
/// last-known-good copy (the last one that loaded fine) is used, then the
/// bundled defaults.
class RemoteConfigLoader {
  RemoteConfigLoader(
    this._prefs, {
    this._dio,
    this._url = AppConstants.remoteConfigUrl,
    this._log,
  });

  final Prefs _prefs;
  final Dio? _dio;
  final String _url;
  final SessionLog? _log;

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
    final cached = sanitizeRemoteConfig(_prefs.getJson(PrefKeys.remoteConfig));
    final lastGood = cached == null
        ? sanitizeRemoteConfig(_prefs.getJson(PrefKeys.remoteConfigLastGood))
        : null;
    final applied = cached ?? lastGood;
    if (applied != null) {
      config = config.merge(RemoteConfig.fromJson(applied));
      if (cached != null) {
        // This copy loaded fine: it is the new last known good.
        unawaited(
          _prefs
              .setJson(PrefKeys.remoteConfigLastGood, cached)
              .catchError((Object _) {}),
        );
      }
      _log?.add(
        'config.applied',
        detail: cached != null ? 'remote' : 'last_known_good',
      );
    } else if (_prefs.getString(PrefKeys.remoteConfig) != null) {
      _log?.add('config.rejected', detail: 'stored copy invalid');
    }
    return config;
  }

  /// Fetches the remote copy (if a URL is configured), validates it and
  /// caches it for the next launch. An invalid document is ignored and the
  /// previous copy stays. Never throws.
  Future<void> refresh() async {
    if (_url.isEmpty) return;
    try {
      final dio =
          _dio ?? Dio(BaseOptions(receiveTimeout: const Duration(seconds: 10)));
      final res = await dio.get<String>(
        _url,
        options: Options(responseType: ResponseType.plain),
      );
      final text = res.data;
      if (text == null || text.length > kRemoteConfigMaxBytes) {
        _log?.add('config.rejected', detail: 'size');
        return;
      }
      final clean = sanitizeRemoteConfig(tryDecodeJson(text));
      if (clean == null) {
        _log?.add('config.rejected', detail: 'schema');
        return;
      }
      await _prefs.setJson(PrefKeys.remoteConfig, clean);
    } on Object {
      // Remote config is optional.
    }
  }
}

/// Effective remote config. `main()` overrides it with the loaded value.
final remoteConfigProvider = Provider<RemoteConfig>(
  (ref) => RemoteConfig.defaults,
);
