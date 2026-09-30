import 'dart:math' as math;

import '../util/clock.dart';

/// Per-account back-off of silent re-auth (SUMMARY §3.4: "back off 30 s →
/// 10 min, honouring `Retry-After`").
///
/// A failed re-auth (Cloudflare, 429, 5xx, timeout, bootstrap failure) starts a
/// cooldown: 30 s, then 1 min, 2 min, 4 min, 8 min, and 10 min from the sixth
/// consecutive failure on. A `Retry-After` from the server replaces the
/// computed delay. While it runs, [SessionManager.session] neither talks to
/// `auth.riotgames.com` nor takes the cross-isolate lock: it returns a
/// still-valid token or throws a `TransientException` carrying the remaining
/// time, so provider retries, polls and taps cannot pile requests onto a
/// host that is already pushing back.
///
/// Plain class (injected clock and jitter) so it is unit-testable.
class ReauthCooldown {
  ReauthCooldown({this._clock = const Clock(), double Function()? jitter})
    : _jitter = jitter ?? _defaultJitter;

  /// First cooldown after a failure (doubles per consecutive failure).
  static const base = Duration(seconds: 30);

  /// Longest computed cooldown.
  static const cap = Duration(minutes: 10);

  /// Longest `Retry-After` honoured.
  static const maxRetryAfter = Duration(hours: 1);

  /// The failure count restarts after this long without a failure.
  static const memory = Duration(minutes: 30);

  static double _defaultJitter() => _random.nextDouble();
  static final math.Random _random = math.Random();

  final Clock _clock;
  final double Function() _jitter;
  final Map<String, _Entry> _entries = {};

  /// Time left before [id] may talk to Riot again, or `null`.
  Duration? remaining(String id) {
    final entry = _entries[id];
    if (entry == null) return null;
    final left = entry.until.difference(_clock.now());
    return left > Duration.zero ? left : null;
  }

  /// Consecutive failures recorded for [id] (0 after a success).
  int failures(String id) => _entries[id]?.failures ?? 0;

  /// A re-auth of [id] failed: starts (or extends) its cooldown and returns
  /// the delay that was applied. [retryAfter] (the server's) wins over the
  /// exponential delay.
  Duration failed(String id, {Duration? retryAfter}) {
    final now = _clock.now();
    final previous = _entries[id];
    var count = previous?.failures ?? 0;
    if (previous != null && now.difference(previous.lastFailureAt) > memory) {
      count = 0;
    }
    count++;
    final Duration delay;
    if (retryAfter != null) {
      delay = retryAfter > maxRetryAfter ? maxRetryAfter : retryAfter;
    } else {
      final exponent = math.min(count - 1, 20);
      final raw = base.inMilliseconds * (1 << exponent);
      final stretched = (raw * (1 + 0.1 * _jitter().clamp(0.0, 1.0))).round();
      delay = Duration(milliseconds: math.min(stretched, cap.inMilliseconds));
    }
    _entries[id] = _Entry(
      failures: count,
      until: now.add(delay),
      lastFailureAt: now,
    );
    return delay;
  }

  /// [id] must wait [delay] without a new failure being counted (the host was
  /// already cooling down, so no request was sent). Never shortens a longer
  /// wait.
  void defer(String id, Duration delay) {
    final now = _clock.now();
    final until = now.add(delay > maxRetryAfter ? maxRetryAfter : delay);
    final previous = _entries[id];
    if (previous != null && previous.until.isAfter(until)) return;
    _entries[id] = _Entry(
      failures: previous?.failures ?? 0,
      until: until,
      lastFailureAt: previous?.lastFailureAt ?? now,
    );
  }

  /// A re-auth of [id] succeeded (or the user logged in again).
  void clear(String id) => _entries.remove(id);
}

class _Entry {
  const _Entry({
    required this.failures,
    required this.until,
    required this.lastFailureAt,
  });

  final int failures;
  final DateTime until;
  final DateTime lastFailureAt;
}
