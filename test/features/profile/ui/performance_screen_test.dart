import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/data/performance_view.dart';
import 'package:valvn/features/profile/ui/performance_screen.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);
  testWidgets(
    'own ledger only, sample threshold, queue filters and zero match requests',
    (tester) async {
      final env = await ProfileTestEnv.create();
      await env.ledger.record(me, [
        for (var i = 0; i < 3; i++)
          MatchStatLine(
            matchId: 'm$i',
            startedAt: env.clock.now().toUtc(),
            outcome: MatchOutcome.win,
            queueId: i == 0 ? 'unrated' : 'competitive',
            rounds: 10,
            score: 2000,
          ),
      ]);
      await pumpProfile(tester, env, const PerformanceScreen(), height: 1800);
      await settle(tester);
      expect(find.textContaining('Lịch sử trên thiết bị, từ'), findsOneWidget);
      expect(find.text('100%'), findsWidgets);
      expect(find.text('200'), findsWidgets);
      verifyNever(() => env.api.matchDetails(any(), any()));
      final ranked = testContent().queueName('competitive');
      await tester.tap(find.text(ranked).first);
      await settle(tester);
      expect(find.text('100%'), findsNothing);
      expect(find.text('200'), findsNothing);
      await tester.tap(
        find.text(ProfileStrings.performanceSegment(PerfSegment.sides)),
      );
      await settle(tester);
      expect(find.textContaining('0/20 vòng'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('no stored matches gives actionable empty text', (tester) async {
    final env = await ProfileTestEnv.create();
    await pumpProfile(tester, env, const PerformanceScreen());
    await settle(tester);
    expect(find.text(ProfileStrings.performanceEmpty), findsOneWidget);
    verifyNever(() => env.api.matchDetails(any(), any()));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
