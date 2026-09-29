import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_models.dart';
import 'community_providers.dart';

/// Leaderboard filters.
@immutable
class TopSkinsFilter {
  const TopSkinsFilter({this.weapon, this.period = TopPeriod.all});

  /// Weapon uuid, `null` = every weapon.
  final String? weapon;
  final TopPeriod period;

  TopSkinsFilter copyWith({String? Function()? weapon, TopPeriod? period}) =>
      TopSkinsFilter(
        weapon: weapon == null ? this.weapon : weapon(),
        period: period ?? this.period,
      );

  @override
  bool operator ==(Object other) =>
      other is TopSkinsFilter &&
      other.weapon == weapon &&
      other.period == period;

  @override
  int get hashCode => Object.hash(weapon, period);
}

final topSkinsFilterProvider =
    NotifierProvider<TopSkinsFilterNotifier, TopSkinsFilter>(
      TopSkinsFilterNotifier.new,
    );

class TopSkinsFilterNotifier extends Notifier<TopSkinsFilter> {
  @override
  TopSkinsFilter build() => const TopSkinsFilter();

  void setWeapon(String? weapon) =>
      state = state.copyWith(weapon: () => weapon);

  void setPeriod(TopPeriod period) => state = state.copyWith(period: period);
}

/// Key of [topSkinsProvider] (`puuid` = whose votes are marked).
typedef TopSkinsQuery = ({String puuid, String? weapon, TopPeriod period});

/// The most-loved skins (`GET /v1/skins/top`).
final topSkinsProvider = FutureProvider.autoDispose
    .family<List<TopSkin>, TopSkinsQuery>(
      (ref, q) => ref
          .watch(communityApiProvider)
          .topSkins(puuid: q.puuid, weapon: q.weapon, period: q.period),
    );

/// Vote states changed on this device (optimistic, then the server's
/// answer), per account. They win over fetched values so the leaderboard
/// and the skin sheet agree.
final skinVoteOverridesProvider =
    NotifierProvider.family<SkinVoteOverrides, Map<String, SkinVote>, String>(
      SkinVoteOverrides.new,
    );

class SkinVoteOverrides extends Notifier<Map<String, SkinVote>> {
  SkinVoteOverrides(this.puuid);

  final String puuid;

  final Set<String> _inFlight = {};

  @override
  Map<String, SkinVote> build() => const {};

  /// Toggles the vote on [current] (optimistic). Reverts and rethrows on
  /// failure; taps while the same skin is in flight are ignored.
  Future<void> toggle(SkinVote current, {String? weaponUuid}) async {
    final id = current.skinUuid;
    if (!_inFlight.add(id)) return;
    final optimistic = current.toggled();
    state = {...state, id: optimistic};
    try {
      final api = ref.read(communityApiProvider);
      final result = optimistic.voted
          ? await api.vote(puuid, id, weaponUuid: weaponUuid)
          : await api.unvote(puuid, id);
      if (ref.mounted) state = {...state, id: result};
    } on Object {
      if (ref.mounted) state = {...state, id: current};
      rethrow;
    } finally {
      _inFlight.remove(id);
    }
  }
}

/// Key of [skinVoteProvider].
typedef SkinVoteKey = ({String? puuid, String skinUuid});

/// Vote count of one skin for the skin sheet. Read-only: uses a cached
/// community session when there is one (never signs in), and any failure
/// yields `null` so the sheet simply hides the count.
final skinVoteProvider = FutureProvider.autoDispose
    .family<SkinVote?, SkinVoteKey>((ref, key) async {
      if (!ref.watch(communityEnabledProvider)) return null;
      final id = key.skinUuid.toLowerCase();
      try {
        final votes = await ref.watch(communityApiProvider).skinVotes([
          id,
        ], puuid: key.puuid);
        return votes[id] ?? SkinVote(skinUuid: id);
      } on Object {
        return null;
      }
    });
