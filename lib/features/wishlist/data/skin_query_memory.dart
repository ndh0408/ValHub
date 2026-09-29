import '../../../core/storage/ui_memory.dart';
import 'skin_query.dart';

/// Remembers the sort order and filters (not the search text) of a skin
/// list across launches, under `UiMemory` keys `<screen>.sort`,
/// `<screen>.tiers` and `<screen>.weapon` (e.g. `catalog.sort`).
class SkinQueryMemory {
  const SkinQueryMemory(this._memory, this.screen);

  /// `UiMemory` key of the wishlist screen (S3A).
  static const wishlist = 'wishlist';

  /// `UiMemory` key of the all-skins catalog (S3B).
  static const catalog = 'catalog';

  final UiMemory _memory;
  final String screen;

  /// The remembered query, or the default (rarity first, no filter).
  /// [rememberWeapon] is off for lists without a weapon filter.
  SkinQuery load({bool rememberWeapon = true}) {
    final tiers = _memory.read('$screen.tiers');
    final weapon = rememberWeapon ? _memory.read('$screen.weapon') : null;
    return SkinQuery(
      sort: _memory.readEnum('$screen.sort', SkinSort.values, SkinSort.rarity),
      tiers: tiers == null || tiers.isEmpty
          ? const {}
          : {
              for (final t in tiers.split(','))
                if (t.trim().isNotEmpty) t.trim(),
            },
      weaponUuid: weapon == null || weapon.isEmpty ? null : weapon,
    );
  }

  /// Stores [query]'s sort and filters when they differ from [previous].
  void save(SkinQuery query, {SkinQuery? previous}) {
    if (previous == null || previous.sort != query.sort) {
      _memory.writeEnum('$screen.sort', query.sort);
    }
    if (previous == null || !_sameSet(previous.tiers, query.tiers)) {
      _memory.write(
        '$screen.tiers',
        query.tiers.isEmpty ? null : (query.tiers.toList()..sort()).join(','),
      );
    }
    if (previous == null || previous.weaponUuid != query.weaponUuid) {
      _memory.write('$screen.weapon', query.weaponUuid);
    }
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
