import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../store_strings.dart';

/// S14 "Chi tiết bundle". Route `/store/bundle/:id` where `id` is the
/// storefront `DataAssetID` (= valorant-api bundle uuid).
class BundleDetailScreen extends StatelessWidget {
  const BundleDetailScreen({super.key, required this.bundleId});

  final String bundleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(StoreStrings.bundleDetailTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
