import '../../../helpers/l10n.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/ui/performance_screen.dart';
import 'package:valvn/features/profile/ui/widgets/performance_widgets.dart';
import 'package:valvn/features/profile/ui/widgets/profile_widgets.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  final content = testContent();
  final jett = content.agents.first;
  // The fixtures hold one agent; another uuid shows as an unknown agent.
  const otherAgent = '11111111-1111-4111-8111-111111111111';
  final maps = [
    for (final m in content.maps)
      if (m.mapUrl.isNotEmpty) m,
  ];

  MatchStatLine line(
    ProfileTestEnv env,
    String id, {
    String queue = 'competitive',
    String? agent,
    String? map,
    MatchOutcome outcome = MatchOutcome.win,
    int score = 2000,
  }) => MatchStatLine(
    matchId: id,
    startedAt: env.clock.now().toUtc(),
    outcome: outcome,
    queueId: queue,
    agentId: agent ?? jett.uuid,
    mapId: map ?? maps.first.mapUrl,
    rounds: 10,
    score: score,
    kills: 10,
    deaths: 5,
  );

  void verifyNoMatchRequests(ProfileTestEnv env) {
    verifyNever(
      () => env.api.matchDetails(
        any(),
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
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
  }

  testWidgets(
    'own ledger only, sample threshold, queue filter and zero requests',
    (tester) async {
      final env = await ProfileTestEnv.create();
      await env.ledger.record(me, [
        for (var i = 0; i < 3; i++)
          line(env, 'm$i', queue: i == 0 ? 'unrated' : 'competitive'),
      ]);
      await pumpProfile(tester, env, const PerformanceScreen(), height: 2400);
      await settle(tester);

      expect(
        find.textContaining(tl.profilePerformanceSince('')),
        findsOneWidget,
      );
      expect(find.byType(PerfOverviewCard), findsOneWidget);
      expect(find.text('100%'), findsWidgets);
      expect(find.text('200'), findsWidgets);
      verifyNoMatchRequests(env);

      // Only two competitive matches: below the 3-match sample.
      final all = tl.profilePerformanceQueueChip(tl.profileFilterAll);
      await tester.tap(find.text(all));
      await settle(tester);
      final ranked = content.queueName(tl, 'competitive');
      await tester.tap(find.text(ranked).last);
      await settle(tester);
      expect(find.text(tl.profilePerformanceQueueChip(ranked)), findsOneWidget);
      final acs = tester
          .widgetList<StatTile>(find.byType(StatTile))
          .firstWhere((t) => t.label == tl.profileAcs);
      expect(acs.value, tl.competitiveNoValue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('no stored matches: the explanation and the backfill button', (
    tester,
  ) async {
    final env = await ProfileTestEnv.create();
    await pumpProfile(tester, env, const PerformanceScreen());
    await settle(tester);
    expect(find.text(tl.profilePerformanceEmpty), findsOneWidget);
    expect(find.text(tl.profilePerformanceLoadOlder), findsOneWidget);
    verifyNoMatchRequests(env);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ADR and HS require three matches with their own data', (
    tester,
  ) async {
    final env = await ProfileTestEnv.create();
    await env.ledger.record(me, [
      for (var i = 0; i < 3; i++)
        MatchStatLine(
          matchId: 'm$i',
          startedAt: env.clock.now().toUtc(),
          outcome: MatchOutcome.win,
          rounds: 10,
          score: 2000,
          damage: i == 0 ? 1500 : null,
          headshots: i == 0 ? 1 : 0,
          bodyshots: i == 0 ? 1 : 0,
        ),
    ]);
    await pumpProfile(tester, env, const PerformanceScreen(), height: 2400);
    await settle(tester);
    final tiles = tester.widgetList<StatTile>(find.byType(StatTile));
    expect(tiles.firstWhere((t) => t.label == tl.profileAcs).value, '200');
    for (final label in [tl.profileAdr, tl.profileHs]) {
      expect(
        tiles.firstWhere((t) => t.label == label).value,
        tl.competitiveNoValue,
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an agent row narrows the screen to that agent and its maps', (
    tester,
  ) async {
    final env = await ProfileTestEnv.create();
    await env.ledger.record(me, [
      for (var i = 0; i < 3; i++) line(env, 'j$i', map: maps[i % 2].mapUrl),
      for (var i = 0; i < 4; i++)
        line(env, 's$i', agent: otherAgent, outcome: MatchOutcome.loss),
    ]);
    await pumpProfile(tester, env, const PerformanceScreen(), height: 3200);
    await settle(tester);

    expect(find.text(tl.profileMatchCount(7)), findsWidgets);
    await tester.ensureVisible(find.text(jett.displayName).last);
    await tester.tap(find.text(jett.displayName).last);
    await settle(tester);

    // The overview now counts Jett's three wins; the table lists her maps.
    expect(find.text(tl.profileMatchCount(3)), findsWidgets);
    expect(find.byType(InputChip), findsOneWidget);
    expect(find.text(maps[0].displayName), findsWidgets);
    expect(find.text(maps[1].displayName), findsWidgets);
    expect(find.text(tl.commonUnknownItem), findsNothing);

    // "Bỏ lọc" restores every agent.
    await tester.ensureVisible(find.text(tl.commonClearFilters));
    await tester.tap(find.text(tl.commonClearFilters));
    await settle(tester);
    expect(find.text(tl.profileMatchCount(7)), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a bar of the per-match chart opens that match', (tester) async {
    final env = await ProfileTestEnv.create();
    await env.ledger.record(me, [
      for (var i = 0; i < 4; i++) line(env, 'c$i', score: 1500 + i * 300),
    ]);
    final router = await pumpProfileRouter(
      tester,
      env,
      initialLocation: '/profile/performance',
      height: 2400,
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const SizedBox(),
          routes: [
            GoRoute(
              path: 'performance',
              builder: (_, _) => const PerformanceScreen(),
            ),
            GoRoute(
              path: 'match/:id',
              builder: (_, s) => Text('match ${s.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );
    await settle(tester);
    expect(find.byType(PerfMatchChartCard), findsOneWidget);
    expect(
      find.text(tl.profilePerformanceAverage('195')),
      findsOneWidget,
      reason: 'Σ score / Σ rounds of the four plotted matches',
    );
    // Tap the right-most (newest) bar.
    final bars = tester.getRect(
      find.descendant(
        of: find.byType(PerfMatchChartCard),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.height == 132,
        ),
      ),
    );
    // Anywhere in the newest match's column (not only on its bar).
    await tester.tapAt(Offset(bars.left + bars.width * 7 / 8, bars.top + 8));
    await settle(tester);
    expect(find.textContaining('match c'), findsOneWidget);
    router.pop();
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
