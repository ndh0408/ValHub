import 'package:valvn/core/accounts/account_status.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/riot/platform_status.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/home/data/home_accounts.dart';
import 'package:valvn/features/home/data/home_community.dart';
import 'package:valvn/features/home/data/home_friends.dart';
import 'package:valvn/features/home/data/home_status.dart';

import 'home_test_env.dart';

/// A friend in VALORANT (in a match by default).
Friend homeFriend(
  int n,
  String name, {
  LoopState loop = LoopState.ingame,
  bool queue = false,
  int? ally,
  int? enemy,
  String? cardId,
}) {
  final puuid = 'f0000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
  return Friend(
    puuid: puuid,
    name: RiotName(gameName: name, tagLine: 'VN$n'),
    presence: FriendPresence(
      puuid: puuid,
      receivedAt: homeNow,
      product: 'valorant',
      valorant: PresenceSnapshot(
        loopState: loop,
        matchMap: '/Game/Maps/Ascent/Ascent',
        partyState: queue ? 'MATCHMAKING' : 'DEFAULT',
        allyScore: ally,
        enemyScore: enemy,
        playerCardId: cardId ?? Fx.cardNgoiSang,
      ),
    ),
  );
}

HomeFriendsSnapshot homeFriendsSnapshot({int total = 3}) => HomeFriendsSnapshot(
  playing: [
    homeFriend(1, 'Ngọc Anh', ally: 8, enemy: 4),
    homeFriend(2, 'Minh Khoa', loop: LoopState.pregame),
    homeFriend(3, 'Bảo Trâm', loop: LoopState.menus, queue: true),
  ].take(total).toList(),
  total: total,
);

LfgPost homeLfg(
  String id, {
  String author = 'Đồng Đội Một',
  int slots = 2,
  int? rankMin,
  int? rankMax,
  bool mic = false,
}) => LfgPost.fromJson({
  'id': id,
  'author': {
    'id': 'ot0000000000000000000000000000$id',
    'gameName': author,
    'tagLine': 'VN9',
    'rankTier': 12,
    'region': 'ap',
  },
  'region': 'ap',
  'mode': 'competitive',
  'partyCode': 'ABC123',
  'slots': slots,
  'rankTier': 12,
  'rankMin': rankMin,
  'rankMax': rankMax,
  'mic': mic,
  'createdAt': homeNow.toUtc().toIso8601String(),
  'expiresAt': homeNow
      .add(const Duration(minutes: 24))
      .toUtc()
      .toIso8601String(),
})!;

TopSkin homeTopSkin(String skinUuid, int votes, int rank) =>
    TopSkin.fromJson({'skinUuid': skinUuid, 'votes': votes}, rank - 1)!;

HomeCommunitySnapshot homeCommunitySnapshot({
  bool lfg = true,
  bool trending = true,
  Set<String> wishlist = const {},
}) => HomeCommunitySnapshot(
  lfg: lfg
      ? [
          homeLfg(
            '1',
            author: 'Đồng Đội Một',
            rankMin: 12,
            rankMax: 15,
            mic: true,
          ),
          homeLfg('2', author: 'Đồng Đội Hai', slots: 1),
        ]
      : const [],
  trending: trending
      ? [
          homeTopSkin(Fx.reaverVandal, 120, 1),
          homeTopSkin(Fx.aresPrism, 90, 2),
          homeTopSkin(Fx.daoReaver, 45, 3),
        ]
      : const [],
  wishlist: wishlist,
);

HomeOtherAccounts homeOtherAccounts({
  bool hit = true,
  bool needsLogin = true,
  int more = 0,
}) => HomeOtherAccounts(
  rows: [
    OtherAccountSummary(
      account: homeAlt1,
      activity: AccountActivity.inMatch,
      liveHits: hit
          ? [
              WishlistHit(
                skinUuid: Fx.aresPrism,
                levelUuid: Fx.aresPrismL1,
                place: WishlistPlace.daily,
                expiresAt: homeNow.add(const Duration(hours: 4)),
              ),
            ]
          : const [],
      storeKnown: true,
    ),
    OtherAccountSummary(
      account: needsLogin ? homeAlt2.copyWith(needsLogin: true) : homeAlt2,
      activity: needsLogin
          ? AccountActivity.needsLogin
          : AccountActivity.offline,
    ),
  ],
  more: more,
);

/// An X-1 body with one maintenance ([kind] `maintenance`, [status] its
/// phase) or one incident ([kind] `incident`, [status] its severity).
PlatformStatus homeStatusPayload({
  String kind = 'maintenance',
  String status = 'in_progress',
  String title = 'Máy chủ đang bảo trì',
  String message = 'Bảo trì để cập nhật phiên bản mới.',
}) {
  final notice = {
    'id': kind == 'maintenance' ? 'm1' : 'i1',
    if (kind == 'maintenance')
      'maintenance_status': status
    else
      'incident_severity': status,
    'titles': [
      {'locale': 'vi_VN', 'content': title},
    ],
    'updates': [
      {
        'translations': [
          {'locale': 'vi_VN', 'content': message},
        ],
      },
    ],
    'platforms': ['windows'],
    'created_at': '2026-09-28T01:00:00Z',
  };
  return PlatformStatus.fromJson({
    if (kind == 'maintenance') 'maintenances': [notice],
    if (kind != 'maintenance') 'incidents': [notice],
  });
}

HomeServerStatus homeServerStatus({
  String kind = 'maintenance',
  String status = 'in_progress',
  Map<String, PlatformStatus?>? other,
}) => buildHomeServerStatus({
  'ap': homeStatusPayload(kind: kind, status: status),
  ...?other,
}, activeRegion: 'ap')!;
