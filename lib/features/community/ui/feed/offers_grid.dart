import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';

/// Compact grid of the skins of a store / Night Market post: tier-tinted
/// tiles with render, name and VP price (names / images / tiers from the
/// vi-VN content).
class OffersGrid extends ConsumerWidget {
  const OffersGrid({
    super.key,
    required this.kind,
    required this.payload,
    this.interactive = true,
  });

  final PostKind kind;
  final PostPayload payload;

  /// Tiles open the skin sheet.
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final theme = Theme.of(context);
    final nightMarket = kind == PostKind.nightmarket;
    final accent = nightMarket ? const Color(0xFFB57BFF) : ValColors.red;
    final day = payload.dayMonth;
    final title = nightMarket
        ? (day == null
              ? CommunityStrings.kindNightMarket
              : CommunityStrings.nightMarketOf(day))
        : (day == null
              ? CommunityStrings.kindStore
              : CommunityStrings.storeOf(day));
    final offers = payload.offers;
    final rows = <Widget>[];
    for (var i = 0; i < offers.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 8));
      rows.add(
        Row(
          children: [
            Expanded(
              child: _OfferTile(
                offer: offers[i],
                db: db,
                nightMarket: nightMarket,
                interactive: interactive,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: i + 1 < offers.length
                  ? _OfferTile(
                      offer: offers[i + 1],
                      db: db,
                      nightMarket: nightMarket,
                      interactive: interactive,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ValRadius.small + 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
            // Wraps the total under the title when the text is large.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      nightMarket
                          ? Icons.nightlight_round
                          : Icons.storefront_rounded,
                      size: 16,
                      color: accent,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (payload.total > 0)
                  Text(
                    CommunityStrings.offersTotal(formatVp(payload.total)),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          ...rows,
        ],
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.offer,
    required this.db,
    required this.nightMarket,
    required this.interactive,
  });

  final PayloadOffer offer;
  final ContentDb db;
  final bool nightMarket;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skin = db.skinByAnyUuid(offer.skinUuid);
    final tier = db.contentTier(skin?.contentTierUuid);
    final tint = opaqueRgba(
      tier?.highlightColor,
      fallback: valColorsOf(context).muted,
    );
    final name = skin?.displayName ?? CommonStrings.unknownItem;
    final price = offer.price;
    final base = offer.baseCost;
    final percent = offer.discountPercent;
    final radius = BorderRadius.circular(ValRadius.small);
    return Semantics(
      button: interactive,
      label: price == null
          ? name
          : CommunityStrings.offerSemantics(name, formatVp(price)),
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: tint.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: !interactive
              ? null
              : () => unawaited(
                  showSkinDetailSheet(
                    context,
                    skinOrLevelUuid: offer.skinUuid,
                    mode: SkinDetailMode.catalog,
                  ),
                ),
          child: Ink(
            height: 118,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.32),
                  theme.colorScheme.surfaceContainer.withValues(alpha: 0),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: NetImage(
                            skin?.image,
                            fit: BoxFit.contain,
                            showSkeleton: false,
                          ),
                        ),
                        if (nightMarket && percent != null && percent > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: ValBadge(
                              formatDiscountPercent(percent),
                              color: valColorsOf(context).win,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: CurrencyColors.vp,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          price == null ? CommonStrings.dash : formatVp(price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (nightMarket && base != null && base != price) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            formatNumber(base),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
