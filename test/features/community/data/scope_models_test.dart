import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/scope_providers.dart';
import 'package:valvn/features/community/ui/scope/scope_bar.dart';

import '../community_test_env.dart';

void main() {
  group('countries and flags', () {
    test('flagEmoji from an ISO alpha-2 code', () {
      expect(flagEmoji('VN'), '🇻🇳');
      expect(flagEmoji('jp'), '🇯🇵');
      expect(flagEmoji('XXX'), isEmpty);
      expect(flagEmoji(null), isEmpty);
    });

    test('countryCode accepts alpha-2 only, upper-cased', () {
      expect(countryCode('vn'), 'VN');
      expect(countryCode(' us '), 'US');
      expect(countryCode('vnm'), isNull);
      expect(countryCode(42), isNull);
      expect(countryCode('XK'), isNull);
      expect(countryCode('ZZ'), isNull);
      expect(countryCode('DE'), 'DE');
    });

    test('every table entry is a valid alpha-2 code with a name', () {
      for (final e in CommunityStrings.countryNames.entries) {
        expect(countryCode(e.key), e.key);
        expect(e.value, isNotEmpty);
      }
      expect(CommunityStrings.countryName('VN'), 'Việt Nam');
      expect(CommunityStrings.countryName('ZZ'), 'ZZ');
    });

    test('Author and content carry country / language (v3)', () {
      final a = CommunityAuthor.fromJson(
        authorJson(country: 'jp', language: 'ZH_tw'),
      )!;
      expect((a.country, a.language), ('JP', 'zh-TW'));
      final p = CommunityPost.fromJson({
        ...postJson('p'),
        'country': 'br',
        'region': 'BR',
        'language': 'pt',
      })!;
      expect((p.country, p.region, p.language), ('BR', 'br', 'pt'));
      final c = CommunityComment.fromJson({
        ...commentJson('c'),
        'language': 'de',
      })!;
      expect(c.language, 'de');
      final r = SkinReview.fromJson({
        'id': 'r',
        'rating': 4,
        'language': 'ko',
      })!;
      expect(r.language, 'ko');
      expect(CommunityAuthor.fromJson(authorJson())!.country, isNull);
    });

    test('CountryCommunity parses defensively', () {
      final c = CountryCommunity.fromJson({
        'country': 'vn',
        'posts': '12',
        'authors': 3,
        'lfg': null,
      })!;
      expect((c.country, c.posts, c.authors, c.lfg), ('VN', 12, 3, 0));
      expect(CountryCommunity.fromJson({'country': 'xyz'}), isNull);
      expect(CountryCommunity.fromJson({'country': 'XK'}), isNull);
      expect(CountryCommunity.fromJson({'country': 'ZZ'}), isNull);
      expect(CountryCommunity.fromJson('<html>'), isNull);
    });
  });

  group('ScopeFilter', () {
    test('query parameters', () {
      expect(
        const ScopeFilter(scope: CommunityScope.country, country: 'VN').query,
        {'scope': 'country', 'country': 'VN'},
      );
      expect(
        const ScopeFilter(scope: CommunityScope.region, region: 'kr').query,
        {'scope': 'region', 'region': 'kr'},
      );
      expect(
        const ScopeFilter(
          scope: CommunityScope.global,
          languages: {'vi', 'ja'},
        ).query,
        {'scope': 'global', 'language': 'ja,vi'},
      );
      expect(ScopeFilter.global.query, {'scope': 'global'});
      for (final invalid in ['XK', 'ZZ', 'vnm']) {
        expect(
          ScopeFilter(scope: CommunityScope.country, country: invalid).query,
          {'scope': 'country'},
        );
      }
    });

    test('equality ignores language order', () {
      expect(
        const ScopeFilter(scope: CommunityScope.global, languages: {'a', 'b'}),
        const ScopeFilter(scope: CommunityScope.global, languages: {'b', 'a'}),
      );
    });

    test('resolveScope fills in the viewer country / region', () {
      expect(
        resolveScope(ScopeFilter.mineCountry, myCountry: 'VN', myRegion: 'ap'),
        const ScopeFilter(scope: CommunityScope.country, country: 'VN'),
      );
      expect(
        resolveScope(
          const ScopeFilter(scope: CommunityScope.country, country: 'JP'),
          myCountry: 'VN',
          myRegion: 'ap',
        ).country,
        'JP',
      );
      // No country on the Riot account: the viewer's shard (spec v3).
      expect(
        resolveScope(ScopeFilter.mineCountry, myCountry: null, myRegion: 'eu'),
        const ScopeFilter(scope: CommunityScope.region, region: 'eu'),
      );
      expect(
        resolveScope(
          ScopeFilter.mineRegion,
          myCountry: 'VN',
          myRegion: 'kr',
        ).region,
        'kr',
      );
      expect(
        resolveScope(
          const ScopeFilter(scope: CommunityScope.global, languages: {'vi'}),
          myCountry: 'VN',
          myRegion: 'ap',
        ).languages,
        {'vi'},
      );
    });

    test('labels', () {
      expect(countrySegmentLabel('VN'), '🇻🇳 Việt Nam');
      expect(countrySegmentLabel(null), CommunityStrings.scopeCountry);
      expect(languageFilterLabel({}), CommunityStrings.anyLanguage);
      expect(languageFilterLabel({'ja'}), '日本語');
      expect(languageFilterLabel({'ja', 'vi'}), '2 ngôn ngữ');
    });
  });

  group('API', () {
    late CommunityTestEnv env;
    late ProviderContainer container;
    late CommunityApi api;

    setUp(() async {
      env = await CommunityTestEnv.create();
      container = env.container();
      api = container.read(communityApiProvider);
    });

    test(
      'scope memory removes XK and invalid countries before requests',
      () async {
        final provider = communityScopeProvider(ScopedSection.feed);
        final notifier = container.read(provider.notifier);
        notifier.set(
          const ScopeFilter(scope: CommunityScope.country, country: 'JP'),
        );
        expect(container.read(provider).country, 'JP');
        notifier.set(
          const ScopeFilter(scope: CommunityScope.country, country: 'XK'),
        );
        expect(container.read(provider).country, isNull);
        await Future<void>.delayed(Duration.zero);
        expect(
          env.prefs.getString(
            PrefKeys.ui(ScopeMemoryKeys.country(ScopedSection.feed)),
          ),
          isNull,
        );
        await env.prefs.setString(
          PrefKeys.ui(ScopeMemoryKeys.country(ScopedSection.feed)),
          'ZZ',
        );
        container.invalidate(provider);
        expect(container.read(provider).country, isNull);
      },
    );

    test('scope params on posts, top skins, reviews and summary', () async {
      env.server
        ..json('GET /v1/posts', page([]))
        ..json('GET /v1/skins/top', {'items': <Object>[]})
        ..json('GET /v1/skins/*/reviews', page([]))
        ..json('GET /v1/skins/*/summary', {'skinUuid': reaverSkin});
      const jp = ScopeFilter(scope: CommunityScope.country, country: 'JP');
      const global = ScopeFilter(
        scope: CommunityScope.global,
        languages: {'ja', 'ko'},
      );

      await api.posts(mePuuid, scope: jp);
      await api.topSkins(puuid: mePuuid, scope: global);
      await api.skinReviews(reaverSkin, puuid: mePuuid, scope: global);
      await api.skinSummary(reaverSkin, puuid: mePuuid, scope: jp);

      expect(env.server.calls('GET /v1/posts').single.query, {
        'scope': 'country',
        'country': 'JP',
        'limit': '20',
      });
      final top = env.server.calls('GET /v1/skins/top').single.query;
      expect((top['scope'], top['language']), ('global', 'ja,ko'));
      expect(
        env.server.calls('GET /v1/skins/*/reviews').single.query['language'],
        'ja,ko',
      );
      expect(env.server.calls('GET /v1/skins/*/summary').single.query, {
        'scope': 'country',
        'country': 'JP',
      });
    });

    test('GET /v1/communities (week), de-duplicated', () async {
      env.server.json('GET /v1/communities', {
        'items': [
          {'country': 'US', 'posts': 9, 'authors': 4, 'lfg': 1},
          {'country': 'us', 'posts': 1},
          {'country': 'nope'},
          {'country': 'VN', 'posts': 3, 'authors': 2},
        ],
      });

      final list = await api.communities(puuid: mePuuid);

      expect(list.map((c) => c.country), ['US', 'VN']);
      expect(env.server.calls('GET /v1/communities').single.query, {
        'period': 'week',
      });
    });

    test(
      'the app language is sent with sign-in, posts, comments, reviews',
      () async {
        env.server
          ..json('POST /v1/posts', postJson('p'))
          ..json('POST /v1/posts/p/comments', commentJson('c'))
          ..json('PUT /v1/skins/*/review', {'id': 'r', 'rating': 5})
          ..json('PATCH /v1/me', authorJson());

        await api.createPost(
          mePuuid,
          kind: PostKind.text,
          body: 'x',
          language: 'vi',
        );
        await api.addComment(mePuuid, 'p', 'hi', language: 'vi');
        await api.putReview(
          mePuuid,
          reaverSkin,
          rating: 5,
          body: 'tốt',
          language: 'vi',
        );
        await api.updateMe(mePuuid, language: 'ja');

        expect(
          env.server.calls('POST /v1/posts').single.json,
          containsPair('language', 'vi'),
        );
        expect(
          env.server.calls('POST /v1/posts/p/comments').single.json,
          containsPair('language', 'vi'),
        );
        expect(
          env.server.calls('PUT /v1/skins/*/review').single.json,
          containsPair('language', 'vi'),
        );
        expect(env.server.calls('PATCH /v1/me').single.json, {
          'language': 'ja',
        });
        expect(
          (env.server.calls('POST /v1/auth/riot').single.json!
              as Map)['language'],
          'vi',
        );
      },
    );

    test('a review without text does not send a language', () async {
      env.server.json('PUT /v1/skins/*/review', {'id': 'r', 'rating': 5});
      await api.putReview(mePuuid, reaverSkin, rating: 5, language: 'vi');
      expect(
        (env.server.calls('PUT /v1/skins/*/review').single.json! as Map)
            .containsKey('language'),
        isFalse,
      );
    });
  });
}
