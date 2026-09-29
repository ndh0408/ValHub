/// Search / tier filter / sort for skin lists (VF C6, C7, C10; S34, S39).
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/riot/riot_ids.dart';
import '../collection_strings.dart';
import 'collection_search.dart';
import 'weapon_sections.dart';

/// Sort orders of the skin lists (VF §8.6).
enum SkinSort {
  rarity(CollectionStrings.sortRarity),
  name(CollectionStrings.sortName),
  weapon(CollectionStrings.sortWeapon),
  price(CollectionStrings.sortPrice);

  const SkinSort(this.label);

  final String label;
}

/// Content tiers in rarity order (filter chips).
const kContentTierOrder = [
  ContentTierIds.select,
  ContentTierIds.deluxe,
  ContentTierIds.premium,
  ContentTierIds.exclusive,
  ContentTierIds.ultra,
];

/// The user's current search, tier filter and sort.
@immutable
class SkinQuery {
  const SkinQuery({
    this.search = '',
    this.tiers = const {},
    this.sort = SkinSort.rarity,
  });

  final String search;

  /// Content-tier uuids to keep (empty = all).
  final Set<String> tiers;
  final SkinSort sort;

  /// Whether the list is narrowed (search or tiers), i.e. "Đang lọc".
  bool get isFiltering => search.trim().isNotEmpty || tiers.isNotEmpty;

  SkinQuery copyWith({String? search, Set<String>? tiers, SkinSort? sort}) =>
      SkinQuery(
        search: search ?? this.search,
        tiers: tiers ?? this.tiers,
        sort: sort ?? this.sort,
      );

  /// Toggles one tier chip.
  SkinQuery toggleTier(String tierUuid) {
    final next = {...tiers};
    if (!next.remove(tierUuid)) next.add(tierUuid);
    return copyWith(tiers: next);
  }

  @override
  bool operator ==(Object other) =>
      other is SkinQuery &&
      other.search == search &&
      setEquals(other.tiers, tiers) &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(search, Object.hashAllUnordered(tiers), sort);
}

/// Applies [query] to [skins]: search (skin and weapon names, accents
/// ignored), tier filter, then the sort (ties by name).
///
/// - rarity: rarest first (C6), skins without a tier last;
/// - name: A → Z;
/// - weapon: weapon order of the loadout screen, then rarity;
/// - price: most expensive first; rewards / unknown prices last.
List<WeaponSkin> querySkins(
  Iterable<WeaponSkin> skins,
  SkinQuery query, {
  required ContentDb db,
  PriceService? prices,
}) {
  final filtered = [
    for (final s in skins)
      if ((query.tiers.isEmpty || query.tiers.contains(s.contentTierUuid)) &&
          matchesSearch(query.search, [
            s.displayName,
            db.weapon(s.weaponUuid)?.displayName,
          ]))
        s,
  ];
  int rank(WeaponSkin s) => db.contentTier(s.contentTierUuid)?.rank ?? -1;
  int byName(WeaponSkin a, WeaponSkin b) =>
      compareNames(a.displayName, b.displayName);
  int byRarity(WeaponSkin a, WeaponSkin b) {
    final c = rank(b).compareTo(rank(a));
    return c != 0 ? c : byName(a, b);
  }

  final Map<String, int> price = {
    if (query.sort == SkinSort.price && prices != null)
      for (final s in filtered) s.uuid: prices.priceForSkin(s.uuid).vp ?? -1,
  };
  final Map<String, int> weaponIndex = {};
  if (query.sort == SkinSort.weapon) {
    final ordered = orderedWeapons(db.weapons);
    for (var i = 0; i < ordered.length; i++) {
      weaponIndex[ordered[i].uuid] = i;
    }
  }

  filtered.sort(switch (query.sort) {
    SkinSort.rarity => byRarity,
    SkinSort.name => byName,
    SkinSort.weapon => (a, b) {
      final c = (weaponIndex[a.weaponUuid] ?? 1 << 20).compareTo(
        weaponIndex[b.weaponUuid] ?? 1 << 20,
      );
      return c != 0 ? c : byRarity(a, b);
    },
    SkinSort.price => (a, b) {
      final c = (price[b.uuid] ?? -1).compareTo(price[a.uuid] ?? -1);
      return c != 0 ? c : byRarity(a, b);
    },
  });
  return filtered;
}

/// Total value of [skins] with the collection rules (C8: Standard skipped,
/// rewards excluded).
CollectionValue valueOf(Iterable<WeaponSkin> skins, PriceService prices) =>
    prices.collectionValue(skins.map((s) => s.uuid));
