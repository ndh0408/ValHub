import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/util/format.dart';
import '../../store_strings.dart';

/// Common-header wallet: ONE full-width pill with the VP / KC / RP balances
/// centered side by side, each with its currency icon (VF §6.2).
class WalletPill extends ConsumerWidget {
  const WalletPill({super.key, required this.puuid});

  final String puuid;

  static const _ids = [CurrencyIds.vp, CurrencyIds.kc, CurrencyIds.rp];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider(puuid));
    final w = wallet.value;
    final Widget content;
    if (w != null) {
      content = Semantics(
        label: StoreStrings.walletSemantics(
          formatNumber(w.vp),
          formatNumber(w.kc),
          formatNumber(w.rp),
        ),
        excludeSemantics: true,
        child: _Pill(amounts: [w.vp, w.kc, w.rp]),
      );
    } else if (wallet.hasError && !wallet.isLoading) {
      // Balances are secondary: show dashes instead of an error block.
      content = const _Pill(amounts: [null, null, null]);
    } else {
      content = const Skeleton(height: 44, radius: 22);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AnimatedSwitcher(duration: ValMotion.medium, child: content),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.amounts});

  final List<int?> amounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.pill),
        border: Border.all(color: valColorsOf(context).hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < WalletPill._ids.length; i++)
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: amounts[i] == null
                      ? Text(CommonStrings.dash, style: style)
                      : CurrencyAmount(
                          currencyId: WalletPill._ids[i],
                          amount: amounts[i]!,
                          iconSize: 18,
                          style: style,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
