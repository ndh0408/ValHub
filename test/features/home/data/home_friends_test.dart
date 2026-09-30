import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/core/xmpp/friends.dart';
import 'package:valvn/core/xmpp/xmpp_models.dart';
import 'package:valvn/features/home/data/home_friends.dart';

final _now = DateTime.utc(2026, 9, 28, 12);

Friend _friend(
  int n,
  String name, {
  LoopState? loop,
  bool queue = false,
  bool away = false,
  bool range = false,
  String? product,
  bool offline = false,
}) {
  final valorant = loop == null
      ? null
      : PresenceSnapshot(
          loopState: loop,
          matchMap: '/Game/Maps/Ascent/Ascent',
          partyState: queue ? 'MATCHMAKING' : 'DEFAULT',
          provisioningFlow: range ? 'ShootingRange' : 'Matchmaking',
        );
  final puuid = 'f0000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
  return Friend(
    puuid: puuid,
    name: RiotName(gameName: name, tagLine: 'VN$n'),
    presence: offline
        ? null
        : FriendPresence(
            puuid: puuid,
            receivedAt: _now,
            product: product ?? (valorant == null ? null : 'valorant'),
            show: away ? PresenceShow.away : PresenceShow.chat,
            valorant: valorant,
          ),
  );
}

FriendsView _view(List<Friend> friends) => FriendsView(
  online: [
    for (final f in friends)
      if (f.isOnline) f,
  ],
  offline: [
    for (final f in friends)
      if (!f.isOnline) f,
  ],
);

void main() {
  test('only friends in a match, in agent select or in a queue count', () {
    final snap = playingFriendsOf(
      _view([
        _friend(1, 'Lobby', loop: LoopState.menus),
        _friend(2, 'Match', loop: LoopState.ingame),
        _friend(3, 'Select', loop: LoopState.pregame),
        _friend(4, 'Queue', loop: LoopState.menus, queue: true),
        _friend(5, 'Range', loop: LoopState.ingame, range: true),
        _friend(6, 'Away', loop: LoopState.menus, away: true),
        _friend(7, 'Other', product: 'league_of_legends'),
        _friend(8, 'Gone', offline: true),
      ]),
    )!;
    expect(snap.playing.map((f) => f.name!.gameName), [
      'Match',
      'Select',
      'Queue',
    ]);
    expect(snap.total, 3);
    expect(snap.hidden, 0);
  });

  test('ordered by activity, then by name', () {
    final snap = playingFriendsOf(
      _view([
        _friend(1, 'Zed', loop: LoopState.ingame),
        _friend(2, 'Bob', loop: LoopState.menus, queue: true),
        _friend(3, 'Amy', loop: LoopState.ingame),
        _friend(4, 'Cid', loop: LoopState.pregame),
      ]),
    )!;
    expect(snap.playing.map((f) => f.name!.gameName), [
      'Amy',
      'Zed',
      'Cid',
      'Bob',
    ]);
  });

  test('capped at eight, the rest counted', () {
    final snap = playingFriendsOf(
      _view([
        for (var i = 1; i <= 11; i++)
          _friend(
            i,
            'Friend${i.toString().padLeft(2, '0')}',
            loop: LoopState.ingame,
          ),
      ]),
    )!;
    expect(kHomeMaxPlayingFriends, 8);
    expect(snap.playing, hasLength(8));
    expect(snap.total, 11);
    expect(snap.hidden, 3);
    expect(snap.playing.first.name!.gameName, 'Friend01');
  });

  test('nobody playing gives null', () {
    expect(playingFriendsOf(const FriendsView()), isNull);
    expect(
      playingFriendsOf(
        _view([
          _friend(1, 'A', loop: LoopState.menus),
          _friend(2, 'B', loop: LoopState.menus, away: true),
          _friend(3, 'C', offline: true),
        ]),
      ),
      isNull,
    );
  });

  test('a custom cap is honored', () {
    final snap = playingFriendsOf(
      _view([
        for (var i = 1; i <= 4; i++) _friend(i, 'F$i', loop: LoopState.ingame),
      ]),
      max: 2,
    )!;
    expect(snap.playing, hasLength(2));
    expect(snap.total, 4);
  });
}
