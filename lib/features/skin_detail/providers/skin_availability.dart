/// "Có trong cửa hàng của: …" (VF §6.2 S15, optional): which of the user's
/// other accounts currently sell a skin, read from the storefront copies
/// already saved on this device. It never calls Riot, so opening a skin
/// from the collection does not fetch up to nine storefronts.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/storage/json_file_cache.dart';
import '../../../core/util/clock.dart';

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
/// written by `storefrontProvider` after every fetch), or `null`.
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

/// Other signed-in accounts whose saved storefront sells [skinUuid] (any
/// skin, level or chroma uuid) right now.
final skinAvailableElsewhereProvider = FutureProvider.autoDispose
    .family<List<Account>, String>((ref, skinUuid) async {
      final db = ref.watch(contentProvider).value;
      final skin = db?.skinByAnyUuid(skinUuid);
      if (skin == null || !skin.isCollectible) return const [];
      final active = ref.watch(activeAccountProvider)?.puuid;
      final others = ref
          .watch(accountsProvider)
          .where((a) => a.puuid != active)
          .toList();
      if (others.isEmpty) return const [];
      final now = ref.read(clockProvider).now();
      final stores = await Future.wait([
        for (final a in others)
          ref.watch(savedStorefrontProvider(a.puuid).future),
      ]);
      return [
        for (var i = 0; i < others.length; i++)
          if (stores[i] case final s? when storefrontSellsSkin(s, skin, now))
            others[i],
      ];
    });
