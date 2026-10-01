import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/competitive/matches.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/json_file_cache.dart';

import 'competitive_test_utils.dart';

void main() {
  group('MatchHistoryPage (P-13)', () {
    test('parses entries, lowercases ids, keeps custom queue ""', () {
      final page = MatchHistoryPage.fromJson(
        competitiveFixture('match_history'),
      );
      expect(page.subject, me);
      expect(page.total, 3);
      expect(page.entries.map((e) => e.matchId), [
        compMatch,
        dmMatch,
        customMatch,
      ]);
      expect(page.entries.map((e) => e.queueId), [
        'competitive',
        'deathmatch',
        '',
      ]);
      expect(page.entries.first.startTime, DateTime.utc(2026, 9, 28, 4));
      expect(page.hasMoreAfter(0), isFalse);
    });

    test('hasMoreAfter uses Total, else a full page', () {
      final twenty = [
        for (var i = 0; i < 20; i++) {'MatchID': 'm$i', 'QueueID': ''},
      ];
      expect(
        MatchHistoryPage.fromJson({'Total': 45, 'History': twenty})
            .hasMoreAfter(20),
        isTrue,
      );
      expect(
        MatchHistoryPage.fromJson({'Total': 40, 'History': twenty})
            .hasMoreAfter(20),
        isFalse,
      );
      expect(
        MatchHistoryPage.fromJson({'History': twenty}).hasMoreAfter(0),
        isTrue,
      );
      expect(
        MatchHistoryPage.fromJson({'History': twenty.sublist(0, 5)})
            .hasMoreAfter(0),
        isFalse,
      );
      expect(MatchHistoryPage.fromJson('<html>').entries, isEmpty);
    });

    test('past-end errors', () {
      expect(
        isPastEndError(const RiotApiException(400, errorCode: 'BAD_PARAMETER')),
        isTrue,
      );
      expect(
        isPastEndError(
          const RiotApiException(
            400,
            errorCode: 'MATCH_HISTORY_INVALID_INDICES',
          ),
        ),
        isFalse,
      );
      expect(isPastEndError(const NotFoundException()), isFalse);
    });

    test('PagedState copyWith', () {
      const s = PagedState<int>(items: [1], total: 5);
      final loading = s.copyWith(isLoadingMore: true, loadMoreError: 'x');
      expect(loading.isLoadingMore, isTrue);
      expect(loading.loadMoreError, 'x');
      expect(loading.copyWith(clearError: true).loadMoreError, isNull);
      expect(loading.total, 5);
      expect(const PagedState<int>().isEmpty, isTrue);
    });
  });

  group('MatchDetailsCache', () {
    late Directory tmp;
    late JsonFileCache files;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('valvn_matches');
      files = JsonFileCache(() async => tmp);
    });
    tearDown(() => tmp.delete(recursive: true));

    test('stores completed matches compactly and reads them back', () async {
      final cache = MatchDetailsCache(files);
      final d = MatchDetails.fromJson(competitiveFixture('match_competitive'));
      await cache.write(d);
      final back = await cache.read(compMatch.toUpperCase());
      expect(back, isNotNull);
      expect(back!.statsFor(me)!.adr, 170);
      expect(back.resultFor(me).outcome, MatchOutcome.win);
      final raw = await files.readRaw(MatchDetailsCache.key(compMatch));
      expect(raw, isNot(contains('playerLocations')));
      expect(await cache.read('d9999999-0000-4000-8000-000000000009'), isNull);
    });

    test('incomplete matches are not cached; corrupt files ignored', () async {
      final cache = MatchDetailsCache(files);
      final custom = MatchDetails.fromJson(competitiveFixture('match_custom'));
      expect(custom.info.isCompleted, isFalse);
      await cache.write(custom);
      expect(await cache.read(customMatch), isNull);
      await files.writeRaw(MatchDetailsCache.key(dmMatch), '{"savedAt":1,');
      expect(await cache.read(dmMatch), isNull);
    });

    test('keeps only the most recently used entries', () async {
      final cache = MatchDetailsCache(files, keep: 3);
      final base = competitiveFixtureMap('match_competitive');
      for (var i = 0; i < 5; i++) {
        final json = {
          ...base,
          'matchInfo': {
            ...(base['matchInfo'] as Map<String, dynamic>),
            'matchId': 'a000000$i-0000-4000-8000-000000000000',
          },
        };
        await cache.write(MatchDetails.fromJson(json));
        final file = await files.fileFor(
          MatchDetailsCache.key('a000000$i-0000-4000-8000-000000000000'),
        );
        await file.setLastModified(DateTime(2026, 1, 1 + i));
      }
      await cache.prune();
      final left = [
        for (var i = 0; i < 5; i++)
          await cache.read('a000000$i-0000-4000-8000-000000000000') != null,
      ];
      expect(left, [false, false, true, true, true]);
    });
  });

  group('MatchRepository', () {
    late Directory tmp;
    late MockPvpApi api;
    late MatchRepository repo;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('valvn_repo');
      api = MockPvpApi();
      repo = MatchRepository(
        api: api,
        cache: MatchDetailsCache(JsonFileCache(() async => tmp)),
      );
    });
    tearDown(() => tmp.delete(recursive: true));

    test('details: network once, then the disk cache', () async {
      when(
        () => api.matchDetails(
          me,
          compMatch,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => competitiveFixtureMap('match_competitive'));
      final first = await repo.details(me, compMatch.toUpperCase());
      final second = await repo.details(me, compMatch);
      expect(first.matchId, compMatch);
      expect(second.statsFor(me)!.acs, 200);
      verify(
        () => api.matchDetails(
          me,
          compMatch,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      await repo.details(me, compMatch, refresh: true);
      verify(
        () => api.matchDetails(
          me,
          compMatch,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test('404 while Riot processes the match propagates', () async {
      when(
        () => api.matchDetails(
          any(),
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => throw const NotFoundException());
      await expectLater(
        repo.details(me, 'x'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('history forwards paging and queue; blank queue = all', () async {
      when(
        () => api.matchHistory(
          me,
          subject: any(named: 'subject'),
          startIndex: any(named: 'startIndex'),
          endIndex: any(named: 'endIndex'),
          queue: any(named: 'queue'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => {'History': null});
      when(
        () => api.matchHistory(
          me,
          subject: friend,
          startIndex: 20,
          endIndex: 40,
          queue: 'competitive',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => competitiveFixtureMap('match_history'));
      final page = await repo.history(
        me,
        subject: friend,
        startIndex: 20,
        endIndex: 40,
        queue: ' competitive ',
      );
      expect(page.entries, hasLength(3));
      final all = await repo.history(me, queue: '');
      expect(all.entries, isEmpty);
      verify(
        () => api.matchHistory(
          me,
          subject: null,
          startIndex: 0,
          endIndex: 20,
          queue: null,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });
  });
}
