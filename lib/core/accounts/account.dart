import 'package:flutter/foundation.dart';

import '../l10n/account_strings.dart';
import '../geo/regions.dart';
import '../geo/countries.dart' show normalizeCountry;
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

enum RegionMode { auto, manual }

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
    this.regionMode = RegionMode.auto,
    this.detectedRegion,
    this.manualRegion,
    this.country,
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
    final mode = m['regionMode'] == 'manual'
        ? RegionMode.manual
        : RegionMode.auto;
    final detected =
        asNonEmptyString(m['detectedRegion'])?.toLowerCase() ??
        asNonEmptyString(m['region'])?.toLowerCase();
    final manual = RegionTable.normalize(m['manualRegion']);
    final region = (mode == RegionMode.manual ? manual : detected) ?? '';
    final country = normalizeCountry(m['country']);
    return Account(
      puuid: puuid,
      gameName: asString(m['gameName']) ?? '',
      tagLine: asString(m['tagLine']) ?? '',
      region: region,
      shard: shardForRegion(region),
      regionMode: mode,
      detectedRegion: detected,
      manualRegion: manual,
      country: country,
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
  final RegionMode regionMode;
  final String? detectedRegion;
  String? get autoRegion =>
      detectedRegion ??
      (regionMode == RegionMode.auto && region.isNotEmpty ? region : null);
  final String? manualRegion;
  final String? country;
  bool get needsRegionSelection => RegionTable.normalize(region) == null;
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
    'regionMode': regionMode.name,
    'detectedRegion':
        detectedRegion ?? (regionMode == RegionMode.auto ? region : null),
    'manualRegion': manualRegion,
    'country': country,
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
    RegionMode? regionMode,
    String? detectedRegion,
    String? manualRegion,
    String? country,
    GamePlatform? platform,
    bool? needsLogin,
    String? cardId,
    int? level,
    int? rankTier,
    String? rankSeasonId,
  }) {
    final mode = regionMode ?? this.regionMode;
    final detected =
        detectedRegion ??
        (region != null && mode == RegionMode.auto
            ? region
            : this.detectedRegion ?? this.region);
    final manual = manualRegion ?? this.manualRegion;
    final effective = mode == RegionMode.manual ? manual ?? '' : detected;
    return Account(
      puuid: puuid,
      gameName: gameName ?? this.gameName,
      tagLine: tagLine ?? this.tagLine,
      region: effective,
      shard: shardForRegion(effective),
      regionMode: mode,
      detectedRegion: detected,
      manualRegion: manual,
      country: country ?? this.country,
      platform: platform ?? this.platform,
      needsLogin: needsLogin ?? this.needsLogin,
      cardId: cardId ?? this.cardId,
      level: level ?? this.level,
      rankTier: rankTier ?? this.rankTier,
      rankSeasonId: rankSeasonId ?? this.rankSeasonId,
      addedAt: addedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.puuid == puuid &&
      other.gameName == gameName &&
      other.tagLine == tagLine &&
      other.region == region &&
      other.shard == shard &&
      other.regionMode == regionMode &&
      other.autoRegion == autoRegion &&
      other.manualRegion == manualRegion &&
      other.country == country &&
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
    regionMode,
    autoRegion,
    manualRegion,
    country,
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
