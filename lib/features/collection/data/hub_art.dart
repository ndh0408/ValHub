import '../../../core/content/content_db.dart';

/// First non-empty image of [items] (the item order is the content order, so
/// this is only used for kinds without a rarity, such as sprays or cards).
String? firstImage<T>(Iterable<T> items, String? Function(T) image) {
  for (final item in items) {
    final url = image(item);
    if (url != null && url.isNotEmpty) return url;
  }
  return null;
}

/// The skin to show on the "Skin" hub row: the rarest owned skin that has an
/// image (highest content tier rank); among equals the last one in content
/// order, i.e. the newest release.
String? showcaseSkinImage(Iterable<WeaponSkin> skins, ContentDb db) {
  String? best;
  var bestRank = -1;
  for (final skin in skins) {
    final url = skin.image;
    if (url == null || url.isEmpty) continue;
    final rank = db.contentTier(skin.contentTierUuid)?.rank ?? 0;
    if (rank >= bestRank) {
      best = url;
      bestRank = rank;
    }
  }
  return best;
}
