import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure-storage key schema (SUMMARY §3.5). Every key is scoped by PUUID.
abstract final class SecureKeys {
  static String cookies(String puuid) => 'acct.$puuid.cookies';
  static String previousCookies(String puuid) => 'acct.$puuid.cookies.prev';
  static String accessToken(String puuid) => 'acct.$puuid.access';
  static String idToken(String puuid) => 'acct.$puuid.id';
  static String entitlementsToken(String puuid) => 'acct.$puuid.entitlements';
  static String tokenExpiry(String puuid) => 'acct.$puuid.expiry';

  /// The user's own login note (Riot username + password), opt-in. Kept
  /// when the session expires; deleted only with the account.
  static String loginNote(String puuid) => 'acct.$puuid.login';

  /// Session token of the ValVN community server (docs/community-api.md).
  static String community(String puuid) => 'acct.$puuid.community';

  /// Every key that belongs to [puuid] (wiped on sign-out).
  static List<String> allFor(String puuid) => [
    cookies(puuid),
    previousCookies(puuid),
    accessToken(puuid),
    idToken(puuid),
    entitlementsToken(puuid),
    tokenExpiry(puuid),
    loginNote(puuid),
    community(puuid),
  ];

  /// The PUUID a key belongs to (`acct.<puuid>.…`), lower case, or `null`
  /// for a key outside the schema.
  static String? puuidOf(String key) {
    if (!key.startsWith('acct.')) return null;
    final rest = key.substring(5);
    final dot = rest.indexOf('.');
    final id = dot < 0 ? rest : rest.substring(0, dot);
    return id.isEmpty ? null : id.toLowerCase();
  }
}

/// Key/value store for secrets (cookies, tokens). Values are never logged.
abstract interface class SecureStore {
  Future<String?> read(String key);

  /// Presence only, without decrypting stored values (login-note picker).
  Future<bool> containsKey(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  /// Every key currently stored (never the values), for the orphan sweeper
  /// (`AccountRepository.sweepOrphans`). Empty when the store cannot be read.
  Future<Set<String>> readAllKeys();

  /// Deletes every ValVN secret (first launch after a reinstall, sign-out all).
  Future<void> deleteAll();
}

/// Receives the operation (`read`, `write`, …) and the error of a failed
/// keystore call, for the session log. Must never see keys or values.
typedef SecureErrorSink = void Function(String operation, Object error);

/// [SecureStore] backed by the Keychain / Android Keystore.
///
/// - Android: `storageNamespace: valvn_secure` (flutter_secure_storage 11) and
///   `resetOnError: false`: a Keystore hiccup (backup restore, OEM bug, lock
///   screen change) no longer erases every account silently. Instead:
///   - a failed **read** is reported to [onError] and reads as "no value", so
///     the account simply needs a new login while the data is kept (the
///     Keystore may recover);
///   - a failed **write** is reported and retried once, then rethrown. It
///     never resets unrelated accounts' secrets.
/// - iOS: `first_unlock_this_device` so background tasks can read it while the
///   phone is locked; never synchronised to iCloud.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage, this.onError])
    : _storage = storage ?? defaultStorage;

  static const defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      storageNamespace: 'valvn_secure',
      resetOnError: false,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  /// Where failures are reported (the session log). Assigned by whoever owns
  /// the log (`sessionManagerProvider`, `BackgroundContext`).
  SecureErrorSink? onError;

  void _report(String operation, Object error) {
    try {
      onError?.call(operation, error);
    } on Object {
      // Reporting must never break storage.
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on Object catch (e) {
      _report('read', e);
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } on Object catch (e) {
      _report('containsKey', e);
      return false;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return;
    } on Object catch (e) {
      _report('write', e);
    }
    try {
      await _storage.write(key: key, value: value);
      return;
    } on Object catch (e) {
      _report('write.retry', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on Object catch (e) {
      // Best effort: the orphan sweeper retries at the next start.
      _report('delete', e);
      rethrow;
    }
  }

  @override
  Future<Set<String>> readAllKeys() async {
    try {
      return (await _storage.readAll()).keys.toSet();
    } on Object catch (e) {
      _report('readAll', e);
      return const <String>{};
    }
  }

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// In-memory [SecureStore] for tests and previews.
class MemorySecureStore implements SecureStore {
  MemorySecureStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<Set<String>> readAllKeys() async => values.keys.toSet();

  @override
  Future<void> deleteAll() async => values.clear();
}

/// App-wide [SecureStore].
final secureStoreProvider = Provider<SecureStore>(
  (ref) => FlutterSecureStore(),
);
