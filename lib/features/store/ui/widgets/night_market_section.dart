import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/price_estimate.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../../community/ui/share_to_community_button.dart';
import '../../providers/store_share.dart';
import '../../store_strings.dart';
import '../share/store_share_sheet.dart';
import 'night_market_card.dart';
import 'store_ui_bits.dart';

/// S11 body: countdown (+ local end time), "Chia sẻ ảnh", up to 6 cards,
/// total-savings footer (+ VND estimate), info note.
class NightMarketSection extends ConsumerWidget {
  const NightMarketSection({
    super.key,
    required this.nightMarket,
    required this.puuid,
  });

  final NightMarket? nightMarket;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nm = nightMarket;
    if (nm == null || nm.offers.isEmpty) {
      return const EmptyView(
        title: StoreStrings.nightMarketEmptyTitle,
        message: StoreStrings.nightMarketEmpty,
        icon: Icons.nightlight_outlined,
      );
    }
    final theme = Theme.of(context);
    final win = valColorsOf(context).win;
    final expiresAt = nm.expiresAt;
    final now = ref.watch(clockProvider).now();
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final owned = ref.watch(ownedItemsProvider(puuid)).value;
    final wishlist = ref.watch(wishlistProvider(puuid));
    final ownedCount = owned == null
        ? 0
        : nm.offers.where((o) => owned.isSkinOwned(o.skinLevelUuid)).length;
    final wishCount = nm.offers
        .where((o) => wishlistContains(wishlist, o.skinLevelUuid, db))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: expiresAt,
          builder: StoreStrings.nightMarketEndsIn,
          note: expiresAt == null
              ? null
              : StoreStrings.nightMarketEndsAt(formatWallTime(expiresAt, now)),
          period: const Duration(days: 14),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: StoreSummaryRow(
            chips: [
              if (ownedCount > 0)
                StoreStatChip(
                  icon: Icons.check_circle_outline,
                  label: StoreStrings.ownedCount(ownedCount, nm.offers.length),
                  color: win,
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
                  data: shareDataForNightMarket(
                    nm,
                    db,
                    ref.read(clockProvider).now(),
                  ),
                ),
              ),
            ),
          ),
        ),
        TwoColumnGrid(
          children: [
            for (final o in nm.offers)
              NightMarketCard(
                key: ValueKey(o.bonusOfferId),
                offer: o,
                puuid: puuid,
              ),
          ],
        ),
        ShareToCommunityButton.nightMarket(nm),
        if (nm.totalSavings > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  win.withValues(alpha: 0.20),
                  win.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(ValRadius.small),
              border: Border.all(color: win.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.savings_outlined, size: 18, color: win),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StoreStrings.nightMarketTotalSavings(
                          formatVp(nm.totalSavings),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: legibleAccent(context, win),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      PriceEstimate(nm.totalSavings),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  StoreStrings.nightMarketNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
