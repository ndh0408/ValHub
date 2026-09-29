import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/skeleton.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/social/social_routes.dart';
import 'package:valvn/features/social/ui/chat_screen.dart';
import 'package:valvn/features/social/ui/friends_screen.dart';

import '../social_test_env.dart';

const _longName = 'Người Chơi Có Cái Tên Cực Kỳ Dài Để Thử Tràn Chữ';

void _seed(SocialTestEnv env) {
  env.xmpp.seed(
    roster: [
      rosterEntry(friendOnline, _longName, tag: 'LONGTAG'),
      rosterEntry(friendLobby, 'Bee', tag: '0001'),
      rosterEntry(
        friendOffline,
        'Cú Đêm',
        lastOnline: now.subtract(const Duration(hours: 2)),
      ),
    ],
    presences: [
      valorantPresence(
        friendOnline,
        const PresenceSnapshot(
          loopState: LoopState.ingame,
          matchMap: '/Game/Maps/Ascent/Ascent',
          allyScore: 8,
          enemyScore: 4,
          playerCardId: cardId,
        ),
      ),
      valorantPresence(
        friendLobby,
        const PresenceSnapshot(loopState: LoopState.menus),
      ),
    ],
  );
  for (var i = 0; i < 3; i++) {
    env.xmpp.store.addLiveMessage(
      ChatMessage(
        id: 'u$i',
        friendPuuid: friendLobby,
        outgoing: false,
        body: 'tin $i',
        at: now,
      ),
    );
  }
}

void main() {
  setUpAll(registerSocialFallbacks);

  late SocialTestEnv env;
  setUp(() async {
    env = await SocialTestEnv.create();
    addTearDown(env.xmpp.dispose);
  });

  testWidgets('shows a skeleton while the roster loads', (tester) async {
    env.xmpp.store.setConnection(
      const XmppConnectionState(XmppStatus.connecting),
    );
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    expect(find.byType(SkeletonShimmer), findsWidgets);
    expect(find.text('Bee'), findsNothing);
  });

  testWidgets('online / offline sections, status lines, unread badge, '
      'long names at 360 dp', (tester) async {
    _seed(env);
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);

    expect(find.text('Bạn bè & trò chuyện'), findsOneWidget);
    expect(find.text('Tìm theo Riot ID…'), findsOneWidget);
    // In a match → "Đang chơi"; in the lobby → "Trực tuyến".
    expect(find.text('ĐANG CHƠI (1)'), findsOneWidget);
    expect(find.text('TRỰC TUYẾN (1)'), findsOneWidget);
    expect(find.text('NGOẠI TUYẾN (1)'), findsOneWidget);
    expect(find.text('Đang đấu · Ascent · 8 – 4'), findsOneWidget);
    expect(find.text('Đang ở sảnh chờ'), findsOneWidget);
    expect(find.text('Hoạt động 2 giờ trước'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // unread badge
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick filter is remembered; "Chưa đọc" shows unread only', (
    tester,
  ) async {
    _seed(env);
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    // Test glyphs are 1 em wide: the chip row scrolls.
    await tester.ensureVisible(find.textContaining('Chưa đọc'));
    await tester.tap(find.textContaining('Chưa đọc'));
    await settle(tester);
    expect(find.textContaining('Bee'), findsOneWidget);
    expect(find.textContaining('Cú Đêm'), findsNothing);
    expect(env.prefs.getString('ui.social.friends.filter'), 'unread');

    // Reopening the screen keeps the filter.
    await tester.pumpWidget(const SizedBox());
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    expect(find.textContaining('Cú Đêm'), findsNothing);
    await tester.ensureVisible(find.text('Tất cả'));
    await tester.tap(find.text('Tất cả'));
    await settle(tester);
    expect(find.textContaining('Cú Đêm'), findsOneWidget);
  });

  testWidgets('fits 360 dp at 200 % text, dark and light', (tester) async {
    _seed(env);
    for (final theme in [buildDarkTheme(), buildLightTheme()]) {
      await pumpSocial(
        tester,
        env,
        const FriendsScreen(),
        theme: theme,
        textScale: 2,
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('ĐANG CHƠI (1)'), findsOneWidget);
    }
  });

  testWidgets('search filters by Riot ID without diacritics', (tester) async {
    _seed(env);
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'cu dem');
    await settle(tester);
    expect(find.textContaining('Cú Đêm'), findsOneWidget);
    expect(find.textContaining('Bee'), findsNothing);
    expect(find.text('TRỰC TUYẾN (1)'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await settle(tester);
    expect(find.text('Không tìm thấy bạn bè nào phù hợp.'), findsOneWidget);
  });

  testWidgets('empty roster', (tester) async {
    env.xmpp.seed();
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    expect(
      find.text(
        'Danh sách bạn bè Riot của bạn đang trống. Hãy kết bạn trong game.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('connection error before the roster: "Thử lại" retries', (
    tester,
  ) async {
    env.xmpp.store.setConnection(
      const XmppConnectionState(
        XmppStatus.failed,
        error: TransientException(reason: 'network'),
      ),
    );
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    expect(find.text('Thử lại'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await settle(tester);
    expect(env.xmpp.retries, 1);
  });

  testWidgets('needs login shows "Đăng nhập lại"', (tester) async {
    env.xmpp.store.setConnection(
      const XmppConnectionState(
        XmppStatus.needsLogin,
        error: NeedsLoginException(reason: 'x'),
      ),
    );
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    expect(find.text('Đăng nhập lại'), findsOneWidget);
  });

  testWidgets('reconnect banner keeps the list visible', (tester) async {
    _seed(env);
    env.xmpp.store.setConnection(
      const XmppConnectionState(
        XmppStatus.reconnecting,
        error: TransientException(reason: 'network'),
        attempt: 1,
      ),
    );
    await pumpSocial(tester, env, const FriendsScreen());
    await settle(tester);
    expect(
      find.text('Mất kết nối trò chuyện. Đang kết nối lại…'),
      findsOneWidget,
    );
    expect(find.text('ĐANG CHƠI (1)'), findsOneWidget);
  });

  testWidgets('tapping a friend opens the chat', (tester) async {
    _seed(env);
    await pumpSocialRouter(
      tester,
      env,
      initialLocation: SocialRoutes.friends,
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const SizedBox(),
          routes: socialRoutes,
        ),
      ],
    );
    await settle(tester);
    await tester.tap(find.textContaining('Bee'));
    await settle(tester);
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('tin 2'), findsOneWidget);
    await unmount(tester);
  });
}
