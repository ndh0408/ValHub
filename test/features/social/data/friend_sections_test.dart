import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/social/data/friend_sections.dart';

final _now = DateTime.utc(2026, 9, 28, 12);

Friend _friend(
  String id, {
  LoopState? loop,
  bool matchmaking = false,
  bool online = true,
  int unread = 0,
}) => Friend(
  puuid: id,
  unread: unread,
  presence: online
      ? FriendPresence(
          puuid: id,
          show: PresenceShow.chat,
          product: 'valorant',
          valorant: loop == null
              ? null
              : PresenceSnapshot(
                  loopState: loop,
                  partyState: matchmaking ? 'MATCHMAKING' : null,
                ),
          receivedAt: _now,
        )
      : null,
);

List<String> _ids(FriendSection s) => [for (final f in s.friends) f.puuid];

void main() {
  // Already in the core order: most active first.
  final view = FriendsView(
    online: [
      _friend('match', loop: LoopState.ingame),
      _friend('select', loop: LoopState.pregame),
      _friend('queue', loop: LoopState.menus, matchmaking: true),
      _friend('lobby', loop: LoopState.menus),
      _friend('lobby-unread', loop: LoopState.menus, unread: 2),
      _friend('launcher'),
    ],
    offline: [
      _friend('off-recent', online: false),
      _friend('off-unread', online: false, unread: 1),
    ],
  );

  test('match, agent select and queue are "Đang chơi"; the rest online', () {
    final sections = friendSections(view);
    expect(sections.map((s) => s.kind), [
      FriendSectionKind.playing,
      FriendSectionKind.online,
      FriendSectionKind.offline,
    ]);
    expect(_ids(sections[0]), ['match', 'select', 'queue']);
    // Unread first, otherwise the activity order is kept.
    expect(_ids(sections[1]), ['lobby-unread', 'lobby', 'launcher']);
    expect(_ids(sections[2]), ['off-unread', 'off-recent']);
  });

  test('"Trực tuyến" hides the offline section', () {
    final sections = friendSections(view, filter: FriendsFilter.online);
    expect(
      sections.map((s) => s.kind),
      isNot(contains(FriendSectionKind.offline)),
    );
    expect(sections.expand((s) => s.friends), hasLength(6));
  });

  test('"Chưa đọc" keeps only unread conversations; empty sections vanish', () {
    final sections = friendSections(view, filter: FriendsFilter.unread);
    expect(sections.map((s) => s.kind), [
      FriendSectionKind.online,
      FriendSectionKind.offline,
    ]);
    expect(sections.expand(_ids), ['lobby-unread', 'off-unread']);
  });

  test('empty view → no sections', () {
    expect(friendSections(const FriendsView()), isEmpty);
  });

  group('searchFriends', () {
    Friend named(String id, String name, String tag, {String? note}) => Friend(
      puuid: id,
      name: RiotName(gameName: name, tagLine: tag),
      note: note,
    );
    final roster = FriendsView(
      online: [named('duc', 'Đức', 'VN1'), named('cu', 'Cú Đêm', 'OWL')],
      offline: [
        named('hoa', 'Hoa', 'VN2', note: 'Bạn đại học'),
        const Friend(puuid: 'nameless'),
      ],
    );
    List<String> ids(FriendsView v) => [for (final f in v.all) f.puuid];

    test('"duc", "ĐỨC" and "đức" all find "Đức"', () {
      for (final q in ['duc', 'ĐỨC', 'đức', 'DUC', '  Duc ']) {
        expect(ids(searchFriends(roster, q)), ['duc'], reason: q);
      }
    });

    test('every word must match, in any order, tag and note included', () {
      expect(ids(searchFriends(roster, 'dem cu')), ['cu']);
      expect(ids(searchFriends(roster, 'owl')), ['cu']);
      expect(ids(searchFriends(roster, 'dai hoc')), ['hoa']);
      expect(ids(searchFriends(roster, 'cu vn1')), isEmpty);
    });

    test('a blank query keeps everyone (and the connection state)', () {
      expect(identical(searchFriends(roster, '  '), roster), isTrue);
      expect(searchFriends(roster, 'x').connection, roster.connection);
    });
  });
}
