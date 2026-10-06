/// Wishlist matching on top of the core per-account wishlist store
/// (SUMMARY §8.2 W1–W7; VF S3A, W2/W4).
///
/// Storage lives in `core/wishlist/wishlist_store.dart` (re-exported here):
/// `wishlistProvider(puuid)` → `Set<String>` of **skin** uuids with
/// `add` / `remove` / `toggle` / `contains`, `WishlistRepository(prefs)` for
/// background isolates, stored under `keep.<puuid>.wishlist` so it survives
/// sign-out. This file adds uuid normalisation (any level / chroma uuid →
/// skin uuid) and the store ↔ wishlist intersection.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_db.dart';
import '../../content/content_repository.dart';
import '../../util/clock.dart';
import '../../wishlist/wishlist_store.dart';
import 'economy_fetch.dart';
import 'storefront.dart';

export '../../wishlist/wishlist_store.dart';

/// Canonical wishlist key for a skin, level or chroma uuid: the skin uuid
/// when [db] knows it, else the lowercased input.
String wishlistKeyFor(String anySkinUuid, ContentDb db) =>
    db.skinByAnyUuid(anySkinUuid)?.uuid ?? anySkinUuid.trim().toLowerCase();

/// [wishlist] normalised to skin uuids (tolerates level uuids stored by
/// older builds or other tools).
Set<String> normalizeWishlist(Iterable<String> wishlist, ContentDb db) => {
  for (final id in wishlist)
    if (id.trim().isNotEmpty) wishlistKeyFor(id, db),
};

/// Whether the skin of [anySkinUuid] (skin / level / chroma uuid) is in
/// [wishlist] (matching on any level uuid, W1).
bool wishlistContains(Set<String> wishlist, String anySkinUuid, ContentDb db) {
  final key = wishlistKeyFor(anySkinUuid, db);
  if (wishlist.contains(key)) return true;
  return normalizeWishlist(wishlist, db).contains(key);
}

/// Every uuid that identifies the skin of [anySkinUuid]: skin, levels,
/// chromas and the raw input.
Set<String> _skinAliases(String anySkinUuid, ContentDb db) {
  final skin = db.skinByAnyUuid(anySkinUuid);
  return {
    anySkinUuid.trim().toLowerCase(),
    if (skin != null) ...[
      skin.uuid,
      for (final l in skin.levels) l.uuid,
      for (final c in skin.chromas) c.uuid,
    ],
  };
}

/// Wishlist actions that accept any skin, level or chroma uuid.
extension WishlistNotifierX on WishlistNotifier {
  bool containsSkin(String anySkinUuid, ContentDb db) =>
      _skinAliases(anySkinUuid, db).any(contains);

  /// Adds the skin (stored as its skin uuid).
  Future<void> addSkin(String anySkinUuid, ContentDb db) =>
      add(wishlistKeyFor(anySkinUuid, db));

  /// Removes the skin, including legacy entries stored as a level uuid.
  Future<void> removeSkin(String anySkinUuid, ContentDb db) async {
    for (final id in _skinAliases(anySkinUuid, db)) {
      if (contains(id)) await remove(id);
    }
  }

  /// Returns the new membership.
  Future<bool> toggleSkin(String anySkinUuid, ContentDb db) async {
    if (containsSkin(anySkinUuid, db)) {
      await removeSkin(anySkinUuid, db);
      return false;
    }
    await addSkin(anySkinUuid, db);
    return true;
  }
}

/// Where a wishlisted skin is on sale.
enum WishlistPlace { daily, nightMarket, bundle }

/// A wishlisted skin found in a storefront (W2, S3A "Đang có trong …!").
@immutable
class WishlistHit {
  const WishlistHit({
    required this.skinUuid,
    required this.levelUuid,
    required this.place,
    this.skin,
    this.bundleId,
    this.bundleDataAssetId,
    this.price,
    this.basePrice,
    this.discountPercent,
    this.expiresAt,
  });

  /// Wishlist key (skin uuid, or the raw offer uuid when content is missing).
  final String skinUuid;

  /// Offer item (level-1 uuid).
  final String levelUuid;
  final WishlistPlace place;

  /// `null` when valorant-api does not know the skin yet.
  final WeaponSkin? skin;

  /// Storefront bundle id (`StoreRoutes.bundle(bundleId)`) for bundle hits.
  final String? bundleId;

  /// valorant-api bundle uuid (name / art) for bundle hits.
  final String? bundleDataAssetId;

  /// Price to pay: daily cost, Night Market discounted cost, or the item's
  /// price inside the bundle.
  final int? price;

  /// Full price when discounted (Night Market / bundle).
  final int? basePrice;

  /// Whole percent for Night Market / discounted bundle items.
  final int? discountPercent;

  /// When this offer ends.
  final DateTime? expiresAt;

  /// Stable id for notifications / dedupe (`place:skin[:bundle]`).
  String get key => bundleId == null
      ? '${place.name}:$skinUuid'
      : '${place.name}:$skinUuid:$bundleId';

  @override
  bool operator ==(Object other) =>
      other is WishlistHit &&
      other.key == key &&
      other.levelUuid == levelUuid &&
      other.price == price &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(key, levelUuid, price, expiresAt);

  @override
  String toString() => 'WishlistHit($key, $price)';
}

/// Intersects [storefront] with [wishlistSkinUuids] (W2): daily offers, then
/// Night Market, then bundle skin items. A skin on sale in several places
/// yields one hit per place (and per bundle). Wishlist entries may be skin,
/// level or chroma uuids. Pure.
List<WishlistHit> findWishlistHits(
  Storefront storefront,
  Set<String> wishlistSkinUuids,
  ContentDb db,
) {
  if (wishlistSkinUuids.isEmpty) return const [];
  final wanted = normalizeWishlist(wishlistSkinUuids, db);
  final hits = <WishlistHit>[];
  final keys = <String>{};

  void consider({
    required String levelUuid,
    required WishlistPlace place,
    int? price,
    int? basePrice,
    int? discountPercent,
    DateTime? expiresAt,
    String? bundleId,
    String? bundleDataAssetId,
  }) {
    final skin = db.skinByAnyUuid(levelUuid);
    final key = skin?.uuid ?? levelUuid;
    if (!wanted.contains(key)) return;
    final hit = WishlistHit(
      skinUuid: key,
      levelUuid: levelUuid,
      place: place,
      skin: skin,
      bundleId: bundleId,
      bundleDataAssetId: bundleDataAssetId,
      price: price,
      basePrice: basePrice,
      discountPercent: discountPercent,
      expiresAt: expiresAt,
    );
    if (keys.add(hit.key)) hits.add(hit);
  }

  for (final o in storefront.daily.offers) {
    consider(
      levelUuid: o.skinLevelUuid,
      place: WishlistPlace.daily,
      price: o.vpCost,
      expiresAt: storefront.daily.expiresAt,
    );
  }
  final nightMarket = storefront.nightMarket;
  for (final o in nightMarket?.offers ?? const <NightMarketOffer>[]) {
    consider(
      levelUuid: o.skinLevelUuid,
      place: WishlistPlace.nightMarket,
      price: o.discountedPrice,
      basePrice: o.basePrice,
      discountPercent: o.discountPercent,
      expiresAt: nightMarket?.expiresAt,
    );
  }
  for (final b in storefront.bundles) {
    for (final item in b.skinItems) {
      consider(
        levelUuid: item.item.itemId,
        place: WishlistPlace.bundle,
        price: item.discountedPrice,
        basePrice: item.isDiscounted ? item.basePrice : null,
        discountPercent: item.isDiscounted ? item.discountPercent : null,
        expiresAt: b.expiresAt,
        bundleId: b.id,
        bundleDataAssetId: b.dataAssetId,
      );
    }
  }
  return List.unmodifiable(hits);
}

/// Wishlisted skins in the current storefront of one account (store badges,
/// S3A highlight). Recomputed when the wishlist, storefront or content
/// changes.
///
/// ```dart
/// final hits = ref.watch(wishlistHitsProvider(puuid)).value ?? const [];
/// ```
final wishlistHitsProvider = FutureProvider.autoDispose
    .family<List<WishlistHit>, String>((ref, puuid) async {
      final wishlist = ref.watch(wishlistProvider(puuid));
      final now = ref.watch(clockProvider).now();
      final (storefront, db) = await awaitBoth(
        ref.watch(storefrontProvider(puuid).future),
        ref.watch(contentProvider.future),
      );
      // A saved storefront (sign-in expired, offline) can be days old: an
      // offer whose rotation ended is no longer on sale and never shows as
      // "available now" with its old price.
      return List.unmodifiable([
        for (final hit in findWishlistHits(storefront, wishlist, db))
          if (hit.expiresAt == null || hit.expiresAt!.isAfter(now)) hit,
      ]);
    });
