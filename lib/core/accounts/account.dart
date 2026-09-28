import 'package:flutter/foundation.dart';

import '../l10n/account_strings.dart';
import '../riot/riot_hosts.dart';
import '../util/json.dart';

/// Game platform used to pick queues / MMR keys (A8). Default PC.
enum GamePlatform {
  pc,
  playstation,
  xbox;

  static GamePlatform parse(Object? value) => switch (asString(value)) {
    'playstation' => GamePlatform.playstation,
    'xbox' => GamePlatform.xbox,
    _ => GamePlatform.pc,
  };

  String get label => switch (this) {
    GamePlatform.pc => AccountStrings.platformPc,
    GamePlatform.playstation => AccountStrings.platformPlayStation,
    GamePlatform.xbox => AccountStrings.platformXbox,
  };

  bool get isConsole => this != GamePlatform.pc;
}

/// Non-secret account metadata (stored in prefs; SUMMARY §3.5). Secrets
/// (cookies, tokens) live in secure storage under the same PUUID.
@immutable
class Account {
  const Account({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    required this.region,
    required this.shard,
    this.platform = GamePlatform.pc,
    this.needsLogin = false,
    this.cardId,
    this.level,
    this.rankTier,
    this.rankSeasonId,
    this.addedAt,
  });

  static Account? fromJson(Object? json) {
    final m = asMap(json);
    final puuid = lowerUuid(m?['puuid']);
    if (m == null || puuid == null) return null;
    final region = asNonEmptyString(m['region'])?.toLowerCase() ?? 'ap';
    return Account(
      puuid: puuid,
      gameName: asString(m['gameName']) ?? '',
      tagLine: asString(m['tagLine']) ?? '',
      region: region,
      shard:
          asNonEmptyString(m['shard'])?.toLowerCase() ?? shardForRegion(region),
      platform: GamePlatform.parse(m['platform']),
      needsLogin: asBool(m['needsLogin']) ?? false,
      cardId: lowerUuid(m['cardId']),
      level: asInt(m['level']),
      rankTier: asInt(m['rankTier']),
      rankSeasonId: lowerUuid(m['rankSeasonId']),
      addedAt: asDateTime(m['addedAt']),
    );
  }

  final String puuid;
  final String gameName;
  final String tagLine;

  /// riot-geo `affinities.live` (e.g. `ap`).
  final String region;

  /// PD shard (e.g. `ap`).
  final String shard;
  final GamePlatform platform;

  /// Cookies are dead; the account must sign in again (never loops).
  final bool needsLogin;

  /// Cached for the switcher (A4): equipped player card uuid.
  final String? cardId;

  /// Cached account level.
  final int? level;

  /// Cached competitive tier and the act it belongs to.
  final int? rankTier;
  final String? rankSeasonId;
  final DateTime? addedAt;

  /// `Name#TAG`, or a generic label when the Riot ID is unknown.
  String get riotId => gameName.isEmpty
      ? AccountStrings.unknownPlayer
      : (tagLine.isEmpty ? gameName : '$gameName#$tagLine');

  RiotHosts get hosts => RiotHosts(region: region, shard: shard);

  JsonMap toJson() => {
    'puuid': puuid,
    'gameName': gameName,
    'tagLine': tagLine,
    'region': region,
    'shard': shard,
    'platform': platform.name,
    'needsLogin': needsLogin,
    'cardId': cardId,
    'level': level,
    'rankTier': rankTier,
    'rankSeasonId': rankSeasonId,
    'addedAt': addedAt?.toUtc().toIso8601String(),
  };

  Account copyWith({
    String? gameName,
    String? tagLine,
    String? region,
    String? shard,
    GamePlatform? platform,
    bool? needsLogin,
    String? cardId,
    int? level,
    int? rankTier,
    String? rankSeasonId,
  }) => Account(
    puuid: puuid,
    gameName: gameName ?? this.gameName,
    tagLine: tagLine ?? this.tagLine,
    region: region ?? this.region,
    shard: shard ?? this.shard,
    platform: platform ?? this.platform,
    needsLogin: needsLogin ?? this.needsLogin,
    cardId: cardId ?? this.cardId,
    level: level ?? this.level,
    rankTier: rankTier ?? this.rankTier,
    rankSeasonId: rankSeasonId ?? this.rankSeasonId,
    addedAt: addedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.puuid == puuid &&
      other.gameName == gameName &&
      other.tagLine == tagLine &&
      other.region == region &&
      other.shard == shard &&
      other.platform == platform &&
      other.needsLogin == needsLogin &&
      other.cardId == cardId &&
      other.level == level &&
      other.rankTier == rankTier &&
      other.rankSeasonId == rankSeasonId;

  @override
  int get hashCode => Object.hash(
    puuid,
    gameName,
    tagLine,
    region,
    shard,
    platform,
    needsLogin,
    cardId,
    level,
    rankTier,
    rankSeasonId,
  );

  /// Never prints the PUUID.
  @override
  String toString() => 'Account($region, needsLogin: $needsLogin)';
}

/// Thrown when adding an 11th account.
class MaxAccountsException implements Exception {
  const MaxAccountsException(this.max);
  final int max;

  String get message => AccountStrings.maxAccounts(max);

  @override
  String toString() => 'MaxAccountsException($max)';
}
