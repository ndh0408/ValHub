import 'package:flutter/foundation.dart';

import '../geo/regions.dart';
import '../network/riot_exception.dart';

/// Maps a riot-geo `affinities.live` region to its PD shard (SUMMARY §4).
/// Unknown regions stay unresolved; no token is sent to guessed hosts.
String shardForRegion(String region) => RegionTable.shardFor(region) ?? '';

/// Regions VanHub supports (PBE hosts are unverified and hidden, U22).
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
  void _validate() {
    if (RegionTable.shardFor(region) != shard || shard.isEmpty) {
      throw const UnsupportedRegionException();
    }
  }

  String get pd {
    _validate();
    return 'https://pd.$shard.a.pvp.net';
  }

  /// `https://glz-{region}-1.{shard}.a.pvp.net`
  String get glz {
    _validate();
    return 'https://glz-$region-1.$shard.a.pvp.net';
  }

  /// `https://shared.{shard}.a.pvp.net`
  String get shared {
    _validate();
    return 'https://shared.$shard.a.pvp.net';
  }

  @override
  bool operator ==(Object other) =>
      other is RiotHosts && other.region == region && other.shard == shard;

  @override
  int get hashCode => Object.hash(region, shard);

  @override
  String toString() => 'RiotHosts($region/$shard)';
}
