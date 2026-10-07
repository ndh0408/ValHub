import 'dart:io' show HttpHeaders;

import 'package:dio/dio.dart';

import '../../../core/network/error_classifier.dart' show parseRetryAfter;
import '../../../core/util/json.dart';

/// Error of the community server (docs/community-api.md "Errors") or of the
/// transport to it. Riot errors met while signing in stay `RiotException`s.
class CommunityException implements Exception {
  const CommunityException(
    this.code, {
    this.status,
    this.retryAfter,
    this.serverMessage,
    this.reason,
    this.requestId,
  });

  static const unauthorized = 'unauthorized';
  static const forbidden = 'forbidden';
  static const notFound = 'not_found';
  static const invalidInput = 'invalid_input';
  static const rateLimited = 'rate_limited';
  static const riotRejected = 'riot_rejected';
  static const serverError = 'server_error';

  /// `503` on sign-in: Riot could not verify the token right now (rate
  /// limit, outage, challenge page). Not a refusal: the Riot token and the
  /// community session are untouched; retry after [retryAfter].
  static const riotUnavailable = 'riot_unavailable';

  /// `507`: the server's image storage is full (posting without images
  /// still works).
  static const storageFull = 'storage_full';
  static const network = 'network';
  static const timeout = 'timeout';
  static const cancelled = 'cancelled';
  static const badResponse = 'bad_response';
  static const disabled = 'disabled';

  /// The user has not agreed to share their Riot ID with the community
  /// server yet: no sign-in (and no Riot token upload) happens.
  static const consentRequired = 'consent_required';
  static const imageTooLarge = 'image_too_large';
  static const imageType = 'image_type';

  /// Server `error.code` (snake_case) or a transport code above.
  final String code;
  final int? status;
  final Duration? retryAfter;

  /// Kept for compatibility with older callers; never rendered in the UI.
  final String? serverMessage;

  /// Stable v3 reason. Unknown and legacy reasons use the app's fallback.
  final String? reason;

  /// Id of the failed request (`X-Request-Id`), as the server logged it.
  final String? requestId;

  bool get isAuthFailure => code == unauthorized || status == 401;

  bool get isRetryable =>
      code == network ||
      code == timeout ||
      code == serverError ||
      code == rateLimited ||
      code == riotUnavailable ||
      code == 'server_busy' ||
      code == badResponse;

  /// Maps a dio failure (or anything else) to a [CommunityException].
  static CommunityException fromDio(DioException e) {
    final response = e.response;
    final sent = asNonEmptyString(e.requestOptions.headers[_requestIdHeader]);
    if (response == null) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => CommunityException(
          timeout,
          requestId: sent,
        ),
        DioExceptionType.cancel => CommunityException(
          cancelled,
          requestId: sent,
        ),
        _ when e.error is CommunityException => e.error! as CommunityException,
        _ => CommunityException(network, requestId: sent),
      };
    }
    return fromResponse(
      response.statusCode ?? 0,
      response.data,
      retryAfterHeader: response.headers.value(HttpHeaders.retryAfterHeader),
      requestId: response.headers.value(_requestIdHeader) ?? sent,
    );
  }

  static const _requestIdHeader = 'X-Request-Id';

  /// Error body `{"error": {"code", "message"}, "retryAfter"?}` (or HTML).
  static CommunityException fromResponse(
    int status,
    Object? body, {
    String? retryAfterHeader,
    String? requestId,
  }) {
    final decoded = body is String ? tryDecodeJson(body) : body;
    final m = asMap(decoded);
    final error = asMap(m?['error']);
    final seconds = asNum(m?['retryAfter']) ?? asNum(error?['retryAfter']);
    final retryAfter = seconds != null && seconds > 0
        ? Duration(seconds: seconds.ceil())
        : parseRetryAfter(retryAfterHeader);
    final code =
        asNonEmptyString(error?['code']) ??
        switch (status) {
          401 => unauthorized,
          403 => forbidden,
          404 => notFound,
          400 || 413 || 415 || 422 => invalidInput,
          429 => rateLimited,
          507 => storageFull,
          _ => serverError,
        };
    return CommunityException(
      code,
      status: status,
      retryAfter: retryAfter,
      serverMessage: asNonEmptyString(error?['message']),
      reason: asNonEmptyString(error?['reason']),
      requestId: asNonEmptyString(error?['requestId']) ?? requestId,
    );
  }

  @override
  String toString() => 'CommunityException($code, $status)';
}
