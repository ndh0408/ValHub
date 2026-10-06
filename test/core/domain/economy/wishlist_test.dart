import 'package:valvn/core/l10n/labels/economy_labels.dart';

import '../../../helpers/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy_strings.dart';
import 'package:valvn/core/domain/economy/storefront.dart';
import 'package:valvn/core/domain/economy/wishlist.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';

import '../../../helpers/test_prefs.dart';
import 'economy_fixtures.dart';

void main() {
  final receivedAt = DateTime.utc(2026, 9, 28, 5);
  late ContentDb db;
  late Storefront store;
  setUp(() {
    db = economyContent();
    store = Storefront.fromJson(
      economyFixture('storefront.json'),
      receivedAt: receivedAt,
    );
  });

  group('normalisation', () {
    test('any level / chroma uuid maps to the skin uuid', () {
      expect(wishlistKeyFor(Fx.reaverL3.toUpperCase(), db), Fx.reaverVandal);
      expect(wishlistKeyFor(Fx.reaverChroma2, db), Fx.reaverVandal);
      expect(wishlistKeyFor(' UNKNOWN ', db), 'unknown');
      expect(normalizeWishlist([Fx.reaverL1, Fx.reaverVandal, ' '], db), {
        Fx.reaverVandal,
      });
      expect(wishlistContains({Fx.reaverL1}, Fx.reaverChroma3, db), isTrue);
      expect(wishlistContains({Fx.reaverVandal}, Fx.reaverL4, db), isTrue);
      expect(wishlistContains({Fx.reaverVandal}, Fx.aresPrism, db), isFalse);
    });
  });

  group('findWishlistHits', () {
    test('daily, Night Market and bundle hits with prices and deadlines', () {
      final hits = findWishlistHits(store, {
        Fx.aresSentinels,
        Fx.reaverL1, // legacy level entry
        Fx.odinNeoFrontier,
        Fx.phantomTocChienChroma,
        Fx.knifeCafe, // not on sale
      }, db);
      expect(hits.map((h) => h.key), [
        'daily:${Fx.aresSentinels}',
        'nightMarket:${Fx.reaverVandal}',
        'bundle:${Fx.odinNeoFrontier}:${Fx.bundleId}',
        'bundle:${Fx.phantomTocChien}:${Fx.bundle2Id}',
      ]);

      final daily = hits[0];
      expect(daily.place, WishlistPlace.daily);
      expect(daily.skin?.uuid, Fx.aresSentinels);
      expect(daily.levelUuid, Fx.aresSentinelsL1);
      expect(daily.price, 2175);
      expect(daily.basePrice, isNull);
      expect(daily.discountPercent, isNull);
      expect(daily.expiresAt, store.daily.expiresAt);
      expect(daily.placeLabel(db, tl), EconomyStrings.placeDaily);

      final nm = hits[1];
      expect(nm.place, WishlistPlace.nightMarket);
      expect((nm.price, nm.basePrice, nm.discountPercent), (1385, 1775, 22));
      expect(nm.expiresAt, store.nightMarket!.expiresAt);
      expect(nm.placeLabel(db, tl), 'Chợ Đêm');

      final bundle = hits[2];
      expect(bundle.bundleId, Fx.bundleId);
      expect(bundle.bundleDataAssetId, Fx.neoFrontierAsset);
      expect(
        (bundle.price, bundle.basePrice, bundle.discountPercent),
        (1457, 2175, 33),
      );
      expect(bundle.expiresAt, store.bundles.first.expiresAt);
      expect(
        bundle.placeLabel(db, tl),
        EconomyStrings.placeBundle(
          db.bundleByUuid(Fx.neoFrontierAsset)!.displayName,
        ),
      );

      final bundle2 = hits[3];
      expect(bundle2.price, 700);
      expect(
        bundle2.placeLabel(db, tl),
        'bundle',
        reason: 'bundle not in content',
      );
    });

    test('same skin in two places yields two hits', () {
      final twice = Storefront.fromJson({
        'SkinsPanelLayout': {
          'SingleItemOffers': [Fx.reaverL1],
          'SingleItemOffersRemainingDurationInSeconds': 10,
        },
        'BonusStore': {
          'BonusStoreOffers': [
            {
              'Offer': {
                'OfferID': Fx.reaverL1,
                'Cost': {'85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741': 1775},
              },
              'DiscountPercent': 10,
              'DiscountCosts': {'85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741': 1598},
            },
          ],
        },
      }, receivedAt: receivedAt);
      final hits = findWishlistHits(twice, {Fx.reaverVandal}, db);
      expect(hits.map((h) => h.place), [
        WishlistPlace.daily,
        WishlistPlace.nightMarket,
      ]);
      expect(hits.first.price, isNull, reason: 'id-only daily payload');
    });

    test('empty wishlist / no match / unknown content', () {
      expect(findWishlistHits(store, const {}, db), isEmpty);
      expect(findWishlistHits(store, {Fx.aresPrism.substring(1)}, db), isEmpty);
      final raw = findWishlistHits(store, {
        Fx.magepunkL1.toUpperCase(),
      }, ContentDb.empty());
      expect(raw.single.skin, isNull);
      expect(raw.single.skinUuid, Fx.magepunkL1);
      expect(raw.single.price, 1775);
    });
  });

  group('WishlistNotifier helpers', () {
    test('toggle / contains / remove with any uuid; legacy entries', () async {
      final prefs = await createTestPrefs({
        WishlistRepository.key(Fx.puuid): [Fx.aresSentinelsL1],
      });
      final c = ProviderContainer.test(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      final n = c.read(wishlistProvider(Fx.puuid).notifier);
      expect(n.containsSkin(Fx.aresSentinels, db), isTrue, reason: 'legacy');

      expect(await n.toggleSkin(Fx.reaverL2, db), isTrue);
      expect(c.read(wishlistProvider(Fx.puuid)), {
        Fx.aresSentinelsL1,
        Fx.reaverVandal,
      });
      expect(n.containsSkin(Fx.reaverChroma3, db), isTrue);

      await n.removeSkin(Fx.aresSentinelsL1, db);
      expect(c.read(wishlistProvider(Fx.puuid)), {Fx.reaverVandal});
      expect(await n.toggleSkin(Fx.reaverVandal, db), isFalse);
      expect(c.read(wishlistProvider(Fx.puuid)), isEmpty);
      expect(WishlistRepository(prefs).read(Fx.puuid), isEmpty);

      await n.addSkin('SOMETHING-NEW', db);
      expect(c.read(wishlistProvider(Fx.puuid)), {'something-new'});
    });

    test('wishlistHitsProvider follows the wishlist', () async {
      final prefs = await createTestPrefs();
      final c = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          contentProvider.overrideWith((ref) async => db),
          storefrontProvider.overrideWith((ref, puuid) async => store),
          clockProvider.overrideWithValue(FixedClock(receivedAt)),
        ],
      );
      expect(
        await readListened(c, wishlistHitsProvider(Fx.puuid).future),
        isEmpty,
      );
      await c
          .read(wishlistProvider(Fx.puuid).notifier)
          .addSkin(Fx.odinNeoFrontierL1, db);
      final hits = await readListened(c, wishlistHitsProvider(Fx.puuid).future);
      expect(hits.single.place, WishlistPlace.bundle);
    });
    test('a saved storefront never lists an ended offer as on sale', () async {
      final prefs = await createTestPrefs();
      final c = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          contentProvider.overrideWith((ref) async => db),
          storefrontProvider.overrideWith((ref, puuid) async => store),
          // Read 30 days later: every rotation of the copy has ended.
          clockProvider.overrideWithValue(
            FixedClock(receivedAt.add(const Duration(days: 30))),
          ),
        ],
      );
      await c
          .read(wishlistProvider(Fx.puuid).notifier)
          .addSkin(Fx.odinNeoFrontierL1, db);
      expect(
        await readListened(c, wishlistHitsProvider(Fx.puuid).future),
        isEmpty,
      );
    });
  });
}
