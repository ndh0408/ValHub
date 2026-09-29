import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/social/data/friend_status.dart';

import '../../../helpers/fixtures.dart';

final _now = DateTime.utc(2026, 9, 28, 12);
final _db = ContentDb.parse(loadContentFixtures());

FriendStatus _status(
  PresenceSnapshot? v, {
  PresenceShow show = PresenceShow.chat,
  String? product = 'valorant',
  bool online = true,
  DateTime? lastOnline,
}) => friendStatus(
  Friend(
    puuid: 'x',
    lastOnline: lastOnline,
    presence: online
        ? FriendPresence(
            puuid: 'x',
            show: show,
            product: product,
            valorant: v,
            receivedAt: _now,
          )
        : null,
  ),
  db: _db,
  now: _now,
);

void main() {
  test('in a match: map and live score (hidden at 0 – 0)', () {
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.ingame,
          matchMap: '/Game/Maps/Ascent/Ascent',
          allyScore: 8,
          enemyScore: 4,
        ),
      ),
      const FriendStatus('Đang đấu · Ascent · 8 – 4', StatusTone.inMatch),
    );
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.ingame,
          matchMap: '/Game/Maps/Ascent/Ascent',
          allyScore: 0,
          enemyScore: 0,
        ),
      ).text,
      'Đang đấu · Ascent',
    );
    expect(
      _status(const PresenceSnapshot(loopState: LoopState.ingame)).text,
      'Đang đấu',
    );
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.ingame,
          provisioningFlow: 'CustomGame',
          matchMap: '/Game/Maps/Ascent/Ascent',
        ),
      ).text,
      'Đang chơi tùy chỉnh · Ascent',
    );
  });

  test('agent select, queue, lobby, range', () {
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.pregame,
          matchMap: '/Game/Maps/Ascent/Ascent',
        ),
      ),
      const FriendStatus('Đang chọn đặc vụ · Ascent', StatusTone.busy),
    );
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.menus,
          partyState: 'MATCHMAKING',
          queueId: 'competitive',
        ),
      ).text,
      'Đang tìm trận · Thi đấu xếp hạng',
    );
    expect(
      _status(const PresenceSnapshot(loopState: LoopState.menus)).text,
      'Đang ở sảnh chờ',
    );
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.menus,
          partySize: 3,
          maxPartySize: 5,
        ),
      ).text,
      'Đang ở sảnh chờ · Tổ đội 3/5',
    );
    expect(
      _status(
        const PresenceSnapshot(
          loopState: LoopState.ingame,
          provisioningFlow: 'ShootingRange',
        ),
      ).text,
      'Đang ở trường bắn',
    );
  });

  test('away, other games, online, offline', () {
    expect(
      _status(
        const PresenceSnapshot(loopState: LoopState.menus),
        show: PresenceShow.away,
      ),
      const FriendStatus('Vắng mặt', StatusTone.away),
    );
    expect(
      _status(const PresenceSnapshot(loopState: LoopState.menus, isIdle: true))
          .text,
      'Vắng mặt',
    );
    expect(
      _status(null, product: 'league_of_legends').text,
      'Đang chơi Liên Minh Huyền Thoại',
    );
    expect(_status(null, product: 'keystone').text, 'Trực tuyến');
    expect(
      _status(null, product: null, show: PresenceShow.mobile).text,
      'Trực tuyến trên điện thoại',
    );
    expect(_status(const PresenceSnapshot()).text, 'Đang trong VALORANT');
    expect(
      _status(
        null,
        online: false,
        lastOnline: _now.subtract(const Duration(hours: 2)),
      ),
      const FriendStatus('Hoạt động 2 giờ trước', StatusTone.offline),
    );
    expect(_status(null, online: false).text, 'Ngoại tuyến');
  });
}
