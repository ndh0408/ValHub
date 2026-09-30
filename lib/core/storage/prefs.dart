import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/json.dart';

/// Key conventions for [Prefs].
///
/// - App-wide keys: `app.<name>` / `settings.<name>`.
/// - Feature keys: `f.<feature>.<name>`.
/// - Per-account keys that must be wiped on sign-out: `acct.<puuid>.<name>`
///   (use [PrefKeys.account]).
/// - Per-account keys that must SURVIVE sign-out (wishlist, VF W6):
///   `keep.<puuid>.<name>` (use [PrefKeys.accountKept]).
abstract final class PrefKeys {
  static const accounts = 'app.accounts';
  static const activePuuid = 'app.activePuuid';
  static const installMarker = 'app.installed';
  static const clientVersion = 'app.clientVersion';
  static const remoteConfig = 'app.remoteConfig';
  static const appSettings = 'settings.app';

  /// Set once the single wishlist-alert switch was split per account.
  static const wishlistPerAccountMigrated = 'settings.wishlistPerAccountV1';

  /// The user's own VP pack price (`VpPriceOverride`).
  static const vpPriceOverride = 'settings.vpPrice';
  static const notificationPrimingShown = 'app.notificationPrimingShown';

  /// Per-account key wiped on sign-out.
  static String account(String puuid, String name) => 'acct.$puuid.$name';

  /// Prefix of every per-account key wiped on sign-out.
  static String accountPrefix(String puuid) => 'acct.$puuid.';

  /// Per-account key that survives sign-out (e.g. wishlist).
  static String accountKept(String puuid, String name) => 'keep.$puuid.$name';

  /// Remembered UI choice (last segment / filter) — see `UiMemory`.
  static String ui(String name) => 'ui.$name';
}

/// Thin synchronous-read wrapper around [SharedPreferencesWithCache].
///
/// Create once with [Prefs.create] (UI isolate in `main()`, and separately in
/// each background isolate) and provide it through [prefsProvider]. Writes are
/// async and write-through. Call [reload] after returning from background
/// (another isolate may have written).
class Prefs {
  Prefs(this._prefs);

  SharedPreferencesWithCache _prefs;

  /// Writes made while [reload] is reading from disk; replayed on the fresh
  /// cache so they are not overwritten by the older disk snapshot.
  List<Future<void> Function(SharedPreferencesWithCache)>? _pendingWrites;
  Future<void>? _reloading;

  static Future<SharedPreferencesWithCache> _open() =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );

  static Future<Prefs> create() async => Prefs(await _open());

  /// Re-reads every value from disk. The current cache keeps serving reads
  /// until the fresh snapshot is ready (never an empty window), then it is
  /// swapped in atomically.
  Future<void> reload() => _reloading ??= _reload().whenComplete(() {
    _reloading = null;
  });

  Future<void> _reload() async {
    _pendingWrites = [];
    try {
      final fresh = await _open();
      final pending = _pendingWrites ?? const [];
      _pendingWrites = null;
      _prefs = fresh;
      for (final write in pending) {
        await write(fresh);
      }
    } finally {
      _pendingWrites = null;
    }
  }

  Future<void> _write(Future<void> Function(SharedPreferencesWithCache) op) {
    _pendingWrites?.add(op);
    return op(_prefs);
  }

  Set<String> get keys => _prefs.keys;
  bool containsKey(String key) => _prefs.containsKey(key);

  String? getString(String key) => _safe(() => _prefs.getString(key));
  int? getInt(String key) => _safe(() => _prefs.getInt(key));
  double? getDouble(String key) => _safe(() => _prefs.getDouble(key));
  bool? getBool(String key) => _safe(() => _prefs.getBool(key));
  List<String>? getStringList(String key) =>
      _safe(() => _prefs.getStringList(key));

  /// Reads [key] straight from disk (bypassing this isolate's cache), for
  /// read-modify-write of values another isolate may have changed. Falls
  /// back to the cached value when storage is unavailable.
  Future<String?> getStringFromDisk(String key) async {
    try {
      return await SharedPreferencesAsync().getString(key);
    } on Object {
      return getString(key);
    }
  }

  /// [getStringList] straight from disk (see [getStringFromDisk]).
  Future<List<String>?> getStringListFromDisk(String key) async {
    try {
      return await SharedPreferencesAsync().getStringList(key);
    } on Object {
      return getStringList(key);
    }
  }

  /// Every key on disk (including ones written by other isolates since the
  /// last [reload]), plus the cached ones.
  Future<Set<String>> keysOnDisk() async {
    try {
      return {...await SharedPreferencesAsync().getKeys(), ...keys};
    } on Object {
      return keys;
    }
  }

  Future<void> setString(String key, String value) =>
      _write((p) => p.setString(key, value));
  Future<void> setInt(String key, int value) =>
      _write((p) => p.setInt(key, value));
  Future<void> setDouble(String key, double value) =>
      _write((p) => p.setDouble(key, value));
  Future<void> setBool(String key, bool value) =>
      _write((p) => p.setBool(key, value));
  Future<void> setStringList(String key, List<String> value) =>
      _write((p) => p.setStringList(key, value));

  Future<void> remove(String key) => _write((p) => p.remove(key));

  /// Removes every key starting with [prefix], including keys another
  /// isolate wrote since the last [reload].
  Future<void> removePrefix(String prefix) async {
    for (final key in (await keysOnDisk()).where((k) => k.startsWith(prefix))) {
      await remove(key);
    }
  }

  /// Decodes a JSON value stored with [setJson]; `null` when absent/corrupt.
  Object? getJson(String key) => tryDecodeJson(getString(key));

  /// Stores [value] as a JSON string.
  Future<void> setJson(String key, Object? value) =>
      setString(key, jsonEncode(value));

  /// Reads a stored instant (epoch ms).
  DateTime? getDateTime(String key) {
    final ms = getInt(key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setDateTime(String key, DateTime value) =>
      setInt(key, value.millisecondsSinceEpoch);

  /// A value of the wrong type (e.g. after a schema change) reads as null
  /// instead of throwing.
  static T? _safe<T>(T? Function() read) {
    try {
      return read();
    } on Object {
      return null;
    }
  }
}

/// App-wide [Prefs]. MUST be overridden in `main()` (and in tests):
/// `prefsProvider.overrideWithValue(await Prefs.create())`.
final prefsProvider = Provider<Prefs>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden'),
);
