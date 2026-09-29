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

/// S11 Night Market card: `-xx%` badge, skin, struck "giá gốc" and the
/// "giá ưu đãi". Tap → S15.
class NightMarketCard extends ConsumerWidget {
  const NightMarketCard({super.key, required this.offer, required this.puuid});

  final NightMarketOffer offer;
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
    final base = offer.basePrice;
    final discounted = offer.discountedPrice;

    return TierCard(
      tint: tint,
      semanticsLabel: StoreStrings.offerSemantics(
        name,
        [
          if (discounted != null) formatVp(discounted),
          if (offer.discountPercent > 0)
            formatDiscountPercent(offer.discountPercent),
        ].join(' '),
      ),
      onTap: () => unawaited(
        showSkinDetailSheet(
          context,
          skinOrLevelUuid: offer.skinLevelUuid,
          mode: SkinDetailMode.store,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (offer.discountPercent > 0)
                  StoreBadge(
                    formatDiscountPercent(offer.discountPercent),
                    color: ValColors.red,
                  ),
                const Spacer(),
                WishlistHeartButton(
                  active: inWishlist,
                  size: 16,
                  onTap: () => unawaited(
                    ref
                        .read(wishlistProvider(puuid).notifier)
                        .toggleSkin(offer.skinLevelUuid, db),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AspectRatio(
              aspectRatio: 16 / 7,
              child: NetImage(skin?.image, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            ContentTierBadge(contentTierUuid: skin?.contentTierUuid, size: 14),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (owned) ...[const SizedBox(height: 4), const OwnedBadge()],
            const Spacer(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (base != null && base != discounted)
                  CurrencyAmount.vp(
                    base,
                    iconSize: 12,
                    strikethrough: true,
                    style: theme.textTheme.bodySmall,
                  ),
                if (discounted != null)
                  CurrencyAmount.vp(
                    discounted,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valColorsOf(context).win,
                    ),
                  )
                else
                  Text(CommonStrings.dash, style: theme.textTheme.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
