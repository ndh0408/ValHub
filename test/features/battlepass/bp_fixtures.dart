import 'dart:convert';

import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/util/json.dart';

import '../../helpers/fixtures.dart';

/// Well-known uuids of the battle pass tests (items exist in the real
/// vi-VN content fixtures under `test/fixtures/content/`).
abstract final class Bp {
  static const puuid = 'c5a5af97-d9b8-5217-9d26-1b35f93ca3d0';

  static const bpId = '3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9';
  static const actId = '8102cd81-43a0-d0d7-bd59-47b8fe9bed1b';
  static const nextActId = 'd816f426-48ea-f052-117f-9697a155b319';
  static const episodeId = '3737c391-497a-6e82-aeb5-cc9f701f72e2';
  static const eventPassId = 'd70f2a95-4682-5216-984f-ddaaa14436a7';
  static const eventId = 'e7049ebc-491a-454d-3ed6-12beca2aa0ec';
  static const agentContractId = 'cae6ab4a-4b4a-69a0-3c7a-48b17e313f52';

  // Rewards
  static const reaverL1 = 'ba42fe63-457a-78ce-4499-47950a698129';
  static const buddyL1 = '6c3b1a9e-4067-7ed6-fc6c-fea61e0a057c';
  static const card = '1711d20d-4b1c-c64a-14be-d4ae58a457c6';
  static const title = '48d870a2-4493-ebf8-7d6f-979be914dc43';
  static const spray = '7e2ba2e8-4597-060a-b41e-81acedca414e';
  static const flex = 'fc33f376-4a58-687c-6961-bd8a7e529346';
  static const rp = 'e59aa87c-4cbf-517a-5983-6e81511be9b7';
  static const kc = '85ca954a-41f2-ce94-9b45-8ca3dd39a00d';

  // Missions
  static const missionUlt = 'ea28678a-4ac4-eeec-d835-59bba4e082bd';
  static const missionDamage = 'c88f4400-4d61-896d-810b-5aacd6812076';
  static const missionHeadshots = '5a4c1d2e-0000-4000-8000-000000000001';
  static const missionNpe = '5a4c1d2e-0000-4000-8000-000000000002';
  static const missionUnknown = '5a4c1d2e-0000-4000-8000-00000000ffff';
  static const objUlt = '04ff6167-4976-eeb3-3e66-a78c57164351';
  static const objDamage = '974cb6ff-4aef-0217-1813-73a28ddfcdc6';
  static const objHeadshots = '5a4c1d2e-0000-4000-8000-0000000000aa';

  static const ultTitle = 'Sử dụng chiêu cuối của bạn';
  static const damageTitle = 'Gây sát thương';
  static const headshotTitle = 'Hạ gục bằng phát bắn vào đầu';
}

/// "Now" of the tests: 2026-09-28 12:00 UTC (Act V ends 2026-10-14).
final t0 = DateTime.utc(2026, 9, 28, 12);

/// XP needed for flat level [i] of a 2026 pass (CA §12).
int bpLevelXp(int i) => i == 0 ? 0 : (i < 50 ? 2000 + (i - 1) * 750 : 36500);

Map<String, Object?> _reward(String type, String uuid) => {
  'type': type,
  'uuid': uuid,
  'amount': 1,
  'isHighlighted': false,
};

/// A 2026-style battle pass: 10 chapters × 5 levels + a 5-level epilogue
/// (55 levels, 1,162,500 XP). Level 1 is a skin, the others cycle through
/// buddy / card / spray / title / flex / Radianite; each normal chapter has
/// two free rewards (card + Kingdom Credits).
Map<String, Object?> bpContractJson({
  String uuid = Bp.bpId,
  String name = 'Mùa 2026 // Phần V',
  String relationType = 'Season',
  String relationUuid = Bp.actId,
  int chapters = 11,
  String skinLevel = Bp.reaverL1,
}) {
  final cycle = [
    _reward('EquippableCharmLevel', Bp.buddyL1),
    _reward('PlayerCard', Bp.card),
    _reward('Spray', Bp.spray),
    _reward('Title', Bp.title),
    _reward('Totem', Bp.flex),
    _reward('Currency', Bp.rp),
  ];
  var flat = 0;
  return {
    'uuid': uuid,
    'displayName': name,
    'displayIcon': null,
    'content': {
      'relationType': relationType,
      'relationUuid': relationUuid,
      'premiumVPCost': 1000,
      'chapters': [
        for (var c = 0; c < chapters; c++)
          {
            'isEpilogue': c == chapters - 1 && chapters > 1,
            'levels': [
              for (var l = 0; l < 5; l++)
                {
                  'reward': flat == 0
                      ? _reward('EquippableSkinLevel', skinLevel)
                      : cycle[flat % cycle.length],
                  'xp': bpLevelXp(flat++),
                  'vpCost': 0,
                  'isPurchasableWithVP': true,
                  'doughCost': 0,
                  'isPurchasableWithDough': false,
                },
            ],
            'freeRewards': c == chapters - 1 && chapters > 1
                ? null
                : [_reward('PlayerCard', Bp.card), _reward('Currency', Bp.kc)],
          },
      ],
    },
  };
}

Map<String, Object?> _mission(
  String uuid,
  String title,
  String type,
  int xp,
  int target,
  String objective,
) => {
  'uuid': uuid,
  'displayName': null,
  'title': title,
  'type': 'EAresMissionType::$type',
  'xpGrant': xp,
  'progressToComplete': target,
  'activationDate': '2026-09-22T00:00:00Z',
  'expirationDate': '2026-10-14T00:00:00Z',
  'objectives': [
    {'objectiveUuid': objective, 'value': target},
  ],
};

/// Real vi-VN content fixtures with the battle pass, missions, acts and
/// the Champions event replaced by the test ones.
ContentDb bpContent({
  bool withBattlePass = true,
  bool withEvent = true,
  String skinLevel = Bp.reaverL1,
}) {
  final raw = <String, Object?>{...loadContentFixtures()};
  raw[ContentEndpoints.contracts] = jsonEncode({
    'status': 200,
    'data': [
      if (withBattlePass) bpContractJson(skinLevel: skinLevel),
      bpContractJson(
        uuid: Bp.eventPassId,
        name: 'Champions 2026: Shanghai',
        relationType: 'Event',
        relationUuid: Bp.eventId,
        chapters: 2,
      ),
      bpContractJson(
        uuid: Bp.agentContractId,
        name: 'Trang Bị Gekko',
        relationType: 'Agent',
        relationUuid: 'e370fa57-4757-3604-3648-499e1f642d3f',
        chapters: 1,
      ),
    ],
  });
  raw[ContentEndpoints.missions] = jsonEncode({
    'status': 200,
    'data': [
      _mission(Bp.missionUlt, Bp.ultTitle, 'Weekly', 38400, 15, Bp.objUlt),
      _mission(
        Bp.missionDamage,
        Bp.damageTitle,
        'Weekly',
        10080,
        18000,
        Bp.objDamage,
      ),
      _mission(
        Bp.missionHeadshots,
        Bp.headshotTitle,
        'Weekly',
        33900,
        40,
        Bp.objHeadshots,
      ),
      _mission(Bp.missionNpe, 'Hướng dẫn', 'NPE', 500, 1, Bp.objUlt),
    ],
  });
  raw[ContentEndpoints.seasons] = jsonEncode({
    'status': 200,
    'data': [
      {
        'uuid': Bp.episodeId,
        'displayName': 'V26',
        'title': null,
        'type': null,
        'startTime': '2026-06-24T00:00:00Z',
        'endTime': '2027-01-06T00:00:00Z',
        'parentUuid': null,
      },
      {
        'uuid': Bp.actId,
        'displayName': 'PHẦN V',
        'title': 'V26 // PHẦN V',
        'type': 'EAresSeasonType::Act',
        'startTime': '2026-08-19T00:00:00Z',
        'endTime': '2026-10-14T00:00:00Z',
        'parentUuid': Bp.episodeId,
      },
      {
        'uuid': Bp.nextActId,
        'displayName': 'PHẦN VI',
        'title': 'V26 // PHẦN VI',
        'type': 'EAresSeasonType::Act',
        'startTime': '2026-10-14T00:00:00Z',
        'endTime': '2027-01-06T00:00:00Z',
        'parentUuid': Bp.episodeId,
      },
    ],
  });
  raw[ContentEndpoints.events] = jsonEncode({
    'status': 200,
    'data': [
      if (withEvent)
        {
          'uuid': Bp.eventId,
          'displayName': 'Champions 2026',
          'shortDisplayName': 'Champions',
          'startTime': '2026-09-24T00:00:00Z',
          'endTime': '2026-10-19T00:00:00Z',
        },
    ],
  });
  return ContentDb.parse(raw);
}

/// P-15 payload (EP §12.1 shape). Defaults = ValBuddy screenshot SS-1:
/// level 46, 7.966 / 35.750 XP, 840.466 XP total.
JsonMap contractsJson({
  int level = 46,
  int inLevel = 7966,
  int total = 840466,
  bool includeBattlePass = true,
  List<Map<String, Object?>>? missions,
  String? weeklyRefill = '2026-09-30T00:00:00Z',
  List<Map<String, Object?>> extraContracts = const [],
}) => {
  'Version': 2185,
  'Subject': Bp.puuid,
  'Contracts': [
    if (includeBattlePass)
      {
        'ContractDefinitionID': Bp.bpId.toUpperCase(),
        'ContractProgression': {
          'TotalProgressionEarned': total,
          'TotalProgressionEarnedVersion': 71,
          'HighestRewardedLevel': {
            'd95831b3-ae9e-499b-989e-746020cd3b97': {
              'Amount': level,
              'Version': 4,
            },
          },
        },
        'ProgressionLevelReached': level,
        'ProgressionTowardsNextLevel': inLevel,
      },
    ...extraContracts,
  ],
  'ProcessedMatches': null,
  'ActiveSpecialContract': Bp.agentContractId,
  'Missions':
      missions ??
      [
        activeMission(Bp.missionUlt, Bp.objUlt, 8),
        activeMission(Bp.missionDamage, Bp.objDamage, 18000, complete: true),
        activeMission(Bp.missionHeadshots, Bp.objHeadshots, 12),
      ],
  'MissionMetadata': {
    'NPECompleted': true,
    'WeeklyCheckpoint': '2026-09-22T00:00:00Z',
    'WeeklyRefillTime': ?weeklyRefill,
  },
};

/// One P-15 `Missions[]` entry.
Map<String, Object?> activeMission(
  String id,
  String objective,
  int progress, {
  bool complete = false,
  String expires = '2026-10-14T00:00:00Z',
}) => {
  'ID': id,
  'Objectives': {objective: progress},
  'Complete': complete,
  'ExpirationTime': expires,
};

/// P-16 payload (EP §12.2 shape).
JsonMap dailyTicketJson({
  List<int> progress = const [4, 3, 0, 0],
  List<bool> bonus = const [true, false, false, false],
  num remaining = 13177,
  int pending = 0,
  bool wrapped = true,
}) {
  final inner = {
    'RemainingLifetimeSeconds': remaining,
    'BonusMilestonesPending': pending,
    'Milestones': [
      for (var i = 0; i < progress.length; i++)
        {'Progress': progress[i], 'BonusApplied': i < bonus.length && bonus[i]},
    ],
  };
  return wrapped ? {'DailyRewards': inner} : inner;
}

/// P-3 premium-contract entitlements containing [contracts].
JsonMap premiumJson(List<String> contracts) => {
  'ItemTypeID': 'f85cb6f7-33e5-4dc8-b609-ec7212301948',
  'Entitlements': [
    for (final c in contracts)
      {'TypeID': '4e60e748-bce6-4faa-9327-ebbe6089d5fe', 'ItemID': c},
  ],
};
