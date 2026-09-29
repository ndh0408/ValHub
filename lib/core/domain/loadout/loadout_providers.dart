/// Riverpod entry points of the loadout domain.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../network/riot_exception.dart';
import '../../riot/pvp_api.dart';
import '../../storage/json_file_cache.dart';
import '../../storage/prefs.dart';
import '../../util/clock.dart';
import '../economy/owned_items.dart';
import 'loadout_changes.dart';
import 'loadout_models.dart';
import 'loadout_presets.dart';
import 'loadout_repository.dart';
import 'loadout_strings.dart';
import 'match_loadouts.dart';

/// How long a fetched loadout stays cached after the last listener leaves
/// (SUMMARY §10: loadout 10 min; a save replaces it immediately).
const kLoadoutTtl = Duration(minutes: 10);

/// App-wide [LoadoutRepository].
final loadoutRepositoryProvider = Provider<LoadoutRepository>(
  (ref) => LoadoutRepository(
    ref.watch(pvpApiProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The signed-in account's loadout (P-8) plus its save controller.
///
/// ```dart
/// final snapshot = ref.watch(loadoutProvider(puuid));      // AsyncValue<LoadoutSnapshot>
/// final vandal = snapshot.value?.loadout.gun(SpecialIds.vandal);
/// try {
///   await ref.read(loadoutProvider(puuid).notifier).apply(
///     SetPlayerCard(cardId),                                // user tapped "Trang bị"
///   );
/// } on LoadoutSaveException catch (e) {
///   showAppSnackBar(context, e.message);                    // "Không thể lưu trang bị"
/// }
/// ```
final loadoutProvider = AsyncNotifierProvider.autoDispose
    .family<LoadoutController, LoadoutSnapshot, String>(LoadoutController.new);

/// Loads the loadout and applies user-initiated changes with an optimistic
/// update and rollback (SUMMARY U8).
class LoadoutController extends AsyncNotifier<LoadoutSnapshot> {
  LoadoutController(String puuid) : puuid = puuid.trim().toLowerCase();

  final String puuid;

  /// Saves run one after another (fresh GET → PUT → re-GET each).
  Future<void> _tail = Future<void>.value();
  int _inFlight = 0;

  /// Whether a save is queued or running.
  bool get isSaving => _inFlight > 0;

  String get _cacheKey => JsonFileCache.accountKey(puuid, 'loadout');

  @override
  Future<LoadoutSnapshot> build() async {
    ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    final repo = ref.watch(loadoutRepositoryProvider);
    final link = ref.keepAlive();
    final timer = Timer(kLoadoutTtl, link.close);
    ref.onDispose(timer.cancel);

    final LoadoutSnapshot snapshot;
    try {
      snapshot = await repo.fetch(puuid);
    } on TransientException {
      final cached = await _readOffline();
      if (cached == null) rethrow;
      return cached;
    }
    unawaited(_writeOffline(snapshot));
    _cacheCard(snapshot);
    return snapshot;
  }

  /// Applies [change]: shows it at once (`isPending`), then saves through
  /// [LoadoutRepository.save]. On failure the previous value is restored and
  /// a [LoadoutSaveException] is thrown ("Không thể lưu trang bị").
  ///
  /// Must only be called from an explicit user action.
  Future<LoadoutSnapshot> apply(LoadoutChange change) {
    _inFlight++;
    final result = _tail.then((_) => _apply(change));
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result.whenComplete(() => _inFlight--);
  }

  /// Applies [preset] in one PUT, leaving out items the account no longer
  /// owns. Returns how many were left out.
  Future<int> applyPreset(LoadoutPreset preset, {OwnedItems? owned}) async {
    final application = preset.toChange(owned: owned);
    await apply(application.change);
    return application.skipped;
  }

  Future<LoadoutSnapshot> _apply(LoadoutChange change) async {
    if (!ref.mounted) {
      throw const LoadoutSaveException(LoadoutSaveFailure.notPersisted);
    }
    final previous = state.value;
    if (previous != null) {
      try {
        state = AsyncData(
          LoadoutSnapshot.fromJson(
            change.appliedTo(previous.raw),
            receivedAt: previous.receivedAt,
            isFromCache: previous.isFromCache,
            isPending: true,
          ),
        );
      } on LoadoutEditException {
        // The repository reports it against the fresh loadout.
      }
    }
    final repo = ref.read(loadoutRepositoryProvider);
    try {
      final saved = await repo.save(puuid, change);
      if (ref.mounted) {
        state = AsyncData(saved);
        unawaited(_writeOffline(saved));
        _cacheCard(saved);
      }
      return saved;
    } on Object catch (error, stack) {
      if (ref.mounted && previous != null) {
        state = AsyncData(previous.copyWith(isPending: false));
      }
      final e = error is LoadoutSaveException
          ? error
          : LoadoutSaveException(LoadoutSaveFailure.request, cause: error);
      if (ref.mounted && e.failure == LoadoutSaveFailure.notPersisted) {
        // Riot's state is unknown: show the truth.
        ref.invalidateSelf();
      }
      Error.throwWithStackTrace(e, stack);
    }
  }

  Future<LoadoutSnapshot?> _readOffline() async {
    try {
      final cached = await ref.read(jsonFileCacheProvider).read(_cacheKey);
      if (cached == null || cached.data == null) return null;
      final snapshot = LoadoutSnapshot.fromJson(
        cached.data,
        receivedAt: cached.savedAt,
        isFromCache: true,
      );
      return snapshot.isValid ? snapshot : null;
    } on Object {
      return null;
    }
  }

  Future<void> _writeOffline(LoadoutSnapshot snapshot) async {
    try {
      await ref
          .read(jsonFileCacheProvider)
          .write(_cacheKey, snapshot.raw, savedAt: snapshot.receivedAt);
    } on Object {
      // Best effort.
    }
  }

  /// Caches the equipped card on the account for the switcher (A4).
  void _cacheCard(LoadoutSnapshot snapshot) {
    final card = snapshot.loadout.identity.playerCardId;
    if (card == null || snapshot.isFromCache || !ref.mounted) return;
    try {
      final account = ref.read(accountProvider(puuid));
      if (account == null || account.cardId == card) return;
      unawaited(
        ref
            .read(accountsProvider.notifier)
            .updateAccount(puuid, (a) => a.copyWith(cardId: card))
            .catchError((Object _) {}),
      );
    } on Object {
      // Never fail a loadout read because of the account cache.
    }
  }
}

// ------------------------------------------------------------------ presets

final loadoutPresetStoreProvider = Provider<LoadoutPresetStore>(
  (ref) => LoadoutPresetStore(ref.watch(prefsProvider)),
);

/// Local presets of one account (S38), newest first.
///
/// ```dart
/// final presets = ref.watch(loadoutPresetsProvider(puuid));
/// await ref.read(loadoutPresetsProvider(puuid).notifier).save(loadout, name: 'Rank');
/// final skipped = await ref.read(loadoutProvider(puuid).notifier)
///     .applyPreset(preset, owned: owned);
/// ```
final loadoutPresetsProvider =
    NotifierProvider.family<
      LoadoutPresetsNotifier,
      List<LoadoutPreset>,
      String
    >(LoadoutPresetsNotifier.new);

class LoadoutPresetsNotifier extends Notifier<List<LoadoutPreset>> {
  LoadoutPresetsNotifier(String puuid) : puuid = puuid.trim().toLowerCase();

  final String puuid;
  int _idCounter = 0;

  LoadoutPresetStore get _store => ref.read(loadoutPresetStoreProvider);

  @override
  List<LoadoutPreset> build() =>
      ref.watch(loadoutPresetStoreProvider).read(puuid);

  /// Name proposed in the "Tên bộ trang bị" dialog.
  String get suggestedName {
    final names = {for (final p in state) p.name};
    var n = state.length + 1;
    while (names.contains(LoadoutStrings.defaultPresetName(n))) {
      n++;
    }
    return LoadoutStrings.defaultPresetName(n);
  }

  bool get isFull => state.length >= kMaxLoadoutPresets;

  /// Saves [loadout] as a new preset (first in the list). The oldest preset
  /// is dropped beyond [kMaxLoadoutPresets].
  Future<LoadoutPreset> save(Loadout loadout, {String? name}) async {
    final now = ref.read(clockProvider).now();
    final preset = LoadoutPreset.fromLoadout(
      loadout,
      id: 'p${now.microsecondsSinceEpoch}_${_idCounter++}',
      name: normalizePresetName(name) ?? suggestedName,
      createdAt: now,
    );
    await _set([preset, ...state].take(kMaxLoadoutPresets).toList());
    return preset;
  }

  Future<void> rename(String id, String name) async {
    final cleaned = normalizePresetName(name);
    if (cleaned == null) return;
    await _set([
      for (final p in state) p.id == id ? p.copyWith(name: cleaned) : p,
    ]);
  }

  Future<void> delete(String id) => _set([
    for (final p in state)
      if (p.id != id) p,
  ]);

  /// Puts a deleted preset back (undo), at [index] when possible.
  Future<void> restore(LoadoutPreset preset, {int index = 0}) async {
    if (state.any((p) => p.id == preset.id)) return;
    final next = [...state];
    next.insert(index.clamp(0, next.length), preset);
    await _set(next.take(kMaxLoadoutPresets).toList());
  }

  Future<void> _set(List<LoadoutPreset> next) async {
    state = List.unmodifiable(next);
    await _store.write(puuid, next);
  }
}

// ---------------------------------------------------------- match loadouts

/// Key of [matchLoadoutsProvider]: the signed-in account whose session is
/// used, the live match and whether it is still in agent select.
typedef MatchLoadoutsQuery = ({String puuid, String matchId, bool pregame});

/// Everyone's skins / buddies / sprays in a live match (G-7 or G-10), with
/// card / title / incognito from the match (G-3 or G-9, best effort). Not
/// cached: invalidate to refresh while the live-game sheet is open.
final matchLoadoutsProvider = FutureProvider.autoDispose
    .family<MatchLoadouts, MatchLoadoutsQuery>((ref, q) async {
      final api = ref.watch(pvpApiProvider);
      final loadoutsFuture = q.pregame
          ? api.pregameLoadouts(q.puuid, q.matchId)
          : api.coreGameLoadouts(q.puuid, q.matchId);
      Future<Object?> fetchMatch() async {
        try {
          return await (q.pregame
              ? api.pregameMatch(q.puuid, q.matchId)
              : api.coreGameMatch(q.puuid, q.matchId));
        } on Object {
          return null; // identities are optional
        }
      }

      final matchFuture = fetchMatch();
      final loadouts = await loadoutsFuture;
      final match = await matchFuture;
      return MatchLoadouts.parse(loadouts, matchJson: match);
    });
