import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/background/background_tasks.dart';

void main() {
  test('a crashing keep-alive never skips the wishlist check', () async {
    var wishlistRan = false;
    final ok = await runPeriodicJob(
      keepAlive: () async => throw StateError('keystore'),
      wishlist: (_) async => wishlistRan = true,
    );
    expect(wishlistRan, isTrue);
    expect(ok, isTrue);
  });

  test('the wishlist step gets only what is left of one job budget', () async {
    var t = DateTime(2026);
    Duration? given;
    await runPeriodicJob(
      now: () => t,
      keepAlive: () async {
        t = t.add(const Duration(seconds: 15));
        return true;
      },
      wishlist: (budget) async {
        given = budget;
        return true;
      },
    );
    expect(given, kBackgroundJobBudget - const Duration(seconds: 15));
  });
}
