import 'package:flutter_test/flutter_test.dart';
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
}
