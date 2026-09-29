import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../store_strings.dart';
import 'store_ui_bits.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
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
                  item?.name ?? CommonStrings.unknownItem,
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
                    StoreStrings.accessoryFrom(contractName),
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
                Text(CommonStrings.dash, style: theme.textTheme.titleSmall)
              else
                CurrencyAmount.kc(
                  kc,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
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
