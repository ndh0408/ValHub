import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/features/skin_detail/providers/skin_availability.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import '../store/store_test_harness.dart';

const _friend = Account(
  puuid: '11111111-1111-1111-1111-111111111111',
  gameName: 'Bạn Thân',
  tagLine: 'VN9',
  region: 'ap',
  shard: 'ap',
);

const _other = Account(
  puuid: '22222222-2222-2222-2222-222222222222',
  gameName: 'Người Khác',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
);

void main() {
  final db = economyContent();
  final store = Storefront.fromJson(
    economyFixture('storefront.json'),
    receivedAt: t0,
  );

  group('storefrontSellsSkin', () {
    test('daily shop, Night Market and bundles while they last', () {
      expect(
        storefrontSellsSkin(store, db.skin(Fx.aresPrism)!, t0),
        isTrue,
        reason: 'daily',
      );
      expect(
        storefrontSellsSkin(store, db.skin(Fx.reaverVandal)!, t0),
        isTrue,
        reason: 'Night Market',
      );
      expect(
        storefrontSellsSkin(store, db.skin(Fx.odinNeoFrontier)!, t0),
        isTrue,
        reason: 'bundle',
      );
      expect(storefrontSellsSkin(store, db.skin(Fx.vandalCafe)!, t0), isFalse);
    });

    test('expired sections no longer count', () {
      final afterDaily = t0.add(const Duration(hours: 5));
      expect(
        storefrontSellsSkin(store, db.skin(Fx.aresPrism)!, afterDaily),
        isFalse,
      );
      expect(
        storefrontSellsSkin(store, db.skin(Fx.reaverVandal)!, afterDaily),
        isTrue,
      );
      final afterAll = t0.add(const Duration(days: 30));
      expect(
        storefrontSellsSkin(store, db.skin(Fx.reaverVandal)!, afterAll),
        isFalse,
      );
      expect(
        storefrontSellsSkin(store, db.skin(Fx.odinNeoFrontier)!, afterAll),
        isFalse,
      );
    });
  });

  group('skinAvailableElsewhereProvider', () {
    late MockPvpApi api;

    Future<List<Account>> run(String skinUuid, MemoryJsonCache cache) async {
      final prefs = await createTestPrefs();
      api = fixtureApi();
      final c = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: storeOverrides(
          api: api,
          prefs: prefs,
          cache: cache,
          accounts: const [testAccount, _friend, _other],
        ),
      );
      await c.read(contentProvider.future);
      return readListened(c, skinAvailableElsewhereProvider(skinUuid).future);
    }

    test('lists other accounts whose saved store sells the skin', () async {
      final cache = MemoryJsonCache();
      await cache.write(
        JsonFileCache.accountKey(_friend.puuid, 'economy_storefront'),
        economyFixture('storefront.json'),
        savedAt: t0,
      );
      // The active account's own store is ignored.
      await cache.write(
        JsonFileCache.accountKey(testAccount.puuid, 'economy_storefront'),
        economyFixture('storefront.json'),
        savedAt: t0,
      );

      final byLevel = await run(Fx.reaverL1, cache);
      expect(byLevel.map((a) => a.puuid), [_friend.puuid]);
      expect(await run(Fx.vandalCafe, cache), isEmpty);
    });

    test('a stale saved store does not count', () async {
      final cache = MemoryJsonCache();
      await cache.write(
        JsonFileCache.accountKey(_friend.puuid, 'economy_storefront'),
        economyFixture('storefront.json'),
        savedAt: t0.subtract(const Duration(days: 30)),
      );
      expect(await run(Fx.reaverVandal, cache), isEmpty);
    });

    test('no saved stores: nothing, and no Riot call', () async {
      expect(await run(Fx.reaverVandal, MemoryJsonCache()), isEmpty);
      verifyNever(() => api.storefront(any()));
    });
  });
}
