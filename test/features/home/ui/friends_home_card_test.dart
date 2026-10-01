import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/ui/cards/friends_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';

import '../../social/social_test_env.dart' show FakeXmppService;
import '../home_test_env.dart';

RosterEntry _entry(Friend f) => RosterEntry(
  puuid: f.puuid,
  jid: '${f.puuid}@eu1.pvp.net',
  name: f.name,
  subscription: 'both',
);

/// A chat with [friends] online (all of them are in VALORANT).
FakeXmppService _chat(List<Friend> friends) {
  final chat = FakeXmppService();
  chat.seed(
    roster: [for (final f in friends) _entry(f)],
    presences: [
      for (final f in friends)
        if (f.presence != null) f.presence!,
    ],
  );
  return chat;
}

void main() {
  final friends = [
    homeFriend(1, 'Ngọc Anh', ally: 8, enemy: 4),
    homeFriend(2, 'Minh Khoa', loop: LoopState.pregame),
    homeFriend(3, 'Bảo Trâm', loop: LoopState.menus, queue: true),
  ];

  group('consent prompt', () {
    testWidgets('asked once, only after the startup gate', (tester) async {
      final env = await HomeTestEnv.create();
      // The store is still loading, so the startup gate stays closed.
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmWith(realFriends: true, store: const AsyncLoading()),
      );
      // Deferred: nothing yet, and no chat connection.
      expect(find.text(HomeStrings.friendsConsentTitle), findsNothing);
      expect(env.xmppCreated, 0);

      await homePastGate(tester);
      expect(find.text(HomeStrings.friendsConsentTitle), findsOneWidget);
      expect(find.text(HomeStrings.friendsConsentBody), findsOneWidget);
      expect(find.text(HomeStrings.friendsConsentAllow), findsOneWidget);
      expect(find.text(HomeStrings.friendsConsentDecline), findsOneWidget);
      // Asking does not connect: friends would see the user online.
      expect(env.xmppCreated, 0);
      await homeUnmount(tester);
    });

    testWidgets('"Bật" persists the choice and starts the chat', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      env.xmpp = _chat(friends);
      await pumpHomeScreen(tester, env, overrides: vmWith(realFriends: true));
      await homePastGate(tester);
      expect(env.xmppCreated, 0);

      await tester.tap(find.text(HomeStrings.friendsConsentAllow));
      await homeSettle(tester);

      expect(
        env.prefs.getBool(PrefKeys.account(homeMe.puuid, 'home.friendsLive')),
        isTrue,
      );
      expect(env.xmppCreated, greaterThan(0));
      // The prompt gave way to the friends who are playing.
      expect(find.text(HomeStrings.friendsConsentTitle), findsNothing);
      expect(find.text(HomeStrings.friendsPlaying(3)), findsOneWidget);
      await homeUnmount(tester);
    });

    testWidgets('"Không, ẩn thẻ" hides the card; undo brings it back', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(tester, env, overrides: vmWith(realFriends: true));
      await homePastGate(tester);

      await tester.tap(find.text(HomeStrings.friendsConsentDecline));
      await homeSettle(tester);
      expect(
        env.prefs.getBool(PrefKeys.account(homeMe.puuid, 'home.friendsLive')),
        isFalse,
      );
      expect(find.text(HomeStrings.friendsConsentTitle), findsNothing);
      expect(find.byType(FriendsHomeCard), findsNothing);
      expect(
        find.text(HomeStrings.cardHidden(HomeCardId.friends.title)),
        findsOneWidget,
      );
      expect(env.xmppCreated, 0);

      await tester.tap(find.text(HomeStrings.undo));
      await homeSettle(tester);
      expect(
        env.prefs.containsKey(
          PrefKeys.account(homeMe.puuid, 'home.friendsLive'),
        ),
        isFalse,
      );
      expect(find.text(HomeStrings.friendsConsentTitle), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  group('with consent', () {
    late HomeTestEnv env;

    setUp(() async {
      env = await HomeTestEnv.create(friendsConsent: true);
      env.content = bpContent();
      env.xmpp = _chat(friends);
    });

    testWidgets('avatars with name and status line, in activity order', (
      tester,
    ) async {
      await pumpHomeCard(
        tester,
        env,
        const FriendsHomeCard(),
        overrides: vmWith(realFriends: true),
      );
      expect(find.text(HomeStrings.friendsPlaying(3)), findsOneWidget);
      expect(find.text('Ngọc Anh'), findsOneWidget);
      expect(find.text('Minh Khoa'), findsOneWidget);
      expect(find.text('Bảo Trâm'), findsOneWidget);
      // The in-match friend shows the map and the live score.
      expect(find.textContaining('Ascent'), findsWidgets);
      expect(find.textContaining('8 – 4'), findsOneWidget);
      final a = tester.getTopLeft(find.text('Ngọc Anh')).dx;
      final b = tester.getTopLeft(find.text('Minh Khoa')).dx;
      final c = tester.getTopLeft(find.text('Bảo Trâm')).dx;
      expect(a, lessThan(b));
      expect(b, lessThan(c));
      homeExpectNoException(tester);
      await homeUnmount(tester);
    });

    testWidgets('an avatar opens the chat, the card opens the friends list', (
      tester,
    ) async {
      await pumpHomeCard(
        tester,
        env,
        const FriendsHomeCard(),
        overrides: vmWith(realFriends: true),
      );
      await tester.tap(find.text('Ngọc Anh'));
      await homeSettle(tester);
      expect(
        find.text('route /profile/friends/${friends.first.puuid}/chat'),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await homeSettle(tester);

      await tester.tap(find.text(HomeStrings.friendsSeeAll));
      await homeSettle(tester);
      expect(find.text('route /profile/friends'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await homeSettle(tester);

      await tester.tap(find.text(HomeStrings.friendsPlaying(3)));
      await homeSettle(tester);
      expect(find.text('route /profile/friends'), findsOneWidget);
      await homeUnmount(tester);
    });

    testWidgets('hidden when nobody is playing', (tester) async {
      env.xmpp = _chat([homeFriend(4, 'Ở Sảnh', loop: LoopState.menus)]);
      await pumpHomeCard(
        tester,
        env,
        const FriendsHomeCard(),
        overrides: vmWith(realFriends: true),
      );
      expect(find.byType(HomeCardFrame), findsNothing);
      await homeUnmount(tester);
    });

    testWidgets('declined: nothing, and the chat is never created', (
      tester,
    ) async {
      final declined = await HomeTestEnv.create(friendsConsent: false);
      declined.xmpp = _chat(friends);
      await pumpHomeCard(
        tester,
        declined,
        const FriendsHomeCard(),
        overrides: vmWith(realFriends: true),
      );
      expect(find.byType(HomeCardFrame), findsNothing);
      expect(declined.xmppCreated, 0);
      await homeUnmount(tester);
    });
  });

  testWidgets('a chat that is already connected needs no question', (
    tester,
  ) async {
    final env = await HomeTestEnv.create();
    env.xmpp = _chat(friends);
    await pumpHomeCard(
      tester,
      env,
      Consumer(
        builder: (context, ref, _) {
          // Another screen (Bạn bè) opened the chat before Home was built.
          ref.read(xmppServiceProvider);
          return const FriendsHomeCard();
        },
      ),
      overrides: vmWith(realFriends: true),
    );
    expect(find.text(HomeStrings.friendsConsentTitle), findsNothing);
    expect(find.text(HomeStrings.friendsPlaying(3)), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('more than eight playing: a "+n" after the strip', (
    tester,
  ) async {
    final env = await HomeTestEnv.create(friendsConsent: true);
    final many = [
      for (var i = 1; i <= 11; i++)
        homeFriend(i, 'Bạn ${i.toString().padLeft(2, '0')}'),
    ];
    env.xmpp = _chat(many);
    await pumpHomeCard(
      tester,
      env,
      const FriendsHomeCard(),
      overrides: vmWith(realFriends: true),
    );
    expect(find.text(HomeStrings.friendsPlaying(11)), findsOneWidget);
    expect(find.text(HomeStrings.friendsMore(3)), findsOneWidget);
    await homeUnmount(tester);
  });
}
