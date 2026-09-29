import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../community/ui/share_to_community_button.dart';
import '../../store_strings.dart';
import 'daily_offer_card.dart';
import 'store_ui_bits.dart';

/// S10 body: "Làm mới sau …" countdown pill with the "Tổng" total, a
/// summary of what is already owned / wishlisted, then the 4 daily cards.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: daily.expiresAt,
          builder: StoreStrings.resetsIn,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          trailing: daily.totalVp > 0
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${StoreStrings.dailyTotalLabel} ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                )
              : null,
        ),
        if (ownedCount > 0 || wishCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
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
