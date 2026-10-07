import 'package:go_router/go_router.dart';

import '../../core/config/app_constants.dart';

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
    ],
  ),
];
