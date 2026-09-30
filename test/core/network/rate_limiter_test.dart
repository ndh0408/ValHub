import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/network/async_semaphore.dart';
import 'package:valvn/core/network/rate_limiter.dart';

void main() {
  test('bursts, then waits for refill; cooldown blocks the host', () async {
    var now = DateTime(2026);
    final waits = <Duration>[];
    final limiter = HostRateLimiter(
      burst: 2,
      refillPerSecond: 1,
      maxConcurrent: 10,
      now: () => now,
      delay: (d) async {
        waits.add(d);
        now = now.add(d);
      },
    );
    await limiter.acquire('h');
    await limiter.acquire('h');
    expect(waits, isEmpty);
    await limiter.acquire('h');
    expect(waits.single, const Duration(seconds: 1));

    limiter.cooldown('h', const Duration(seconds: 30));
    expect(limiter.cooldownRemaining('h'), const Duration(seconds: 30));
    waits.clear();
    await limiter.acquire('h');
    expect(waits.first, const Duration(seconds: 30));
    expect(limiter.cooldownRemaining('other'), isNull);
  });

  test('concurrency cap waits for release', () async {
    var now = DateTime(2026);
    late HostRateLimiter limiter;
    var released = false;
    limiter = HostRateLimiter(
      burst: 10,
      maxConcurrent: 1,
      now: () => now,
      delay: (d) async {
        now = now.add(d);
        if (!released) {
          released = true;
          limiter.release('h');
        }
      },
    );
    await limiter.acquire('h');
    await limiter.acquire('h');
    expect(released, isTrue);
  });

  group('penalize (Cloudflare / repeated 5xx / 429)', () {
    late DateTime now;
    late HostRateLimiter limiter;

    setUp(() {
      now = DateTime(2026, 9, 30, 12);
      limiter = HostRateLimiter(now: () => now, jitter: () => 0);
    });

    test('doubles from 30 s and caps at 10 min', () {
      final applied = [
        for (var i = 0; i < 8; i++) limiter.penalize('h').inSeconds,
      ];
      expect(applied, [30, 60, 120, 240, 480, 600, 600, 600]);
      expect(limiter.cooldownRemaining('h'), const Duration(minutes: 10));
    });

    test('jitter only ever stretches, never past the cap', () {
      final jittery = HostRateLimiter(now: () => now, jitter: () => 1);
      expect(jittery.penalize('h'), const Duration(milliseconds: 37500));
      for (var i = 0; i < 10; i++) {
        jittery.penalize('h');
      }
      expect(jittery.penalize('h'), const Duration(minutes: 10));
    });

    test('Retry-After wins over the computed back-off', () {
      limiter.penalize('h'); // strike 1 = 30 s
      expect(
        limiter.penalize('h', retryAfter: const Duration(seconds: 7)),
        const Duration(seconds: 7),
      );
      // A day-long header never freezes the host for more than an hour.
      expect(
        limiter.penalize('h', retryAfter: const Duration(days: 1)),
        const Duration(hours: 1),
      );
    });

    test('a success resets the strikes; quiet time forgets them', () {
      limiter
        ..penalize('h')
        ..penalize('h')
        ..recordSuccess('h');
      expect(limiter.penalize('h'), const Duration(seconds: 30));
      limiter.penalize('h'); // 60 s
      now = now.add(const Duration(hours: 1));
      expect(limiter.penalize('h'), const Duration(seconds: 30));
    });

    test('a success keeps an active cooldown running', () {
      limiter
        ..penalize('h')
        ..recordSuccess('h');
      expect(limiter.cooldownRemaining('h'), const Duration(seconds: 30));
    });

    test('recordServerError: the second 5xx in two minutes penalises', () {
      expect(limiter.recordServerError('h'), isNull);
      now = now.add(const Duration(seconds: 30));
      expect(limiter.recordServerError('h'), const Duration(seconds: 30));
      expect(limiter.cooldownRemaining('h'), isNotNull);
    });

    test('recordServerError: old 5xx are forgotten', () {
      expect(limiter.recordServerError('h'), isNull);
      now = now.add(const Duration(minutes: 3));
      expect(limiter.recordServerError('h'), isNull);
    });

    test('recordServerError with Retry-After penalises at once', () {
      expect(
        limiter.recordServerError('h', retryAfter: const Duration(seconds: 12)),
        const Duration(seconds: 12),
      );
    });

    test('other hosts are unaffected', () {
      limiter.penalize('a');
      expect(limiter.cooldownRemaining('b'), isNull);
    });
  });

  group('acquire', () {
    test('a cancelled wait ends at once and takes no slot', () async {
      var now = DateTime(2026);
      final never = Completer<void>();
      final cancel = Completer<Object?>();
      final limiter = HostRateLimiter(
        burst: 1,
        refillPerSecond: 0.01,
        now: () => now,
        // Would sleep for 100 s: cancellation must not wait for it.
        delay: (d) => never.future,
      );
      await limiter.acquire('h'); // takes the only token
      limiter.release('h');
      final waiting = limiter.acquire('h', cancelled: cancel.future);
      final outcome = expectLater(waiting, throwsA(isA<LimiterCancelled>()));
      await Future<void>.delayed(Duration.zero);
      cancel.complete('stop');
      await outcome;
      now = now.add(const Duration(seconds: 200));
      // The slot was never taken, so a later caller is not blocked by it.
      await limiter.acquire('h');
    });

    test('priority requests do not queue for a token', () async {
      var now = DateTime(2026);
      final waits = <Duration>[];
      final limiter = HostRateLimiter(
        burst: 1,
        refillPerSecond: 1,
        maxConcurrent: 5,
        now: () => now,
        delay: (d) async {
          waits.add(d);
          now = now.add(d);
        },
      );
      await limiter.acquire('h');
      await limiter.acquire('h', priority: true);
      expect(waits, isEmpty);
      // The normal caller after it pays the token back.
      await limiter.acquire('h');
      expect(waits, isNotEmpty);
    });

    test('priority requests get one extra in-flight slot', () async {
      final now = DateTime(2026);
      final limiter = HostRateLimiter(
        burst: 10,
        maxConcurrent: 1,
        now: () => now,
        delay: (d) async => fail('must not wait: ${d.inMilliseconds} ms'),
      );
      await limiter.acquire('h');
      await limiter.acquire('h', priority: true);
    });

    test('a cooldown still blocks priority requests', () async {
      var now = DateTime(2026);
      final waits = <Duration>[];
      final limiter = HostRateLimiter(
        now: () => now,
        delay: (d) async {
          waits.add(d);
          now = now.add(d);
        },
      )..cooldown('h', const Duration(seconds: 5));
      await limiter.acquire('h', priority: true);
      expect(waits.first, const Duration(seconds: 5));
    });
  });

  group('AsyncSemaphore', () {
    test('never runs more than the permits at once, FIFO', () async {
      final gate = AsyncSemaphore(2);
      var running = 0;
      var peak = 0;
      final order = <int>[];
      final completers = [for (var i = 0; i < 5; i++) Completer<void>()];
      final futures = [
        for (var i = 0; i < 5; i++)
          gate.run(() async {
            order.add(i);
            running++;
            peak = running > peak ? running : peak;
            await completers[i].future;
            running--;
          }),
      ];
      await Future<void>.delayed(Duration.zero);
      expect(order, [0, 1]);
      expect(gate.waiting, 3);
      completers[0].complete();
      await Future<void>.delayed(Duration.zero);
      expect(order, [0, 1, 2]);
      for (final c in completers) {
        if (!c.isCompleted) c.complete();
        await Future<void>.delayed(Duration.zero);
      }
      await Future.wait(futures);
      expect(peak, 2);
      expect(order, [0, 1, 2, 3, 4]);
      expect(gate.running, 0);
      expect(gate.waiting, 0);
    });

    test('a failing body still releases its permit', () async {
      final gate = AsyncSemaphore(1);
      await expectLater(
        gate.run<void>(() async => throw StateError('boom')),
        throwsStateError,
      );
      expect(await gate.run(() async => 7), 7);
      expect(gate.running, 0);
    });
  });
}
