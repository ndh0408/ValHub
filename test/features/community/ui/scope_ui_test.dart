import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';

import '../community_test_env.dart';

Future<void> _open(
  WidgetTester tester,
  CommunityTestEnv env, {
  String location = CommunityRoutes.root,
}) async {
  await pumpCommunityRouter(
    tester,
    env,
    routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
    initialLocation: location,
  );
  await settle(tester);
}

Map<String, String> _lastQuery(CommunityTestEnv env, String route) =>
    env.server.calls(route).last.query;

Future<void> _tapChip(WidgetTester tester, Finder chip, String list) async {
  await tester.scrollUntilVisible(
    chip,
    120,
    scrollable: find.descendant(
      of: find.byKey(ValueKey(list)),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pump();
  await tester.tap(chip);
}

void _serveCommunities(CommunityTestEnv env) {
  env.server.json('GET /v1/communities', {
    'items': [
      {'country': 'US', 'posts': 50, 'authors': 20, 'lfg': 3},
      {'country': 'JP', 'posts': 30, 'authors': 9},
      {'country': 'VN', 'posts': 5, 'authors': 4},
    ],
  });
}

void main() {
  late CommunityTestEnv env;
  setUp(() async {
    env = await CommunityTestEnv.create();
    env.server
      ..json('POST /v1/auth/riot', sessionJson(country: 'VN'))
      ..json('GET /v1/posts', page([postJson('p1')]))
      ..json('GET /v1/skins/top', {'items': <Object>[]});
  });

  group('Bảng tin', () {
    testWidgets('default: the viewer country, from the Riot account', (
      tester,
    ) async {
      await _open(tester, env);

      final q = _lastQuery(env, 'GET /v1/posts');
      expect((q['scope'], q['country']), ('country', 'VN'));
      expect(find.text('🇻🇳 Việt Nam'), findsOneWidget);
      expect(find.text(CommunityStrings.scopeRegion), findsOneWidget);
      expect(find.text(CommunityStrings.scopeGlobal), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('no country on the account: falls back to the viewer shard', (
      tester,
    ) async {
      env.server.json('POST /v1/auth/riot', sessionJson());
      await _open(tester, env);
      final q = _lastQuery(env, 'GET /v1/posts');
      expect((q['scope'], q['region']), ('region', 'ap'));
      expect(find.text(CommunityStrings.scopeCountry), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('Khu vực → region, Quốc tế → global; remembered', (
      tester,
    ) async {
      await _open(tester, env);

      await tester.tap(find.text(CommunityStrings.scopeRegion));
      await settle(tester);
      var q = _lastQuery(env, 'GET /v1/posts');
      expect((q['scope'], q['region']), ('region', 'ap'));

      await tester.tap(find.text(CommunityStrings.scopeGlobal));
      await settle(tester);
      q = _lastQuery(env, 'GET /v1/posts');
      expect(q['scope'], 'global');
      expect(q.containsKey('language'), isFalse);
      expect(
        env.prefs.getString(PrefKeys.ui('community.feed.scope')),
        'global',
      );
      await unmount(tester);

      // A later launch keeps the choice.
      await _open(tester, env);
      expect(_lastQuery(env, 'GET /v1/posts')['scope'], 'global');
      await unmount(tester);
    });

    testWidgets('a shard menu picks any region', (tester) async {
      await _open(tester, env);
      await tester.tap(find.text(CommunityStrings.scopeRegion));
      await settle(tester);

      await tester.tap(find.text(CommunityStrings.regionLabel('ap')).last);
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.regionLabel('kr')).last);
      await settle(tester);

      final q = _lastQuery(env, 'GET /v1/posts');
      expect((q['scope'], q['region']), ('region', 'kr'));
      await unmount(tester);
    });

    testWidgets('international: multi-language filter', (tester) async {
      await _open(tester, env);
      await tester.tap(find.text(CommunityStrings.scopeGlobal));
      await settle(tester);

      await tester.tap(find.byKey(const ValueKey('scope-languages-feed')));
      await settle(tester);
      for (final code in ['ja', 'vi']) {
        final row = find.byKey(ValueKey('filter-lang-$code'));
        await tester.ensureVisible(row);
        await tester.pump();
        await tester.tap(row);
        await tester.pump();
      }
      await tester.tap(find.text(CommunityStrings.apply));
      await settle(tester);

      final q = _lastQuery(env, 'GET /v1/posts');
      expect((q['scope'], q['language']), ('global', 'ja,vi'));
      expect(find.text('2 ngôn ngữ'), findsOneWidget);
      expect(
        env.prefs.getString(PrefKeys.ui('community.feed.languages')),
        'ja,vi',
      );
      await unmount(tester);
    });

    testWidgets('"Cộng đồng các nước": flags, counts, accent-folding search', (
      tester,
    ) async {
      _serveCommunities(env);
      await _open(tester, env);

      await _tapChip(
        tester,
        find.byKey(const ValueKey('scope-countries-feed')),
        'scope-actions-feed',
      );
      await settle(tester);

      expect(find.text(CommunityStrings.countriesTitle), findsWidgets);
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('Hoa Kỳ'), findsOneWidget);
      expect(find.textContaining('50 bài · 20 người'), findsOneWidget);
      expect(find.textContaining('3 tin tìm đồng đội'), findsOneWidget);
      // Own country first and marked.
      expect(find.textContaining(CommunityStrings.yourCountry), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'nhat ban');
      await settle(tester);
      expect(find.text('Nhật Bản'), findsOneWidget);
      expect(find.text('Hoa Kỳ'), findsNothing);

      await tester.tap(find.text('Nhật Bản'));
      await settle(tester, frames: 30);

      final q = _lastQuery(env, 'GET /v1/posts');
      expect((q['scope'], q['country']), ('country', 'JP'));
      expect(find.text('🇯🇵 Nhật Bản'), findsOneWidget);
      expect(env.prefs.getString(PrefKeys.ui('community.feed.country')), 'JP');

      // "Về nước bạn" resets to the viewer's country.
      await tester.tap(find.text(CommunityStrings.backToMyCountry));
      await settle(tester);
      expect(_lastQuery(env, 'GET /v1/posts')['country'], 'VN');
      await unmount(tester);
    });

    testWidgets('the picker offers own country even when nothing is active', (
      tester,
    ) async {
      env.server.json('GET /v1/communities', {'items': <Object>[]});
      await _open(tester, env);
      await _tapChip(
        tester,
        find.byKey(const ValueKey('scope-countries-feed')),
        'scope-actions-feed',
      );
      await settle(tester);
      expect(find.text('Việt Nam'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('authors show their country flag', (tester) async {
      env.server.json(
        'GET /v1/posts',
        page([postJson('p1', author: authorJson(country: 'JP'))]),
      );
      await _open(tester, env);
      expect(find.text('🇯🇵'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('after switching, items of the old scope are not shown', (
      tester,
    ) async {
      env.server.on(
        'GET /v1/posts',
        (r) => FakeResponse(
          200,
          page([
            postJson(
              r.query['scope'] == 'global' ? 'g' : 'c',
              body: r.query['scope'] == 'global'
                  ? 'bài quốc tế'
                  : 'bài nước bạn',
            ),
          ]),
        ),
      );
      await _open(tester, env);
      expect(find.text('bài nước bạn'), findsOneWidget);

      await tester.tap(find.text(CommunityStrings.scopeGlobal));
      await settle(tester);

      expect(find.text('bài quốc tế'), findsOneWidget);
      expect(find.text('bài nước bạn'), findsNothing);
      await unmount(tester);
    });

    testWidgets('empty scope: friendly copy', (tester) async {
      env.server.json('GET /v1/posts', page([]));
      await _open(tester, env);
      expect(find.text(CommunityStrings.feedEmptyScopeTitle), findsOneWidget);
      await unmount(tester);
    });
  });

  group('Xếp hạng skin', () {
    testWidgets(
      'toggle Nước bạn / Khu vực / Toàn cầu, remembered per section',
      (tester) async {
        await _open(tester, env, location: '/community?section=skins');
        var q = _lastQuery(env, 'GET /v1/skins/top');
        expect((q['scope'], q['country']), ('country', 'VN'));

        await tester.tap(find.text(CommunityStrings.scopeRegion));
        await settle(tester);
        q = _lastQuery(env, 'GET /v1/skins/top');
        expect((q['scope'], q['region']), ('region', 'ap'));

        await tester.tap(find.text(CommunityStrings.scopeWorldwide));
        await settle(tester);
        expect(_lastQuery(env, 'GET /v1/skins/top')['scope'], 'global');
        expect(
          env.prefs.getString(PrefKeys.ui('community.skins.scope')),
          'global',
        );
        // The feed keeps its own choice.
        expect(
          env.prefs.getString(PrefKeys.ui('community.feed.scope')),
          isNull,
        );
        await unmount(tester);
      },
    );
  });

  group('Tìm đồng đội', () {
    testWidgets('explains that only the same shard can join', (tester) async {
      env.server.json('GET /v1/lfg', page([]));
      await _open(tester, env, location: '/community?section=lfg');
      expect(find.text(CommunityStrings.lfgSameShardNote), findsOneWidget);
      final q = _lastQuery(env, 'GET /v1/lfg');
      expect((q['scope'], q['region']), ('region', 'ap'));
      await unmount(tester);
    });

    testWidgets('another shard: a stronger warning', (tester) async {
      env.server.json('GET /v1/lfg', page([]));
      await _open(tester, env, location: '/community?section=lfg');
      await tester.tap(find.byTooltip(CommunityStrings.region));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.regionLabel('eu')).last);
      await settle(tester);
      expect(
        find.text(
          CommunityStrings.lfgOtherShardNote(
            CommunityStrings.regionLabel('eu'),
          ),
        ),
        findsOneWidget,
      );
      expect(_lastQuery(env, 'GET /v1/lfg')['region'], 'eu');
      await unmount(tester);
    });

    testWidgets('language filter in the LFG filter bar', (tester) async {
      env.server.json('GET /v1/lfg', page([]));
      await _open(tester, env, location: '/community?section=lfg');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('lfg-language-filter')),
        120,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('lfg-filters')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('lfg-language-filter')));
      await settle(tester);
      await tester.tap(find.text('日本語').last);
      await settle(tester);
      expect(_lastQuery(env, 'GET /v1/lfg')['language'], 'ja');
      await unmount(tester);
    });
  });

  for (final light in [false, true]) {
    testWidgets(
      'no overflow at 360 dp × 2.0 with the scope bar (${light ? 'light' : 'dark'})',
      (tester) async {
        _serveCommunities(env);
        await pumpCommunityRouter(
          tester,
          env,
          routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
          initialLocation: CommunityRoutes.root,
          size: const Size(360, 2000),
          textScale: 2,
        );
        await settle(tester);
        await tester.tap(find.text(CommunityStrings.scopeGlobal));
        await settle(tester);
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );
  }
}
