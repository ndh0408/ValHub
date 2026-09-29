import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/community_exception.dart';
import 'package:valvn/features/community/data/community_http.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';

import '../community_test_env.dart';

void main() {
  late CommunityTestEnv env;
  late ProviderContainer container;
  late CommunityApi api;

  setUp(() async {
    env = await CommunityTestEnv.create();
    container = env.container();
    api = container.read(communityApiProvider);
  });

  test(
    'signs in once with the Riot token, stores the session securely',
    () async {
      env.server.json('GET /v1/posts', page([postJson('p1')]));

      final first = await api.posts(mePuuid);
      final second = await api.posts(mePuuid);

      expect(first.items.single.id, 'p1');
      expect(second.items, hasLength(1));
      final auth = env.server.calls('POST /v1/auth/riot');
      expect(auth, hasLength(1));
      expect(auth.single.json, {
        'accessToken': 'riot-access-1',
        'region': 'ap',
        'cardId': cardId,
        'rankTier': 18,
      });
      final gets = env.server.calls('GET /v1/posts');
      expect(
        gets.map((r) => r.authorization),
        everyElement('Bearer community-1'),
      );
      final stored = env.secure.values[SecureKeys.community(mePuuid)];
      expect(stored, isNotNull);
      expect(jsonDecode(stored!), containsPair('token', 'community-1'));
      expect(
        SecureKeys.allFor(mePuuid),
        contains(SecureKeys.community(mePuuid)),
      );
    },
  );

  test('reuses a stored session without calling Riot', () async {
    env.secure.values[SecureKeys.community(mePuuid)] = jsonEncode(
      sessionJson(token: 'stored-1'),
    );
    env.server.json('GET /v1/me', authorJson(id: meId));

    final me = await api.me(mePuuid);

    expect(me.id, meId);
    expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
    expect(env.server.requests.single.authorization, 'Bearer stored-1');
    verifyNever(() => env.sessions.session(any()));
  });

  test('a 401 re-signs in once and retries', () async {
    env.secure.values[SecureKeys.community(mePuuid)] = jsonEncode(
      sessionJson(token: 'expired-1'),
    );
    env.server
      ..json('POST /v1/auth/riot', sessionJson(token: 'fresh-2'))
      ..on(
        'GET /v1/posts',
        (r) => r.authorization == 'Bearer fresh-2'
            ? FakeResponse(200, page([postJson('ok')]))
            : const FakeResponse(401, {
                'error': {'code': 'unauthorized', 'message': 'expired'},
              }),
      );

    final result = await api.posts(mePuuid);

    expect(result.items.single.id, 'ok');
    expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
    expect(env.server.calls('GET /v1/posts'), hasLength(2));
    expect(
      jsonDecode(env.secure.values[SecureKeys.community(mePuuid)]!),
      containsPair('token', 'fresh-2'),
    );
  });

  test('a second 401 surfaces as unauthorized (no loop)', () async {
    env.server.json('GET /v1/posts', {
      'error': {'code': 'unauthorized'},
    }, status: 401);

    await expectLater(
      api.posts(mePuuid),
      throwsA(
        isA<CommunityException>().having(
          (e) => e.code,
          'code',
          CommunityException.unauthorized,
        ),
      ),
    );
    expect(env.server.calls('GET /v1/posts'), hasLength(2));
    expect(env.server.calls('POST /v1/auth/riot'), hasLength(2));
  });

  test('riot_rejected refreshes the Riot token once', () async {
    when(
      () => env.sessions.refreshAfterAuthFailure(
        any(),
        failedAccessToken: any(named: 'failedAccessToken'),
      ),
    ).thenAnswer((_) async => riotSession(token: 'riot-access-2'));
    env.server
      ..on(
        'POST /v1/auth/riot',
        (r) => (r.json! as Map)['accessToken'] == 'riot-access-2'
            ? FakeResponse(200, sessionJson())
            : const FakeResponse(401, {
                'error': {'code': 'riot_rejected'},
              }),
      )
      ..json('GET /v1/lfg', page([lfgJson('l1')]));

    final result = await api.lfg(mePuuid, region: 'ap');

    expect(result.items.single.id, 'l1');
    verify(
      () => env.sessions.refreshAfterAuthFailure(
        mePuuid,
        failedAccessToken: 'riot-access-1',
      ),
    ).called(1);
    expect(env.server.calls('GET /v1/lfg').single.query, {
      'region': 'ap',
      'limit': '20',
    });
  });

  test('Riot needs-login during sign-in propagates as a Riot error', () async {
    when(() => env.sessions.session(any()))
        .thenThrow(const NeedsLoginException(puuid: mePuuid));
    await expectLater(api.posts(mePuuid), throwsA(isA<NeedsLoginException>()));
    expect(env.server.requests, isEmpty);
  });

  test('rate limits carry retryAfter (body, then header) → vi copy', () async {
    env.server
      ..json('POST /v1/posts', {
        'error': {'code': 'rate_limited', 'message': 'slow down'},
        'retryAfter': 120,
      }, status: 429)
      ..on(
        'POST /v1/lfg',
        (_) => const FakeResponse(
          429,
          {
            'error': {'code': 'rate_limited'},
          },
          {
            'retry-after': ['30'],
          },
        ),
      );

    final e1 = await api
        .createPost(mePuuid, kind: PostKind.text, body: 'x')
        .then<Object?>((_) => null, onError: (Object e) => e);
    expect(e1, isA<CommunityException>());
    final ex = e1! as CommunityException;
    expect(ex.code, CommunityException.rateLimited);
    expect(ex.retryAfter, const Duration(minutes: 2));
    expect(
      describeCommunityError(ex).message,
      'Bạn thao tác hơi nhanh. Thử lại sau 2 phút.',
    );

    final e2 = await api
        .createLfg(
          mePuuid,
          region: 'ap',
          mode: 'competitive',
          partyCode: 'abc123',
          slots: 2,
        )
        .then<Object?>((_) => null, onError: (Object e) => e);
    expect((e2! as CommunityException).retryAfter, const Duration(seconds: 30));
    expect(
      env.server.calls('POST /v1/lfg').single.json,
      containsPair('partyCode', 'ABC123'),
    );
  });

  test('HTML error pages and garbage 2xx bodies never crash', () async {
    env.server
      ..json(
        'GET /v1/posts',
        '<html><body>502 Bad Gateway</body></html>',
        status: 502,
      )
      ..json('GET /v1/me', '<html>captive portal</html>');

    await expectLater(
      api.posts(mePuuid),
      throwsA(
        isA<CommunityException>()
            .having((e) => e.code, 'code', CommunityException.serverError)
            .having((e) => e.status, 'status', 502),
      ),
    );
    await expectLater(
      api.me(mePuuid),
      throwsA(
        isA<CommunityException>().having(
          (e) => e.code,
          'code',
          CommunityException.badResponse,
        ),
      ),
    );
    expect(
      describeCommunityError(
        const CommunityException(CommunityException.serverError),
      ).message,
      contains('Máy chủ Cộng đồng'),
    );
  });

  test('empty 204 bodies are fine (delete, report)', () async {
    env.server
      ..json('DELETE /v1/posts/*', null, status: 204)
      ..json('POST /v1/reports', null, status: 204);
    await api.deletePost(mePuuid, 'p 1');
    await api.report(
      mePuuid,
      targetType: ReportTarget.comment,
      targetId: 'c1',
      reason: 'spam',
    );
    expect(
      env.server.calls('DELETE /v1/posts/*').single.path,
      '/v1/posts/p%201',
    );
    expect(env.server.calls('POST /v1/reports').single.json, {
      'targetType': 'comment',
      'targetId': 'c1',
      'reason': 'spam',
    });
  });

  test('optional auth: skin votes without a session skip Riot', () async {
    env.server.json('GET /v1/skins/votes', {
      'items': [
        {'skinUuid': reaverSkin, 'votes': 42, 'voted': false},
        {'nope': true},
      ],
    });

    final votes = await api.skinVotes([
      reaverSkin.toUpperCase(),
    ], puuid: mePuuid);

    expect(votes[reaverSkin]?.vote.votes, 42);
    final req = env.server.requests.single;
    expect(req.authorization, isNull);
    expect(req.query['ids'], reaverSkin);
    verifyNever(() => env.sessions.session(any()));
  });

  test('votes, likes and the leaderboard', () async {
    env.server
      ..json('PUT /v1/skins/*/vote', {
        'skinUuid': reaverSkin,
        'votes': 8,
        'voted': true,
      })
      ..json('PUT /v1/posts/*/like', {'likes': 4, 'liked': true})
      ..json('GET /v1/skins/top', {
        'items': [
          {'rank': 2, 'skinUuid': knifeSkin, 'votes': 3},
          {'rank': 1, 'skinUuid': reaverSkin, 'votes': 9, 'voted': true},
          {'rank': 3, 'skinUuid': reaverSkin, 'votes': 1},
        ],
      });

    final v = await api.vote(mePuuid, reaverSkin, weaponUuid: vandal);
    expect((v.votes, v.voted), (8, true));
    expect(env.server.calls('PUT /v1/skins/*/vote').single.json, {
      'weaponUuid': vandal,
    });
    final like = await api.setLiked(mePuuid, 'p1', liked: true);
    expect(like, (likes: 4, liked: true));
    final top = await api.topSkins(
      puuid: mePuuid,
      weapon: vandal,
      period: TopPeriod.week,
    );
    expect(top.map((t) => t.skinUuid), [reaverSkin, knifeSkin]);
    expect(env.server.calls('GET /v1/skins/top').single.query, {
      'weapon': vandal,
      'period': 'week',
      'sort': 'votes',
      'limit': '50',
    });
  });

  test('media upload sends raw JPEG bytes; other files are refused', () async {
    env.server.json('POST /v1/media', {
      'key': 'm1',
      'url': 'https://val.test/v1/media/m1',
    });
    final bytes = jpegBytes();

    final media = await api.uploadMedia(mePuuid, bytes);

    expect(media.key, 'm1');
    final req = env.server.calls('POST /v1/media').single;
    expect(req.bytes, bytes);
    expect(req.headers[Headers.contentTypeHeader], 'image/jpeg');
    await expectLater(
      api.uploadMedia(mePuuid, jpegBytes()..[0] = 0),
      throwsA(
        isA<CommunityException>().having(
          (e) => e.code,
          'code',
          CommunityException.imageType,
        ),
      ),
    );
    expect(imageMimeType([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]), 'image/png');
    expect(imageMimeType('RIFF0000WEBP'.codeUnits), 'image/webp');
  });

  test('creating a post sends kind, trimmed body, media and payload', () async {
    env.server.on(
      'POST /v1/posts',
      (r) => FakeResponse(200, postJson('new', kind: 'store')),
    );
    const payload = PostPayload(
      date: '2026-09-28',
      offers: [PayloadOffer(skinUuid: reaverSkin, cost: 1775)],
    );
    await api.createPost(
      mePuuid,
      kind: PostKind.store,
      body: '  Shop hôm nay đẹp  ',
      media: ['m1'],
      payload: payload,
    );
    expect(env.server.calls('POST /v1/posts').single.json, {
      'kind': 'store',
      'body': 'Shop hôm nay đẹp',
      'media': ['m1'],
      'payload': {
        'date': '2026-09-28',
        'offers': [
          {'skinUuid': reaverSkin, 'cost': 1775},
        ],
      },
    });
  });

  test('transport errors map to network / timeout', () {
    final o = RequestOptions(path: '/');
    expect(
      CommunityException.fromDio(
        DioException(requestOptions: o, type: DioExceptionType.receiveTimeout),
      ).code,
      CommunityException.timeout,
    );
    expect(
      CommunityException.fromDio(
        DioException(requestOptions: o, type: DioExceptionType.connectionError),
      ).code,
      CommunityException.network,
    );
    expect(
      describeCommunityError(const CommunityException('network')).message,
      contains('Không kết nối được'),
    );
  });

  test('an unusable base URL disables the client', () async {
    expect(isUsableCommunityUrl('https://val.gianguyen.cloud'), isTrue);
    expect(isUsableCommunityUrl('http://insecure.test'), isFalse);
    expect(isUsableCommunityUrl('https://x.REPLACE.workers.dev'), isFalse);
    expect(isUsableCommunityUrl(''), isFalse);
    final disabled = CommunityHttp(dio: env.server.dio, baseUrl: '');
    await expectLater(
      disabled.send('GET', '/v1/me'),
      throwsA(
        isA<CommunityException>().having(
          (e) => e.code,
          'code',
          CommunityException.disabled,
        ),
      ),
    );
    expect(env.server.requests, isEmpty);
  });

  test('moderation / validation: the server message is shown', () async {
    env.server.json('POST /v1/posts', {
      'error': {
        'code': 'invalid_input',
        'message': 'Nội dung chứa từ ngữ không phù hợp',
      },
    }, status: 400);
    final e = await api
        .createPost(mePuuid, kind: PostKind.text, body: 'x')
        .then<Object?>((_) => null, onError: (Object e) => e);
    expect(
      describeCommunityError(e!).message,
      'Nội dung chứa từ ngữ không phù hợp',
    );
    expect(
      describeCommunityError(
        const CommunityException(CommunityException.invalidInput),
      ).message,
      'Nội dung chưa hợp lệ. Kiểm tra lại rồi thử lại.',
    );
  });

  test('a JSON null body (no own LFG post) is not an error', () async {
    env.server.json('GET /v1/lfg/mine', 'null');
    expect(await api.myLfg(mePuuid), isNull);
  });
}
