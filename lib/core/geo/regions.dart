import 'region_data.g.dart';

abstract final class RegionTable {
  static String? normalize(Object? value) {
    if (value is! String) return null;
    final id = value.trim().toLowerCase();
    return regionShards.containsKey(id) ? id : null;
  }

  static String? shardFor(String? region) =>
      regionShards[region?.toLowerCase()];
  static String? chatFor(String? region) =>
      regionChatAffinities[region?.toLowerCase()];
  static const visibleRegions = ['ap', 'eu', 'na', 'latam', 'br', 'kr'];
}
