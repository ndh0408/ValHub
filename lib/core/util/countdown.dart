/// Countdown helpers (SUMMARY §9.1).
///
/// Riot returns remaining durations (`*RemainingDurationInSeconds`,
/// `RemainingLifetimeSeconds`). Convert them to absolute instants once, at
/// the time the response was received, and derive every countdown from that.
library;

import 'json.dart';

/// `expiresAt = receivedAt + seconds`. Returns `null` when [seconds] is not a
/// finite number.
DateTime? expiresAtFrom(Object? seconds, DateTime receivedAt) {
  final s = asNum(seconds);
  if (s == null || !s.isFinite) return null;
  return receivedAt.add(Duration(milliseconds: (s * 1000).round()));
}

/// Time left until [expiresAt], never negative.
Duration remainingUntil(DateTime expiresAt, DateTime now) {
  final d = expiresAt.difference(now);
  return d.isNegative ? Duration.zero : d;
}

/// An absolute deadline derived from a server-provided remaining duration.
class Deadline {
  const Deadline(this.expiresAt);

  /// Builds a deadline from a Riot `…Seconds` field. Returns `null` when the
  /// field is missing or not numeric.
  static Deadline? fromSeconds(
    Object? seconds, {
    required DateTime receivedAt,
  }) {
    final at = expiresAtFrom(seconds, receivedAt);
    return at == null ? null : Deadline(at);
  }

  final DateTime expiresAt;

  Duration remaining(DateTime now) => remainingUntil(expiresAt, now);

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  @override
  bool operator ==(Object other) =>
      other is Deadline && other.expiresAt == expiresAt;

  @override
  int get hashCode => expiresAt.hashCode;

  @override
  String toString() => 'Deadline($expiresAt)';
}

/// The earliest of [deadlines] (ignoring nulls), e.g. to know when a
/// storefront must be refetched.
DateTime? earliest(Iterable<DateTime?> deadlines) {
  DateTime? best;
  for (final d in deadlines) {
    if (d != null && (best == null || d.isBefore(best))) best = d;
  }
  return best;
}
