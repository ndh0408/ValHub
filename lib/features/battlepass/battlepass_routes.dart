import 'package:go_router/go_router.dart';

import 'ui/battlepass_rewards_screen.dart';
import 'ui/battlepass_screen.dart';

/// Locations of the Battle Pass feature.
abstract final class BattlePassRoutes {
  static const root = '/battlepass';
  static const rewards = '/battlepass/rewards';

  /// Query parameter selecting another contract (an event pass).
  static const contractParam = 'contract';

  /// S21 for a specific contract (event pass): `/battlepass/rewards?contract=…`.
  static String rewardsFor(String contractId) => Uri(
    path: rewards,
    queryParameters: {contractParam: contractId.toLowerCase()},
  ).toString();
}

/// Branch 1 of the tab shell.
List<RouteBase> get battlepassBranchRoutes => [
  GoRoute(
    path: BattlePassRoutes.root,
    builder: (context, state) => const BattlePassScreen(),
    routes: [
      GoRoute(
        path: 'rewards',
        builder: (context, state) => BattlePassRewardsScreen(
          contractId: state.uri.queryParameters[BattlePassRoutes.contractParam],
        ),
      ),
    ],
  ),
];
