import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';

/// Per-account wishlist persistence (W1–W3, W6).
///
/// Shared contract: the store, skin-detail, wishlist and settings features
/// all read/write the same data. Entries are **skin uuids** (lowercase); match
/// store offers through `ContentDb.skinByLevelUuid(offer).uuid`. Stored under
/// `keep.<puuid>.wishlist` so it survives sign-out (VF W6).
///
/// Plain class so the background wishlist check can use it without Riverpod.
class WishlistRepository {
  WishlistRepository(this._prefs);

  final Prefs _prefs;

  static String key(String puuid) =>
      PrefKeys.accountKept(puuid.toLowerCase(), 'wishlist');

  Set<String> read(String puuid) => {
    for (final id in _prefs.getStringList(key(puuid)) ?? const <String>[])
      if (id.trim().isNotEmpty) id.trim().toLowerCase(),
  };

  Future<void> write(String puuid, Set<String> skinUuids) =>
      _prefs.setStringList(key(puuid), skinUuids.toList()..sort());
}

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(ref.watch(prefsProvider)),
);

/// Wishlist of one account (family key = PUUID).
///
/// ```dart
/// final wishlist = ref.watch(wishlistProvider(puuid));
/// final inList = wishlist.contains(skin.uuid);
/// await ref.read(wishlistProvider(puuid).notifier).toggle(skin.uuid);
/// ```
final wishlistProvider =
    NotifierProvider.family<WishlistNotifier, Set<String>, String>(
      WishlistNotifier.new,
    );

class WishlistNotifier extends Notifier<Set<String>> {
  WishlistNotifier(this.puuid);

  final String puuid;

  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  @override
  Set<String> build() => ref.watch(wishlistRepositoryProvider).read(puuid);

  bool contains(String skinUuid) => state.contains(skinUuid.toLowerCase());

  Future<void> add(String skinUuid) => _set({...state, skinUuid.toLowerCase()});

  Future<void> remove(String skinUuid) =>
      _set({...state}..remove(skinUuid.toLowerCase()));

  /// Returns the new membership.
  Future<bool> toggle(String skinUuid) async {
    final id = skinUuid.toLowerCase();
    final adding = !state.contains(id);
    await (adding ? add(id) : remove(id));
    return adding;
  }

  Future<void> _set(Set<String> next) async {
    state = next;
    await _repo.write(puuid, next);
  }
}
