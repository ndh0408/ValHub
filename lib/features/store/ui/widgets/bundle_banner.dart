import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_ring.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/price_estimate.dart';
import '../../../../core/util/format.dart';
import '../../store_routes.dart';
import 'store_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Hero tag shared by the bundle banner art and the S14 hero.
Object bundleArtHeroTag(String bundleId) => ('bundle-art', bundleId);

/// S13 bundle banner: art, name, price (with the bundle discount, VND
/// estimate) and "Còn …" countdown. Tap → S14 (the art flies into its hero).
class BundleBanner extends ConsumerWidget {
  const BundleBanner({super.key, required this.bundle});

  final StoreBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref
        .watch(contentProvider)
        .value
        ?.bundleByUuid(bundle.dataAssetId);
    final name = content?.displayName ?? context.l10n.commonUnknownItem;
    final expiresAt = bundle.expiresAt;
    final theme = Theme.of(context);
    const onArt = Colors.white;

    return Semantics(
      button: true,
      label: context.l10n.storeOfferSemantics(
        name,
        '${formatNumber(bundle.price)} ${currencyOf(ref, bundle.currencyId)?.label(context.l10n) ?? ''}'
            .trim(),
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(StoreRoutes.bundle(bundle.id)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: bundleArtHeroTag(bundle.id),
                  child: NetImage(content?.cardImage, fit: BoxFit.cover),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.3, 1],
                    ),
                  ),
                ),
                if (bundle.discountPercent > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: StoreBadge(
                      formatDiscountPercent(bundle.discountPercent),
                      color: ValColors.red,
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.6,
                          color: onArt,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (bundle.savings > 0)
                            CurrencyAmount(
                              currencyId: bundle.currencyId,
                              amount: bundle.itemsTotal,
                              iconSize: 12,
                              strikethrough: true,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          CurrencyAmount(
                            currencyId: bundle.currencyId,
                            amount: bundle.price,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: onArt,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (bundle.currencyId == CurrencyIds.vp)
                            PriceEstimate(
                              bundle.price,
                              interactive: false,
                              color: Colors.white70,
                            ),
                          if (expiresAt != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(
                                  ValRadius.pill,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CountdownRing(
                                    expiresAt: expiresAt,
                                    period: const Duration(days: 14),
                                    size: 13,
                                    strokeWidth: 2,
                                    color: onArt,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: CountdownText(
                                      expiresAt: expiresAt,
                                      builder: context.l10n.storeBundleEndsIn,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
