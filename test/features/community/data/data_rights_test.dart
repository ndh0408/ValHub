import '../../../helpers/l10n.dart';

import 'package:valvn/features/community/ui/community_error.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/community_exception.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/providers/data_rights_providers.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart';

import '../community_test_env.dart';

/// What `GET /v1/me/export` returns (docs: `valvn-community-export/1`).
Map<String, Object?> exportJson() => {
  'format': 'valvn-community-export/1',
  'exportedAt': now.toIso8601String(),
  'profile': {'id': meId, 'gameName': 'Tôi Là Ai', 'tagLine': 'VN1'},
  'posts': [
    {'id': 'p1', 'body': 'Bài viết đầu tiên — đẹp quá!', 'hidden': false},
  ],
  'comments': <Object>[],
  'reviews': [
    {'skinUuid': reaverSkin, 'rating': 5},
  ],
  'lfgPosts': <Object>[],
};

Matcher _isCode(String code) =>
    throwsA(isA<CommunityException>().having((e) => e.code, 'code', code));

void main() {
  late CommunityTestEnv env;
  late ProviderContainer container;
  late CommunityApi api;

  setUp(() async {
    env = await CommunityTestEnv.create();
    container = env.container();
    api = container.read(communityApiProvider);
  });

  group('new server errors', () {
    CommunityException fromBody(
      int status,
      Object? body, {
      String? retryAfterHeader,
    }) => CommunityException.fromResponse(
      status,
      body,
      retryAfterHeader: retryAfterHeader,
    );

    test('riot_unavailable: 503 + Retry-After, a retryable Riot outage', () {
      final e = fromBody(503, {
        'error': {'code': 'riot_unavailable', 'message': 'Riot bận'},
      }, retryAfterHeader: '45');

      expect(e.code, CommunityException.riotUnavailable);
      expect(e.status, 503);
      expect(e.retryAfter, const Duration(seconds: 45));
      expect(e.isRetryable, isTrue);
      // Never a token refusal.
      expect(e.isAuthFailure, isFalse);
      final d = describeCommunityError(tl, e);
      expect(d.message, CommunityStrings.errorRiotUnavailableIn('45 giây'));
      expect(d.message, contains('Riot đang gặp sự cố'));
      expect(d.canRetry, isTrue);
      expect(d.needsLogin, isFalse);
    });

    test('riot_unavailable: retryAfter in the body, minutes are coarse', () {
      final e = fromBody(503, {
        'error': {'code': 'riot_unavailable', 'retryAfter': 120},
      });
      expect(e.retryAfter, const Duration(seconds: 120));
      expect(
        describeCommunityError(tl, e).message,
        CommunityStrings.errorRiotUnavailableIn(
          formatDurationCoarse(const Duration(minutes: 2)),
        ),
      );
    });

    test('riot_unavailable without a delay: a plain "try again later"', () {
      final e = fromBody(503, {
        'error': {'code': 'riot_unavailable'},
      });
      expect(e.retryAfter, isNull);
      expect(
        describeCommunityError(tl, e).message,
        CommunityStrings.errorRiotUnavailable,
      );
    });

    test('an HTML 503 (gateway page) stays a generic server error', () {
      final e = fromBody(503, '<html><body>Bad gateway</body></html>');
      expect(e.code, CommunityException.serverError);
      expect(
        describeCommunityError(tl, e).message,
        CommunityStrings.errorServer,
      );
    });

    test('storage_full: 507, no retry, says images cannot be added', () {
      final e = fromBody(507, {
        'error': {'code': 'storage_full', 'message': 'disk'},
      });
      expect(e.code, CommunityException.storageFull);
      expect(e.isRetryable, isFalse);
      final d = describeCommunityError(tl, e);
      expect(d.message, CommunityStrings.errorStorageFull);
      expect(d.message, contains('Kho ảnh của Cộng đồng đã đầy'));
      expect(d.canRetry, isFalse);
      // A bare 507 (no JSON) is the same thing.
      expect(fromBody(507, null).code, CommunityException.storageFull);
    });

    test('a legacy validation message is replaced by player copy', () {
      const message =
          'Bạn đã dùng hết 50 MB dung lượng ảnh. Hãy xóa bớt bài có ảnh.';
      final e = fromBody(400, {
        'error': {'code': 'invalid_input', 'message': message},
      });
      expect(e.code, CommunityException.invalidInput);
      expect(
        describeCommunityError(tl, e).message,
        CommunityStrings.errorInvalid,
      );
      expect(describeCommunityError(tl, e).canRetry, isFalse);
    });

    test('rate_limited keeps retryAfter (body wins over the header)', () {
      final a = fromBody(429, {
        'error': {'code': 'rate_limited', 'retryAfter': 1800},
      }, retryAfterHeader: '5');
      expect(a.retryAfter, const Duration(minutes: 30));
      expect(
        describeCommunityError(tl, a).message,
        CommunityStrings.errorRateLimitedIn('30 phút'),
      );
      final b = fromBody(429, {
        'error': {'code': 'rate_limited'},
      }, retryAfterHeader: '90');
      expect(b.retryAfter, const Duration(seconds: 90));
      expect(b.isRetryable, isTrue);
    });

    test(
      'sign-in outage: riot_unavailable, no refresh, nothing wiped',
      () async {
        env.server.on(
          'POST /v1/auth/riot',
          (_) => const FakeResponse(
            503,
            {
              'error': {'code': 'riot_unavailable', 'message': 'Riot bận'},
            },
            {
              'retry-after': ['30'],
            },
          ),
        );

        await expectLater(
          api.lfg(mePuuid, region: 'ap'),
          _isCode(CommunityException.riotUnavailable),
        );

        // Not a rejection of the Riot token: no refresh, no second attempt.
        verifyNever(
          () => env.sessions.refreshAfterAuthFailure(
            any(),
            failedAccessToken: any(named: 'failedAccessToken'),
          ),
        );
        expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
        // The consent stays; a later call works once Riot is back.
        expect(
          container.read(communityConsentProvider(mePuuid)),
          CommunityConsent.granted,
        );
        env.server
          ..json('POST /v1/auth/riot', sessionJson())
          ..json('GET /v1/lfg', page([lfgJson('l1')]));
        final page1 = await api.lfg(mePuuid, region: 'ap');
        expect(page1.items.single.id, 'l1');
      },
    );

    test('a stored session survives a riot_unavailable on a request', () async {
      final stored = jsonEncode(sessionJson(token: 'stored-1'));
      env.secure.values[SecureKeys.community(mePuuid)] = stored;
      env.server.json('GET /v1/lfg', {
        'error': {'code': 'riot_unavailable'},
      }, status: 503);

      await expectLater(
        api.lfg(mePuuid, region: 'ap'),
        _isCode(CommunityException.riotUnavailable),
      );

      expect(env.secure.values[SecureKeys.community(mePuuid)], stored);
      expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
      expect(
        container.read(communityConsentProvider(mePuuid)),
        CommunityConsent.granted,
      );
    });

    test('uploading with a full disk: storage_full', () async {
      env.server.json('POST /v1/media', {
        'error': {'code': 'storage_full'},
      }, status: 507);
      await expectLater(
        api.uploadMedia(mePuuid, jpegBytes()),
        _isCode(CommunityException.storageFull),
      );
      // The session is untouched.
      expect(env.secure.values[SecureKeys.community(mePuuid)], isNotNull);
    });
  });

  group('GET /v1/me/export', () {
    test('sends the session token and returns the document', () async {
      env.server.json('GET /v1/me/export', exportJson());

      final doc = await api.exportMyData(mePuuid);

      expect(doc['format'], 'valvn-community-export/1');
      final call = env.server.calls('GET /v1/me/export').single;
      expect(call.authorization, 'Bearer community-1');
    });

    test('a body that is not an object is a bad response', () async {
      env.server.json('GET /v1/me/export', ['nope']);
      await expectLater(
        api.exportMyData(mePuuid),
        _isCode(CommunityException.badResponse),
      );
    });

    test('over 5 / hour: rate_limited with the delay', () async {
      env.server.json('GET /v1/me/export', {
        'error': {'code': 'rate_limited', 'retryAfter': 1200},
      }, status: 429);
      await expectLater(
        api.exportMyData(mePuuid),
        throwsA(
          isA<CommunityException>()
              .having((e) => e.code, 'code', CommunityException.rateLimited)
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(minutes: 20),
              ),
        ),
      );
    });

    test(
      'the file: readable UTF-8 JSON named valvn-community-<date>.json',
      () async {
        env.server.json('GET /v1/me/export', exportJson());
        env.clock.time = DateTime(2026, 9, 28, 12);

        final file = await container
            .read(communityDataRightsProvider)
            .export(mePuuid);

        expect(file.fileName, 'valvn-community-2026-09-28.json');
        expect(file.text, contains('\n  "format": "valvn-community-export/1"'));
        // Vietnamese text is kept as is, not \u-escaped.
        expect(file.text, contains('Bài viết đầu tiên — đẹp quá!'));
        expect(jsonDecode(file.text), exportJson());
      },
    );

    test('exportAndShare hands the file to the share sheet', () async {
      env.server.json('GET /v1/me/export', exportJson());
      env.clock.time = DateTime(2026, 1, 5, 8);

      await container.read(communityDataRightsProvider).exportAndShare(mePuuid);

      final shared = env.sharedExports;
      expect(shared, hasLength(1));
      expect(shared.single.fileName, 'valvn-community-2026-01-05.json');
      expect(jsonDecode(shared.single.text), exportJson());
      expect(shared.single.shareTitle, tl.communityExportSubject);
      // Read-only: nothing local changed.
      expect(
        container.read(communityConsentProvider(mePuuid)),
        CommunityConsent.granted,
      );
    });

    test('a failed export shares nothing', () async {
      env.server.json('GET /v1/me/export', {
        'error': {'code': 'server_error'},
      }, status: 500);
      await expectLater(
        container.read(communityDataRightsProvider).exportAndShare(mePuuid),
        _isCode(CommunityException.serverError),
      );
      expect(env.sharedExports, isEmpty);
    });

    test('account switch during export never opens the share sheet', () async {
      final gate = Completer<void>();
      env.server.json('GET /v1/me/export', exportJson());
      env.server.hold('GET /v1/me/export', gate);
      final pending = container
          .read(communityDataRightsProvider)
          .exportAndShare(mePuuid);
      final rejected = expectLater(
        pending,
        _isCode(CommunityException.cancelled),
      );
      for (
        var i = 0;
        env.server.calls('GET /v1/me/export').isEmpty && i < 100;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(env.server.calls('GET /v1/me/export'), hasLength(1));
      container.read(activePuuidProvider.notifier).select(null);
      gate.complete();
      await rejected;
      expect(env.sharedExports, isEmpty);
    });

    Future<void> cancelPendingExport(Future<void> Function() invalidate) async {
      final gate = Completer<void>();
      env.server.json('GET /v1/me/export', exportJson());
      env.server.hold('GET /v1/me/export', gate);
      final pending = container
          .read(communityDataRightsProvider)
          .exportAndShare(mePuuid);
      final rejected = expectLater(
        pending,
        _isCode(CommunityException.cancelled),
      );
      for (
        var i = 0;
        env.server.calls('GET /v1/me/export').isEmpty && i < 100;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(env.server.calls('GET /v1/me/export'), hasLength(1));
      await invalidate();
      gate.complete();
      await rejected;
      expect(env.sharedExports, isEmpty);
    }

    test('switching away and back still cancels the old export', () async {
      await cancelPendingExport(() async {
        final active = container.read(activePuuidProvider.notifier);
        active.select(null);
        active.select(mePuuid);
      });
    });

    test('removed account cannot share its pending export', () async {
      await cancelPendingExport(() async {
        await env.prefs.setJson(PrefKeys.accounts, []);
        container.read(accountsProvider.notifier).reload();
      });
    });

    test('withdrawn consent cannot share its pending export', () async {
      await cancelPendingExport(() async {
        await container
            .read(communityConsentProvider(mePuuid).notifier)
            .revoke();
      });
    });

    test(
      'disposed provider cancels sharing without reading its dead ref',
      () async {
        await cancelPendingExport(() async {
          container.dispose();
        });
      },
    );

    test('stale account cannot start an export or share', () async {
      container.read(activePuuidProvider.notifier).select(null);
      await expectLater(
        container.read(communityDataRightsProvider).exportAndShare(mePuuid),
        _isCode(CommunityException.cancelled),
      );
      expect(env.server.calls('GET /v1/me/export'), isEmpty);
      expect(env.sharedExports, isEmpty);
    });

    test('file name uses the local date, zero padded', () {
      expect(
        communityExportFileName(DateTime(2027, 3, 4, 23, 59)),
        'valvn-community-2027-03-04.json',
      );
    });
  });

  group('DELETE /v1/me', () {
    Future<void> signIn() async {
      // A session on the device (as after using the Community).
      await api.me(mePuuid).then((_) {}, onError: (Object _) {});
    }

    setUp(() {
      env.server.json('GET /v1/me', authorJson(id: meId));
    });

    test(
      'erases on the server, then forgets session and consent here',
      () async {
        env.server.on('DELETE /v1/me', (_) => const FakeResponse(204));
        await signIn();
        expect(env.secure.values[SecureKeys.community(mePuuid)], isNotNull);
        final sub = container.listen(
          communityConsentProvider(mePuuid),
          (_, _) {},
        );
        addTearDown(sub.close);

        await container.read(communityDataRightsProvider).deleteAll(mePuuid);

        final call = env.server.calls('DELETE /v1/me').single;
        expect(call.authorization, 'Bearer community-1');
        expect(env.secure.values[SecureKeys.community(mePuuid)], isNull);
        expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
        expect(
          container.read(communityConsentProvider(mePuuid)),
          CommunityConsent.unknown,
        );
        expect(
          container.read(communityAuthProvider).hasConsent(mePuuid),
          isFalse,
        );
        expect(
          await container.read(communityAuthProvider).cachedSession(mePuuid),
          isNull,
        );
        // Back to anonymous: writes need consent again, before any request.
        final before = env.server.requests.length;
        await expectLater(
          api.createPost(mePuuid, kind: PostKind.text, body: 'x'),
          _isCode(CommunityException.consentRequired),
        );
        expect(env.server.requests.length, before);
      },
    );

    test('other accounts are untouched', () async {
      env.server.on('DELETE /v1/me', (_) => const FakeResponse(204));
      const other = '11111111-2222-3333-4444-555555555555';
      await env.prefs.setString(communityConsentKey(other), 'granted');
      await env.prefs.setString(
        communityConsentVersionKey(other),
        communityConsentVersion,
      );
      env.secure.values[SecureKeys.community(other)] = jsonEncode(
        sessionJson(token: 'other-1'),
      );
      await signIn();

      await container.read(communityDataRightsProvider).deleteAll(mePuuid);

      expect(env.prefs.getString(communityConsentKey(other)), 'granted');
      expect(env.secure.values[SecureKeys.community(other)], isNotNull);
    });

    test('a failed request leaves session and consent as they were', () async {
      env.server.json('DELETE /v1/me', {
        'error': {'code': 'server_error'},
      }, status: 500);
      await signIn();

      await expectLater(
        container.read(communityDataRightsProvider).deleteAll(mePuuid),
        _isCode(CommunityException.serverError),
      );

      expect(env.secure.values[SecureKeys.community(mePuuid)], isNotNull);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      expect(
        container.read(communityConsentProvider(mePuuid)),
        CommunityConsent.granted,
      );
    });

    test('over 3 / hour: rate_limited, nothing wiped', () async {
      env.server.json('DELETE /v1/me', {
        'error': {'code': 'rate_limited', 'retryAfter': 3000},
      }, status: 429);
      await signIn();
      await expectLater(
        container.read(communityDataRightsProvider).deleteAll(mePuuid),
        _isCode(CommunityException.rateLimited),
      );
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
    });

    test('the poster\'s own LFG post and vote overrides are dropped', () async {
      env.server
        ..on('DELETE /v1/me', (_) => const FakeResponse(204))
        ..json(
          'GET /v1/lfg/mine',
          lfgJson('mine', author: authorJson(id: meId)),
        );
      final mine = myLfgProvider(mePuuid);
      final sub = container.listen(mine, (_, _) {});
      addTearDown(sub.close);
      expect((await container.read(mine.future))?.id, 'mine');

      await container.read(communityDataRightsProvider).deleteAll(mePuuid);
      // Rebuilds without a session: no post, and no request for it.
      final calls = env.server.calls('GET /v1/lfg/mine').length;
      expect(await container.read(mine.future), isNull);
      expect(env.server.calls('GET /v1/lfg/mine'), hasLength(calls));
    });

    test(
      'a sign-in still running when data is deleted keeps nothing',
      () async {
        final gate = Completer<void>();
        env.server.hold('POST /v1/auth/riot', gate);
        env.server.on('DELETE /v1/me', (_) => const FakeResponse(204));
        final auth = container.read(communityAuthProvider);

        final pending = auth.session(mePuuid);
        // Let the request reach the (held) server.
        while (env.server.calls('POST /v1/auth/riot').isEmpty) {
          await Future<void>.delayed(Duration.zero);
        }
        await container
            .read(communityDataRightsProvider)
            .withdrawConsent(mePuuid);
        gate.complete();

        await expectLater(pending, _isCode(CommunityException.consentRequired));
        expect(env.secure.values[SecureKeys.community(mePuuid)], isNull);
        expect(await auth.cachedSession(mePuuid), isNull);
      },
    );
  });

  group('Rút lại đồng ý', () {
    test('forgets locally and sends nothing to the server', () async {
      env.server.json('GET /v1/me', authorJson(id: meId));
      await api.me(mePuuid);
      final requests = env.server.requests.length;

      await container
          .read(communityDataRightsProvider)
          .withdrawConsent(mePuuid);

      expect(env.server.requests.length, requests);
      expect(env.server.calls('DELETE /v1/me'), isEmpty);
      expect(env.secure.values[SecureKeys.community(mePuuid)], isNull);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
      expect(
        container.read(communityConsentProvider(mePuuid)),
        CommunityConsent.unknown,
      );
    });

    test('reads keep working anonymously afterwards', () async {
      env.server.json('GET /v1/posts', page([postJson('p1')]));
      await api.posts(mePuuid);
      await container
          .read(communityDataRightsProvider)
          .withdrawConsent(mePuuid);

      final result = await api.posts(mePuuid);

      expect(result.items.single.id, 'p1');
      expect(env.server.calls('GET /v1/posts').last.authorization, isNull);
    });

    test('joining again signs in from scratch', () async {
      env.server.json('GET /v1/posts', page([postJson('p1')]));
      await api.posts(mePuuid);
      await container
          .read(communityDataRightsProvider)
          .withdrawConsent(mePuuid);
      await container.read(communityConsentProvider(mePuuid).notifier).grant();

      await api.posts(mePuuid);

      expect(env.server.calls('POST /v1/auth/riot'), hasLength(2));
    });
  });
}
