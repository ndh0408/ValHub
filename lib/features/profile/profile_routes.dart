import 'package:go_router/go_router.dart';

import 'ui/daily_rr_screen.dart';
import 'ui/match_detail_screen.dart';
import 'ui/player_profile_screen.dart';
import 'ui/profile_screen.dart';
import 'ui/performance_screen.dart';
import 'ui/rank_up_calculator_screen.dart';

/// Locations of the profile feature.
abstract final class ProfileRoutes {
  static const root = '/profile';
  static const rankUp = '/profile/rankup';
  static const dailyRr = '/profile/daily-rr';
  static const performance = '/profile/performance';

  /// Query parameter: whose point of view a match is shown from.
  static const playerParam = 'player';

  /// Query parameter of [player]: the name must stay hidden (incognito).
  static const hiddenParam = 'hidden';

  /// Match detail inside the profile tab (keeps the nav bar). [player] =
  /// whose summary to show (default: the active account).
  static String match(String matchId, {String? player}) =>
      _withPlayer('$root/match/$matchId', player);

  /// Match detail pushed above the tab bar (from a player profile or a
  /// sheet).
  static String matchFullScreen(String matchId, {String? player}) =>
      _withPlayer('/match/$matchId', player);

  /// Top-level (pushed above the tab bar). [hidden] shows "Người chơi ẩn
  /// danh" instead of the name (SUMMARY U16).
  static String player(String puuid, {bool hidden = false}) =>
      hidden ? '/player/$puuid?$hiddenParam=1' : '/player/$puuid';

  static String _withPlayer(String path, String? player) =>
      player == null || player.isEmpty ? path : '$path?$playerParam=$player';
}

/// Branch 3 of the tab shell. [nested] are extra relative sub-routes of
/// `/profile` owned by other features (the app router passes
/// `socialRoutes`).
List<RouteBase> profileBranchRoutes({List<RouteBase> nested = const []}) => [
  GoRoute(
    path: ProfileRoutes.root,
    builder: (context, state) => const ProfileScreen(),
    routes: [
      GoRoute(
        path: 'performance',
        builder: (context, state) => const PerformanceScreen(),
      ),
      GoRoute(
        path: 'rankup',
        builder: (context, state) => const RankUpCalculatorScreen(),
      ),
      GoRoute(
        path: 'daily-rr',
        builder: (context, state) => const DailyRrScreen(),
      ),
      GoRoute(
        path: 'match/:id',
        builder: (context, state) => MatchDetailScreen(
          matchId: state.pathParameters['id'] ?? '',
          playerPuuid: state.uri.queryParameters[ProfileRoutes.playerParam],
        ),
      ),
      ...nested,
    ],
  ),
];

/// Top-level routes of the profile feature (outside the tab shell).
List<RouteBase> get profileTopLevelRoutes => [
  GoRoute(
    path: '/player/:puuid',
    builder: (context, state) => PlayerProfileScreen(
      puuid: state.pathParameters['puuid'] ?? '',
      hideName: state.uri.queryParameters[ProfileRoutes.hiddenParam] == '1',
    ),
  ),
  GoRoute(
    path: '/match/:id',
    builder: (context, state) => MatchDetailScreen(
      matchId: state.pathParameters['id'] ?? '',
      playerPuuid: state.uri.queryParameters[ProfileRoutes.playerParam],
    ),
  ),
];
