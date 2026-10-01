import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/social/providers/party_providers.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_prefs.dart';
import 'social_test_data.dart';

export 'social_test_data.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MockSessionManager extends Mock implements SessionManager {}

class _NoCredentials implements XmppCredentialSource {
  @override
  Future<XmppCredentials> credentials(String puuid) =>
      throw const TransientException(reason: 'test');

  @override
  Future<void> invalidate(String puuid, {required String failedAccessToken}) =>
      Future.value();
}

/// [XmppService] without sockets: tests seed [store] directly.
class FakeXmppService extends XmppService {
  FakeXmppService() : super(puuid: me, credentials: _NoCredentials());

  final List<(String, String)> sent = [];
  final Map<String, List<ChatMessage>> history = {};
  int historyLoads = 0;
  int retries = 0;
  int refreshes = 0;

  @override
  void start() {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> retryNow() async => retries++;

  @override
  Future<void> refresh() async => refreshes++;

  @override
  Future<void> loadHistory(String friendPuuid) async {
    historyLoads++;
    store.addHistory(friendPuuid, history[friendPuuid] ?? const []);
  }

  @override
  Future<ChatMessage> sendMessage(String friendPuuid, String text) async {
    sent.add((friendPuuid, text.trim()));
    final m = ChatMessage(
      id: '$localMessagePrefix${sent.length}',
      friendPuuid: friendPuuid,
      outgoing: true,
      body: text.trim(),
      at: DateTime.utc(2026, 9, 28, 12),
      status: ChatMessageStatus.sent,
    );
    store.addLiveMessage(m);
    return m;
  }

  /// Connected with a roster.
  void seed({
    List<RosterEntry> roster = const [],
    List<FriendPresence> presences = const [],
  }) {
    store
      ..setConnection(const XmppConnectionState(XmppStatus.connected))
      ..setRoster(roster);
    presences.forEach(store.applyPresence);
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
      entries[key] = CachedJson(
        jsonDecode(jsonEncode(data)),
        savedAt ?? DateTime(2026),
      );

  @override
  Future<void> delete(String key) async => entries.remove(key);

  @override
  Future<void> deletePrefix(String prefix) async =>
      entries.removeWhere((k, _) => k.startsWith(prefix));

  @override
  Future<void> clear() async => entries.clear();

  @override
  Future<int> sizeBytes() async => 0;
}

const myAccount = Account(
  puuid: me,
  gameName: 'Tôi',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
  level: 200,
);

final ContentDb _content = ContentDb.parse(loadContentFixtures());

final now = DateTime.utc(2026, 9, 28, 12);

RosterEntry rosterEntry(
  String puuid,
  String? gameName, {
  String tag = 'VN1',
  DateTime? lastOnline,
}) => RosterEntry(
  puuid: puuid,
  jid: '$puuid@jp1.pvp.net',
  name: gameName == null ? null : RiotName(gameName: gameName, tagLine: tag),
  subscription: 'both',
  lastOnline: lastOnline,
);

FriendPresence valorantPresence(
  String puuid,
  PresenceSnapshot snapshot, {
  PresenceShow show = PresenceShow.chat,
}) => FriendPresence(
  puuid: puuid,
  resource: 'RC-1',
  show: show,
  product: 'valorant',
  valorant: snapshot,
  receivedAt: now,
);

/// Overrides for the social screens: no plugins, no network, no sockets.
class SocialTestEnv {
  SocialTestEnv._(this.prefs);

  static Future<SocialTestEnv> create({
    RemoteConfig remoteConfig = const RemoteConfig(),
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [myAccount.toJson()]);
    await prefs.setString(PrefKeys.activePuuid, me);
    return SocialTestEnv._(prefs)
      ..remoteConfig = remoteConfig
      .._stub();
  }

  final Prefs prefs;
  final api = MockPvpApi();
  final sessions = MockSessionManager();
  final xmpp = FakeXmppService();
  final clock = FixedClock(now);
  RemoteConfig remoteConfig = const RemoteConfig();

  /// Texts sent to the OS share sheet.
  final shared = <String>[];

  List<Override> get overrides => [
    partyShareProvider.overrideWithValue((text) async => shared.add(text)),
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(MemorySecureStore()),
    sessionManagerProvider.overrideWithValue(sessions),
    jsonFileCacheProvider.overrideWithValue(MemoryJsonFileCache()),
    rrHistoryStoreProvider.overrideWithValue(
      RrHistoryStore(MemoryJsonFileCache()),
    ),
    pvpApiProvider.overrideWithValue(api),
    contentProvider.overrideWith((ref) async => _content),
    clockProvider.overrideWithValue(clock),
    remoteConfigProvider.overrideWithValue(remoteConfig),
    xmppServiceProvider.overrideWithValue(xmpp),
  ];

  void _stub() {
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(
      () => api.mmr(
        any(),
        subject: any(named: 'subject'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenThrow(const NotFoundException());
    when(() => api.names(any(), any())).thenAnswer(
      (inv) async => [
        for (final id in (inv.positionalArguments[1] as Iterable<String>))
          {
            'Subject': id,
            'GameName': switch (id) {
              mate => 'Đồng Đội Có Cái Tên Rất Là Dài Luôn',
              stranger => 'Người Lạ',
              _ => 'Ai Đó',
            },
            'TagLine': '1234',
          },
      ],
    );
  }

  /// Serves [party] from G-12 / G-13 and every mutation.
  void serveParty(
    JsonMap party, {
    List<JsonMap>? invites,
    String loopState = 'MENUS',
  }) {
    when(() => api.partyPlayer(any())).thenAnswer(
      (_) async => {
        'Subject': me,
        'CurrentPartyID': partyId,
        'Invites': invites,
        'Requests': <Object>[],
      },
    );
    when(() => api.party(any(), any())).thenAnswer((_) async => party);
    when(() => api.gameSession(any()))
        .thenAnswer((_) async => {'loopState': loopState});
    when(() => api.partyChangeQueue(any(), any(), any()))
        .thenAnswer((_) async => party);
    when(() => api.partyJoinMatchmaking(any(), any()))
        .thenAnswer((_) async => party);
    when(() => api.partyLeaveMatchmaking(any(), any()))
        .thenAnswer((_) async => party);
    when(() => api.partySetReady(any(), any(), ready: any(named: 'ready')))
        .thenAnswer((_) async => party);
    when(
      () => api.partyInviteByRiotId(
        any(),
        any(),
        gameName: any(named: 'gameName'),
        tagLine: any(named: 'tagLine'),
      ),
    ).thenAnswer((_) async => party);
    when(() => api.partyGenerateInviteCode(any(), any()))
        .thenAnswer((_) async => {...party, 'InviteCode': 'NEW123'});
    when(() => api.partyDisableInviteCode(any(), any()))
        .thenAnswer((_) async => {...party, 'InviteCode': ''});
    when(() => api.partyJoinByCode(any(), any()))
        .thenAnswer((_) async => party);
    when(() => api.partyRemovePlayer(any(), subject: any(named: 'subject')))
        .thenAnswer((_) async => party);
    when(() => api.partyAcceptInvite(any(), any()))
        .thenAnswer((_) async => party);
    when(
      () => api.partySetAccessibility(any(), any(), open: any(named: 'open')),
    ).thenAnswer((_) async => party);
  }
}

void registerSocialFallbacks() {
  registerFallbackValue(<String>[]);
}

/// Pumps [child] at phone size (360 × [height] dp) with the dark theme
/// (or [theme]) and an optional forced text scale.
Future<void> pumpSocial(
  WidgetTester tester,
  SocialTestEnv env,
  Widget child, {
  double height = 1400,
  ThemeData? theme,
  double? textScale,
}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final scale = textScale;
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp(
        theme: theme ?? buildDarkTheme(),
        home: scale == null
            ? child
            : MediaQuery.withClampedTextScaling(
                minScaleFactor: scale,
                maxScaleFactor: scale,
                child: child,
              ),
      ),
    ),
  );
}

/// Pumps a [GoRouter] app (navigation tests).
Future<GoRouter> pumpSocialRouter(
  WidgetTester tester,
  SocialTestEnv env, {
  required List<RouteBase> routes,
  required String initialLocation,
  double height = 1400,
}) async {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp.router(theme: buildDarkTheme(), routerConfig: router),
    ),
  );
  return router;
}

/// Lets futures, microtasks and frames run (no pumpAndSettle: the party
/// ring animates forever).
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Unmounts the tree so periodic timers / tickers are disposed.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}
