import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/domain/competitive/match_stats_store.dart';
import 'package:valvn/core/domain/economy/store_history.dart';
import 'package:valvn/core/accounts/local_data.dart';
import 'package:valvn/core/domain/competitive/rr_history.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/riot_session.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/l10n/locale.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_hosts.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/features/community/data/community_http.dart';
import 'package:valvn/features/community/data/community_models.dart'
    show kLfgLanguages;
import 'package:valvn/features/community/data/community_translator.dart';
import 'package:valvn/features/community/data/image_source.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/providers/data_rights_providers.dart';
import 'package:valvn/features/community/providers/translation_providers.dart';
import 'package:valvn/features/community/providers/community_providers.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_prefs.dart';

class MockSessionManager extends Mock implements SessionManager {}

class MockPvpApi extends Mock implements PvpApi {}

const mePuuid = 'c5a5af97-d9b8-5217-9d26-1b35f93ca3d0';
const meId = 'me0000000000000000000000000000aa';
const otherId = 'ot0000000000000000000000000000bb';
const baseUrl = 'https://community.test';

/// Fixture skins / weapons / cards (test/fixtures/content).
const vandal = '9c82e19d-4575-0200-1a81-3eacf00cf872';
const reaverSkin = '30388628-42f0-606c-82c0-73ad43de997f';
const reaverLevel = 'ba42fe63-457a-78ce-4499-47950a698129';
const knifeSkin = '58442f45-4783-42a2-f4cb-789a27555889';
const cardId = '1711d20d-4b1c-c64a-14be-d4ae58a457c6';

const meAccount = Account(
  puuid: mePuuid,
  gameName: 'Tôi Là Ai',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
  cardId: cardId,
  rankTier: 18,
);

final now = DateTime.utc(2026, 9, 28, 12);

final ContentDb fixtureContent = ContentDb.parse(loadContentFixtures());

RiotSession riotSession({String token = 'riot-access-1'}) => RiotSession(
  puuid: mePuuid,
  accessToken: token,
  idToken: 'id',
  entitlementsToken: 'ent',
  expiresAt: now.add(const Duration(hours: 1)),
  hosts: const RiotHosts(region: 'ap', shard: 'ap'),
  clientVersion: 'v',
  userAgent: 'ua',
);

// ------------------------------------------------------------ JSON builders

Map<String, Object?> authorJson({
  String id = otherId,
  String name = 'Người Chơi',
  String tag = 'VN2',
  int? rank = 12,
  String? card,
  String? country,
  String? language,
}) => {
  'id': id,
  'gameName': name,
  'tagLine': tag,
  'cardId': card,
  'rankTier': rank,
  'region': 'ap',
  'country': country,
  'language': language,
};

Map<String, Object?> sessionJson({
  String token = 'community-1',
  String? country,
}) => {
  'token': token,
  'expiresAt': now.add(const Duration(days: 30)).toIso8601String(),
  'user': authorJson(
    id: meId,
    name: 'Tôi Là Ai',
    tag: 'VN1',
    rank: 18,
    country: country,
  ),
};

Map<String, Object?> postJson(
  String id, {
  String body = 'Xin chào',
  String kind = 'text',
  Map<String, Object?>? author,
  int likes = 3,
  bool liked = false,
  int comments = 1,
  List<Map<String, Object?>> media = const [],
  Map<String, Object?>? payload,
}) => {
  'id': id,
  'author': author ?? authorJson(),
  'kind': kind,
  'body': body,
  'media': media,
  'payload': payload,
  'likes': likes,
  'liked': liked,
  'comments': comments,
  'createdAt': now.subtract(const Duration(minutes: 5)).toIso8601String(),
};

Map<String, Object?> commentJson(
  String id, {
  String body = 'Hay quá',
  Map<String, Object?>? author,
}) => {
  'id': id,
  'postId': 'p1',
  'author': author ?? authorJson(),
  'body': body,
  'createdAt': now.subtract(const Duration(minutes: 2)).toIso8601String(),
};

Map<String, Object?> lfgJson(
  String id, {
  Map<String, Object?>? author,
  String mode = 'competitive',
  String code = 'ABC123',
  int slots = 2,
  String note = 'Cần 1 Controller',
  Duration left = const Duration(minutes: 24),
}) => {
  'id': id,
  'author': author ?? authorJson(),
  'region': 'ap',
  'mode': mode,
  'partyCode': code,
  'slots': slots,
  'rankTier': 12,
  'note': note,
  'createdAt': now.subtract(const Duration(minutes: 6)).toIso8601String(),
  'expiresAt': now.add(left).toIso8601String(),
};

Map<String, Object?> page(List<Object?> items, {String? next}) => {
  'items': items,
  'nextCursor': next,
};

// ------------------------------------------------------------ fake server

/// A request received by [FakeCommunityServer].
class RecordedRequest {
  RecordedRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.headers,
    required this.bytes,
  });

  final String method;
  final String path;
  final Map<String, String> query;
  final Map<String, dynamic> headers;
  final List<int> bytes;

  Object? get json => bytes.isEmpty ? null : jsonDecode(utf8.decode(bytes));

  String? get authorization => headers['Authorization'] as String?;

  @override
  String toString() => '$method $path';
}

/// A canned response.
class FakeResponse {
  const FakeResponse(this.status, [this.body, this.headers = const {}]);

  final int status;
  final Object? body;
  final Map<String, List<String>> headers;

  String get text => switch (body) {
    null => '',
    final String s => s,
    final other => jsonEncode(other),
  };
}

typedef FakeHandler = FakeResponse Function(RecordedRequest request);

/// In-memory community server behind a dio adapter (no network). Routes are
/// `METHOD /path` where a `*` segment matches anything.
class FakeCommunityServer implements HttpClientAdapter {
  final List<RecordedRequest> requests = [];
  final Map<String, FakeHandler> _routes = {};

  late final Dio dio = Dio()..httpClientAdapter = this;

  final Map<String, Completer<void>> _holds = {};

  void on(String route, FakeHandler handler) => _routes[route] = handler;

  /// Keeps the answer to [route] pending until [gate] completes (a request
  /// "in flight").
  void hold(String route, Completer<void> gate) => _holds[route] = gate;

  /// Serves [body] with 200 for [route].
  void json(String route, Object? body, {int status = 200}) =>
      on(route, (_) => FakeResponse(status, body));

  /// Requests matching `METHOD /path`.
  List<RecordedRequest> calls(String route) =>
      requests.where((r) => _matches(route, r.method, r.path)).toList();

  static bool _matches(String route, String method, String path) {
    final parts = route.split(' ');
    if (parts.length != 2 || parts[0] != method) return false;
    final want = parts[1].split('/');
    final got = path.split('/');
    if (want.length != got.length) return false;
    for (var i = 0; i < want.length; i++) {
      if (want[i] != '*' && want[i] != got[i]) return false;
    }
    return true;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    final req = RecordedRequest(
      method: options.method,
      path: options.uri.path,
      query: options.uri.queryParameters,
      headers: Map.of(options.headers),
      bytes: bytes,
    );
    requests.add(req);
    for (final e in _holds.entries) {
      if (_matches(e.key, req.method, req.path)) await e.value.future;
    }
    FakeHandler? handler;
    for (final e in _routes.entries) {
      if (_matches(e.key, req.method, req.path)) handler = e.value;
    }
    final res =
        handler?.call(req) ??
        const FakeResponse(404, {
          'error': {'code': 'not_found', 'message': 'no route'},
        });
    return ResponseBody.fromString(
      res.text,
      res.status,
      headers: {
        Headers.contentTypeHeader: [
          if (res.body is String) 'text/html' else 'application/json',
        ],
        ...res.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Image picker returning [next].
class FakeImagePicker implements CommunityImagePicker {
  List<PickedImage> next = const [];
  int calls = 0;

  @override
  Future<List<PickedImage>> pick({required int limit}) async {
    calls++;
    return next.take(limit).toList();
  }
}

/// A tiny valid JPEG header (the app sniffs the signature only).
Uint8List jpegBytes([int size = 64]) =>
    Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(size, 1)]);

/// In-memory [CommunityTranslator]: records downloads / translations, no
/// plugin, no network.
class FakeCommunityTranslator implements CommunityTranslator {
  FakeCommunityTranslator({
    this.supported = true,
    Set<String>? downloaded,
    this.failTranslate = false,
  }) : downloaded = downloaded ?? {'vi', 'en'};

  bool supported;
  bool failTranslate;
  final Set<String> downloaded;
  final List<String> downloads = [];
  final List<(String, String, String)> translations = [];

  @override
  bool get isSupported => supported;

  @override
  bool supportsLanguage(String code) => kLfgLanguages.contains(code);

  @override
  Future<bool> isDownloaded(String code) async => downloaded.contains(code);

  @override
  Future<void> download(String code) async {
    downloads.add(code);
    downloaded.add(code);
  }

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    translations.add((text, from, to));
    if (failTranslate) throw StateError('translate failed');
    return '[$from>$to] $text';
  }
}

/// In-memory [JsonFileCache].
class MemoryJsonFileCache extends JsonFileCache {
  MemoryJsonFileCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

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
}

class MemoryStoreHistory extends StoreHistoryStore {
  MemoryStoreHistory(this.files) : super(files);
  final MemoryJsonFileCache files;
  @override
  Future<void> delete(String puuid) =>
      files.delete(StoreHistoryStore.key(puuid));
}

/// Records `showNow` calls (no plugin).
class RecordingNotifications extends NotificationService {
  RecordingNotifications(Prefs prefs) : super(prefs: prefs);

  final shown = <({String title, String body, String? payload})>[];

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async => shown.add((title: title, body: body, payload: payload));

  @override
  Future<void> cancelForAccount(String puuid) async {}
}

// --------------------------------------------------------------------- env

/// Overrides for the community feature: signed-in account, fake community
/// server, mocked Riot session / PvpApi, fixture content, fixed clock.
class CommunityTestEnv {
  CommunityTestEnv._(this.prefs);

  /// [consent]: the account already agreed to share its Riot ID with the
  /// community server (the one-time sheet is skipped).
  static Future<CommunityTestEnv> create({
    Account? account = meAccount,
    bool consent = true,
  }) async {
    final prefs = await createTestPrefs();
    if (account != null) {
      if (consent) {
        await prefs.setString(communityConsentKey(account.puuid), 'granted');
        await prefs.setString(
          communityConsentVersionKey(account.puuid),
          communityConsentVersion,
        );
      }
      await prefs.setJson(PrefKeys.accounts, [account.toJson()]);
      await prefs.setString(PrefKeys.activePuuid, account.puuid);
    }
    final env = CommunityTestEnv._(prefs);
    when(() => env.sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => env.sessions.forget(any())).thenAnswer((_) async {});
    when(() => env.sessions.session(any()))
        .thenAnswer((_) async => riotSession());
    env.server.json('POST /v1/auth/riot', sessionJson());
    return env;
  }

  final Prefs prefs;
  final secure = MemorySecureStore();
  final sessions = MockSessionManager();
  final pvp = MockPvpApi();
  final server = FakeCommunityServer();
  final picker = FakeImagePicker();
  final clock = FixedClock(now);
  late final notifications = RecordingNotifications(prefs);
  final translator = FakeCommunityTranslator();

  /// Export files handed to the (fake) native share sheet.
  final sharedExports = <CommunityExportFile>[];

  List<Override> get overrides => [
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(secure),
    sessionManagerProvider.overrideWithValue(sessions),
    pvpApiProvider.overrideWithValue(pvp),
    jsonFileCacheProvider.overrideWithValue(MemoryJsonFileCache()),
    retainedHistoryFilesProvider.overrideWithValue(MemoryJsonFileCache()),
    rrHistoryStoreProvider.overrideWith((ref) {
      final store = RrHistoryStore(MemoryJsonFileCache());
      ref.onDispose(store.dispose);
      return store;
    }),
    matchStatsStoreProvider.overrideWith((ref) {
      final store = MatchStatsStore(MemoryJsonFileCache());
      ref.onDispose(store.dispose);
      return store;
    }),
    storeHistoryStoreProvider.overrideWith((ref) {
      final store = MemoryStoreHistory(MemoryJsonFileCache());
      ref.onDispose(store.dispose);
      return store;
    }),
    contentProvider.overrideWith((ref) async => fixtureContent),
    clockProvider.overrideWithValue(clock),
    communityBaseUrlProvider.overrideWithValue(baseUrl),
    communityHttpProvider.overrideWithValue(
      CommunityHttp(dio: server.dio, baseUrl: baseUrl),
    ),
    communityImagePickerProvider.overrideWithValue(picker),
    notificationServiceProvider.overrideWithValue(notifications),
    communityTranslatorProvider.overrideWithValue(translator),
    communityExportSharerProvider.overrideWithValue((file, {origin}) async {
      sharedExports.add(file);
    }),
  ];

  ProviderContainer container() =>
      ProviderContainer.test(overrides: overrides, retry: (_, _) => null);
}

/// Pumps [child] at phone size with the dark theme.
Future<void> pumpCommunity(
  WidgetTester tester,
  CommunityTestEnv env,
  Widget child, {
  Size size = const Size(360, 1600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp(
        theme: buildDarkTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: child,
      ),
    ),
  );
}

/// Pumps a router app (navigation between community screens).
Future<GoRouter> pumpCommunityRouter(
  WidgetTester tester,
  CommunityTestEnv env, {
  required List<RouteBase> routes,
  required String initialLocation,
  Size size = const Size(360, 1600),
  double textScale = 1,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp.router(
        theme: theme ?? buildDarkTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  return router;
}

/// Lets futures and frames run (shimmers and countdowns never settle).
Future<void> settle(WidgetTester tester, {int frames = 10}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Unmounts the tree so timers and tickers are disposed.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
