import 'package:flutter/foundation.dart';

/// Maps a riot-geo `affinities.live` region to its PD shard (SUMMARY §4).
/// Unknown regions fall back to themselves.
String shardForRegion(String region) => switch (region.toLowerCase()) {
  'na' || 'latam' || 'br' => 'na',
  'eu' => 'eu',
  'ap' => 'ap',
  'kr' => 'kr',
  'pbe' => 'pbe',
  final other => other,
};

/// Regions ValVN supports (PBE hosts are unverified and hidden, U22).
const supportedRegions = {'ap', 'na', 'latam', 'br', 'eu', 'kr'};

/// Base URLs for one account's game servers. Keep region and shard separate:
/// GLZ needs both (`glz-latam-1.na.a.pvp.net`).
@immutable
class RiotHosts {
  const RiotHosts({required this.region, required this.shard});

  /// Hosts for a riot-geo region, e.g. `ap`.
  factory RiotHosts.forRegion(String region) {
    final r = region.toLowerCase();
    return RiotHosts(region: r, shard: shardForRegion(r));
  }

  final String region;
  final String shard;

  /// `https://pd.{shard}.a.pvp.net`
  String get pd => 'https://pd.$shard.a.pvp.net';

  /// `https://glz-{region}-1.{shard}.a.pvp.net`
  String get glz => 'https://glz-$region-1.$shard.a.pvp.net';

  /// `https://shared.{shard}.a.pvp.net`
  String get shared => 'https://shared.$shard.a.pvp.net';

  @override
  bool operator ==(Object other) =>
      other is RiotHosts && other.region == region && other.shard == shard;

  @override
  int get hashCode => Object.hash(region, shard);

  @override
  String toString() => 'RiotHosts($region/$shard)';
}
