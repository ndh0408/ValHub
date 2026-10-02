/// Local "seen" tracking for the Night Market segment (VF §6.2 common
/// header: red dot on the segment until the user has opened it in ValHub,
/// per account). This is not Riot's `IsSeen` flag, which follows the game
/// client's card flips.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs.dart';

/// Persists the `BonusOfferID`s of the Night Market the user last opened,
/// per account (wiped at sign-out with the other `acct.<puuid>.*` keys).
class NightMarketSeenStore {
  NightMarketSeenStore(this._prefs);

  final Prefs _prefs;

  static String key(String puuid) =>
      PrefKeys.account(puuid.toLowerCase(), 'nightMarketSeen');

  Set<String> read(String puuid) =>
      normalizeOfferIds(_prefs.getStringList(key(puuid)) ?? const <String>[]);

  Future<void> write(String puuid, Set<String> bonusOfferIds) =>
      _prefs.setStringList(key(puuid), bonusOfferIds.toList()..sort());
}

/// Trimmed, lowercase, non-empty ids.
Set<String> normalizeOfferIds(Iterable<String> ids) => {
  for (final id in ids)
    if (id.trim().isNotEmpty) id.trim().toLowerCase(),
};

/// Whether [offerIds] contains an id the user has not seen yet.
bool hasUnseenOffers(Iterable<String> offerIds, Set<String> seen) =>
    normalizeOfferIds(offerIds).any((id) => !seen.contains(id));

final nightMarketSeenStoreProvider = Provider<NightMarketSeenStore>(
  (ref) => NightMarketSeenStore(ref.watch(prefsProvider)),
);

/// Bonus-offer ids of the Night Market rotation the user last opened.
///
/// ```dart
/// final seen = ref.watch(nightMarketSeenProvider(puuid));
/// final dot = hasUnseenOffers(nm.offers.map((o) => o.bonusOfferId), seen);
/// await ref.read(nightMarketSeenProvider(puuid).notifier)
///     .markSeen(nm.offers.map((o) => o.bonusOfferId));
/// ```
final nightMarketSeenProvider =
    NotifierProvider.family<NightMarketSeenNotifier, Set<String>, String>(
      NightMarketSeenNotifier.new,
    );

class NightMarketSeenNotifier extends Notifier<Set<String>> {
  NightMarketSeenNotifier(this.puuid);

  final String puuid;

  @override
  Set<String> build() => ref.watch(nightMarketSeenStoreProvider).read(puuid);

  /// Records the offers currently on screen as seen. Only the current
  /// rotation is kept, so the stored list never grows.
  Future<void> markSeen(Iterable<String> bonusOfferIds) async {
    final next = normalizeOfferIds(bonusOfferIds);
    if (next.isEmpty || next.every(state.contains)) return;
    state = next;
    await ref.read(nightMarketSeenStoreProvider).write(puuid, next);
  }
}
