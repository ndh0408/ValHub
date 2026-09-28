import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/domain/economy/prices.dart';
import 'package:valvn/core/domain/economy/storefront.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import '../../../helpers/test_prefs.dart';
import 'economy_fixtures.dart';

class MockPvpApi extends Mock implements PvpApi {}

/// In-memory [JsonFileCache] (no dart:io, so it also works in fake time).
class MemoryJsonCache extends JsonFileCache {
  MemoryJsonCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime.now());
}

void main() {
  final t0 = DateTime(2026, 9, 28, 12);
  late MockPvpApi api;
  late Prefs prefs;
  late MemoryJsonCache cache;

  setUp(() async {
    api = MockPvpApi();
    prefs = await createTestPrefs();
    cache = MemoryJsonCache();
  });

  ProviderContainer container({Clock? clock}) => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      pvpApiProvider.overrideWithValue(api),
      prefsProvider.overrideWithValue(prefs),
      accountProvider.overrideWith((ref, puuid) => null),
      jsonFileCacheProvider.overrideWithValue(cache),
      clockProvider.overrideWithValue(clock ?? FixedClock(t0)),
    ],
  );

  group('storefrontProvider', () {
    test('parses P-1 and records full prices for the price chain', () async {
      when(() => api.storefront(Fx.puuid))
          .thenAnswer((_) async => economyFixture('storefront.json'));
      final c = container();
      final store = await readListened(c, storefrontProvider(Fx.puuid).future);
      expect(store.receivedAt, t0);
      expect(store.isFromCache, isFalse);
      expect(store.daily.offers, hasLength(4));
      expect(c.read(observedPricesProvider)[Fx.reaverL1], 1775);
      expect(
        ObservedPriceStore(prefs).read()[Fx.odinNeoFrontierL1],
        2175,
        reason: 'persisted in prefs',
      );
      expect(
        cache.entries.keys,
        contains(JsonFileCache.accountKey(Fx.puuid, 'economy_storefront')),
      );
    });

    test('transient failure: offline copy, no price recording', () async {
      await cache.write(
        JsonFileCache.accountKey(Fx.puuid, 'economy_storefront'),
        economyFixture('storefront.json'),
        savedAt: t0.subtract(const Duration(hours: 1)),
      );
      when(() => api.storefront(Fx.puuid))
          .thenThrow(const TransientException(status: 503));
      final c = container();
      final store = await readListened(c, storefrontProvider(Fx.puuid).future);
      expect(store.isFromCache, isTrue);
      expect(store.receivedAt, t0.subtract(const Duration(hours: 1)));
      expect(
        store.daily.expiresAt,
        t0
            .subtract(const Duration(hours: 1))
            .add(const Duration(seconds: 17401)),
      );
      expect(c.read(observedPricesProvider), isEmpty);
    });

    test('needs-login propagates (never hidden by the cache)', () async {
      await cache.write(
        JsonFileCache.accountKey(Fx.puuid, 'economy_storefront'),
        economyFixture('storefront.json'),
      );
      when(() => api.storefront(Fx.puuid))
          .thenThrow(const NeedsLoginException());
      final c = container();
      await expectLater(
        readListened(c, storefrontProvider(Fx.puuid).future),
        throwsA(isA<NeedsLoginException>()),
      );
    });

    testWidgets('refetches when the earliest countdown expires', (
      tester,
    ) async {
      final clock = FixedClock(t0);
      var calls = 0;
      when(() => api.storefront(Fx.puuid)).thenAnswer((_) async {
        calls++;
        final json = economyFixture('storefront.json');
        // Make the daily reset the earliest deadline: 60 s.
        asMap(
          json['SkinsPanelLayout'],
        )!['SingleItemOffersRemainingDurationInSeconds'] = 60;
        return json;
      });
      final c = container(clock: clock);
      final sub = c.listen(storefrontProvider(Fx.puuid), (_, _) {});
      await tester.pump();
      expect(calls, 1);
      expect(
        c.read(storefrontProvider(Fx.puuid)).value?.daily.offers,
        hasLength(4),
      );

      await tester.pump(const Duration(seconds: 30));
      expect(calls, 1);

      clock.advance(const Duration(seconds: 64));
      await tester.pump(const Duration(seconds: 34));
      await tester.pump();
      expect(calls, 2);
      sub.close();
      c.dispose();
    });
  });

  testWidgets('offline copy is retried after ~60 s', (tester) async {
    await cache.write(
      JsonFileCache.accountKey(Fx.puuid, 'economy_storefront'),
      economyFixture('storefront.json'),
      savedAt: t0,
    );
    var fail = true;
    when(() => api.storefront(Fx.puuid)).thenAnswer((_) async {
      if (fail) throw const TransientException(status: 503);
      return economyFixture('storefront.json');
    });
    final c = container();
    final sub = c.listen(storefrontProvider(Fx.puuid), (_, _) {});
    await tester.pump();
    expect(c.read(storefrontProvider(Fx.puuid)).value?.isFromCache, isTrue);
    fail = false;
    await tester.pump(const Duration(seconds: 64));
    await tester.pump();
    expect(c.read(storefrontProvider(Fx.puuid)).value?.isFromCache, isFalse);
    sub.close();
    c.dispose();
  });

  group('walletProvider', () {
    test('parses balances and keeps an offline copy', () async {
      when(() => api.wallet(Fx.puuid))
          .thenAnswer((_) async => economyFixture('wallet.json'));
      final c1 = container();
      final wallet = await readListened(c1, walletProvider(Fx.puuid).future);
      expect((wallet.vp, wallet.kc, wallet.rp), (1450, 11200, 60));
      c1.dispose();

      when(() => api.wallet(Fx.puuid))
          .thenThrow(const TransientException(status: 429));
      final c2 = container();
      final cached = await readListened(c2, walletProvider(Fx.puuid).future);
      expect(cached.isFromCache, isTrue);
      expect(cached.vp, 1450);
    });

    testWidgets('refreshes after the 5-minute TTL while listened', (
      tester,
    ) async {
      var calls = 0;
      when(() => api.wallet(Fx.puuid)).thenAnswer((_) async {
        calls++;
        return economyFixture('wallet.json');
      });
      final c = container();
      final sub = c.listen(walletProvider(Fx.puuid), (_, _) {});
      await tester.pump();
      expect(calls, 1);
      await tester.pump(kWalletTtl + const Duration(seconds: 4));
      await tester.pump();
      expect(calls, 2);
      sub.close();
      c.dispose();
    });
  });
}
