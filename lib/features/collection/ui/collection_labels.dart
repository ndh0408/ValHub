import '../../../core/content/content_db.dart';
import '../../../core/l10n/l10n.dart';
import '../data/skin_query.dart';

extension CollectionSortDisplay on SkinSort {
  String label(AppLocalizations l10n) => switch (this) {
    SkinSort.rarity => l10n.collectionSortRarity,
    SkinSort.name => l10n.collectionSortName,
    SkinSort.weapon => l10n.collectionSortWeapon,
    SkinSort.price => l10n.collectionSortPrice,
  };
}

extension EquippedSkinDisplay on WeaponSkin {
  String equippedLabel(AppLocalizations l10n) =>
      isStandard ? l10n.collectionDefaultSkin : displayName;
}
