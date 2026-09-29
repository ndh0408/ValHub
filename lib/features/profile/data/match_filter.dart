import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';

/// Queue ids offered as match-history filter chips after "Tất cả" (VF §6.5,
/// §8.9). They are PC ids; console accounts get `console_*` automatically.
const kProfileQueueFilters = <String>[
  'competitive',
  'unrated',
  'swiftplay',
  'spikerush',
  'deathmatch',
  'hurm',
  'ggteam',
  'premier',
  'onefa',
  'valaram',
  'snowball',
  'skirmish2v2',
  'dodgeball',
  'fortcollins',
];

/// Selected queue and map of a match-history list.
@immutable
class MatchFilter {
  const MatchFilter({this.queue, this.mapUrl});

  /// PC queue id; `null` = every queue ("Tất cả").
  final String? queue;

  /// Riot map path (`/Game/Maps/Ascent/Ascent`); `null` = every map.
  final String? mapUrl;

  bool get hasMap => mapUrl != null;

  MatchFilter withQueue(String? queue) =>
      MatchFilter(queue: queue, mapUrl: mapUrl);

  MatchFilter withMap(String? mapUrl) =>
      MatchFilter(queue: queue, mapUrl: mapUrl);

  /// Whether a match played on [mapId] passes the map filter.
  bool acceptsMap(String? mapId) {
    final wanted = mapUrl;
    if (wanted == null) return true;
    return mapId != null &&
        mapId.trim().toLowerCase() == wanted.trim().toLowerCase();
  }

  @override
  bool operator ==(Object other) =>
      other is MatchFilter && other.queue == queue && other.mapUrl == mapUrl;

  @override
  int get hashCode => Object.hash(queue, mapUrl);
}

final RegExp _nonPlayableMap = RegExp(
  r'/(poveglia|npe|npev2|range)\b',
  caseSensitive: false,
);

/// Maps offered by the map filter: every map with a Riot path and a name,
/// except the shooting range and the tutorial. Standard (site) maps first,
/// then the other modes' maps, each alphabetically.
List<GameMap> filterableMaps(ContentDb db) {
  final maps = [
    for (final m in db.maps)
      if (m.mapUrl.trim().isNotEmpty &&
          m.displayName.trim().isNotEmpty &&
          !_nonPlayableMap.hasMatch(m.mapUrl))
        m,
  ];
  int group(GameMap m) => m.tacticalDescription == null ? 1 : 0;
  maps.sort((a, b) {
    final g = group(a).compareTo(group(b));
    return g != 0 ? g : a.displayName.compareTo(b.displayName);
  });
  return maps;
}
