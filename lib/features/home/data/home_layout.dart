/// The user's Home layout (order + hidden cards) and how it is combined with
/// what each card can show right now (docs/design/HOME.md §3.3, §7).
library;

import 'package:flutter/foundation.dart';

import '../../../core/util/json.dart';
import 'home_card.dart';

/// Order and visibility chosen in "Tùy chỉnh Trang chủ". Stored in Prefs as
/// `{"v":1,"order":["live",…],"hidden":["community"]}` (app-wide, not per
/// account).
@immutable
class HomeLayout {
  const HomeLayout({required this.order, this.hidden = const {}});

  static const defaults = HomeLayout(order: kDefaultHomeOrder);

  /// Never throws. A non-map value gives [defaults]; unknown and duplicate
  /// ids are dropped; a card missing from the stored order (added in a later
  /// version) is inserted right after its closest default predecessor that
  /// is present, else at index 0, and is visible.
  factory HomeLayout.fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return defaults;
    final order = <HomeCardId>[];
    for (final raw in asList(m['order'])) {
      final id = HomeCardId.tryParse(asString(raw));
      if (id != null && !order.contains(id)) order.add(id);
    }
    for (var i = 0; i < kDefaultHomeOrder.length; i++) {
      final id = kDefaultHomeOrder[i];
      if (order.contains(id)) continue;
      var at = 0;
      for (var j = i - 1; j >= 0; j--) {
        final k = order.indexOf(kDefaultHomeOrder[j]);
        if (k >= 0) {
          at = k + 1;
          break;
        }
      }
      order.insert(at, id);
    }
    final hidden = <HomeCardId>{
      for (final raw in asList(m['hidden']))
        ?HomeCardId.tryParse(asString(raw)),
    };
    return HomeLayout(
      order: List.unmodifiable(order),
      hidden: Set.unmodifiable(hidden),
    );
  }

  /// Every card, in the user's order (always all [HomeCardId.values]).
  final List<HomeCardId> order;
  final Set<HomeCardId> hidden;

  JsonMap toJson() => {
    'v': 1,
    'order': [for (final c in order) c.storageId],
    'hidden': [
      for (final c in order)
        if (hidden.contains(c)) c.storageId,
    ],
  };

  bool isHidden(HomeCardId id) => hidden.contains(id);

  /// `ReorderableListView` semantics: [to] is an index of the list before
  /// the item is removed (so moving down passes `to + 1`).
  HomeLayout moved(int from, int to) {
    if (from < 0 || from >= order.length) return this;
    var target = to;
    if (target > from) target -= 1;
    target = target.clamp(0, order.length - 1);
    if (target == from) return this;
    final list = [...order];
    final item = list.removeAt(from);
    list.insert(target, item);
    return HomeLayout(order: List.unmodifiable(list), hidden: hidden);
  }

  HomeLayout withHidden(HomeCardId id, {required bool hidden}) {
    if (this.hidden.contains(id) == hidden) return this;
    final next = {...this.hidden};
    hidden ? next.add(id) : next.remove(id);
    return HomeLayout(order: order, hidden: Set.unmodifiable(next));
  }

  @override
  bool operator ==(Object other) =>
      other is HomeLayout &&
      listEquals(other.order, order) &&
      setEquals(other.hidden, hidden);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(order), Object.hashAllUnordered(hidden));
}

/// The cards Home shows, split into the full-width pinned ones and the flow
/// that follows the user's order.
@immutable
class HomeArrangement {
  const HomeArrangement({
    this.pinned = const [],
    this.flow = const [],
    this.allUserHidden = false,
  });

  /// Full width, above the columns: a blocking status, then a live match.
  final List<HomeCardId> pinned;

  /// The user's order.
  final List<HomeCardId> flow;

  /// Every card is switched off in "Tùy chỉnh Trang chủ".
  final bool allUserHidden;

  bool get isEmpty => pinned.isEmpty && flow.isEmpty;

  /// Pinned cards first, then the flow.
  List<HomeCardId> get all => [...pinned, ...flow];

  @override
  bool operator ==(Object other) =>
      other is HomeArrangement &&
      listEquals(other.pinned, pinned) &&
      listEquals(other.flow, flow) &&
      other.allUserHidden == allUserHidden;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(pinned), Object.hashAll(flow), allUserHidden);
}

/// Pure. [presenceOf] is only called for the cards the user did not hide, so
/// hidden cards never watch their data.
///
/// - shown = the layout's order without hidden cards and without cards whose
///   presence is [HomeCardPresence.hidden];
/// - pinned = a blocking status (first), then a live match;
/// - flow = shown − pinned.
HomeArrangement arrangeHomeCards({
  required HomeLayout layout,
  required HomeCardPresence Function(HomeCardId) presenceOf,
  required bool liveActive,
  required bool statusBlocking,
}) {
  final shown = <HomeCardId>[
    for (final id in layout.order)
      if (!layout.isHidden(id) && presenceOf(id) != HomeCardPresence.hidden) id,
  ];
  final pinned = <HomeCardId>[
    if (statusBlocking && shown.contains(HomeCardId.serverStatus))
      HomeCardId.serverStatus,
    if (liveActive && shown.contains(HomeCardId.live)) HomeCardId.live,
  ];
  return HomeArrangement(
    pinned: List.unmodifiable(pinned),
    flow: List.unmodifiable([
      for (final id in shown)
        if (!pinned.contains(id)) id,
    ]),
    allUserHidden: layout.order.every(layout.isHidden),
  );
}
