import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../wishlist_strings.dart';

/// S3B "Tất cả skin" (catalog to add skins to the wishlist).
/// Route `/collection/catalog`.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(WishlistStrings.catalogTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
