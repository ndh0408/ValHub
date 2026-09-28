import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import '../../../helpers/test_prefs.dart';
import 'competitive_test_utils.dart';

String _puuid(int i) =>
    'eeeeeeee-0000-4000-8000-${i.toRadixString(16).padLeft(12, '0')}';

List<JsonMap> _rows(Iterable<String> subjects) => [
  for (final s in subjects)
    {'Subject': s.toUpperCase(), 'GameName': 'P$s', 'TagLine': 'VN'},
];

void main() {
  late MockPvpApi api;
  late Prefs prefs;
  late FixedClock clock;
  final calls = <List<String>>[];

  setUpAll(() => registerFallbackValue(<String>[]));

  setUp(() async {
    api = MockPvpApi();
    prefs = await createTestPrefs();
    clock = FixedClock(DateTime(2026, 9, 28, 12));
    calls.clear();
    when(() => api.names(any(), any())).thenAnswer((inv) async {
      final subjects = (inv.positionalArguments[1] as Iterable<String>)
          .toList();
      calls.add(subjects);
      return _rows(subjects);
    });
  });

  NameResolver resolver() => NameResolver(
    api: api,
    prefs: prefs,
    clock: clock,
    batchWindow: Duration.zero,
  );

  group('RiotName', () {
    test('parsing and display', () {
      expect(RiotName.of('  ', 'VN'), isNull);
      expect(RiotName.of('Tên', null)!.riotId, 'Tên');
      expect(RiotName.of(' Tên ', 'VN1')!.riotId, 'Tên#VN1');
      expect(
        RiotName.fromNameService(competitiveFixture('name_service')),
        isNull,
      );
      final rows = asMapList(competitiveFixture('name_service'));
      expect(RiotName.fromNameService(rows[0])!.riotId, 'Đồng Đội#VN1');
      // Legacy DisplayName when GameName is blank.
      expect(RiotName.fromNameService(rows[2])!.riotId, 'LegacyName');
      expect(RiotName.fromNameService({'GameName': ''}), isNull);
      expect(const RiotName(gameName: 'A').toString(), 'RiotName(A)');
    });
  });

  group('incognito (SUMMARY U16)', () {
    test('hidden unless self or party member', () {
      expect(isIdentityHidden(incognito: true), isTrue);
      expect(isIdentityHidden(incognito: true, isSelf: true), isFalse);
      expect(isIdentityHidden(incognito: true, isPartyMember: true), isFalse);
      expect(isIdentityHidden(incognito: false), isFalse);
    });

    test('display name and level', () {
      const name = RiotName(gameName: 'Tên', tagLine: 'VN1');
      expect(playerDisplayName(name), 'Tên#VN1');
      expect(playerDisplayName(name, withTag: false), 'Tên');
      expect(playerDisplayName(name, hidden: true), 'Người chơi ẩn danh');
      expect(playerDisplayName(null, fallback: 'Jett'), 'Jett');
      expect(playerDisplayName(null, fallback: ' '), 'Người chơi');
      expect(visibleAccountLevel(222, hideAccountLevel: true), isNull);
      expect(
        visibleAccountLevel(222, hideAccountLevel: true, isSelf: true),
        222,
      );
      expect(visibleAccountLevel(222, hideAccountLevel: false), 222);
    });
  });

  group('NameResolver', () {
    test('coalesces concurrent requests into batches of at most 50', () async {
      final r = resolver();
      final ids = [for (var i = 0; i < 120; i++) _puuid(i)];
      final results = await Future.wait([
        r.resolve(me, ids.sublist(0, 60)),
        r.resolve(me, ids.sublist(40, 120)),
        r.resolve(me, [ids[5].toUpperCase(), ids[5]]),
      ]);
      expect(calls.map((c) => c.length), [50, 50, 20]);
      expect(calls.expand((c) => c).toSet(), hasLength(120));
      expect(results[0], hasLength(60));
      expect(results[1], hasLength(80));
      expect(results[2], {
        ids[5]: RiotName(gameName: 'P${ids[5]}', tagLine: 'VN'),
      });
      verify(() => api.names(me, any())).called(3);
    });

    test('memory cache, prefs cache, freshness', () async {
      final r = resolver();
      await r.resolve(me, [enemy1, enemy2]);
      await r.resolve(me, [enemy1]);
      expect(calls, hasLength(1));
      expect(r.peek(enemy1.toUpperCase())!.gameName, 'P$enemy1');

      final reloaded = resolver();
      expect(reloaded.peek(enemy2)!.tagLine, 'VN');
      await reloaded.resolve(me, [enemy2]);
      expect(calls, hasLength(1));

      clock.advance(const Duration(days: 2));
      await reloaded.resolve(me, [enemy2]);
      expect(calls, hasLength(2));
      await reloaded.resolve(me, [enemy2], refresh: true);
      expect(calls, hasLength(3));
    });

    test('unknown PUUIDs are left out; stale names survive errors', () async {
      when(() => api.names(any(), any())).thenAnswer((inv) async {
        calls.add(inv.positionalArguments[1] as List<String>);
        return [
          {'Subject': enemy1, 'GameName': 'Một', 'TagLine': '1'},
          {'Subject': null, 'GameName': 'Ai'},
          {'Subject': mate, 'GameName': '', 'TagLine': ''},
        ];
      });
      final r = resolver();
      final first = await r.resolve(me, [enemy1, mate]);
      expect(first.keys, [enemy1]);

      clock.advance(const Duration(days: 2));
      when(() => api.names(any(), any()))
          .thenThrow(const TransientException(status: 503));
      final stale = await r.resolve(me, [enemy1, mate]);
      expect(stale, {enemy1: const RiotName(gameName: 'Một', tagLine: '1')});
      await expectLater(
        r.resolve(me, [friend]),
        throwsA(isA<TransientException>()),
      );
      expect(await r.resolve(me, const []), isEmpty);
    });

    test('remember seeds the cache without a call', () async {
      final r = resolver();
      r.remember(friend.toUpperCase(), const RiotName(gameName: 'Bạn'));
      r.remember(friend, const RiotName(gameName: ' '));
      expect(await r.resolveOne(me, friend), const RiotName(gameName: 'Bạn'));
      expect(calls, isEmpty);
      await pumpEventQueue();
      expect(resolver().peek(friend)!.gameName, 'Bạn');
    });

    test('bounded prefs cache', () async {
      final r = NameResolver(
        api: api,
        prefs: prefs,
        clock: clock,
        batchWindow: Duration.zero,
        maxEntries: 3,
      );
      for (var i = 0; i < 5; i++) {
        clock.advance(const Duration(minutes: 1));
        r.remember(_puuid(i), RiotName(gameName: 'N$i'));
      }
      await pumpEventQueue();
      final stored = asMap(prefs.getJson(NameResolver.prefsKey))!;
      expect(stored.keys.toSet(), {_puuid(2), _puuid(3), _puuid(4)});
    });

    test('dispose completes pending lookups with no name', () async {
      final r = NameResolver(
        api: api,
        prefs: prefs,
        clock: clock,
        batchWindow: const Duration(hours: 1),
      );
      final pending = r.resolve(me, [enemy1]);
      r.dispose();
      expect(await pending, isEmpty);
      expect(await r.resolve(me, [enemy2]), isEmpty);
      expect(calls, isEmpty);
    });
  });
}
