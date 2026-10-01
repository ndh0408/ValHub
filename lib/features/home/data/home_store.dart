/// "Cửa hàng hôm nay" card model (docs/design/HOME.md §5.2). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../../store/providers/night_market_seen.dart';

/// Skin tiles shown on the card.
const kHomeMaxDailyTiles = 4;

/// One daily skin tile.
@immutable
class HomeSkinOffer {
  const HomeSkinOffer({
    required this.levelUuid,
    this.skin,
    this.vp,
    this.tierUuid,
    this.inWishlist = false,
  });

  /// Level-1 skin uuid (`showSkinDetailSheet` accepts it).
  final String levelUuid;

  /// `null` when valorant-api does not know the skin yet.
  final WeaponSkin? skin;
  final int? vp;
  final String? tierUuid;
  final bool inWishlist;
}

/// The Night Market row: how many cards wait, until when, the best deal and
/// whether the user has opened the Night Market in ValVN yet.
@immutable
class HomeNightMarket {
  const HomeNightMarket({
    required this.count,
    required this.unseen,
    this.expiresAt,
    this.best,
  });

  final int count;
  final DateTime? expiresAt;

  /// Highest [NightMarketOffer.discountPercent]; ties go to the larger
  /// savings, then to the skin name.
  final NightMarketOffer? best;

  /// The user has not opened the Night Market since it started (the best
  /// deal stays hidden so the "flip the cards" surprise is kept).
  final bool unseen;
}

/// Everything the store card renders.
@immutable
class HomeStoreSummary {
  const HomeStoreSummary({
    required this.daily,
    required this.totalVp,
    required this.affordableTogether,
    required this.hits,
    required this.isFromCache,
    required this.receivedAt,
    this.resetsAt,
    this.walletVp,
    this.nightMarket,
    this.hasContentMiss = false,
  });

  /// At most [kHomeMaxDailyTiles] offers.
  final List<HomeSkinOffer> daily;
  final DateTime? resetsAt;
  final int totalVp;

  /// `null` while the wallet is unknown.
  final int? walletVp;

  /// How many daily skins the wallet can pay **all at once** (0 without a
  /// wallet): the cheapest first, so 2,440 VP against 1,275 + 1,275 + 1,775 +
  /// 2,175 buys one, not four (PR-04).
  final int affordableTogether;

  /// Wishlisted skins on sale right now, one per skin, ordered daily →
  /// Night Market → bundle.
  final List<WishlistHit> hits;
  final HomeNightMarket? nightMarket;
  final bool isFromCache;
  final DateTime receivedAt;

  /// An offered level is missing from the content (a new patch).
  final bool hasContentMiss;
}

/// The store card's summary; `null` when there are no daily offers and no
/// Night Market. [wishlist] holds skin uuids, [nightMarketSeen] the
/// `BonusOfferID`s of the rotation the user last opened, [wallet] may be
/// unknown.
HomeStoreSummary? buildHomeStoreSummary(
  Storefront store, {
  required ContentDb db,
  required Set<String> wishlist,
  required DateTime now,
  Wallet? wallet,
  Set<String> nightMarketSeen = const {},
}) {
  bool live(DateTime? at) => at == null || at.isAfter(now);

  final offers = store.daily.offers;
  final nm = store.nightMarket;
  final nmLive = nm != null && live(nm.expiresAt);
  if (offers.isEmpty && !nmLive) return null;

  final tiles = <HomeSkinOffer>[
    for (final o in offers.take(kHomeMaxDailyTiles))
      () {
        final skin = db.skinByLevelUuid(o.skinLevelUuid);
        return HomeSkinOffer(
          levelUuid: o.skinLevelUuid,
          skin: skin,
          vp: o.vpCost,
          tierUuid: skin?.contentTierUuid,
          inWishlist: wishlistContains(wishlist, o.skinLevelUuid, db),
        );
      }(),
  ];

  final seenSkins = <String>{};
  final hits = <WishlistHit>[
    for (final h in findWishlistHits(store, wishlist, db))
      if (live(h.expiresAt) && seenSkins.add(h.skinUuid)) h,
  ];

  final walletVp = wallet?.vp;
  final affordable = walletVp == null
      ? 0
      : store.daily.affordableTogether(walletVp);

  HomeNightMarket? market;
  if (nmLive) {
    NightMarketOffer? best;
    int compare(NightMarketOffer a, NightMarketOffer b) {
      final byPercent = a.discountPercent.compareTo(b.discountPercent);
      if (byPercent != 0) return byPercent;
      final bySavings = a.savings.compareTo(b.savings);
      if (bySavings != 0) return bySavings;
      // Equal deals: the skin that comes first by name wins.
      final an = db.skinByLevelUuid(a.skinLevelUuid)?.displayName ?? '';
      final bn = db.skinByLevelUuid(b.skinLevelUuid)?.displayName ?? '';
      return bn.compareTo(an);
    }

    for (final o in nm.offers) {
      if (best == null || compare(o, best) > 0) best = o;
    }
    market = HomeNightMarket(
      count: nm.offers.length,
      expiresAt: nm.expiresAt,
      best: best,
      unseen: hasUnseenOffers(
        nm.offers.map((o) => o.bonusOfferId),
        nightMarketSeen,
      ),
    );
  }

  final levels = [
    ...offers.map((o) => o.skinLevelUuid),
    if (nmLive) ...nm.offers.map((o) => o.skinLevelUuid),
  ];
  final miss = !db.isEmpty && levels.any((l) => db.skinByLevelUuid(l) == null);

  return HomeStoreSummary(
    daily: List.unmodifiable(tiles),
    resetsAt: store.daily.expiresAt,
    totalVp: store.daily.totalVp,
    walletVp: walletVp,
    affordableTogether: affordable,
    hits: List.unmodifiable(hits),
    nightMarket: market,
    isFromCache: store.isFromCache,
    receivedAt: store.receivedAt,
    hasContentMiss: miss,
  );
}
