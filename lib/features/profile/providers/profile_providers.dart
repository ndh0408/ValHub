import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/storage/ui_memory.dart';
import '../data/match_filter.dart';
import '../data/player_identity.dart';

/// Card / title / privacy flags of a signed-in account (P-8), kept 5
/// minutes. Also caches the card on the [Account] for the account switcher
/// (A4). Throws [StateError] for a PUUID that is not signed in.
final playerIdentityProvider = FutureProvider.autoDispose
    .family<PlayerIdentity, String>((ref, puuid) async {
      final id = puuid.trim().toLowerCase();
      final isOwn = ref.watch(accountProvider(id).select((a) => a != null));
      if (!isOwn) {
        throw StateError('The loadout is only available for own accounts');
      }
      final viewer = watchViewer(ref, id);
      final api = ref.watch(pvpApiProvider);
      cacheFor(ref, const Duration(minutes: 5));
      final identity = PlayerIdentity.fromLoadout(
        await api.playerLoadout(viewer),
      );
      if (!ref.mounted) return identity;
      final account = ref.read(accountProvider(id));
      final card = identity.cardId;
      if (account != null && card != null && account.cardId != card) {
        unawaited(
          ref
              .read(accountsProvider.notifier)
              .updateAccount(id, (a) => a.copyWith(cardId: card))
              .catchError((Object _) {}),
        );
      }
      return identity;
    });

/// Queue + map filter of one player's match history (family key = PUUID).
/// Kept for the app session; for signed-in accounts the choice is also
/// remembered across launches ([UiMemory] keys `profile.history.mode` /
/// `profile.history.map`), so the profile tab reopens on the same chips.
final matchFilterProvider =
    NotifierProvider.family<MatchFilterNotifier, MatchFilter, String>(
      MatchFilterNotifier.new,
    );

class MatchFilterNotifier extends Notifier<MatchFilter> {
  MatchFilterNotifier(this.puuid);

  final String puuid;

  static const modeKey = 'profile.history.mode';
  static const mapKey = 'profile.history.map';

  /// Only the user's own profiles remember the filter (another player's
  /// profile always opens on "Tất cả").
  bool get _remembers =>
      ref.read(accountProvider(puuid.trim().toLowerCase())) != null;

  @override
  MatchFilter build() {
    if (!_remembers) return const MatchFilter();
    final memory = ref.read(uiMemoryProvider);
    final queue = memory.read(modeKey);
    return MatchFilter(
      queue: queue != null && kProfileQueueFilters.contains(queue)
          ? queue
          : null,
      mapUrl: memory.read(mapKey),
    );
  }

  void setQueue(String? queue) {
    state = state.withQueue(queue);
    if (_remembers) ref.read(uiMemoryProvider).write(modeKey, queue);
  }

  void setMap(String? mapUrl) {
    state = state.withMap(mapUrl);
    if (_remembers) ref.read(uiMemoryProvider).write(mapKey, mapUrl);
  }
}

/// What another player's profile header shows, taken from their most
/// recent match (P-13 + P-14): card, title and account level at that time.
@immutable
class PlayerSnapshot {
  const PlayerSnapshot({
    this.cardId,
    this.titleId,
    this.accountLevel,
    this.lastMatchId,
  });

  final String? cardId;
  final String? titleId;

  /// `null` when unknown (0 in the data).
  final int? accountLevel;
  final String? lastMatchId;
}

/// [PlayerSnapshot] of any player (S44). Empty when they have no public
/// match; errors of the history request propagate.
final playerSnapshotProvider = FutureProvider.autoDispose
    .family<PlayerSnapshot, String>((ref, puuid) async {
      final id = puuid.trim().toLowerCase();
      final history = await ref.watch(
        matchHistoryProvider((puuid: id, queue: null)).future,
      );
      for (final entry in history.items.take(3)) {
        try {
          final details = await ref.watch(
            matchDetailsProvider(entry.matchId).future,
          );
          final p = details.player(id);
          if (p == null) continue;
          return PlayerSnapshot(
            cardId: p.playerCard,
            titleId: p.playerTitle,
            accountLevel: p.accountLevel > 0 ? p.accountLevel : null,
            lastMatchId: entry.matchId,
          );
        } on Object {
          // Try the next match (still processing, custom without data…).
        }
      }
      return const PlayerSnapshot();
    });
