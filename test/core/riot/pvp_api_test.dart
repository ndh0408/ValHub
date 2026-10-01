import 'dart:async';
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

  test('refresh player identity uses own party, authenticated GLZ POST', () async {
    const party = '00000000-0000-0000-0000-000000000099';
    adapter.reply(200, {'ID': party});
    expect(await api.partyRefreshPlayerIdentity(_puuid, party), {'ID': party});
    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(
      request.uri.toString(),
      'https://glz-ap-1.ap.a.pvp.net/parties/v1/parties/$party/members/$_puuid/refreshPlayerIdentity',
    );
    expect(request.data, isNull);
    expect(request.headers['Authorization'], 'Bearer T1');
    expect(request.headers['X-Riot-Entitlements-JWT'], 'ent');
    expect(request.headers['X-Riot-ClientVersion'], isNotEmpty);
    expect(request.headers['X-Riot-ClientPlatform'], isNotEmpty);
  });

  test(
    'manual region validation reads only the candidate host and own subject',
    () async {
      when(() => sessions.forRegionValidation(_puuid, 'eu')).thenAnswer(
        (_) async => _session('T1').copyWith(hosts: RiotHosts.forRegion('eu')),
      );
      adapter.reply(200, {'Subject': _puuid.toUpperCase()});
      expect(await api.validateRegion(_puuid, 'eu'), RegionValidation.verified);
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.followRedirects, false);
      expect(
        adapter.requests.single.uri.toString(),
        'https://pd.eu.a.pvp.net/account-xp/v1/players/$_puuid',
      );
      verifyNever(() => sessions.session(any()));
      verifyNever(
        () => sessions.refreshAfterAuthFailure(
          any(),
          failedAccessToken: any(named: 'failedAccessToken'),
        ),
      );
      adapter.reply(200, {'Subject': 'another-account'});
      expect(await api.validateRegion(_puuid, 'eu'), RegionValidation.rejected);
    },
  );

  group('region validation errors', () {
    setUp(() {
      when(() => sessions.forRegionValidation(_puuid, 'eu')).thenAnswer(
        (_) async => _session('T1').copyWith(hosts: RiotHosts.forRegion('eu')),
      );
      when(
        () => sessions.refreshForRegionValidation(
          _puuid,
          failedAccessToken: 'T1',
        ),
      ).thenAnswer((_) async {});
    });
    test(
      '401 renews once; second rejection is unverified, not logout',
      () async {
        adapter.reply(401, {'errorCode': 'BAD_CLAIMS'});
        adapter.reply(401, {'errorCode': 'BAD_CLAIMS'});
        expect(
          await api.validateRegion(_puuid, 'eu'),
          RegionValidation.unverified,
        );
        expect(adapter.requests, hasLength(2));
        verify(
          () => sessions.refreshForRegionValidation(
            _puuid,
            failedAccessToken: 'T1',
          ),
        ).called(1);
        verifyNever(
          () => sessions.reportAuthFailureAfterReauth(
            any(),
            accessToken: any(named: 'accessToken'),
          ),
        );
      },
    );
    test('renewed token can confirm own account', () async {
      adapter.reply(400, {'errorCode': 'BAD_CLAIMS'});
      adapter.reply(200, {'Subject': _puuid});
      expect(await api.validateRegion(_puuid, 'eu'), RegionValidation.verified);
      verify(
        () => sessions.refreshForRegionValidation(
          _puuid,
          failedAccessToken: 'T1',
        ),
      ).called(1);
    });
    for (final status in [400, 404]) {
      test('JSON $status rejects wrong shard', () async {
        adapter.reply(status, {'errorCode': 'RESOURCE_NOT_FOUND'});
        expect(
          await api.validateRegion(_puuid, 'eu'),
          RegionValidation.rejected,
        );
        expect(adapter.requests, hasLength(1));
      });
    }
    for (final status in [429, 500, 503]) {
      test(
        '$status permits explicit unverified choice without a retry',
        () async {
          adapter.reply(status, {});
          expect(
            await api.validateRegion(_puuid, 'eu'),
            RegionValidation.unverified,
          );
          expect(adapter.requests, hasLength(1));
        },
      );
    }
    test('Cloudflare HTML is unverified', () async {
      adapter.reply(403, '<html>blocked</html>');
      expect(
        await api.validateRegion(_puuid, 'eu'),
        RegionValidation.unverified,
      );
    });
    test(
      'TLS failure and explicit cancellation never count as unverified',
      () async {
        when(() => sessions.forRegionValidation(_puuid, 'eu'))
            .thenThrow(const TransientException(reason: 'tls'));
        await expectLater(
          api.validateRegion(_puuid, 'eu'),
          throwsA(isA<TransientException>()),
        );
        final cancel = CancelToken()..cancel();
        when(() => sessions.forRegionValidation(_puuid, 'eu'))
            .thenAnswer((_) async => _session('T1'));
        await expectLater(
          api.validateRegion(_puuid, 'eu', cancelToken: cancel),
          throwsA(isA<TransientException>()),
        );
        expect(adapter.requests, isEmpty);
      },
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

  test(
    'Cloudflare HTML 403 is not retried inline: host cooldown instead',
    () async {
      adapter.reply(403, '<!DOCTYPE html><title>Just a moment...</title>');
      await expectLater(
        api.mmr(_puuid),
        throwsA(
          isA<TransientException>()
              .having((e) => e.reason, 'reason', 'cloudflare')
              .having((e) => e.retryAfter, 'retryAfter', isNotNull),
        ),
      );
      expect(adapter.requests, hasLength(1));
      // Everyone stops for the cooldown: the next call fails without a request.
      await expectLater(
        api.wallet(_puuid),
        throwsA(
          isA<TransientException>().having(
            (e) => e.reason,
            'reason',
            'cooldown',
          ),
        ),
      );
      expect(adapter.requests, hasLength(1));
    },
  );

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

  group('traffic shaping (AR-005 / AR-006 / AR-017)', () {
    ResponseBody Function(RequestOptions) failWith(DioExceptionType type) =>
        (o) => throw DioException(requestOptions: o, type: type);

    PvpApi build({
      HostRateLimiter? limiter,
      Duration deadline = PvpApi.callDeadline,
      Future<void> Function(Duration)? delay,
    }) => PvpApi(
      sessions: sessions,
      dio: createPvpDio(sessions: sessions)..httpClientAdapter = adapter,
      limiter: limiter ?? HostRateLimiter(burst: 100, refillPerSecond: 100),
      delay: delay ?? (_) async {},
      deadline: deadline,
    );

    test(
      'a lone 5xx is retried; the second one within two minutes stops it',
      () async {
        for (var i = 0; i < 3; i++) {
          adapter.reply(503, {'errorCode': 'x'});
        }
        await expectLater(
          api.mmr(_puuid),
          throwsA(
            isA<TransientException>()
                .having((e) => e.status, 'status', 503)
                .having(
                  (e) => e.retryAfter,
                  'retryAfter',
                  greaterThanOrEqualTo(const Duration(seconds: 30)),
                ),
          ),
        );
        expect(adapter.requests, hasLength(2));
        // The host is penalised now: the next call does not even try.
        await expectLater(
          api.wallet(_puuid),
          throwsA(
            isA<TransientException>().having(
              (e) => e.reason,
              'reason',
              'cooldown',
            ),
          ),
        );
        expect(adapter.requests, hasLength(2));
      },
    );

    test('a 5xx that recovers on the retry succeeds', () async {
      adapter
        ..reply(502, {'errorCode': 'x'})
        ..reply(200, {'Balances': <String, dynamic>{}});
      final wallet = await api.wallet(_puuid);
      expect(wallet.containsKey('Balances'), isTrue);
      expect(adapter.requests, hasLength(2));
    });

    test('a connection error (offline) is not retried inline', () async {
      adapter.queue.add(failWith(DioExceptionType.connectionError));
      await expectLater(
        api.mmr(_puuid),
        throwsA(
          isA<TransientException>().having(
            (e) => e.reason,
            'reason',
            'network',
          ),
        ),
      );
      expect(adapter.requests, hasLength(1));
    });

    test('a timeout is retried once', () async {
      adapter
        ..queue.add(failWith(DioExceptionType.receiveTimeout))
        ..reply(200, {'ok': true});
      expect(await api.mmr(_puuid), {'ok': true});
      expect(adapter.requests, hasLength(2));

      adapter
        ..queue.add(failWith(DioExceptionType.receiveTimeout))
        ..queue.add(failWith(DioExceptionType.receiveTimeout));
      await expectLater(
        api.mmr(_puuid),
        throwsA(
          isA<TransientException>().having((e) => e.isTimeout, 'timeout', true),
        ),
      );
      expect(adapter.requests, hasLength(4));
    });

    test('a 429 with a short Retry-After waits for it and retries', () async {
      var now = DateTime(2026, 9, 30, 12);
      Future<void> tick(Duration d) async => now = now.add(d);
      final waits = <Duration>[];
      final limiter = HostRateLimiter(
        burst: 100,
        refillPerSecond: 100,
        now: () => now,
        delay: (d) async {
          waits.add(d);
          await tick(d);
        },
      );
      final shaped = build(limiter: limiter, delay: tick);
      adapter
        ..reply(
          429,
          {'errorCode': 'x'},
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'retry-after': ['5'],
          },
        )
        ..reply(200, {'Balances': <String, dynamic>{}});
      final wallet = await shaped.wallet(_puuid);
      expect(wallet.containsKey('Balances'), isTrue);
      expect(adapter.requests, hasLength(2));
      expect(now.difference(DateTime(2026, 9, 30, 12)).inSeconds, 5);
    });

    test('a 429 with a long Retry-After is surfaced, not waited for', () async {
      adapter.reply(
        429,
        {'errorCode': 'x'},
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'retry-after': ['120'],
        },
      );
      await expectLater(
        api.mmr(_puuid),
        throwsA(
          isA<TransientException>()
              .having((e) => e.status, 'status', 429)
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 120),
              ),
        ),
      );
      expect(adapter.requests, hasLength(1));
    });

    test('a 429 without Retry-After starts at 10 s and doubles', () async {
      adapter.reply(429, {'errorCode': 'x'});
      final first = await api
          .mmr(_puuid)
          .then<Object?>((_) => null, onError: (Object e) => e);
      expect(
        (first! as TransientException).retryAfter,
        greaterThanOrEqualTo(const Duration(seconds: 10)),
      );
      expect(
        (first as TransientException).retryAfter,
        lessThan(const Duration(seconds: 13)),
      );
    });

    test('mutations skip the token queue (priority lane)', () async {
      final limiter = HostRateLimiter(
        burst: 1,
        refillPerSecond: 0.001,
        delay: (d) async => fail('a mutation must not wait for a token'),
      );
      final shaped = build(limiter: limiter);
      adapter
        ..reply(200, {'ok': true})
        ..reply(200, {'ok': true});
      await shaped.wallet(_puuid); // takes the only token
      await shaped.renewDailyTicket(_puuid); // same host, a mutation
      expect(adapter.requests, hasLength(2));
    });

    test('the deadline ends a hanging call with a timeout', () async {
      final hanging = _HangingAdapter();
      final shaped = PvpApi(
        sessions: sessions,
        dio: createPvpDio(sessions: sessions)..httpClientAdapter = hanging,
        limiter: HostRateLimiter(burst: 100, refillPerSecond: 100),
        delay: (_) async {},
        deadline: const Duration(milliseconds: 150),
      );
      await expectLater(
        shaped.mmr(_puuid),
        throwsA(
          isA<TransientException>().having((e) => e.isTimeout, 'timeout', true),
        ),
      );
      expect(hanging.requests, 1, reason: 'no retry after the deadline');
    });

    test('a slow session also counts against the deadline', () async {
      when(() => sessions.session(any()))
          .thenAnswer((_) => Completer<RiotSession>().future);
      final shaped = build(deadline: const Duration(milliseconds: 100));
      await expectLater(
        shaped.mmr(_puuid),
        throwsA(
          isA<TransientException>().having((e) => e.isTimeout, 'timeout', true),
        ),
      );
      expect(adapter.requests, isEmpty);
    });

    test('a cancel token stops the request (disposed provider)', () async {
      final hanging = _HangingAdapter();
      final shaped = PvpApi(
        sessions: sessions,
        dio: createPvpDio(sessions: sessions)..httpClientAdapter = hanging,
        limiter: HostRateLimiter(burst: 100, refillPerSecond: 100),
        delay: (_) async {},
      );
      final token = CancelToken();
      final call = shaped.matchDetails(_puuid, 'm1', cancelToken: token);
      final outcome = expectLater(
        call,
        throwsA(
          isA<TransientException>().having(
            (e) => e.reason,
            'reason',
            'cancelled',
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      token.cancel('screen closed');
      await outcome;
    });

    test('an already cancelled token sends nothing', () async {
      final token = CancelToken()..cancel('gone');
      await expectLater(
        api.matchDetails(_puuid, 'm1', cancelToken: token),
        throwsA(isA<TransientException>()),
      );
      expect(adapter.requests, isEmpty);
    });

    test(
      'cancelling while awaiting a session does not wait for its deadline',
      () async {
        when(() => sessions.session(any()))
            .thenAnswer((_) => Completer<RiotSession>().future);
        final token = CancelToken();
        final call = build().matchDetails(_puuid, 'm1', cancelToken: token);
        final outcome = expectLater(
          call,
          throwsA(
            isA<TransientException>().having(
              (e) => e.reason,
              'reason',
              'cancelled',
            ),
          ),
        );
        token.cancel('screen closed');
        await outcome.timeout(const Duration(seconds: 1));
        expect(adapter.requests, isEmpty);
      },
    );
  });
}

/// Never answers; completes with a cancellation when dio asks it to stop.
class _HangingAdapter implements HttpClientAdapter {
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    await cancelFuture;
    throw DioException.requestCancelled(requestOptions: o, reason: 'cancel');
  }

  @override
  void close({bool force = false}) {}
}
