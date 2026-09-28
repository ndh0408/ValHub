import 'dart:async';
import 'dart:math' as math;

/// Per-host token bucket + concurrency cap (SUMMARY U17, §10).
///
/// Defaults: bursts of 8, refilling 2 requests/s, at most 3 requests in
/// flight per host. A `429` puts the host into a cooldown ([cooldown]).
class HostRateLimiter {
  HostRateLimiter({
    this.burst = 8,
    this.refillPerSecond = 2.0,
    this.maxConcurrent = 3,
    DateTime Function()? now,
    Future<void> Function(Duration)? delay,
  }) : _now = now ?? DateTime.now,
       _delay = delay ?? Future<void>.delayed;

  final int burst;
  final double refillPerSecond;
  final int maxConcurrent;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;
  final Map<String, _Bucket> _buckets = {};

  _Bucket _bucket(String host) =>
      _buckets.putIfAbsent(host, () => _Bucket(burst.toDouble(), _now()));

  /// Waits until a request to [host] may start. Pair every call with
  /// [release].
  Future<void> acquire(String host) async {
    final bucket = _bucket(host);
    while (true) {
      final wait = _tryTake(bucket);
      if (wait == null) return;
      await _delay(wait);
    }
  }

  /// Marks a request to [host] as finished.
  void release(String host) {
    final bucket = _buckets[host];
    if (bucket != null && bucket.inFlight > 0) bucket.inFlight--;
  }

  /// Blocks new requests to [host] for [duration] (e.g. `Retry-After`).
  void cooldown(String host, Duration duration) {
    final bucket = _bucket(host);
    final until = _now().add(duration);
    if (bucket.cooldownUntil == null || until.isAfter(bucket.cooldownUntil!)) {
      bucket.cooldownUntil = until;
    }
  }

  /// Remaining cooldown for [host], or `null`.
  Duration? cooldownRemaining(String host) {
    final until = _buckets[host]?.cooldownUntil;
    if (until == null) return null;
    final d = until.difference(_now());
    return d.isNegative ? null : d;
  }

  /// Returns `null` when a slot was taken, else how long to wait.
  Duration? _tryTake(_Bucket b) {
    final now = _now();
    final cooldownUntil = b.cooldownUntil;
    if (cooldownUntil != null && now.isBefore(cooldownUntil)) {
      return cooldownUntil.difference(now);
    }
    final elapsed = now.difference(b.lastRefill).inMicroseconds / 1e6;
    if (elapsed > 0) {
      b.tokens = math.min(
        burst.toDouble(),
        b.tokens + elapsed * refillPerSecond,
      );
      b.lastRefill = now;
    }
    if (b.inFlight >= maxConcurrent) return const Duration(milliseconds: 50);
    if (b.tokens >= 1) {
      b.tokens -= 1;
      b.inFlight++;
      return null;
    }
    final missing = 1 - b.tokens;
    final ms = (missing / refillPerSecond * 1000).ceil();
    return Duration(milliseconds: math.max(ms, 10));
  }
}

class _Bucket {
  _Bucket(this.tokens, this.lastRefill);

  double tokens;
  DateTime lastRefill;
  int inFlight = 0;
  DateTime? cooldownUntil;
}
