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
  static const notificationPrimingShown = 'app.notificationPrimingShown';

  /// Per-account key wiped on sign-out.
  static String account(String puuid, String name) => 'acct.$puuid.$name';

  /// Prefix of every per-account key wiped on sign-out.
  static String accountPrefix(String puuid) => 'acct.$puuid.';

  /// Per-account key that survives sign-out (e.g. wishlist).
  static String accountKept(String puuid, String name) => 'keep.$puuid.$name';
}

/// Thin synchronous-read wrapper around [SharedPreferencesWithCache].
///
/// Create once with [Prefs.create] (UI isolate in `main()`, and separately in
/// each background isolate) and provide it through [prefsProvider]. Writes are
/// async and write-through. Call [reload] after returning from background
/// (another isolate may have written).
class Prefs {
  Prefs(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<Prefs> create() async => Prefs(
    await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    ),
  );

  /// Re-reads every value from disk.
  Future<void> reload() => _prefs.reloadCache();

  Set<String> get keys => _prefs.keys;
  bool containsKey(String key) => _prefs.containsKey(key);

  String? getString(String key) => _safe(() => _prefs.getString(key));
  int? getInt(String key) => _safe(() => _prefs.getInt(key));
  double? getDouble(String key) => _safe(() => _prefs.getDouble(key));
  bool? getBool(String key) => _safe(() => _prefs.getBool(key));
  List<String>? getStringList(String key) =>
      _safe(() => _prefs.getStringList(key));

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  /// Removes every key starting with [prefix].
  Future<void> removePrefix(String prefix) async {
    for (final key in keys.where((k) => k.startsWith(prefix)).toList()) {
      await _prefs.remove(key);
    }
  }

  /// Decodes a JSON value stored with [setJson]; `null` when absent/corrupt.
  Object? getJson(String key) => tryDecodeJson(getString(key));

  /// Stores [value] as a JSON string.
  Future<void> setJson(String key, Object? value) =>
      _prefs.setString(key, jsonEncode(value));

  /// Reads a stored instant (epoch ms).
  DateTime? getDateTime(String key) {
    final ms = getInt(key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setDateTime(String key, DateTime value) =>
      _prefs.setInt(key, value.millisecondsSinceEpoch);

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
