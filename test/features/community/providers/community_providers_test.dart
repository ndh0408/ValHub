import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/app_constants.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/features/community/data/community_exception.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/feed_providers.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart';
import 'package:valvn/features/community/providers/skin_vote_providers.dart';

import '../community_test_env.dart';

void main() {
  late CommunityTestEnv env;
  late ProviderContainer container;

  setUp(() async {
    env = await CommunityTestEnv.create();
    container = env.container();
  });

  group('base URL', () {
    test('defaults to the constant, remote config overrides it', () {
      final plain = ProviderContainer.test();
      expect(
        plain.read(communityBaseUrlProvider),
        AppConstants.communityBaseUrl,
      );
      expect(plain.read(communityEnabledProvider), isTrue);
      final remote = ProviderContainer.test(
        overrides: [
          remoteConfigProvider.overrideWithValue(
            RemoteConfig.fromJson({'communityBaseUrl': 'https://other.test'}),
          ),
        ],
      );
      expect(remote.read(communityBaseUrlProvider), 'https://other.test');
    });

    test('remote config parses, merges and serialises the key', () {
      final a = RemoteConfig.fromJson({'communityBaseUrl': 'https://a.test'});
      final b = const RemoteConfig().merge(a);
      expect(b.communityBaseUrl, 'https://a.test');
      expect(b.toJson()['communityBaseUrl'], 'https://a.test');
      expect(
        RemoteConfig.fromJson({'communityBaseUrl': 3}).communityBaseUrl,
        '3',
      );
      expect(RemoteConfig.fromJson({}).communityBaseUrl, isNull);
    });
  });

  group('feed', () {
    test('loads, pages and de-duplicates', () async {
      env.server.on(
        'GET /v1/posts',
        (r) => r.query['cursor'] == 'c2'
            ? FakeResponse(200, page([postJson('b'), postJson('c')]))
            : FakeResponse(
                200,
                page([postJson('a'), postJson('b')], next: 'c2'),
              ),
      );
      final sub = container.listen(feedProvider(mePuuid), (_, _) {});
      addTearDown(sub.close);

      final first = await container.read(feedProvider(mePuuid).future);
      expect(first.items.map((p) => p.id), ['a', 'b']);
      expect(first.canLoadMore, isTrue);

      await container.read(feedProvider(mePuuid).notifier).loadMore();
      final s = container.read(feedProvider(mePuuid)).requireValue;
      expect(s.items.map((p) => p.id), ['a', 'b', 'c']);
      expect(s.hasMore, isFalse);
    });

    test('load-more failure is kept for a retry row', () async {
      env.server.on(
        'GET /v1/posts',
        (r) => r.query['cursor'] == null
            ? FakeResponse(200, page([postJson('a')], next: 'c2'))
            : const FakeResponse(500, '<html>oops</html>'),
      );
      final sub = container.listen(feedProvider(mePuuid), (_, _) {});
      addTearDown(sub.close);
      await container.read(feedProvider(mePuuid).future);

      await container.read(feedProvider(mePuuid).notifier).loadMore();

      final s = container.read(feedProvider(mePuuid)).requireValue;
      expect(s.items, hasLength(1));
      expect(s.loadMoreError, isA<CommunityException>());
      expect(s.canLoadMore, isFalse);
    });

    test('like is optimistic and reverts on failure', () async {
      env.server
        ..json('GET /v1/posts', page([postJson('a', likes: 3)]))
        ..json('PUT /v1/posts/a/like', {'likes': 10, 'liked': true});
      final sub = container.listen(feedProvider(mePuuid), (_, _) {});
      addTearDown(sub.close);
      await container.read(feedProvider(mePuuid).future);
      final notifier = container.read(feedProvider(mePuuid).notifier);

      final pending = notifier.toggleLike('a');
      var post = container
          .read(feedProvider(mePuuid))
          .requireValue
          .items
          .single;
      expect((post.liked, post.likes), (true, 4));
      await pending;
      post = container.read(feedProvider(mePuuid)).requireValue.items.single;
      expect((post.liked, post.likes), (true, 10));

      env.server.json('DELETE /v1/posts/a/like', {
        'error': {'code': 'server_error'},
      }, status: 500);
      await expectLater(
        notifier.toggleLike('a'),
        throwsA(isA<CommunityException>()),
      );
      post = container.read(feedProvider(mePuuid)).requireValue.items.single;
      expect((post.liked, post.likes), (true, 10));
    });

    test('publishPost uploads images first, then creates the post', () async {
      env.server
        ..on('POST /v1/media', (r) {
          final n = env.server.calls('POST /v1/media').length;
          return FakeResponse(200, {
            'key': 'm$n',
            'url': 'https://val.test/m$n.jpg',
          });
        })
        ..on('POST /v1/posts', (r) => FakeResponse(200, postJson('new')));
      final api = container.read(communityApiProvider);

      final post = await publishPost(
        api,
        mePuuid,
        kind: PostKind.text,
        body: 'Ảnh đẹp',
        uploads: [
          () => api.uploadMedia(mePuuid, jpegBytes()),
          () => api.uploadMedia(mePuuid, jpegBytes(10)),
        ],
      );

      expect(post.id, 'new');
      expect(
        env.server.calls('POST /v1/posts').single.json,
        containsPair('media', ['m1', 'm2']),
      );
    });
  });

  group('comments', () {
    test('add appends; delete removes', () async {
      const key = (puuid: mePuuid, postId: 'p1');
      env.server
        ..json('GET /v1/posts/p1/comments', page([commentJson('c1')]))
        ..json('POST /v1/posts/p1/comments', commentJson('c2', body: 'Mới'))
        ..json('DELETE /v1/comments/c1', null, status: 204);
      final sub = container.listen(commentsProvider(key), (_, _) {});
      addTearDown(sub.close);
      await container.read(commentsProvider(key).future);
      final notifier = container.read(commentsProvider(key).notifier);

      await notifier.add('  Mới  ');
      expect(env.server.calls('POST /v1/posts/p1/comments').single.json, {
        'body': 'Mới',
        'language': 'vi',
      });
      await notifier.delete('c1');

      final ids = container
          .read(commentsProvider(key))
          .requireValue
          .items
          .map((c) => c.id);
      expect(ids, ['c2']);
    });
  });

  group('skin votes', () {
    test('toggle is optimistic, then takes the server answer', () async {
      env.server.json('PUT /v1/skins/*/vote', {
        'skinUuid': reaverSkin,
        'votes': 20,
        'voted': true,
      });
      final overrides = skinVoteOverridesProvider(mePuuid);
      const current = SkinVote(skinUuid: reaverSkin, votes: 5);

      final pending = container
          .read(overrides.notifier)
          .toggle(current, weaponUuid: vandal);
      expect(container.read(overrides)[reaverSkin]?.votes, 6);
      expect(container.read(overrides)[reaverSkin]?.voted, isTrue);
      await pending;
      expect(container.read(overrides)[reaverSkin]?.votes, 20);
    });

    test('toggle failure reverts', () async {
      env.server.json('DELETE /v1/skins/*/vote', {
        'error': {'code': 'rate_limited'},
        'retryAfter': 60,
      }, status: 429);
      final overrides = skinVoteOverridesProvider(mePuuid);
      const current = SkinVote(skinUuid: reaverSkin, votes: 5, voted: true);

      await expectLater(
        container.read(overrides.notifier).toggle(current),
        throwsA(isA<CommunityException>()),
      );
      expect(container.read(overrides)[reaverSkin], current);
    });

    test('the skin-sheet count never throws and never signs in', () async {
      env.server.json('GET /v1/skins/votes', '<html>down</html>', status: 503);
      final key = (puuid: mePuuid, skinUuid: reaverSkin);
      final sub = container.listen(skinVoteProvider(key), (_, _) {});
      addTearDown(sub.close);
      expect(await container.read(skinVoteProvider(key).future), isNull);
      expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
    });
  });

  group('LFG', () {
    test('lists by region / mode and refreshes silently on errors', () async {
      var fail = false;
      env.server.on(
        'GET /v1/lfg',
        (r) => fail
            ? const FakeResponse(502, '<html>bad gateway</html>')
            : FakeResponse(200, page([lfgJson('l1')])),
      );
      const LfgQuery q = (
        puuid: mePuuid,
        region: 'ap',
        mode: 'unrated',
        rank: null,
        role: null,
        mic: null,
        language: null,
      );
      final sub = container.listen(lfgProvider(q), (_, _) {});
      addTearDown(sub.close);
      await container.read(lfgProvider(q).future);
      expect(env.server.calls('GET /v1/lfg').single.query['mode'], 'unrated');

      fail = true;
      await container.read(lfgProvider(q).notifier).silentRefresh();
      final s = container.read(lfgProvider(q));
      expect(s.hasError, isFalse);
      expect(s.requireValue.items.single.id, 'l1');
    });
  });
}
