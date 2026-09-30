import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/reauth_cooldown.dart';
import 'package:valvn/core/util/clock.dart';

void main() {
  late FixedClock clock;
  late ReauthCooldown cooldown;

  setUp(() {
    clock = FixedClock(DateTime(2026, 9, 30, 12));
    cooldown = ReauthCooldown(clock: clock, jitter: () => 0);
  });

  test('no failure, no cooldown', () {
    expect(cooldown.remaining('a'), isNull);
    expect(cooldown.failures('a'), 0);
  });

  test('30 s, 1 min, 2 min, 4 min, 8 min, then 10 min', () {
    final applied = [
      for (var i = 0; i < 8; i++) cooldown.failed('a').inSeconds,
    ];
    expect(applied, [30, 60, 120, 240, 480, 600, 600, 600]);
    expect(cooldown.failures('a'), 8);
  });

  test('the remaining time counts down and ends', () {
    cooldown.failed('a');
    expect(cooldown.remaining('a'), const Duration(seconds: 30));
    clock.advance(const Duration(seconds: 12));
    expect(cooldown.remaining('a'), const Duration(seconds: 18));
    clock.advance(const Duration(seconds: 18));
    expect(cooldown.remaining('a'), isNull);
  });

  test('Retry-After replaces the exponential delay (capped at an hour)', () {
    expect(
      cooldown.failed('a', retryAfter: const Duration(seconds: 5)),
      const Duration(seconds: 5),
    );
    expect(
      cooldown.failed('a', retryAfter: const Duration(days: 2)),
      const Duration(hours: 1),
    );
  });

  test('a success clears the state', () {
    cooldown
      ..failed('a')
      ..failed('a')
      ..clear('a');
    expect(cooldown.remaining('a'), isNull);
    expect(cooldown.failed('a'), const Duration(seconds: 30));
  });

  test('a long quiet spell forgets the earlier failures', () {
    cooldown
      ..failed('a')
      ..failed('a');
    clock.advance(const Duration(hours: 1));
    expect(cooldown.failed('a'), const Duration(seconds: 30));
  });

  test('accounts are independent', () {
    cooldown.failed('a');
    expect(cooldown.remaining('b'), isNull);
  });

  test('jitter only stretches the delay, never past the cap', () {
    final jittery = ReauthCooldown(clock: clock, jitter: () => 1);
    expect(jittery.failed('a'), const Duration(seconds: 33));
    for (var i = 0; i < 12; i++) {
      jittery.failed('a');
    }
    expect(jittery.failed('a'), const Duration(minutes: 10));
  });

  test('defer waits without counting a failure and never shortens', () {
    cooldown.defer('a', const Duration(seconds: 45));
    expect(cooldown.remaining('a'), const Duration(seconds: 45));
    expect(cooldown.failures('a'), 0);
    cooldown.defer('a', const Duration(seconds: 10));
    expect(cooldown.remaining('a'), const Duration(seconds: 45));
    cooldown.defer('a', const Duration(seconds: 90));
    expect(cooldown.remaining('a'), const Duration(seconds: 90));
  });
}
