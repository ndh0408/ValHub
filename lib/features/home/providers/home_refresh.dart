/// Refresh policy of Home (docs/design/HOME.md §6): the constants and the
/// pull-to-refresh. Home adds no polling loop for Riot data: live game,
/// storefront, MMR and Battle Pass keep their own providers and TTLs; only
/// three slow pollers live in the cards (`HomeCardPoller`) and only tick
/// while Home is visible and the app is in the foreground.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_status.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/riot/platform_status.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../../battlepass/providers/battlepass_providers.dart';
import '../../community/community_previews.dart';
import '../../community/data/community_models.dart';
import '../../live_game/providers/live_game_providers.dart';
import '../data/home_accounts.dart';
import '../data/home_card.dart';
import '../data/home_layout.dart';
import 'home_card_providers.dart';

const kHomeLfgRefresh = Duration(minutes: 3);
const kHomeStatusRefresh = Duration(minutes: 5);
const kHomeAccountsRefresh = Duration(minutes: 2);
const kHomeStartupDelay = Duration(milliseconds: 1500);
const kHomeRefreshTimeout = Duration(seconds: 12);

/// Coming back to the foreground after this long refreshes the community
/// previews and the server status (everything else follows its own TTL).
const kHomeResumeRefreshAfter = Duration(minutes: 5);

/// Pull-to-refresh: refreshes only the cards currently shown (pinned +
/// flow), in parallel; never throws; the spinner stops after
/// [kHomeRefreshTimeout] at the latest. Hidden cards are never touched.
Future<void> refreshHome(
  WidgetRef ref, {
  required String puuid,
  required HomeArrangement shown,
}) async {
  final tasks = <Future<void>>[];

  Future<void> guarded(Future<void> Function() run) async {
    try {
      await run();
    } on Object {
      // Errors are rendered by the cards themselves.
    }
  }

  for (final card in shown.all) {
    switch (card) {
      case HomeCardId.live:
        tasks.add(
          guarded(() => ref.read(liveGameProvider(puuid).notifier).refresh()),
        );
      case HomeCardId.store:
        ref.invalidate(walletProvider(puuid));
        ref.invalidate(storefrontProvider(puuid));
        tasks.add(guarded(() => ref.read(storefrontProvider(puuid).future)));
      case HomeCardId.rank:
        ref.invalidate(competitiveUpdatesProvider(puuid));
        tasks.add(guarded(() => ref.refresh(mmrProvider(puuid).future)));
      case HomeCardId.battlePass:
        tasks.add(guarded(() => refreshBattlePass(ref, puuid)));
      case HomeCardId.friends:
        if (ref.read(homeFriendsLiveProvider)) {
          tasks.add(
            guarded(() async => ref.read(xmppServiceProvider)?.refresh()),
          );
        }
      case HomeCardId.community:
        ref
          ..invalidate(matchingLfgPreviewProvider(puuid))
          ..invalidate(trendingSkinsProvider(TopPeriod.week));
      case HomeCardId.otherAccounts:
        final rows =
            ref.read(homeOtherAccountsProvider)?.rows ??
            const <OtherAccountSummary>[];
        for (final row in rows) {
          ref
            ..invalidate(accountActivityProvider(row.account.puuid))
            ..invalidate(savedStorefrontProvider(row.account.puuid));
        }
      case HomeCardId.serverStatus:
        for (final region in ref.read(homeStatusRegionsProvider)) {
          ref.invalidate(platformStatusProvider(region));
        }
    }
  }

  if (tasks.isEmpty) return;
  try {
    await Future.wait(tasks).timeout(kHomeRefreshTimeout);
  } on Object {
    // Timeout or error: stop the spinner; the cards show their own state.
  }
}
