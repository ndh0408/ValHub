/// The user's Home layout and the friends opt-in, both kept in Prefs
/// (docs/design/HOME.md §7).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/friends_consent.dart';
import '../data/home_card.dart';
import '../data/home_layout.dart';

/// `f.home.layout`: app-wide (not per account), so it survives sign-out.
const kHomeLayoutPrefKey = 'f.home.layout';

/// `f.home.friendsLive`: `true` once the user agreed that Home connects to
/// Riot chat (friends then see them online), `false` once declined.
const kHomeFriendsPrefKey = 'f.home.friendsLive';

/// Order and hidden cards. Writes go straight to Prefs; a failed write keeps
/// the in-memory state.
final homeLayoutProvider = NotifierProvider<HomeLayoutNotifier, HomeLayout>(
  HomeLayoutNotifier.new,
);

class HomeLayoutNotifier extends Notifier<HomeLayout> {
  @override
  HomeLayout build() =>
      HomeLayout.fromJson(ref.watch(prefsProvider).getJson(kHomeLayoutPrefKey));

  /// Moves the card at [from] to [to] (`ReorderableListView` indices).
  Future<void> move(int from, int to) => _set(state.moved(from, to));

  Future<void> setHidden(HomeCardId id, {required bool hidden}) =>
      _set(state.withHidden(id, hidden: hidden));

  /// Back to the IA order with every card visible.
  Future<void> reset() => _set(HomeLayout.defaults);

  Future<void> _set(HomeLayout next) async {
    if (next == state) return;
    state = next;
    try {
      await ref.read(prefsProvider).setJson(kHomeLayoutPrefKey, next.toJson());
    } on Object {
      // The layout is a convenience: keep it for this session.
    }
  }
}

/// Whether Home may connect to Riot chat to show friends who are playing:
/// `null` not asked yet, `false` declined, `true` allowed.
final homeFriendsConsentProvider =
    NotifierProvider<HomeFriendsConsentNotifier, bool?>(
      HomeFriendsConsentNotifier.new,
    );

class HomeFriendsConsentNotifier extends Notifier<bool?> {
  String? _id;

  @override
  bool? build() {
    _id = ref.watch(activePuuidProvider);
    final id = _id;
    if (id == null) return null;
    final allowed = ref.watch(friendsLiveConsentProvider(id));
    final answered = ref
        .watch(prefsProvider)
        .containsKey(PrefKeys.account(id, 'home.friendsLive'));
    return answered ? allowed : null;
  }

  Future<void> set({required bool allowed}) async {
    final id = _id;
    if (id == null) return;
    await ref.read(friendsLiveConsentProvider(id).notifier).setConsent(allowed);
    if (ref.mounted && _id == id) ref.invalidateSelf();
  }

  Future<void> clear() async {
    final id = _id;
    if (id == null) return;
    await ref.read(friendsLiveConsentProvider(id).notifier).clearConsent();
    if (ref.mounted && _id == id) ref.invalidateSelf();
  }
}
