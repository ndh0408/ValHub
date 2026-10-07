import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/features/home/data/home_store.dart';

import '../../../core/domain/economy/economy_fixtures.dart';

final _t0 = DateTime.utc(2026, 9, 28, 12);

Storefront _store({
  Map<String, dynamic>? json,
  DateTime? at,
  bool cache = false,
}) => Storefront.fromJson(
  json ?? economyFixture('storefront.json'),
  receivedAt: at ?? _t0,
  isFromCache: cache,
);

Wallet _wallet(int vp) => Wallet.fromJson({
  'Balances': {'85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741': vp},
}, receivedAt: _t0);

HomeStoreSummary? _summary(
  Storefront store, {
  Set<String> wishlist = const {},
  Wallet? wallet,
  Set<String> seen = const {},
  DateTime? now,
  ContentDb? db,
}) => buildHomeStoreSummary(
  store,
  db: db ?? economyContent(),
  wishlist: wishlist,
  wallet: wallet,
  nightMarketSeen: seen,
  now: now ?? _t0,
);

void main() {
  test('four daily tiles, the total and the reset time', () {
    final s = _summary(_store())!;
    expect(s.daily, hasLength(4));
    expect(s.daily.map((o) => o.levelUuid), [
      Fx.aresSentinelsL1,
      Fx.aresPrismL1,
      Fx.magepunkL1,
      Fx.operatorL1,
    ]);
    expect(s.daily.map((o) => o.vp), [2175, 1275, 1775, 1275]);
    expect(s.totalVp, 6500);
    expect(s.resetsAt, _t0.add(const Duration(seconds: 17401)));
    expect(s.isFromCache, isFalse);
    expect(s.receivedAt, _t0);
    // Every fixture skin is known to the content.
    expect(s.hasContentMiss, isFalse);
    expect(s.daily.first.skin?.displayName, isNotEmpty);
    expect(s.daily.first.tierUuid, isNotNull);
  });

  test('at most four tiles even with more offers', () {
    final json = economyFixture('storefront.json');
    final panel = json['SkinsPanelLayout'] as Map<String, dynamic>;
    final offers = (panel['SingleItemStoreOffers'] as List<dynamic>);
    panel['SingleItemStoreOffers'] = [
      ...offers,
      {
        ...(offers.first as Map<String, dynamic>),
        'OfferID': 'aaaaaaaa-0000-4000-8000-000000000001',
        'Rewards': [
          {
            'ItemTypeID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
            'ItemID': 'aaaaaaaa-0000-4000-8000-000000000001',
            'Quantity': 1,
          },
        ],
      },
    ];
    final s = _summary(_store(json: json))!;
    expect(s.daily, hasLength(4));
  });

  test('skins the wallet buys together, not one by one (PR-04)', () {
    // Offers: 2.175 / 1.275 / 1.775 / 1.275 VP.
    final without = _summary(_store())!;
    expect(without.walletVp, isNull);
    expect(without.affordableTogether, 0);

    // Each 1.275 VP skin alone fits 1.300 VP, but only one of them can be
    // bought: the second would need 2.550 VP.
    final some = _summary(_store(), wallet: _wallet(1300))!;
    expect(some.walletVp, 1300);
    expect(some.affordableTogether, 1);

    // 2.440 VP is enough for one skin at a time (the old "4" was wrong):
    // 1.275 + 1.275 = 2.550 > 2.440.
    expect(_summary(_store(), wallet: _wallet(2440))!.affordableTogether, 1);
    expect(_summary(_store(), wallet: _wallet(2550))!.affordableTogether, 2);
    // 1.275 + 1.275 + 1.775 = 4.325.
    expect(_summary(_store(), wallet: _wallet(4325))!.affordableTogether, 3);
    expect(_summary(_store(), wallet: _wallet(6500))!.affordableTogether, 4);
    expect(_summary(_store(), wallet: _wallet(0))!.affordableTogether, 0);
    expect(_summary(_store(), wallet: _wallet(1274))!.affordableTogether, 0);
  });

  test('maxAffordableTogether: cheapest first is optimal for the count', () {
    expect(maxAffordableTogether(const [2175, 1275, 1775, 1275], 2440), 1);
    expect(maxAffordableTogether(const [2175, 1275, 1775, 1275], 2550), 2);
    expect(maxAffordableTogether(const [100, 100, 100], 250), 2);
    expect(maxAffordableTogether(const [100, 100, 100], 300), 3);
    // Order of the input does not matter.
    expect(maxAffordableTogether(const [500, 100, 300, 200], 600), 3);
    // Unknown / zero prices are never "free"; an empty or broke wallet buys
    // nothing.
    expect(maxAffordableTogether(const [0, -5, 300], 300), 1);
    expect(maxAffordableTogether(const [], 1000), 0);
    expect(maxAffordableTogether(const [100], 0), 0);
    expect(maxAffordableTogether(const [100], -50), 0);
  });

  test('wishlist hits are live only, one per skin, daily first', () {
    final s = _summary(
      _store(),
      wishlist: {
        Fx.aresPrism, // daily
        Fx.daoReaver, // Night Market
        Fx.odinNeoFrontier, // bundle
      },
    )!;
    expect(s.hits.map((h) => h.place), [
      WishlistPlace.daily,
      WishlistPlace.nightMarket,
      WishlistPlace.bundle,
    ]);
    expect(s.hits.map((h) => h.skinUuid), hasLength(3));
    // The daily tile knows it is wishlisted.
    expect(
      s.daily.firstWhere((o) => o.levelUuid == Fx.aresPrismL1).inWishlist,
      isTrue,
    );
    expect(s.daily.first.inWishlist, isFalse);

    // After the daily reset the daily hit is gone; the Night Market and the
    // bundle are still live.
    final later = _summary(
      _store(),
      wishlist: {Fx.aresPrism, Fx.daoReaver, Fx.odinNeoFrontier},
      now: _t0.add(const Duration(hours: 6)),
    )!;
    expect(later.hits.map((h) => h.place), [
      WishlistPlace.nightMarket,
      WishlistPlace.bundle,
    ]);
  });

  test('a skin on sale in two places counts once', () {
    // Reaver Vandal is in the Night Market; make it a daily offer too.
    final json = economyFixture('storefront.json');
    final panel = json['SkinsPanelLayout'] as Map<String, dynamic>;
    final offers = panel['SingleItemStoreOffers'] as List<dynamic>;
    (offers.first as Map<String, dynamic>)
      ..['OfferID'] = Fx.reaverL1.toUpperCase()
      ..['Rewards'] = [
        {
          'ItemTypeID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
          'ItemID': Fx.reaverL1,
          'Quantity': 1,
        },
      ];
    final s = _summary(_store(json: json), wishlist: {Fx.reaverVandal})!;
    expect(s.hits, hasLength(1));
    expect(s.hits.single.place, WishlistPlace.daily);
  });

  group('Night Market', () {
    test('the best deal is the highest discount and starts unseen', () {
      final s = _summary(_store())!;
      final nm = s.nightMarket!;
      expect(nm.count, 3);
      expect(nm.best!.discountPercent, 41);
      expect(nm.best!.skinLevelUuid, Fx.daoReaverL1);
      expect(nm.unseen, isTrue);
      expect(nm.expiresAt, _t0.add(const Duration(seconds: 1109206)));
    });

    test('after the user opened it, nothing is unseen', () {
      final ids = _store().nightMarket!.offers.map((o) => o.bonusOfferId);
      final s = _summary(_store(), seen: ids.toSet())!;
      expect(s.nightMarket!.unseen, isFalse);
      // A new rotation (other offer ids) is unseen again.
      final other = _summary(_store(), seen: {'ffffffff'})!;
      expect(other.nightMarket!.unseen, isTrue);
    });

    test('ties go to the higher savings, then to the name', () {
      final json = economyFixture('storefront.json');
      final bonus = json['BonusStore'] as Map<String, dynamic>;
      final offers = bonus['BonusStoreOffers'] as List<dynamic>;
      // Two offers with the same discount, different savings.
      for (final o in offers) {
        (o as Map<String, dynamic>)['DiscountPercent'] = 40;
      }
      final s = _summary(_store(json: json))!;
      // Largest savings: dao Reaver (3550 − 2094 = 1456).
      expect(s.nightMarket!.best!.skinLevelUuid, Fx.daoReaverL1);
    });

    test('an ended Night Market is not shown', () {
      final s = _summary(_store(), now: _t0.add(const Duration(days: 30)))!;
      expect(s.nightMarket, isNull);
    });

    test('no Night Market key: no row', () {
      final json = economyFixture('storefront.json')..remove('BonusStore');
      expect(_summary(_store(json: json))!.nightMarket, isNull);
    });
  });

  test('null with no daily offers and no Night Market', () {
    expect(_summary(_store(json: const {})), isNull);
    final json = economyFixture('storefront.json');
    (json['SkinsPanelLayout'] as Map<String, dynamic>)
      ..['SingleItemStoreOffers'] = <Object?>[]
      ..['SingleItemOffers'] = <Object?>[];
    json.remove('BonusStore');
    expect(_summary(_store(json: json)), isNull);
    // A Night Market alone is enough to show the card.
    final nmOnly = economyFixture('storefront.json');
    (nmOnly['SkinsPanelLayout'] as Map<String, dynamic>)
      ..['SingleItemStoreOffers'] = <Object?>[]
      ..['SingleItemOffers'] = <Object?>[];
    expect(_summary(_store(json: nmOnly))!.nightMarket, isNotNull);
  });

  test('a level missing from the content is a content miss', () {
    final json = economyFixture('storefront.json');
    final panel = json['SkinsPanelLayout'] as Map<String, dynamic>;
    final offers = panel['SingleItemStoreOffers'] as List<dynamic>;
    (offers.first as Map<String, dynamic>)
      ..['OfferID'] = Fx.unknownLevel
      ..['Rewards'] = [
        {
          'ItemTypeID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
          'ItemID': Fx.unknownLevel,
          'Quantity': 1,
        },
      ];
    final s = _summary(_store(json: json))!;
    expect(s.hasContentMiss, isTrue);
    expect(s.daily.first.skin, isNull);
    // An empty content (not downloaded yet) is not a miss.
    expect(_summary(_store(), db: ContentDb.empty())!.hasContentMiss, isFalse);
  });

  test('a cached storefront is flagged', () {
    final s = _summary(
      _store(cache: true, at: _t0.subtract(const Duration(hours: 1))),
    )!;
    expect(s.isFromCache, isTrue);
    expect(s.receivedAt, _t0.subtract(const Duration(hours: 1)));
  });

  test('a saved store from before the reset shows none of its skins', () {
    // The copy kept while the sign-in is expired, read the next day: the
    // daily rotation ended at _t0 + 17401 s, the Night Market still runs.
    final s = _summary(
      _store(cache: true),
      wallet: _wallet(10000),
      wishlist: {Fx.aresPrism},
      now: _t0.add(const Duration(days: 1)),
    )!;
    expect(s.dailyExpired, isTrue);
    expect(s.daily, isEmpty);
    expect(s.resetsAt, isNull);
    expect(s.totalVp, 0);
    expect(s.affordableTogether, 0);
    expect(
      s.hits.where((h) => h.place == WishlistPlace.daily),
      isEmpty,
      reason: 'the skin of the ended rotation is not on sale',
    );
    expect(s.nightMarket, isNotNull);
    expect(s.isFromCache, isTrue);
  });

  test('a store still inside its rotation is not expired', () {
    final s = _summary(_store(cache: true))!;
    expect(s.dailyExpired, isFalse);
    expect(s.daily, hasLength(4));
  });

  test('Night Market cards flipped in the game are not waiting', () {
    final json = economyFixture('storefront.json');
    final bonus = json['BonusStore'] as Map<String, dynamic>;
    for (final o in bonus['BonusStoreOffers'] as List<dynamic>) {
      (o as Map<String, dynamic>)['IsSeen'] = true;
    }
    final s = _summary(_store(json: json))!;
    expect(s.nightMarket!.unseen, isFalse);
    expect(s.nightMarket!.best, isNotNull);
  });
}
