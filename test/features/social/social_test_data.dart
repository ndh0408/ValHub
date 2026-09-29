import 'package:valvn/core/util/json.dart';

const me = 'aaaaaaaa-0000-4000-8000-000000000001';
const mate = 'aaaaaaaa-0000-4000-8000-000000000002';
const stranger = 'eeeeeeee-0000-4000-8000-00000000000e';
const friendOnline = 'f0000000-0000-4000-8000-00000000000a';
const friendLobby = 'f0000000-0000-4000-8000-00000000000b';
const friendOffline = 'f0000000-0000-4000-8000-00000000000c';
const partyId = '62d30f62-98c0-4f6f-8380-350a84aac00e';
const otherPartyId = '11111111-2222-4333-8444-555555555555';

/// A player card of the content fixtures.
const cardId = '1711d20d-4b1c-c64a-14be-d4ae58a457c6';

JsonMap memberJson(
  String puuid, {
  bool owner = false,
  bool ready = false,
  int tier = 0,
  int level = 100,
  bool incognito = false,
  int remainingLevels = 0,
}) => {
  'Subject': puuid,
  'CompetitiveTier': tier,
  'PlayerIdentity': {
    'Subject': puuid,
    'PlayerCardID': cardId.toUpperCase(),
    'PlayerTitleID': '00000000-0000-0000-0000-000000000000',
    'AccountLevel': level,
    'Incognito': incognito,
    'HideAccountLevel': false,
  },
  'IsOwner': owner,
  'IsReady': ready,
  'QueueEligibleRemainingAccountLevels': remainingLevels,
  'Pings': [
    {'Ping': 24, 'GamePodID': 'a'},
    {'Ping': 60, 'GamePodID': 'b'},
  ],
  'PlatformType': 'PC',
};

JsonMap partyJson({
  List<JsonMap>? members,
  String state = 'DEFAULT',
  String queue = 'competitive',
  String? entry,
  String code = '',
  Object? eligible = const ['competitive', 'unrated', 'swiftplay'],
  List<String> ineligible = const [],
  List<JsonMap> requests = const [],
  List<JsonMap>? invites,
  int restricted = 0,
  String accessibility = 'CLOSED',
}) => {
  'ID': partyId.toUpperCase(),
  'Version': 1,
  'Members': members ?? [memberJson(me, owner: true, ready: true, tier: 18)],
  'State': state,
  'Accessibility': accessibility,
  'MatchmakingData': {'QueueID': queue, 'PreferredGamePods': <String>[]},
  'Invites': invites,
  'Requests': requests,
  'QueueEntryTime': entry ?? '0001-01-01T00:00:00Z',
  'RestrictedSeconds': restricted,
  'EligibleQueues': eligible,
  'QueueIneligibilities': ineligible,
  'InviteCode': code,
};
