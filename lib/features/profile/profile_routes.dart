import 'package:go_router/go_router.dart';

import 'ui/daily_rr_screen.dart';
import 'ui/match_detail_screen.dart';
import 'ui/player_profile_screen.dart';
import 'ui/profile_screen.dart';
import 'ui/rank_up_calculator_screen.dart';

/// Locations of the profile feature.
abstract final class ProfileRoutes {
  static const root = '/profile';
  static const rankUp = '/profile/rankup';
  static const dailyRr = '/profile/daily-rr';

  static String match(String matchId) => '$root/match/$matchId';

  /// Top-level (pushed above the tab bar).
  static String player(String puuid) => '/player/$puuid';
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
        path: 'rankup',
        builder: (context, state) => const RankUpCalculatorScreen(),
      ),
      GoRoute(
        path: 'daily-rr',
        builder: (context, state) => const DailyRrScreen(),
      ),
      GoRoute(
        path: 'match/:id',
        builder: (context, state) =>
            MatchDetailScreen(matchId: state.pathParameters['id'] ?? ''),
      ),
      ...nested,
    ],
  ),
];

/// Top-level routes of the profile feature (outside the tab shell).
List<RouteBase> get profileTopLevelRoutes => [
  GoRoute(
    path: '/player/:puuid',
    builder: (context, state) =>
        PlayerProfileScreen(puuid: state.pathParameters['puuid'] ?? ''),
  ),
];
