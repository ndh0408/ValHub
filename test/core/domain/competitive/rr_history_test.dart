import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/match_models.dart';
import 'package:valvn/core/domain/competitive/rank_models.dart';
import 'package:valvn/core/domain/competitive/rr_history.dart';
import 'package:valvn/core/storage/json_file_cache.dart';

import 'competitive_test_utils.dart';

CompetitiveUpdate _row(String id, int day, {int earned = 10, int rr = 50}) =>
    CompetitiveUpdate(
      matchId: id,
      seasonId: actV,
      matchStartTime: DateTime.utc(2026, 9, day),
      tierBefore: 12,
      tierAfter: 12,
      rrBefore: rr - earned,
      rrAfter: rr,
      rrEarned: earned,
    );

void main() {
  late Directory tmp;
  late JsonFileCache files;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('valvn_rr');
    files = JsonFileCache(() async => tmp);
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test(
    'late RR and outcomes after sign-out cannot recreate retained history',
    () async {
      var signedIn = true;
      final store = RrHistoryStore(files, canRecord: (_) async => signedIn);
      await store.merge('me', [_row('a', 1)]);
      signedIn = false;
      await store.delete('me');
      await store.merge('me', [_row('b', 2)]);
      await store.recordOutcomes('me', {'b': MatchOutcome.win}, force: true);
      expect((await store.read('me')).rows, isEmpty);
      expect((await store.read('me')).outcomes, isEmpty);
      expect(await files.read(RrHistoryStore.key('me')), isNull);
      store.dispose();
    },
  );

  test(
    'legacy third-party files are erased while retained own accounts stay',
    () async {
      final store = RrHistoryStore(files);
      await store.merge('me', [_row('a', 1)]);
      await store.merge('kept-own', [_row('b', 2)]);
      await store.merge('other-player', [_row('c', 3)]);
      await store.pruneUnowned({'ME', 'kept-own'});
      expect(await files.read(RrHistoryStore.key('other-player')), isNull);
      expect((await store.read('me')).rows, hasLength(1));
      expect((await store.read('kept-own')).rows, hasLength(1));
      store.dispose();
    },
  );

  test(
    'other players stay in memory, bounded to 20 players and 200 rows',
    () async {
      final store = RrHistoryStore(files);
      store.mergeVisitor('visitor', [
        for (var i = 0; i < 250; i++) _row('m$i', 1),
      ]);
      expect(store.readVisitor('visitor').rows, hasLength(200));
      expect(await files.read(RrHistoryStore.key('visitor')), isNull);
      for (var i = 0; i < 20; i++) {
        store.mergeVisitor('v$i', [_row('a', 2)]);
      }
      expect(store.readVisitor('visitor').rows, isEmpty);
      expect(await tmp.list(recursive: true).toList(), isEmpty);
      store.dispose();
    },
  );

  test('merge de-duplicates by match id and sorts newest first', () async {
    final store = RrHistoryStore(files);
    expect(await store.merge(me, [_row('a', 1), _row('b', 3)]), 2);
    expect(
      await store.merge(me.toUpperCase(), [_row('b', 3), _row('c', 2)]),
      1,
    );
    final h = await store.read(me);
    expect(h.rows.map((r) => r.matchId), ['b', 'c', 'a']);
    expect(h.forMatch('C')!.rrEarned, 10);
    expect(h.forMatch(null), isNull);
    // A changed copy of a known row replaces it but is not "new".
    expect(await store.merge(me, [_row('a', 1, earned: -5)]), 0);
    expect((await store.read(me)).forMatch('a')!.rrEarned, -5);
    expect(await store.merge(me, const []), 0);
    expect(await store.merge('', [_row('z', 1)]), 0);
  });

  test('persists across instances; keys survive sign-out prefixes', () async {
    await RrHistoryStore(files).merge(me, [_row('a', 1), _row('b', 2)]);
    final again = await RrHistoryStore(files).read(me);
    expect(again.rows.map((r) => r.matchId), ['b', 'a']);
    expect(RrHistoryStore.key(me.toUpperCase()), 'keep/$me/rr_history');
    expect(
      RrHistoryStore.key(me).startsWith(JsonFileCache.accountPrefix(me)),
      isFalse,
    );
    expect((await RrHistoryStore(files).read(friend)).isEmpty, isTrue);
  });

  test('caps the number of rows (newest kept) and prunes outcomes', () async {
    final store = RrHistoryStore(files, maxRows: 3);
    await store.merge(me, [_row('a', 1), _row('b', 2)]);
    await store.recordOutcomes(me, {'a': MatchOutcome.win});
    await store.merge(me, [_row('c', 3), _row('d', 4)]);
    final h = await store.read(me);
    expect(h.rows.map((r) => r.matchId), ['d', 'c', 'b']);
    expect(h.outcomes, isEmpty);
  });

  test('outcomes: only known rows unless forced; unknown ignored', () async {
    final store = RrHistoryStore(files);
    await store.merge(me, [_row('a', 1)]);
    await store.recordOutcomes(me, {
      'A': MatchOutcome.loss,
      'x': MatchOutcome.win,
      'a2': MatchOutcome.unknown,
    });
    expect((await store.read(me)).outcomes, {'a': MatchOutcome.loss});
    await store.recordOutcomes(me, {'x': MatchOutcome.win}, force: true);
    final reread = await RrHistoryStore(files).read(me);
    expect(reread.outcomes, {'a': MatchOutcome.loss, 'x': MatchOutcome.win});
  });

  test('change notifications and deletion', () async {
    final store = RrHistoryStore(files);
    final changes = <String>[];
    final sub = store.changes.listen(changes.add);
    await store.merge(me, [_row('a', 1)]);
    await store.merge(me, [_row('a', 1)]); // no change → no event
    await store.merge(friend, [_row('b', 1)]);
    await store.delete(me);
    await Future<void>.delayed(Duration.zero);
    expect(changes, [me, friend, me]);
    expect((await store.read(me)).isEmpty, isTrue);
    expect((await store.read(friend)).rows, hasLength(1));
    await store.clear();
    expect((await RrHistoryStore(files).read(friend)).isEmpty, isTrue);
    await sub.cancel();
    store.dispose();
  });

  test('concurrent merges are serialised', () async {
    final store = RrHistoryStore(files);
    final results = await Future.wait([
      for (var i = 0; i < 10; i++) store.merge(me, [_row('m$i', i + 1)]),
    ]);
    expect(results.every((n) => n == 1), isTrue);
    expect((await RrHistoryStore(files).read(me)).rows, hasLength(10));
  });

  test('corrupt or unreadable storage degrades to empty / memory', () async {
    await files.writeRaw(RrHistoryStore.key(me), '<html>oops');
    expect((await RrHistoryStore(files).read(me)).isEmpty, isTrue);
    final decoded = RrHistoryStore.decode(me, {
      'rows': [
        null,
        {'MatchID': ''},
        _row('a', 1).toJson(),
        _row('a', 1).toJson(),
      ],
      'outcomes': {'a': 'win', 'b': 'bogus', 'c': 3},
    });
    expect(decoded.rows, hasLength(1));
    expect(decoded.outcomes, {'a': MatchOutcome.win});

    final broken = RrHistoryStore(
      JsonFileCache(() async => throw const FileSystemException('no disk')),
    );
    expect(await broken.merge(me, [_row('a', 1)]), 1);
    expect((await broken.read(me)).rows, hasLength(1));
    await broken.delete(me);
    expect((await broken.read(me)).isEmpty, isTrue);
  });

  test('encode/decode round trip', () {
    final h = RrHistory(
      puuid: me,
      rows: [_row('b', 2), _row('a', 1)],
      outcomes: {'a': MatchOutcome.draw},
    );
    final back = RrHistoryStore.decode(me, RrHistoryStore.encode(h));
    expect(back.rows, h.rows);
    expect(back.outcomes, h.outcomes);
  });
}
