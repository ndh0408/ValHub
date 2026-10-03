import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/ui/feed/media_grid.dart';
import 'package:valvn/features/community/ui/post_detail_screen.dart';

import '../community_test_env.dart';

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  Future<void> switchAccount(WidgetTester tester) async {
    final second = Account.fromJson({
      ...meAccount.toJson(),
      'puuid': 'bbbbbbbb-0000-0000-0000-00000000000b',
      'gameName': 'Second',
    })!;
    await env.prefs.setJson(PrefKeys.accounts, [
      meAccount.toJson(),
      second.toJson(),
    ]);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PostDetailScreen)),
    );
    container.read(accountsProvider.notifier).reload();
    container.read(activePuuidProvider.notifier).select(second.puuid);
    await settle(tester);
  }

  testWidgets('comment draft is isolated when the account changes', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/posts/p1', postJson('p1'))
      ..json('GET /v1/posts/p1/comments', page([]));
    await pumpCommunity(tester, env, const PostDetailScreen(postId: 'p1'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Private comment A');
    await tester.pump();
    await switchAccount(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(env.server.calls('POST /v1/posts/p1/comments'), isEmpty);
    await unmount(tester);
  });

  testWidgets('old comment response cannot clear the next account draft', (
    tester,
  ) async {
    final gate = Completer<void>();
    env.server
      ..json('GET /v1/posts/p1', postJson('p1'))
      ..json('GET /v1/posts/p1/comments', page([]))
      ..json('POST /v1/posts/p1/comments', commentJson('new'))
      ..hold('POST /v1/posts/p1/comments', gate);
    await pumpCommunity(tester, env, const PostDetailScreen(postId: 'p1'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Private comment A');
    await tester.pump();
    await tester.tap(find.byTooltip(CommunityStrings.sendComment));
    await settle(tester);
    expect(env.server.calls('POST /v1/posts/p1/comments'), hasLength(1));
    await switchAccount(tester);
    await tester.enterText(find.byType(TextField), 'Private comment B');
    await tester.pump();
    gate.complete();
    await settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Private comment B',
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('shows the post and comments; sending appends and counts', (
    tester,
  ) async {
    env.server
      ..json(
        'GET /v1/posts/p1',
        postJson('p1', body: 'Bài chi tiết', comments: 1),
      )
      ..json(
        'GET /v1/posts/p1/comments',
        page([
          commentJson('c1', body: 'Bình luận đầu'),
          commentJson(
            'c2',
            body: 'Của tôi',
            author: authorJson(id: meId),
          ),
        ]),
      )
      ..json(
        'POST /v1/posts/p1/comments',
        commentJson('c3', body: 'Mới toanh'),
      );
    await pumpCommunity(tester, env, const PostDetailScreen(postId: 'p1'));
    await settle(tester);

    expect(find.text('Bài chi tiết'), findsOneWidget);
    expect(find.text('Bình luận đầu'), findsOneWidget);
    expect(find.text('BÌNH LUẬN · 1'), findsOneWidget);

    final send = find.byTooltip(CommunityStrings.sendComment);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.send_rounded),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField), '  Mới toanh ');
    await tester.pump();
    await tester.tap(send);
    await settle(tester);

    expect(env.server.calls('POST /v1/posts/p1/comments').single.json, {
      'body': 'Mới toanh',
      'language': 'vi',
    });
    expect(find.text('Mới toanh'), findsOneWidget);
    expect(find.text('BÌNH LUẬN · 2'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('renders the feed copy while loading and 404 as removed', (
    tester,
  ) async {
    env.server.json('GET /v1/posts/gone', {
      'error': {'code': 'not_found'},
    }, status: 404);
    await pumpCommunity(tester, env, const PostDetailScreen(postId: 'gone'));
    await settle(tester);
    expect(find.text(CommunityStrings.postNotFound), findsOneWidget);
    await unmount(tester);

    env.server
      ..on(
        'GET /v1/posts/p2',
        (_) => FakeResponse(200, postJson('p2', body: 'Từ máy chủ')),
      )
      ..json('GET /v1/posts/p2/comments', page([]));
    await pumpCommunity(
      tester,
      env,
      PostDetailScreen(
        postId: 'p2',
        initial: CommunityPost.fromJson(postJson('p2', body: 'Bản trong feed')),
      ),
    );
    expect(find.text('Bản trong feed'), findsOneWidget);
    await settle(tester);
    expect(find.text('Từ máy chủ'), findsOneWidget);
    expect(find.text(CommunityStrings.noComments), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('images open the full-screen viewer', (tester) async {
    env.server
      ..json(
        'GET /v1/posts/p3',
        postJson(
          'p3',
          media: [
            {'key': 'a', 'url': 'https://val.test/a.jpg'},
            {'key': 'b', 'url': 'https://val.test/b.jpg'},
            {'key': 'c', 'url': 'https://val.test/c.jpg'},
          ],
        ),
      )
      ..json('GET /v1/posts/p3/comments', page([]));
    await pumpCommunity(tester, env, const PostDetailScreen(postId: 'p3'));
    await settle(tester);

    await tester.tap(find.bySemanticsLabel('Ảnh 2/3'));
    await settle(tester);
    expect(find.byType(ImageViewerScreen), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsWidgets);

    await tester.tap(find.byTooltip('Đóng'));
    await settle(tester, frames: 30);
    expect(find.byType(ImageViewerScreen), findsNothing);
    await unmount(tester);
  });
}
