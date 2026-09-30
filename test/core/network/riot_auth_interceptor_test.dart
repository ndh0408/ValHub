import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/auth/riot_session.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/network/dio_factory.dart';
import 'package:valvn/core/network/error_classifier.dart';
import 'package:valvn/core/riot/riot_hosts.dart';

class MockSessions extends Mock implements SessionManager {}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responses);

  final List<ResponseBody Function(RequestOptions)> responses;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responses.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

const _puuid = 'p1';

RiotSession _session(String token) => RiotSession(
  puuid: _puuid,
  accessToken: token,
  idToken: 'id',
  entitlementsToken: 'ent',
  expiresAt: DateTime(2100),
  hosts: RiotHosts.forRegion('ap'),
  clientVersion: 'v',
  userAgent: 'ua',
);

ResponseBody Function(RequestOptions) _json(int status, String body) =>
    (_) => ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

ResponseBody Function(RequestOptions) _html(int status) =>
    (_) => ResponseBody.fromString(
      '<!DOCTYPE html><title>Just a moment...</title>',
      status,
      headers: {
        Headers.contentTypeHeader: ['text/html'],
      },
    );

void main() {
  late MockSessions sessions;
  late Dio dio;
  late _FakeAdapter adapter;

  void setUpDio(List<ResponseBody Function(RequestOptions)> responses) {
    adapter = _FakeAdapter(responses);
    dio = createPvpDio(sessions: sessions)..httpClientAdapter = adapter;
  }

  Future<Response<dynamic>> call(String path) => dio.put<dynamic>(
    'https://pd.ap.a.pvp.net$path',
    data: '[]',
    options: Options(extra: {RequestExtras.puuid: _puuid}),
  );

  setUp(() {
    sessions = MockSessions();
    when(() => sessions.session(_puuid))
        .thenAnswer((_) async => _session('T1'));
    when(
      () => sessions.refreshAfterAuthFailure(
        _puuid,
        failedAccessToken: any(named: 'failedAccessToken'),
      ),
    ).thenAnswer((_) async => _session('T2'));
    when(
      () => sessions.reportAuthFailureAfterReauth(
        _puuid,
        accessToken: any(named: 'accessToken'),
      ),
    ).thenAnswer((_) async {});
  });

  test('isAuthFailure: JSON 403 only on name-service', () {
    const body = '{"httpStatus":403,"errorCode":"UNAUTHORIZED"}';
    expect(isAuthFailure(403, body, path: '/name-service/v2/players'), isTrue);
    expect(isAuthFailure(403, body), isFalse);
    expect(isAuthFailure(403, body, path: '/store/v3/storefront/x'), isFalse);
    expect(
      isAuthFailure(
        403,
        '<html>blocked</html>',
        path: '/name-service/v2/players',
      ),
      isFalse,
    );
    expect(
      isAuthFailure(
        403,
        '{"errorCode":"SCHEDULED_DOWNTIME"}',
        path: '/name-service/v2/players',
      ),
      isFalse,
    );
  });

  test('JSON 403 on name-service → one re-auth, then retry', () async {
    setUpDio([_json(403, '{"errorCode":"UNAUTHORIZED"}'), _json(200, '[]')]);
    final res = await call('/name-service/v2/players');
    expect(res.statusCode, 200);
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests.last.headers['Authorization'], 'Bearer T2');
    verify(
      () => sessions.refreshAfterAuthFailure(_puuid, failedAccessToken: 'T1'),
    ).called(1);
  });

  test('HTML 403 on name-service → no re-auth', () async {
    setUpDio([_html(403)]);
    await expectLater(
      call('/name-service/v2/players'),
      throwsA(isA<DioException>()),
    );
    verifyNever(
      () => sessions.refreshAfterAuthFailure(
        _puuid,
        failedAccessToken: any(named: 'failedAccessToken'),
      ),
    );
  });

  test('401 again after the retry is reported (→ needsLogin)', () async {
    setUpDio([_json(401, '{}'), _json(401, '{}')]);
    await expectLater(call('/store/v2/x'), throwsA(isA<DioException>()));
    verify(
      () => sessions.reportAuthFailureAfterReauth(_puuid, accessToken: 'T2'),
    ).called(1);
  });

  test('name-service 403 twice: not reported, no second re-auth', () async {
    when(() => sessions.session(_puuid))
        .thenAnswer((_) async => _session('T2'));
    setUpDio([
      _json(403, '{"errorCode":"X"}'),
      _json(403, '{"errorCode":"X"}'),
      _json(403, '{"errorCode":"X"}'),
    ]);
    await expectLater(
      call('/name-service/v2/players'),
      throwsA(isA<DioException>()),
    );
    // Same token again: no re-auth this time.
    await expectLater(
      call('/name-service/v2/players'),
      throwsA(isA<DioException>()),
    );
    verify(
      () => sessions.refreshAfterAuthFailure(
        _puuid,
        failedAccessToken: any(named: 'failedAccessToken'),
      ),
    ).called(1);
    verifyNever(
      () => sessions.reportAuthFailureAfterReauth(
        _puuid,
        accessToken: any(named: 'accessToken'),
      ),
    );
  });

  group('client version rejected (AR-011)', () {
    const rejection = '{"httpStatus":400,"errorCode":"BAD_CLIENT_VERSION"}';

    test('/v1/version is re-read and the call repeated once', () async {
      when(() => sessions.noteVersionRejected()).thenAnswer((_) async => true);
      setUpDio([_json(400, rejection), _json(200, '[]')]);
      final res = await call('/store/v2/x');
      expect(res.statusCode, 200);
      expect(adapter.requests, hasLength(2));
      verify(() => sessions.noteVersionRejected()).called(1);
      verifyNever(
        () => sessions.refreshAfterAuthFailure(
          _puuid,
          failedAccessToken: any(named: 'failedAccessToken'),
        ),
      );
    });

    test('an unchanged version leaves the error alone', () async {
      when(() => sessions.noteVersionRejected()).thenAnswer((_) async => false);
      setUpDio([_json(400, rejection)]);
      await expectLater(call('/store/v2/x'), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(1));
    });

    test('the repeat is not repeated (no loop)', () async {
      when(() => sessions.noteVersionRejected()).thenAnswer((_) async => true);
      setUpDio([_json(400, rejection), _json(400, rejection)]);
      await expectLater(call('/store/v2/x'), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(2));
      verify(() => sessions.noteVersionRejected()).called(1);
    });

    test('a failing refresh leaves the original error', () async {
      when(() => sessions.noteVersionRejected()).thenThrow(StateError('boom'));
      setUpDio([_json(400, rejection)]);
      await expectLater(call('/store/v2/x'), throwsA(isA<DioException>()));
      expect(adapter.requests, hasLength(1));
    });

    test('other 400s do not touch the version', () async {
      setUpDio([_json(400, '{"errorCode":"BAD_PARAMETER"}')]);
      await expectLater(call('/store/v2/x'), throwsA(isA<DioException>()));
      verifyNever(() => sessions.noteVersionRejected());
    });
  });
}
