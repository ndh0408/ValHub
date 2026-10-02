import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import 'accessory_row.dart';
import 'store_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S12 body: countdown row (+ local reset time), then the accessory rows in
/// one card.
class AccessorySection extends ConsumerWidget {
  const AccessorySection({
    super.key,
    required this.accessoryStore,
    required this.puuid,
  });

  final AccessoryStore? accessoryStore;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = accessoryStore;
    if (store == null || store.offers.isEmpty) {
      return EmptyView(
        title: context.l10n.storeAccessoryEmptyTitle,
        message: context.l10n.storeAccessoryEmpty,
        icon: Icons.style_outlined,
      );
    }
    final expiresAt = store.expiresAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: expiresAt,
          builder: context.l10n.storeAccessoryRefreshIn,
          note: expiresAt == null
              ? null
              : context.l10n.storeAccessoryResetAt(
                  formatWallTime(expiresAt, ref.watch(clockProvider).now()),
                ),
          period: const Duration(days: 7),
        ),
        GroupedSection(
          children: [
            for (final o in store.offers)
              AccessoryRow(
                key: ValueKey(o.offer.offerId),
                offer: o,
                puuid: puuid,
              ),
          ],
        ),
      ],
    );
  }
}
