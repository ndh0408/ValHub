import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../store_routes.dart';
import '../../store_strings.dart';
import 'store_ui_bits.dart';

/// S13 bundle banner: art, name, price (with the bundle discount) and
/// "Còn …" countdown. Tap → S14.
class BundleBanner extends ConsumerWidget {
  const BundleBanner({super.key, required this.bundle});

  final StoreBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref
        .watch(contentProvider)
        .value
        ?.bundleByUuid(bundle.dataAssetId);
    final name = content?.displayName ?? CommonStrings.unknownItem;
    final expiresAt = bundle.expiresAt;
    final theme = Theme.of(context);
    const onArt = Colors.white;

    return Semantics(
      button: true,
      label: StoreStrings.offerSemantics(
        name,
        '${formatNumber(bundle.price)} ${currencyOf(ref, bundle.currencyId)?.label ?? ''}'
            .trim(),
      ),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(StoreRoutes.bundle(bundle.id)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(content?.cardImage, fit: BoxFit.cover),
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
                          CurrencyAmount(
                            currencyId: bundle.currencyId,
                            amount: bundle.price,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: onArt,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (expiresAt != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: CountdownText(
                                    expiresAt: expiresAt,
                                    builder: StoreStrings.bundleEndsIn,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
