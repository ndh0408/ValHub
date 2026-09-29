import 'package:flutter/foundation.dart';

import '../../../core/util/json.dart';

/// Typed P-15 `GET /contracts/v1/contracts/{puuid}` (EP §12.1, SUMMARY §8.4).
///
/// Every field is optional in the payload: a missing contract means level 0,
/// a missing `Missions` array means no weekly missions. Never throws.
@immutable
class PlayerContracts {
  const PlayerContracts({
    required this.receivedAt,
    this.contracts = const [],
    this.missions = const [],
    this.metadata = const MissionMetadata(),
    this.activeSpecialContract,
    this.isFromCache = false,
  });

  factory PlayerContracts.fromJson(
    Object? json, {
    required DateTime receivedAt,
    bool isFromCache = false,
  }) {
    final m = asMap(json) ?? const <String, dynamic>{};
    return PlayerContracts(
      receivedAt: receivedAt,
      isFromCache: isFromCache,
      contracts: List.unmodifiable([
        for (final c in m.list('Contracts')) ?ContractProgress.fromJson(c),
      ]),
      missions: List.unmodifiable([
        for (final x in m.list('Missions')) ?ActiveMission.fromJson(x),
      ]),
      metadata: MissionMetadata.fromJson(m['MissionMetadata']),
      activeSpecialContract: m.uuid('ActiveSpecialContract'),
    );
  }

  /// When the response arrived (or was first received, for a cached copy).
  final DateTime receivedAt;

  /// `true` when this is the offline copy shown after a transient failure.
  final bool isFromCache;

  /// Battle passes, event passes, agent contracts…
  final List<ContractProgress> contracts;

  /// Currently assigned missions (weekly, plus NPE ones for new accounts).
  final List<ActiveMission> missions;
  final MissionMetadata metadata;

  /// Active agent contract (lowercase uuid), if any.
  final String? activeSpecialContract;

  /// Progress in the contract [contractId] (`null` = not started, level 0).
  ContractProgress? progressFor(String contractId) {
    final id = contractId.toLowerCase();
    for (final c in contracts) {
      if (c.contractId == id) return c;
    }
    return null;
  }

  PlayerContracts copyWith({bool? isFromCache, DateTime? receivedAt}) =>
      PlayerContracts(
        receivedAt: receivedAt ?? this.receivedAt,
        isFromCache: isFromCache ?? this.isFromCache,
        contracts: contracts,
        missions: missions,
        metadata: metadata,
        activeSpecialContract: activeSpecialContract,
      );
}

/// One `Contracts[]` entry.
@immutable
class ContractProgress {
  const ContractProgress({
    required this.contractId,
    this.levelReached = 0,
    this.xpTowardsNextLevel = 0,
    this.totalXpEarned = 0,
  });

  static ContractProgress? fromJson(Object? json) {
    final m = asMap(json);
    final id = m?.uuid('ContractDefinitionID');
    if (m == null || id == null || id.isEmpty) return null;
    final progression = m.obj('ContractProgression');
    return ContractProgress(
      contractId: id,
      levelReached: _nonNegative(m.integer('ProgressionLevelReached')),
      xpTowardsNextLevel: _nonNegative(
        m.integer('ProgressionTowardsNextLevel'),
      ),
      totalXpEarned: _nonNegative(
        progression?.integer('TotalProgressionEarned'),
      ),
    );
  }

  /// `ContractDefinitionID` (= valorant-api `/v1/contracts` uuid).
  final String contractId;

  /// `ProgressionLevelReached`: current tier.
  final int levelReached;

  /// `ProgressionTowardsNextLevel`: XP inside the current tier.
  final int xpTowardsNextLevel;

  /// `ContractProgression.TotalProgressionEarned`.
  final int totalXpEarned;
}

/// One `Missions[]` entry (joined with valorant-api `/v1/missions` by [id]).
@immutable
class ActiveMission {
  const ActiveMission({
    required this.id,
    this.objectives = const {},
    this.isComplete = false,
    this.expiresAt,
  });

  static ActiveMission? fromJson(Object? json) {
    final m = asMap(json);
    final id = m?.uuid('ID');
    if (m == null || id == null || id.isEmpty) return null;
    final objectives = <String, int>{};
    final raw = m.obj('Objectives');
    if (raw != null) {
      for (final e in raw.entries) {
        final key = lowerUuid(e.key);
        if (key == null) continue;
        objectives[key] = _nonNegative(asInt(e.value));
      }
    }
    return ActiveMission(
      id: id,
      objectives: Map.unmodifiable(objectives),
      isComplete: m.boolean('Complete') ?? false,
      expiresAt: m.dateTime('ExpirationTime'),
    );
  }

  /// Mission uuid (lowercase).
  final String id;

  /// objectiveUuid → current progress.
  final Map<String, int> objectives;
  final bool isComplete;
  final DateTime? expiresAt;

  /// Sum of the objectives' progress (weekly missions have one objective).
  int get progress => objectives.values.fold(0, (sum, v) => sum + v);
}

/// `MissionMetadata` (both dates may be absent).
@immutable
class MissionMetadata {
  const MissionMetadata({
    this.npeCompleted,
    this.weeklyCheckpoint,
    this.weeklyRefillTime,
  });

  factory MissionMetadata.fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return const MissionMetadata();
    return MissionMetadata(
      npeCompleted: m.boolean('NPECompleted'),
      weeklyCheckpoint: m.dateTime('WeeklyCheckpoint'),
      weeklyRefillTime: m.dateTime('WeeklyRefillTime'),
    );
  }

  final bool? npeCompleted;

  /// Activation date of the last completed weekly set.
  final DateTime? weeklyCheckpoint;

  /// When the next weekly missions arrive.
  final DateTime? weeklyRefillTime;
}

int _nonNegative(int? v) => v == null || v < 0 ? 0 : v;
