import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/ui/empty_view.dart';
import '../../store_strings.dart';
import 'bundle_banner.dart';

/// S13 body: one banner per featured bundle.
class BundleSection extends StatelessWidget {
  const BundleSection({super.key, required this.bundles});

  final List<StoreBundle> bundles;

  @override
  Widget build(BuildContext context) {
    if (bundles.isEmpty) {
      return const EmptyView(
        title: StoreStrings.bundlesEmptyTitle,
        message: StoreStrings.bundlesEmpty,
        icon: Icons.inventory_2_outlined,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < bundles.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            BundleBanner(key: ValueKey(bundles[i].id), bundle: bundles[i]),
          ],
        ],
      ),
    );
  }
}
