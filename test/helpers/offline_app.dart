import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/community/data/community_http.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';

import '../core/domain/economy/economy_fixtures.dart';
import 'test_prefs.dart';

/// Riot is unreachable: every game-client call fails with a transient error.
class _OfflinePvpApi implements PvpApi {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<Never>.error(const TransientException(reason: 'offline'));
}

class _MemoryJsonCache extends JsonFileCache {
  _MemoryJsonCache() : super(() => throw UnimplementedError());

  final _entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => _entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      _entries[key] = CachedJson(data, savedAt ?? DateTime(2026));
}

class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => Future.error(
    DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    ),
  );

  @override
  void close({bool force = false}) {}
}

class _NoopMissReporter extends ContentMissReporter {
  _NoopMissReporter(super.ref);

  @override
  Future<void> report() async {}
}

/// A signed-in account with community consent, for whole-app smoke tests.
const offlineAccount = Account(
  puuid: 'c5a5af97-d9b8-5217-9d26-1b35f93ca3d0',
  gameName: 'Player One',
  tagLine: 'EUW',
  region: 'eu',
  shard: 'eu',
  country: 'DE',
);

/// Pumps frames without waiting for shimmers / countdowns to settle.
Future<void> settleFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 16));
}

/// The whole app, signed in, with Riot and the community server offline, at
/// [size] logical pixels with the device locale [locale] and [textScale].
/// Returns the router so a test can visit routes without localized taps.
Future<GoRouter> pumpOfflineApp(
  WidgetTester tester, {
  required Locale locale,
  Size size = const Size(360, 740),
  double textScale = 1,
}) async {
  final prefs = await createTestPrefs();
  await prefs.setJson(PrefKeys.accounts, [offlineAccount.toJson()]);
  await prefs.setString(PrefKeys.activePuuid, offlineAccount.puuid);
  await prefs.setString(communityConsentKey(offlineAccount.puuid), 'granted');
  await prefs.setString(
    communityConsentVersionKey(offlineAccount.puuid),
    communityConsentVersion,
  );
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
        sessionLogProvider.overrideWithValue(SessionLog()),
        notificationServiceProvider.overrideWithValue(
          NotificationService(prefs: prefs),
        ),
        pvpApiProvider.overrideWithValue(_OfflinePvpApi()),
        jsonFileCacheProvider.overrideWithValue(_MemoryJsonCache()),
        contentProvider.overrideWith((ref) async => economyContent()),
        priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
        contentMissReporterProvider.overrideWith(_NoopMissReporter.new),
        xmppServiceProvider.overrideWith((ref) => null),
        communityHttpProvider.overrideWithValue(
          CommunityHttp(
            dio: Dio()..httpClientAdapter = _OfflineAdapter(),
            baseUrl: 'https://community.test',
          ),
        ),
      ],
      child: const ValVnApp(),
    ),
  );
  await settleFrames(tester);
  return ProviderScope.containerOf(tester.element(find.byType(ValVnApp)))
      .read(routerProvider);
}

/// Unmounts the app and lets its timers expire.
Future<void> unmountOfflineApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 11));
}

/// Full Flutter error reports of this test (widget, file and line of an
/// overflow), for failure messages; the framework still fails the test.
List<String> recordFlutterErrors() {
  final reports = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    reports.add(details.toString());
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
  return reports;
}
