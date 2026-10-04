import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/skin_review_providers.dart';
import 'package:valvn/features/community/providers/skin_vote_providers.dart';

import '../community_test_env.dart';

Map<String, Object?> reviewJson(
  String id, {
  int rating = 4,
  String body = 'Đẹp',
  Map<String, Object?>? author,
  int likes = 0,
  bool liked = false,
  bool mine = false,
}) => {
  'id': id,
  'skinUuid': reaverSkin,
  'author': author ?? authorJson(),
  'rating': rating,
  'body': body,
  'likes': likes,
  'liked': liked,
  'mine': mine,
  'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
  'updatedAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
};

Map<String, Object?> summaryJson({
  double? avg = 4.6,
  int count = 128,
  List<int> dist = const [2, 3, 10, 30, 83],
  Map<String, Object?>? myReview,
  int votes = 40,
  bool voted = false,
}) => {
  'skinUuid': reaverSkin,
  'weaponUuid': vandal,
  'votes': votes,
  'voted': voted,
  'ratingAvg': avg,
  'ratingCount': count,
  'distribution': dist,
  'reviewCount': 57,
  'myReview': myReview,
};

void main() {
  group('parsing', () {
    test('SkinReview clamps the rating and never crashes', () {
      final r = SkinReview.fromJson(reviewJson('r1', rating: 9, mine: true))!;
      expect(r.rating, 5);
      expect(r.mine, isTrue);
      expect(SkinReview.fromJson({'id': 'x'}), isNull, reason: 'no rating');
      expect(SkinReview.fromJson('<html>'), isNull);
      final liked = r.toggledLike();
      expect((liked.liked, liked.likes), (true, 1));
    });

    test('SkinSummary: rating, 5-bar distribution, own review', () {
      final s = SkinSummary.fromJson(
        summaryJson(myReview: reviewJson('mine', mine: true)),
        reaverSkin,
      );
      expect(s.rating.average, 4.6);
      expect(s.rating.count, 128);
      expect(s.rating.reviewCount, 57);
      expect(s.distribution, [2, 3, 10, 30, 83]);
      expect(s.share(5), closeTo(83 / 128, 1e-9));
      expect(s.myReview?.id, 'mine');
      expect(s.vote?.votes, 40);
    });

    test('odd summaries: no ratings, short distribution, garbage', () {
      final s = SkinSummary.fromJson({
        'ratingAvg': null,
        'distribution': [1, 'x'],
      }, reaverSkin.toUpperCase());
      expect(s.skinUuid, reaverSkin);
      expect(s.rating.hasRatings, isFalse);
      expect(s.distribution, [1, 0, 0, 0, 0]);
      expect(s.share(3), 0);
      expect(SkinSummary.fromJson('<html>', reaverSkin).rating.count, 0);
    });

    test('formatRating uses one decimal and a comma', () {
      expect(formatRating(4.56), '4,6');
      expect(formatRating(5), '5,0');
      expect(
        SkinRating.fromJson({'ratingAvg': 7, 'ratingCount': 1}).average,
        5,
      );
    });

    test('TopSkin carries the rating', () {
      final t = TopSkin.fromJson({
        'skinUuid': reaverSkin,
        'votes': 3,
        'ratingAvg': 3.25,
        'ratingCount': 4,
        'reviewCount': 2,
      }, 0)!;
      expect(t.rating.average, 3.25);
      expect(t.rating.reviewCount, 2);
    });
  });

  group('api', () {
    late CommunityTestEnv env;
    late ProviderContainer container;
    late CommunityApi api;

    setUp(() async {
      env = await CommunityTestEnv.create();
      container = env.container();
      api = container.read(communityApiProvider);
    });

    test('summary and reviews (optional auth), sort query', () async {
      env.server
        ..json('GET /v1/skins/*/summary', summaryJson())
        ..json('GET /v1/skins/*/reviews', page([reviewJson('r1')], next: 'c2'));

      final s = await api.skinSummary(reaverSkin, puuid: mePuuid);
      final p = await api.skinReviews(
        reaverSkin,
        puuid: mePuuid,
        sort: ReviewSort.top,
      );

      expect(s.rating.count, 128);
      expect(p.items.single.id, 'r1');
      expect(p.hasMore, isTrue);
      final req = env.server.calls('GET /v1/skins/*/reviews').single;
      expect(req.query, {'sort': 'top', 'limit': '20'});
      expect(req.path, '/v1/skins/$reaverSkin/reviews');
    });

    test('optional auth falls back to anonymous when sign-in fails', () async {
      env.server.json('GET /v1/skins/*/summary', summaryJson());
      env.server.on(
        'POST /v1/auth/riot',
        (_) => const FakeResponse(503, '<html>down</html>'),
      );

      final s = await api.skinSummary(reaverSkin, puuid: mePuuid);

      expect(s.rating.average, 4.6);
      expect(
        env.server.calls('GET /v1/skins/*/summary').single.authorization,
        isNull,
      );
    });

    test('put / delete own review, like / unlike, delete by id', () async {
      env.server
        ..json('PUT /v1/skins/*/review', reviewJson('mine', rating: 5))
        ..json('DELETE /v1/skins/*/review', null, status: 204)
        ..json('PUT /v1/reviews/*/like', {'likes': 3, 'liked': true})
        ..json('DELETE /v1/reviews/*', null, status: 204);

      final r = await api.putReview(
        mePuuid,
        reaverSkin,
        rating: 5,
        body: '  Tuyệt  ',
        weaponUuid: vandal,
      );
      expect(r.rating, 5);
      expect(env.server.calls('PUT /v1/skins/*/review').single.json, {
        'weaponUuid': vandal,
        'accessToken': 'riot-access-1',
        'rating': 5,
        'body': 'Tuyệt',
      });
      await api.putReview(mePuuid, reaverSkin, rating: 2);
      expect(env.server.calls('PUT /v1/skins/*/review').last.json, {
        'accessToken': 'riot-access-1',
        'rating': 2,
      }, reason: 'empty text is not sent');
      await api.deleteMyReview(mePuuid, reaverSkin);
      final like = await api.setReviewLiked(mePuuid, 'r9', liked: true);
      expect(like, (likes: 3, liked: true));
      await api.deleteReview(mePuuid, 'r9');
      expect(
        env.server.calls('DELETE /v1/reviews/*').single.path,
        '/v1/reviews/r9',
      );
    });

    test('owner proof uses a fresh Riot token and retries one real rejection, never sends PUUID', () async {
      when(
        () => env.sessions.refreshAfterAuthFailure(
          mePuuid,
          failedAccessToken: 'riot-access-1',
        ),
      ).thenAnswer((_) async => riotSession(token: 'riot-access-2'));
      var calls = 0;
      env.server.on(
        'PUT /v1/skins/*/review',
        (r) => ++calls == 1
            ? const FakeResponse(401, {
                'error': {'code': 'riot_rejected'},
              })
            : FakeResponse(200, reviewJson('mine')),
      );
      await api.putReview(mePuuid, reaverSkin, rating: 5, weaponUuid: vandal);
      final requests = env.server.calls('PUT /v1/skins/*/review');
      expect(requests, hasLength(2));
      expect((requests.first.json as Map)['accessToken'], 'riot-access-1');
      expect((requests.last.json as Map)['accessToken'], 'riot-access-2');
      expect((requests.last.json as Map).containsKey('puuid'), isFalse);
      expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
    });

    test('top skins by rating; votes endpoint carries ratings', () async {
      env.server
        ..json('GET /v1/skins/top', {
          'items': [
            {
              'rank': 1,
              'skinUuid': knifeSkin,
              'votes': 2,
              'ratingAvg': 4.9,
              'ratingCount': 12,
            },
          ],
        })
        ..json('GET /v1/skins/votes', {
          'items': [
            {
              'skinUuid': reaverSkin,
              'votes': 5,
              'ratingAvg': 4.2,
              'ratingCount': 9,
            },
          ],
        });
      final top = await api.topSkins(puuid: mePuuid, sort: TopSort.rating);
      expect(top.single.rating.average, 4.9);
      expect(
        env.server.calls('GET /v1/skins/top').single.query['sort'],
        'rating',
      );
      final stats = await api.skinVotes([reaverSkin]);
      expect(stats[reaverSkin]?.rating.count, 9);
    });
  });

  group('providers', () {
    late CommunityTestEnv env;
    late ProviderContainer container;

    setUp(() async {
      env = await CommunityTestEnv.create();
      container = env.container();
    });

    test('validateReview', () {
      expect(validateReview(rating: 0, body: ''), ReviewProblem.noRating);
      expect(validateReview(rating: 6, body: ''), ReviewProblem.noRating);
      expect(validateReview(rating: 3, body: 'a' * 501), ReviewProblem.tooLong);
      expect(validateReview(rating: 3, body: 'ố' * 500), isNull);
    });

    test('"Hữu ích" is optimistic and reverts on failure', () async {
      final key = (
        puuid: mePuuid,
        skinUuid: reaverSkin,
        sort: ReviewSort.newest,
      );
      env.server
        ..json('GET /v1/skins/*/reviews', page([reviewJson('r1', likes: 1)]))
        ..json('PUT /v1/reviews/r1/like', {'likes': 7, 'liked': true});
      final sub = container.listen(skinReviewsProvider(key), (_, _) {});
      addTearDown(sub.close);
      await container.read(skinReviewsProvider(key).future);
      final n = container.read(skinReviewsProvider(key).notifier);

      final pending = n.toggleLike('r1');
      expect(
        container
            .read(skinReviewsProvider(key))
            .requireValue
            .items
            .single
            .likes,
        2,
      );
      await pending;
      expect(
        container
            .read(skinReviewsProvider(key))
            .requireValue
            .items
            .single
            .likes,
        7,
      );

      env.server.json(
        'DELETE /v1/reviews/r1/like',
        '<html>x</html>',
        status: 502,
      );
      await expectLater(n.toggleLike('r1'), throwsA(anything));
      final r = container
          .read(skinReviewsProvider(key))
          .requireValue
          .items
          .single;
      expect((r.likes, r.liked), (7, true));
    });

    test('leaderboard filters are remembered', () async {
      container.read(topSkinsFilterProvider.notifier)
        ..setSort(TopSort.reviews)
        ..setPeriod(TopPeriod.week)
        ..setWeapon(vandal);
      await Future<void>.delayed(Duration.zero);
      final fresh = env.container();
      final f = fresh.read(topSkinsFilterProvider);
      expect(
        (f.sort, f.period, f.weapon),
        (TopSort.reviews, TopPeriod.all, vandal),
      );
    });
  });
}
