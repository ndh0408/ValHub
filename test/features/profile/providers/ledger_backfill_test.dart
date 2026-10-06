import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/profile/providers/ledger_backfill.dart';

import '../profile_test_env.dart';

String _id(int i) =>
    'b${i.toString().padLeft(7, '0')}-0000-4000-8000-000000000000';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;
  late ProviderContainer container;
  late List<int> historyStarts;

  /// A Riot history of [total] matches, newest first, 20 per page.
  void stubHistory(int total) {
    for (var i = 0; i < total; i++) {
      env.matches[_id(i)] = competitiveMatchWithId(_id(i));
    }
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((inv) async {
      final start = inv.namedArguments[#startIndex] as int;
      final end = inv.namedArguments[#endIndex] as int;
      historyStarts.add(start);
      return <String, dynamic>{
        'Subject': me,
        'Total': total,
        'History': [
          for (var i = start; i < end && i < total; i++)
            {'MatchID': _id(i), 'QueueID': 'competitive'},
        ],
      };
    });
  }

  int detailCalls() => verify(
    () => env.api.matchDetails(
      any(),
      any(),
      cancelToken: any(named: 'cancelToken'),
    ),
  ).callCount;

  setUp(() async {
    env = await ProfileTestEnv.create();
    historyStarts = [];
    container = ProviderContainer(
      overrides: env.overrides,
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  Future<LedgerBackfillState> run() async {
    final sub = container.listen(ledgerBackfillProvider(me), (_, _) {});
    addTearDown(sub.close);
    await container.read(ledgerBackfillProvider(me).notifier).run();
    // Ledger writes are fire-and-forget after each match loads.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return container.read(ledgerBackfillProvider(me));
  }

  test(
    'opens only the matches the ledger lacks, then reports the end',
    () async {
      stubHistory(5);
      await env.ledger.record(me, [
        MatchStatLine.fromDetails(
          MatchDetails.fromJson(competitiveMatchWithId(_id(0))),
          me,
        )!,
      ]);

      final state = await run();

      expect(detailCalls(), 4, reason: 'match 0 was already analysed');
      expect(state.running, isFalse);
      expect(state.lastAdded, 4);
      expect(state.exhausted, isTrue);
      expect((await env.ledger.read(me)).length, 5);
    },
  );

  test('one tap adds at most a batch, the next continues after it', () async {
    stubHistory(45);

    final first = await run();
    expect(first.lastAdded, kBackfillBatch);
    expect(first.exhausted, isFalse);
    expect(historyStarts, [0]);

    final second = await run();
    expect(second.lastAdded, kBackfillBatch);
    expect(historyStarts, [0, 20]);

    final third = await run();
    expect(third.lastAdded, 5);
    expect(third.exhausted, isTrue);
    expect((await env.ledger.read(me)).length, 45);
  });

  test('a failed history request keeps the error for a retry', () async {
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => throw const TransientException(reason: 'network'),
    );

    final state = await run();

    expect(state.running, isFalse);
    expect(state.error, isA<TransientException>());
    expect(state.exhausted, isFalse);
    verifyNever(
      () => env.api.matchDetails(
        any(),
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('a page past the end is the end of the history, not an error', () async {
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          throw const RiotApiException(400, errorCode: 'BAD_PARAMETER'),
    );

    final state = await run();

    expect(state.error, isNull);
    expect(state.exhausted, isTrue);
    expect(state.lastAdded, 0);
  });

  test(
    'accounts that are not signed in on this device are never read',
    () async {
      final none = container.read(
        ledgerBackfillProvider('someone-else').notifier,
      );
      await none.run();
      verifyNever(
        () => env.api.matchHistory(
          any(),
          subject: any(named: 'subject'),
          startIndex: any(named: 'startIndex'),
          endIndex: any(named: 'endIndex'),
          queue: any(named: 'queue'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );
    },
  );
}
