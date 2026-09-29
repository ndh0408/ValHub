import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/accounts/account_providers.dart';
import '../core/auth/auth_routes.dart';
import '../core/auth/login_screen.dart';
import '../core/l10n/common_strings.dart';
import '../core/ui/empty_view.dart';
import '../features/battlepass/battlepass_routes.dart';
import '../features/collection/collection_routes.dart';
import '../features/community/community_routes.dart';
import '../features/profile/profile_routes.dart';
import '../features/settings/settings_routes.dart';
import '../features/social/social_routes.dart';
import '../features/store/store_routes.dart';
import '../features/wishlist/wishlist_routes.dart';
import 'shell.dart';

/// Root navigator (full-screen routes above the tab bar: /welcome, /login,
/// /player/:puuid, sheets opened with `useRootNavigator`).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Locations reachable without any signed-in account.
const _publicPaths = {SettingsRoutes.welcome, AuthRoutes.login};

/// Pure redirect rule (unit-tested):
/// - no accounts → everything except `/welcome` and `/login` goes to
///   `/welcome`;
/// - accounts → `/welcome` and `/` go to `/store`.
String? appRedirect({required bool hasAccounts, required Uri location}) {
  final path = location.path.isEmpty ? '/' : location.path;
  if (!hasAccounts) {
    return _publicPaths.contains(path) ? null : SettingsRoutes.welcome;
  }
  if (path == SettingsRoutes.welcome || path == '/') return StoreRoutes.root;
  return null;
}

/// Every route of the app. Feature route lists are composed here; features
/// only edit their own `*_routes.dart`.
List<RouteBase> buildAppRoutes() => [
  ...settingsTopLevelRoutes,
  GoRoute(
    path: AuthRoutes.login,
    builder: (context, state) =>
        LoginScreen(reauthPuuid: state.uri.queryParameters['reauth']),
  ),
  ...profileTopLevelRoutes,
  ...communityTopLevelRoutes,
  StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => AppShell(navigationShell: shell),
    branches: [
      StatefulShellBranch(routes: storeBranchRoutes),
      StatefulShellBranch(routes: battlepassBranchRoutes),
      StatefulShellBranch(routes: communityBranchRoutes),
      StatefulShellBranch(
        routes: collectionBranchRoutes(nested: wishlistRoutes),
      ),
      StatefulShellBranch(routes: profileBranchRoutes(nested: socialRoutes)),
      StatefulShellBranch(routes: settingsBranchRoutes),
    ],
  ),
];

/// Builds the router. [hasAccounts] drives the redirect and is re-evaluated
/// whenever it notifies.
GoRouter createAppRouter({
  required ValueListenable<bool> hasAccounts,
  String initialLocation = StoreRoutes.root,
  GlobalKey<NavigatorState>? navigatorKey,
}) => GoRouter(
  navigatorKey: navigatorKey ?? rootNavigatorKey,
  initialLocation: initialLocation,
  refreshListenable: hasAccounts,
  redirect: (context, state) =>
      appRedirect(hasAccounts: hasAccounts.value, location: state.uri),
  routes: buildAppRoutes(),
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(),
    body: EmptyView(
      message: CommonStrings.pageNotFound,
      icon: Icons.explore_off_outlined,
      action: FilledButton(
        onPressed: () => context.go(StoreRoutes.root),
        child: const Text(CommonStrings.goHome),
      ),
    ),
  ),
);

/// The app's single [GoRouter] (created once; redirects re-run when the
/// account list becomes empty / non-empty).
final routerProvider = Provider<GoRouter>((ref) {
  final hasAccounts = ValueNotifier<bool>(ref.read(hasAccountsProvider));
  ref.listen(hasAccountsProvider, (_, next) => hasAccounts.value = next);
  final router = createAppRouter(hasAccounts: hasAccounts);
  ref.onDispose(() {
    router.dispose();
    hasAccounts.dispose();
  });
  return router;
});
