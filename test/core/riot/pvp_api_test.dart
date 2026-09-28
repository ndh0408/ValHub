import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/auth/riot_session.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/network/dio_factory.dart';
import 'package:valvn/core/network/rate_limiter.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_hosts.dart';

class MockSessions extends Mock implements SessionManager {}

const _puuid = '41c322a1-b328-495b-a004-5ccd3e45eae8';

RiotSession _session(String token) => RiotSession(
  puuid: _puuid,
  accessToken: token,
  idToken: 'id',
  entitlementsToken: 'ent',
  expiresAt: DateTime(2100),
  hosts: RiotHosts.forRegion('ap'),
  clientVersion: 'release-13.06-shipping-13-5435758',
  userAgent: 'RiotClient/111 rso-auth',
);

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  /// Header snapshots (the retry reuses the same RequestOptions instance).
  final headers = <Map<String, dynamic>>[];
  final List<ResponseBody Function(RequestOptions)> queue = [];

  void reply(int status, Object? json, {Map<String, List<String>>? headers}) =>
      queue.add(
        (_) => ResponseBody.fromString(
          json is String ? json : jsonEncode(json),
          status,
          headers:
              headers ??
              {
                Headers.contentTypeHeader: [
                  json is String ? 'text/html' : Headers.jsonContentType,
                ],
              },
        ),
      );

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async {
    requests.add(o);
    headers.add(Map.of(o.headers));
    return queue.removeAt(0)(o);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockSessions sessions;
  late _Adapter adapter;
  late PvpApi api;

  setUp(() {
    sessions = MockSessions();
    adapter = _Adapter();
    when(() => sessions.session(any())).thenAnswer((_) async => _session('T1'));
    final dio = createPvpDio(sessions: sessions)..httpClientAdapter = adapter;
    api = PvpApi(
      sessions: sessions,
      dio: dio,
      limiter: HostRateLimiter(burst: 100, refillPerSecond: 100),
      delay: (_) async {},
    );
  });

  test('storefront: POST {} with every game header', () async {
    adapter.reply(200, {'SkinsPanelLayout': <String, dynamic>{}});
    final json = await api.storefront(_puuid);
    expect(json.containsKey('SkinsPanelLayout'), isTrue);
    final r = adapter.requests.single;
    expect(r.method, 'POST');
    expect(
      r.uri.toString(),
      'https://pd.ap.a.pvp.net/store/v3/storefront/$_puuid',
    );
    expect(r.data, <String, dynamic>{});
    expect(r.headers['Authorization'], 'Bearer T1');
    expect(r.headers['X-Riot-Entitlements-JWT'], 'ent');
    expect(
      r.headers['X-Riot-ClientVersion'],
      'release-13.06-shipping-13-5435758',
    );
    expect(
      r.headers['X-Riot-ClientPlatform'],
      startsWith('ew0KCSJwbGF0Zm9ybVR5cGUi'),
    );
    expect(r.headers['User-Agent'], 'RiotClient/111 rso-auth');
  });

  test('name-service: PUT a JSON list, batched by 50', () async {
    adapter
      ..reply(200, [
        {'Subject': 'a', 'GameName': 'A', 'TagLine': '1'},
      ])
      ..reply(200, [
        {'Subject': 'b'},
      ]);
    final subjects = [for (var i = 0; i < 60; i++) 'P$i'];
    final names = await api.names(_puuid, subjects);
    expect(names, hasLength(2));
    expect(adapter.requests.map((r) => r.method), ['PUT', 'PUT']);
    expect((adapter.requests.first.data as List), hasLength(50));
    expect((adapter.requests.first.data as List).first, 'p0');
  });

  test(
    'match history pages are clamped to 20 and GLZ uses region+shard',
    () async {
      adapter
        ..reply(200, {'History': <Object?>[]})
        ..reply(200, {'MatchID': 'm'});
      await api.matchHistory(
        _puuid,
        subject: 'other',
        startIndex: 20,
        endIndex: 100,
        queue: 'competitive',
      );
      final q = adapter.requests.first.uri.queryParameters;
      expect(
        adapter.requests.first.uri.path,
        '/match-history/v1/history/other',
      );
      expect(q, {'startIndex': '20', 'endIndex': '40', 'queue': 'competitive'});
      await api.pregamePlayer(_puuid);
      expect(adapter.requests.last.uri.host, 'glz-ap-1.ap.a.pvp.net');
    },
  );

  test(
    '400 BAD_CLAIMS → single re-auth → retried once with the new token',
    () async {
      when(
        () => sessions.refreshAfterAuthFailure(
          any(),
          failedAccessToken: any(named: 'failedAccessToken'),
        ),
      ).thenAnswer((_) async => _session('T2'));
      adapter
        ..reply(400, {
          'httpStatus': 400,
          'errorCode': 'BAD_CLAIMS',
          'message': 'x',
        })
        ..reply(200, {'Balances': <String, dynamic>{}});
      final wallet = await api.wallet(_puuid);
      expect(wallet.containsKey('Balances'), isTrue);
      expect(adapter.headers.map((h) => h['Authorization']), [
        'Bearer T1',
        'Bearer T2',
      ]);
      verify(
        () => sessions.refreshAfterAuthFailure(_puuid, failedAccessToken: 'T1'),
      ).called(1);
    },
  );

  test('re-auth failure surfaces NeedsLoginException', () async {
    when(
      () => sessions.refreshAfterAuthFailure(
        any(),
        failedAccessToken: any(named: 'failedAccessToken'),
      ),
    ).thenThrow(const NeedsLoginException(puuid: _puuid));
    adapter.reply(401, {'error': 'x'});
    await expectLater(
      api.accountXp(_puuid),
      throwsA(isA<NeedsLoginException>()),
    );
  });

  test('404 is NotFoundException (a state for live-game endpoints)', () async {
    adapter.reply(404, {'httpStatus': 404, 'errorCode': 'RESOURCE_NOT_FOUND'});
    expect(await api.coreGamePlayer(_puuid).orNullIfNotFound(), isNull);
  });

  test('Cloudflare HTML 403 on GET is retried twice, then transient', () async {
    for (var i = 0; i < 3; i++) {
      adapter.reply(403, '<!DOCTYPE html><title>Just a moment...</title>');
    }
    await expectLater(api.mmr(_puuid), throwsA(isA<TransientException>()));
    expect(adapter.requests, hasLength(3));
  });

  test('mutations are never retried automatically', () async {
    adapter.reply(503, {'errorCode': 'x'});
    await expectLater(
      api.pregameLockAgent(_puuid, 'match', 'agent'),
      throwsA(isA<TransientException>()),
    );
    expect(adapter.requests, hasLength(1));
    expect(
      adapter.requests.single.uri.path,
      '/pregame/v1/matches/match/lock/agent',
    );
  });

  test('loadout PUT sends the raw map back', () async {
    final loadout = {
      'Subject': _puuid,
      'Version': 3,
      'Guns': <Object?>[],
      'Unknown': {'keep': true},
    };
    adapter.reply(200, loadout);
    await api.putPlayerLoadout(_puuid, loadout);
    expect(adapter.requests.single.method, 'PUT');
    expect(adapter.requests.single.data, loadout);
  });

  test('party invite URL-encodes the Riot ID', () async {
    adapter.reply(200, {});
    await api.partyInviteByRiotId(
      _puuid,
      'party',
      gameName: 'Tên Tôi',
      tagLine: 'VN 1',
    );
    expect(
      adapter.requests.single.uri.toString(),
      'https://glz-ap-1.ap.a.pvp.net/parties/v1/parties/party/invites/name/T%C3%AAn%20T%C3%B4i/tag/VN%201',
    );
  });

  test('empty 2xx bodies decode to {}', () async {
    adapter.queue.add((_) => ResponseBody.fromString('', 204));
    expect(await api.partyLeaveMatchmaking(_puuid, 'p'), isEmpty);
  });
}
