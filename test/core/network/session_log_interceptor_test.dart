import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/network/dio_factory.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, [this.headers = const {}]);

  final int status;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async => ResponseBody.fromString('{}', status, headers: headers);

  @override
  void close({bool force = false}) {}
}

void main() {
  Future<SessionLogEntry> failOnce(
    _Adapter adapter, {
    Map<String, String> headers = const {},
  }) async {
    final log = SessionLog();
    final dio = createBaseDio(log: log)..httpClientAdapter = adapter;
    await expectLater(
      dio.get<String>(
        'https://val.example.test/v1/posts',
        options: Options(headers: headers),
      ),
      throwsA(isA<DioException>()),
    );
    return log.entries.single;
  }

  test('a failed request records the id the server echoed', () async {
    final entry = await failOnce(
      _Adapter(500, {
        'x-request-id': ['vh0123456789abcdef'],
      }),
      headers: {'X-Request-Id': 'vh0123456789abcdef'},
    );
    expect(entry.status, 500);
    expect(entry.detail, 'id=vh0123456789abcdef');
    expect(entry.toLine(), contains('id=vh0123456789abcdef'));
  });

  test('without a server answer the id the app sent is kept', () async {
    final entry = await failOnce(
      _Adapter(502),
      headers: {'X-Request-Id': 'vhfedcba9876543210'},
    );
    expect(entry.detail, 'id=vhfedcba9876543210');
  });

  test('Riot requests carry no id and record none', () async {
    final entry = await failOnce(_Adapter(404));
    expect(entry.detail, isNull);
  });
}
