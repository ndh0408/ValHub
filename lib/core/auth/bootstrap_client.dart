import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../network/auth_traffic.dart';
import '../network/error_classifier.dart';
import '../network/rate_limiter.dart';
import '../network/riot_exception.dart';
import '../util/json.dart';

/// `GET /userinfo` subset.
@immutable
class RiotUserInfo {
  const RiotUserInfo({
    required this.puuid,
    this.gameName,
    this.tagLine,
    this.country,
  });

  static RiotUserInfo? fromJson(Object? json) {
    final m = asMap(json);
    final puuid = lowerUuid(m?['sub']);
    if (m == null || puuid == null) return null;
    final acct = asMap(m['acct']);
    return RiotUserInfo(
      puuid: puuid,
      gameName: asNonEmptyString(acct?['game_name']),
      tagLine: asNonEmptyString(acct?['tag_line']),
      country: asNonEmptyString(m['country']),
    );
  }

  final String puuid;
  final String? gameName;
  final String? tagLine;
  final String? country;
}

/// Picks `affinities.live` from a riot-geo response.
String? regionFromGeo(Object? json) =>
    asNonEmptyString(pick(json, ['affinities', 'live']))?.toLowerCase();

/// Bootstrap calls after login and after every re-auth (SUMMARY §3.3 a–c).
/// Throws [RiotException] subtypes only.
///
/// Calls go through the shared auth [HostRateLimiter] (`createAuthLimiter`),
/// and fail at once with a `cooldown` [TransientException] while their host
/// is cooling down after a block.
class RiotBootstrapClient {
  RiotBootstrapClient({
    Dio? dio,
    required this._userAgent,
    HostRateLimiter? limiter,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: AppConstants.networkTimeout,
               receiveTimeout: AppConstants.networkTimeout,
               sendTimeout: AppConstants.networkTimeout,
             ),
           ),
       _limiter = limiter ?? createAuthLimiter();

  final Dio _dio;
  final String Function() _userAgent;
  final HostRateLimiter _limiter;

  Map<String, String> _bearer(String accessToken) => {
    'Authorization': 'Bearer $accessToken',
    'User-Agent': _userAgent(),
  };

  /// (a) `POST entitlements.auth.riotgames.com/api/token/v1` body `{}`.
  Future<String> fetchEntitlementsToken(String accessToken) async {
    final data = await _call(
      AuthConstants.entitlementsUrl,
      () => _dio.post<Object?>(
        AuthConstants.entitlementsUrl,
        data: const <String, dynamic>{},
        options: Options(
          headers: _bearer(accessToken),
          contentType: Headers.jsonContentType,
        ),
      ),
    );
    final token = asNonEmptyString(asMap(data)?['entitlements_token']);
    if (token == null) {
      throw const TransientException(reason: 'no_entitlements_token');
    }
    return token;
  }

  /// (b) `GET auth.riotgames.com/userinfo`.
  Future<RiotUserInfo> fetchUserInfo(String accessToken) async {
    final data = await _call(
      AuthConstants.userInfoUrl,
      () => _dio.get<Object?>(
        AuthConstants.userInfoUrl,
        options: Options(headers: _bearer(accessToken)),
      ),
    );
    final info =
        RiotUserInfo.fromJson(data ?? const <String, dynamic>{}) ??
        RiotUserInfo.fromJson(tryDecodeJson(asString(data)));
    if (info == null) throw const TransientException(reason: 'bad_userinfo');
    return info;
  }

  /// (c) `PUT riot-geo…/pas/v1/product/valorant` body `{"id_token":…}` →
  /// `affinities.live`.
  Future<String> fetchRegion(String accessToken, String idToken) async {
    final data = await _call(
      AuthConstants.riotGeoUrl,
      () => _dio.put<Object?>(
        AuthConstants.riotGeoUrl,
        data: {'id_token': idToken},
        options: Options(
          headers: _bearer(accessToken),
          contentType: Headers.jsonContentType,
        ),
      ),
    );
    final region =
        regionFromGeo(data) ?? regionFromGeo(tryDecodeJson(asString(data)));
    if (region == null) throw const TransientException(reason: 'no_region');
    return region;
  }

  Future<Object?> _call(
    String url,
    Future<Response<Object?>> Function() request,
  ) async {
    final host = Uri.parse(url).host;
    final blocked = _limiter.cooldownRemaining(host);
    if (blocked != null) {
      throw TransientException(retryAfter: blocked, reason: 'cooldown');
    }
    await _limiter.acquire(host);
    try {
      final res = await request();
      learnFromAuthAnswer(_limiter, host);
      return res.data;
    } on Object catch (e) {
      final error = classifyError(e);
      // A 401 here means the fresh token was rejected: treat as transient
      // (the session layer decides whether the account needs a login).
      if (error is NeedsLoginException) {
        throw const TransientException(status: 401, reason: 'bootstrap_401');
      }
      if (error is TransientException) {
        learnFromAuthFailure(_limiter, host, error);
      }
      throw error;
    } finally {
      _limiter.release(host);
    }
  }
}
