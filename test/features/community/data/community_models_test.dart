import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/data/compose_draft.dart';

import '../community_test_env.dart';

void main() {
  group('CommunityAuthor', () {
    test('parses and builds the Riot ID', () {
      final a = CommunityAuthor.fromJson(
        authorJson(name: 'KAYN', tag: '04082', card: cardId.toUpperCase()),
      )!;
      expect(a.riotId, 'KAYN#04082');
      expect(a.cardId, cardId);
      expect(a.rankTier, 12);
    });

    test('odd bodies never crash', () {
      expect(CommunityAuthor.fromJson(null), isNull);
      expect(CommunityAuthor.fromJson('<html>'), isNull);
      expect(CommunityAuthor.fromJson({'gameName': 'x'}), isNull);
      final a = CommunityAuthor.fromJson({'id': 7, 'rankTier': '9'})!;
      expect(a.id, '7');
      expect(a.rankTier, 9);
      expect(a.riotId, isNull);
    });
  });

  group('CommunityPost', () {
    test('parses text posts with media, skipping bad entries', () {
      final p = CommunityPost.fromJson(
        postJson(
          'p1',
          likes: 5,
          liked: true,
          media: [
            {'key': 'k1', 'url': 'https://cdn.test/k1.jpg'},
            {'key': 'k2', 'url': 'javascript:alert(1)'},
            {'key': 'k3'},
          ],
        ),
      )!;
      expect(p.kind, PostKind.text);
      expect(p.media.map((m) => m.key), ['k1']);
      expect(p.likes, 5);
      expect(p.liked, isTrue);
      expect(p.createdAt, isNotNull);
      expect(p.author.gameName, 'Người Chơi');
    });

    test('store payload is parsed and capped at 6 offers', () {
      final p = CommunityPost.fromJson(
        postJson(
          'p2',
          kind: 'store',
          payload: {
            'date': '2026-09-28',
            'offers': [
              for (var i = 0; i < 8; i++)
                {'skinUuid': reaverSkin.toUpperCase(), 'cost': 1775},
              'garbage',
            ],
          },
        ),
      )!;
      expect(p.kind, PostKind.store);
      expect(p.payload!.offers, hasLength(6));
      expect(p.payload!.offers.first.skinUuid, reaverSkin);
      expect(p.payload!.dayMonth, '28/09');
      expect(p.payload!.total, 6 * 1775);
    });

    test('unknown kind, negative counts and missing fields are safe', () {
      final p = CommunityPost.fromJson({
        'id': 'x',
        'kind': 'poll',
        'likes': -3,
        'comments': '4',
        'payload': {'offers': 'nope'},
        'media': null,
      })!;
      expect(p.kind, PostKind.text);
      expect(p.likes, 0);
      expect(p.comments, 4);
      expect(p.payload, isNull);
      expect(p.media, isEmpty);
      expect(p.author.isUnknown, isTrue);
      expect(CommunityPost.fromJson([1, 2]), isNull);
    });

    test('toggledLike flips the state and the count', () {
      final p = CommunityPost.fromJson(postJson('p', likes: 1))!;
      final liked = p.toggledLike();
      expect((liked.liked, liked.likes), (true, 2));
      final back = liked.toggledLike();
      expect((back.liked, back.likes), (false, 1));
    });
  });

  test('CommunityPage parses items and cursor, tolerating bare lists', () {
    final p = CommunityPage.fromJson(
      page([postJson('a'), null, postJson('b')], next: 'c2'),
      CommunityPost.fromJson,
    );
    expect(p.items.map((e) => e.id), ['a', 'b']);
    expect(p.hasMore, isTrue);
    final bare = CommunityPage.fromJson([
      postJson('z'),
    ], CommunityPost.fromJson);
    expect(bare.items.single.id, 'z');
    expect(bare.hasMore, isFalse);
    expect(
      CommunityPage.fromJson('<html>502</html>', CommunityPost.fromJson).items,
      isEmpty,
    );
  });

  group('LfgPost', () {
    test('parses, clamps slots and uppercases the code', () {
      final p = LfgPost.fromJson(lfgJson('l1', code: 'abc123', slots: 9))!;
      expect(p.partyCode, 'ABC123');
      expect(p.hasValidCode, isTrue);
      expect(p.slots, 4);
      expect(p.isExpired(now), isFalse);
      expect(p.isExpired(now.add(const Duration(hours: 1))), isTrue);
    });

    test('party code pattern', () {
      expect(partyCodePattern.hasMatch('A1B2C3'), isTrue);
      expect(partyCodePattern.hasMatch('a1b2c3'), isFalse);
      expect(partyCodePattern.hasMatch('A1B2C'), isFalse);
      expect(partyCodePattern.hasMatch('A1B2C3D'), isFalse);
      expect(partyCodePattern.hasMatch('A1-2C3'), isFalse);
    });
  });

  test('SkinVote / TopSkin parse defensively', () {
    final v = SkinVote.fromJson({
      'skinUuid': reaverSkin.toUpperCase(),
      'votes': '12',
      'voted': 1,
    })!;
    expect((v.skinUuid, v.votes, v.voted), (reaverSkin, 12, true));
    expect(v.toggled().votes, 11);
    expect(SkinVote.fromJson({'votes': 3}), isNull);
    final t = TopSkin.fromJson({'skinUuid': knifeSkin, 'votes': 2}, 4)!;
    expect(t.rank, 5);
  });

  test('CommunitySession expiry and toString hide the token', () {
    final s = CommunitySession.fromJson(sessionJson(token: 'secret-token'))!;
    expect(s.isExpired(now), isFalse);
    expect(s.isExpired(now.add(const Duration(days: 31))), isTrue);
    expect(s.toString(), isNot(contains('secret-token')));
    expect(s.user.id, meId);
    expect(CommunitySession.fromJson({'user': <String, Object?>{}}), isNull);
  });

  test('communityRegion refuses unknown routing', () {
    expect(communityRegion('EU'), 'eu');
    expect(communityRegion('pbe'), '');
    expect(communityRegion(null), '');
  });

  group('ComposeDraft', () {
    test('daily store → store payload with skin uuids and VP costs', () {
      final daily = DailyStore.fromJson({
        'SingleItemStoreOffers': [
          {
            'OfferID': reaverLevel,
            'Cost': {'85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741': 1775},
            'Rewards': [
              {
                'ItemTypeID': 'e7c63390-eda7-46e0-bb7a-a6abdacd2433',
                'ItemID': reaverLevel,
                'Quantity': 1,
              },
            ],
          },
        ],
        'SingleItemOffersRemainingDurationInSeconds': 3600,
      }, receivedAt: now);
      final draft = ComposeDraft.fromDaily(
        daily,
        db: fixtureContent,
        now: now,
      )!;
      expect(draft.kind, PostKind.store);
      expect(draft.payload!.date, '2026-09-28');
      expect(draft.payload!.offers.single.skinUuid, reaverSkin);
      expect(draft.payload!.offers.single.cost, 1775);
      expect(draft.payload!.toJson(PostKind.store), {
        'date': '2026-09-28',
        'offers': [
          {'skinUuid': reaverSkin, 'cost': 1775},
        ],
      });
    });

    test('empty stores yield no draft', () {
      expect(
        ComposeDraft.fromDaily(
          DailyStore.fromJson(null, receivedAt: now),
          db: fixtureContent,
          now: now,
        ),
        isNull,
      );
    });

    test('night market payload keeps the discount fields', () {
      const offer = PayloadOffer(
        skinUuid: reaverSkin,
        baseCost: 1775,
        discountCost: 1100,
        discountPercent: 38,
      );
      expect(offer.price, 1100);
      expect(offer.toJson(PostKind.nightmarket), {
        'skinUuid': reaverSkin,
        'baseCost': 1775,
        'discountCost': 1100,
        'discountPercent': 38,
      });
    });

    test('isoDate uses UTC', () {
      expect(isoDate(DateTime.utc(2026, 1, 2, 23, 59)), '2026-01-02');
    });
  });
}
