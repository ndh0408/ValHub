import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of "now". Inject it instead of calling `DateTime.now()` so that
/// countdowns, caches and token expiry are testable.
class Clock {
  const Clock();

  /// Current local time.
  DateTime now() => DateTime.now();

  /// Current UTC time.
  DateTime nowUtc() => now().toUtc();
}

/// A clock frozen at [time] (advance it with [advance]); for tests.
class FixedClock extends Clock {
  FixedClock(this.time);

  DateTime time;

  @override
  DateTime now() => time;

  void advance(Duration d) => time = time.add(d);
}

/// The app clock. Override in tests with `clockProvider.overrideWithValue(...)`.
final clockProvider = Provider<Clock>((ref) => const Clock());
