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
}

/// Key/value store for secrets (cookies, tokens). Values are never logged.
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  /// Deletes every ValVN secret (first launch after a reinstall, sign-out all).
  Future<void> deleteAll();
}

/// [SecureStore] backed by the Keychain / Android Keystore.
///
/// - Android: `storageNamespace: valvn_secure` (flutter_secure_storage 11).
/// - iOS: `first_unlock_this_device` so background tasks can read it while the
///   phone is locked; never synchronised to iCloud.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
    : _storage = storage ?? defaultStorage;

  static const defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(storageNamespace: 'valvn_secure'),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

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
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();
}

/// App-wide [SecureStore].
final secureStoreProvider = Provider<SecureStore>(
  (ref) => FlutterSecureStore(),
);
