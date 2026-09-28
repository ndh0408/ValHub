import 'package:go_router/go_router.dart';

import 'ui/catalog_screen.dart';
import 'ui/wishlist_screen.dart';

/// Locations of the wishlist feature (nested under `/collection`).
abstract final class WishlistRoutes {
  static const wishlist = '/collection/wishlist';
  static const catalog = '/collection/catalog';
}

/// Relative sub-routes nested by the app router under `/collection`.
List<RouteBase> get wishlistRoutes => [
  GoRoute(
    path: 'wishlist',
    builder: (context, state) => const WishlistScreen(),
  ),
  GoRoute(path: 'catalog', builder: (context, state) => const CatalogScreen()),
];
