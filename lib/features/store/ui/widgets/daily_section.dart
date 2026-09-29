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
import '../../store_strings.dart';
import '../share/store_share_sheet.dart';
import 'daily_offer_card.dart';
import 'store_ui_bits.dart';

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
      return const EmptyView(
        title: StoreStrings.dailyEmptyTitle,
        message: StoreStrings.dailyEmpty,
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
          builder: StoreStrings.resetsIn,
          // The daily shop always resets at the same local time.
          note: expiresAt == null
              ? null
              : StoreStrings.dailyResetAt(formatTime(expiresAt)),
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
                            '${StoreStrings.dailyTotalLabel} ',
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
                  label: StoreStrings.ownedCount(
                    ownedCount,
                    daily.offers.length,
                  ),
                  color: colors.win,
                ),
              if (wishCount > 0)
                StoreStatChip(
                  icon: Icons.favorite,
                  label: StoreStrings.wishlistCount(wishCount),
                  color: ValColors.red,
                ),
            ],
            action: StoreActionPill(
              icon: isCupertino(context) ? Icons.ios_share : Icons.share,
              label: StoreStrings.shareImage,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < daily.offers.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                DailyOfferCard(
                  key: ValueKey(daily.offers[i].skinLevelUuid),
                  offer: daily.offers[i],
                  puuid: puuid,
                ),
              ],
            ],
          ),
        ),
        ShareToCommunityButton.daily(daily),
      ],
    );
  }
}
