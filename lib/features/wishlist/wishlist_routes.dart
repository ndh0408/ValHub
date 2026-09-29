import 'package:go_router/go_router.dart';

import '../../core/config/app_constants.dart';

import 'ui/catalog_screen.dart';
import 'ui/wishlist_screen.dart';

/// Locations of the wishlist feature (nested under `/collection`).
abstract final class WishlistRoutes {
  static const wishlist = '/collection/wishlist';
  static const catalog = '/collection/catalog';

  /// Query parameter that opens a skin's detail sheet on the wishlist
  /// (wishlist notification deep link, W5).
  static const skinParam = 'skin';

  /// `/collection/wishlist?skin=<uuid>`: the wishlist with that skin's
  /// detail sheet open.
  static String skin(String skinUuid) =>
      Uri(path: wishlist, queryParameters: {skinParam: skinUuid}).toString();
}

/// Relative sub-routes nested by the app router under `/collection`.
List<RouteBase> get wishlistRoutes => [
  GoRoute(
    path: 'wishlist',
    builder: (context, state) => WishlistScreen(
      initialSkinUuid: state.uri.queryParameters[WishlistRoutes.skinParam],
      linkNonce: state.uri.queryParameters[AppConstants.linkNonceParam],
    ),
  ),
  GoRoute(path: 'catalog', builder: (context, state) => const CatalogScreen()),
];
