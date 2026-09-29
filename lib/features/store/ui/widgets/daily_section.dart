import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/empty_view.dart';
import '../../store_strings.dart';
import 'daily_offer_card.dart';
import 'store_ui_bits.dart';

/// S10 body: "Làm mới sau …" countdown with the "Tổng" total, then the 4
/// daily cards.
class DailySection extends StatelessWidget {
  const DailySection({super.key, required this.daily, required this.puuid});

  final DailyStore daily;
  final String puuid;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) {
      return const EmptyView(
        message: StoreStrings.dailyEmpty,
        icon: Icons.storefront_outlined,
      );
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: daily.expiresAt,
          builder: StoreStrings.resetsIn,
          trailing: daily.totalVp > 0
              ? Row(
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
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < daily.offers.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                DailyOfferCard(offer: daily.offers[i], puuid: puuid),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
