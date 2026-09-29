import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_layout.dart';

void main() {
  test('the default order is the IA order', () {
    expect(kDefaultHomeOrder, [
      HomeCardId.live,
      HomeCardId.store,
      HomeCardId.rank,
      HomeCardId.battlePass,
      HomeCardId.friends,
      HomeCardId.community,
      HomeCardId.otherAccounts,
      HomeCardId.serverStatus,
    ]);
    expect(HomeLayout.defaults.order, kDefaultHomeOrder);
    expect(HomeLayout.defaults.hidden, isEmpty);
  });

  test('storage ids are stable and parse both ways', () {
    expect(HomeCardId.battlePass.storageId, 'battlepass');
    expect(HomeCardId.otherAccounts.storageId, 'accounts');
    expect(HomeCardId.serverStatus.storageId, 'status');
    for (final c in HomeCardId.values) {
      expect(HomeCardId.tryParse(c.storageId), c);
    }
    expect(HomeCardId.tryParse(' store '), HomeCardId.store);
    expect(HomeCardId.tryParse('nope'), isNull);
    expect(HomeCardId.tryParse(null), isNull);
    expect(HomeCardId.tryParse(''), isNull);
  });

  test('JSON round-trip keeps the order and the hidden cards', () {
    final layout = HomeLayout.defaults
        .moved(0, 3)
        .withHidden(HomeCardId.community, hidden: true)
        .withHidden(HomeCardId.live, hidden: true);
    final json = layout.toJson();
    expect(json['v'], 1);
    expect(HomeLayout.fromJson(json), layout);
    expect(HomeLayout.fromJson(json).order, layout.order);
    expect(json['hidden'], ['live', 'community']);
  });

  test('a corrupt or non-map value gives the defaults', () {
    expect(HomeLayout.fromJson(null), HomeLayout.defaults);
    expect(HomeLayout.fromJson('nonsense'), HomeLayout.defaults);
    expect(HomeLayout.fromJson(42), HomeLayout.defaults);
    expect(HomeLayout.fromJson(<Object?>[1, 2]), HomeLayout.defaults);
    // A map without usable fields: the default order, nothing hidden.
    expect(
      HomeLayout.fromJson({'order': 5, 'hidden': 'x'}),
      HomeLayout.defaults,
    );
  });

  test('unknown and duplicate ids are dropped', () {
    final layout = HomeLayout.fromJson({
      'v': 1,
      'order': ['rank', 'ghost', 'rank', 'store', 7, null],
      'hidden': ['store', 'ghost', 'store'],
    });
    expect(layout.order.where((c) => c == HomeCardId.rank), hasLength(1));
    // "live" is missing from the stored order and has no predecessor: index
    // 0; the stored relative order of the others is kept.
    expect(layout.order.first, HomeCardId.live);
    expect(layout.order.indexOf(HomeCardId.rank), 1);
    expect(
      layout.order.indexOf(HomeCardId.rank),
      lessThan(layout.order.indexOf(HomeCardId.store)),
    );
    expect(layout.order, hasLength(HomeCardId.values.length));
    expect(layout.hidden, {HomeCardId.store});
  });

  test('a card missing from the stored order goes after its predecessor', () {
    // Stored by an older version that had no "friends" and no "live".
    final layout = HomeLayout.fromJson({
      'v': 1,
      'order': [
        'status',
        'store',
        'rank',
        'battlepass',
        'community',
        'accounts',
      ],
    });
    // "live" has no predecessor: index 0. "friends" comes after the closest
    // default predecessor that is present ("battlepass").
    expect(layout.order.first, HomeCardId.live);
    final friends = layout.order.indexOf(HomeCardId.friends);
    expect(layout.order[friends - 1], HomeCardId.battlePass);
    expect(layout.order, hasLength(HomeCardId.values.length));
    // New cards are visible by default.
    expect(layout.isHidden(HomeCardId.friends), isFalse);
    expect(layout.isHidden(HomeCardId.live), isFalse);
  });

  test('a future version still parses the known fields', () {
    final layout = HomeLayout.fromJson({
      'v': 9,
      'order': ['store', 'live'],
      'hidden': ['rank'],
      'somethingNew': true,
    });
    // "rank" is missing from the stored order: right after its closest
    // default predecessor ("store").
    expect(layout.order.take(2), [HomeCardId.store, HomeCardId.rank]);
    // "battlepass" follows its own closest present predecessor: "rank".
    expect(layout.order[2], HomeCardId.battlePass);
    expect(layout.order.contains(HomeCardId.live), isTrue);
    expect(layout.hidden, {HomeCardId.rank});
  });

  group('moved (ReorderableListView semantics)', () {
    HomeLayout m(int from, int to) => HomeLayout.defaults.moved(from, to);

    test('forward: the target index is before the removal', () {
      // Move "live" (0) below "store" (to = 2): store, live, rank…
      expect(m(0, 2).order.take(3), [
        HomeCardId.store,
        HomeCardId.live,
        HomeCardId.rank,
      ]);
    });

    test('backward', () {
      expect(m(3, 1).order.take(4), [
        HomeCardId.live,
        HomeCardId.battlePass,
        HomeCardId.store,
        HomeCardId.rank,
      ]);
    });

    test('edges: to the end and to the start', () {
      expect(m(0, 8).order.last, HomeCardId.live);
      expect(m(7, 0).order.first, HomeCardId.serverStatus);
    });

    test('a no-op and out-of-range moves change nothing', () {
      expect(m(2, 2), HomeLayout.defaults);
      expect(m(2, 3), HomeLayout.defaults);
      expect(m(-1, 3), HomeLayout.defaults);
      expect(m(20, 3), HomeLayout.defaults);
    });

    test('hidden cards keep their flag while moving', () {
      final layout = HomeLayout.defaults
          .withHidden(HomeCardId.live, hidden: true)
          .moved(0, 8);
      expect(layout.order.last, HomeCardId.live);
      expect(layout.isHidden(HomeCardId.live), isTrue);
    });
  });

  test('hide, show and reset', () {
    var layout = HomeLayout.defaults;
    layout = layout.withHidden(HomeCardId.rank, hidden: true);
    expect(layout.isHidden(HomeCardId.rank), isTrue);
    layout = layout.withHidden(HomeCardId.rank, hidden: false);
    expect(layout.isHidden(HomeCardId.rank), isFalse);
    // Hiding twice is a no-op (same instance).
    final hidden = layout.withHidden(HomeCardId.rank, hidden: true);
    expect(
      identical(hidden.withHidden(HomeCardId.rank, hidden: true), hidden),
      isTrue,
    );
    expect(HomeLayout.defaults.hidden, isEmpty);
  });

  test('core, session and deferred cards are classified', () {
    expect(HomeCardId.values.where((c) => c.isCore), [
      HomeCardId.store,
      HomeCardId.rank,
      HomeCardId.battlePass,
    ]);
    expect(HomeCardId.values.where((c) => c.isDeferred), [
      HomeCardId.friends,
      HomeCardId.community,
      HomeCardId.otherAccounts,
    ]);
    expect(HomeCardId.community.needsRiotSession, isFalse);
    expect(HomeCardId.otherAccounts.needsRiotSession, isFalse);
    expect(HomeCardId.serverStatus.needsRiotSession, isFalse);
    expect(HomeCardId.friends.needsRiotSession, isTrue);
  });
}
