import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/core/xmpp/xmpp.dart';

import 'fake_xmpp_server.dart';

final _now = DateTime.utc(2026, 9, 28, 12);

FriendPresence _presence(
  String puuid, {
  String resource = 'RC',
  bool available = true,
  PresenceShow show = PresenceShow.chat,
  String? product = 'valorant',
  PresenceSnapshot? valorant = const PresenceSnapshot(
    loopState: LoopState.menus,
  ),
}) => FriendPresence(
  puuid: puuid,
  resource: resource,
  available: available,
  show: show,
  product: product,
  valorant: product == 'valorant' ? valorant : null,
  receivedAt: _now,
);

RosterEntry _entry(String puuid, String? name, {DateTime? lastOnline}) =>
    RosterEntry(
      puuid: puuid,
      jid: '$puuid@jp1.pvp.net',
      name: name == null ? null : RiotName(gameName: name, tagLine: 'VN'),
      subscription: 'both',
      lastOnline: lastOnline,
    );

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('XmppStore', () {
    late XmppStore store;

    setUp(() => store = XmppStore(ownPuuid: me, now: () => _now));
    tearDown(() => store.dispose());

    test('keeps friends only and applies roster pushes', () async {
      store.setRoster([
        _entry(friendA, 'A'),
        const RosterEntry(puuid: 'x', jid: 'x@d', subscription: 'pending_in'),
      ]);
      expect(store.snapshot.roster.keys, [friendA]);
      expect(store.snapshot.rosterLoaded, isTrue);
      store.applyRosterPush([
        _entry(friendB, 'B'),
        RosterEntry(
          puuid: friendA,
          jid: '$friendA@jp1.pvp.net',
          subscription: 'remove',
        ),
      ]);
      expect(store.snapshot.roster.keys, [friendB]);
    });

    test('roster map is stable across presence changes', () {
      store.setRoster([_entry(friendA, 'A')]);
      final roster = store.snapshot.roster;
      store.applyPresence(_presence(friendA));
      expect(identical(store.snapshot.roster, roster), isTrue);
      expect(store.snapshot.presences.keys, [friendA]);
    });

    test('tracks resources separately and picks the best', () {
      store
        ..applyPresence(_presence(friendA, resource: 'mobile', product: null))
        ..applyPresence(_presence(friendA, resource: 'game'));
      expect(store.snapshot.presences[friendA]!.resource, 'game');
      store.applyPresence(
        _presence(friendA, resource: 'game', available: false),
      );
      expect(store.snapshot.presences[friendA]!.resource, 'mobile');
      store.applyPresence(
        _presence(friendA, resource: 'mobile', available: false),
      );
      expect(store.snapshot.presences, isEmpty);
    });

    test('own presence comes from other resources of our JID', () {
      store
        ..ownResource = 'RC-VALVN'
        ..applyPresence(_presence(me, resource: 'RC-VALVN'));
      expect(store.snapshot.ownPresence, isNull);
      store.applyPresence(_presence(me, resource: 'RC-GAME'));
      expect(store.snapshot.ownPresence?.resource, 'RC-GAME');
      expect(store.snapshot.presences, isEmpty);
      store.clearPresences();
      expect(store.snapshot.ownPresence, isNull);
    });

    test('unread counts, active conversation and history merge', () async {
      ChatMessage msg(String id, String body, int minute, {bool out = false}) =>
          ChatMessage(
            id: id,
            friendPuuid: friendA,
            outgoing: out,
            body: body,
            at: _now.add(Duration(minutes: minute)),
          );
      store
        ..addLiveMessage(msg('1', 'a', 1))
        ..addLiveMessage(msg('2', 'b', 2));
      expect(store.snapshot.unread[friendA], 2);
      expect(store.snapshot.totalUnread, 2);

      store.setActiveConversation(friendA);
      expect(store.snapshot.unread, isEmpty);
      store.addLiveMessage(msg('3', 'c', 3));
      expect(store.snapshot.unread, isEmpty);

      // A local copy is replaced by the archived one.
      store
        ..addLiveMessage(msg('${localMessagePrefix}9', 'mine', 4, out: true))
        ..addHistory(friendA, [
          msg('0', 'old', -60),
          msg('2', 'b', 2),
          msg('srv-9', 'mine', 4, out: true),
        ]);
      final conv = store.conversation(friendA);
      expect(conv.historyLoaded, isTrue);
      expect(conv.messages.map((m) => m.id), ['0', '1', '2', '3', 'srv-9']);
    });

    test('emits one snapshot per burst', () async {
      final snaps = <XmppSnapshot>[];
      final sub = store.snapshots.listen(snaps.add);
      store
        ..applyPresence(_presence(friendA))
        ..applyPresence(_presence(friendB))
        ..applyPresence(_presence(friendC));
      await _flush();
      await sub.cancel();
      expect(snaps, hasLength(2)); // current + one change
      expect(snaps.last.presences, hasLength(3));
    });

    test('watchConversation starts with the current conversation', () async {
      final seen = <int>[];
      final sub = store
          .watchConversation(friendA.toUpperCase())
          .listen((c) => seen.add(c.messages.length));
      store.addLiveMessage(
        ChatMessage(
          id: '1',
          friendPuuid: friendA,
          outgoing: false,
          body: 'x',
          at: _now,
        ),
      );
      await _flush();
      await sub.cancel();
      expect(seen, [0, 1]);
    });
  });

  group('friends view', () {
    test('activity follows SUMMARY §9.9 priorities', () {
      PresenceSnapshot v(LoopState s, {String party = 'DEFAULT'}) =>
          PresenceSnapshot(loopState: s, partyState: party);
      expect(friendActivity(null), FriendActivity.offline);
      expect(
        friendActivity(_presence(friendA, valorant: v(LoopState.ingame))),
        FriendActivity.inMatch,
      );
      expect(
        friendActivity(
          _presence(
            friendA,
            show: PresenceShow.away,
            valorant: v(LoopState.pregame),
          ),
        ),
        FriendActivity.agentSelect,
      );
      expect(
        friendActivity(
          _presence(
            friendA,
            valorant: v(LoopState.menus, party: 'MATCHMAKING'),
          ),
        ),
        FriendActivity.inQueue,
      );
      expect(
        friendActivity(_presence(friendA, valorant: v(LoopState.menus))),
        FriendActivity.inLobby,
      );
      expect(
        friendActivity(
          _presence(
            friendA,
            valorant: const PresenceSnapshot(
              loopState: LoopState.menus,
              isIdle: true,
            ),
          ),
        ),
        FriendActivity.away,
      );
      expect(
        friendActivity(
          _presence(
            friendA,
            valorant: const PresenceSnapshot(
              loopState: LoopState.ingame,
              provisioningFlow: 'ShootingRange',
            ),
          ),
        ),
        FriendActivity.shootingRange,
      );
      expect(
        friendActivity(_presence(friendA, product: 'league_of_legends')),
        FriendActivity.otherGame,
      );
      expect(
        friendActivity(_presence(friendA, product: 'keystone')),
        FriendActivity.online,
      );
    });

    test('splits, sorts, fills names and filters', () {
      final store = XmppStore(ownPuuid: me, now: () => _now)
        ..setRoster([
          _entry(friendA, 'Zeta'),
          _entry(friendB, 'Alpha', lastOnline: DateTime.utc(2026, 9, 1)),
          _entry(friendC, null, lastOnline: DateTime.utc(2026, 9, 20)),
          _entry('f0000000-0000-4000-8000-00000000000e', 'Đức Anh'),
          _entry('f0000000-0000-4000-8000-00000000000f', 'Beta'),
        ])
        ..applyPresence(
          _presence(
            'f0000000-0000-4000-8000-00000000000e',
            valorant: const PresenceSnapshot(loopState: LoopState.ingame),
          ),
        )
        ..applyPresence(_presence(friendA))
        ..applyPresence(_presence('f0000000-0000-4000-8000-00000000000f'));
      final view = buildFriendsView(
        store.snapshot,
        names: {friendC: const RiotName(gameName: 'Cường', tagLine: 'VN')},
      );
      expect(view.online.map((f) => f.name!.gameName), [
        'Đức Anh', // in a match
        'Beta', // lobby, by name
        'Zeta',
      ]);
      expect(view.offline.map((f) => f.name!.gameName), ['Cường', 'Alpha']);
      expect(view.filter('duc').online.single.name!.gameName, 'Đức Anh');
      expect(view.filter('CUONG').offline.single.puuid, friendC);
      expect(view.filter('#vn').all, hasLength(5));
      expect(view.filter('zzz').isEmpty, isTrue);
      expect(view.byPuuid(friendC.toUpperCase())?.name?.gameName, 'Cường');
      store.dispose();
    });

    test('foldVietnamese strips diacritics', () {
      expect(foldVietnamese('ĐỨC Ánh Hường'), 'duc anh huong');
    });
  });
}
