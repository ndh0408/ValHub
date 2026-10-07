import 'package:go_router/go_router.dart';

import '../../core/config/app_constants.dart';

import '../wishlist/ui/catalog_screen.dart';
import '../wishlist/ui/wishlist_screen.dart';
import '../wishlist/wishlist_routes.dart';
import 'ui/bundle_detail_screen.dart';
import 'ui/store_history_screen.dart';
import 'ui/store_screen.dart';

/// Locations of the store feature.
abstract final class StoreRoutes {
  static const root = '/store';

  /// `/store?segment=nightmarket` etc.
  static String segment(StoreSegment segment) =>
      '$root?segment=${segment.queryValue}';

  static String bundle(String bundleId) => '$root/bundle/$bundleId';

  /// The daily shops this device recorded for the active account.
  static const history = '$root/history';

  /// The wishlist and its skin catalogue inside the Store tab (the ♡ of the
  /// header), so the tab bar stays on Cửa hàng. The same screens also live
  /// under Bộ sưu tập ([WishlistRoutes]).
  static const wishlist = '$root/wishlist';
  static const catalog = '$root/catalog';
}

/// Branch 0 of the tab shell: `/store` + sub-routes. The store feature may
/// add sub-routes here.
List<RouteBase> get storeBranchRoutes => [
  GoRoute(
    path: StoreRoutes.root,
    builder: (context, state) => StoreScreen(
      initialSegment: StoreSegment.parse(state.uri.queryParameters['segment']),
      linkNonce: state.uri.queryParameters[AppConstants.linkNonceParam],
    ),
    routes: [
      GoRoute(
        path: 'bundle/:id',
        builder: (context, state) =>
            BundleDetailScreen(bundleId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: 'history',
        builder: (context, state) => const StoreHistoryScreen(),
      ),
      GoRoute(
        path: 'wishlist',
        builder: (context, state) => WishlistScreen(
          initialSkinUuid: state.uri.queryParameters[WishlistRoutes.skinParam],
          linkNonce: state.uri.queryParameters[AppConstants.linkNonceParam],
          catalogPath: StoreRoutes.catalog,
        ),
      ),
      GoRoute(
        path: 'catalog',
        builder: (context, state) => const CatalogScreen(),
      ),
    ],
  ),
];
