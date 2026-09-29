import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/skeleton.dart';
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
            CurrencyAmount.vp(w.vp, style: _amountStyle(context)),
            CurrencyAmount.kc(w.kc, style: _amountStyle(context)),
            CurrencyAmount.rp(w.rp, style: _amountStyle(context)),
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
            _DashAmount(currencyId: id),
        ],
      );
    } else {
      content = const Skeleton(width: 220, height: 32, radius: 16);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
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

  static TextStyle? _amountStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700);
}

class _DashAmount extends ConsumerWidget {
  const _DashAmount({required this.currencyId});

  final String currencyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = currencyOf(ref, currencyId)?.label ?? '';
    return Text(
      '${CommonStrings.dash} $label',
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(width: 10),
              Container(width: 1, height: 14, color: scheme.outline),
              const SizedBox(width: 10),
            ],
            children[i],
          ],
        ],
      ),
    );
  }
}
