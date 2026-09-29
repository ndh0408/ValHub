/// The storefront copy saved on this device for each account, read without
/// any network call (skin availability in other accounts, Home's "Tài khoản
/// khác" card, reset reminders of accounts that are not active).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_db.dart';
import '../../storage/json_file_cache.dart';
import 'storefront.dart';

/// Whether [store] still sells any level of [skin] at [now] (daily shop,
/// Night Market or a bundle whose countdown has not ended).
bool storefrontSellsSkin(Storefront store, WeaponSkin skin, DateTime now) {
  final levels = {for (final l in skin.levels) l.uuid};
  if (levels.isEmpty) return false;
  bool live(DateTime? expiresAt) => expiresAt != null && expiresAt.isAfter(now);

  if (live(store.daily.expiresAt) &&
      store.daily.offers.any((o) => levels.contains(o.skinLevelUuid))) {
    return true;
  }
  final nm = store.nightMarket;
  if (nm != null &&
      live(nm.expiresAt) &&
      nm.offers.any((o) => levels.contains(o.skinLevelUuid))) {
    return true;
  }
  return store.bundles.any(
    (b) =>
        live(b.expiresAt) &&
        b.skinItems.any((i) => levels.contains(i.item.itemId)),
  );
}

/// The saved storefront of [puuid] (`acct/<puuid>/economy_storefront`,
/// written by `storefrontProvider` after every fetch), or `null`. Never
/// calls Riot.
final savedStorefrontProvider = FutureProvider.autoDispose
    .family<Storefront?, String>((ref, puuid) async {
      try {
        final cached = await ref
            .watch(jsonFileCacheProvider)
            .read(
              JsonFileCache.accountKey(
                puuid.toLowerCase(),
                'economy_storefront',
              ),
            );
        if (cached == null || cached.data == null) return null;
        return Storefront.fromJson(
          cached.data,
          receivedAt: cached.savedAt,
          isFromCache: true,
        );
      } on Object {
        return null;
      }
    });
