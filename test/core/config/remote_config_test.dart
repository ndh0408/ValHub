import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/app_constants.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../../helpers/test_prefs.dart';

const _url = 'https://config.example/remote_config.json';

Map<String, Object?> _doc({
  Object? schema = 1,
  Object? flags,
  Object? webViewUserAgent,
  Object? apiUserAgent,
  Object? clientVersionOverride,
  Object? communityBaseUrl,
  Object? vpPrices,
}) => {
  'schema': ?schema,
  'flags': ?flags,
  'webViewUserAgent': ?webViewUserAgent,
  'apiUserAgent': ?apiUserAgent,
  'clientVersionOverride': ?clientVersionOverride,
  'communityBaseUrl': ?communityBaseUrl,
  'vpPrices': ?vpPrices,
};

class _Adapter implements HttpClientAdapter {
  String? body;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async {
    calls++;
    return ResponseBody.fromString(body ?? '', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('RemoteConfig.fromJson validates every field (AR-010)', () {
    test('flags: snake_case names with boolean values only', () {
      final c = RemoteConfig.fromJson({
        'flags': {
          'live_score': true,
          'Bad Name': true,
          '../x': false,
          'ok_flag_2': false,
          'not_bool': 'yes',
          'UPPER': true,
        },
      });
      expect(c.flags, {'live_score': true, 'ok_flag_2': false});
    });

    test('flags are capped', () {
      final c = RemoteConfig.fromJson({
        'flags': {for (var i = 0; i < 200; i++) 'flag_$i': true},
      });
      expect(c.flags.length, RemoteConfig.maxFlags);
    });

    test('user agents: printable ASCII, 20-300 characters, no CR/LF', () {
      const good =
          'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 Chrome/140';
      expect(
        RemoteConfig.fromJson({'webViewUserAgent': good}).webViewUserAgent,
        good,
      );
      for (final bad in [
        'short',
        '$good\r\nX-Injected: 1',
        '$good\nmore',
        'Mozilla/5.0 (Linux) Tiếng Việt không được phép ở đây đâu',
        'x' * 301,
        '',
        42,
      ]) {
        final c = RemoteConfig.fromJson({
          'webViewUserAgent': bad,
          'apiUserAgent': bad,
        });
        expect(c.webViewUserAgent, isNull, reason: '$bad');
        expect(c.apiUserAgent, isNull, reason: '$bad');
      }
    });

    test('client version override must have the release shape', () {
      expect(
        RemoteConfig.fromJson({
          'clientVersionOverride': 'release-13.07-shipping-2-5500000',
        }).clientVersionOverride,
        'release-13.07-shipping-2-5500000',
      );
      for (final bad in [
        'release-13.07',
        'release-13.07-shipping-2-5500000\r\nEvil: 1',
        '13.07.00.5500000',
        '',
      ]) {
        expect(
          RemoteConfig.fromJson({'clientVersionOverride': bad})
              .clientVersionOverride,
          isNull,
          reason: bad,
        );
      }
    });

    test('communityBaseUrl is gone: never parsed, merged or written', () {
      final c = RemoteConfig.fromJson(
        _doc(communityBaseUrl: 'https://evil.example'),
      );
      expect(c.communityBaseUrl, isNull);
      expect(c.merge(c).communityBaseUrl, isNull);
      expect(c.toJson().containsKey('communityBaseUrl'), isFalse);
    });

    test('garbage in, defaults out', () {
      for (final junk in <Object?>[
        null,
        3,
        'x',
        <Object?>[],
        {'flags': 3},
      ]) {
        final c = RemoteConfig.fromJson(junk);
        expect(c.flags, isEmpty);
        expect(c.vpPrices.isEmpty, isTrue);
      }
    });
  });

  group('sanitizeRemoteConfig', () {
    test('needs schema 1', () {
      expect(sanitizeRemoteConfig(_doc()), isNotNull);
      expect(sanitizeRemoteConfig(_doc(schema: null)), isNull);
      expect(sanitizeRemoteConfig(_doc(schema: 2)), isNull);
      expect(sanitizeRemoteConfig(_doc(schema: '1')), isNotNull);
      expect(sanitizeRemoteConfig('not a map'), isNull);
      expect(sanitizeRemoteConfig(null), isNull);
    });

    test('keeps only known, valid fields', () {
      final clean = sanitizeRemoteConfig({
        ..._doc(
          flags: {'live_score': false, 'BAD': true},
          clientVersionOverride: 'nope',
          communityBaseUrl: 'https://evil.example',
        ),
        'somethingElse': {'x': 1},
      })!;
      expect(clean['flags'], {'live_score': false});
      expect(clean['clientVersionOverride'], isNull);
      expect(clean.containsKey('communityBaseUrl'), isFalse);
      expect(clean.containsKey('somethingElse'), isFalse);
      expect(clean['schema'], 1);
    });

    test('VP price tables survive a round trip, bad ones do not', () {
      final clean = sanitizeRemoteConfig(
        _doc(
          vpPrices: {
            'JP': {
              'currency': 'JPY',
              'packs': [
                {'vp': 475, 'price': 500},
              ],
            },
            'XX1': {'currency': 'ZZ', 'packs': <Object?>[]},
          },
        ),
      )!;
      final again = RemoteConfig.fromJson(clean);
      expect(again.vpPrices.forCountry('jp')?.currency, 'JPY');
      expect(again.vpPrices.byCountry.length, 1);
    });
  });

  group('RemoteConfigLoader', () {
    late Prefs prefs;
    late _Adapter adapter;
    late SessionLog log;

    RemoteConfigLoader loader({String url = _url}) => RemoteConfigLoader(
      prefs,
      dio: Dio()..httpClientAdapter = adapter,
      url: url,
      log: log,
    );

    setUp(() async {
      prefs = await createTestPrefs();
      adapter = _Adapter();
      log = SessionLog();
    });

    List<String> logged() => [
      for (final e in log.entries) '${e.event} ${e.detail}',
    ];

    test(
      'refresh stores the sanitised document and logs nothing bad',
      () async {
        adapter.body = jsonEncode(
          _doc(
            flags: {'live_score': false},
            communityBaseUrl: 'https://evil.example',
            webViewUserAgent:
                'Mozilla/5.0 (Test) AppleWebKit/537.36 Mobile Safari',
          ),
        );
        await loader().refresh();
        final stored =
            prefs.getJson(PrefKeys.remoteConfig)! as Map<String, Object?>;
        expect(stored['flags'], {'live_score': false});
        expect(stored.containsKey('communityBaseUrl'), isFalse);
        expect(logged(), isEmpty);
      },
    );

    test(
      'an invalid document is ignored and the previous copy stays',
      () async {
        adapter.body = jsonEncode(_doc(flags: {'live_score': false}));
        await loader().refresh();
        final before = prefs.getString(PrefKeys.remoteConfig);

        for (final bad in [
          jsonEncode(_doc(schema: 9, flags: {'live_score': true})),
          jsonEncode(_doc(schema: null)),
          'not json at all',
          '[]',
          '',
        ]) {
          adapter.body = bad;
          await loader().refresh();
          expect(prefs.getString(PrefKeys.remoteConfig), before, reason: bad);
        }
        expect(
          logged().where((l) => l.startsWith('config.rejected')).length,
          5,
        );
      },
    );

    test('an oversized document is refused', () async {
      adapter.body = jsonEncode(
        _doc(flags: {'live_score': true}, apiUserAgent: 'x' * 10),
      ).padRight(kRemoteConfigMaxBytes + 10, ' ');
      await loader().refresh();
      expect(prefs.getString(PrefKeys.remoteConfig), isNull);
      expect(logged(), ['config.rejected size']);
    });

    test('no URL: no request', () async {
      await loader(url: '').refresh();
      expect(adapter.calls, 0);
    });

    test('a failing download never throws', () async {
      final failing = RemoteConfigLoader(
        prefs,
        dio: Dio()..httpClientAdapter = _Throwing(),
        url: _url,
        log: log,
      );
      await failing.refresh();
      expect(prefs.getString(PrefKeys.remoteConfig), isNull);
    });

    test(
      'load applies a valid stored copy and remembers it as last good',
      () async {
        await prefs.setJson(
          PrefKeys.remoteConfig,
          _doc(flags: {'live_score': false, 'custom_flag': true}),
        );
        final config = await loader().load();
        expect(config.flag('live_score', fallback: true), isFalse);
        expect(config.flag('custom_flag'), isTrue);
        await Future<void>.delayed(Duration.zero);
        expect(prefs.getJson(PrefKeys.remoteConfigLastGood), isNotNull);
        expect(logged(), ['config.applied remote']);
      },
    );

    test(
      'a tampered stored copy falls back to the last known good one',
      () async {
        await prefs.setJson(
          PrefKeys.remoteConfigLastGood,
          _doc(flags: {'custom_flag': true}),
        );
        await prefs.setJson(PrefKeys.remoteConfig, {
          'schema': 7,
          'flags': 'tampered',
        });
        final config = await loader().load();
        expect(config.flag('custom_flag'), isTrue);
        expect(logged(), ['config.applied last_known_good']);
      },
    );

    test('with nothing usable the bundled defaults apply', () async {
      await prefs.setString(PrefKeys.remoteConfig, '{"schema":5}');
      final config = await loader().load();
      expect(config.communityBaseUrl, isNull);
      expect(logged(), ['config.rejected stored copy invalid']);
    });

    test('a stored copy can no longer change the community host', () async {
      await prefs.setJson(
        PrefKeys.remoteConfig,
        _doc(communityBaseUrl: 'https://evil.example'),
      );
      final config = await loader().load();
      expect(config.communityBaseUrl, isNull);
      expect(
        AppConstants.isCommunityHost(
          Uri.parse(AppConstants.communityBaseUrl).host,
        ),
        isTrue,
      );
    });
  });

  group('pinned community hosts', () {
    test('only the ValVN server receives the token', () {
      expect(AppConstants.isCommunityHost('val.gianguyen.cloud'), isTrue);
      expect(AppConstants.isCommunityHost(' VAL.GianGuyen.cloud '), isTrue);
      expect(AppConstants.isCommunityHost('evil.example'), isFalse);
      expect(
        AppConstants.isCommunityHost('val.gianguyen.cloud.evil.example'),
        isFalse,
      );
      expect(AppConstants.isCommunityHost('gianguyen.cloud'), isFalse);
      expect(AppConstants.isCommunityHost(''), isFalse);
    });
  });
}

class _Throwing implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async => throw DioException(
    requestOptions: o,
    type: DioExceptionType.connectionError,
  );

  @override
  void close({bool force = false}) {}
}
