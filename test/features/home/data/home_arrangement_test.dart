import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_layout.dart';

const _visible = HomeCardPresence.visible;
const _hidden = HomeCardPresence.hidden;
const _loading = HomeCardPresence.loading;

HomeArrangement _arrange(
  HomeLayout layout,
  Map<HomeCardId, HomeCardPresence> presence, {
  bool liveActive = false,
  bool statusBlocking = false,
  List<HomeCardId>? asked,
}) => arrangeHomeCards(
  layout: layout,
  presenceOf: (id) {
    asked?.add(id);
    return presence[id] ?? _hidden;
  },
  liveActive: liveActive,
  statusBlocking: statusBlocking,
);

void main() {
  const all = {
    HomeCardId.live: _visible,
    HomeCardId.store: _visible,
    HomeCardId.rank: _visible,
    HomeCardId.battlePass: _visible,
    HomeCardId.friends: _visible,
    HomeCardId.community: _visible,
    HomeCardId.otherAccounts: _visible,
    HomeCardId.serverStatus: _visible,
  };

  test('every visible card follows the default order', () {
    final a = _arrange(HomeLayout.defaults, all);
    expect(a.pinned, isEmpty);
    expect(a.flow, kDefaultHomeOrder);
    expect(a.isEmpty, isFalse);
    expect(a.allUserHidden, isFalse);
  });

  test('user-hidden cards are never shown and never asked for', () {
    final asked = <HomeCardId>[];
    final layout = HomeLayout.defaults
        .withHidden(HomeCardId.community, hidden: true)
        .withHidden(HomeCardId.store, hidden: true);
    final a = _arrange(layout, all, asked: asked);
    expect(a.flow, isNot(contains(HomeCardId.community)));
    expect(a.flow, isNot(contains(HomeCardId.store)));
    expect(asked, isNot(contains(HomeCardId.community)));
    expect(asked, isNot(contains(HomeCardId.store)));
    expect(asked, contains(HomeCardId.rank));
  });

  test('a card without data is left out', () {
    final a = _arrange(HomeLayout.defaults, {
      HomeCardId.store: _visible,
      HomeCardId.rank: _hidden,
    });
    expect(a.flow, [HomeCardId.store]);
  });

  test('live is pinned only while it is active', () {
    final active = _arrange(HomeLayout.defaults, all, liveActive: true);
    expect(active.pinned, [HomeCardId.live]);
    expect(active.flow, isNot(contains(HomeCardId.live)));

    // Not active: it would have no data anyway; never pinned by default.
    final idle = _arrange(HomeLayout.defaults, all);
    expect(idle.pinned, isEmpty);
    expect(idle.flow.first, HomeCardId.live);
  });

  test('a blocking status is pinned above live', () {
    final a = _arrange(
      HomeLayout.defaults,
      all,
      liveActive: true,
      statusBlocking: true,
    );
    expect(a.pinned, [HomeCardId.serverStatus, HomeCardId.live]);
    expect(a.flow, [
      HomeCardId.store,
      HomeCardId.rank,
      HomeCardId.battlePass,
      HomeCardId.friends,
      HomeCardId.community,
      HomeCardId.otherAccounts,
    ]);
    expect(a.all.first, HomeCardId.serverStatus);
  });

  test('a non-blocking status keeps the position the user gave it', () {
    final layout = HomeLayout.defaults.moved(7, 1);
    final a = _arrange(layout, all);
    expect(a.pinned, isEmpty);
    expect(a.flow[1], HomeCardId.serverStatus);
  });

  test('a hidden card is not pinned, blocking or not', () {
    final layout = HomeLayout.defaults
        .withHidden(HomeCardId.serverStatus, hidden: true)
        .withHidden(HomeCardId.live, hidden: true);
    final a = _arrange(layout, all, liveActive: true, statusBlocking: true);
    expect(a.pinned, isEmpty);
    expect(a.all, isNot(contains(HomeCardId.serverStatus)));
    expect(a.all, isNot(contains(HomeCardId.live)));
  });

  test('core cards that load appear (skeleton); optional ones do not', () {
    // The presence provider maps loading to `loading` only for core cards;
    // the arrangement keeps whatever is not hidden.
    final a = _arrange(HomeLayout.defaults, {
      HomeCardId.store: _loading,
      HomeCardId.rank: _loading,
      HomeCardId.battlePass: _loading,
      HomeCardId.community: _hidden,
    });
    expect(a.flow, [HomeCardId.store, HomeCardId.rank, HomeCardId.battlePass]);
  });

  test('allUserHidden and an empty arrangement are reported', () {
    var layout = HomeLayout.defaults;
    for (final c in HomeCardId.values) {
      layout = layout.withHidden(c, hidden: true);
    }
    final none = _arrange(layout, all);
    expect(none.isEmpty, isTrue);
    expect(none.allUserHidden, isTrue);

    // Nothing to show, but the user switched nothing off: "quiet" state.
    final quiet = _arrange(HomeLayout.defaults, const {});
    expect(quiet.isEmpty, isTrue);
    expect(quiet.allUserHidden, isFalse);
  });
}
