import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../wishlist_strings.dart';

/// S3A "Wishlist" of the active account. Route `/collection/wishlist`.
/// Data: `wishlistProvider(puuid)` (lib/core/wishlist/wishlist_store.dart).
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(WishlistStrings.title)),
      body: const FeaturePlaceholder(),
    );
  }
}
