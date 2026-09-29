/// Remembers the tier filter and sort of each skin list across launches
/// (the search text is intentionally not remembered).
library;

import '../../../core/storage/ui_memory.dart';
import 'skin_query.dart';

/// `UiMemory` keys of the collection screens.
abstract final class CollectionMemoryKeys {
  static const browseSkins = 'collection.browse.skin';
  static const weaponSkins = 'collection.weaponSkins';
  static const expressionsTab = 'collection.expressions.tab';
}

/// The remembered [SkinQuery] of [screen] (no search), limited to
/// [allowedSorts]; defaults to rarity-first without tier filter.
SkinQuery readSkinQuery(
  UiMemory memory,
  String screen, {
  List<SkinSort> allowedSorts = SkinSort.values,
}) {
  var sort = memory.readEnum('$screen.sort', SkinSort.values, SkinSort.rarity);
  if (!allowedSorts.contains(sort)) sort = SkinSort.rarity;
  final raw = memory.read('$screen.tiers') ?? '';
  final tiers = {
    for (final t in raw.split(','))
      if (kContentTierOrder.contains(t.trim().toLowerCase()))
        t.trim().toLowerCase(),
  };
  return SkinQuery(sort: sort, tiers: tiers);
}

/// Stores the sort and tier filter of [query] for [screen].
void writeSkinQuery(UiMemory memory, String screen, SkinQuery query) {
  memory
    ..writeEnum('$screen.sort', query.sort)
    ..write(
      '$screen.tiers',
      query.tiers.isEmpty ? null : (query.tiers.toList()..sort()).join(','),
    );
}
