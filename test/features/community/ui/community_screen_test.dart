import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/ui/community_screen.dart';
import 'package:valvn/features/community/ui/lfg/lfg_section.dart';
import 'package:valvn/features/community/ui/post_detail_screen.dart';

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

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  group('Bảng tin', () {
    testWidgets('posts with author, rank, text, skins and images', (
      tester,
    ) async {
      env.server.json(
        'GET /v1/posts',
        page([
          postJson(
            'p1',
            body: 'Shop hôm nay quá đẹp!',
            kind: 'store',
            author: authorJson(id: meId, name: 'Tôi Là Ai', tag: 'VN1'),
            payload: {
              'date': '2026-09-28',
              'offers': [
                {'skinUuid': reaverSkin, 'cost': 1775},
                {'skinUuid': knifeSkin, 'cost': 4350},
              ],
            },
          ),
          postJson(
            'p2',
            body: 'Clip ace nè',
            likes: 7,
            media: [
              {'key': 'k1', 'url': 'https://val.test/k1.jpg'},
              {'key': 'k2', 'url': 'https://val.test/k2.jpg'},
            ],
          ),
        ]),
      );
      await _open(tester, env);

      expect(find.text(CommunityStrings.title), findsOneWidget);
      expect(find.text(CommunityStrings.sectionFeed), findsOneWidget);
      expect(find.text('Shop hôm nay quá đẹp!'), findsOneWidget);
      expect(find.text('Clip ace nè'), findsOneWidget);
      expect(find.text(CommunityStrings.you), findsOneWidget);
      expect(find.text('Vandal Reaver'), findsOneWidget);
      expect(find.text('Cửa hàng ngày 28/09'), findsOneWidget);
      expect(find.text('Tổng 6.125 VP'), findsOneWidget);
      expect(find.text('5 phút trước'), findsNWidgets(2));
      expect(find.bySemanticsLabel('Ảnh 1/2'), findsOneWidget);
      expect(find.text(CommunityStrings.newPost), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('like is optimistic with the server count after', (
      tester,
    ) async {
      env.server
        ..json('GET /v1/posts', page([postJson('p1', likes: 3)]))
        ..json('PUT /v1/posts/p1/like', {'likes': 9, 'liked': true});
      await _open(tester, env);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.like));
      await tester.pump();
      expect(find.text('4'), findsWidgets);
      await settle(tester);
      expect(find.text('9'), findsOneWidget);
      expect(env.server.calls('PUT /v1/posts/p1/like'), hasLength(1));
      await unmount(tester);
    });

    testWidgets('empty feed invites the first post', (tester) async {
      env.server.json('GET /v1/posts', page([]));
      await _open(tester, env);
      expect(find.text(CommunityStrings.feedEmptyTitle), findsOneWidget);
      expect(find.text(CommunityStrings.writePost), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('errors show Vietnamese copy and retry', (tester) async {
      var calls = 0;
      env.server.on('GET /v1/posts', (_) {
        calls++;
        return calls == 1
            ? const FakeResponse(503, '<html>maintenance</html>')
            : FakeResponse(200, page([postJson('p1', body: 'Đã ổn')]));
      });
      await _open(tester, env);
      expect(find.text(CommunityStrings.errorServer), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      await settle(tester);
      expect(find.text('Đã ổn'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a dead Riot session asks to sign in again', (tester) async {
      when(() => env.sessions.session(any()))
          .thenThrow(const NeedsLoginException(puuid: mePuuid));
      await _open(tester, env);
      expect(find.text('Đăng nhập lại'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('delete own post after confirmation', (tester) async {
      env.server
        ..json(
          'GET /v1/posts',
          page([
            postJson(
              'mine',
              body: 'Bài của tôi',
              author: authorJson(id: meId),
            ),
          ]),
        )
        ..json('DELETE /v1/posts/mine', null, status: 204);
      await _open(tester, env);

      await tester.tap(find.byTooltip(CommunityStrings.moreActions));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.deletePost));
      await settle(tester);
      expect(find.text(CommunityStrings.deletePostTitle), findsOneWidget);
      await tester.tap(find.text(CommunityStrings.delete).last);
      await settle(tester);

      expect(env.server.calls('DELETE /v1/posts/mine'), hasLength(1));
      expect(find.text('Bài của tôi'), findsNothing);
      await unmount(tester);
    });

    testWidgets('report others’ posts with a reason and a confirmation', (
      tester,
    ) async {
      env.server
        ..json('GET /v1/posts', page([postJson('p9')]))
        ..json('POST /v1/reports', null, status: 204);
      await _open(tester, env);

      await tester.tap(find.byTooltip(CommunityStrings.moreActions));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.report));
      await settle(tester);
      await tester.tap(find.text('Spam hoặc quảng cáo'));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.send));
      await settle(tester);

      expect(env.server.calls('POST /v1/reports').single.json, {
        'targetType': 'post',
        'targetId': 'p9',
        'reason': 'spam',
      });
      expect(find.text(CommunityStrings.reported), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('tapping a post opens its detail', (tester) async {
      env.server
        ..json('GET /v1/posts', page([postJson('p1', body: 'Mở tôi ra')]))
        ..json('GET /v1/posts/p1', postJson('p1', body: 'Mở tôi ra'))
        ..json('GET /v1/posts/p1/comments', page([commentJson('c1')]));
      await _open(tester, env);

      await tester.tap(find.text('Mở tôi ra'));
      await settle(tester);

      expect(find.byType(PostDetailScreen), findsOneWidget);
      expect(find.text('Hay quá'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('Tìm đồng đội', () {
    testWidgets('cards, pinned own post, join with confirmation', (
      tester,
    ) async {
      env.server.json(
        'GET /v1/lfg',
        page([
          lfgJson(
            'mine',
            author: authorJson(id: meId),
            code: 'MINE12',
          ),
          lfgJson('l1', note: 'Cần 1 Controller, có mic'),
        ]),
      );
      when(() => env.pvp.partyJoinByCode(any(), any()))
          .thenAnswer((_) async => {});
      await _open(tester, env, location: '/community?section=lfg');

      expect(find.text(CommunityStrings.removeLfg), findsOneWidget);
      expect(find.text('Mã tổ đội: MINE12'), findsOneWidget);
      expect(find.text('Cần 1 Controller, có mic'), findsOneWidget);
      expect(find.text('Cần 2 người'), findsWidgets);
      expect(find.text('Còn 24:00'), findsWidgets);
      expect(find.text('Xếp hạng'), findsWidgets);

      await tester.tap(find.text(CommunityStrings.joinParty));
      await settle(tester);
      expect(find.text(CommunityStrings.joinConfirmTitle), findsOneWidget);
      verifyNever(() => env.pvp.partyJoinByCode(any(), any()));

      await tester.tap(find.text(CommunityStrings.join));
      await settle(tester);
      verify(() => env.pvp.partyJoinByCode(mePuuid, 'ABC123')).called(1);
      expect(find.text(CommunityStrings.joined), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('join errors are explained (game not running)', (tester) async {
      env.server.json('GET /v1/lfg', page([lfgJson('l1')]));
      when(() => env.pvp.partyJoinByCode(any(), any()))
          .thenThrow(const NotFoundException(errorCode: 'RESOURCE_NOT_FOUND'));
      await _open(tester, env, location: '/community?section=lfg');

      await tester.tap(find.text(CommunityStrings.joinParty));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.join));
      await settle(tester);
      expect(find.text(CommunityStrings.joinGameNotRunning), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('filters: mode chip refetches, auto refresh every 20 s', (
      tester,
    ) async {
      env.server.json('GET /v1/lfg', page([lfgJson('l1')]));
      await _open(tester, env, location: '/community?section=lfg');
      expect(env.server.calls('GET /v1/lfg'), hasLength(1));

      final chip = find.widgetWithText(ChoiceChip, 'Đấu thường');
      await tester.scrollUntilVisible(
        chip,
        120,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('lfg-filters')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.ensureVisible(chip);
      await tester.pump();
      await tester.tap(chip);
      await settle(tester);
      final calls = env.server.calls('GET /v1/lfg');
      expect(calls.last.query['mode'], 'unrated');
      final before = calls.length;

      await tester.pump(const Duration(seconds: 21));
      await settle(tester);
      expect(env.server.calls('GET /v1/lfg').length, greaterThan(before));
      await unmount(tester);
    });

    testWidgets('empty list invites to post', (tester) async {
      env.server.json('GET /v1/lfg', page([]));
      await _open(tester, env, location: '/community?section=lfg');
      expect(find.text(CommunityStrings.lfgEmptyTitle), findsOneWidget);
      await unmount(tester);
    });

    test('join error mapping', () {
      expect(
        joinErrorMessage(const NotFoundException(errorCode: 'PARTY_NOT_FOUND')),
        CommunityStrings.joinInvalidCode,
      );
      expect(
        joinErrorMessage(const RiotApiException(409)),
        CommunityStrings.joinInvalidCode,
      );
      expect(
        joinErrorMessage(const NotFoundException()),
        CommunityStrings.joinGameNotRunning,
      );
    });
  });

  group('Xếp hạng skin', () {
    testWidgets('leaderboard with an optimistic heart', (tester) async {
      env.server
        ..json('GET /v1/skins/top', {
          'items': [
            {
              'rank': 1,
              'skinUuid': reaverSkin,
              'weaponUuid': vandal,
              'votes': 12,
            },
            {'rank': 2, 'skinUuid': knifeSkin, 'votes': 4, 'voted': true},
          ],
        })
        ..json('PUT /v1/skins/*/vote', {
          'skinUuid': reaverSkin,
          'votes': 30,
          'voted': true,
        });
      await _open(tester, env, location: '/community?section=skins');

      expect(find.text('Vandal Reaver'), findsOneWidget);
      expect(find.text('Dao Đặc Nhiệm 809'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.vote).first);
      await tester.pump();
      expect(find.text('13'), findsWidgets);
      await settle(tester);
      expect(find.text('30'), findsOneWidget);
      expect(env.server.calls('PUT /v1/skins/*/vote').single.json, {
        'weaponUuid': vandal,
      });
      await unmount(tester);
    });

    testWidgets('period toggle and weapon chips refetch', (tester) async {
      env.server.json('GET /v1/skins/top', {'items': <Object>[]});
      await _open(tester, env, location: '/community?section=skins');
      expect(find.text(CommunityStrings.skinsEmptyTitle), findsOneWidget);

      await tester.tap(find.text(CommunityStrings.periodWeek));
      await settle(tester);
      expect(
        env.server.calls('GET /v1/skins/top').last.query['period'],
        'week',
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Vandal'));
      await settle(tester);
      expect(
        env.server.calls('GET /v1/skins/top').last.query['weapon'],
        vandal,
      );
      await unmount(tester);
    });
  });

  testWidgets('switching segments keeps the capsule on screen', (tester) async {
    env.server
      ..json('GET /v1/posts', page([]))
      ..json('GET /v1/lfg', page([]))
      ..json('GET /v1/skins/top', {'items': <Object>[]});
    await _open(tester, env);
    await tester.tap(find.text(CommunityStrings.sectionLfg));
    await settle(tester);
    expect(find.text(CommunityStrings.lfgEmptyTitle), findsOneWidget);
    await tester.tap(find.text(CommunityStrings.sectionSkins));
    await settle(tester);
    expect(find.text(CommunityStrings.skinsEmptyTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('no account: friendly sign-in state, no requests', (
    tester,
  ) async {
    final signedOut = await CommunityTestEnv.create(account: null);
    await pumpCommunity(tester, signedOut, const CommunityScreen());
    await settle(tester);
    expect(find.text(CommunityStrings.noAccountTitle), findsOneWidget);
    expect(signedOut.server.requests, isEmpty);
    await unmount(tester);
  });
}
