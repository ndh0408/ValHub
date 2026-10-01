import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/features/community/community_previews.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';

import '../community_test_env.dart';

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  /// The Cộng đồng tab created a session earlier (the previews never sign
  /// in themselves).
  void seedSession() => env.secure.values[SecureKeys.community(mePuuid)] =
      jsonEncode(sessionJson());

  test(
    'matchingLfgPreviewProvider: 2 newest open posts fitting the rank',
    () async {
      seedSession();
      env.server.json(
        'GET /v1/lfg',
        page([
          {...lfgJson('a'), 'rankMin': 15, 'rankMax': 21},
          {...lfgJson('low'), 'rankMin': 3, 'rankMax': 8},
          lfgJson('old', left: const Duration(minutes: -1)),
          {...lfgJson('full'), 'status': 'full'},
          // Own posts are excluded. A missing list code is valid: join supplies it.
          lfgJson('mine', author: authorJson(id: meId)),
          lfgJson('no-list-code', code: ''),
          lfgJson('b'),
          lfgJson('c'),
        ]),
      );
      final container = env.container();
      final sub = container.listen(
        matchingLfgPreviewProvider(mePuuid),
        (_, _) {},
      );
      addTearDown(sub.close);

      final posts = await container.read(
        matchingLfgPreviewProvider(mePuuid).future,
      );

      expect(posts.map((p) => p.id), ['a', 'no-list-code']);
      final q = env.server.calls('GET /v1/lfg').single.query;
      expect((q['region'], q['rank']), ('ap', '18'));
    },
  );

  test('matchingLfgPreviewProvider never signs in: no cached session, no '
      'request', () async {
    env.server.json('GET /v1/lfg', page([lfgJson('a')]));
    final container = env.container();
    final sub = container.listen(
      matchingLfgPreviewProvider(mePuuid),
      (_, _) {},
    );
    addTearDown(sub.close);

    final posts = await container.read(
      matchingLfgPreviewProvider(mePuuid).future,
    );

    expect(posts, isEmpty);
    expect(env.server.requests, isEmpty);
    expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
    verifyNever(() => env.sessions.session(any()));
  });

  test('trendingSkinsProvider: this week, read-only (no sign-in)', () async {
    env.server.json('GET /v1/skins/top', {
      'items': [
        {
          'rank': 1,
          'skinUuid': reaverSkin,
          'votes': 30,
          'ratingAvg': 4.4,
          'ratingCount': 5,
        },
      ],
    });
    final container = env.container();
    final sub = container.listen(
      trendingSkinsProvider(TopPeriod.week),
      (_, _) {},
    );
    addTearDown(sub.close);

    final rows = await container.read(
      trendingSkinsProvider(TopPeriod.week).future,
    );

    expect(rows.single.skinUuid, reaverSkin);
    final req = env.server.calls('GET /v1/skins/top').single;
    expect(req.query['period'], 'week');
    expect(req.authorization, isNull);
    expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
  });

  testWidgets('compact cards render and open their targets', (tester) async {
    seedSession();
    env.server
      ..json(
        'GET /v1/lfg',
        page([lfgJson('a', author: authorJson(name: 'Đồng Đội'))]),
      )
      ..json('GET /v1/skins/top', {
        'items': [
          {
            'rank': 1,
            'skinUuid': reaverSkin,
            'votes': 30,
            'ratingAvg': 4.4,
            'ratingCount': 5,
          },
        ],
      });
    String? opened;
    await pumpCommunityRouter(
      tester,
      env,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Column(
              children: [
                LfgPreviewCard(puuid: mePuuid),
                TrendingSkinsCard(),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/community/skin/:uuid',
          builder: (context, state) {
            opened = state.pathParameters['uuid'];
            return const Scaffold(body: Text('review page'));
          },
        ),
      ],
    );
    await settle(tester);

    expect(find.text(CommunityStrings.lfgPreviewTitle), findsOneWidget);
    expect(find.text('Đồng Đội#VN2'), findsOneWidget);
    expect(find.text(CommunityStrings.trendingTitle), findsOneWidget);
    expect(find.text('4,4'), findsOneWidget);

    await tester.tap(find.text('Vandal Reaver'));
    await settle(tester, frames: 30);
    expect(opened, reaverSkin);
    await unmount(tester);
  });

  testWidgets('cards hide themselves when there is nothing to show', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/lfg', page([]))
      ..json('GET /v1/skins/top', {'items': <Object>[]});
    await pumpCommunity(
      tester,
      env,
      const Scaffold(
        body: Column(
          children: [
            LfgPreviewCard(puuid: mePuuid),
            TrendingSkinsCard(),
          ],
        ),
      ),
    );
    await settle(tester);
    expect(find.text(CommunityStrings.lfgPreviewTitle), findsNothing);
    expect(find.text(CommunityStrings.trendingTitle), findsNothing);
    await unmount(tester);
  });
}
