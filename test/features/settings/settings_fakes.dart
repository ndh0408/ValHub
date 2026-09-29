import 'dart:ui' show Rect;

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/features/settings/data/cache_stats.dart';
import 'package:valvn/features/settings/providers/settings_providers.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MockSessionManager extends Mock implements SessionManager {}

/// In-memory [JsonFileCache] (no `dart:io`, so nothing races against
/// `pumpAndSettle`).
class FakeJsonFileCache extends JsonFileCache {
  FakeJsonFileCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};
  int size = 0;

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime(2026));

  @override
  Future<void> delete(String key) async => entries.remove(key);

  @override
  Future<void> deletePrefix(String prefix) async =>
      entries.removeWhere((k, _) => k.startsWith(prefix));

  @override
  Future<void> clear() async {
    entries.clear();
    size = 0;
  }

  @override
  Future<int> sizeBytes() async => size;
}

/// Records permission requests and cancellations; never touches a plugin.
class FakeNotificationService extends NotificationService {
  FakeNotificationService({this.enabled = false, this.grantOnRequest = true});

  bool enabled;
  bool grantOnRequest;
  int permissionRequests = 0;
  int openedSystemSettings = 0;
  final cancelled = <int>[];

  @override
  Future<void> init() async {}

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    enabled = grantOnRequest;
    return grantOnRequest;
  }

  @override
  Future<void> openSystemSettings() async => openedSystemSettings++;

  @override
  Future<void> cancel(int id, {String? tag}) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelForAccount(String puuid) async {}
}

/// A [CacheService] over a [FakeJsonFileCache] and a fake media size.
class FakeCacheService extends CacheService {
  FakeCacheService(this.fileCache, {int mediaBytes = 0})
    : _media = mediaBytes,
      super(responses: fileCache);

  final FakeJsonFileCache fileCache;
  int _media;
  int clears = 0;
  bool fail = false;

  @override
  Future<int> sizeBytes() async => fileCache.size + _media;

  @override
  Future<int> clear() async {
    if (fail) throw StateError('disk');
    clears++;
    final freed = await sizeBytes();
    fileCache.size = 0;
    _media = 0;
    return freed;
  }
}

String testPuuid(int i) =>
    '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}';

Account testAccount(
  int i, {
  bool needsLogin = false,
  GamePlatform platform = GamePlatform.pc,
}) => Account(
  puuid: testPuuid(i),
  gameName: 'Player$i',
  tagLine: 'VN',
  region: 'ap',
  shard: 'ap',
  needsLogin: needsLogin,
  platform: platform,
);

Future<void> seedAccounts(Prefs prefs, List<Account> accounts) =>
    prefs.setJson(PrefKeys.accounts, [for (final a in accounts) a.toJson()]);

/// Every override the settings screens need: no platform channels, no
/// network.
class SettingsTestEnv {
  SettingsTestEnv(this.prefs)
    : fileCache = FakeJsonFileCache(),
      notifications = FakeNotificationService(),
      api = MockPvpApi(),
      sessions = MockSessionManager() {
    cacheService = FakeCacheService(fileCache, mediaBytes: 5 * 1024 * 1024);
    when(() => api.platformStatus(any()))
        .thenAnswer((_) async => <String, dynamic>{});
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => sessions.forget(any())).thenAnswer((_) async {});
  }

  final Prefs prefs;
  final FakeJsonFileCache fileCache;
  final FakeNotificationService notifications;
  final MockPvpApi api;
  final MockSessionManager sessions;
  late final FakeCacheService cacheService;
  SessionLog log = SessionLog();
  Future<PackageInfo> Function() loadPackageInfo = () async => PackageInfo(
    appName: 'ValVN',
    packageName: 'vn.valvn.app',
    version: '1.2.3',
    buildNumber: '42',
  );
  final openedUrls = <Uri>[];
  bool urlOpens = true;
  final shared = <String>[];
  Rect? lastShareOrigin;

  List<Override> get overrides => [
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(MemorySecureStore()),
    jsonFileCacheProvider.overrideWithValue(fileCache),
    notificationServiceProvider.overrideWithValue(notifications),
    pvpApiProvider.overrideWithValue(api),
    sessionManagerProvider.overrideWithValue(sessions),
    packageInfoProvider.overrideWith((ref) => loadPackageInfo()),
    cacheServiceProvider.overrideWithValue(cacheService),
    sessionLogProvider.overrideWithValue(log),
    externalUrlOpenerProvider.overrideWithValue((uri) async {
      openedUrls.add(uri);
      return urlOpens;
    }),
    textSharerProvider.overrideWithValue((text, {subject, origin}) async {
      shared.add(text);
      lastShareOrigin = origin;
    }),
  ];
}
