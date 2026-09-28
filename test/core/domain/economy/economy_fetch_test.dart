import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/economy_fetch.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/util/clock.dart';

void main() {
  group('runPooled', () {
    test('keeps input order and bounds concurrency', () async {
      var inFlight = 0;
      var peak = 0;
      final out = await runPooled<int, int>(List.generate(10, (i) => i), (
        i,
      ) async {
        inFlight++;
        peak = inFlight > peak ? inFlight : peak;
        await Future<void>.delayed(Duration(milliseconds: 10 - i));
        inFlight--;
        return i * 2;
      }, concurrency: 3);
      expect(out, [for (var i = 0; i < 10; i++) i * 2]);
      expect(peak, 3);
    });

    test('empty input', () async {
      expect(await runPooled<int, int>(const [], (i) async => i), isEmpty);
    });

    test('rethrows needs-login first, stops starting new tasks', () async {
      final started = <int>[];
      await expectLater(
        runPooled<int, int>(List.generate(9, (i) => i), (i) async {
          started.add(i);
          await Future<void>.delayed(const Duration(milliseconds: 1));
          if (i == 0) throw const TransientException(status: 503);
          if (i == 1) throw const NeedsLoginException();
          return i;
        }, concurrency: 2),
        throwsA(isA<NeedsLoginException>()),
      );
      expect(started, [0, 1]);
    });

    test('maintenance beats other errors; else first by input order', () async {
      await expectLater(
        runPooled<int, int>([0, 1], (i) async {
          if (i == 0) throw const NotFoundException();
          throw const MaintenanceException();
        }),
        throwsA(isA<MaintenanceException>()),
      );
      await expectLater(
        runPooled<int, int>([0, 1], (i) async {
          await Future<void>.delayed(Duration(milliseconds: i == 0 ? 5 : 0));
          throw StateError('task $i');
        }),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'task 0'),
        ),
      );
    });
  });

  group('awaitBoth', () {
    test('returns both values', () async {
      expect(await awaitBoth(Future.value(1), Future.value('a')), (1, 'a'));
    });

    test('rethrows the error unwrapped, even from the second future', () async {
      await expectLater(
        awaitBoth(
          Future<int>.delayed(const Duration(milliseconds: 5), () => 1),
          Future<int>.error(const TransientException(status: 500)),
        ),
        throwsA(isA<TransientException>()),
      );
    });
  });

  test('offlineRetryDelay clamps Retry-After to 30 s … 10 min', () {
    expect(offlineRetryDelay(const TransientException()), kOfflineRetryDelay);
    expect(
      offlineRetryDelay(
        const TransientException(retryAfter: Duration(seconds: 2)),
      ),
      const Duration(seconds: 30),
    );
    expect(
      offlineRetryDelay(
        const TransientException(retryAfter: Duration(hours: 1)),
      ),
      const Duration(minutes: 10),
    );
    expect(
      offlineRetryDelay(
        const TransientException(retryAfter: Duration(minutes: 2)),
      ),
      const Duration(minutes: 2),
    );
  });

  group('fetchWithOfflineCache', () {
    late Directory tmp;
    setUp(() async => tmp = await Directory.systemTemp.createTemp('valvn_fx'));
    tearDown(() => tmp.delete(recursive: true));

    ProviderContainer container(DateTime now) => ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        jsonFileCacheProvider.overrideWithValue(JsonFileCache(() async => tmp)),
        clockProvider.overrideWithValue(FixedClock(now)),
      ],
    );

    FutureProvider<FetchedJson> provider(Future<Object?> Function() fetch) =>
        FutureProvider<FetchedJson>(
          (ref) => fetchWithOfflineCache(
            ref,
            puuid: 'PUUID-A',
            name: 'thing',
            fetch: fetch,
          ),
        );

    test(
      'stores live data per account, serves it after a transient error',
      () async {
        final t1 = DateTime(2026, 9, 28, 10);
        final live = await container(t1)
            .read(provider(() async => {'a': 1}).future);
        expect(live.isFromCache, isFalse);
        expect(live.receivedAt, t1);
        expect(
          File('${tmp.path}/acct/puuid-a/economy_thing.json').existsSync(),
          isTrue,
        );

        const error = TransientException(status: 503);
        final cached = await container(DateTime(2026, 9, 28, 11))
            .read(provider(() async => throw error).future);
        expect(cached.isFromCache, isTrue);
        expect(cached.cachedAfter, same(error));
        expect(cached.data, {'a': 1});
        expect(cached.receivedAt, t1);
      },
    );

    test('no copy → rethrows; other errors never use the cache', () async {
      final now = DateTime(2026, 9, 28);
      await expectLater(
        container(
          now,
        ).read(provider(() async => throw const TransientException()).future),
        throwsA(isA<TransientException>()),
      );
      await container(now).read(provider(() async => {'a': 1}).future);
      await expectLater(
        container(
          now,
        ).read(provider(() async => throw const NeedsLoginException()).future),
        throwsA(isA<NeedsLoginException>()),
      );
    });
  });

  group('scheduleProviderRefresh', () {
    test('keeps the value, then refetches while listened', () async {
      var builds = 0;
      final p = FutureProvider.autoDispose<int>((ref) async {
        builds++;
        final now = DateTime.now();
        scheduleProviderRefresh(
          ref,
          now.add(const Duration(milliseconds: 20)),
          now: now,
          grace: const Duration(milliseconds: 1),
          minDelay: Duration.zero,
        );
        return builds;
      });
      final c = ProviderContainer.test();
      final sub = c.listen(p, (_, _) {});
      await c.read(p.future);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(builds, greaterThanOrEqualTo(2));
      sub.close();
    });

    test('keeps an unlistened value alive until the deadline', () async {
      var builds = 0;
      var disposed = 0;
      final p = FutureProvider.autoDispose<int>((ref) async {
        builds++;
        ref.onDispose(() => disposed++);
        final now = DateTime.now();
        scheduleProviderRefresh(
          ref,
          now.add(const Duration(milliseconds: 40)),
          now: now,
          refetch: false,
          grace: Duration.zero,
          minDelay: Duration.zero,
        );
        return builds;
      });
      final c = ProviderContainer.test();
      final sub = c.listen(p.future, (_, _) {});
      expect(await c.read(p.future), 1);
      sub.close();
      // Still cached after the listener is gone …
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(disposed, 0);
      // … and disposed once the deadline passes.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(disposed, 1);
      expect(builds, 1);
    });

    testWidgets('never refetches sooner than the minimum delay', (
      tester,
    ) async {
      var builds = 0;
      final p = FutureProvider.autoDispose<int>((ref) async {
        builds++;
        final now = DateTime.now();
        scheduleProviderRefresh(ref, now, now: now);
        return builds;
      });
      final c = ProviderContainer.test();
      final sub = c.listen(p, (_, _) {});
      await tester.pump();
      await tester.pump(kMinRefreshDelay - const Duration(seconds: 1));
      expect(builds, 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(builds, 2);
      sub.close();
      c.dispose();
    });

    test('null deadline keeps nothing alive', () async {
      var disposed = 0;
      final p = FutureProvider.autoDispose<int>((ref) async {
        ref.onDispose(() => disposed++);
        scheduleProviderRefresh(ref, null, now: DateTime.now());
        return 1;
      });
      final c = ProviderContainer.test();
      final sub = c.listen(p.future, (_, _) {});
      expect(await c.read(p.future), 1);
      sub.close();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(disposed, 1);
    });
  });
}
