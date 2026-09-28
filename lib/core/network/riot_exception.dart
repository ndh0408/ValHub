/// Typed errors for every Riot / valorant-api call (SUMMARY §11).
///
/// Core APIs (PvpApi, SessionManager, ContentRepository) only ever throw
/// [RiotException] subtypes, so UI code can `switch` exhaustively.
library;

sealed class RiotException implements Exception {
  const RiotException();

  /// Whether retrying the same call later may succeed.
  bool get isRetryable => false;
}

/// The account's cookies are dead: only an interactive login in the WebView
/// can fix it. Never retry automatically.
final class NeedsLoginException extends RiotException {
  const NeedsLoginException({this.puuid, this.reason});

  /// The account that needs to log in again (null when unknown).
  final String? puuid;

  /// Short, token-free reason for the session log.
  final String? reason;

  @override
  String toString() => 'NeedsLoginException(${reason ?? ''})';
}

/// Network error, timeout, Cloudflare HTML 403, 429 or 5xx. Keep the session
/// and show cached data; retry after [retryAfter] when present.
final class TransientException extends RiotException {
  const TransientException({this.retryAfter, this.status, this.reason});

  final Duration? retryAfter;
  final int? status;
  final String? reason;

  bool get isTimeout => reason == 'timeout';

  @override
  bool get isRetryable => true;

  @override
  String toString() =>
      'TransientException(status: $status, retryAfter: $retryAfter, $reason)';
}

/// `403 SCHEDULED_DOWNTIME` or active maintenance in the status JSON.
final class MaintenanceException extends RiotException {
  const MaintenanceException({this.message});

  /// Localised title from the status JSON when available.
  final String? message;

  @override
  String toString() => 'MaintenanceException';
}

/// `404` (e.g. `RESOURCE_NOT_FOUND`: not in pregame / core-game, match not
/// processed yet). Often a *state*, not an error (SUMMARY §11.5).
final class NotFoundException extends RiotException {
  const NotFoundException({this.errorCode});

  final String? errorCode;

  @override
  String toString() => 'NotFoundException($errorCode)';
}

/// Any other non-2xx answer with a Riot error body
/// (`{"httpStatus":400,"errorCode":"…","message":"…"}`).
final class RiotApiException extends RiotException {
  const RiotApiException(this.status, {this.errorCode, this.message});

  final int status;
  final String? errorCode;
  final String? message;

  @override
  String toString() => 'RiotApiException($status, $errorCode)';
}

/// Helpers for the "404 is a state" endpoints.
extension RiotNotFoundX<T> on Future<T> {
  /// Completes with `null` instead of throwing [NotFoundException].
  Future<T?> orNullIfNotFound() async {
    try {
      return await this;
    } on NotFoundException {
      return null;
    }
  }
}
