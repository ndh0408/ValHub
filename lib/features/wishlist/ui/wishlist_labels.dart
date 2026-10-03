import '../../../core/l10n/l10n.dart';
import '../data/skin_query.dart';

extension WishlistSortDisplay on SkinSort {
  String label(AppLocalizations l10n) => switch (this) {
    SkinSort.rarity => l10n.wishlistSortRarity,
    SkinSort.name => l10n.wishlistSortName,
    SkinSort.weapon => l10n.wishlistSortWeapon,
    SkinSort.price => l10n.wishlistSortPrice,
  };
}
