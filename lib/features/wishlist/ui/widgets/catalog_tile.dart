import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../data/skin_query.dart';
import '../../wishlist_strings.dart';
import 'skin_bits.dart';

/// S3B grid tile: edition, render, name, price and the wishlist heart.
/// Tap → S15 (catalog mode). Only this tile rebuilds when its heart flips.
class CatalogSkinTile extends ConsumerWidget {
  const CatalogSkinTile({
    super.key,
    required this.facts,
    required this.db,
    required this.puuid,
  });

  final SkinFacts facts;
  final ContentDb db;

  /// Active account (`null` hides the heart).
  final String? puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final puuid = this.puuid;
    final inWishlist =
        puuid != null &&
        ref.watch(
          wishlistProvider(puuid)
              .select((s) => wishlistContains(s, facts.uuid, db)),
        );
    final owned =
        puuid != null &&
        ref.watch(
          ownedItemsProvider(puuid)
              .select((v) => v.value?.isSkinOwned(facts.uuid) ?? false),
        );
    final tint = contentTierTint(
      ref,
      facts.skin.contentTierUuid,
      fallback: colors.muted,
    );
    final quote = facts.quote;
    final priceText =
        quote.caption ??
        (quote.vp == null
            ? CommonStrings.dash
            : (quote.isEstimate
                  ? formatEstimatedVp(quote.vp!)
                  : formatVp(quote.vp!)));

    return Semantics(
      container: true,
      label: WishlistStrings.tileSemantics(facts.name, priceText, inWishlist),
      child: TierGradientCard(
        tint: tint,
        borderColor: inWishlist ? ValColors.red.withValues(alpha: 0.7) : null,
        onTap: () => unawaited(
          showSkinDetailSheet(
            context,
            skinOrLevelUuid: facts.uuid,
            mode: SkinDetailMode.catalog,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ContentTierBadge(
                    contentTierUuid: facts.skin.contentTierUuid,
                    size: 16,
                  ),
                  const Spacer(),
                  if (owned)
                    Tooltip(
                      message: WishlistStrings.owned,
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: colors.win,
                      ),
                    ),
                  if (puuid != null)
                    _HeartButton(
                      active: inWishlist,
                      onTap: () => unawaited(
                        ref
                            .read(wishlistProvider(puuid).notifier)
                            .toggleSkin(facts.uuid, db),
                      ),
                    )
                  else
                    const SizedBox(height: 40),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 10, 6),
                  child: NetImage(facts.skin.image, fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  facts.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: SkinPriceText(
                  quote: quote,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: active
          ? WishlistStrings.removeFromWishlist
          : WishlistStrings.addToWishlist,
      isSelected: active,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Icon(
        active ? Icons.favorite : Icons.favorite_border,
        size: 20,
        color: active ? ValColors.red : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
