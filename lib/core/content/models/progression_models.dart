import 'package:flutter/foundation.dart';

import '../../l10n/content_strings.dart';
import '../../riot/riot_ids.dart';
import '../../util/json.dart';
import 'weapon_models.dart' show cleanText, enumSuffix;

/// Contract reward types (`/v1/contracts` `reward.type`).
enum ContractRewardType {
  skinLevel('EquippableSkinLevel', ItemTypeIds.skinLevel),
  buddyLevel('EquippableCharmLevel', ItemTypeIds.buddyLevel),
  currency('Currency', ItemTypeIds.currency),
  playerCard('PlayerCard', ItemTypeIds.playerCard),
  spray('Spray', ItemTypeIds.spray),
  title('Title', ItemTypeIds.playerTitle),
  flex('Totem', ItemTypeIds.flex),
  agent('Character', ItemTypeIds.agent),
  unknown('', '');

  const ContractRewardType(this.apiName, this.itemTypeId);

  final String apiName;

  /// Matching Riot `ItemTypeID` (for `ContentDb.item`).
  final String itemTypeId;

  static ContractRewardType parse(Object? value) {
    final s = asString(value);
    for (final t in values) {
      if (t.apiName == s && t != unknown) return t;
    }
    return unknown;
  }

  /// Vietnamese type label (VF S21).
  String get label => switch (this) {
    skinLevel => ContentStrings.itemSkin,
    buddyLevel => ContentStrings.itemBuddy,
    currency => ContentStrings.itemCurrency,
    playerCard => ContentStrings.itemCard,
    spray => ContentStrings.itemSpray,
    title => ContentStrings.itemTitle,
    flex => ContentStrings.itemFlex,
    agent => ContentStrings.itemAgent,
    unknown => '',
  };
}

@immutable
class ContractReward {
  const ContractReward({
    required this.type,
    required this.rawType,
    required this.uuid,
    this.amount = 1,
    this.isHighlighted = false,
  });

  static ContractReward? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return ContractReward(
      type: ContractRewardType.parse(m['type']),
      rawType: asString(m['type']) ?? '',
      uuid: uuid,
      amount: asInt(m['amount']) ?? 1,
      isHighlighted: asBool(m['isHighlighted']) ?? false,
    );
  }

  final ContractRewardType type;
  final String rawType;
  final String uuid;

  /// UNVERIFIED for Radianite (always 1); do not display (SUMMARY U20).
  final int amount;
  final bool isHighlighted;
}

/// One level of a contract (premium track).
@immutable
class ContractLevel {
  const ContractLevel({
    required this.reward,
    required this.xp,
    this.vpCost = 0,
    this.isPurchasableWithVP = false,
    this.doughCost = 0,
    this.isPurchasableWithDough = false,
  });

  final ContractReward? reward;

  /// XP needed for THIS level (SUMMARY §9.4).
  final int xp;
  final int vpCost;
  final bool isPurchasableWithVP;
  final int doughCost;
  final bool isPurchasableWithDough;
}

@immutable
class ContractChapter {
  const ContractChapter({
    required this.isEpilogue,
    required this.levels,
    required this.freeRewards,
  });

  final bool isEpilogue;
  final List<ContractLevel> levels;

  /// Free-track rewards of this chapter.
  final List<ContractReward> freeRewards;
}

/// What a contract belongs to (`content.relationType`).
enum ContractRelation {
  season,
  agent,
  event,
  other;

  static ContractRelation parse(Object? v) => switch (asString(v)) {
    'Season' => season,
    'Agent' => agent,
    'Event' => event,
    _ => other,
  };

  /// C9 reward-source label.
  String? get rewardSourceLabel => switch (this) {
    season => ContentStrings.rewardSourceBattlePass,
    agent => ContentStrings.rewardSourceAgent,
    event => ContentStrings.rewardSourceEvent,
    other => null,
  };
}

/// `/v1/contracts`: battle passes, event passes, agent contracts.
@immutable
class Contract {
  const Contract({
    required this.uuid,
    required this.displayName,
    required this.relation,
    required this.chapters,
    this.relationUuid,
    this.displayIcon,
    this.premiumVpCost,
  });

  static Contract? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final content = asMap(m['content']) ?? const <String, dynamic>{};
    return Contract(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      displayIcon: asNonEmptyString(m['displayIcon']),
      relation: ContractRelation.parse(content['relationType']),
      relationUuid: lowerUuid(content['relationUuid']),
      premiumVpCost: asInt(content['premiumVPCost']),
      chapters: [
        for (final c in asMapList(content['chapters']))
          ContractChapter(
            isEpilogue: asBool(c['isEpilogue']) ?? false,
            levels: [
              for (final l in asMapList(c['levels']))
                ContractLevel(
                  reward: ContractReward.fromJson(l['reward']),
                  xp: asInt(l['xp']) ?? 0,
                  vpCost: asInt(l['vpCost']) ?? 0,
                  isPurchasableWithVP:
                      asBool(l['isPurchasableWithVP']) ?? false,
                  doughCost: asInt(l['doughCost']) ?? 0,
                  isPurchasableWithDough:
                      asBool(l['isPurchasableWithDough']) ?? false,
                ),
            ],
            freeRewards: [
              for (final r in asList(c['freeRewards']))
                ?ContractReward.fromJson(r),
            ],
          ),
      ],
    );
  }

  final String uuid;
  final String displayName;
  final String? displayIcon;
  final ContractRelation relation;

  /// Act uuid (Season), agent uuid (Agent) or event uuid (Event).
  final String? relationUuid;
  final int? premiumVpCost;
  final List<ContractChapter> chapters;

  /// All premium-track levels in order (`flat` in SUMMARY §9.4).
  List<ContractLevel> get flatLevels => [for (final c in chapters) ...c.levels];

  int get levelCount => flatLevels.length;

  /// Σ xp of every level (1,162,500 for 2026 passes).
  int get totalXp => flatLevels.fold(0, (sum, l) => sum + l.xp);

  /// XP needed to go from [levelReached] to the next level, i.e.
  /// `flat[levelReached].xp`; `null` when the contract is complete.
  int? xpForNextLevel(int levelReached) {
    final flat = flatLevels;
    if (levelReached < 0 || levelReached >= flat.length) return null;
    return flat[levelReached].xp;
  }
}

/// `/v1/missions`.
@immutable
class Mission {
  const Mission({
    required this.uuid,
    required this.title,
    this.type,
    this.xpGrant = 0,
    this.progressToComplete = 0,
    this.activationDate,
    this.expirationDate,
    this.objectives = const {},
  });

  static Mission? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return Mission(
      uuid: uuid,
      title: cleanText(m['title']) ?? cleanText(m['displayName']) ?? '',
      type: enumSuffix(m['type']),
      xpGrant: asInt(m['xpGrant']) ?? 0,
      progressToComplete: asInt(m['progressToComplete']) ?? 0,
      activationDate: asDateTime(m['activationDate']),
      expirationDate: asDateTime(m['expirationDate']),
      objectives: {
        for (final o in asMapList(m['objectives']))
          ?lowerUuid(o['objectiveUuid']): asInt(o['value']) ?? 0,
      },
    );
  }

  final String uuid;

  /// vi mission text ("Sử dụng chiêu cuối của bạn").
  final String title;

  /// `Weekly` / `Daily` / `BTE` / `NPE` / `Tutorial`.
  final String? type;
  final int xpGrant;
  final int progressToComplete;
  final DateTime? activationDate;
  final DateTime? expirationDate;

  /// objectiveUuid → target value.
  final Map<String, int> objectives;

  bool get isWeekly => type == 'Weekly';
}
