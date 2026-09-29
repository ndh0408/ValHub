/// Weapons grouped by category for S33 "Trang bị vũ khí" (app-owned vi
/// labels keyed by the `category` enum, SUMMARY §1 #18).
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/models/weapon_models.dart';
import 'collection_search.dart';

/// Display order of the categories (in-game buy menu order, melee last).
const kWeaponCategoryOrder = [
  WeaponCategory.sidearm,
  WeaponCategory.smg,
  WeaponCategory.shotgun,
  WeaponCategory.rifle,
  WeaponCategory.sniper,
  WeaponCategory.heavy,
  WeaponCategory.unknown,
  WeaponCategory.melee,
];

/// One category and its weapons.
@immutable
class WeaponSection {
  const WeaponSection(this.category, this.weapons);

  final WeaponCategory category;
  final List<Weapon> weapons;
}

int _compareWeapons(Weapon a, Weapon b) {
  final ca = kWeaponCategoryOrder.indexOf(a.category);
  final cb = kWeaponCategoryOrder.indexOf(b.category);
  if (ca != cb) return ca.compareTo(cb);
  // Cheapest first inside a category (Classic → Sheriff), like the buy menu.
  final pa = a.shopCost ?? 1 << 20;
  final pb = b.shopCost ?? 1 << 20;
  if (pa != pb) return pa.compareTo(pb);
  return compareNames(a.displayName, b.displayName);
}

/// [weapons] in category order, cheapest first inside a category.
List<Weapon> orderedWeapons(Iterable<Weapon> weapons) =>
    [...weapons]..sort(_compareWeapons);

/// Non-empty sections in [kWeaponCategoryOrder]. With [onlyIds] only those
/// weapon uuids are kept (the guns of the player's loadout).
List<WeaponSection> weaponSections(
  Iterable<Weapon> weapons, {
  Set<String>? onlyIds,
}) {
  final byCategory = <WeaponCategory, List<Weapon>>{};
  for (final w in orderedWeapons(weapons)) {
    if (onlyIds != null && !onlyIds.contains(w.uuid)) continue;
    byCategory.putIfAbsent(w.category, () => []).add(w);
  }
  return [
    for (final c in kWeaponCategoryOrder)
      if (byCategory[c] case final list?)
        WeaponSection(c, List.unmodifiable(list)),
  ];
}
