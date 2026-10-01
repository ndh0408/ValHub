import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/core/xmpp/xmpp.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_prefs.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MockSessionManager extends Mock implements SessionManager {}

// ------------------------------------------------------------------ ids

/// Players (the same PUUIDs as `test/fixtures/competitive/*.json`).
const me = 'aaaaaaaa-0000-4000-8000-000000000001';
const mate = 'aaaaaaaa-0000-4000-8000-000000000002';
const mateHidden = 'aaaaaaaa-0000-4000-8000-000000000009';
const enemy1 = 'bbbbbbbb-0000-4000-8000-000000000003';
const enemy2 = 'bbbbbbbb-0000-4000-8000-000000000004';

const liveMatchId = 'cfa364b6-bc65-4805-9988-3ba02ba506ac';
const pregameMatchId = 'a6e7cba8-a4ef-4aae-b775-4eb61e43a0d1';
const partyId = 'a457b58c-0000-4000-8000-00000000000a';

/// The finished match of `match_competitive.json`.
const finishedMatchId = 'd1000000-0000-4000-8000-000000000001';

const ascent = '/Game/Maps/Ascent/Ascent';

/// Agents of [liveTestContent] (Jett, Sova, Sage are starters).
const jett = 'add6443a-41bd-e414-f6ad-e58d267f4e95';
const sova = '320b2a48-4d9b-a075-30f1-1f93a9b638fa';
const sage = '569fdd95-4d10-43ab-ca70-79becc718b46';
const reyna = 'a3bfb853-43b2-7238-a4f1-ad90e9e46bcc';
const omen = '8e253930-4c05-31dd-1b6c-968525494517';
const raze = 'f94c3b30-42be-e959-889c-5aa313dba261';

/// Skins / cosmetics of the content fixtures.
const vandal = '9c82e19d-4575-0200-1a81-3eacf00cf872';
const reaverSkin = '30388628-42f0-606c-82c0-73ad43de997f';
const reaverLevel = 'ba42fe63-457a-78ce-4499-47950a698129';
const reaverChroma = '2bd28382-48c6-8579-83e8-e9b64b783de3';
const buddyLevel = '6c3b1a9e-4067-7ed6-fc6c-fea61e0a057c';
const sprayId = '7e2ba2e8-4597-060a-b41e-81acedca414e';
const cardId = '1711d20d-4b1c-c64a-14be-d4ae58a457c6';
const titleId = '48d870a2-4493-ebf8-7d6f-979be914dc43';

const myAccount = Account(
  puuid: me,
  gameName: 'Tôi',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
  level: 200,
);

// -------------------------------------------------------------- content

ContentDb? _content;

/// Content fixtures plus a few more agents (copies of Jett's entry).
ContentDb liveTestContent() => _content ??= () {
  final raw = Map<String, Object?>.of(loadContentFixtures());
  final agents = asMap(jsonDecode(raw['agents']! as String))!;
  final list = asMapList(agents['data']);
  final jettJson = list.first;
  JsonMap copy(String uuid, String name) => {
    ...jettJson,
    'uuid': uuid,
    'displayName': name,
    'isBaseContent': false,
    'displayIcon':
        'https://media.valorant-api.com/agents/$uuid/displayicon.png',
  };
  raw['agents'] = jsonEncode({
    'status': 200,
    'data': [
      ...list,
      copy(sova, 'Sova'),
      copy(sage, 'Sage'),
      copy(reyna, 'Reyna'),
      copy(omen, 'Omen'),
      copy(raze, 'Raze'),
    ],
  });
  return ContentDb.parse(raw);
}();

Object? competitiveFixture(String name) =>
    jsonDecode(File('test/fixtures/competitive/$name.json').readAsStringSync());

// ------------------------------------------------------------- payloads

JsonMap identity({
  int level = 120,
  bool incognito = false,
  bool hideLevel = false,
}) => {
  'Subject': '',
  'PlayerCardID': cardId,
  'PlayerTitleID': titleId,
  'AccountLevel': level,
  'PreferredLevelBorderID': '',
  'Incognito': incognito,
  'HideAccountLevel': hideLevel,
};

JsonMap pregamePlayer(
  String subject, {
  String agent = '',
  String state = '',
  int level = 120,
  bool incognito = false,
  bool hideLevel = false,
}) => {
  'Subject': subject.toUpperCase(),
  'CharacterID': agent,
  'CharacterSelectionState': state,
  'PregamePlayerState': 'joined',
  'CompetitiveTier': 0,
  'PlayerIdentity': identity(
    level: level,
    incognito: incognito,
    hideLevel: hideLevel,
  ),
  'SeasonalBadgeInfo': {'SeasonID': '', 'Rank': 0},
  'IsCaptain': false,
};

/// G-3 body: me (optionally hovering / locking), a teammate who locked
/// Sova and an incognito teammate with a hidden level.
JsonMap pregameMatchJson({
  String myAgent = '',
  String myState = '',
  num phaseNs = 42e9,
}) => {
  'ID': pregameMatchId,
  'Version': 1,
  'Teams': [
    {
      'TeamID': 'Blue',
      'Players': [
        {'Subject': me},
      ],
    },
  ],
  'AllyTeam': {
    'TeamID': 'Blue',
    'Players': [
      pregamePlayer(me, agent: myAgent, state: myState, level: 200),
      pregamePlayer(mate, agent: sova, state: 'locked', level: 87),
      pregamePlayer(
        mateHidden,
        agent: sage,
        state: 'selected',
        incognito: true,
        hideLevel: true,
        level: 55,
      ),
    ],
  },
  'EnemyTeam': null,
  'ObserverSubjects': <Object>[],
  'EnemyTeamSize': 5,
  'EnemyTeamLockCount': 4,
  'PregameState': 'character_select_active',
  'MapID': ascent,
  'Mode': '/Game/GameModes/Bomb/BombGameMode.BombGameMode_C',
  'QueueID': 'competitive',
  'ProvisioningFlowID': 'Matchmaking',
  'IsRanked': true,
  'PhaseTimeRemainingNS': phaseNs,
};

JsonMap corePlayer(
  String subject,
  String team,
  String agent, {
  int level = 120,
  bool incognito = false,
  bool hideLevel = false,
}) => {
  'Subject': subject,
  'TeamID': team,
  'CharacterID': agent,
  'PlayerIdentity': identity(
    level: level,
    incognito: incognito,
    hideLevel: hideLevel,
  ),
  'SeasonalBadgeInfo': {'SeasonID': '', 'Rank': 0},
  'IsCoach': false,
  'IsAssociated': true,
};

/// G-9 body: me + mate (Blue) against two enemies (Red).
JsonMap coreMatchJson({String state = 'IN_PROGRESS'}) => {
  'MatchID': liveMatchId,
  'Version': 1,
  'State': state,
  'MapID': ascent,
  'ModeID': '/Game/GameModes/Bomb/BombGameMode.BombGameMode_C',
  'ProvisioningFlow': 'Matchmaking',
  'Players': [
    corePlayer(me, 'Blue', jett, level: 200),
    corePlayer(mate, 'Blue', sova, level: 87),
    corePlayer(enemy1, 'Red', reyna, level: 30),
    corePlayer(enemy2, 'Red', omen, incognito: true, hideLevel: true),
  ],
  'MatchmakingData': {'QueueID': 'competitive'},
};

/// G-10 body for [liveMatchId].
JsonMap coreLoadoutsJson() => {
  'Loadouts': [
    {
      'CharacterID': jett,
      'Loadout': {
        'Subject': me,
        'Items': {
          vandal: {
            'ID': vandal,
            'TypeID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
            'Sockets': {
              'bcef87d6-209b-46c6-8b19-fbe40bd95abc': {
                'ID': 'bcef87d6-209b-46c6-8b19-fbe40bd95abc',
                'Item': {'ID': reaverSkin},
              },
              'e7c63390-eda7-46e0-bb7a-a6abdacd2433': {
                'ID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
                'Item': {'ID': reaverLevel},
              },
              '3ad1b2b2-acdb-4524-852f-954a76ddae0a': {
                'ID': '3ad1b2b2-acdb-4524-852f-954a76ddae0a',
                'Item': {'ID': reaverChroma},
              },
              'dd3bf334-87f3-40bd-b043-682a57a8dc3a': {
                'ID': 'dd3bf334-87f3-40bd-b043-682a57a8dc3a',
                'Item': {'ID': buddyLevel},
              },
            },
          },
        },
        'Expressions': {
          'AESSelections': [
            {
              'SocketID': 'x',
              'AssetID': sprayId,
              'TypeID': 'd5f120f8-ff8c-4aac-92ea-f2b5acbe9475',
            },
          ],
        },
        'Identity': {'PlayerCardID': cardId, 'PlayerTitleID': titleId},
        'Incognito': false,
      },
    },
  ],
};

JsonMap partyJson({bool matchmaking = true}) => {
  'ID': partyId,
  'Members': [
    {'Subject': me},
    {'Subject': mate},
  ],
  'State': matchmaking ? 'MATCHMAKING' : 'DEFAULT',
  'MatchmakingData': {'QueueID': 'competitive'},
  'QueueEntryTime': '2026-09-28T11:58:28Z',
};

/// A friend's presence in party [party].
FriendPresence friendInParty(String puuid, String party, DateTime at) =>
    FriendPresence(
      puuid: puuid,
      receivedAt: at,
      product: 'valorant',
      valorant: PresenceSnapshot(loopState: LoopState.ingame, partyId: party),
    );

/// Own game-client presence with a live score.
FriendPresence scorePresence(
  DateTime at, {
  int ally = 8,
  int enemy = 4,
  LoopState loop = LoopState.ingame,
}) => FriendPresence(
  puuid: me,
  receivedAt: at,
  product: 'valorant',
  valorant: PresenceSnapshot(
    loopState: loop,
    matchMap: ascent,
    allyScore: ally,
    enemyScore: enemy,
  ),
);

// ------------------------------------------------------------- the env

/// Foreground flag tests can flip.
class TestForeground extends AppForegroundNotifier {
  TestForeground([this.initial = true]);

  final bool initial;

  @override
  bool build() => initial;

  set foreground(bool value) => state = value;
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

/// A fake Riot: [loop] / [pregame] / [core] / [party] describe what the
/// live-game endpoints answer; every mutation is recorded by mocktail.
class LiveTestEnv {
  LiveTestEnv._(this.prefs);

  static Future<LiveTestEnv> create({
    List<Account> accounts = const [myAccount],
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    if (accounts.isNotEmpty) {
      await prefs.setString(PrefKeys.activePuuid, accounts.first.puuid);
    }
    return LiveTestEnv._(prefs).._stub();
  }

  final Prefs prefs;
  final api = MockPvpApi();
  final sessions = MockSessionManager();
  final clock = FixedClock(DateTime.utc(2026, 9, 28, 12));
  final foreground = TestForeground();

  /// `null` = G-1 answers 404 (game not running).
  String? loop;
  JsonMap? pregame;
  JsonMap? core;
  JsonMap? party;
  FriendPresence? presence;
  XmppSnapshot snapshot = const XmppSnapshot();
  Object? sessionError;

  Map<String, Object?> matches = {
    finishedMatchId: competitiveFixture('match_competitive'),
  };

  List<Override> get overrides => [
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(MemorySecureStore()),
    sessionManagerProvider.overrideWithValue(sessions),
    jsonFileCacheProvider.overrideWithValue(MemoryJsonFileCache()),
    rrHistoryStoreProvider.overrideWithValue(
      RrHistoryStore(MemoryJsonFileCache()),
    ),
    pvpApiProvider.overrideWithValue(api),
    contentProvider.overrideWith((ref) async => liveTestContent()),
    clockProvider.overrideWithValue(clock),
    remoteConfigProvider.overrideWithValue(const RemoteConfig()),
    appForegroundProvider.overrideWith(() => foreground),
    ownPresenceProvider.overrideWith((ref) => Stream.value(presence)),
    xmppSnapshotProvider.overrideWith((ref) => Stream.value(snapshot)),
    ownedItemsProvider.overrideWith(
      (ref, puuid) async => OwnedItems.resolve(
        Entitlements.fromTypeResponses({
          ItemTypeIds.agent: {
            'ItemTypeID': ItemTypeIds.agent,
            'Entitlements': [
              {'ItemID': reyna},
            ],
          },
        }, receivedAt: clock.now()),
        liveTestContent(),
      ),
    ),
  ];

  void _stub() {
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => api.gameSession(any())).thenAnswer((_) async {
      if (sessionError case final e?) throw e;
      final l = loop;
      if (l == null) throw const NotFoundException();
      return {'subject': me, 'loopState': l};
    });
    when(() => api.pregamePlayer(any())).thenAnswer((_) async {
      final p = pregame;
      if (p == null) throw const NotFoundException();
      return {'Subject': me, 'MatchID': p['ID']};
    });
    when(() => api.pregameMatch(any(), any())).thenAnswer((_) async {
      final p = pregame;
      if (p == null) throw const NotFoundException();
      return p;
    });
    when(() => api.coreGamePlayer(any())).thenAnswer((_) async {
      final c = core;
      if (c == null) throw const NotFoundException();
      return {'Subject': me, 'MatchID': c['MatchID']};
    });
    when(() => api.coreGameMatch(any(), any())).thenAnswer((_) async {
      final c = core;
      if (c == null) throw const NotFoundException();
      return c;
    });
    when(() => api.partyPlayer(any())).thenAnswer((_) async {
      if (party == null) throw const NotFoundException();
      return {'Subject': me, 'CurrentPartyID': partyId};
    });
    when(() => api.party(any(), any())).thenAnswer((_) async {
      final p = party;
      if (p == null) throw const NotFoundException();
      return p;
    });
    when(() => api.pregameSelectAgent(any(), any(), any()))
        .thenAnswer((inv) async => <String, dynamic>{});
    when(() => api.pregameLockAgent(any(), any(), any()))
        .thenAnswer((inv) async => <String, dynamic>{});
    when(() => api.pregameQuit(any(), any()))
        .thenAnswer((_) async => <String, dynamic>{});
    when(() => api.coreGameDisassociate(any(), any()))
        .thenAnswer((_) async => <String, dynamic>{});
    when(() => api.coreGameLoadouts(any(), any()))
        .thenAnswer((_) async => coreLoadoutsJson());
    when(() => api.pregameLoadouts(any(), any()))
        .thenAnswer((_) async => {'Loadouts': <Object>[]});
    when(() => api.names(any(), any())).thenAnswer(
      (_) async => [
        {'Subject': mate, 'GameName': 'Đồng Đội', 'TagLine': 'VN1'},
        {'Subject': mateHidden, 'GameName': 'Bí Mật', 'TagLine': 'KIN'},
        {'Subject': enemy1, 'GameName': 'Đối Thủ', 'TagLine': '0001'},
        {'Subject': enemy2, 'GameName': 'Kẻ Thù', 'TagLine': 'EN2'},
      ],
    );
    when(
      () => api.mmr(
        any(),
        subject: any(named: 'subject'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => asMap(competitiveFixture('mmr'))!);
    when(
      () => api.matchDetails(
        any(),
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((inv) async {
      final id = (inv.positionalArguments[1] as String).toLowerCase();
      final json = matches[id];
      if (json == null) throw const NotFoundException();
      return asMap(json)!;
    });
  }
}

/// Registers mocktail fallback values (call from `setUpAll`).
void registerLiveFallbacks() {
  registerFallbackValue(<String>[]);
}

/// Pumps [child] at phone size with the dark theme.
Future<void> pumpLive(
  WidgetTester tester,
  LiveTestEnv env,
  Widget child, {
  double width = 360,
  double height = 800,
  double textScale = 1,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: env.overrides,
      retry: (_, _) => null,
      child: MaterialApp(
        theme: theme ?? buildDarkTheme(),
        home: MediaQuery.withClampedTextScaling(
          minScaleFactor: textScale,
          maxScaleFactor: textScale,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

/// Lets futures, the name-service batch window and frames run.
Future<void> settle(WidgetTester tester, {int frames = 8}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
