import 'package:dio/dio.dart';

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
  if (log != null) dio.interceptors.add(SessionLogInterceptor(log));
  return dio;
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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final puuid = options.extra[RequestExtras.puuid];
    final response = err.response;
    if (puuid is! String ||
        options.extra[RequestExtras.authRetried] == true ||
        !isAuthFailure(response?.statusCode, response?.data)) {
      return handler.next(err);
    }
    final failedToken = _bearer(options.headers['Authorization']);
    try {
      final session = await _sessions.refreshAfterAuthFailure(
        puuid,
        failedAccessToken: failedToken ?? '',
      );
      options.extra[RequestExtras.authRetried] = true;
      options.headers.addAll(session.gameHeaders);
      final retried = await _dio.fetch<dynamic>(options);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    } on Object catch (e) {
      final error = e is RiotException ? e : classifyError(e);
      handler.next(
        DioException(requestOptions: options, error: error, response: response),
      );
    }
  }

  static String? _bearer(Object? header) {
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring(7);
  }
}
