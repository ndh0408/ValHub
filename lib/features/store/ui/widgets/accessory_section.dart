import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/ui/empty_view.dart';
import '../../store_strings.dart';
import 'accessory_row.dart';
import 'store_ui_bits.dart';

/// S12 body: countdown row, then the accessory rows in one card.
class AccessorySection extends StatelessWidget {
  const AccessorySection({
    super.key,
    required this.accessoryStore,
    required this.puuid,
  });

  final AccessoryStore? accessoryStore;
  final String puuid;

  @override
  Widget build(BuildContext context) {
    final store = accessoryStore;
    if (store == null || store.offers.isEmpty) {
      return const EmptyView(
        message: StoreStrings.accessoryEmpty,
        icon: Icons.style_outlined,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownRow(
          expiresAt: store.expiresAt,
          builder: StoreStrings.accessoryRefreshIn,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              for (var i = 0; i < store.offers.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 84),
                AccessoryRow(offer: store.offers[i], puuid: puuid),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
