import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/store_history.dart';
import 'package:valvn/features/store/data/store_history_view.dart';

StoreHistoryDay _day(
  int day,
  List<(String, int?)> daily, {
  List<int> nightPercents = const [],
}) {
  final at = DateTime.utc(2026, 10, day, 8);
  return StoreHistoryDay(
    key: 'utc:2026-10-$day',
    firstSeen: at,
    lastSeen: at,
    daily: [
      for (final (level, vp) in daily)
        HistoryDailyOffer(skinLevelUuid: level, vp: vp),
    ],
    nightMarket: [
      for (var i = 0; i < nightPercents.length; i++)
        HistoryNightOffer(
          skinLevelUuid: 'n$i',
          bonusOfferId: 'run-$day-$i',
          percent: nightPercents[i],
        ),
    ],
  );
}

void main() {
  final db = ContentDb.empty();

  test('most offered: twice or more, most often first, newest price', () {
    final history = StoreHistory(
      days: [
        _day(1, [('a', 1775), ('b', 875), ('c', 1275), ('d', 2175)]),
        _day(2, [('a', 1775), ('e', 875), ('c', 1275), ('f', 2175)]),
        _day(3, [('a', 1975), ('g', 875), ('h', 1275), ('c', 2175)]),
        _day(4, [('b', 875), ('i', 875), ('j', 1275), ('k', 2175)]),
      ],
    );
    final top = mostOfferedSkins(history, db);
    expect(top.map((s) => s.levelUuid), ['a', 'c', 'b']);
    expect(top.map((s) => s.times), [3, 3, 2]);
    // Ties go to the skin seen most recently; the price is the newest one.
    expect(top.first.vp, 1975);
    expect(mostOfferedSkins(history, db, limit: 1), hasLength(1));
    expect(
      mostOfferedSkins(
        StoreHistory(
          days: [
            _day(1, [('x', 1)]),
          ],
        ),
        db,
      ),
      isEmpty,
      reason: 'one appearance says nothing',
    );
  });

  test('a day total needs every price; the best Night Market discount', () {
    expect(dailyTotalVp(_day(1, [('a', 1775), ('b', 875)])), 2650);
    expect(dailyTotalVp(_day(1, [('a', 1775), ('b', null)])), isNull);
    expect(dailyTotalVp(_day(1, [])), isNull);
    expect(bestNightDiscount(_day(1, [], nightPercents: [12, 40, 0])), 40);
    expect(bestNightDiscount(_day(1, [])), isNull);
  });

  test('a rotation is named by the day it started, not when it was seen', () {
    // Reset at 00:00 UTC; the shop of 6 Oct opened at 17:03 UTC (00:03 the
    // next day in UTC+7).
    final seen = DateTime.utc(2026, 10, 6, 17, 3);
    final day = StoreHistoryDay(
      key: 'utc:2026-10-06',
      firstSeen: seen,
      lastSeen: seen,
      resetsAt: DateTime.utc(2026, 10, 7),
    );
    expect(rotationStart(day), DateTime.utc(2026, 10, 6));
    final unknown = StoreHistoryDay(
      key: 'utc:2026-10-06',
      firstSeen: seen,
      lastSeen: seen,
    );
    expect(rotationStart(unknown), seen);
  });
}
