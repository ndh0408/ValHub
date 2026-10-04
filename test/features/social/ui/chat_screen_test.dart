import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/social/ui/chat_screen.dart';

import '../social_test_env.dart';

ChatMessage _msg(String id, String body, DateTime at, {bool out = false}) =>
    ChatMessage(
      id: id,
      friendPuuid: friendOnline,
      outgoing: out,
      body: body,
      at: at,
    );

void main() {
  setUpAll(registerSocialFallbacks);

  late SocialTestEnv env;
  setUp(() async {
    env = await SocialTestEnv.create();
    addTearDown(env.xmpp.dispose);
    env.xmpp.seed(
      roster: [rosterEntry(friendOnline, 'Bạn Thân', tag: 'VN9')],
      presences: [
        valorantPresence(
          friendOnline,
          const PresenceSnapshot(
            loopState: LoopState.pregame,
            matchMap: '/Game/Maps/Ascent/Ascent',
          ),
        ),
      ],
    );
  });

  testWidgets('empty conversation invites a greeting', (tester) async {
    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOnline));
    await settle(tester);
    expect(env.xmpp.historyLoads, 1);
    expect(find.text('Chưa có tin nhắn. Hãy gửi lời chào!'), findsOneWidget);
    // Header: name + status, profile button.
    expect(find.textContaining('Bạn Thân'), findsOneWidget);
    expect(find.text('Đang chọn đặc vụ · Ascent'), findsOneWidget);
    expect(find.byTooltip('Xem hồ sơ'), findsOneWidget);
  });

  testWidgets('history grouped by day; incoming messages are read', (
    tester,
  ) async {
    env.xmpp.history[friendOnline] = [
      _msg('1', 'hôm qua nè', now.subtract(const Duration(days: 1))),
      _msg('2', 'chào buổi sáng', now.subtract(const Duration(hours: 1))),
      _msg(
        '3',
        'ok luôn',
        now.subtract(const Duration(minutes: 50)),
        out: true,
      ),
    ];
    env.xmpp.store.addLiveMessage(_msg('0', 'chưa đọc', now));
    expect(env.xmpp.snapshot.unread[friendOnline], 1);

    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOnline));
    await settle(tester);
    expect(find.text('Hôm qua'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);
    expect(find.text('hôm qua nè'), findsOneWidget);
    expect(find.text('chào buổi sáng'), findsOneWidget);
    expect(find.text('ok luôn'), findsOneWidget);
    expect(env.xmpp.snapshot.unread, isEmpty);

    // A live message while the chat is open is read at once.
    env.xmpp.store.addLiveMessage(_msg('9', 'mới tới', now));
    await settle(tester);
    expect(find.text('mới tới'), findsOneWidget);
    expect(env.xmpp.snapshot.unread, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sends a message', (tester) async {
    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOnline));
    await settle(tester);
    final send = find.byTooltip('Gửi');
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
    await tester.enterText(find.byType(TextField), '  gg wp  ');
    await settle(tester);
    await tester.tap(send);
    await settle(tester);
    expect(env.xmpp.sent, [(friendOnline, 'gg wp')]);
    expect(find.text('gg wp'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets(
    'unsent private draft cannot follow an account switch or logout',
    (tester) async {
      await env.prefs.setJson(PrefKeys.accounts, [
        myAccount.toJson(),
        const Account(
          puuid: friendOffline,
          gameName: 'Account B',
          tagLine: 'TEST',
          region: 'ap',
          shard: 'ap',
        ).toJson(),
      ]);
      await pumpSocial(
        tester,
        env,
        const ChatScreen(friendPuuid: friendOnline),
      );
      await settle(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChatScreen)),
      );
      await tester.enterText(
        find.byType(TextField),
        'private draft for account A',
      );
      container.read(activePuuidProvider.notifier).select(friendOffline);
      await settle(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(
        find.byType(TextField),
        'private draft for account B',
      );
      container.read(activePuuidProvider.notifier).select(null);
      await settle(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(env.xmpp.sent, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unsent draft cannot follow a change of conversation recipient', (
    tester,
  ) async {
    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOnline));
    await settle(tester);
    await tester.enterText(
      find.byType(TextField),
      'private draft for one friend',
    );
    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOffline));
    await settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(env.xmpp.sent, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a queued send cannot use a draft after the sender changes before rebuild',
    (tester) async {
      await pumpSocial(
        tester,
        env,
        const ChatScreen(friendPuuid: friendOnline),
      );
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'private account A text');
      await settle(tester);
      final send = tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.send_rounded),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed!;
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChatScreen)),
      );
      container.read(activePuuidProvider.notifier).select(friendOffline);
      send();
      await settle(tester);
      expect(env.xmpp.sent, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('input is disabled while the chat is not connected', (
    tester,
  ) async {
    env.xmpp.store.setConnection(
      const XmppConnectionState(XmppStatus.reconnecting, attempt: 1),
    );
    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOnline));
    await settle(tester);
    expect(
      find.text('Đang kết nối… Bạn có thể gửi tin khi kết nối xong.'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('history error with "Thử lại"', (tester) async {
    await pumpSocial(tester, env, const ChatScreen(friendPuuid: friendOnline));
    await settle(tester);
    env.xmpp.store.updateConversation(
      friendOnline,
      (c) => Conversation(
        friendPuuid: friendOnline,
        historyError: const TransientException(reason: 'network'),
      ),
    );
    await settle(tester);
    expect(find.text('Thử lại'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await settle(tester);
    expect(env.xmpp.historyLoads, 2);
  });
}
