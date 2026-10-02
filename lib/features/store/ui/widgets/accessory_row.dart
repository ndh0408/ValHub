import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
import 'store_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S12 accessory-store row: image, name, type label, optional
/// "Từ: `<contract>`", KC price.
class AccessoryRow extends ConsumerWidget {
  const AccessoryRow({super.key, required this.offer, required this.puuid});

  final AccessoryOffer offer;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final theme = Theme.of(context);
    final typeId = offer.itemTypeId ?? '';
    final item = db.item(typeId, offer.itemId);
    final contractName = offer.contractId == null
        ? null
        : db.contract(offer.contractId!)?.displayName;
    final owned =
        ref
            .watch(ownedItemsProvider(puuid))
            .value
            ?.owns(typeId, offer.itemId) ??
        false;
    final muted = theme.colorScheme.onSurfaceVariant;
    final kc = offer.kcCost;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CurrencyColors.kc.withValues(alpha: 0.16),
                  theme.colorScheme.surfaceContainerHigh,
                ],
              ),
              borderRadius: BorderRadius.circular(ValRadius.small),
            ),
            child: item?.image == null && typeId == ItemTypeIds.playerTitle
                ? Icon(Icons.text_fields, color: muted)
                : NetImage(item?.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item?.name ?? context.l10n.commonUnknownItem,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.typeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
                if (contractName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.storeAccessoryFrom(contractName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kc == null)
                Text(context.l10n.commonDash, style: theme.textTheme.titleSmall)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: CurrencyColors.kc.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(ValRadius.pill),
                  ),
                  child: CurrencyAmount.kc(
                    kc,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (owned) ...[const SizedBox(height: 6), const OwnedBadge()],
            ],
          ),
        ],
      ),
    );
  }
}
