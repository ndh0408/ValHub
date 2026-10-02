import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/app/deep_links.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/post_share.dart';
import 'package:valvn/features/community/ui/feed/post_share_button.dart';

import '../community_test_env.dart';

void main() {
  test('public post link opens its route without account switching', () {
    const id = '22a03b18-0daa-461d-9a94-ad1cdb4cd817';
    final link = parseDeepLink(communityPostLink(id));
    expect(link.location, '/post/$id');
    expect(link.accountPuuid, isNull);
    expect(Uri.parse(communityPostLink(id)).query, isEmpty);
  });

  testWidgets(
    'anonymous sharing uses public text and an anchored native sheet',
    (tester) async {
      final env = await CommunityTestEnv.create(consent: false);
      String? sent;
      Rect? anchor;
      env.extraOverrides = [
        communityPostSharerProvider.overrideWithValue(({
          required text,
          required subject,
          origin,
        }) async {
          sent = text;
          anchor = origin;
        }),
      ];
      await pumpCommunity(
        tester,
        env,
        Scaffold(
          body: PostShareButton(
            post: CommunityPost.fromJson(
              postJson('p1', body: 'Bài công khai'),
            )!,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Chia sẻ'));
      await settle(tester);
      expect(sent, contains('Bài công khai'));
      expect(sent, contains('valvn://post/p1'));
      expect(sent, isNot(contains('account=')));
      expect(anchor, isNotNull);
      expect(anchor!.width, greaterThan(0));
      expect(anchor!.height, greaterThan(0));
      expect(env.server.requests, isEmpty);
      verifyNever(() => env.sessions.session(any()));
      await unmount(tester);
    },
  );

  testWidgets('sharing disables repeated taps until native sheet finishes', (
    tester,
  ) async {
    final env = await CommunityTestEnv.create(consent: false);
    final done = Completer<void>();
    var calls = 0;
    env.extraOverrides = [
      communityPostSharerProvider.overrideWithValue(({
        required text,
        required subject,
        origin,
      }) {
        calls++;
        return done.future;
      }),
    ];
    await pumpCommunity(
      tester,
      env,
      Scaffold(
        body: PostShareButton(post: CommunityPost.fromJson(postJson('p1'))!),
      ),
    );
    final action = find.byKey(const ValueKey('share-post-p1'));
    await tester.tap(action);
    await tester.pump();
    expect(tester.widget<IconButton>(action).onPressed, isNull);
    expect(calls, 1);
    done.complete();
    await settle(tester);
    expect(tester.widget<IconButton>(action).onPressed, isNotNull);
    await unmount(tester);
  });

  testWidgets('native share failure is visible and allows retry', (
    tester,
  ) async {
    final env = await CommunityTestEnv.create(consent: false);
    var calls = 0;
    env.extraOverrides = [
      communityPostSharerProvider.overrideWithValue(({
        required text,
        required subject,
        origin,
      }) async {
        if (++calls == 1) throw StateError('fixture native failure');
      }),
    ];
    await pumpCommunity(
      tester,
      env,
      Scaffold(
        body: PostShareButton(post: CommunityPost.fromJson(postJson('p1'))!),
      ),
    );
    await tester.tap(find.byTooltip('Chia sẻ'));
    await settle(tester);
    expect(find.text(CommunityStrings.errorGeneric), findsOneWidget);
    await tester.tap(find.byTooltip('Chia sẻ'));
    await settle(tester);
    expect(calls, 2);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
