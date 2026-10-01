import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/store_history.dart';
import 'package:valvn/core/domain/economy/storefront.dart';
import 'package:valvn/core/storage/json_file_cache.dart';

import '../../../helpers/temp_dir.dart';
import 'economy_fixtures.dart';

void main() {
  late Directory temp;
  late JsonFileCache files;
  final now = DateTime.utc(2026, 9, 28, 23);
  Storefront shop(DateTime at, {bool cached = false}) => Storefront.fromJson(
    economyFixture('storefront.json'),
    receivedAt: at,
    isFromCache: cached,
  );
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('valvn_store_history');
    files = JsonFileCache(() async => temp);
  });
  tearDown(() async => deleteTempDir(temp));

  test(
    'UTC day dedupes fetches but identical skins on another day count again',
    () async {
      final store = StoreHistoryStore(files);
      await store.record('ME', shop(now), now);
      await store.record(
        'me',
        shop(now),
        now.subtract(const Duration(hours: 1)),
      );
      expect((await store.read('me')).daysRecorded, 1);
      await store.record('me', shop(now), now.add(const Duration(hours: 2)));
      final history = await store.read('me');
      expect(history.daysRecorded, 2);
      final skin = shop(now).daily.offers.first.skinLevelUuid;
      final summary = history.forSkin([skin.toUpperCase()])!;
      expect(summary.dailyDays, 2);
      expect(summary.recordingSince, now.subtract(const Duration(hours: 1)));
      expect(summary.lastSeen, now.add(const Duration(hours: 2)));
      expect(summary.lastDailyVp, shop(now).daily.offers.first.vpCost);
      store.dispose();
    },
  );

  test('does not invent history from cached or empty stores', () async {
    final store = StoreHistoryStore(files);
    expect(await store.record('me', shop(now, cached: true), now), isFalse);
    expect(
      await store.record('me', Storefront.fromJson({}, receivedAt: now), now),
      isFalse,
    );
    expect((await store.read('me')).isEmpty, isTrue);
    expect(await files.read(StoreHistoryStore.key('me')), isNull);
    store.dispose();
  });

  test('late completion of an older fetch cannot replace newer prices', () {
    final newer = StoreHistoryDay(
      key: 'day',
      firstSeen: now,
      lastSeen: now,
      daily: const [HistoryDailyOffer(skinLevelUuid: 'skin', vp: 1775)],
    );
    final olderAt = now.subtract(const Duration(hours: 1));
    final older = StoreHistoryDay(
      key: 'day',
      firstSeen: olderAt,
      lastSeen: olderAt,
      daily: const [HistoryDailyOffer(skinLevelUuid: 'skin', vp: 1275)],
    );
    final merged = newer.seenAgain(older);
    expect(merged.daily.single.vp, 1775);
    expect(merged.firstSeen, olderAt);
    expect(merged.lastSeen, now);
    expect(older.seenAgain(newer), merged);
  });

  test('retention, account separation, reload and deletion', () async {
    final store = StoreHistoryStore(files, maxDays: 3);
    for (var day = 0; day < 5; day++) {
      final at = now.add(Duration(days: day));
      await store.record('me', shop(at), at);
    }
    await store.record('other', shop(now), now);
    final reloaded = StoreHistoryStore(files);
    expect((await reloaded.read('me')).daysRecorded, 3);
    expect(
      (await reloaded.read('me')).recordingSince,
      now.add(const Duration(days: 2)),
    );
    await reloaded.delete('me');
    expect((await store.read('me')).isEmpty, isTrue);
    expect((await reloaded.read('other')).daysRecorded, 1);
    store.dispose();
    reloaded.dispose();
  });

  test('two writers preserve both days with a file lock', () async {
    final foreground = StoreHistoryStore(files);
    final background = StoreHistoryStore(JsonFileCache(() async => temp));
    final tomorrow = now.add(const Duration(days: 1));
    await Future.wait([
      foreground.record('me', shop(now), now),
      background.record('me', shop(tomorrow), tomorrow),
    ]);
    expect((await foreground.read('me')).daysRecorded, 2);
    foreground.dispose();
    background.dispose();
  });

  test(
    'Night Market counts distinct runs, rather than each daily observation',
    () async {
      final offer = shop(now).nightMarket!.offers.first;
      final history = StoreHistory(
        days: [
          for (var i = 0; i < 3; i++)
            StoreHistoryDay(
              key: 'day$i',
              firstSeen: now.add(Duration(days: i)),
              lastSeen: now.add(Duration(days: i)),
              nightMarket: [
                HistoryNightOffer(
                  skinLevelUuid: offer.skinLevelUuid,
                  bonusOfferId: i < 2 ? 'run-a' : 'run-b',
                  basePrice: 1775,
                  discountedPrice: 1000,
                  percent: 44,
                ),
              ],
            ),
        ],
      );
      final summary = history.forSkin([offer.skinLevelUuid])!;
      expect(summary.nightMarketRuns, 2);
      expect(summary.dailyDays, 0);
      expect(summary.lastNightPercent, 44);
      expect(
        StoreHistoryStore.decode(StoreHistoryStore.encode(history)).days,
        history.days,
      );
      expect(history.forSkin(['missing'])!.appearances, 0);
    },
  );

  test('corruption and future schemas never fabricate entries', () {
    for (final raw in <Object?>[
      null,
      <Object?>[],
      <String, Object?>{},
      {'v': 999, 'days': <Object?>[]},
      {
        'v': 1,
        'days': [
          null,
          <String, Object?>{},
          {'k': 'a'},
        ],
      },
    ]) {
      expect(StoreHistoryStore.decode(raw).isEmpty, isTrue);
    }
  });
}
