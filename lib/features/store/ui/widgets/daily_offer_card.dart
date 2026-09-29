import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../store_strings.dart';
import 'store_ui_bits.dart';

/// S10 daily-shop card: tier-tinted gradient, render, tier, name, VP price,
/// "Đã sở hữu" and wishlist heart. Tap → S15.
class DailyOfferCard extends ConsumerWidget {
  const DailyOfferCard({super.key, required this.offer, required this.puuid});

  final DailyOffer offer;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final skin = db.skinByLevelUuid(offer.skinLevelUuid);
    final theme = Theme.of(context);
    final tint = contentTierTint(
      ref,
      skin?.contentTierUuid,
      fallback: valColorsOf(context).muted,
    );
    final owned =
        ref
            .watch(ownedItemsProvider(puuid))
            .value
            ?.isSkinOwned(offer.skinLevelUuid) ??
        false;
    final inWishlist = wishlistContains(
      ref.watch(wishlistProvider(puuid)),
      offer.skinLevelUuid,
      db,
    );
    final name = skin?.displayName ?? CommonStrings.unknownItem;
    final price = offer.vpCost;

    return TierCard(
      tint: tint,
      semanticsLabel: StoreStrings.offerSemantics(
        name,
        price == null ? CommonStrings.dash : formatVp(price),
      ),
      onTap: () => unawaited(
        showSkinDetailSheet(
          context,
          skinOrLevelUuid: offer.skinLevelUuid,
          mode: SkinDetailMode.store,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TierLabel(contentTierUuid: skin?.contentTierUuid),
                  ),
                ),
                if (owned) ...[const OwnedBadge(), const SizedBox(width: 6)],
                WishlistHeartButton(
                  active: inWishlist,
                  onTap: () => unawaited(
                    ref
                        .read(wishlistProvider(puuid).notifier)
                        .toggleSkin(offer.skinLevelUuid, db),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 92,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: NetImage(skin?.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (price == null)
                  Text(CommonStrings.dash, style: theme.textTheme.titleMedium)
                else
                  CurrencyAmount.vp(
                    price,
                    iconSize: 18,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
