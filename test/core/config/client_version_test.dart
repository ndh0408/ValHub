import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/app_constants.dart';
import 'package:valvn/core/config/client_version.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/network/error_classifier.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';

import '../../helpers/test_prefs.dart';

const _goodVersion = 'release-13.06-shipping-13-5435758';
const _goodBuild = '111.0.0.3261.5663';

Map<String, Object?> _payload({
  Object? version = _goodVersion,
  Object? build = _goodBuild,
  Object? manifest = 'ABCDEF0123456789',
}) => {
  'status': 200,
  'data': {
    'riotClientVersion': version,
    'riotClientBuild': build,
    'manifestId': manifest,
  },
};

class _Adapter implements HttpClientAdapter {
  Object body = _payload();
  int calls = 0;
  bool offline = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async {
    calls++;
    if (offline) {
      throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('validation (AR-011)', () {
    test('the real shape is accepted', () {
      final info = ClientVersionInfo.fromApi(_payload())!;
      expect(info.riotClientVersion, _goodVersion);
      expect(info.riotClientBuild, _goodBuild);
      expect(info.manifestId, 'ABCDEF0123456789');
    });

    test('malformed versions are rejected', () {
      for (final bad in <Object?>[
        '',
        '   ',
        'release-13.06',
        'release-13.06-shipping-13-5435758\r\nX-Evil: 1',
        'release-13.06-shipping-13-5435758 ',
        'RELEASE-13.06-shipping-13-5435758',
        'release-13.06-shipping-13-abc',
        'release-13.06-shipping-13-5435758; drop',
        '<html>blocked</html>',
        42,
        null,
      ]) {
        // (trailing spaces are trimmed, so that one is fine)
        final expectNull = bad != 'release-13.06-shipping-13-5435758 ';
        expect(
          ClientVersionInfo.fromApi(_payload(version: bad)),
          expectNull ? isNull : isNotNull,
          reason: '$bad',
        );
      }
    });

    test('malformed builds are rejected', () {
      for (final bad in <Object?>[
        '',
        '1',
        'abc',
        '111.0.0.3261.5663 UA',
        null,
      ]) {
        expect(
          ClientVersionInfo.fromApi(_payload(build: bad)),
          isNull,
          reason: '$bad',
        );
      }
    });

    test('an odd manifest id is dropped, the versions survive', () {
      final info = ClientVersionInfo.fromApi(_payload(manifest: 'a b/../c'))!;
      expect(info.manifestId, isNull);
      expect(info.riotClientVersion, _goodVersion);
    });

    test('the built-in fallback obeys its own patterns', () {
      expect(
        isValidClientVersion(RiotClientConstants.fallbackClientVersion),
        isTrue,
      );
      expect(
        isValidClientBuild(RiotClientConstants.fallbackClientBuild),
        isTrue,
      );
    });
  });

  group('ClientVersionRepository', () {
    late Prefs prefs;
    late _Adapter adapter;
    late FixedClock clock;
    late RemoteConfig config;
    late ClientVersionRepository repo;

    setUp(() async {
      prefs = await createTestPrefs();
      adapter = _Adapter();
      clock = FixedClock(DateTime(2026, 9, 30, 12));
      config = RemoteConfig.defaults;
      repo = ClientVersionRepository(
        prefs: prefs,
        remoteConfig: () => config,
        dio: Dio()..httpClientAdapter = adapter,
        clock: clock,
      );
    });

    test('a malformed answer keeps the last good value', () async {
      await repo.refresh();
      expect(repo.current.riotClientVersion, _goodVersion);
      expect(repo.current.manifestId, 'ABCDEF0123456789');

      adapter.body = _payload(version: 'release-14.01-shipping-9-1234567');
      clock.advance(const Duration(hours: 7));
      await repo.refresh();
      expect(
        repo.current.riotClientVersion,
        'release-14.01-shipping-9-1234567',
      );

      adapter.body = _payload(version: 'release-99.99-shipping-1\r\nEvil: 1');
      clock.advance(const Duration(hours: 7));
      await repo.refresh();
      expect(
        repo.current.riotClientVersion,
        'release-14.01-shipping-9-1234567',
        reason: 'the bad answer was not stored',
      );
    });

    test(
      'nothing stored and a malformed answer → the built-in fallback',
      () async {
        adapter.body = _payload(version: 'nope');
        await repo.refresh();
        expect(
          repo.current.riotClientVersion,
          RiotClientConstants.fallbackClientVersion,
        );
      },
    );

    test('a bad value already in prefs is ignored', () async {
      await prefs.setJson(PrefKeys.clientVersion, {
        'riotClientVersion': 'bad\r\nvalue',
        'riotClientBuild': _goodBuild,
      });
      expect(
        repo.current.riotClientVersion,
        RiotClientConstants.fallbackClientVersion,
      );
      expect(
        repo.apiUserAgent,
        contains(RiotClientConstants.fallbackClientBuild),
      );
    });

    test('a malformed remote override is ignored, a good one applies', () {
      config = const RemoteConfig(clientVersionOverride: 'x\r\ny');
      expect(
        repo.current.riotClientVersion,
        RiotClientConstants.fallbackClientVersion,
      );
      config = const RemoteConfig(
        clientVersionOverride: 'release-13.07-shipping-2-5500000',
      );
      expect(
        repo.current.riotClientVersion,
        'release-13.07-shipping-2-5500000',
      );
    });

    test('refresh is gated to 6 h; a stale copy is refreshed', () async {
      await repo.refresh();
      await repo.refresh();
      expect(adapter.calls, 1);
      clock.advance(const Duration(hours: 7));
      await repo.refresh();
      expect(adapter.calls, 2);
    });

    test('offline keeps the stored value and never throws', () async {
      await repo.refresh();
      adapter.offline = true;
      clock.advance(const Duration(hours: 30));
      expect((await repo.refresh()).riotClientVersion, _goodVersion);
    });

    test(
      'noteRejected: forced refresh, reports a change, once per 10 min',
      () async {
        await repo.refresh();
        adapter.body = _payload(version: 'release-13.07-shipping-2-5500000');
        expect(await repo.noteRejected(), isTrue);
        expect(
          repo.current.riotClientVersion,
          'release-13.07-shipping-2-5500000',
        );
        final calls = adapter.calls;

        // A second rejection right away does not hammer valorant-api.
        expect(await repo.noteRejected(), isFalse);
        expect(adapter.calls, calls);

        clock.advance(const Duration(minutes: 11));
        // Same version again: refreshed, but nothing changed.
        expect(await repo.noteRejected(), isFalse);
        expect(adapter.calls, calls + 1);
      },
    );
  });

  group('isClientVersionRejection', () {
    test('a 400 naming the client version', () {
      expect(
        isClientVersionRejection(400, {'errorCode': 'BAD_CLIENT_VERSION'}),
        isTrue,
      );
      expect(
        isClientVersionRejection(400, '{"errorCode":"INVALID_CLIENT_VERSION"}'),
        isTrue,
      );
      expect(
        isClientVersionRejection(400, {'message': 'Invalid Client Version.'}),
        isTrue,
      );
    });

    test('everything else is not', () {
      expect(
        isClientVersionRejection(400, {'errorCode': 'BAD_CLAIMS'}),
        isFalse,
      );
      expect(
        isClientVersionRejection(403, {'errorCode': 'BAD_CLIENT_VERSION'}),
        isFalse,
      );
      expect(isClientVersionRejection(400, null), isFalse);
      expect(isClientVersionRejection(400, '<html>'), isFalse);
      expect(isClientVersionRejection(null, {}), isFalse);
    });
  });
}
