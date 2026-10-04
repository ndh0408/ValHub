import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/ui_memory.dart';
import '../data/community_models.dart';
import 'community_providers.dart';
import 'consent_providers.dart';

/// Leaderboard filters.
@immutable
class TopSkinsFilter {
  const TopSkinsFilter({
    this.weapon,
    this.period = TopPeriod.all,
    this.sort = TopSort.votes,
  });

  /// Weapon uuid, `null` = every weapon.
  final String? weapon;
  final TopPeriod period;
  final TopSort sort;

  TopSkinsFilter copyWith({
    String? Function()? weapon,
    TopPeriod? period,
    TopSort? sort,
  }) => TopSkinsFilter(
    weapon: weapon == null ? this.weapon : weapon(),
    period: period ?? this.period,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is TopSkinsFilter &&
      other.weapon == weapon &&
      other.period == period &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(weapon, period, sort);
}

/// `UiMemory` keys of the leaderboard filters.
abstract final class TopSkinsMemoryKeys {
  static const weapon = 'community.skins.weapon';
  static const period = 'community.skins.period';
  static const sort = 'community.skins.sort';
}

/// The leaderboard filters, remembered across launches (`UiMemory`).
final topSkinsFilterProvider =
    NotifierProvider<TopSkinsFilterNotifier, TopSkinsFilter>(
      TopSkinsFilterNotifier.new,
    );

class TopSkinsFilterNotifier extends Notifier<TopSkinsFilter> {
  UiMemory get _memory => ref.read(uiMemoryProvider);

  @override
  TopSkinsFilter build() {
    final memory = ref.watch(uiMemoryProvider);
    final weapon = memory.read(TopSkinsMemoryKeys.weapon);
    return TopSkinsFilter(
      weapon: weapon == null || weapon.isEmpty ? null : weapon,
      // Previous weekly preferences remain compatible on disk, but the product
      // leaderboard is now always global/all-time.
      period: TopPeriod.all,
      sort: memory.readEnum(
        TopSkinsMemoryKeys.sort,
        TopSort.values,
        TopSort.votes,
      ),
    );
  }

  void setWeapon(String? weapon) {
    state = state.copyWith(weapon: () => weapon);
    _memory.write(TopSkinsMemoryKeys.weapon, weapon);
  }

  void setPeriod(TopPeriod period) {
    state = state.copyWith(period: TopPeriod.all);
    _memory.writeEnum(TopSkinsMemoryKeys.period, TopPeriod.all);
  }

  void setSort(TopSort sort) {
    state = state.copyWith(sort: sort);
    _memory.writeEnum(TopSkinsMemoryKeys.sort, sort);
  }

  /// Apply a confirmed sheet selection once; dismissing the sheet changes nothing.
  void setFilters(TopSkinsFilter filter) {
    state = filter.copyWith(period: TopPeriod.all);
    _memory.write(TopSkinsMemoryKeys.weapon, filter.weapon);
    _memory.writeEnum(TopSkinsMemoryKeys.period, TopPeriod.all);
    _memory.writeEnum(TopSkinsMemoryKeys.sort, filter.sort);
  }
}

/// Key of [topSkinsProvider] (`puuid` = whose votes are marked).
typedef TopSkinsQuery = ({
  String puuid,
  String? weapon,
  TopPeriod period,
  TopSort sort,
  ScopeFilter? scope,
});

/// The leaderboard for [TopSkinsFilter] (`GET /v1/skins/top`) with the
/// scope the server applied.
final topSkinsProvider = FutureProvider.autoDispose
    .family<TopSkinsResult, TopSkinsQuery>((ref, q) {
      // Joining changes what is marked as voted (and the token sent): reload.
      ref.watch(communityConsentProvider(q.puuid));
      return ref
          .watch(communityApiProvider)
          .topSkinsResult(
            puuid: q.puuid,
            weapon: q.weapon,
            period: q.period,
            sort: q.sort,
            scope: q.scope,
          );
    });

/// Vote states changed on this device (optimistic, then the server's
/// answer), per account. They win over fetched values so the leaderboard,
/// the review page and the skin sheet agree.
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

/// Votes + rating of one skin for the skin sheet. Read-only: uses a cached
/// community session when there is one (never signs in), and any failure
/// yields `null` so the sheet simply hides the row.
final skinVoteProvider = FutureProvider.autoDispose
    .family<SkinStats?, SkinVoteKey>((ref, key) async {
      if (!ref.watch(communityEnabledProvider)) return null;
      final viewer = key.puuid;
      if (viewer != null) ref.watch(communityConsentProvider(viewer));
      final id = key.skinUuid.toLowerCase();
      try {
        final stats = await ref.watch(communityApiProvider).skinVotes([
          id,
        ], puuid: key.puuid);
        return stats[id] ?? SkinStats(vote: SkinVote(skinUuid: id));
      } on Object {
        return null;
      }
    });
