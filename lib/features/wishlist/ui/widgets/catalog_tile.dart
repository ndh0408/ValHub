import 'package:valvn/core/l10n/labels/economy_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/net_image.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../data/skin_query.dart';
import '../../wishlist_strings.dart';
import 'skin_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
        quote.caption(context.l10n) ??
        (quote.vp == null
            ? context.l10n.commonDash
            : (quote.isEstimate
                  ? context.fmt.estimatedVp(quote.vp!)
                  : context.fmt.vp(quote.vp!)));

    return Semantics(
      container: true,
      label: WishlistStrings.tileSemantics(facts.name, priceText, inWishlist),
      child: TierGradientCard(
        tint: tint,
        borderColor: inWishlist
            ? theme.colorScheme.primary.withValues(alpha: 0.8)
            : null,
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
                      message: context.l10n.wishlistOwned,
                      child: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: colors.win,
                        semanticLabel: context.l10n.wishlistOwned,
                      ),
                    ),
                  if (puuid != null)
                    _HeartButton(
                      active: inWishlist,
                      onTap: () {
                        Haptics.light();
                        unawaited(
                          ref
                              .read(wishlistProvider(puuid).notifier)
                              .toggleSkin(facts.uuid, db),
                        );
                      },
                    )
                  else
                    const SizedBox(height: 40),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 10, 6),
                  child: NetImage(
                    facts.skin.image,
                    fit: BoxFit.contain,
                    showSkeleton: false,
                  ),
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
    final accent = Theme.of(context).colorScheme.primary;
    return IconButton(
      onPressed: onTap,
      tooltip: active
          ? context.l10n.wishlistRemoveFromWishlist
          : context.l10n.wishlistAddToWishlist,
      isSelected: active,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: AnimatedSwitcher(
        duration: ValMotion.fast,
        transitionBuilder: (child, a) =>
            ScaleTransition(scale: a, child: child),
        child: Icon(
          active ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(active),
          size: 20,
          color: active ? accent : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
