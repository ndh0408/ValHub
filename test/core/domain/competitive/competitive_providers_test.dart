import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/network/retry_policy.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import '../../../helpers/temp_dir.dart';
import '../../../helpers/test_prefs.dart';
import 'competitive_test_utils.dart';

class MockSessions extends Mock implements SessionManager {}

JsonMap _updatesPage(int start, int count) => {
  'Subject': me,
  'Matches': [
    for (var i = start; i < start + count; i++)
      {
        'MatchID':
            'c${i.toString().padLeft(7, '0')}-0000-4000-8000-000000000000',
        'SeasonID': actV,
        'MatchStartTime': DateTime.utc(
          2026,
          9,
          28,
        ).subtract(Duration(hours: i)).millisecondsSinceEpoch,
        'TierBeforeUpdate': 12,
        'TierAfterUpdate': 12,
        'RankedRatingBeforeUpdate': 40,
        'RankedRatingAfterUpdate': 60,
        'RankedRatingEarned': 20,
      },
  ],
};

void main() {
  setUpAll(() => registerFallbackValue(<String>[]));

  late MockPvpApi api;
  late MockSessions sessions;
  late Directory tmp;
  late Prefs prefs;
  late RrHistoryStore store;

  const myAccount = Account(
    puuid: me,
    gameName: 'Tôi',
    tagLine: 'VN1',
    region: 'ap',
    shard: 'ap',
  );

  setUp(() async {
    api = MockPvpApi();
    sessions = MockSessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    tmp = await Directory.systemTemp.createTemp('valvn_comp');
    store = RrHistoryStore(
      JsonFileCache(() async => Directory('${tmp.path}/h')),
    );
    when(() => api.names(any(), any()))
        .thenAnswer((_) async => asMapList(competitiveFixture('name_service')));
  });

  tearDown(() async {
    store.dispose();
    await deleteTempDir(tmp);
  });

  Future<ProviderContainer> container({
    List<Account> accounts = const [myAccount],
    Map<String, bool> flags = const {},
  }) async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    if (accounts.isNotEmpty) {
      await prefs.setString(PrefKeys.activePuuid, accounts.first.puuid);
    }
    return ProviderContainer.test(
      retry: riotRetry,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
        sessionManagerProvider.overrideWithValue(sessions),
        jsonFileCacheProvider.overrideWithValue(
          JsonFileCache(() async => Directory('${tmp.path}/c')),
        ),
        rrHistoryStoreProvider.overrideWithValue(store),
        pvpApiProvider.overrideWithValue(api),
        contentProvider.overrideWith((ref) async => testContent()),
        clockProvider.overrideWithValue(
          FixedClock(DateTime.utc(2026, 9, 28, 12)),
        ),
        remoteConfigProvider.overrideWithValue(RemoteConfig(flags: flags)),
      ],
    );
  }

  void stubMmr() =>
      when(() => api.mmr(any(), subject: any(named: 'subject')))
          .thenAnswer((_) async => competitiveFixtureMap('mmr'));

  void stubUpdates(JsonMap Function(int start, String queue) page) =>
      when(
        () => api.competitiveUpdates(
          any(),
          subject: any(named: 'subject'),
          startIndex: any(named: 'startIndex'),
          endIndex: any(named: 'endIndex'),
          queue: any(named: 'queue'),
        ),
      ).thenAnswer(
        (inv) async => page(
          inv.namedArguments[#startIndex] as int,
          inv.namedArguments[#queue] as String,
        ),
      );

  group('MMR and rank', () {
    test('own MMR; latest update lands in the RR history', () async {
      stubMmr();
      final c = await container();
      await c.read(contentProvider.future);
      final mmr = await c.read(mmrProvider(me.toUpperCase()).future);
      expect(mmr.subject, me);
      verify(() => api.mmr(me, subject: me)).called(1);
      await pumpEventQueue();
      final history = await c.read(rrHistoryProvider(me).future);
      expect(history.forMatch(updateId(5))!.rrEarned, 32);
    });

    test('other players are looked at with the active account', () async {
      stubMmr();
      final c = await container();
      await c.read(mmrProvider(friend).future);
      verify(() => api.mmr(me, subject: friend)).called(1);
      await pumpEventQueue();
      expect((await store.read(friend)).isEmpty, isTrue);
    });

    test('nobody signed in → NeedsLoginException', () async {
      final c = await container(accounts: const []);
      c.listen(mmrProvider(friend), (_, _) {});
      await expectLater(
        c.read(mmrProvider(friend).future),
        throwsA(isA<NeedsLoginException>()),
      );
    });

    test('rank summary; caches the rank on the account (A4)', () async {
      stubMmr();
      final c = await container();
      await c.read(contentProvider.future);
      final sub = c.listen(rankSummaryProvider(me), (_, _) {});
      final summary = await c.read(rankSummaryProvider(me).future);
      expect(summary.current.tierName, 'Kim Cương 1');
      expect(summary.current.rr, 6);
      expect(summary.peak!.rank.tierName, 'Bất Tử 1');
      expect(summary.peak!.actUuid, e1a1);
      await pumpEventQueue();
      final account = c.read(accountProvider(me))!;
      expect(account.rankTier, 18);
      expect(account.rankSeasonId, actV);
      sub.close();
    });

    test('console accounts read console queue keys when enabled', () async {
      stubMmr();
      stubUpdates((start, queue) => {'Matches': const <Object>[]});
      final console = myAccount.copyWith(platform: GamePlatform.playstation);
      final c = await container(
        accounts: [console],
        flags: {RemoteFlags.consoleSupport: true},
      );
      await c.read(contentProvider.future);
      final summary = await c.read(rankSummaryProvider(me).future);
      expect(summary.current.tierName, 'Bạc 1');
      await c.read(competitiveUpdatesProvider(me).future);
      verify(
        () => api.competitiveUpdates(
          me,
          subject: me,
          startIndex: 0,
          endIndex: 20,
          queue: 'console_competitive',
        ),
      ).called(1);

      final off = await container(accounts: [console]);
      await off.read(contentProvider.future);
      expect(
        (await off.read(rankSummaryProvider(me).future)).current.tierName,
        'Kim Cương 1',
      );
    });
  });

  group('competitive updates', () {
    test(
      'another player has bounded in-memory updates and no RR file',
      () async {
        stubUpdates((_, _) => _updatesPage(0, 20));
        final c = await container();
        await c.read(competitiveUpdatesProvider(friend).future);
        final history = await c.read(rrHistoryProvider(friend).future);
        expect(history.rows, hasLength(20));
        expect((await store.read(friend)).rows, isEmpty);
        expect(await c.read(rrHistorySyncProvider(friend).future), 0);
      },
    );
    test(
      'Settings delete helper only clears the selected own account',
      () async {
        final c = await container();
        await store.merge(me, [
          CompetitiveUpdate.fromJson(
            asList(_updatesPage(0, 1)['Matches']).first,
          )!,
        ]);
        await c.read(deleteRrHistoryProvider(friend))();
        expect((await store.read(me)).rows, hasLength(1));
        await c.read(deleteRrHistoryProvider(me))();
        expect((await store.read(me)).rows, isEmpty);
      },
    );
    test('pagination merges every page into the history', () async {
      stubUpdates((start, _) => _updatesPage(start, start == 0 ? 20 : 5));
      final c = await container();
      final sub = c.listen(competitiveUpdatesProvider(me), (_, _) {});
      final first = await c.read(competitiveUpdatesProvider(me).future);
      expect(first.items, hasLength(20));
      expect(first.hasMore, isTrue);
      final notifier = c.read(competitiveUpdatesProvider(me).notifier);
      expect(notifier.newInFirstPage, 20);
      await notifier.loadMore();
      final second = c.read(competitiveUpdatesProvider(me)).value!;
      expect(second.items, hasLength(25));
      expect(second.hasMore, isFalse);
      await notifier.loadMore(); // at the end: no call
      verify(
        () => api.competitiveUpdates(
          me,
          subject: me,
          startIndex: 20,
          endIndex: 40,
          queue: 'competitive',
        ),
      ).called(1);
      expect((await store.read(me)).rows, hasLength(25));
      sub.close();
    });

    test('BAD_PARAMETER ends the list; other errors are kept', () async {
      RiotException fail = const RiotApiException(
        400,
        errorCode: 'BAD_PARAMETER',
      );
      stubUpdates((start, _) {
        if (start > 0) throw fail;
        return _updatesPage(0, 20);
      });
      final c = await container();
      final sub = c.listen(competitiveUpdatesProvider(me), (_, _) {});
      await c.read(competitiveUpdatesProvider(me).future);
      final notifier = c.read(competitiveUpdatesProvider(me).notifier);
      await notifier.loadMore();
      var state = c.read(competitiveUpdatesProvider(me)).value!;
      expect(state.hasMore, isFalse);
      expect(state.loadMoreError, isNull);

      c.invalidate(competitiveUpdatesProvider(me));
      await c.read(competitiveUpdatesProvider(me).future);
      fail = const TransientException(status: 503);
      await c.read(competitiveUpdatesProvider(me).notifier).loadMore();
      state = c.read(competitiveUpdatesProvider(me)).value!;
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreError, isA<TransientException>());
      expect(state.items, hasLength(20));
      sub.close();
    });

    test('history sync backfills until it overlaps', () async {
      stubUpdates((start, _) => _updatesPage(start, 20));
      await store.merge(me, [
        CompetitiveUpdatesPage.fromJson(_updatesPage(45, 1)).matches.single,
      ]);
      final c = await container();
      final sub = c.listen(rrHistorySyncProvider(me), (_, _) {});
      final added = await c.read(rrHistorySyncProvider(me).future);
      // Pages 20–39 (new) and 40–59 (overlaps at 45): 20 + 19.
      expect(added, 39);
      expect((await store.read(me)).rows, hasLength(60));
      sub.close();
    });

    test(
      'history sync still backfills when MMR stored the newest row first',
      () async {
        stubUpdates((start, _) => _updatesPage(start, 20));
        // mmrProvider's LatestCompetitiveUpdate = row 0 of the first page.
        await store.merge(me, [
          CompetitiveUpdatesPage.fromJson(_updatesPage(0, 1)).matches.single,
        ]);
        final c = await container();
        final sub = c.listen(rrHistorySyncProvider(me), (_, _) {});
        final added = await c.read(rrHistorySyncProvider(me).future);
        // Pages 2–5 (matches 21–100) are fetched.
        expect(added, 80);
        expect((await store.read(me)).rows, hasLength(100));
        sub.close();
      },
    );

    test('daily RR and rank-up estimate from the stored rows', () async {
      stubMmr();
      stubUpdates((_, _) => competitiveFixtureMap('competitive_updates'));
      final c = await container();
      await c.read(contentProvider.future);
      final sub = c.listen(dailyRrProvider(me), (_, _) {});
      await c.read(competitiveUpdatesProvider(me).future);
      await pumpEventQueue();
      final days = await c.read(dailyRrProvider(me).future);
      expect(days.expand((d) => d.matches), hasLength(5));
      expect(days.fold<int>(0, (sum, d) => sum + d.netRr), 56);

      final est = await c.read(
        rankUpEstimateProvider((puuid: me, targetTier: null)).future,
      );
      expect(est!.targetTier, 19);
      expect(est.rrNeeded, 94);
      expect(est.matchesAtCurrentForm, 7);
      final form = await c.read(rankUpFormProvider(me).future);
      expect(form.winRate, 0.75);
      sub.close();
    });
  });

  group('matches', () {
    test(
      'account switches cannot reuse another viewer’s match error',
      () async {
        const other = Account(
          puuid: friend,
          gameName: 'Bạn',
          tagLine: 'VN1',
          region: 'ap',
          shard: 'ap',
        );
        when(() => api.matchDetails(any(), any())).thenAnswer((inv) async {
          if (inv.positionalArguments[0] == me) {
            throw const NeedsLoginException();
          }
          return competitiveFixtureMap('match_competitive');
        });
        final c = await container(accounts: [myAccount, other]);
        final sub = c.listen(matchDetailsProvider(compMatch), (_, _) {});
        await expectLater(
          c.read(matchDetailsProvider(compMatch).future),
          throwsA(isA<NeedsLoginException>()),
        );
        c.read(activePuuidProvider.notifier).select(friend);
        await pumpEventQueue();
        final details = await c.read(matchDetailsProvider(compMatch).future);
        expect(details.matchId, compMatch);
        verify(() => api.matchDetails(friend, compMatch)).called(1);
        sub.close();
      },
    );
    test('history with queue filter and paging by Total', () async {
      when(
        () => api.matchHistory(
          any(),
          subject: any(named: 'subject'),
          startIndex: any(named: 'startIndex'),
          endIndex: any(named: 'endIndex'),
          queue: any(named: 'queue'),
        ),
      ).thenAnswer((_) async => competitiveFixtureMap('match_history'));
      final c = await container();
      final q = (puuid: me, queue: 'competitive');
      final page = await c.read(matchHistoryProvider(q).future);
      expect(page.items.map((e) => e.matchId), [
        compMatch,
        dmMatch,
        customMatch,
      ]);
      expect(page.hasMore, isFalse);
      expect(page.total, 3);
      verify(
        () => api.matchHistory(
          me,
          subject: me,
          startIndex: 0,
          endIndex: 20,
          queue: 'competitive',
        ),
      ).called(1);
    });

    test('details: names resolved, outcome recorded, disk cache', () async {
      when(() => api.matchDetails(any(), any()))
          .thenAnswer((_) async => competitiveFixtureMap('match_competitive'));
      final c = await container();
      final sub = c.listen(matchDetailsProvider(compMatch), (_, _) {});
      final d = await c.read(matchDetailsProvider(compMatch).future);
      expect(d.player(me)!.name!.riotId, 'Tôi#VN1'); // own account
      expect(d.player(mate)!.name!.riotId, 'Đồng Đội#VN1'); // name-service
      expect(d.player(enemy1)!.name!.riotId, 'Đối Thủ#0001');
      expect(d.player(enemy2)!.name!.riotId, 'Kẻ Thù#VN2'); // from the match
      expect(d.player(observer)!.name!.riotId, 'LegacyName');
      final asked = verify(() => api.names(me, captureAny())).captured;
      expect(asked.single, unorderedEquals([mate, enemy1, observer]));

      await pumpEventQueue();
      expect((await store.read(me)).outcomes[compMatch], MatchOutcome.win);

      c.invalidate(matchDetailsProvider(compMatch));
      await c.read(matchDetailsProvider(compMatch).future);
      verify(() => api.matchDetails(me, compMatch)).called(1);

      final summary = await c.read(
        matchSummaryProvider((matchId: compMatch, puuid: me)).future,
      );
      expect(summary!.result.outcome, MatchOutcome.win);
      expect(summary.stats.acs, 200);
      sub.close();
    });

    test('name-service failure keeps the scoreboard', () async {
      when(() => api.matchDetails(any(), any()))
          .thenAnswer((_) async => competitiveFixtureMap('match_deathmatch'));
      when(() => api.names(any(), any()))
          .thenAnswer((_) async => throw const TransientException(status: 403));
      final c = await container();
      final d = await c.read(matchDetailsProvider(dmMatch).future);
      expect(d.player(me)!.name!.riotId, 'Tôi#VN1');
      expect(d.player('dddddddd-0000-4000-8000-000000000002')!.name, isNull);
      // Not competitive: no outcome recorded.
      await pumpEventQueue();
      expect((await store.read(me)).outcomes, isEmpty);
    });
  });

  group('names and account XP', () {
    test('player names: own account without a call, others batched', () async {
      final c = await container();
      expect(
        await c.read(playerNameProvider(me).future),
        const RiotName(gameName: 'Tôi', tagLine: 'VN1'),
      );
      verifyNever(() => api.names(any(), any()));
      final results = await Future.wait([
        c.read(playerNameProvider(mate).future),
        c.read(playerNameProvider(enemy1).future),
      ]);
      expect(results.map((n) => n?.riotId), ['Đồng Đội#VN1', 'Đối Thủ#0001']);
      verify(() => api.names(me, any())).called(1);
    });

    test('account XP updates the cached level', () async {
      when(() => api.accountXp(me))
          .thenAnswer((_) async => competitiveFixtureMap('account_xp'));
      final c = await container();
      final sub = c.listen(accountXpProvider(me), (_, _) {});
      final xp = await c.read(accountXpProvider(me).future);
      expect(xp.level, 222);
      await pumpEventQueue();
      expect(c.read(accountProvider(me))!.level, 222);
      await expectLater(
        c.read(accountXpProvider(friend).future),
        throwsA(isA<StateError>()),
      );
      sub.close();
    });
  });
}
