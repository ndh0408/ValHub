/// Reward-source index built from `/v1/contracts` (C9, SUMMARY §8.3, CA §12):
/// which contract (battle pass, agent contract, event pass) grants a skin
/// level, buddy level, card, spray, title or flex, and at which level.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_db.dart';
import '../../content/content_repository.dart';

/// Where one item is granted.
@immutable
class RewardSourceEntry {
  const RewardSourceEntry({
    required this.contract,
    required this.itemUuid,
    required this.rewardType,
    required this.chapterIndex,
    required this.isFreeReward,
    this.level,
    this.isEpilogue = false,
  });

  final Contract contract;

  /// Rewarded uuid as listed in the contract (skin LEVEL / buddy LEVEL /
  /// card / spray / title / flex uuid), lowercase.
  final String itemUuid;
  final ContractRewardType rewardType;

  /// 0-based chapter of the contract.
  final int chapterIndex;

  /// Free track (`freeRewards`) rather than the premium track.
  final bool isFreeReward;

  /// 1-based premium-track level ("Cấp 25"); `null` for free rewards.
  final int? level;
  final bool isEpilogue;

  /// Season (battle pass) / Agent / Event.
  ContractRelation get relation => contract.relation;

  /// "Mùa 2026 // Phần V", "Trang Bị Cypher", "Champions 2026: Shanghai".
  String get contractName => contract.displayName;

  /// "Phần thưởng Battle Pass" / "Hợp đồng đặc vụ" / "Vé sự kiện"; `null`
  /// for contracts without a relation type.
  String? get label => relation.rewardSourceLabel;

  @override
  String toString() =>
      'RewardSourceEntry(${contract.uuid}, $itemUuid, level: $level)';
}

/// Immutable reward index. Currency rewards are not indexed.
///
/// When an item appears in several contracts, the first contract (content
/// order) with a known relation (Season / Agent / Event) wins; [allFor]
/// returns every occurrence.
class RewardSourceIndex {
  RewardSourceIndex._(this._byItem, this._db);

  static final empty = RewardSourceIndex._(const {}, null);

  /// Indexes every contract of [db]; skins are also resolvable by skin /
  /// chroma uuid through [db].
  factory RewardSourceIndex.fromContent(ContentDb db) =>
      RewardSourceIndex.fromContracts(db.contracts, db: db);

  factory RewardSourceIndex.fromContracts(
    Iterable<Contract> contracts, {
    ContentDb? db,
  }) {
    final byItem = <String, List<RewardSourceEntry>>{};
    void add(RewardSourceEntry e) =>
        byItem.putIfAbsent(e.itemUuid, () => []).add(e);

    for (final contract in contracts) {
      var level = 0;
      for (var ci = 0; ci < contract.chapters.length; ci++) {
        final chapter = contract.chapters[ci];
        for (final l in chapter.levels) {
          level++;
          final reward = l.reward;
          if (reward == null || !_indexed(reward.type)) continue;
          add(
            RewardSourceEntry(
              contract: contract,
              itemUuid: reward.uuid,
              rewardType: reward.type,
              chapterIndex: ci,
              isFreeReward: false,
              level: level,
              isEpilogue: chapter.isEpilogue,
            ),
          );
        }
        for (final reward in chapter.freeRewards) {
          if (!_indexed(reward.type)) continue;
          add(
            RewardSourceEntry(
              contract: contract,
              itemUuid: reward.uuid,
              rewardType: reward.type,
              chapterIndex: ci,
              isFreeReward: true,
              isEpilogue: chapter.isEpilogue,
            ),
          );
        }
      }
    }
    return RewardSourceIndex._({
      for (final e in byItem.entries) e.key: List.unmodifiable(e.value),
    }, db);
  }

  static bool _indexed(ContractRewardType type) =>
      type != ContractRewardType.currency && type != ContractRewardType.unknown;

  final Map<String, List<RewardSourceEntry>> _byItem;
  final ContentDb? _db;

  /// Number of distinct rewarded items.
  int get length => _byItem.length;

  /// Every contract granting [itemUuid] (content order).
  List<RewardSourceEntry> allFor(String itemUuid) =>
      _byItem[itemUuid.trim().toLowerCase()] ?? const [];

  /// Preferred source of [itemUuid] (a level uuid for skins and buddies).
  RewardSourceEntry? forItem(String itemUuid) {
    final all = allFor(itemUuid);
    for (final e in all) {
      if (e.relation != ContractRelation.other) return e;
    }
    return all.firstOrNull;
  }

  /// Source of a skin: checks every level (contracts list level 1).
  RewardSourceEntry? forSkin(WeaponSkin skin) {
    for (final l in skin.levels) {
      final e = forItem(l.uuid);
      if (e != null) return e;
    }
    return forItem(skin.uuid);
  }

  /// Source of a skin, level or chroma uuid (needs content; without it only
  /// the exact uuid is looked up).
  RewardSourceEntry? forSkinUuid(String anySkinUuid) {
    final skin = _db?.skinByAnyUuid(anySkinUuid);
    return skin == null ? forItem(anySkinUuid) : forSkin(skin);
  }

  /// Never-sold skins (C9): excluded from collection value, shown with a
  /// source label instead of a price.
  bool isRewardSkin(WeaponSkin skin) => forSkin(skin) != null;

  /// Source of a buddy (LEVEL uuid, or buddy uuid → its levels).
  RewardSourceEntry? forBuddy(String buddyOrLevelUuid) {
    final buddy = _db?.buddy(buddyOrLevelUuid);
    if (buddy == null) return forItem(buddyOrLevelUuid);
    for (final l in buddy.levels) {
      final e = forItem(l.uuid);
      if (e != null) return e;
    }
    return forItem(buddy.uuid);
  }
}

/// Reward index of the current content (empty until content loads).
///
/// ```dart
/// final source = ref.watch(rewardSourceIndexProvider).forSkin(skin);
/// Text(source?.label ?? priceText);   // "Phần thưởng Battle Pass"
/// ```
final rewardSourceIndexProvider = Provider<RewardSourceIndex>((ref) {
  final db = ref.watch(contentProvider).value;
  return db == null
      ? RewardSourceIndex.empty
      : RewardSourceIndex.fromContent(db);
});
