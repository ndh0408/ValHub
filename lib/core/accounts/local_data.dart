import '../domain/competitive/names.dart' show NameResolver;
import '../domain/competitive/rr_history.dart';
import '../domain/loadout/loadout_presets.dart' show LoadoutPresetStore;
import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';

/// The data ValVN keeps on the device **beyond** the signed-in session, and how
/// to erase it (decision D3, AR-002):
///
/// | Data | Where | Erased |
/// |---|---|---|
/// | Wishlist, loadout presets | `keep.<puuid>.*` prefs | at sign-out unless kept; [eraseAll] |
/// | RR history (own accounts) | `history/keep/<puuid>/` | at sign-out unless kept; [eraseAll] |
/// | Player names (Riot IDs) | prefs `f.competitive.names` | [eraseSharedCaches] |
/// | Matches seen | `cache/matches/` | [eraseSharedCaches] |
///
/// Only public APIs of the stores are used (`RrHistoryStore.delete` / `clear`);
/// their internals belong to the competitive domain.
class LocalDataEraser {
  LocalDataEraser({
    required this._prefs,
    required this._cache,
    required this._history,
  });

  final Prefs _prefs;
  final JsonFileCache _cache;
  final RrHistoryStore _history;

  /// What an account chose to keep is erased: its `keep.<puuid>.*` prefs
  /// (wishlist, presets) and its RR history.
  Future<void> eraseAccount(String puuid) async {
    final id = puuid.trim().toLowerCase();
    await _prefs.removePrefix(PrefKeys.accountKeptPrefix(id));
    await _history.delete(id);
  }

  /// The caches that hold **other players'** data: Riot IDs looked up by
  /// PUUID and the matches that were opened.
  Future<void> eraseSharedCaches() async {
    await _prefs.remove(NameResolver.prefsKey);
    await _cache.deletePrefix('matches');
    await _cache.deletePrefix('names');
  }

  /// "Xóa dữ liệu cục bộ": RR history of everyone, loadout presets of every
  /// account, everything kept for accounts that are **no longer** signed in
  /// (wishlist included), and the shared caches. The wishlist of an account
  /// that is still signed in stays: it has its own screen.
  Future<void> eraseAll({required Set<String> signedIn}) async {
    final keep = {for (final id in signedIn) id.trim().toLowerCase()};
    await _history.clear();
    // Current and future account-scoped history recorders share this root.
    for (final id in keep) {
      await _cache.deletePrefix('acct/$id/store_history');
    }
    for (final key in await _prefs.keysOnDisk()) {
      final id = keptKeyOwner(key);
      if (id == null) continue;
      final isPreset = key == LoadoutPresetStore.key(id);
      if (isPreset || !keep.contains(id)) await _prefs.remove(key);
    }
    await eraseSharedCaches();
  }

  /// The PUUID a `keep.<puuid>.<name>` pref key belongs to, or `null`.
  static String? keptKeyOwner(String key) {
    if (!key.startsWith('keep.')) return null;
    final rest = key.substring(5);
    final dot = rest.indexOf('.');
    if (dot <= 0) return null;
    return rest.substring(0, dot).toLowerCase();
  }
}
