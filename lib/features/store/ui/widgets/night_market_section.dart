import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/util/format.dart';
import '../../store_strings.dart';
import 'night_market_card.dart';
import 'store_ui_bits.dart';

/// S11 body: countdown, up to 6 cards, total-savings footer, info note.
class NightMarketSection extends StatelessWidget {
  const NightMarketSection({
    super.key,
    required this.nightMarket,
    required this.puuid,
  });

  final NightMarket? nightMarket;
  final String puuid;

  @override
  Widget build(BuildContext context) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: nm.expiresAt,
          builder: StoreStrings.nightMarketEndsIn,
          period: const Duration(days: 14),
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
                  child: Text(
                    StoreStrings.nightMarketTotalSavings(
                      formatVp(nm.totalSavings),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: win,
                      fontWeight: FontWeight.w700,
                    ),
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
