import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:go_router/go_router.dart';

import '../core/config/app_constants.dart';
import '../features/battlepass/battlepass_routes.dart';
import '../features/profile/profile_routes.dart';
import '../features/settings/settings_routes.dart';

/// A notification payload resolved into a route and an optional account.
@immutable
class DeepLink {
  const DeepLink({required this.location, this.accountPuuid});

  /// App route location to `go` to.
  final String location;

  /// Account to switch to first (`?account=<puuid>`).
  final String? accountPuuid;

  @override
  bool operator ==(Object other) =>
      other is DeepLink &&
      other.location == location &&
      other.accountPuuid == accountPuuid;

  @override
  int get hashCode => Object.hash(location, accountPuuid);

  @override
  String toString() => 'DeepLink($location)';
}

/// Parses a notification payload (VF §6.9): a route location such as
/// `/store?account=<puuid>&segment=nightmarket`. The `account` parameter is
/// removed from the location. Anything that is not an absolute app path
/// falls back to `/`, the default tab (the router sends it to Trang chủ).
///
/// [nonce] (a fresh value per tap) is added as
/// [AppConstants.linkNonceParam], so tapping the same link twice still
/// switches the Store segment / reopens the wishlist skin sheet.
DeepLink parseDeepLink(String payload, {String? nonce}) {
  final uri = Uri.tryParse(payload.trim());
  if (uri == null || uri.hasScheme || !uri.path.startsWith('/')) {
    return const DeepLink(location: '/');
  }
  final account = uri.queryParameters['account']?.toLowerCase();
  final rest = Map.of(uri.queryParameters)
    ..remove('account')
    ..remove(AppConstants.linkNonceParam);
  if (nonce != null) rest[AppConstants.linkNonceParam] = nonce;
  final clean = Uri(
    path: uri.path,
    queryParameters: rest.isEmpty ? null : rest,
  );
  return DeepLink(
    location: clean.toString(),
    accountPuuid: (account == null || account.isEmpty) ? null : account,
  );
}

/// Pages the Hồ sơ branch hosts without being children of `/profile`
/// (Battle Pass and Cài đặt are no longer tabs).
const kProfileHostedRoots = [BattlePassRoutes.root, SettingsRoutes.root];

/// How to open a link so Back has somewhere to go.
@immutable
class LinkNavigation {
  const LinkNavigation(this.go, {this.push});

  /// Location to `go` to: switches the tab and resets that branch.
  final String go;

  /// Pushed on top of [go] afterwards (a hosted page), so Back returns to
  /// the tab root instead of leaving the app.
  final String? push;

  @override
  bool operator ==(Object other) =>
      other is LinkNavigation && other.go == go && other.push == push;

  @override
  int get hashCode => Object.hash(go, push);

  @override
  String toString() => 'LinkNavigation($go, push: $push)';
}

/// Plans the navigation of [location] (pure, unit-tested). A location under
/// `/battlepass` or `/settings` opens the Hồ sơ tab first and pushes the page
/// above it (stack: Hồ sơ → page, so Back works); anything else is a plain
/// `go`.
LinkNavigation planLinkNavigation(String location) {
  final path = Uri.tryParse(location)?.path ?? '';
  final hosted = kProfileHostedRoots.any(
    (root) => path == root || path.startsWith('$root/'),
  );
  return hosted
      ? LinkNavigation(ProfileRoutes.root, push: location)
      : LinkNavigation(location);
}

/// Opens a parsed link (after the optional account switch).
void openAppLink(GoRouter router, DeepLink link) {
  final plan = planLinkNavigation(link.location);
  router.go(plan.go);
  final child = plan.push;
  if (child != null) {
    // After the Hồ sơ page is built: `push` starts from the current
    // configuration.
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => unawaited(router.push<void>(child)))
      ..ensureVisualUpdate();
  }
}
