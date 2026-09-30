import 'package:go_router/go_router.dart';

import '../../core/config/app_constants.dart';
import 'data/home_card.dart';
import 'ui/home_screen.dart';

/// Locations of the Home ("Trang chủ") dashboard.
abstract final class HomeRoutes {
  /// Tab root and landing page: `/home[?focus=<card>]`.
  static const root = '/home';

  /// `?focus=` scrolls to (and briefly highlights) a card.
  static const focusParam = 'focus';

  /// `/home?focus=battlepass`: the only way to build a focus link.
  static String focus(HomeCardId card) =>
      Uri(path: root, queryParameters: {focusParam: card.storageId}).toString();
}

/// Branch 0 of the tab shell: `/home`.
List<RouteBase> get homeBranchRoutes => [
  GoRoute(
    path: HomeRoutes.root,
    builder: (context, state) => HomeScreen(
      focus: HomeCardId.tryParse(
        state.uri.queryParameters[HomeRoutes.focusParam],
      ),
      linkNonce: state.uri.queryParameters[AppConstants.linkNonceParam],
    ),
  ),
];
