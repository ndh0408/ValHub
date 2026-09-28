import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/storefront.dart';
import 'package:valvn/core/riot/riot_ids.dart';

import 'economy_fixtures.dart';

void main() {
  final receivedAt = DateTime.utc(2026, 9, 28, 5);

  group('parseCostMap', () {
    test('lowercases ids, rounds numbers, drops junk', () {
      expect(
        parseCostMap({
          '85AD13F7-3D1B-5128-9EB2-7CD8EE0B5741': 1775.4,
          'e59aa87c-4cbf-517a-5983-6e81511be9b7': '60',
          'bad': 'x',
          'nan': double.nan,
        }),
        {CurrencyIds.vp: 1775, CurrencyIds.rp: 60},
      );
      expect(parseCostMap(null), isEmpty);
      expect(parseCostMap([1, 2]), isEmpty);
    });
  });

  group('Storefront.fromJson (full P-1)', () {
    late Storefront store;
    setUp(() {
      store = Storefront.fromJson(
        economyFixture('storefront.json'),
        receivedAt: receivedAt,
      );
    });

    test('daily offers carry level uuid, VP cost and reset time', () {
      expect(store.daily.offers.map((o) => o.skinLevelUuid), [
        Fx.aresSentinelsL1,
        Fx.aresPrismL1,
        Fx.magepunkL1,
        Fx.operatorL1,
      ]);
      expect(store.daily.offers.map((o) => o.vpCost), [2175, 1275, 1775, 1275]);
      expect(store.daily.totalVp, 6500);
      expect(
        store.daily.expiresAt,
        receivedAt.add(const Duration(seconds: 17401)),
      );
      expect(store.daily.offers.first.offer.startDate?.year, 2023);
    });

    test('renders every bundle once, headline deduped', () {
      expect(store.bundles.map((b) => b.id), [Fx.bundleId, Fx.bundle2Id]);
      final b = store.bundles.first;
      expect(b.dataAssetId, Fx.neoFrontierAsset);
      expect(b.price, 1457);
      expect(b.isPriceComputed, isFalse);
      expect(b.itemsTotal, 3350);
      expect(b.savings, 1893);
      expect(b.discountPercent, 57);
      expect(b.totalDiscountFraction, closeTo(0.565, 1e-9));
      expect(b.expiresAt, receivedAt.add(const Duration(seconds: 1821001)));
      expect(b.skinItems.map((i) => i.item.itemId), [Fx.odinNeoFrontierL1]);

      final skin = b.items[0];
      expect(skin.discountFraction, closeTo(0.33, 1e-9));
      expect(skin.discountPercent, 33);
      expect(skin.isDiscounted, isTrue);
      expect(skin.isFree, isFalse);

      final buddy = b.items[1];
      expect(buddy.item.itemTypeId, ItemTypeIds.buddyLevel);
      expect(buddy.item.quantity, 2);
      expect(buddy.isFree, isTrue);
      expect(buddy.discountPercent, 100);
    });

    test('bundle without Items falls back to ItemOffers and sums totals', () {
      final b = store.bundleById(Fx.bundle2Id)!;
      expect(b.dataAssetId, '2116a38e-4b71-f169-0d16-ce9289af4bfa');
      expect(b.currencyId, CurrencyIds.vp);
      expect(b.wholesaleOnly, isTrue);
      expect(b.items.single.item.itemId, Fx.phantomTocChienL1);
      expect(b.items.single.item.isSkinLevel, isTrue);
      expect(b.items.single.basePrice, 875);
      expect(b.items.single.discountedPrice, 700);
      expect(b.totalDiscountedCost, isNull);
      expect(b.isPriceComputed, isTrue);
      expect(b.price, 700);
      expect(b.itemsTotal, 875);
      expect(b.savings, 175);
      expect(b.expiresAt, receivedAt.add(const Duration(seconds: 604800)));
      expect(
        store.bundleById(Fx.neoFrontierAsset.toUpperCase())?.id,
        Fx.bundleId,
      );
    });

    test('night market: integer percent, full and discounted cost, IsSeen', () {
      final nm = store.nightMarket!;
      expect(store.hasNightMarket, isTrue);
      expect(nm.offers, hasLength(3));
      final first = nm.offers.first;
      expect(first.skinLevelUuid, Fx.reaverL1);
      expect(first.bonusOfferId, 'e0c08290-92d1-4437-ac01-83257a08b8e2');
      expect(first.basePrice, 1775);
      expect(first.discountedPrice, 1385);
      expect(first.discountPercent, 22);
      expect(first.isSeen, isFalse);
      expect(first.savings, 390);
      expect(nm.totalSavings, 390 + 1456 + 485);
      expect(nm.hasUnseen, isTrue);
      expect(nm.expiresAt, receivedAt.add(const Duration(seconds: 1109206)));
    });

    test('accessory store: type, KC cost, contract, rotation', () {
      final acc = store.accessoryStore!;
      expect(acc.offers, hasLength(4));
      expect(acc.offers.map((o) => o.itemTypeId), [
        ItemTypeIds.spray,
        ItemTypeIds.playerCard,
        ItemTypeIds.playerTitle,
        ItemTypeIds.buddyLevel,
      ]);
      expect(acc.offers.map((o) => o.kcCost), [4000, 4000, 3000, 4500]);
      expect(acc.offers.first.itemId, Fx.sprayTinhNguyen);
      expect(
        acc.offers.first.contractId,
        'be540721-4d60-0675-a586-ecb14adcb5f7',
      );
      expect(acc.offers[2].contractId, isNull, reason: 'all-zero uuid');
      expect(acc.storefrontId, '27ce4bc3-81b1-575c-bcdf-572df8e8ce84');
      expect(acc.expiresAt, receivedAt.add(const Duration(seconds: 535801)));
    });

    test('next refresh = earliest future countdown', () {
      expect(store.deadlines, hasLength(5));
      expect(store.nextRefreshAt(receivedAt), store.daily.expiresAt);
      final afterReset = receivedAt.add(const Duration(seconds: 17402));
      expect(store.nextRefreshAt(afterReset), store.accessoryStore!.expiresAt);
      expect(
        store.nextRefreshAt(receivedAt.add(const Duration(days: 60))),
        isNull,
      );
    });

    test('observed prices use full prices only', () {
      expect(store.observedSkinPrices(), {
        Fx.aresSentinelsL1: 2175,
        Fx.aresPrismL1: 1275,
        Fx.magepunkL1: 1775,
        Fx.operatorL1: 1275,
        Fx.reaverL1: 1775,
        Fx.daoReaverL1: 3550,
        Fx.bulldogVoCucL1: 1275,
        Fx.odinNeoFrontierL1: 2175,
        Fx.phantomTocChienL1: 875,
      });
    });
  });

  group('Storefront.fromJson (defensive)', () {
    test('minimal payload: headline bundle, id-only daily, null offers', () {
      final store = Storefront.fromJson(
        economyFixture('storefront_minimal.json'),
        receivedAt: receivedAt,
      );
      expect(store.daily.offers.map((o) => o.skinLevelUuid), [
        Fx.aresSentinelsL1,
        Fx.aresPrismL1,
      ]);
      expect(store.daily.offers.first.vpCost, isNull);
      expect(store.daily.totalVp, 0);
      expect(store.daily.expiresAt, receivedAt.add(const Duration(hours: 2)));

      final b = store.bundles.single;
      expect(b.id, Fx.bundleId);
      expect(b.dataAssetId, Fx.neoFrontierAsset);
      expect(b.items, hasLength(2));
      expect(b.items.first.item.itemId, Fx.odinNeoFrontierL1);
      expect(b.items.first.basePrice, 2175);
      expect(b.items[1].discountedPrice, 0, reason: 'computed from fraction');
      expect(b.isPriceComputed, isTrue);
      expect(b.price, 1457);
      expect(b.itemsTotal, 2650);
      expect(b.wholesaleOnly, isFalse);
      expect(
        b.expiresAt,
        receivedAt.add(const Duration(milliseconds: 3600500)),
      );

      expect(store.nightMarket, isNull);
      expect(store.hasNightMarket, isFalse);
      expect(store.accessoryStore!.offers, isEmpty);
      expect(store.accessoryStore!.expiresAt, isNotNull);
    });

    test('non-JSON / wrong types never throw', () {
      for (final junk in <Object?>[
        null,
        '<html>',
        42,
        <Object?>[],
        {'FeaturedBundle': 'x', 'SkinsPanelLayout': <Object?>[]},
      ]) {
        final s = Storefront.fromJson(junk, receivedAt: receivedAt);
        expect(s.daily.isEmpty, isTrue);
        expect(s.bundles, isEmpty);
        expect(s.nightMarket, isNull);
        expect(s.accessoryStore, isNull);
        expect(s.nextRefreshAt(receivedAt), isNull);
      }
    });

    test('Night Market percent tolerates a fraction or a missing value', () {
      NightMarketOffer offer(Object? percent) => NightMarketOffer.fromJson({
        'BonusOfferID': 'X',
        'Offer': {
          'OfferID': Fx.reaverL1,
          'Cost': {CurrencyIds.vp: 2000},
          'Rewards': [
            {'ItemTypeID': ItemTypeIds.skinLevel, 'ItemID': Fx.reaverL1},
          ],
        },
        'DiscountPercent': percent,
        'DiscountCosts': {CurrencyIds.vp: 1500},
      })!;
      expect(offer(25).discountPercent, 25);
      expect(offer(0.25).discountPercent, 25);
      expect(offer(null).discountPercent, 25);
      expect(offer('junk').discountPercent, 25);
      expect(offer(25).isSeen, isFalse);
    });

    test('empty BonusStore means no Night Market', () {
      expect(
        NightMarket.fromJson({
          'BonusStoreOffers': null,
          'BonusStoreRemainingDurationInSeconds': 5,
        }, receivedAt: receivedAt),
        isNull,
      );
    });

    test('bundle whole-percent DiscountPercent is read as a fraction', () {
      final item = BundleItem.fromJson({
        'Item': {'ItemTypeID': ItemTypeIds.skinLevel, 'ItemID': 'A'},
        'BasePrice': 1000,
        'DiscountPercent': 30,
      }, currencyId: CurrencyIds.vp)!;
      expect(item.discountFraction, closeTo(0.3, 1e-9));
      expect(item.discountedPrice, 700);
      expect(item.item.itemId, 'a');
    });
  });

  group('Wallet', () {
    test('reads all balances', () {
      final w = Wallet.fromJson(
        economyFixture('wallet.json'),
        receivedAt: receivedAt,
      );
      expect((w.vp, w.rp, w.kc, w.agentTokens), (1450, 60, 11200, 2));
      expect(w.balance(CurrencyIds.vp.toUpperCase()), 1450);
      expect(w.isFromCache, isFalse);
    });

    test('missing currencies are 0; junk never throws', () {
      final w = Wallet.fromJson({
        'Balances': {'85AD13F7-3D1B-5128-9EB2-7CD8EE0B5741': 99.0},
      }, receivedAt: receivedAt);
      expect((w.vp, w.rp, w.kc, w.agentTokens), (99, 0, 0, 0));
      final junk = Wallet.fromJson('<html>', receivedAt: receivedAt);
      expect(junk.vp, 0);
      expect(junk.balances, isEmpty);
    });
  });
}
