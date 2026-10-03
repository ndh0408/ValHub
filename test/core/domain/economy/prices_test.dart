import 'package:valvn/core/l10n/labels/economy_labels.dart';

import '../../../helpers/l10n.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/owned_items.dart';
import 'package:valvn/core/domain/economy/prices.dart';
import 'package:valvn/core/l10n/content_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';

import '../../../helpers/test_prefs.dart';
import 'economy_fixtures.dart';

class MockPvpApi extends Mock implements PvpApi {}

class _FixedActive extends ActivePuuidNotifier {
  @override
  String? build() => Fx.puuid;
}

final _t0 = DateTime(2026, 9, 28, 12);

OwnedItems _ownedFixture(ContentDb db) => OwnedItems.resolve(
  Entitlements.fromJson(
    economyFixture('entitlements_skin_levels.json'),
    receivedAt: _t0,
  ),
  db,
);

void main() {
  late ContentDb db;
  setUp(() => db = economyContent());

  group('PriceTable', () {
    test('parses a document defensively', () {
      final t = PriceTable.fromJson({
        'schema': 1,
        'updatedAt': '2026-09-28',
        'prices': {
          'AB': 2375,
          'cd': '1775',
          'neg': -5,
          'huge': 1e9,
          '_comment': 1,
          'text': 'no',
        },
        'tierPrices': {ContentTierIds.exclusive.toUpperCase(): 2375.0},
        'meleeMultiplier': 9,
      });
      expect(t.prices, {'ab': 2375, 'cd': 1775});
      expect(t.tierPrices, {ContentTierIds.exclusive: 2375});
      expect(t.meleeMultiplier, PriceTable.defaultMeleeMultiplier);
      expect(t.updatedAt, '2026-09-28');
      expect(PriceTable.fromJson('<html>').isEmpty, isTrue);
      expect(
        PriceTable.fromJson({'meleeMultiplier': 1.5}).meleeMultiplier,
        1.5,
      );
    });

    test('remote-config block: bare map or full document', () {
      expect(
        PriceTable.fromRemoteConfig({
          'flags': {'live_score': true},
          'prices': {'AA': 100},
        }).prices,
        {'aa': 100},
      );
      final full = PriceTable.fromRemoteConfig({
        'prices': {
          'prices': {'bb': 200},
          'meleeMultiplier': 1.5,
        },
      });
      expect(full.prices, {'bb': 200});
      expect(full.meleeMultiplier, 1.5);
      expect(
        PriceTable.fromRemoteConfig({'flags': <String, Object?>{}}).isEmpty,
        isTrue,
      );
      expect(PriceTable.fromRemoteConfig(null).isEmpty, isTrue);
    });

    test('merge: the other table wins entry by entry', () {
      const a = PriceTable(
        prices: {'x': 1, 'y': 2},
        tierPrices: {'t': 10},
        updatedAt: 'a',
      );
      const b = PriceTable(prices: {'y': 3}, meleeMultiplier: 1.5);
      final m = a.merge(b);
      expect(m.prices, {'x': 1, 'y': 3});
      expect(m.tierPrices, {'t': 10});
      expect(m.meleeMultiplier, 1.5);
      expect(m.updatedAt, 'a');
    });

    test('bundled assets/data/prices.json is valid and matches §7.3', () {
      final json = jsonDecode(
        File('assets/data/prices.json').readAsStringSync(),
      );
      final t = PriceTable.fromJson(json);
      expect((json as Map)['schema'], 1);
      for (final tier in ContentDb.empty().contentTiers) {
        expect(
          t.tierPrices[tier.uuid],
          tier.fallbackPrice,
          reason: tier.devName,
        );
      }
      expect(t.meleeMultiplier, 2);
    });
  });

  group('PriceService chain', () {
    test('Standard / Random favorite are not for sale', () {
      final s = PriceService(db: db);
      for (final id in [Fx.vandalStandard, Fx.randomFavorite]) {
        final q = s.priceForSkin(id);
        expect(q.source, PriceSource.notForSale);
        expect(q.vp, isNull);
        expect(q.caption(tl), ContentStrings.notForSale);
      }
    });

    test('tier fallback is an estimate; melee doubles', () {
      final s = PriceService(db: db);
      expect(
        s.priceForSkin(Fx.reaverVandal),
        const PriceQuote(
          vp: 1775,
          source: PriceSource.tierFallback,
          isEstimate: true,
        ),
      );
      expect(s.priceForSkin(Fx.aresSentinelsL1).vp, 2175);
      expect(s.priceForSkin(Fx.phantomTocChien).vp, 875);
      expect(s.priceForSkin(Fx.bulldogVoCucL1).vp, 1275);
      final melee = s.priceForSkin(Fx.daoReaver);
      expect(melee.vp, 4350);
      expect(melee.isEstimate, isTrue);
      expect(melee.caption(tl), isNull);
    });

    test('reward skins have a source label instead of a price', () {
      final s = PriceService(db: db);
      final bp = s.priceForSkin(Fx.vandalCafe);
      expect(bp.isReward, isTrue);
      expect(bp.vp, isNull);
      expect(bp.caption(tl), ContentStrings.rewardSourceBattlePass);
      expect(bp.reward?.level, 25);
      expect(
        s.priceForSkin(Fx.knifeCafeL1).caption(tl),
        ContentStrings.rewardSourceBattlePass,
      );
      expect(
        s.priceForSkin(Fx.ghostThinhLang).caption(tl),
        ContentStrings.rewardSourceAgent,
      );
    });

    test('exact prices win in order table > observed > offers', () {
      final s = PriceService(
        db: db,
        table: const PriceTable(prices: {Fx.reaverVandal: 1800}),
        observed: const {Fx.reaverL1: 1775, Fx.bulldogVoCucL1: 1275},
        offers: const {Fx.bulldogVoCucL1: 1300, Fx.phantomTocChienL1: 900},
      );
      expect(
        s.priceForSkin(Fx.reaverChroma2),
        const PriceQuote(vp: 1800, source: PriceSource.table),
      );
      expect(
        s.priceForSkin(Fx.bulldogVoCuc),
        const PriceQuote(vp: 1275, source: PriceSource.observed),
      );
      expect(
        s.priceForSkin(Fx.phantomTocChienChroma),
        const PriceQuote(vp: 900, source: PriceSource.offers),
      );
      expect(s.priceForSkin(Fx.aresPrismL1).source, PriceSource.tierFallback);
    });

    test('an exact price beats the reward label', () {
      final s = PriceService(db: db, observed: const {Fx.vandalCafeL1: 1275});
      expect(s.priceForSkin(Fx.vandalCafe).source, PriceSource.observed);
    });

    test('tier overrides and melee multiplier from the table', () {
      final s = PriceService(
        db: db,
        table: const PriceTable(
          tierPrices: {ContentTierIds.exclusive: 2375},
          meleeMultiplier: 1.5,
        ),
      );
      expect(s.priceForSkin(Fx.aresSentinels).vp, 2375);
      expect(s.priceForSkin(Fx.daoReaver).vp, 3563);
      expect(s.tierFallbackPrice(db.skin(Fx.reaverVandal)!), 1775);
    });

    test('unknown skins: exact map hit or unknown', () {
      final s = PriceService(db: db, observed: const {'zzz': 999});
      expect(s.priceForSkin('ZZZ').vp, 999);
      expect(s.priceForSkin('nope').source, PriceSource.unknown);
      final bare = PriceService(db: ContentDb.empty());
      expect(bare.priceForSkin(Fx.reaverVandal).source, PriceSource.unknown);
      expect(bare.priceForSkin(Fx.reaverVandal).caption(tl), isNull);
    });
  });

  group('collection value', () {
    test('owned skins: estimates counted, rewards excluded', () {
      final s = PriceService(db: db);
      final v = s.ownedCollectionValue(_ownedFixture(db));
      expect(v.totalVp, 1775 + 1275 + 4350);
      expect(v.pricedCount, 3);
      expect(v.estimatedCount, 3);
      expect(v.rewardCount, 2);
      expect(v.unpricedCount, 0);
      expect(v.skinCount, 5);
      expect(v.isEstimate, isTrue);

      final exact = PriceService(
        db: db,
        observed: const {
          Fx.reaverL1: 1775,
          Fx.bulldogVoCucL1: 1275,
          Fx.daoReaverL1: 3550,
        },
      ).ownedCollectionValue(_ownedFixture(db));
      expect(exact.totalVp, 1775 + 1275 + 3550);
      expect(exact.isEstimate, isFalse);
    });

    test('dedupes levels/chromas, skips Standard, counts unknowns', () {
      final v = PriceService(db: db).collectionValue([
        Fx.reaverL1,
        Fx.reaverVandal,
        Fx.reaverChroma2.toUpperCase(),
        Fx.vandalStandard,
        Fx.randomFavorite,
        'zzz',
        'ZZZ',
      ]);
      expect(v.totalVp, 1775);
      expect(v.pricedCount, 1);
      expect(v.unpricedCount, 1);
      expect(v.skinCount, 2);
      expect(
        PriceService(db: db).collectionValue(const []),
        isA<CollectionValue>(),
      );
      expect(CollectionValue.zero.totalVp, 0);
    });
  });

  group('ObservedPriceStore', () {
    test('records, skips no-ops, persists', () async {
      final prefs = await createTestPrefs();
      final store = ObservedPriceStore(prefs);
      expect(store.read(), isEmpty);
      expect(await store.record({'A': 100, 'b': 0}), {'a': 100});
      expect(await store.record({'a': 100}), isNull);
      expect(await store.record(const {}), isNull);
      expect(await store.record({'a': 120, 'c': 50}), {'a': 120, 'c': 50});
      expect(ObservedPriceStore(prefs).read(), {'a': 120, 'c': 50});
    });

    test('evicts the oldest entries beyond the cap', () async {
      final prefs = await createTestPrefs();
      final store = ObservedPriceStore(prefs);
      await store.record({'first': 1, 'second': 2});
      await store.record({'first': 3}); // refreshed → newest
      final many = {
        for (var i = 0; i < ObservedPriceStore.maxEntries - 1; i++) 'k$i': 10,
      };
      final result = (await store.record(many))!;
      expect(result.length, ObservedPriceStore.maxEntries);
      expect(result.containsKey('second'), isFalse);
      expect(result['first'], 3);
    });

    test('corrupt prefs value reads as empty', () async {
      final prefs = await createTestPrefs({
        ObservedPriceStore.key: '<not json>',
      });
      expect(ObservedPriceStore(prefs).read(), isEmpty);
    });
  });

  group('OffersPriceCache', () {
    test('parses skin-level VP offers only', () {
      expect(OffersPriceCache.parseOffers(economyFixture('offers.json')), {
        Fx.reaverL1: 1775,
        Fx.phantomTocChienL1: 875,
      });
      expect(OffersPriceCache.parseOffers('<html>'), isEmpty);
      expect(OffersPriceCache.parseOffers({'Offers': null}), isEmpty);
    });

    test('24 h fetch and disable windows', () async {
      final cache = OffersPriceCache(await createTestPrefs());
      expect(cache.shouldFetch(_t0), isTrue);
      await cache.saveSuccess({'a': 1}, _t0);
      expect(cache.read(), {'a': 1});
      expect(cache.shouldFetch(_t0.add(const Duration(hours: 23))), isFalse);
      expect(cache.shouldFetch(_t0.add(const Duration(hours: 24))), isTrue);
      await cache.saveFailure(_t0.add(const Duration(hours: 24)));
      expect(cache.shouldFetch(_t0.add(const Duration(hours: 30))), isFalse);
      expect(cache.shouldFetch(_t0.add(const Duration(hours: 48))), isTrue);
      expect(cache.read(), {'a': 1}, reason: 'failures keep old prices');
    });
  });

  group('providers', () {
    late Prefs prefs;
    late MockPvpApi api;
    setUp(() async {
      api = MockPvpApi();
      prefs = await createTestPrefs({
        PrefKeys.remoteConfig: jsonEncode({
          'prices': {Fx.aresSentinelsL1: 2375},
        }),
      });
    });

    ProviderContainer container({
      bool offersFlag = false,
      Future<String> Function()? asset,
    }) => ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        pvpApiProvider.overrideWithValue(api),
        contentProvider.overrideWith((ref) async => db),
        clockProvider.overrideWithValue(FixedClock(_t0)),
        activePuuidProvider.overrideWith(_FixedActive.new),
        remoteConfigProvider.overrideWithValue(
          RemoteConfig(flags: {RemoteFlags.useOffersEndpoint: offersFlag}),
        ),
        priceAssetLoaderProvider.overrideWithValue(
          asset ??
              () async => jsonEncode({
                'prices': {Fx.reaverL1: 1999},
              }),
        ),
      ],
    );

    test(
      'priceServiceProvider combines asset, remote and observed prices',
      () async {
        final c = container();
        c.listen(priceServiceProvider, (_, _) {});
        await c.read(contentProvider.future);
        final table = await c.read(priceTableProvider.future);
        expect(table.prices, {Fx.reaverL1: 1999, Fx.aresSentinelsL1: 2375});

        var service = c.read(priceServiceProvider);
        expect(service.priceForSkin(Fx.reaverVandal).vp, 1999);
        expect(
          service.priceForSkin(Fx.aresSentinels).source,
          PriceSource.table,
        );
        expect(service.priceForSkin(Fx.bulldogVoCuc).isEstimate, isTrue);

        await c.read(observedPricesProvider.notifier).record({
          Fx.bulldogVoCucL1: 1275,
        });
        service = c.read(priceServiceProvider);
        expect(
          service.priceForSkin(Fx.bulldogVoCuc).source,
          PriceSource.observed,
        );
        verifyNever(() => api.offers(any()));
      },
    );

    test('missing asset → empty table, fallback still works', () async {
      final c = container(asset: () async => throw StateError('no asset'));
      final table = await c.read(priceTableProvider.future);
      expect(table.prices, {Fx.aresSentinelsL1: 2375});
      await c.read(contentProvider.future);
      expect(
        c.read(priceServiceProvider).priceForSkin(Fx.reaverVandal).source,
        PriceSource.tierFallback,
      );
    });

    test('offers: flag off → never called', () async {
      final c = container();
      expect(await c.read(offerPricesProvider.future), isEmpty);
      verifyNever(() => api.offers(any()));
    });

    test('offers: fetched once per 24 h, then cached', () async {
      when(() => api.offers(Fx.puuid))
          .thenAnswer((_) async => economyFixture('offers.json'));
      final c1 = container(offersFlag: true);
      expect(await c1.read(offerPricesProvider.future), {
        Fx.reaverL1: 1775,
        Fx.phantomTocChienL1: 875,
      });
      c1.dispose();
      final c2 = container(offersFlag: true);
      expect(await c2.read(offerPricesProvider.future), hasLength(2));
      verify(() => api.offers(Fx.puuid)).called(1);
      await c2.read(contentProvider.future);
      c2.listen(priceServiceProvider, (_, _) {});
      await c2.read(priceTableProvider.future);
      expect(
        c2.read(priceServiceProvider).priceForSkin(Fx.phantomTocChien),
        const PriceQuote(vp: 875, source: PriceSource.offers),
      );
    });

    test('offers: failure disables the endpoint for 24 h', () async {
      when(
        () => api.offers(Fx.puuid),
      ).thenThrow(const RiotApiException(404, errorCode: 'RESOURCE_NOT_FOUND'));
      final c = container(offersFlag: true);
      expect(await c.read(offerPricesProvider.future), isEmpty);
      final cache = OffersPriceCache(prefs);
      expect(cache.disabledUntil, _t0.add(OffersPriceCache.interval));
      expect(cache.shouldFetch(_t0.add(const Duration(hours: 1))), isFalse);
    });

    test('offers: an empty list counts as a failure', () async {
      when(() => api.offers(Fx.puuid))
          .thenAnswer((_) async => {'Offers': <Object?>[]});
      final c = container(offersFlag: true);
      expect(await c.read(offerPricesProvider.future), isEmpty);
      expect(OffersPriceCache(prefs).disabledUntil, isNotNull);
    });

    test('offers: transient errors are swallowed too', () async {
      when(() => api.offers(Fx.puuid))
          .thenThrow(const TransientException(status: 503));
      final c = container(offersFlag: true);
      expect(await c.read(offerPricesProvider.future), isEmpty);
    });
  });
}
