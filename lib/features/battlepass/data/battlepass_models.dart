import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import 'player_contracts.dart';

/// Average XP of one Unrated / Competitive match used by the "≈ n trận"
/// estimate (VF §6.3, a ValVN extra). Missions are not counted, so the real
/// number of matches is usually lower.
const kEstimatedXpPerMatch = 4000;

/// Progress in one contract (battle pass or event pass), SUMMARY §9.4.
@immutable
class PassProgress {
  const PassProgress._({
    required this.contract,
    required this.level,
    required this.levelCount,
    required this.xpInLevel,
    required this.xpForNextLevel,
    required this.totalXpEarned,
    required this.totalXp,
  });

  /// Combines the valorant-api [contract] with the player's [progress]
  /// (`null` = the contract is missing from P-15, i.e. level 0).
  factory PassProgress.compute(Contract contract, ContractProgress? progress) {
    final flat = contract.flatLevels;
    final count = flat.length;
    final level = (progress?.levelReached ?? 0).clamp(0, count);
    final complete = level >= count;
    final next = complete ? null : contract.xpForNextLevel(level);
    final xpNeeded = next != null && next > 0 ? next : null;
    final inLevel = complete ? 0 : (progress?.xpTowardsNextLevel ?? 0);
    final totalXp = contract.totalXp;
    var earned = progress?.totalXpEarned ?? 0;
    if (earned <= 0 && level > 0) {
      // TotalProgressionEarned missing: rebuild it from the levels reached.
      earned =
          flat.take(level).fold(0, (sum, l) => sum + l.xp) +
          (xpNeeded == null ? 0 : math.min(inLevel, xpNeeded));
    }
    return PassProgress._(
      contract: contract,
      level: level,
      levelCount: count,
      xpInLevel: xpNeeded == null ? inLevel : math.min(inLevel, xpNeeded),
      xpForNextLevel: xpNeeded,
      totalXpEarned: totalXp > 0 ? math.min(earned, totalXp) : earned,
      totalXp: totalXp,
    );
  }

  final Contract contract;

  /// `ProgressionLevelReached`, clamped to `0…levelCount`.
  final int level;

  /// Number of levels (55 for 2026 passes; never hard-coded).
  final int levelCount;

  /// XP inside the current level ("7.966").
  final int xpInLevel;

  /// XP needed for the next level ("35.750"); `null` once the pass is
  /// complete or when the next level needs no XP.
  final int? xpForNextLevel;

  /// Total XP earned in this pass ("840.466").
  final int totalXpEarned;

  /// Σ XP of every level ("1.162.500").
  final int totalXp;

  bool get isComplete => levelCount > 0 && level >= levelCount;

  /// Level bar fill, 0–1.
  double get levelFraction {
    if (isComplete) return 1;
    final need = xpForNextLevel;
    if (need == null || need <= 0) return 0;
    return (xpInLevel / need).clamp(0.0, 1.0);
  }

  /// Whole-pass bar fill, 0–1.
  double get totalFraction {
    if (isComplete) return 1;
    if (totalXp <= 0) return 0;
    return (totalXpEarned / totalXp).clamp(0.0, 1.0);
  }

  /// XP left to finish the pass.
  int get xpRemaining => isComplete ? 0 : math.max(0, totalXp - totalXpEarned);

  /// Levels unlocked ("46/55 đã mở khóa").
  int get unlockedLevels => math.min(level, levelCount);

  /// Matches still needed at [xpPerMatch] XP each (ceil), 0 when complete.
  int estimatedMatches({int xpPerMatch = kEstimatedXpPerMatch}) {
    final left = xpRemaining;
    if (left <= 0 || xpPerMatch <= 0) return 0;
    return (left / xpPerMatch).ceil();
  }
}

/// Whether a reward is unlocked for the player.
enum RewardState {
  /// Level reached (and premium owned for premium-track rewards).
  unlocked,

  /// Level not reached yet.
  locked,

  /// Level reached, but the premium track was not bought.
  needsPremium,
}

/// One reward of the track (S21 tile).
@immutable
class RewardTier {
  const RewardTier({
    required this.level,
    required this.reward,
    required this.state,
    this.isFree = false,
  });

  /// 1-based level that grants this reward (free rewards: the chapter's
  /// last level).
  final int level;
  final ContractReward? reward;
  final RewardState state;

  /// Free-track reward ("Miễn phí" tag).
  final bool isFree;

  bool get isUnlocked => state == RewardState.unlocked;
}

/// One chapter of the track ("Chương 3" / "Phần mở rộng").
@immutable
class RewardChapter {
  const RewardChapter({
    required this.number,
    required this.isEpilogue,
    required this.firstLevel,
    required this.lastLevel,
    required this.premium,
    required this.free,
    required this.isCurrent,
  });

  /// 1-based among the normal chapters (epilogues keep counting too, but
  /// render as "Phần mở rộng").
  final int number;
  final bool isEpilogue;
  final int firstLevel;
  final int lastLevel;
  final List<RewardTier> premium;
  final List<RewardTier> free;

  /// The chapter holding the next level to unlock.
  final bool isCurrent;

  List<RewardTier> get all => [...premium, ...free];

  /// Premium-track levels reached in this chapter.
  int levelsReached(int level) =>
      (level - firstLevel + 1).clamp(0, lastLevel - firstLevel + 1);

  int get levelCount => lastLevel - firstLevel + 1;
}

/// Builds the S21 reward track of [contract] for a player at [level].
///
/// Premium-track rewards unlock at their level when [isPremium] is `true`
/// (or unknown); free-track rewards (`chapters[].freeRewards`) unlock when
/// the chapter's last level is reached.
List<RewardChapter> buildRewardTrack(
  Contract contract, {
  required int level,
  bool? isPremium,
}) {
  final chapters = <RewardChapter>[];
  final premiumOwned = isPremium ?? true;
  var next = 1;
  var number = 0;
  var currentAssigned = false;
  for (final c in contract.chapters) {
    if (c.levels.isEmpty && c.freeRewards.isEmpty) continue;
    number++;
    final first = next;
    final last = next + c.levels.length - 1;
    next = last + 1;
    final chapterEnd = math.max(first, last);
    final premium = <RewardTier>[
      for (var i = 0; i < c.levels.length; i++)
        RewardTier(
          level: first + i,
          reward: c.levels[i].reward,
          state: level < first + i
              ? RewardState.locked
              : premiumOwned
              ? RewardState.unlocked
              : RewardState.needsPremium,
        ),
    ];
    final free = <RewardTier>[
      for (final r in c.freeRewards)
        RewardTier(
          level: chapterEnd,
          reward: r,
          isFree: true,
          state: level >= chapterEnd && c.levels.isNotEmpty
              ? RewardState.unlocked
              : RewardState.locked,
        ),
    ];
    final isCurrent = !currentAssigned && level < last;
    if (isCurrent) currentAssigned = true;
    chapters.add(
      RewardChapter(
        number: number,
        isEpilogue: c.isEpilogue,
        firstLevel: first,
        lastLevel: math.max(first, last),
        premium: List.unmodifiable(premium),
        free: List.unmodifiable(free),
        isCurrent: isCurrent,
      ),
    );
  }
  return List.unmodifiable(chapters);
}

/// A weekly mission joined with its valorant-api definition.
@immutable
class WeeklyMissionView {
  const WeeklyMissionView({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.xpGrant,
    required this.isComplete,
  });

  final String id;

  /// vi title; `null` when the mission is not in the content yet.
  final String? title;
  final int progress;
  final int target;
  final int xpGrant;
  final bool isComplete;

  double get fraction {
    if (isComplete) return 1;
    if (target <= 0) return 0;
    return (progress / target).clamp(0.0, 1.0);
  }
}

/// The weekly missions section (SUMMARY §8.4 P3).
@immutable
class WeeklyMissions {
  const WeeklyMissions({
    this.missions = const [],
    this.refillAt,
    this.unknownIds = const {},
  });

  /// Incomplete missions first, then completed ones (stable order).
  final List<WeeklyMissionView> missions;

  /// When the next weekly missions arrive (header countdown).
  final DateTime? refillAt;

  /// Mission ids missing from the content (report a content miss).
  final Set<String> unknownIds;

  bool get isEmpty => missions.isEmpty;

  int get completedCount => missions.where((m) => m.isComplete).length;

  bool get isAllComplete =>
      missions.isNotEmpty && completedCount == missions.length;

  /// XP still available from incomplete missions.
  int get xpAvailable =>
      missions.where((m) => !m.isComplete).fold(0, (sum, m) => sum + m.xpGrant);
}

/// Joins P-15 `Missions[]` with valorant-api `/v1/missions`. Only weekly
/// missions are kept; missions unknown to the content are kept too (with a
/// `null` title) so a new patch never hides them.
WeeklyMissions buildWeeklyMissions(
  PlayerContracts contracts,
  ContentDb db, {
  required DateTime now,
}) {
  final open = <WeeklyMissionView>[];
  final done = <WeeklyMissionView>[];
  final unknown = <String>{};
  DateTime? earliestExpiry;
  for (final m in contracts.missions) {
    final def = db.mission(m.id);
    if (def == null) {
      unknown.add(m.id);
    } else if (!def.isWeekly) {
      continue;
    }
    final objectiveTargets = def?.objectives.values.fold(0, (s, v) => s + v);
    var target = def != null && def.progressToComplete > 0
        ? def.progressToComplete
        : (objectiveTargets ?? 0);
    if (target <= 0) target = math.max(m.progress, 1);
    final view = WeeklyMissionView(
      id: m.id,
      title: def?.title.isNotEmpty ?? false ? def!.title : null,
      progress: m.isComplete ? target : math.min(m.progress, target),
      target: target,
      xpGrant: def?.xpGrant ?? 0,
      isComplete: m.isComplete,
    );
    (m.isComplete ? done : open).add(view);
    final exp = m.expiresAt;
    if (exp != null &&
        exp.isAfter(now) &&
        (earliestExpiry == null || exp.isBefore(earliestExpiry))) {
      earliestExpiry = exp;
    }
  }
  final refill = contracts.metadata.weeklyRefillTime;
  return WeeklyMissions(
    missions: List.unmodifiable([...open, ...done]),
    refillAt: refill != null && refill.isAfter(now) ? refill : earliestExpiry,
    unknownIds: Set.unmodifiable(unknown),
  );
}

/// An active event pass ("Vé sự kiện") the player can progress.
@immutable
class EventPassInfo {
  const EventPassInfo({required this.progress, this.endsAt, this.eventName});

  final PassProgress progress;
  final DateTime? endsAt;
  final String? eventName;
}

/// Everything S20 shows except the daily checkpoints.
@immutable
class BattlePassOverview {
  const BattlePassOverview({
    required this.contracts,
    required this.weekly,
    this.battlePass,
    this.actEndsAt,
    this.premiumContracts,
    this.eventPasses = const [],
  });

  /// Combines content, P-15 and the premium-contract entitlements
  /// ([premiumContracts] `null` = unknown).
  factory BattlePassOverview.build({
    required ContentDb db,
    required PlayerContracts contracts,
    required DateTime now,
    Set<String>? premiumContracts,
  }) {
    final bp = db.currentBattlePass(now);
    final actId = bp?.relationUuid;
    final events = <EventPassInfo>[];
    for (final c in db.contracts) {
      if (c.relation != ContractRelation.event || c.flatLevels.isEmpty) {
        continue;
      }
      final eventId = c.relationUuid;
      final event = eventId == null ? null : db.event(eventId);
      if (event == null || !event.isActiveAt(now.toUtc())) continue;
      events.add(
        EventPassInfo(
          progress: PassProgress.compute(c, contracts.progressFor(c.uuid)),
          endsAt: event.endTime,
          eventName: event.displayName.isEmpty ? null : event.displayName,
        ),
      );
    }
    return BattlePassOverview(
      contracts: contracts,
      weekly: buildWeeklyMissions(contracts, db, now: now),
      battlePass: bp == null
          ? null
          : PassProgress.compute(bp, contracts.progressFor(bp.uuid)),
      actEndsAt: actId == null ? null : db.season(actId)?.endTime,
      premiumContracts: premiumContracts,
      eventPasses: List.unmodifiable(events),
    );
  }

  final PlayerContracts contracts;
  final WeeklyMissions weekly;

  /// `null` when the content has no current battle pass.
  final PassProgress? battlePass;

  /// End of the act the pass belongs to.
  final DateTime? actEndsAt;

  /// Contracts whose premium track was bought (`null` = unknown).
  final Set<String>? premiumContracts;
  final List<EventPassInfo> eventPasses;

  /// Premium track of the current battle pass bought (`null` = unknown).
  bool? get isPremium {
    final bp = battlePass;
    return bp == null ? null : isPremiumFor(bp.contract.uuid);
  }

  /// Premium track of [contractId] bought (`null` = unknown).
  bool? isPremiumFor(String contractId) =>
      premiumContracts?.contains(contractId.toLowerCase());

  /// Progress of the contract [contractId] (battle pass or event pass).
  PassProgress? passFor(String contractId) {
    final id = contractId.toLowerCase();
    if (battlePass?.contract.uuid == id) return battlePass;
    for (final e in eventPasses) {
      if (e.progress.contract.uuid == id) return e.progress;
    }
    return null;
  }
}
