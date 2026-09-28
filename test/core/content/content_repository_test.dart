import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/client_version.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_prefs.dart';

/// Serves fixtures by path; can be switched offline.
class _Vapi implements HttpClientAdapter {
  _Vapi(this.fixtures);

  final Map<String, String> fixtures;
  bool offline = false;
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async {
    if (offline) {
      throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      );
    }
    paths.add('${o.uri.path}?${o.uri.query}');
    if (o.uri.path == '/v1/version') {
      return ResponseBody.fromString(
        '{"status":200,"data":{"manifestId":"M1","riotClientVersion":"release-13.06-shipping-13-5435758","riotClientBuild":"111.0.0.3261.5663"}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    final entry = ContentRepository.endpoints.entries.firstWhere(
      (e) => o.uri.path == '/v1${e.value.split('?').first}',
    );
    return ResponseBody.fromString(
      fixtures[entry.key] ?? '{"status":200,"data":[]}',
      200,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tmp;
  late Prefs prefs;
  late _Vapi vapi;
  late FixedClock clock;
  late ContentRepository repo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('valvn_content');
    prefs = await createTestPrefs();
    vapi = _Vapi(loadContentFixtures());
    clock = FixedClock(DateTime(2026, 9, 28, 12));
    final dio = Dio()..httpClientAdapter = vapi;
    repo = ContentRepository(
      versions: ClientVersionRepository(
        prefs: prefs,
        remoteConfig: () => RemoteConfig.defaults,
        dio: dio,
        clock: clock,
      ),
      dio: dio,
      cache: JsonFileCache(() async => tmp),
      prefs: prefs,
      clock: clock,
      parser: (raw, language, manifestId) async =>
          ContentDb.parse(raw, language: language, manifestId: manifestId),
    );
  });

  tearDown(() => tmp.delete(recursive: true));

  test(
    'downloads every endpoint with language=vi-VN, then serves from cache',
    () async {
      final db = await repo.load();
      expect(db.manifestId, 'M1');
      expect(db.skin('30388628-42f0-606c-82c0-73ad43de997f'), isNotNull);
      final contentCalls = vapi.paths
          .where((p) => !p.startsWith('/v1/version'))
          .toList();
      expect(contentCalls, hasLength(ContentRepository.endpoints.length));
      expect(contentCalls.every((p) => p.contains('language=vi-VN')), isTrue);
      expect(
        contentCalls,
        contains('/v1/agents?isPlayableCharacter=true&language=vi-VN'),
      );

      vapi.paths.clear();
      final again = await repo.load();
      expect(again.weapons, isNotEmpty);
      expect(
        vapi.paths,
        isEmpty,
        reason: 'fresh cache + fresh version: no network',
      );
    },
  );

  test(
    'refetches after 7 days; falls back to the stale cache offline',
    () async {
      await repo.load();
      clock.advance(const Duration(days: 8));
      vapi.paths.clear();
      await repo.load();
      expect(
        vapi.paths.where((p) => p.startsWith('/v1/weapons')),
        hasLength(1),
      );

      clock.advance(const Duration(days: 8));
      vapi.offline = true;
      final offline = await repo.load();
      expect(offline.weapons, isNotEmpty);
    },
  );

  test('nothing cached and offline → TransientException', () async {
    vapi.offline = true;
    await expectLater(repo.load(), throwsA(isA<TransientException>()));
  });

  test('miss refresh is debounced to once per 6 h', () async {
    expect(await repo.allowMissRefresh('vi-VN'), isTrue);
    expect(await repo.allowMissRefresh('vi-VN'), isFalse);
    clock.advance(const Duration(hours: 7));
    expect(await repo.allowMissRefresh('vi-VN'), isTrue);
  });

  test('cache key includes manifest, language and schema', () {
    expect(ContentRepository.cacheKey('M1', 'vi-VN'), 'M1|vi-VN|schema=1');
  });
}
