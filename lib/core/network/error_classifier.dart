import 'dart:io' show HttpDate, HttpException;

import 'package:dio/dio.dart';

import '../util/json.dart';
import 'riot_exception.dart';

/// Parses a `Retry-After` header (delta-seconds or HTTP-date).
Duration? parseRetryAfter(String? header, {DateTime? now}) {
  if (header == null) return null;
  final value = header.trim();
  if (value.isEmpty) return null;
  final seconds = int.tryParse(value);
  if (seconds != null) {
    return seconds < 0 ? Duration.zero : Duration(seconds: seconds);
  }
  try {
    final at = HttpDate.parse(value);
    final diff = at.difference((now ?? DateTime.now()).toUtc());
    return diff.isNegative ? Duration.zero : diff;
  } on FormatException {
    return null;
  } on HttpException {
    return null;
  }
}

/// Exponential backoff (SUMMARY §11.3): 10 s → 20 s → 40 s … capped at
/// 10 min. [attempt] starts at 0.
Duration backoffDelay(
  int attempt, {
  Duration base = const Duration(seconds: 10),
  Duration cap = const Duration(minutes: 10),
}) {
  if (attempt < 0) attempt = 0;
  if (attempt > 20) return cap;
  final ms = base.inMilliseconds * (1 << attempt);
  return ms >= cap.inMilliseconds ? cap : Duration(milliseconds: ms);
}

/// True for a Cloudflare / HTML error page (never assume JSON, SUMMARY §11.1).
bool looksLikeHtml(Object? body, {String? contentType}) {
  if (contentType != null && contentType.toLowerCase().contains('text/html')) {
    return true;
  }
  if (body is String) {
    final head = body.trimLeft().toLowerCase();
    return head.startsWith('<!doctype html') ||
        head.startsWith('<html') ||
        head.contains('<title>just a moment');
  }
  return false;
}

/// Extracts `errorCode` from a Riot error body (map or JSON string).
String? riotErrorCode(Object? body) {
  final map = asMap(body) ?? asMap(tryDecodeJson(asString(body)));
  return asString(map?['errorCode']);
}

String? _riotMessage(Object? body) {
  final map = asMap(body) ?? asMap(tryDecodeJson(asString(body)));
  return asString(map?['message']);
}

/// True when a PD/GLZ/auth response means "token expired": `401`, or `400`
/// with `errorCode == BAD_CLAIMS` (SUMMARY §1 #4).
///
/// With the request [path], a `403` with a JSON body from `name-service` is a
/// re-auth trigger too (SUMMARY §3.4, U15); a Cloudflare HTML 403 and
/// `SCHEDULED_DOWNTIME` never are. Without [path] (e.g. [classifyHttpError])
/// only 401 / BAD_CLAIMS count, so a name-service 403 that survives the retry
/// stays a cosmetic [RiotApiException] and never marks the account.
bool isAuthFailure(
  int? status,
  Object? body, {
  String? path,
  String? contentType,
}) {
  if (status == 401) return true;
  if (status == 400) return riotErrorCode(body) == 'BAD_CLAIMS';
  return status == 403 &&
      isNameServiceAuthFailure(
        status,
        body,
        path: path,
        contentType: contentType,
      );
}

/// True when a `400` says the `X-Riot-ClientVersion` header is out of date
/// (the exact Riot error is UNVERIFIED, SUMMARY §13: an `errorCode` naming the
/// client version, or a message that does). A call refused like this is worth
/// exactly one repeat, after `/v1/version` was re-read.
bool isClientVersionRejection(int? status, Object? body) {
  if (status != 400) return false;
  final code = riotErrorCode(body)?.toUpperCase() ?? '';
  if (code.contains('CLIENT_VERSION')) return true;
  return (_riotMessage(body) ?? '').toLowerCase().contains('client version');
}

/// `403` + JSON body (not downtime) on a `/name-service/` path.
bool isNameServiceAuthFailure(
  int? status,
  Object? body, {
  String? path,
  String? contentType,
}) =>
    status == 403 &&
    path != null &&
    path.contains('/name-service/') &&
    body != null &&
    !looksLikeHtml(body, contentType: contentType) &&
    riotErrorCode(body) != 'SCHEDULED_DOWNTIME';

/// Maps an HTTP error response to a [RiotException] (SUMMARY §7.8, §11).
RiotException classifyHttpError({
  required int status,
  Object? body,
  String? contentType,
  String? retryAfterHeader,
  DateTime? now,
}) {
  final html = looksLikeHtml(body, contentType: contentType);
  final code = html ? null : riotErrorCode(body);
  final retryAfter = parseRetryAfter(retryAfterHeader, now: now);
  if (status == 403 && code == 'SCHEDULED_DOWNTIME') {
    return MaintenanceException(message: _riotMessage(body));
  }
  if (status == 429) {
    return TransientException(
      status: 429,
      retryAfter: retryAfter,
      reason: 'rate_limited',
    );
  }
  if (status >= 500) {
    return TransientException(
      status: status,
      retryAfter: retryAfter,
      reason: 'server',
    );
  }
  if (status == 403 && html) {
    return TransientException(
      status: 403,
      retryAfter: retryAfter,
      reason: 'cloudflare',
    );
  }
  if (isAuthFailure(status, body)) {
    return NeedsLoginException(reason: code ?? 'http_$status');
  }
  if (status == 404) return NotFoundException(errorCode: code);
  if (html) {
    return TransientException(
      status: status,
      retryAfter: retryAfter,
      reason: 'html',
    );
  }
  return RiotApiException(status, errorCode: code, message: _riotMessage(body));
}

/// Maps any error thrown by dio (or already a [RiotException]) to a
/// [RiotException].
RiotException classifyError(Object error, {DateTime? now}) {
  if (error is RiotException) return error;
  if (error is DioException) {
    final inner = error.error;
    if (inner is RiotException) return inner;
    final res = error.response;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TransientException(reason: 'timeout');
      case DioExceptionType.connectionError:
        return const TransientException(reason: 'network');
      case DioExceptionType.cancel:
        return const TransientException(reason: 'cancelled');
      case DioExceptionType.badCertificate:
        return const TransientException(reason: 'tls');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        if (res != null && res.statusCode != null) {
          return classifyHttpError(
            status: res.statusCode!,
            body: res.data,
            contentType: res.headers.value(Headers.contentTypeHeader),
            retryAfterHeader: res.headers.value('retry-after'),
            now: now,
          );
        }
        return const TransientException(reason: 'network');
    }
  }
  return TransientException(reason: error.runtimeType.toString());
}
