import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../data/skin_query.dart';

/// Every collectible skin with its sort keys and B9 price (S3A / S3B).
///
/// Kept alive: it only depends on the (kept-alive) content and price
/// service, and rebuilding ~2 000 entries on every visit is wasted work.
final skinCatalogProvider = FutureProvider<SkinCatalog>((ref) async {
  final db = await ref.watch(contentProvider.future);
  final prices = ref.watch(priceServiceProvider);
  return SkinCatalog.build(db, prices);
});
