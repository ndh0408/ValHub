import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart' show showAppSnackBar;
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../data/round_economy.dart';

/// "Kinh tế đội": the rounds the player's team won with each of its buy
/// types (pistol, eco, semi-eco, semi-buy, full buy). The buy type comes
/// from the team's loadout value Riot reports for each round; the rule is
/// one tap away so the numbers are never a black box.
class EconomyCard extends StatelessWidget {
  const EconomyCard({super.key, required this.record});

  final Map<BuyType, BuyRecord> record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return ValCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    context.l10n.profileEconomyTitle,
                    style: ValText.sectionTitle.copyWith(
                      fontSize: 17,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.profileEconomyHint,
                icon: Icon(Icons.info_outline_rounded, color: muted),
                onPressed: () =>
                    showAppSnackBar(context, context.l10n.profileEconomyHint),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final entry in record.entries)
            _BuyRow(type: entry.key, record: entry.value),
        ],
      ),
    );
  }
}

class _BuyRow extends StatelessWidget {
  const _BuyRow({required this.type, required this.record});

  final BuyType type;
  final BuyRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final rate = record.winRate ?? 0;
    final color = rate >= 0.5 ? colors.win : colors.loss;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      // Name and record on one line, the bar under them: nothing has a
      // fixed width, so it fits any phone and text size.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.profileBuyType(type.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.profileEconomyWon(record.won, record.played),
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6,
              color: color,
              backgroundColor: colors.track,
              semanticsLabel: context.l10n.profileBuyType(type.name),
              semanticsValue: formatPercent(rate),
            ),
          ),
        ],
      ),
    );
  }
}
