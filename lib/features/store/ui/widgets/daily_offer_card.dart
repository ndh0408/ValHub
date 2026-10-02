import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/price_estimate.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../../skin_detail/community_skin_score.dart';
import 'store_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S10 daily-shop card, image-forward (ValBuddy style): full width, ~2.8:1,
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
    final name = skin?.displayName ?? context.l10n.commonUnknownItem;
    final price = offer.vpCost;
    final roomyText = MediaQuery.textScalerOf(context).scale(1) <= 1.35;

    return TierCard(
      tint: tint,
      semanticsLabel: context.l10n.storeOfferSemantics(
        name,
        price == null ? context.l10n.commonDash : formatVp(price),
      ),
      onTap: () => unawaited(
        showSkinDetailSheet(
          context,
          skinOrLevelUuid: offer.skinLevelUuid,
          mode: SkinDetailMode.store,
        ),
      ),
      // Full-width ~2.8:1 card: large centered render on the tier-tinted
      // background, then tier icon + name (left) and VP price (right).
      child: AspectRatio(
        aspectRatio: 2.8,
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
                    padding: const EdgeInsets.fromLTRB(48, 10, 48, 0),
                  ),
                  if (owned)
                    const PositionedDirectional(
                      top: 10,
                      start: 12,
                      child: OwnedBadge(),
                    ),
                  if (skin != null)
                    PositionedDirectional(
                      start: 12,
                      end: 12,
                      bottom: 2,
                      child: CommunitySkinScore(skinUuid: skin.uuid),
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
                  // Intrinsic width, pinned right: the name takes the rest.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: price == null
                              ? Text(
                                  context.l10n.commonDash,
                                  style: theme.textTheme.bodyLarge,
                                )
                              : CurrencyAmount.vp(
                                  price,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        // The fixed 2.8:1 card has no room for a second
                        // line at very large text sizes.
                        if (price != null && roomyText)
                          PriceEstimate(
                            price,
                            interactive: false,
                            style: theme.textTheme.labelSmall,
                          ),
                      ],
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
