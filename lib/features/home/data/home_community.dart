/// "Cộng đồng" card model (docs/design/HOME.md §5.6). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../community/data/community_models.dart';

/// LFG rows on the card.
const kHomeMaxLfg = 2;

/// Trending skins on the card.
const kHomeMaxTrending = 3;

/// LFG posts that fit the viewer's rank and this week's hot skins.
@immutable
class HomeCommunitySnapshot {
  const HomeCommunitySnapshot({
    this.lfg = const [],
    this.trending = const [],
    this.wishlist = const {},
  });

  /// At most [kHomeMaxLfg], newest first.
  final List<LfgPost> lfg;

  /// At most [kHomeMaxTrending], most voted first.
  final List<TopSkin> trending;

  /// The viewer's wishlist (skin uuids), to mark trending skins with a ♥.
  final Set<String> wishlist;

  bool get isEmpty => lfg.isEmpty && trending.isEmpty;
}

/// The card's snapshot; `null` when both lists are empty.
HomeCommunitySnapshot? buildHomeCommunitySnapshot({
  required List<LfgPost> lfg,
  required List<TopSkin> trending,
  Set<String> wishlist = const {},
}) {
  final snapshot = HomeCommunitySnapshot(
    lfg: List.unmodifiable(lfg.take(kHomeMaxLfg)),
    trending: List.unmodifiable(trending.take(kHomeMaxTrending)),
    wishlist: wishlist,
  );
  return snapshot.isEmpty ? null : snapshot;
}
