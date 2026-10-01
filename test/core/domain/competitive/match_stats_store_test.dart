import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/match_models.dart';
import 'package:valvn/core/domain/competitive/match_stats_store.dart';
import 'package:valvn/core/domain/competitive/performance.dart';
import 'package:valvn/core/storage/json_file_cache.dart';

import 'competitive_test_utils.dart';

MatchStatLine _line(
  String id, {
  int day = 1,
  MatchOutcome outcome = MatchOutcome.win,
  int k = 15,
  String? map = '/Game/Maps/Ascent/Ascent',
  String? agent = 'add6443a-41bd-e414-f6ad-e58d267f4e95',
  String queue = 'competitive',
  MatchModeKind mode = MatchModeKind.standard,
  SideLine attack = SideLine.none,
  SideLine defense = SideLine.none,
  List<int>? multi,
  int? damage,
}) => MatchStatLine(
  matchId: id,
  startedAt: DateTime.utc(2026, 9, day, 12),
  outcome: outcome,
  queueId: queue,
  mapId: map,
  agentId: agent,
  mode: mode,
  kills: k,
  deaths: 10,
  assists: 4,
  score: 5200,
  rounds: 22,
  damage: damage,
  headshots: 12,
  bodyshots: 40,
  legshots: 3,
  firstBloods: 3,
  firstDeaths: 2,
  attack: attack,
  defense: defense,
  multiKills: multi,
);

String _id(int i) =>
    'e${i.toString().padLeft(7, '0')}-0000-4000-8000-000000000001';

void main() {
  late Directory tmp;
  late JsonFileCache files;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('valvn_ledger');
    files = JsonFileCache(() async => tmp);
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('records lines newest first, unique by match id', () async {
    final store = MatchStatsStore(files);
    expect(await store.record(me, [_line('a', day: 1), _line('b', day: 3)]), 2);
    expect(
      await store.record(me.toUpperCase(), [
        _line('b', day: 3),
        _line('c', day: 2),
      ]),
      1,
    );
    final ledger = await store.read(me);
    expect(ledger.lines.map((l) => l.matchId), ['b', 'c', 'a']);
    expect(ledger.byMatch('C')!.matchId, 'c');
    expect(ledger.byMatch(null), isNull);
    expect(ledger.byMatch('zzz'), isNull);
    expect(ledger.oldest, DateTime.utc(2026, 9, 1, 12));
    expect(ledger.newest, DateTime.utc(2026, 9, 3, 12));
    expect(ledger.length, 3);
    // A changed copy of a known match replaces it but is not "new".
    expect(await store.record(me, [_line('a', day: 1, k: 30)]), 0);
    expect((await store.read(me)).byMatch('a')!.kills, 30);
    expect(await store.record(me, const []), 0);
    expect(await store.record('', [_line('z')]), 0);
    await store.flush();
  });

  test('persists across instances at keep/<puuid>/match_stats', () async {
    final store = MatchStatsStore(files);
    await store.record(me, [_line('a'), _line('b', day: 2)]);
    await store.flush();
    expect(MatchStatsStore.key(me.toUpperCase()), 'keep/$me/match_stats');
    // Survives sign-out prefixes like the RR history.
    expect(
      MatchStatsStore.key(me).startsWith(JsonFileCache.accountPrefix(me)),
      isFalse,
    );
    final again = await MatchStatsStore(files).read(me);
    expect(again.lines.map((l) => l.matchId), ['b', 'a']);
    expect((await MatchStatsStore(files).read(friend)).isEmpty, isTrue);
  });

  test(
    'round trip keeps every field, including sides and multi-kills',
    () async {
      final line = _line(
        'a',
        damage: 3400,
        attack: const SideLine(
          rounds: 12,
          won: 8,
          kills: 11,
          deaths: 6,
          firstBloods: 3,
          firstDeaths: 1,
        ),
        defense: const SideLine(rounds: 10, won: 5),
        multi: const [3, 2, 1, 0],
      );
      final dm = _line(
        'dm',
        day: 2,
        queue: 'deathmatch',
        mode: MatchModeKind.deathmatch,
        outcome: MatchOutcome.loss,
        map: null,
        agent: null,
      );
      final store = MatchStatsStore(files);
      await store.record(me, [line, dm]);
      await store.flush();
      final back = await MatchStatsStore(files).read(me);
      expect(back.byMatch('a'), line);
      expect(back.byMatch('dm'), dm);
      expect(back.byMatch('dm')!.mapId, isNull);
      expect(back.byMatch('a')!.defense.kills, isNull); // unknown stays unknown
      expect(back.byMatch('a')!.multiKills, [3, 2, 1, 0]);
      expect(back.byMatch('dm')!.multiKills, isNull);
      expect(back.byMatch('dm')!.mode, MatchModeKind.deathmatch);
    },
  );

  test('a real fixture survives the trip unchanged', () async {
    final line = MatchStatLine.fromDetails(
      MatchDetails.fromJson(competitiveFixture('match_competitive')),
      me,
    )!;
    final store = MatchStatsStore(files);
    await store.record(me, [line]);
    await store.flush();
    final back = (await MatchStatsStore(files).read(me)).byMatch(compMatch)!;
    expect(back, line);
  });

  test('caps the number of rows, keeping the newest matches', () async {
    final store = MatchStatsStore(files, maxRows: 3);
    await store.record(me, [
      for (var i = 1; i <= 5; i++) _line(_id(i), day: i),
    ]);
    final ledger = await store.read(me);
    expect(ledger.lines.map((l) => l.matchId), [_id(5), _id(4), _id(3)]);
    await store.flush();
    expect((await MatchStatsStore(files).read(me)).length, 3);
  });

  test('about 130-150 bytes per match on disk', () async {
    final store = MatchStatsStore(files);
    await store.record(me, [
      for (var i = 0; i < 1000; i++)
        _line(
          _id(i),
          day: 1 + i % 28,
          k: 10 + i % 20,
          damage: 3000 + i,
          attack: SideLine(
            rounds: 11,
            won: 6,
            kills: 8,
            deaths: 7,
            firstBloods: 2,
            firstDeaths: 1,
          ),
          defense: SideLine(
            rounds: 11,
            won: 5,
            kills: 9,
            deaths: 8,
            firstBloods: 1,
            firstDeaths: 2,
          ),
          multi: const [2, 1, 0, 0],
        ),
    ]);
    await store.flush();
    final bytes = utf8
        .encode((await files.readRaw(MatchStatsStore.key(me)))!)
        .length;
    expect(bytes / 1000, lessThan(200));
    expect(bytes / 1000, greaterThan(80));
  });

  test('corrupt or foreign files read as an empty ledger', () async {
    await files.writeRaw(MatchStatsStore.key(me), '<html>oops');
    expect((await MatchStatsStore(files).read(me)).isEmpty, isTrue);
    await files.write(MatchStatsStore.key(mate), {'v': 99, 'rows': <Object>[]});
    expect((await MatchStatsStore(files).read(mate)).isEmpty, isTrue);
  });

  test('bad rows are dropped, good ones kept; short rows get defaults', () {
    final ledger = MatchStatsStore.decode(me, {
      'v': 1,
      'queues': ['competitive'],
      'maps': ['/Game/Maps/Ascent/Ascent'],
      'agents': ['add6443a-41bd-e414-f6ad-e58d267f4e95'],
      'rows': [
        null,
        'x',
        <Object>[],
        ['', 1790000000, 0, 0, 0, 0, 1], // no id
        ['dup', 1790000000, 0, 0, 0, 0, 1],
        ['dup', 1790000001, 0, 0, 0, 0, 2], // duplicate id
        ['badtime', 0, 0, 0, 0, 0, 1],
        ['badoutcome', 1790000000, 0, 0, 0, 0, 9],
        ['short', 1790000002, 0, 0, 0, 0, 2, 7, 9],
        ['out', 1790000003, 5, 5, 5, 0, 3], // indexes out of range
      ],
    });
    expect(ledger.lines.map((l) => l.matchId), ['out', 'short', 'dup']);
    final short = ledger.byMatch('short')!;
    expect((short.kills, short.deaths, short.assists), (7, 9, 0));
    expect(short.outcome, MatchOutcome.loss);
    expect(short.damage, isNull);
    expect(short.mapId, '/Game/Maps/Ascent/Ascent');
    expect(short.multiKills, isNull);
    final out = ledger.byMatch('out')!;
    expect(out.queueId, '');
    expect(out.mapId, isNull);
    expect(out.agentId, isNull);
    expect(out.outcome, MatchOutcome.draw);
  });

  test('change notifications, deletion and concurrent records', () async {
    final store = MatchStatsStore(files);
    final changes = <String>[];
    final sub = store.changes.listen(changes.add);
    await store.record(me, [_line('a')]);
    await store.record(me, [_line('a')]); // no change → no event
    await store.record(friend, [_line('b')]);
    await store.delete(me);
    await Future<void>.delayed(Duration.zero);
    expect(changes, [me, friend, me]);
    expect((await store.read(me)).isEmpty, isTrue);
    expect((await store.read(friend)).length, 1);
    await store.flush();
    expect((await MatchStatsStore(files).read(me)).isEmpty, isTrue);

    final results = await Future.wait([
      for (var i = 0; i < 10; i++)
        store.record(mate, [_line(_id(i), day: i + 1)]),
    ]);
    expect(results.every((n) => n == 1), isTrue);
    await store.flush();
    expect((await MatchStatsStore(files).read(mate)).length, 10);
    await sub.cancel();
    store.dispose();
  });

  test('unreadable storage degrades to memory', () async {
    final broken = MatchStatsStore(
      JsonFileCache(() async => throw const FileSystemException('no disk')),
    );
    expect(await broken.record(me, [_line('a')]), 1);
    await broken.flush();
    expect((await broken.read(me)).length, 1);
    await broken.delete(me);
    expect((await broken.read(me)).isEmpty, isTrue);
  });
}
