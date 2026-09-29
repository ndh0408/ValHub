import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/app_constants.dart';
import '../network/error_classifier.dart';
import '../util/json.dart';
import 'auth_callback.dart';
import 'cookie_jar.dart';

/// Outcome of a silent re-auth attempt (SUMMARY §3.4). Every outcome carries
/// the jar **after** merging `Set-Cookie`, which the caller must persist.
sealed class ReauthOutcome {
  const ReauthOutcome(this.jar);
  final RiotCookieJar jar;
}

final class ReauthOk extends ReauthOutcome {
  const ReauthOk(this.tokens, super.jar);
  final AuthTokens tokens;
}

/// Cookies are dead; only an interactive login helps.
final class ReauthNeedsLogin extends ReauthOutcome {
  const ReauthNeedsLogin(this.reason, super.jar);
  final String reason;
}

/// Cloudflare / 429 / 5xx / timeout / unexplained answer. Keep the session.
final class ReauthTransient extends ReauthOutcome {
  const ReauthTransient(this.reason, super.jar, {this.retryAfter, this.status});
  final String reason;
  final Duration? retryAfter;
  final int? status;
}

/// Pure classification result used by both re-auth calls.
sealed class ReauthVerdict {
  const ReauthVerdict();
}

final class VerdictOk extends ReauthVerdict {
  const VerdictOk(this.tokens);
  final AuthTokens tokens;
}

final class VerdictNeedsLogin extends ReauthVerdict {
  const VerdictNeedsLogin(this.reason);
  final String reason;
}

final class VerdictTransient extends ReauthVerdict {
  const VerdictTransient(this.reason, {this.retryAfter, this.status});
  final String reason;
  final Duration? retryAfter;
  final int? status;
}

/// No token and no clear "dead session" signal: try the fallback call.
final class VerdictUnknown extends ReauthVerdict {
  const VerdictUnknown(this.reason);
  final String reason;
}

ReauthVerdict? _transientFor(
  int status,
  Object? body,
  String? contentType,
  String? retryAfterHeader,
  DateTime now,
) {
  final retryAfter = parseRetryAfter(retryAfterHeader, now: now);
  if (status == 429) {
    return VerdictTransient(
      'rate_limited',
      retryAfter: retryAfter,
      status: 429,
    );
  }
  if (status >= 500) {
    return VerdictTransient('server', retryAfter: retryAfter, status: status);
  }
  if (status == 403 && looksLikeHtml(body, contentType: contentType)) {
    return VerdictTransient('cloudflare', retryAfter: retryAfter, status: 403);
  }
  return null;
}

/// OAuth errors that really mean "the cookies no longer log in" (SUMMARY
/// §3.4). Anything else (`server_error`, `temporarily_unavailable`,
/// `rate_limited`…) is a Riot-side hiccup and must not mark the account.
const _loginErrors = {
  'login_required',
  'interaction_required',
  'consent_required',
  'account_selection_required',
};

bool _isLoginError(String? error, [String? description]) {
  if (error != null && _loginErrors.contains(error.toLowerCase())) return true;
  return description != null &&
      description.toLowerCase().contains('login_required');
}

/// Verdict for a callback-shaped URL (`…/opt_in#access_token=…` or `#error=…`).
ReauthVerdict _verdictForCallbackUri(Uri uri, DateTime receivedAt) {
  final params = parseCallbackParams(uri);
  final error = params['error'];
  if (error != null) {
    final code = error.firstOrNull;
    final description = params['error_description']?.firstOrNull;
    if (_isLoginError(code, description)) {
      return VerdictNeedsLogin(description ?? code ?? 'error');
    }
    return VerdictUnknown('callback_error_${code ?? 'unknown'}');
  }
  final tokens = AuthTokens.fromParams(params, receivedAt: receivedAt);
  if (tokens != null) return VerdictOk(tokens);
  return const VerdictUnknown('callback_without_token');
}

/// Classifies `GET /authorize?…&prompt=none` (redirects NOT followed).
///
/// - 3xx → `…/opt_in#access_token=…` = ok
/// - 3xx → `…#error=interaction_required…login_required` = needsLogin
/// - 3xx → absolute `https://authenticate.riotgames.com/login?…` = needsLogin
/// - HTML 403 / 429 / 5xx = transient
/// - anything else = unknown (→ fallback POST)
ReauthVerdict classifyAuthorizeResponse({
  required int status,
  String? location,
  Object? body,
  String? contentType,
  String? retryAfterHeader,
  required DateTime receivedAt,
}) {
  final transient = _transientFor(
    status,
    body,
    contentType,
    retryAfterHeader,
    receivedAt,
  );
  if (transient != null) return transient;
  if (status >= 300 && status < 400) {
    if (location == null || location.isEmpty) {
      return VerdictUnknown('redirect_without_location_$status');
    }
    final uri = Uri.tryParse(location);
    if (uri == null) return const VerdictUnknown('bad_location');
    // Relative redirects resolve against auth.riotgames.com.
    final absolute = uri.hasScheme
        ? uri
        : Uri.parse(AuthConstants.authorizeUrl).resolveUri(uri);
    if (isCallbackLocation(absolute)) {
      return _verdictForCallbackUri(absolute, receivedAt);
    }
    final host = absolute.host.toLowerCase();
    if (host == 'authenticate.riotgames.com' ||
        absolute.path.toLowerCase().startsWith('/login')) {
      return const VerdictNeedsLogin('login_redirect');
    }
    return VerdictUnknown('redirect_$host');
  }
  return VerdictUnknown('http_$status');
}

/// Classifies `POST /api/v1/authorization` with the cookie jar (fallback).
///
/// - `{"type":"response","response":{"parameters":{"uri":"…#access_token=…"}}}` = ok
/// - `{"type":"auth"}` / `{"type":"multifactor"}` = needsLogin
ReauthVerdict classifyAuthorizationResponse({
  required int status,
  Object? body,
  String? contentType,
  String? retryAfterHeader,
  required DateTime receivedAt,
}) {
  final transient = _transientFor(
    status,
    body,
    contentType,
    retryAfterHeader,
    receivedAt,
  );
  if (transient != null) return transient;
  final json = asMap(body) ?? asMap(tryDecodeJson(asString(body)));
  if (json == null) return VerdictUnknown('non_json_$status');
  final type = asString(json['type']);
  if (type == 'auth' || type == 'multifactor') return VerdictNeedsLogin(type!);
  if (type == 'response') {
    final uriString = asString(pick(json, ['response', 'parameters', 'uri']));
    final uri = uriString == null ? null : Uri.tryParse(uriString);
    if (uri != null) return _verdictForCallbackUri(uri, receivedAt);
    return const VerdictUnknown('response_without_uri');
  }
  final error = asString(json['error']);
  if (error != null) {
    if (_isLoginError(error, asString(json['error_description']))) {
      return VerdictNeedsLogin(error);
    }
    return VerdictUnknown('error_$error');
  }
  return VerdictUnknown('type_${type ?? 'null'}');
}

/// Silent re-auth against `auth.riotgames.com` using an account's cookie jar.
///
/// Primary: `GET /authorize?…&prompt=none` (no redirects). Fallback:
/// `POST /api/v1/authorization`. The username/password `PUT` is never used.
class RiotReauthClient {
  RiotReauthClient({
    Dio? dio,
    required this._userAgent,
    DateTime Function()? now,
  }) : _dio = dio ?? createAuthDio(),
       _now = now ?? DateTime.now;

  final Dio _dio;
  final String Function() _userAgent;
  final DateTime Function() _now;

  /// A dio that returns every status (we classify it) and never follows
  /// redirects (we need the 303 `Location`).
  static Dio createAuthDio() => Dio(
    BaseOptions(
      followRedirects: false,
      maxRedirects: 0,
      validateStatus: (s) => s != null,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.plain,
    ),
  );

  /// Runs the re-auth sequence. Never throws.
  Future<ReauthOutcome> reauth(
    RiotCookieJar jar, {
    bool postFirst = false,
  }) async {
    if (jar.isEmpty || !jar.has(AuthConstants.sessionCookie)) {
      return ReauthNeedsLogin('no_session_cookie', jar);
    }
    var current = jar;
    final calls = postFirst ? [_post, _get] : [_get, _post];
    String lastReason = 'unknown';
    for (final call in calls) {
      final (verdict, merged) = await call(current);
      current = merged;
      switch (verdict) {
        case VerdictOk(:final tokens):
          return ReauthOk(tokens, current);
        case VerdictNeedsLogin(:final reason):
          return ReauthNeedsLogin(reason, current);
        case VerdictTransient(:final reason, :final retryAfter, :final status):
          return ReauthTransient(
            reason,
            current,
            retryAfter: retryAfter,
            status: status,
          );
        case VerdictUnknown(:final reason):
          lastReason = reason;
          continue;
      }
    }
    return ReauthTransient(lastReason, current);
  }

  Future<(ReauthVerdict, RiotCookieJar)> _get(RiotCookieJar jar) async {
    try {
      final res = await _dio.get<String>(
        reauthAuthorizeUrl,
        options: Options(
          headers: {'Cookie': jar.header, 'User-Agent': _userAgent()},
        ),
      );
      final merged = jar.merge(res.headers['set-cookie'], now: _now());
      return (
        classifyAuthorizeResponse(
          status: res.statusCode ?? 0,
          location: res.headers.value('location'),
          body: res.data,
          contentType: res.headers.value(Headers.contentTypeHeader),
          retryAfterHeader: res.headers.value('retry-after'),
          receivedAt: _now(),
        ),
        merged,
      );
    } on DioException catch (e) {
      return (_networkVerdict(e), jar);
    }
  }

  Future<(ReauthVerdict, RiotCookieJar)> _post(RiotCookieJar jar) async {
    try {
      final res = await _dio.post<String>(
        AuthConstants.authorizationApiUrl,
        data: jsonEncode({
          'client_id': AuthConstants.clientId,
          'nonce': AuthConstants.reauthNonce,
          'redirect_uri': AuthConstants.redirectUri,
          'response_type': AuthConstants.responseType,
          'scope': AuthConstants.scope,
        }),
        options: Options(
          headers: {
            'Cookie': jar.header,
            'User-Agent': _userAgent(),
            Headers.contentTypeHeader: Headers.jsonContentType,
          },
        ),
      );
      final merged = jar.merge(res.headers['set-cookie'], now: _now());
      return (
        classifyAuthorizationResponse(
          status: res.statusCode ?? 0,
          body: res.data,
          contentType: res.headers.value(Headers.contentTypeHeader),
          retryAfterHeader: res.headers.value('retry-after'),
          receivedAt: _now(),
        ),
        merged,
      );
    } on DioException catch (e) {
      return (_networkVerdict(e), jar);
    }
  }

  static ReauthVerdict _networkVerdict(DioException e) =>
      VerdictTransient(switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout => 'timeout',
        _ => 'network',
      });
}
