import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/client_version.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/storage/json_file_cache.dart';

import '../../helpers/test_prefs.dart';

class _CountingAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'offline',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tmp;

  setUp(() async => tmp = await Directory.systemTemp.createTemp('content'));
  tearDown(() async => tmp.delete(recursive: true));

  test(
    'preferCache returns stale complete cache without any request',
    () async {
      final prefs = await createTestPrefs();
      final adapter = _CountingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final cache = JsonFileCache(() async => tmp);
      // Complete but stale cache (no meta = unknown age).
      for (final name in ContentRepository.endpoints.keys) {
        await cache.writeRaw('vi-VN/$name', '{"data":[]}');
      }
      var parsed = 0;
      final repo = ContentRepository(
        versions: ClientVersionRepository(
          prefs: prefs,
          remoteConfig: () => RemoteConfig.defaults,
          dio: dio,
        ),
        dio: dio,
        cache: cache,
        parser: (raw, language, manifestId) async {
          parsed++;
          return ContentDb.empty();
        },
      );
      await repo.load(preferCache: true);
      expect(parsed, 1);
      expect(adapter.calls, 0);
    },
  );
}
