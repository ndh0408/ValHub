import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/economy/economy.dart';
import '../../../../core/ui/empty_view.dart';
import 'bundle_banner.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S13 body: one banner per featured bundle.
class BundleSection extends StatelessWidget {
  const BundleSection({super.key, required this.bundles});

  final List<StoreBundle> bundles;

  @override
  Widget build(BuildContext context) {
    if (bundles.isEmpty) {
      return EmptyView(
        title: context.l10n.storeBundlesEmptyTitle,
        message: context.l10n.storeBundlesEmpty,
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
