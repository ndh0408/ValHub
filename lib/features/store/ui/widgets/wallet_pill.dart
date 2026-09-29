import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../store_strings.dart';

/// Common-header wallet pill: VP / KC / RP balances (VF §6.2).
class WalletPill extends ConsumerWidget {
  const WalletPill({super.key, required this.puuid});

  final String puuid;

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
        child: _Pill(
          children: [
            _Balance(currencyId: CurrencyIds.vp, amount: formatNumber(w.vp)),
            _Balance(currencyId: CurrencyIds.kc, amount: formatNumber(w.kc)),
            _Balance(currencyId: CurrencyIds.rp, amount: formatNumber(w.rp)),
          ],
        ),
      );
    } else if (wallet.hasError && !wallet.isLoading) {
      // Balances are secondary: show dashes instead of an error block.
      content = _Pill(
        children: [
          for (final id in const [
            CurrencyIds.vp,
            CurrencyIds.kc,
            CurrencyIds.rp,
          ])
            _Balance(currencyId: id, amount: CommonStrings.dash),
        ],
      );
    } else {
      content = const Skeleton(width: 260, height: 34, radius: 17);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: content,
        ),
      ),
    );
  }
}

/// One Figma wallet pill: colored dot, amount and currency code.
class _Balance extends ConsumerWidget {
  const _Balance({required this.currencyId, required this.amount});

  final String currencyId;
  final String amount;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CurrencyPill(
    dotColor: switch (currencyId) {
      CurrencyIds.kc => CurrencyColors.kc,
      CurrencyIds.rp => CurrencyColors.rp,
      _ => CurrencyColors.vp,
    },
    amount: amount,
    code: currencyOf(ref, currencyId)?.label ?? '',
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        children[i],
      ],
    ],
  );
}
