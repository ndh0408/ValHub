/// Which cards Home shows and where (docs/design/HOME.md §3.3, §3.4): each
/// card's presence, the startup gate that delays the optional cards, and the
/// resulting arrangement.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../data/home_card.dart';
import '../data/home_layout.dart';
import 'home_card_providers.dart';
import 'home_layout_provider.dart';
import 'home_refresh.dart';

/// Presence of a card that has an [AsyncValue] view model.
///
/// - a value: `null` is hidden, anything else visible;
/// - an error without a value: visible (the card shows a compact error) for
///   a core card unless the status is blocking, otherwise hidden;
/// - loading without a value: a skeleton for a core card, otherwise hidden.
HomeCardPresence presenceOfAsync<T>(
  AsyncValue<T?> value, {
  required bool core,
  bool statusBlocking = false,
}) {
  if (value.hasValue) {
    return value.value == null
        ? HomeCardPresence.hidden
        : HomeCardPresence.visible;
  }
  if (value.hasError) {
    return core && !statusBlocking
        ? HomeCardPresence.visible
        : HomeCardPresence.hidden;
  }
  return core ? HomeCardPresence.loading : HomeCardPresence.hidden;
}

/// Presence of one card of one account. Only watched for cards the user did
/// not hide, so hidden cards never fetch anything.
final homeCardPresenceProvider = Provider.autoDispose
    .family<HomeCardPresence, HomeCardKey>((ref, key) {
      final puuid = key.puuid;
      final needsLogin = ref.watch(
        accountProvider(puuid).select((a) => a?.needsLogin ?? false),
      );
      final blocking = key.card.isCore
          ? ref.watch(homeStatusBlockingProvider)
          : false;
      return switch (key.card) {
        HomeCardId.live =>
          ref.watch(homeLiveSnapshotProvider(puuid).select((s) => s != null))
              ? HomeCardPresence.visible
              : HomeCardPresence.hidden,
        HomeCardId.store => presenceOfAsync(
          ref.watch(homeStoreSummaryProvider(puuid)),
          core: !needsLogin,
          statusBlocking: blocking,
        ),
        HomeCardId.rank => presenceOfAsync(
          ref.watch(homeRankSnapshotProvider(puuid)),
          core: true,
          statusBlocking: blocking,
        ),
        HomeCardId.battlePass => presenceOfAsync(
          ref.watch(homeBattlePassSnapshotProvider(puuid)),
          core: !needsLogin,
          statusBlocking: blocking,
        ),
        HomeCardId.friends => _friendsPresence(ref),
        HomeCardId.community => presenceOfAsync(
          ref.watch(homeCommunitySnapshotProvider(puuid)),
          core: false,
        ),
        HomeCardId.otherAccounts =>
          ref.watch(homeOtherAccountsProvider) == null
              ? HomeCardPresence.hidden
              : HomeCardPresence.visible,
        HomeCardId.serverStatus =>
          ref.watch(homeServerStatusProvider) == null
              ? HomeCardPresence.hidden
              : HomeCardPresence.visible,
      };
    });

/// Friends: declined → hidden; not asked and no chat → the opt-in prompt;
/// otherwise visible only while somebody is playing.
HomeCardPresence _friendsPresence(Ref ref) {
  final consent = ref.watch(homeFriendsConsentProvider);
  if (consent == false) return HomeCardPresence.hidden;
  if (consent == null && !ref.watch(homeFriendsLiveProvider)) {
    return HomeCardPresence.visible; // the prompt
  }
  return presenceOfAsync(ref.watch(homeFriendsSnapshotProvider), core: false);
}

/// Opens once the core cards have left their skeletons, or
/// [kHomeStartupDelay] after Home was built, whichever comes first. The
/// optional cards (friends, community, other accounts) do not read their
/// data before, so the launch stays within the request budget.
final homeStartupGateProvider =
    NotifierProvider.autoDispose<HomeStartupGate, bool>(HomeStartupGate.new);

class HomeStartupGate extends Notifier<bool> {
  @override
  bool build() {
    final timer = Timer(kHomeStartupDelay, open);
    ref.onDispose(timer.cancel);
    return false;
  }

  void open() {
    if (ref.mounted && !state) state = true;
  }
}

/// The arrangement of Home for the account [puuid].
final homeArrangementProvider = Provider.autoDispose
    .family<HomeArrangement, String>((ref, puuid) {
      final layout = ref.watch(homeLayoutProvider);
      final gate = ref.watch(homeStartupGateProvider);
      final needsLogin = ref.watch(
        accountProvider(puuid).select((a) => a?.needsLogin ?? false),
      );
      final blocking = ref.watch(homeStatusBlockingProvider);
      final seen = <HomeCardId, HomeCardPresence>{};

      HomeCardPresence presenceOf(HomeCardId id) {
        final HomeCardPresence presence;
        final canShowSaved =
            id == HomeCardId.store || id == HomeCardId.battlePass;
        if ((id.needsRiotSession && needsLogin && !canShowSaved) ||
            (id.isDeferred && !gate)) {
          presence = HomeCardPresence.hidden;
        } else {
          presence = ref.watch(
            homeCardPresenceProvider((puuid: puuid, card: id)),
          );
        }
        return seen[id] = presence;
      }

      final liveActive =
          !needsLogin &&
          !layout.isHidden(HomeCardId.live) &&
          ref.watch(homeLiveSnapshotProvider(puuid).select((s) => s != null));

      final arrangement = arrangeHomeCards(
        layout: layout,
        presenceOf: presenceOf,
        liveActive: liveActive,
        statusBlocking: blocking,
      );

      if (!gate &&
          !HomeCardId.values.any(
            (c) => c.isCore && seen[c] == HomeCardPresence.loading,
          )) {
        // Every enabled core card has settled: let the optional ones read.
        unawaited(
          Future<void>.microtask(
            () => ref.mounted
                ? ref.read(homeStartupGateProvider.notifier).open()
                : null,
          ),
        );
      }
      return arrangement;
    });
