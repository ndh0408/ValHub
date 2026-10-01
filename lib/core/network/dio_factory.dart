import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../auth/session_manager.dart';
import '../config/app_constants.dart';
import '../logging/session_log.dart';
import 'error_classifier.dart';
import 'riot_exception.dart';

/// `RequestOptions.extra` keys understood by ValVN interceptors.
abstract final class RequestExtras {
  /// PUUID whose session headers must be attached (PD / GLZ / shared).
  static const puuid = 'valvn.puuid';

  /// Set on the single retry after a re-auth, to prevent loops.
  static const authRetried = 'valvn.authRetried';

  /// Request start time (session log).
  static const startedAt = 'valvn.startedAt';
}

/// Base dio: 30 s timeouts (A9), gzip, optional UA. JSON bodies are decoded
/// by dio; non-JSON error bodies (Cloudflare HTML) arrive as strings.
Dio createBaseDio({
  String? userAgent,
  Duration timeout = AppConstants.networkTimeout,
  SessionLog? log,
}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {'Accept-Encoding': 'gzip', 'User-Agent': ?userAgent},
    ),
  );
  // First in the chain: a request that would leak the Riot token never leaves.
  dio.interceptors.add(TokenEgressGuard());
  if (log != null) dio.interceptors.add(SessionLogInterceptor(log));
  return dio;
}

/// Refuses to send a Riot **access token** anywhere but the pinned community
/// host (CLAUDE.md: the token goes only to `POST /v1/auth/riot` of the ValVN
/// community server; AR-009). A request counts as carrying the token when it is
/// the community sign-in path or its small JSON body has an `accessToken` key.
/// The base URL is a compile-time constant already; this guard makes the rule
/// hold even if a future change (a config, a provider override) points the
/// transport somewhere else.
class TokenEgressGuard extends Interceptor {
  TokenEgressGuard({bool Function(String host)? isAllowedHost})
    : _isAllowedHost = isAllowedHost ?? AppConstants.isCommunityHost;

  final bool Function(String host) _isAllowedHost;

  /// Path of the community sign-in that legitimately carries the token.
  static const signInPath = '/v1/auth/riot';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final hasToken = carriesAccessToken(options);
    if (hasToken) {
      // Native HTTP redirects bypass Dio's interceptor chain; a 307/308
      // could otherwise forward this body to a host outside the allow-list.
      options.followRedirects = false;
      options.maxRedirects = 0;
    }
    if (hasToken &&
        (options.uri.scheme != 'https' ||
            options.uri.port != 443 ||
            options.uri.userInfo.isNotEmpty ||
            !_isAllowedHost(options.uri.host))) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: const TransientException(reason: 'blocked_host'),
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }

  /// Whether [options] would send a Riot access token.
  @visibleForTesting
  static bool carriesAccessToken(RequestOptions options) {
    if (options.uri.path.endsWith(signInPath)) return true;
    final data = options.data;
    if (data is Map) return data.containsKey('accessToken');
    if (data is String && data.length <= 4096) return _tokenKey.hasMatch(data);
    return false;
  }

  /// `"accessToken":` as a JSON key (a user's text mentioning the word is
  /// escaped inside a string and never matches).
  static final RegExp _tokenKey = RegExp(r'"accessToken"\s*:');
}

/// Dio for PD / GLZ / shared: session log + [RiotAuthInterceptor].
Dio createPvpDio({required SessionManager sessions, SessionLog? log}) {
  final dio = createBaseDio(log: log);
  dio.interceptors.add(RiotAuthInterceptor(sessions, dio));
  return dio;
}

/// Records `{method, host+path template, status, ms}` for every request.
/// Never logs headers, bodies or query values (see [SessionLog.scrubUri]).
class SessionLogInterceptor extends Interceptor {
  SessionLogInterceptor(this._log);

  final SessionLog _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[RequestExtras.startedAt] = DateTime.now();
    handler.next(options);
  }

  Duration? _elapsed(RequestOptions o) {
    final started = o.extra[RequestExtras.startedAt];
    return started is DateTime ? DateTime.now().difference(started) : null;
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final o = response.requestOptions;
    _log.http(
      o.method,
      o.uri,
      status: response.statusCode,
      elapsed: _elapsed(o),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    _log.http(
      o.method,
      o.uri,
      status: err.response?.statusCode ?? -1,
      elapsed: _elapsed(o),
    );
    handler.next(err);
  }
}

/// Adds the account's game headers and, on `401` or `400 BAD_CLAIMS`,
/// triggers a single-flight re-auth and retries once (SUMMARY §3.4, §11.2).
///
/// Requests opt in by setting `extra[RequestExtras.puuid]`.
class RiotAuthInterceptor extends Interceptor {
  RiotAuthInterceptor(this._sessions, this._dio);

  final SessionManager _sessions;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final puuid = options.extra[RequestExtras.puuid];
    // The retry after a re-auth already carries the refreshed headers.
    if (puuid is! String || options.extra[RequestExtras.authRetried] == true) {
      return handler.next(options);
    }
    try {
      final session = await _sessions.session(puuid);
      options.headers.addAll(session.gameHeaders);
      handler.next(options);
    } on Object catch (e) {
      handler.reject(
        DioException(requestOptions: options, error: classifyError(e)),
      );
    }
  }

  /// Tokens whose name-service 403 survived a re-auth + retry: further
  /// name-service 403s with them do not trigger another re-auth.
  final Set<String> _nameServiceRejected = {};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final puuid = options.extra[RequestExtras.puuid];
    final response = err.response;
    final status = response?.statusCode;
    final contentType = response?.headers.value(Headers.contentTypeHeader);
    if (puuid is String &&
        options.extra[RequestExtras.authRetried] != true &&
        isClientVersionRejection(status, response?.data)) {
      // The client version is out of date: re-read /v1/version and repeat the
      // call once with the fresh header (no re-auth involved).
      try {
        if (await _sessions.noteVersionRejected()) {
          final session = await _sessions.session(puuid);
          options.extra[RequestExtras.authRetried] = true;
          options.headers.addAll(session.gameHeaders);
          return handler.resolve(await _dio.fetch<dynamic>(options));
        }
      } on DioException catch (e) {
        return handler.next(e);
      } on Object {
        // Could not refresh: the original error stands.
      }
      return handler.next(err);
    }
    final nameService = isNameServiceAuthFailure(
      status,
      response?.data,
      path: options.uri.path,
      contentType: contentType,
    );
    if (puuid is! String ||
        options.extra[RequestExtras.authRetried] == true ||
        !(nameService || isAuthFailure(status, response?.data))) {
      return handler.next(err);
    }
    final failedToken = _bearer(options.headers['Authorization']);
    if (nameService &&
        failedToken != null &&
        _nameServiceRejected.contains(failedToken)) {
      return handler.next(err);
    }
    try {
      final session = await _sessions.refreshAfterAuthFailure(
        puuid,
        failedAccessToken: failedToken ?? '',
      );
      options.extra[RequestExtras.authRetried] = true;
      options.headers.addAll(session.gameHeaders);
      try {
        final retried = await _dio.fetch<dynamic>(options);
        handler.resolve(retried);
      } on DioException catch (e) {
        await _afterFailedRetry(puuid, session.accessToken, e, nameService);
        handler.next(e);
      }
    } on DioException catch (e) {
      handler.next(e);
    } on Object catch (e) {
      final error = e is RiotException ? e : classifyError(e);
      handler.next(
        DioException(requestOptions: options, error: error, response: response),
      );
    }
  }

  /// The retry with fresh tokens failed too (SUMMARY §11.2: otherwise
  /// needsLogin). Stops the next request from re-authing in a loop.
  Future<void> _afterFailedRetry(
    String puuid,
    String token,
    DioException e,
    bool nameService,
  ) async {
    final res = e.response;
    try {
      if (isAuthFailure(res?.statusCode, res?.data)) {
        await _sessions.reportAuthFailureAfterReauth(puuid, accessToken: token);
      } else if (nameService &&
          isNameServiceAuthFailure(
            res?.statusCode,
            res?.data,
            path: e.requestOptions.uri.path,
            contentType: res?.headers.value(Headers.contentTypeHeader),
          )) {
        if (_nameServiceRejected.length > 32) _nameServiceRejected.clear();
        _nameServiceRejected.add(token);
      }
    } on Object {
      // Best effort: the original error is still reported to the caller.
    }
  }

  static String? _bearer(Object? header) {
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring(7);
  }
}
