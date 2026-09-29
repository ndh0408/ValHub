import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/features/wishlist/data/skin_query.dart';
import 'package:valvn/features/wishlist/data/wishlist_view.dart';

import '../../../core/domain/economy/economy_fixtures.dart';

void main() {
  late ContentDb db;
  late SkinCatalog catalog;
  late List<WishlistHit> hits;
  const wishlist = {
    Fx.knifeCafe,
    Fx.reaverL1, // legacy level entry
    Fx.aresSentinels,
    Fx.unknownLevel, // not in the content yet
  };

  setUp(() {
    db = economyContent();
    catalog = SkinCatalog.build(db, PriceService(db: db));
    final store = Storefront.fromJson(
      economyFixture('storefront.json'),
      receivedAt: DateTime.utc(2026, 9, 28, 5),
    );
    hits = findWishlistHits(store, wishlist, db);
  });

  List<String> keys(WishlistView v) => [for (final e in v.visible) e.key];

  test('on-sale entries first, then the sort, unknown skins last', () {
    final view = buildWishlistView(
      wishlist: wishlist,
      catalog: catalog,
      hits: hits,
      query: const SkinQuery(sort: SkinSort.name),
    );
    expect(view.entries, hasLength(4));
    expect(keys(view), [
      Fx.aresSentinels,
      Fx.reaverVandal,
      Fx.knifeCafe,
      Fx.unknownLevel,
    ]);
    expect(view.onSaleCount, 2);
    expect(view.hasUnknown, isTrue);
    final ares = view.visible.first;
    expect(ares.isOnSale, isTrue);
    expect(ares.hits.single.place, WishlistPlace.daily);
    expect(view.visible[1].hits.single.place, WishlistPlace.nightMarket);
    expect(view.visible[2].isOnSale, isFalse);
    expect(view.visible.last.isKnown, isFalse);
  });

  test('total value counts every skin; filtered value only visible', () {
    final all = buildWishlistView(
      wishlist: wishlist,
      catalog: catalog,
      hits: hits,
      query: const SkinQuery(),
    );
    expect(all.total.skinCount, 4);
    expect(all.total.totalVp, greaterThan(0));
    expect(all.visibleValue.totalVp, all.total.totalVp);

    final filtered = buildWishlistView(
      wishlist: wishlist,
      catalog: catalog,
      hits: hits,
      query: const SkinQuery(text: 'dao'),
    );
    expect(keys(filtered), [Fx.knifeCafe], reason: 'unknown hidden');
    expect(filtered.total.totalVp, all.total.totalVp);
    expect(
      filtered.visibleValue.totalVp,
      catalog.prices.priceForSkin(Fx.knifeCafe).vp ?? 0,
    );
    expect(filtered.visibleValue.skinCount, 1);
    expect(filtered.onSaleCount, 0);
  });

  test('empty wishlist', () {
    final view = buildWishlistView(
      wishlist: const {},
      catalog: catalog,
      hits: const [],
      query: const SkinQuery(),
    );
    expect(view.isEmpty, isTrue);
    expect(view.visible, isEmpty);
    expect(view.total.totalVp, 0);
  });
}
