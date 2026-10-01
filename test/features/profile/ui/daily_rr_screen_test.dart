import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/ui/daily_rr_screen.dart';
import 'package:valvn/features/profile/ui/widgets/rr_trend_chart.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpProfile(tester, env, const DailyRrScreen(), height: 1600);
    await settle(tester);
  }

  testWidgets('groups ranked matches by local day, newest first', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text(CommonStrings.today), findsOneWidget);
    expect(find.text(CommonStrings.yesterdayTitle), findsOneWidget);
    // Today: one win (+24); yesterday: +20 and −18 → +2.
    expect(find.text('+24 RR'), findsWidgets);
    expect(find.text('+2 RR'), findsWidgets);
    expect(
      find.textContaining(ProfileStrings.winsLosses(1, 1, 0)),
      findsOneWidget,
    );
    // Rank change across the day (Bạch Kim 3 → Kim Cương 1).
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label ==
                ProfileStrings.rankChange('Bạch Kim 3', 'Kim Cương 1'),
      ),
      findsOneWidget,
    );
    expect(find.byType(RrTrendChart), findsOneWidget);
    expect(find.text(ProfileStrings.dailyRrFootnote), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanding a day lists its matches', (tester) async {
    await pump(tester);
    // Today is expanded by default: one Ascent row.
    expect(find.text('Ascent'), findsOneWidget);

    await tester.tap(find.text(CommonStrings.yesterdayTitle));
    await settle(tester, frames: 12);
    expect(find.text('Ascent'), findsNWidgets(3));
  });

  testWidgets('empty history shows the on-device message', (tester) async {
    env.updates = {'Subject': me, 'Matches': <Object>[]};
    await pump(tester);
    expect(find.text(ProfileStrings.dailyRrEmpty), findsOneWidget);
  });

  testWidgets('a failed refresh shows "Thử lại"', (tester) async {
    when(
      () => env.api.competitiveUpdates(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenThrow(const TransientException(reason: 'network'));
    await pump(tester);
    expect(find.text(CommonStrings.errorNetwork), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsOneWidget);
  });
}
