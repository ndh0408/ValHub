import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../storage/secure_store.dart';
import '../util/json.dart';
import 'account.dart';

/// Persists account metadata in prefs and wipes per-account data.
///
/// Plain class (no Riverpod) so background isolates can use it. The UI goes
/// through `accountsProvider`, which wraps this repository.
class AccountRepository {
  AccountRepository({
    required this._prefs,
    required SecureStore secureStore,
    JsonFileCache? fileCache,
  }) : _secure = secureStore,
       _files = fileCache;

  final Prefs _prefs;
  final SecureStore _secure;
  final JsonFileCache? _files;

  /// All accounts in the user's order. Corrupt entries are skipped.
  List<Account> loadAll() {
    final seen = <String>{};
    return [
      for (final json in asList(_prefs.getJson(PrefKeys.accounts)))
        if (Account.fromJson(json) case final a? when seen.add(a.puuid)) a,
    ];
  }

  Future<void> saveAll(List<Account> accounts) =>
      _prefs.setJson(PrefKeys.accounts, [for (final a in accounts) a.toJson()]);

  Account? find(String puuid) {
    final id = puuid.toLowerCase();
    for (final a in loadAll()) {
      if (a.puuid == id) return a;
    }
    return null;
  }

  /// Inserts or replaces (keeping the list position) [account].
  Future<void> upsert(Account account) async {
    final all = loadAll();
    final i = all.indexWhere((a) => a.puuid == account.puuid);
    if (i < 0) {
      all.add(account);
    } else {
      all[i] = account;
    }
    await saveAll(all);
  }

  /// Applies [update] to the stored account, if present. Returns the result.
  Future<Account?> patch(String puuid, Account Function(Account) update) async {
    final current = find(puuid);
    if (current == null) return null;
    final next = update(current);
    if (next != current) await upsert(next);
    return next;
  }

  Future<void> removeMetadata(String puuid) async {
    final all = loadAll()..removeWhere((a) => a.puuid == puuid.toLowerCase());
    await saveAll(all);
  }

  String? get activePuuid => _prefs.getString(PrefKeys.activePuuid);

  Future<void> setActivePuuid(String? puuid) => puuid == null
      ? _prefs.remove(PrefKeys.activePuuid)
      : _prefs.setString(PrefKeys.activePuuid, puuid.toLowerCase());

  /// Sign-out (A11, SUMMARY §3.5): deletes the account's cookie jars, token
  /// cache, `acct.<puuid>.*` prefs and `acct/<puuid>/…` file caches. Keeps
  /// `keep.<puuid>.*` (wishlist, VF W6).
  Future<void> wipeAccountData(String puuid) async {
    final id = puuid.toLowerCase();
    for (final key in SecureKeys.allFor(id)) {
      await _secure.delete(key);
    }
    await _prefs.removePrefix(PrefKeys.accountPrefix(id));
    await _files?.deletePrefix(JsonFileCache.accountPrefix(id));
  }
}
