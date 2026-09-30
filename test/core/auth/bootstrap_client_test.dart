import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/bootstrap_client.dart';
import 'package:valvn/core/network/auth_traffic.dart';
import 'package:valvn/core/network/rate_limiter.dart';
import 'package:valvn/core/network/riot_exception.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final List<ResponseBody Function(RequestOptions)> queue = [];

  void json(int status, String body, {Map<String, List<String>>? headers}) =>
      queue.add(
        (_) => ResponseBody.fromString(
          body,
          status,
          headers:
              headers ??
              {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
        ),
      );

  void cloudflare() => queue.add(
    (_) => ResponseBody.fromString(
      '<!DOCTYPE html><title>Just a moment...</title>',
      403,
      headers: {
        Headers.contentTypeHeader: ['text/html'],
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
    return queue.removeAt(0)(o);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late DateTime now;
  late HostRateLimiter limiter;
  late _Adapter adapter;
  late RiotBootstrapClient client;

  setUp(() {
    now = DateTime(2026, 9, 30, 12);
    limiter = createAuthLimiter(now: () => now, jitter: () => 0);
    adapter = _Adapter();
    client = RiotBootstrapClient(
      dio: Dio()..httpClientAdapter = adapter,
      userAgent: () => 'UA',
      limiter: limiter,
    );
  });

  test('entitlements, userinfo and region parse their answers', () async {
    adapter
      ..json(200, '{"entitlements_token":"ENT"}')
      ..json(
        200,
        '{"sub":"41C322A1-B328-495B-A004-5CCD3E45EAE8","acct":{"game_name":"Tên","tag_line":"VN1"},"country":"vnm"}',
      )
      ..json(200, '{"affinities":{"live":"AP"}}');
    expect(await client.fetchEntitlementsToken('T'), 'ENT');
    final info = await client.fetchUserInfo('T');
    expect(info.puuid, '41c322a1-b328-495b-a004-5ccd3e45eae8');
    expect(info.gameName, 'Tên');
    expect(await client.fetchRegion('T', 'ID'), 'ap');
    expect(adapter.requests.map((r) => r.uri.host), [
      'entitlements.auth.riotgames.com',
      'auth.riotgames.com',
      'riot-geo.pas.si.riotgames.com',
    ]);
    expect(adapter.requests.first.headers['Authorization'], 'Bearer T');
  });

  test(
    'Cloudflare on one auth host cools that host down, fail-fast after',
    () async {
      adapter.cloudflare();
      await expectLater(
        client.fetchEntitlementsToken('T'),
        throwsA(
          isA<TransientException>().having(
            (e) => e.reason,
            'reason',
            'cloudflare',
          ),
        ),
      );
      expect(
        limiter.cooldownRemaining('entitlements.auth.riotgames.com'),
        const Duration(seconds: 30),
      );
      await expectLater(
        client.fetchEntitlementsToken('T'),
        throwsA(
          isA<TransientException>()
              .having((e) => e.reason, 'reason', 'cooldown')
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 30),
              ),
        ),
      );
      expect(
        adapter.requests,
        hasLength(1),
        reason: 'nothing sent in cooldown',
      );

      // Other auth hosts are not blocked by it.
      adapter.json(200, '{"affinities":{"live":"eu"}}');
      expect(await client.fetchRegion('T', 'ID'), 'eu');
    },
  );

  test('429 keeps the server\'s Retry-After', () async {
    adapter.json(
      429,
      '{}',
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'retry-after': ['75'],
      },
    );
    await expectLater(
      client.fetchUserInfo('T'),
      throwsA(
        isA<TransientException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 75),
        ),
      ),
    );
    expect(
      limiter.cooldownRemaining('auth.riotgames.com'),
      const Duration(seconds: 75),
    );
  });

  test(
    'a rejected fresh token stays transient (the session layer decides)',
    () async {
      adapter.json(401, '{}');
      await expectLater(
        client.fetchEntitlementsToken('T'),
        throwsA(
          isA<TransientException>().having((e) => e.status, 'status', 401),
        ),
      );
      // A 401 is a normal answer: the host is not penalised.
      expect(
        limiter.cooldownRemaining('entitlements.auth.riotgames.com'),
        isNull,
      );
    },
  );

  test('missing fields are transient, not crashes', () async {
    adapter
      ..json(200, '{}')
      ..json(200, '{"acct":{}}')
      ..json(200, '{"affinities":{}}');
    for (final call in [
      () => client.fetchEntitlementsToken('T'),
      () => client.fetchUserInfo('T'),
      () => client.fetchRegion('T', 'ID'),
    ]) {
      await expectLater(call(), throwsA(isA<TransientException>()));
    }
  });

  test('the slot is released after every call (no leak)', () async {
    for (var i = 0; i < 6; i++) {
      adapter.json(200, '{"entitlements_token":"E$i"}');
    }
    for (var i = 0; i < 6; i++) {
      now = now.add(const Duration(seconds: 2));
      expect(await client.fetchEntitlementsToken('T'), 'E$i');
    }
  });
}
