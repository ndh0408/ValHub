import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../storage/secure_store.dart';
import '../util/json.dart';
import 'account.dart';

/// What [AccountRepository.sweepOrphans] found and removed.
@immutable
class SweepReport {
  const SweepReport({this.accounts = const {}, this.finishedSignOuts = 0});

  /// PUUIDs whose leftovers were wiped (never signed-in accounts).
  final Set<String> accounts;

  /// Interrupted sign-outs that were completed.
  final int finishedSignOuts;

  bool get isEmpty => accounts.isEmpty && finishedSignOuts == 0;

  @override
  String toString() =>
      'SweepReport(orphans: ${accounts.length}, finished: $finishedSignOuts)';
}

/// Persists account metadata in prefs and wipes per-account data.
///
/// Plain class (no Riverpod) so background isolates can use it. The UI goes
/// through `accountsProvider`, which wraps this repository.
///
/// Every read-modify-write of the account list ([upsert], [patch],
/// [removeMetadata]) runs through one queue, so concurrent providers patching
/// different accounts cannot drop each other's update (AR-020), and each one
/// starts from the list as it is on disk (another isolate may have changed it).
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

  static final RegExp _uuidShape = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  Future<void> _tail = Future<void>.value();

  /// Runs [body] after every earlier queued operation finished (a failure
  /// of one never blocks the next).
  Future<T> _serial<T>(Future<T> Function() body) {
    final result = Completer<T>();
    final previous = _tail;
    _tail = result.future.then<void>((_) {}, onError: (Object _) {});
    unawaited(
      previous.then<void>((_) async {
        try {
          result.complete(await body());
        } on Object catch (e, st) {
          result.completeError(e, st);
        }
      }),
    );
    return result.future;
  }

  /// All accounts in the user's order. Corrupt entries are skipped.
  List<Account> loadAll() => _parse(_prefs.getJson(PrefKeys.accounts));

  static List<Account> _parse(Object? raw) {
    final seen = <String>{};
    return [
      for (final json in asList(raw))
        if (Account.fromJson(json) case final a? when seen.add(a.puuid)) a,
    ];
  }

  /// The list as stored on disk right now. Read-modify-write goes through
  /// this, because another isolate (background task) may have changed the
  /// list since this isolate's prefs cache was loaded; rewriting the stale
  /// cached list would resurrect removed accounts or drop `needsLogin`.
  Future<List<Account>> _loadFresh() async =>
      _parse(tryDecodeJson(await _prefs.getStringFromDisk(PrefKeys.accounts)));

  /// Like [find], but reads the list from disk (cross-isolate check).
  Future<Account?> findFresh(String puuid) async {
    final id = puuid.toLowerCase();
    for (final a in await _loadFresh()) {
      if (a.puuid == id) return a;
    }
    return null;
  }

  /// Replaces the whole list and bumps [PrefKeys.accountsVersion].
  Future<void> saveAll(List<Account> accounts) async {
    await _prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    await _prefs.setInt(
      PrefKeys.accountsVersion,
      (await accountsVersionOnDisk()) + 1,
    );
  }

  /// How many times the list was written (as this isolate last saw it).
  int get accountsVersion => _prefs.getInt(PrefKeys.accountsVersion) ?? 0;

  /// [accountsVersion] as it is on disk now: a larger value than the cached one
  /// means another isolate changed the list.
  Future<int> accountsVersionOnDisk() async {
    try {
      return await _prefs.getIntFromDisk(PrefKeys.accountsVersion) ?? 0;
    } on Object {
      return accountsVersion;
    }
  }

  Account? find(String puuid) {
    final id = puuid.toLowerCase();
    for (final a in loadAll()) {
      if (a.puuid == id) return a;
    }
    return null;
  }

  /// Inserts or replaces (keeping the list position) [account]. Adding an
  /// account also lifts the write block a sign-out left on its PUUID.
  Future<void> upsert(Account account) => _serial(() async {
    _allowWrites(account.puuid);
    final all = await _loadFresh();
    final i = all.indexWhere((a) => a.puuid == account.puuid);
    if (i < 0) {
      all.add(account);
    } else {
      all[i] = account;
    }
    await saveAll(all);
  });

  /// Applies [update] to the stored account, if present. Returns the result.
  Future<Account?> patch(String puuid, Account Function(Account) update) =>
      _serial(() async {
        final id = puuid.toLowerCase();
        final all = await _loadFresh();
        final i = all.indexWhere((a) => a.puuid == id);
        if (i < 0) return null;
        final current = all[i];
        final next = update(current);
        if (next != current || find(id) != current) {
          all[i] = next;
          await saveAll(all);
        }
        return next;
      });

  Future<void> removeMetadata(String puuid) => _serial(() async {
    final all = (await _loadFresh())
      ..removeWhere((a) => a.puuid == puuid.toLowerCase());
    await saveAll(all);
  });

  String? get activePuuid => _prefs.getString(PrefKeys.activePuuid);

  Future<void> setActivePuuid(String? puuid) => puuid == null
      ? _prefs.remove(PrefKeys.activePuuid)
      : _prefs.setString(PrefKeys.activePuuid, puuid.toLowerCase());

  // ------------------------------------------------------------- sign-out

  void _allowWrites(String puuid) {
    final id = puuid.toLowerCase();
    _prefs
      ..allowWrites(PrefKeys.accountPrefix(id))
      ..allowWrites(PrefKeys.accountKeptPrefix(id));
    _files?.allowWrites(JsonFileCache.accountPrefix(id));
  }

  /// Sign-outs that started and did not finish: `puuid → keepLocalData`.
  Map<String, bool> get pendingWipes {
    final raw = asMap(_prefs.getJson(PrefKeys.pendingWipe));
    if (raw == null) return const {};
    return {
      for (final e in raw.entries)
        if (e.key.isNotEmpty) e.key.toLowerCase(): asBool(e.value) ?? true,
    };
  }

  /// Written FIRST by a sign-out ([clearPendingWipe] clears it LAST): if the
  /// app is killed in between, the next start finishes the job
  /// ([finishPendingWipes]) with the same [keepLocalData] choice.
  Future<void> markPendingWipe(String puuid, {required bool keepLocalData}) =>
      _serial(() async {
        final next = {...pendingWipes, puuid.toLowerCase(): keepLocalData};
        await _prefs.setString(PrefKeys.pendingWipe, jsonEncode(next));
      });

  Future<void> clearPendingWipe(String puuid) => _serial(() async {
    final next = {...pendingWipes}..remove(puuid.toLowerCase());
    if (next.isEmpty) {
      await _prefs.remove(PrefKeys.pendingWipe);
    } else {
      await _prefs.setString(PrefKeys.pendingWipe, jsonEncode(next));
    }
  });

  /// Sign-out (A11, SUMMARY §3.5): deletes the account's cookie jars, token
  /// cache, login note, community session, `acct.<puuid>.*` prefs and
  /// `acct/<puuid>/…` file caches, and blocks any later write under those
  /// keys until the account is added again (an in-flight fetch must not
  /// re-create them).
  ///
  /// With [keepLocalData] (the default) `keep.<puuid>.*` (wishlist, loadout
  /// presets) stays, VF W6; without it those go too.
  Future<void> wipeAccountData(
    String puuid, {
    bool keepLocalData = true,
  }) async {
    final id = puuid.toLowerCase();
    _prefs.blockWrites(PrefKeys.accountPrefix(id));
    _files?.blockWrites(JsonFileCache.accountPrefix(id));
    for (final key in SecureKeys.allFor(id)) {
      await _secure.delete(key);
    }
    await _prefs.removePrefix(PrefKeys.accountPrefix(id));
    await _files?.deletePrefix(JsonFileCache.accountPrefix(id));
    if (!keepLocalData) {
      _prefs.blockWrites(PrefKeys.accountKeptPrefix(id));
      await _prefs.removePrefix(PrefKeys.accountKeptPrefix(id));
    }
  }

  /// Completes the sign-outs a kill interrupted: removes the account from the
  /// list when it is still there and wipes its data with the recorded
  /// choice. Returns the PUUIDs finished. [beforeWipe] runs first for each
  /// (e.g. cancelling its notifications, whose ids are in `acct.<id>.*`).
  Future<Set<String>> finishPendingWipes({
    Future<void> Function(String puuid)? beforeWipe,
    Future<void> Function(String puuid)? afterWipe,
  }) async {
    final pending = pendingWipes;
    final done = <String>{};
    for (final entry in pending.entries) {
      final id = entry.key;
      try {
        if (beforeWipe != null) await beforeWipe(id);
        await removeMetadata(id);
        await wipeAccountData(id, keepLocalData: entry.value);
        if (afterWipe != null) await afterWipe(id);
        await clearPendingWipe(id);
        done.add(id);
      } on Object {
        // Left in the marker: the next start tries again.
      }
    }
    return done;
  }

  /// Deletes what accounts that are not in the list left behind (secure keys,
  /// `acct.<puuid>.*` prefs and `acct/<puuid>/` files): a kill in the middle
  /// of a sign-out, or an in-flight fetch that finished after it. **Never**
  /// touches `keep.*` (data the user chose to keep) nor keys that are not
  /// shaped like `acct.<uuid>`.
  ///
  /// Run once at start, before any login can be in progress (a login writes
  /// its secrets before the account joins the list). [beforeWipe] runs for
  /// each orphan first (e.g. cancelling its notifications).
  Future<SweepReport> sweepOrphans({
    Future<void> Function(String puuid)? beforeWipe,
  }) => _serial(() async {
    final known = {for (final a in await _loadFresh()) a.puuid};
    final orphans = <String>{};
    void consider(String? id) {
      if (id != null && _uuidShape.hasMatch(id) && !known.contains(id)) {
        orphans.add(id);
      }
    }

    for (final key in await _secure.readAllKeys()) {
      consider(SecureKeys.puuidOf(key));
    }
    for (final key in await _prefs.keysOnDisk()) {
      consider(SecureKeys.puuidOf(key));
    }
    final directories = await _files?.listDirectories('acct');
    for (final dir in directories ?? const <String>[]) {
      consider(dir.toLowerCase());
    }
    final pending = pendingWipes;
    for (final id in orphans) {
      try {
        if (beforeWipe != null) await beforeWipe(id);
        await wipeAccountData(id, keepLocalData: pending[id] ?? true);
      } on Object {
        // Retried at the next start.
      }
    }
    return SweepReport(accounts: orphans);
  });

  /// Whether [key] (`acct.<uuid>…` in prefs or secure storage) belongs to an
  /// account outside [known]; exposed for tests.
  @visibleForTesting
  static bool isOrphanKey(String key, Set<String> known) {
    final id = SecureKeys.puuidOf(key);
    return id != null && _uuidShape.hasMatch(id) && !known.contains(id);
  }
}
