import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/cookie_jar.dart';
import 'package:valvn/core/auth/reauth_client.dart';
import 'package:valvn/core/auth/session_manager.dart';

import '../../helpers/jwt.dart';

const _puuid = '41c322a1-b328-495b-a004-5ccd3e45eae8';
final _now = DateTime(2026, 9, 28, 12);

String _okLocation() =>
    'https://playvalorant.com/opt_in#access_token=${fakeJwt({'sub': _puuid})}'
    '&scope=openid&iss=https%3A%2F%2Fauth.riotgames.com&id_token=${fakeJwt({'nonce': '1'})}'
    '&token_type=Bearer&session_state=x&expires_in=3600';

/// Minimal fake transport returning queued responses.
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

ResponseBody _res(
  int status, {
  String body = '',
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(body, status, headers: headers);

void main() {
  group('classifyAuthorizeResponse (GET prompt=none)', () {
    ReauthVerdict classify(
      int status, {
      String? location,
      String? body,
      String? type,
      String? retryAfter,
    }) => classifyAuthorizeResponse(
      status: status,
      location: location,
      body: body,
      contentType: type,
      retryAfterHeader: retryAfter,
      receivedAt: _now,
    );

    test('303 with tokens → ok', () {
      final v = classify(303, location: _okLocation());
      expect(v, isA<VerdictOk>());
      expect((v as VerdictOk).tokens.puuid, _puuid);
      expect(v.tokens.expiresAt, _now.add(const Duration(hours: 1)));
    });

    test('303 to a localized callback → ok', () {
      final v = classify(
        303,
        location: _okLocation().replaceFirst('/opt_in', '/vi-vn/opt_in/'),
      );
      expect(v, isA<VerdictOk>());
    });

    test('login_required fragment → needsLogin', () {
      final v = classify(
        303,
        location:
            'https://playvalorant.com/opt_in#error=interaction_required'
            '&iss=https%3A%2F%2Fauth.riotgames.com&error_description=login_required',
      );
      expect(v, isA<VerdictNeedsLogin>());
      expect((v as VerdictNeedsLogin).reason, 'login_required');
    });

    test('absolute authenticate.riotgames.com/login → needsLogin', () {
      final v = classify(
        303,
        location: 'https://authenticate.riotgames.com/login?client_id=play-valorant-web-prod&locale=vi-VN',
      );
      expect(v, isA<VerdictNeedsLogin>());
    });

    test('legacy relative /login redirect → needsLogin', () {
      expect(classify(302, location: '/login?x=1'), isA<VerdictNeedsLogin>());
    });

    test('Cloudflare HTML 403 → transient', () {
      final v = classify(
        403,
        body: '<!DOCTYPE html><title>Just a moment...</title>',
        type: 'text/html',
      );
      expect(v, isA<VerdictTransient>());
      expect((v as VerdictTransient).reason, 'cloudflare');
    });

    test('429 honours Retry-After', () {
      final v = classify(429, retryAfter: '120');
      expect(v, isA<VerdictTransient>());
      expect((v as VerdictTransient).retryAfter, const Duration(seconds: 120));
    });

    test('5xx → transient', () {
      expect(classify(502), isA<VerdictTransient>());
    });

    test('anything else without a token → unknown (fallback)', () {
      expect(classify(200, body: '{}'), isA<VerdictUnknown>());
      expect(classify(303), isA<VerdictUnknown>());
      expect(
        classify(303, location: 'https://example.com/'),
        isA<VerdictUnknown>(),
      );
      expect(
        classify(400, body: '{"error":"x"}', type: 'application/json'),
        isA<VerdictUnknown>(),
      );
    });
  });

  group('classifyAuthorizationResponse (POST fallback)', () {
    ReauthVerdict classify(int status, Object? body, {String? type}) =>
        classifyAuthorizationResponse(
          status: status,
          body: body,
          contentType: type,
          receivedAt: _now,
        );

    test('type=response with token URI → ok', () {
      final v = classify(200, {
        'type': 'response',
        'response': {
          'parameters': {'uri': _okLocation()},
        },
      });
      expect(v, isA<VerdictOk>());
    });

    test('JSON string bodies are decoded', () {
      final v = classify(200, jsonEncode({'type': 'auth', 'country': 'vnm'}));
      expect(v, isA<VerdictNeedsLogin>());
    });

    test('auth / multifactor → needsLogin', () {
      expect(classify(200, {'type': 'auth'}), isA<VerdictNeedsLogin>());
      expect(classify(200, {'type': 'multifactor'}), isA<VerdictNeedsLogin>());
    });

    test('HTML 403 / 429 → transient; junk → unknown', () {
      expect(
        classify(403, '<html>blocked</html>', type: 'text/html'),
        isA<VerdictTransient>(),
      );
      expect(classify(429, null), isA<VerdictTransient>());
      expect(classify(200, 'not json'), isA<VerdictUnknown>());
      expect(classify(200, {'type': 'weird'}), isA<VerdictUnknown>());
    });
  });

  group('RiotReauthClient', () {
    RiotReauthClient client(_FakeAdapter adapter) {
      final dio = RiotReauthClient.createAuthDio()..httpClientAdapter = adapter;
      return RiotReauthClient(dio: dio, userAgent: () => 'UA', now: () => _now);
    }

    const jar = RiotCookieJar({'ssid': 'old', 'tdid': 't'});

    test('ok: merges rotated Set-Cookie and sends Cookie + UA', () async {
      final adapter = _FakeAdapter([
        (_) => _res(
          303,
          headers: {
            'location': [_okLocation()],
            'set-cookie': [
              'ssid=new; Max-Age=2592000',
              'clid=uw1; Max-Age=2592000',
            ],
          },
        ),
      ]);
      final out = await client(adapter).reauth(jar);
      expect(out, isA<ReauthOk>());
      expect(out.jar.cookies, {'ssid': 'new', 'tdid': 't', 'clid': 'uw1'});
      expect(adapter.requests.single.headers['Cookie'], 'ssid=old; tdid=t');
      expect(adapter.requests.single.headers['User-Agent'], 'UA');
      expect(adapter.requests.single.uri.queryParameters['prompt'], 'none');
    });

    test('unknown GET answer falls back to POST', () async {
      final adapter = _FakeAdapter([
        (_) => _res(
          200,
          body: '<html></html>',
          headers: {
            'content-type': ['text/html'],
          },
        ),
        (_) => _res(
          200,
          body: jsonEncode({'type': 'auth'}),
          headers: {
            'content-type': ['application/json'],
          },
        ),
      ]);
      final out = await client(adapter).reauth(jar);
      expect(out, isA<ReauthNeedsLogin>());
      expect(adapter.requests.map((r) => r.method), ['GET', 'POST']);
      expect(adapter.requests.last.data, contains('play-valorant-web-prod'));
    });

    test('no ssid → needsLogin without any request', () async {
      final adapter = _FakeAdapter([]);
      final out = await client(adapter)
          .reauth(const RiotCookieJar({'tdid': 't'}));
      expect(out, isA<ReauthNeedsLogin>());
      expect(adapter.requests, isEmpty);
    });

    test('network errors are transient', () async {
      final adapter = _FakeAdapter([
        (o) => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionTimeout,
        ),
      ]);
      final out = await client(adapter).reauth(jar);
      expect(out, isA<ReauthTransient>());
      expect((out as ReauthTransient).reason, 'timeout');
    });
  });

  group('resolveReauthRetry', () {
    const jar = RiotCookieJar({'ssid': 's'});
    const needs = ReauthNeedsLogin('login_required', jar);
    const transient = ReauthTransient('cloudflare', jar);

    test('a successful retry wins', () {
      final ok = ReauthOk(
        (classifyAuthorizeResponse(
          status: 303,
          location: _okLocation(),
          receivedAt: _now,
        ) as VerdictOk).tokens,
        jar,
      );
      expect(
        resolveReauthRetry(needs, ok, retriedWithPrevious: true),
        same(ok),
      );
    });

    test('needsLogin twice → needsLogin', () {
      expect(
        resolveReauthRetry(needs, needs, retriedWithPrevious: true),
        isA<ReauthNeedsLogin>(),
      );
    });

    test('transient then needsLogin with the same jar → needsLogin', () {
      expect(
        resolveReauthRetry(transient, needs, retriedWithPrevious: false),
        isA<ReauthNeedsLogin>(),
      );
    });

    test('transient then needsLogin with the OLD jar → transient', () {
      expect(
        resolveReauthRetry(transient, needs, retriedWithPrevious: true),
        isA<ReauthTransient>(),
      );
    });

    test('needsLogin then transient → transient (previous jar unverified)', () {
      expect(
        resolveReauthRetry(needs, transient, retriedWithPrevious: true),
        isA<ReauthTransient>(),
      );
    });
  });
}
