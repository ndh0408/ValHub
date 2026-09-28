import 'package:go_router/go_router.dart';

import 'ui/battlepass_rewards_screen.dart';
import 'ui/battlepass_screen.dart';

/// Locations of the Battle Pass feature.
abstract final class BattlePassRoutes {
  static const root = '/battlepass';
  static const rewards = '/battlepass/rewards';
}

/// Branch 1 of the tab shell.
List<RouteBase> get battlepassBranchRoutes => [
  GoRoute(
    path: BattlePassRoutes.root,
    builder: (context, state) => const BattlePassScreen(),
    routes: [
      GoRoute(
        path: 'rewards',
        builder: (context, state) => const BattlePassRewardsScreen(),
      ),
    ],
  ),
];
