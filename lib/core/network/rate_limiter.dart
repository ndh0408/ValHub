import 'dart:async';
import 'dart:math' as math;

/// Thrown by [HostRateLimiter.acquire] when the caller gave up waiting
/// (`cancelled` completed). Nothing was taken, so nothing must be released.
class LimiterCancelled implements Exception {
  const LimiterCancelled();

  @override
  String toString() => 'LimiterCancelled';
}

/// Per-host token bucket + concurrency cap + back-off (SUMMARY U17, §10, §11).
///
/// Defaults: bursts of 8, refilling 2 requests/s, at most 3 requests in
/// flight per host. Mutations may use the [acquire] `priority` lane: they do
/// not queue behind reads for a token and get one extra in-flight slot.
///
/// A host that answers with `429` / a Cloudflare page / repeated `5xx` is
/// **penalised** ([penalize]): every caller stops for a cooldown that doubles
/// on each consecutive strike (30 s → 10 min, with jitter) unless the server
/// sent a `Retry-After`, which always wins. A success ([recordSuccess]) resets
/// the strikes.
class HostRateLimiter {
  HostRateLimiter({
    this.burst = 8,
    this.refillPerSecond = 2.0,
    this.maxConcurrent = 3,
    DateTime Function()? now,
    Future<void> Function(Duration)? delay,
    double Function()? jitter,
  }) : _now = now ?? DateTime.now,
       _delay = delay ?? Future<void>.delayed,
       _jitter = jitter ?? _defaultJitter;

  /// First cooldown of a penalised host (doubles per strike).
  static const baseCooldown = Duration(seconds: 30);

  /// Longest computed cooldown (SUMMARY §11.3).
  static const maxCooldown = Duration(minutes: 10);

  /// Longest `Retry-After` honoured (a day-long value would freeze the app).
  static const maxRetryAfter = Duration(hours: 1);

  /// Strikes are forgotten after this long without a new penalty.
  static const strikeMemory = Duration(minutes: 30);

  /// Two `5xx` within this window count as "repeated".
  static const serverErrorWindow = Duration(minutes: 2);

  static double _defaultJitter() => _random.nextDouble();
  static final math.Random _random = math.Random();

  final int burst;
  final double refillPerSecond;
  final int maxConcurrent;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;
  final double Function() _jitter;
  final Map<String, _Bucket> _buckets = {};

  _Bucket _bucket(String host) =>
      _buckets.putIfAbsent(host, () => _Bucket(burst.toDouble(), _now()));

  /// Waits until a request to [host] may start. Pair every call with
  /// [release].
  ///
  /// - [cancelled]: completes when the caller no longer wants the slot; the
  ///   wait ends at once with [LimiterCancelled].
  /// - [priority]: the priority lane (mutations); still blocked by a cooldown.
  Future<void> acquire(
    String host, {
    Future<Object?>? cancelled,
    bool priority = false,
  }) async {
    final bucket = _bucket(host);
    var giveUp = false;
    Future<void>? signal;
    if (cancelled != null) {
      signal = cancelled.then<void>(
        (_) {
          giveUp = true;
        },
        onError: (Object _) {
          giveUp = true;
        },
      );
    }
    while (true) {
      if (giveUp) throw const LimiterCancelled();
      final wait = _tryTake(bucket, priority);
      if (wait == null) return;
      final sleeping = _delay(wait);
      await (signal == null ? sleeping : Future.any([sleeping, signal]));
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
    return d.isNegative || d == Duration.zero ? null : d;
  }

  /// The host answered with a block (429, Cloudflare, repeated 5xx): every
  /// caller stops for the returned cooldown.
  ///
  /// [retryAfter] (the header) wins over the computed back-off; otherwise the
  /// cooldown is [base] doubled per consecutive strike, capped at [cap], and
  /// stretched by up to 25 % of random jitter so accounts do not all come back
  /// in the same second.
  Duration penalize(
    String host, {
    Duration? retryAfter,
    Duration base = baseCooldown,
    Duration cap = maxCooldown,
  }) {
    final bucket = _bucket(host);
    final now = _now();
    final last = bucket.lastStrikeAt;
    if (last != null && now.difference(last) > strikeMemory) {
      bucket.strikes = 0;
    }
    bucket.strikes++;
    bucket.lastStrikeAt = now;
    final Duration applied;
    if (retryAfter != null) {
      applied = retryAfter > maxRetryAfter ? maxRetryAfter : retryAfter;
    } else {
      final exponent = math.min(bucket.strikes - 1, 20);
      final raw = base.inMilliseconds * (1 << exponent);
      final stretched = (raw * (1 + 0.25 * _jitter().clamp(0.0, 1.0))).round();
      applied = Duration(milliseconds: math.min(stretched, cap.inMilliseconds));
    }
    cooldown(host, applied);
    return applied;
  }

  /// A `5xx` from [host]. Returns the cooldown when this is a repeat within
  /// [serverErrorWindow] (then the host is penalised), else `null`.
  Duration? recordServerError(String host, {Duration? retryAfter}) {
    final bucket = _bucket(host);
    final now = _now();
    bucket.serverErrors
      ..removeWhere((t) => now.difference(t) > serverErrorWindow)
      ..add(now);
    if (bucket.serverErrors.length < 2 && retryAfter == null) return null;
    return penalize(host, retryAfter: retryAfter);
  }

  /// A request to [host] succeeded: forgets its strikes and 5xx history (an
  /// active cooldown keeps running).
  void recordSuccess(String host) {
    final bucket = _buckets[host];
    if (bucket == null) return;
    bucket.strikes = 0;
    bucket.serverErrors.clear();
  }

  /// Returns `null` when a slot was taken, else how long to wait.
  Duration? _tryTake(_Bucket b, bool priority) {
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
    final limit = maxConcurrent + (priority ? 1 : 0);
    if (b.inFlight >= limit) return const Duration(milliseconds: 50);
    if (b.tokens >= 1) {
      b.tokens -= 1;
      b.inFlight++;
      return null;
    }
    if (priority) {
      // Mutations never queue for a token: they borrow one (the reads that
      // follow wait a little longer to pay it back).
      b.tokens = math.max(b.tokens - 1, -burst.toDouble());
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
  int strikes = 0;
  DateTime? lastStrikeAt;
  final List<DateTime> serverErrors = [];
}
