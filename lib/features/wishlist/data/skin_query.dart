/// Search / tier + weapon filter / sort shared by the wishlist (S3A) and the
/// all-skins catalog (S3B), same options as the collection (VF §6.4 S39,
/// SUMMARY W7). Pure and synchronous: sort keys are computed once per
/// content + price change in [SkinCatalog.build].
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../wishlist_strings.dart';
import 'vi_search.dart';

/// Sort orders (VF §8.6 "Độ hiếm / Tên / Vũ khí / Giá").
enum SkinSort {
  /// Highest edition first, then name.
  rarity,

  /// A → Z (accent-insensitive).
  name,

  /// Weapon order of the loadout screen (sidearms → melee), then name.
  weapon,

  /// Most expensive first; skins without a price last.
  price;

  String get label => switch (this) {
    rarity => WishlistStrings.sortRarity,
    name => WishlistStrings.sortName,
    weapon => WishlistStrings.sortWeapon,
    price => WishlistStrings.sortPrice,
  };
}

/// What the user typed / picked in the filter bar.
@immutable
class SkinQuery {
  const SkinQuery({
    this.text = '',
    this.tiers = const {},
    this.weaponUuid,
    this.sort = SkinSort.rarity,
  });

  final String text;

  /// Content tier uuids to keep (empty = every tier).
  final Set<String> tiers;

  /// Weapon to keep (`null` = every weapon).
  final String? weaponUuid;
  final SkinSort sort;

  /// Whether any filter (not the sort) narrows the list.
  bool get isFiltering =>
      text.trim().isNotEmpty || tiers.isNotEmpty || weaponUuid != null;

  SkinQuery copyWith({
    String? text,
    Set<String>? tiers,
    String? weaponUuid,
    bool clearWeapon = false,
    SkinSort? sort,
  }) => SkinQuery(
    text: text ?? this.text,
    tiers: tiers ?? this.tiers,
    weaponUuid: clearWeapon ? null : (weaponUuid ?? this.weaponUuid),
    sort: sort ?? this.sort,
  );

  /// Same sort, no filters.
  SkinQuery cleared() => SkinQuery(sort: sort);

  /// [tiers] with [tierUuid] toggled.
  SkinQuery toggleTier(String tierUuid) {
    final next = {...tiers};
    if (!next.remove(tierUuid)) next.add(tierUuid);
    return copyWith(tiers: next);
  }

  @override
  bool operator ==(Object other) =>
      other is SkinQuery &&
      other.text == text &&
      setEquals(other.tiers, tiers) &&
      other.weaponUuid == weaponUuid &&
      other.sort == sort;

  @override
  int get hashCode =>
      Object.hash(text, Object.hashAllUnordered(tiers), weaponUuid, sort);
}

/// One skin with its precomputed filter and sort keys.
@immutable
class SkinFacts {
  const SkinFacts({
    required this.skin,
    required this.weapon,
    required this.tier,
    required this.searchKey,
    required this.nameKey,
    required this.weaponOrder,
    required this.quote,
  });

  final WeaponSkin skin;
  final Weapon? weapon;
  final ContentTier? tier;

  /// Folded "skin name + weapon name" for accent-insensitive search.
  final String searchKey;

  /// Folded skin name (sort by name).
  final String nameKey;

  /// Index of the weapon in `ContentDb.weapons` (category, then name).
  final int weaponOrder;

  /// B9 price (exact, estimate "≈", reward caption or "Không bán").
  final PriceQuote quote;

  String get uuid => skin.uuid;
  String get name => skin.displayName;

  /// 0 (Select) … 4 (Ultra); -1 without a tier.
  int get tierRank => tier?.rank ?? -1;

  /// VP used by the price sort (`null` = no price, sorted last).
  int? get sortPrice => quote.hasPrice ? quote.vp : null;

  /// Whether this skin passes [query]'s filters ([tokens] =
  /// `searchTokens(query.text)`).
  bool matches(SkinQuery query, List<String> tokens) {
    if (query.weaponUuid != null && skin.weaponUuid != query.weaponUuid) {
      return false;
    }
    if (query.tiers.isNotEmpty && !query.tiers.contains(skin.contentTierUuid)) {
      return false;
    }
    return tokens.isEmpty || matchesTokens(searchKey, tokens);
  }
}

/// Comparator for [sort] (ties broken by name, then uuid, so the order is
/// stable across rebuilds).
int Function(SkinFacts, SkinFacts) skinComparator(SkinSort sort) {
  int byName(SkinFacts a, SkinFacts b) {
    final c = a.nameKey.compareTo(b.nameKey);
    return c != 0 ? c : a.uuid.compareTo(b.uuid);
  }

  return switch (sort) {
    SkinSort.rarity => (a, b) {
      final c = b.tierRank.compareTo(a.tierRank);
      return c != 0 ? c : byName(a, b);
    },
    SkinSort.name => byName,
    SkinSort.weapon => (a, b) {
      final c = a.weaponOrder.compareTo(b.weaponOrder);
      return c != 0 ? c : byName(a, b);
    },
    SkinSort.price => (a, b) {
      final pa = a.sortPrice;
      final pb = b.sortPrice;
      if (pa != pb) {
        if (pa == null) return 1;
        if (pb == null) return -1;
        return pb.compareTo(pa);
      }
      final c = b.tierRank.compareTo(a.tierRank);
      return c != 0 ? c : byName(a, b);
    },
  };
}

/// [items] filtered by [query] and sorted by `query.sort`.
List<SkinFacts> applySkinQuery(Iterable<SkinFacts> items, SkinQuery query) {
  final tokens = searchTokens(query.text);
  return [
    for (final f in items)
      if (f.matches(query, tokens)) f,
  ]..sort(skinComparator(query.sort));
}

/// Every collectible weapon skin of the current content with its sort keys
/// (S3B), plus lookups for wishlist entries.
class SkinCatalog {
  SkinCatalog._({
    required this.db,
    required this.prices,
    required this.skins,
    required this.weapons,
    required this._weaponOrder,
  }) : _byUuid = {for (final f in skins) f.uuid: f};

  /// Builds the catalog (Standard and Random-favorite skins left out).
  factory SkinCatalog.build(ContentDb db, PriceService prices) {
    final order = <String, int>{
      for (final (i, w) in db.weapons.indexed) w.uuid: i,
    };
    final skins = <SkinFacts>[];
    final weapons = <Weapon>[];
    for (final w in db.weapons) {
      var any = false;
      for (final s in w.skins) {
        if (!s.isCollectible) continue;
        any = true;
        skins.add(_facts(s, w, db, prices, order));
      }
      if (any) weapons.add(w);
    }
    return SkinCatalog._(
      db: db,
      prices: prices,
      skins: List.unmodifiable(skins),
      weapons: List.unmodifiable(weapons),
      weaponOrder: order,
    );
  }

  static SkinFacts _facts(
    WeaponSkin s,
    Weapon? w,
    ContentDb db,
    PriceService prices,
    Map<String, int> order,
  ) {
    final name = foldForSearch(s.displayName);
    final weaponName = w == null ? '' : foldForSearch(w.displayName);
    return SkinFacts(
      skin: s,
      weapon: w,
      tier: db.contentTier(s.contentTierUuid),
      searchKey: weaponName.isEmpty || name.contains(weaponName)
          ? name
          : '$name $weaponName',
      nameKey: name,
      weaponOrder: order[s.weaponUuid] ?? order.length,
      quote: prices.priceForSkin(s.uuid),
    );
  }

  final ContentDb db;
  final PriceService prices;

  /// Collectible skins in weapon order (category, weapon name, content
  /// order).
  final List<SkinFacts> skins;

  /// Weapons that have at least one collectible skin (content order).
  final List<Weapon> weapons;
  final Map<String, int> _weaponOrder;
  final Map<String, SkinFacts> _byUuid;

  /// Content tiers for the tier filter (Select → Ultra).
  List<ContentTier> get tiers => db.contentTiers;

  /// Facts of the skin of any skin / level / chroma uuid; `null` when the
  /// content does not know it (new patch).
  SkinFacts? factsFor(String anySkinUuid) {
    final skin = db.skinByAnyUuid(anySkinUuid);
    if (skin == null) return null;
    return _byUuid[skin.uuid] ??
        _facts(skin, db.weapon(skin.weaponUuid), db, prices, _weaponOrder);
  }
}
