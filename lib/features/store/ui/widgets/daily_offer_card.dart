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
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../store_strings.dart';
import 'store_ui_bits.dart';

/// S10 daily-shop card, image-forward (ValBuddy style): full width, ~2.2:1,
/// tier-tinted background with a soft glow and a large centered render;
/// bottom row = tier icon + name, VP icon + price. "Đã sở hữu" and the
/// wishlist heart stay small in the top corners. Tap → S15.
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
      // Full-width ~2.2:1 card: large centered render on the tier-tinted
      // background, then tier icon + name (left) and VP price (right).
      child: AspectRatio(
        aspectRatio: 2.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SkinGlowArt(
                    imageUrl: skin?.image,
                    tint: tint,
                    padding: const EdgeInsets.fromLTRB(36, 14, 36, 2),
                  ),
                  if (owned)
                    const PositionedDirectional(
                      top: 10,
                      start: 12,
                      child: OwnedBadge(),
                    ),
                  PositionedDirectional(
                    top: 2,
                    end: 2,
                    child: WishlistHeartButton(
                      active: inWishlist,
                      size: 16,
                      subtle: true,
                      onTap: () => unawaited(
                        ref
                            .read(wishlistProvider(puuid).notifier)
                            .toggleSkin(offer.skinLevelUuid, db),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  ContentTierBadge(
                    contentTierUuid: skin?.contentTierUuid,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: price == null
                          ? Text(
                              CommonStrings.dash,
                              style: theme.textTheme.bodyLarge,
                            )
                          : CurrencyAmount.vp(
                              price,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
