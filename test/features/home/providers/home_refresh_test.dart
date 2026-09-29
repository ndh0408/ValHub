import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/xmpp/xmpp_providers.dart' show appForegroundProvider;
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_layout.dart';
import 'package:valvn/features/home/providers/home_card_providers.dart';
import 'package:valvn/features/home/providers/home_refresh.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';

import '../home_test_env.dart';

const _puuid = Fx.puuid;

/// Watches the store and Battle Pass view models (so their providers are
/// alive and fetching) and hands out the [WidgetRef].
class _Probe extends ConsumerWidget {
  const _Probe({required this.onRef});

  final void Function(WidgetRef ref) onRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    onRef(ref);
    ref
      ..watch(homeStoreSummaryProvider(_puuid))
      ..watch(homeBattlePassSnapshotProvider(_puuid))
      ..watch(homeRankSnapshotProvider(_puuid))
      ..watch(homeServerStatusProvider);
    return const SizedBox();
  }
}

void main() {
  late HomeTestEnv env;
  late WidgetRef probe;

  setUp(() async {
    env = await HomeTestEnv.create();
    env.content = bpContent();
    when(() => env.api.storefront(any()))
        .thenAnswer((_) async => economyFixture('storefront.json'));
    when(() => env.api.wallet(any()))
        .thenAnswer((_) async => economyFixture('wallet.json'));
    when(() => env.api.contracts(any()))
        .thenAnswer((_) async => contractsJson());
    when(() => env.api.dailyTicket(any()))
        .thenAnswer((_) async => dailyTicketJson());
    when(() => env.api.mmr(any(), subject: any(named: 'subject')))
        .thenAnswer((_) async => throw const TransientException(reason: 'x'));
    when(
      () => env.api.competitiveUpdates(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
      ),
    ).thenAnswer((_) async => throw const TransientException(reason: 'x'));
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpHomeCard(tester, env, _Probe(onRef: (ref) => probe = ref));
    await homeSettle(tester);
    clearInteractions(env.api);
  }

  testWidgets('refreshes only the cards that are shown', (tester) async {
    await pump(tester);

    // Only the store is shown: the Battle Pass and rank are left alone.
    await refreshHome(
      probe,
      puuid: _puuid,
      shown: const HomeArrangement(flow: [HomeCardId.store]),
    );
    await homeSettle(tester);
    verify(() => env.api.storefront(_puuid)).called(1);
    verify(() => env.api.wallet(_puuid)).called(1);
    verifyNever(() => env.api.contracts(any()));
    verifyNever(() => env.api.mmr(any(), subject: any(named: 'subject')));
    await homeUnmount(tester);
  });

  testWidgets('refreshes each shown card once, in parallel', (tester) async {
    await pump(tester);

    await refreshHome(
      probe,
      puuid: _puuid,
      shown: const HomeArrangement(
        pinned: [HomeCardId.serverStatus],
        flow: [HomeCardId.store, HomeCardId.battlePass],
      ),
    );
    await homeSettle(tester);
    verify(() => env.api.storefront(_puuid)).called(1);
    verify(() => env.api.contracts(_puuid)).called(1);
    verify(() => env.api.dailyTicket(_puuid)).called(1);
    // The pinned status card refreshes X-1 of the account regions.
    verify(() => env.api.platformStatus('ap')).called(greaterThanOrEqualTo(1));
    await homeUnmount(tester);
  });

  testWidgets('nothing shown: nothing fetched', (tester) async {
    await pump(tester);
    await refreshHome(probe, puuid: _puuid, shown: const HomeArrangement());
    verifyNever(() => env.api.storefront(any()));
    verifyNever(() => env.api.contracts(any()));
    await homeUnmount(tester);
  });

  testWidgets('errors are swallowed (the cards show them themselves)', (
    tester,
  ) async {
    await pump(tester);
    when(() => env.api.storefront(any()))
        .thenAnswer((_) async => throw const TransientException(reason: 'x'));

    // Completes normally, no exception escapes.
    await refreshHome(
      probe,
      puuid: _puuid,
      shown: const HomeArrangement(flow: [HomeCardId.store]),
    );
    await homeSettle(tester);
    expect(tester.takeException(), isNull);
    await homeUnmount(tester);
  });

  testWidgets('stops waiting after the timeout when a call hangs', (
    tester,
  ) async {
    await pump(tester);
    final never = Completer<Map<String, dynamic>>();
    when(() => env.api.storefront(any())).thenAnswer((_) => never.future);

    var done = false;
    unawaited(
      refreshHome(
        probe,
        puuid: _puuid,
        shown: const HomeArrangement(flow: [HomeCardId.store]),
      ).then((_) => done = true),
    );
    await tester.pump(const Duration(seconds: 5));
    expect(done, isFalse, reason: 'still within the timeout');

    await tester.pump(kHomeRefreshTimeout);
    await tester.pump();
    expect(done, isTrue, reason: 'the spinner stops after 12 s at the latest');
    await homeUnmount(tester);
  });

  group('HomeCardPoller', () {
    Future<int> ticks(
      WidgetTester tester, {
      required bool tabVisible,
      bool foreground = true,
      Duration wait = const Duration(minutes: 5),
    }) async {
      var count = 0;
      await pumpHomeCard(
        tester,
        env,
        TickerMode(
          enabled: tabVisible,
          child: HomeCardPoller(
            every: const Duration(minutes: 1),
            onTick: () => count++,
            child: const SizedBox(),
          ),
        ),
      );
      if (!foreground) {
        ProviderScope.containerOf(tester.element(find.byType(HomeCardPoller)))
            .read(appForegroundProvider);
        env.foreground.foreground = false;
      }
      await tester.pump(wait);
      await homeUnmount(tester);
      return count;
    }

    testWidgets('ticks while the tab is visible and the app in front', (
      tester,
    ) async {
      expect(await ticks(tester, tabVisible: true), 5);
    });

    testWidgets('is silent while the tab is not visible', (tester) async {
      expect(await ticks(tester, tabVisible: false), 0);
    });

    testWidgets('is silent while the app is in the background', (tester) async {
      expect(await ticks(tester, tabVisible: true, foreground: false), 0);
    });
  });
}
