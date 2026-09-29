/// What the S3A list shows for one account: wishlist entries resolved
/// against the content, the current storefront hits ("Đang có trong …!"),
/// the active filters and the total value (SUMMARY W1–W7).
library;

import 'package:flutter/foundation.dart';

import '../../../core/domain/economy/economy.dart';
import 'skin_query.dart';

/// One wishlisted skin.
@immutable
class WishlistEntry {
  const WishlistEntry({required this.key, this.facts, this.hits = const []});

  /// Stored wishlist key (skin uuid, or the raw uuid when unknown).
  final String key;

  /// `null` when the content does not know the skin yet.
  final SkinFacts? facts;

  /// Where the skin is on sale right now for this account (store order:
  /// daily → Night Market → bundles).
  final List<WishlistHit> hits;

  bool get isKnown => facts != null;
  bool get isOnSale => hits.isNotEmpty;
}

/// The filtered / sorted S3A list and its summary.
@immutable
class WishlistView {
  const WishlistView({
    required this.entries,
    required this.visible,
    required this.total,
    required this.visibleValue,
    required this.query,
  });

  /// Every entry (known and unknown), unsorted.
  final List<WishlistEntry> entries;

  /// Entries after the filters, on-sale ones first, then [query]'s sort.
  final List<WishlistEntry> visible;

  /// Value of the whole wishlist ("Tổng giá trị wishlist", W7).
  final CollectionValue total;

  /// Value of [visible] ("Đang lọc: …").
  final CollectionValue visibleValue;
  final SkinQuery query;

  bool get isEmpty => entries.isEmpty;
  bool get hasUnknown => entries.any((e) => !e.isKnown);
  int get onSaleCount => visible.where((e) => e.isOnSale).length;
}

/// Builds the S3A view. Wishlist keys may be skin, level or chroma uuids
/// (normalised to skins); [hits] come from `findWishlistHits` on the
/// current storefront. Unknown skins are listed last and only while no
/// filter is active.
WishlistView buildWishlistView({
  required Set<String> wishlist,
  required SkinCatalog catalog,
  required List<WishlistHit> hits,
  required SkinQuery query,
}) {
  final keys = normalizeWishlist(wishlist, catalog.db);
  final hitsBySkin = <String, List<WishlistHit>>{};
  for (final h in hits) {
    (hitsBySkin[h.skinUuid] ??= []).add(h);
  }
  final entries = <WishlistEntry>[
    for (final key in keys)
      WishlistEntry(
        key: key,
        facts: catalog.factsFor(key),
        hits: List.unmodifiable(hitsBySkin[key] ?? const <WishlistHit>[]),
      ),
  ];

  final known = <String, WishlistEntry>{
    for (final e in entries)
      if (e.facts != null) e.facts!.uuid: e,
  };
  final sorted = applySkinQuery(known.values.map((e) => e.facts!), query);
  final visible = <WishlistEntry>[
    for (final f in sorted)
      if (known[f.uuid]!.isOnSale) known[f.uuid]!,
    for (final f in sorted)
      if (!known[f.uuid]!.isOnSale) known[f.uuid]!,
    if (!query.isFiltering)
      for (final e in entries)
        if (!e.isKnown) e,
  ];

  final prices = catalog.prices;
  return WishlistView(
    entries: List.unmodifiable(entries),
    visible: List.unmodifiable(visible),
    total: prices.collectionValue(keys),
    visibleValue: prices.collectionValue(visible.map((e) => e.key)),
    query: query,
  );
}
