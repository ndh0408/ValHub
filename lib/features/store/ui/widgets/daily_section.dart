import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/price_estimate.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../../community/ui/share_to_community_button.dart';
import '../../providers/store_share.dart';
import '../share/store_share_sheet.dart';
import 'daily_offer_card.dart';
import 'store_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

import '../../store_routes.dart';

/// S10 body: "Làm mới sau …" countdown with the local reset time and the
/// "Tổng" total (+ VND estimate), what is already owned / wishlisted,
/// "Chia sẻ ảnh", then the 4 daily cards.
class DailySection extends ConsumerWidget {
  const DailySection({super.key, required this.daily, required this.puuid});

  final DailyStore daily;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (daily.isEmpty) {
      return EmptyView(
        title: context.l10n.storeDailyEmptyTitle,
        message: context.l10n.storeDailyEmpty,
        icon: Icons.storefront_outlined,
      );
    }
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final owned = ref.watch(ownedItemsProvider(puuid)).value;
    final wishlist = ref.watch(wishlistProvider(puuid));
    final ownedCount = owned == null
        ? 0
        : daily.offers.where((o) => owned.isSkinOwned(o.skinLevelUuid)).length;
    final wishCount = daily.offers
        .where((o) => wishlistContains(wishlist, o.skinLevelUuid, db))
        .length;
    final colors = valColorsOf(context);
    final expiresAt = daily.expiresAt;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: expiresAt,
          builder: context.l10n.storeResetsIn,
          // The daily shop always resets at the same local time.
          note: expiresAt == null
              ? null
              : context.l10n.storeDailyResetAt(
                  formatTime(roundToMinute(expiresAt)),
                ),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          trailing: daily.totalVp > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${context.l10n.storeDailyTotalLabel} ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                          CurrencyAmount.vp(
                            daily.totalVp,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PriceEstimate(daily.totalVp),
                  ],
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: StoreSummaryRow(
            chips: [
              if (ownedCount > 0)
                StoreStatChip(
                  icon: Icons.check_circle_outline,
                  label: context.l10n.storeOwnedCount(
                    ownedCount,
                    daily.offers.length,
                  ),
                  color: colors.win,
                ),
              if (wishCount > 0)
                StoreStatChip(
                  icon: Icons.favorite,
                  label: context.l10n.storeWishlistCount(wishCount),
                  color: ValColors.red,
                  onTap: () => unawaited(context.push(StoreRoutes.wishlist)),
                ),
            ],
            action: StoreActionPill(
              icon: isCupertino(context) ? Icons.ios_share : Icons.share,
              label: context.l10n.storeShareImage,
              onTap: () => unawaited(
                showStoreShareSheet(
                  context,
                  data: shareDataForDaily(
                    daily,
                    db,
                    ref.read(clockProvider).now(),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final wide = constraints.maxWidth >= 600;
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < daily.offers.length; i++) ...[
                      if (i > 0) const SizedBox(height: gap),
                      DailyOfferCard(
                        key: ValueKey(daily.offers[i].skinLevelUuid),
                        offer: daily.offers[i],
                        puuid: puuid,
                      ),
                    ],
                  ],
                );
              }
              final cardWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final offer in daily.offers)
                    SizedBox(
                      width: cardWidth,
                      child: DailyOfferCard(
                        key: ValueKey(offer.skinLevelUuid),
                        offer: offer,
                        puuid: puuid,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        ShareToCommunityButton.daily(daily),
      ],
    );
  }
}
