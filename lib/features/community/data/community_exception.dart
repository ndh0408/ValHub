import 'dart:io' show HttpHeaders, SocketException;

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart' hide ErrorDescription;

import '../../../core/network/error_classifier.dart' show parseRetryAfter;
import '../../../core/l10n/community_error_strings.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/util/format.dart';
import '../../../core/util/json.dart';
import '../community_strings.dart';

/// Error of the community server (docs/community-api.md "Errors") or of the
/// transport to it. Riot errors met while signing in stay `RiotException`s.
class CommunityException implements Exception {
  const CommunityException(
    this.code, {
    this.status,
    this.retryAfter,
    this.serverMessage,
    this.reason,
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
    if (response == null) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => const CommunityException(timeout),
        DioExceptionType.cancel => const CommunityException(cancelled),
        _ when e.error is CommunityException => e.error! as CommunityException,
        _ when e.error is SocketException => const CommunityException(network),
        _ => const CommunityException(network),
      };
    }
    return fromResponse(
      response.statusCode ?? 0,
      response.data,
      retryAfterHeader: response.headers.value(HttpHeaders.retryAfterHeader),
    );
  }

  /// Error body `{"error": {"code", "message"}, "retryAfter"?}` (or HTML).
  static CommunityException fromResponse(
    int status,
    Object? body, {
    String? retryAfterHeader,
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
    );
  }

  @override
  String toString() => 'CommunityException($code, $status)';
}

/// Vietnamese copy for any error of the community feature: community
/// errors get their own messages, Riot errors (e.g. `NeedsLoginException`
/// while signing in) keep the app-wide ones.
ErrorDescription describeCommunityError(Object error) {
  if (error is! CommunityException) return describeError(error);
  final e = error;
  final reasonMessage =
      e.code == CommunityException.invalidInput || e.code == 'suspended'
      ? CommunityErrorStrings.forReason(e.reason)
      : null;
  if (reasonMessage != null) {
    return ErrorDescription(
      message: reasonMessage,
      icon: e.code == 'suspended'
          ? Icons.block_outlined
          : Icons.edit_note_outlined,
      canRetry: false,
    );
  }
  return switch (e.code) {
    CommunityException.network => const ErrorDescription(
      message: CommunityStrings.errorNetwork,
      icon: Icons.wifi_off_outlined,
    ),
    CommunityException.timeout => const ErrorDescription(
      message: CommunityStrings.errorTimeout,
      icon: Icons.wifi_off_outlined,
    ),
    CommunityException.rateLimited => ErrorDescription(
      title: CommunityStrings.rateLimitedTitle,
      message: e.retryAfter == null
          ? CommunityStrings.errorRateLimited
          : CommunityStrings.errorRateLimitedIn(
              formatDurationCoarse(e.retryAfter!),
            ),
      icon: Icons.hourglass_top_rounded,
    ),
    CommunityException.riotUnavailable => ErrorDescription(
      title: CommunityStrings.riotUnavailableTitle,
      message: e.retryAfter == null
          ? CommunityStrings.errorRiotUnavailable
          : CommunityStrings.errorRiotUnavailableIn(
              formatDurationCoarse(e.retryAfter!),
            ),
      icon: Icons.cloud_off_outlined,
    ),
    CommunityException.storageFull => const ErrorDescription(
      message: CommunityStrings.errorStorageFull,
      icon: Icons.cloud_off_outlined,
      canRetry: false,
    ),
    CommunityException.riotRejected => const ErrorDescription(
      message: CommunityStrings.errorRiotRejected,
      icon: Icons.verified_user_outlined,
    ),
    CommunityException.unauthorized => const ErrorDescription(
      message: CommunityStrings.errorUnauthorized,
      icon: Icons.lock_clock_outlined,
    ),
    CommunityException.forbidden => const ErrorDescription(
      message: CommunityStrings.errorForbidden,
      icon: Icons.block_outlined,
      canRetry: false,
    ),
    CommunityException.notFound => const ErrorDescription(
      message: CommunityStrings.errorNotFound,
      icon: Icons.search_off_outlined,
      canRetry: false,
    ),
    CommunityException.invalidInput => ErrorDescription(
      message: CommunityStrings.errorInvalid,
      icon: Icons.edit_note_outlined,
      canRetry: false,
    ),
    CommunityException.imageTooLarge => const ErrorDescription(
      message: CommunityStrings.errorImageTooLarge,
      icon: Icons.photo_size_select_large_outlined,
      canRetry: false,
    ),
    CommunityException.imageType => const ErrorDescription(
      message: CommunityStrings.errorImageType,
      icon: Icons.image_not_supported_outlined,
      canRetry: false,
    ),
    CommunityException.consentRequired => const ErrorDescription(
      message: CommunityStrings.errorConsent,
      icon: Icons.verified_user_outlined,
      canRetry: false,
    ),
    CommunityException.disabled => const ErrorDescription(
      message: CommunityStrings.unavailableBody,
      icon: Icons.cloud_off_outlined,
      canRetry: false,
    ),
    'suspended' => const ErrorDescription(
      message: CommunityStrings.errorForbidden,
      icon: Icons.block_outlined,
      canRetry: false,
    ),
    'server_busy' => ErrorDescription(
      message: e.retryAfter == null
          ? CommunityStrings.errorServer
          : CommunityStrings.errorRateLimitedIn(
              formatDurationCoarse(e.retryAfter!),
            ),
      icon: Icons.cloud_off_outlined,
    ),
    _ => const ErrorDescription(
      message: CommunityStrings.errorServer,
      icon: Icons.cloud_off_outlined,
    ),
  };
}
