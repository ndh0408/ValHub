import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart';

import '../community_test_env.dart';

Map<String, Object?> applied(String scope, {String? country, String? region}) =>
    {'scope': scope, 'country': country, 'region': region};

void main() {
  group('AppliedScope.fromJson', () {
    test('the three scopes, with their target', () {
      expect(
        AppliedScope.fromJson(applied('country', country: 'VN')),
        const AppliedScope(scope: CommunityScope.country, country: 'VN'),
      );
      expect(
        AppliedScope.fromJson(applied('region', region: 'ap')),
        const AppliedScope(scope: CommunityScope.region, region: 'ap'),
      );
      expect(AppliedScope.fromJson(applied('global')), AppliedScope.global);
    });

    test('codes are normalised; foreign fields of the scope are dropped', () {
      expect(
        AppliedScope.fromJson(applied('country', country: 'vn', region: 'ap')),
        const AppliedScope(scope: CommunityScope.country, country: 'VN'),
      );
      expect(
        AppliedScope.fromJson(applied('region', country: 'VN', region: 'EU')),
        const AppliedScope(scope: CommunityScope.region, region: 'eu'),
      );
      expect(
        AppliedScope.fromJson(applied('global', country: 'VN', region: 'ap')),
        AppliedScope.global,
      );
    });

    test('anything odd is "not told", never a crash', () {
      for (final bad in <Object?>[
        null,
        'global',
        42,
        <Object>[],
        <String, Object?>{},
        {'scope': 'planet'},
        {'scope': null},
        // A country scope always names its country.
        {'scope': 'country'},
        {'scope': 'country', 'country': 'nope'},
      ]) {
        expect(AppliedScope.fromJson(bad), isNull, reason: '$bad');
      }
      // An unknown shard keeps the scope, without a region.
      expect(
        AppliedScope.fromJson(applied('region', region: 'mars')),
        const AppliedScope(scope: CommunityScope.region),
      );
    });

    test('matches: did the server apply what was asked?', () {
      const vn = AppliedScope(scope: CommunityScope.country, country: 'VN');
      expect(vn.matches(ScopeFilter.mineCountry), isTrue);
      expect(
        vn.matches(
          const ScopeFilter(scope: CommunityScope.country, country: 'VN'),
        ),
        isTrue,
      );
      expect(
        vn.matches(
          const ScopeFilter(scope: CommunityScope.country, country: 'JP'),
        ),
        isFalse,
      );
      // Fell back to the shard.
      expect(
        const AppliedScope(
          scope: CommunityScope.region,
          region: 'ap',
        ).matches(ScopeFilter.mineCountry),
        isFalse,
      );
      expect(AppliedScope.global.matches(ScopeFilter.global), isTrue);
    });
  });

  group('lists carry appliedScope', () {
    test('CommunityPage', () {
      final p = CommunityPage.fromJson({
        'items': [
          {'id': 'x'},
        ],
        'nextCursor': 'c2',
        'appliedScope': applied('region', region: 'na'),
      }, (e) => e);
      expect(p.items, hasLength(1));
      expect(
        p.applied,
        const AppliedScope(scope: CommunityScope.region, region: 'na'),
      );
      // Older server / bare list: no applied scope.
      expect(
        CommunityPage.fromJson({'items': <Object>[]}, (e) => e).applied,
        isNull,
      );
      expect(CommunityPage.fromJson([1, 2], (e) => e).applied, isNull);
    });

    test('PagedState keeps it through refresh, append and copyWith', () {
      const first = AppliedScope(scope: CommunityScope.global);
      final s = PagedState<String>.fromPage(
        const CommunityPage(['a'], nextCursor: 'n', applied: first),
        tag: 'x',
      );
      expect(s.applied, first);
      expect(s.copyWith(loadingMore: true).applied, first);
      // A later page without one keeps the first; one with it replaces it.
      expect(s.append(const CommunityPage(['b']), (i) => i).applied, first);
      const region = AppliedScope(scope: CommunityScope.region, region: 'ap');
      expect(
        s.append(const CommunityPage(['c'], applied: region), (i) => i).applied,
        region,
      );
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

    test('feed, LFG and review lists', () async {
      env.server
        ..json('GET /v1/posts', {
          ...page([postJson('p1')]),
          'appliedScope': applied('country', country: 'VN'),
        })
        ..json('GET /v1/lfg', {
          ...page([lfgJson('l1')]),
          'appliedScope': applied('region', region: 'ap'),
        })
        ..json('GET /v1/skins/*/reviews', {
          ...page([]),
          'appliedScope': applied('global'),
        });

      final posts = await api.posts(mePuuid, scope: ScopeFilter.mineCountry);
      final lfg = await api.lfg(mePuuid, region: 'ap');
      final reviews = await api.skinReviews(reaverSkin, puuid: mePuuid);

      expect(
        posts.applied,
        const AppliedScope(scope: CommunityScope.country, country: 'VN'),
      );
      expect(lfg.applied?.region, 'ap');
      expect(reviews.applied, AppliedScope.global);
    });

    test('skins top: rows + applied, topSkins still a plain list', () async {
      env.server.json('GET /v1/skins/top', {
        'items': [
          {'rank': 1, 'skinUuid': reaverSkin, 'votes': 9},
        ],
        'appliedScope': applied('region', region: 'ap'),
      });

      final result = await api.topSkinsResult(puuid: mePuuid);
      final rows = await api.topSkins(puuid: mePuuid);

      expect(result.rows.single.skinUuid, reaverSkin);
      expect(result.applied?.scope, CommunityScope.region);
      expect(result.applied?.region, 'ap');
      expect(rows.single.skinUuid, reaverSkin);
    });

    test('skins top without appliedScope (older server)', () async {
      env.server.json('GET /v1/skins/top', {
        'items': [
          {'rank': 1, 'skinUuid': reaverSkin, 'votes': 9},
        ],
      });
      expect((await api.topSkinsResult(puuid: mePuuid)).applied, isNull);
    });

    test('skin votes and summary', () async {
      env.server
        ..json('GET /v1/skins/votes', {
          'items': [
            {'skinUuid': reaverSkin, 'votes': 4},
          ],
          'appliedScope': applied('country', country: 'JP'),
        })
        ..json('GET /v1/skins/*/summary', {
          'skinUuid': reaverSkin,
          'votes': 4,
          'appliedScope': applied('global'),
        });

      final votes = await api.skinVotes([reaverSkin]);
      final summary = await api.skinSummary(reaverSkin, puuid: mePuuid);

      expect(votes[reaverSkin]?.applied?.country, 'JP');
      expect(summary.applied, AppliedScope.global);
      // Editing the own review keeps it.
      expect(summary.withMyReview(null).applied, AppliedScope.global);
    });

    test('LFG provider state keeps the applied scope', () async {
      env.server.json('GET /v1/lfg', {
        ...page([lfgJson('l1')]),
        'appliedScope': applied('region', region: 'ap'),
      });
      const LfgQuery q = (
        puuid: mePuuid,
        region: 'ap',
        mode: null,
        rank: null,
        role: null,
        mic: null,
        language: null,
      );
      final sub = container.listen(lfgProvider(q), (_, _) {});
      addTearDown(sub.close);

      final state = await container.read(lfgProvider(q).future);
      expect(state.applied?.region, 'ap');

      await container.read(lfgProvider(q).notifier).silentRefresh();
      expect(container.read(lfgProvider(q)).requireValue.applied?.region, 'ap');
    });
  });
}
