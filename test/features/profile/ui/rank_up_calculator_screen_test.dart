import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/ui/rank_up_calculator_screen.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpProfile(
      tester,
      env,
      const RankUpCalculatorScreen(),
      height: 1800,
    );
    await settle(tester);
  }

  testWidgets('estimates the next tier from recent form', (tester) async {
    // Diamond 1 · 6 RR; recent form +24 / −18 / +20 → G 22, L 18, p 2/3.
    await pump(tester);

    expect(find.text(ProfileStrings.rankUpTitle), findsOneWidget);
    expect(find.text('Kim Cương 1'), findsOneWidget);
    expect(find.text(ProfileStrings.rrLeft('94')), findsOneWidget);
    expect(find.text(ProfileStrings.aboutMatches(11)), findsOneWidget);
    expect(find.text(ProfileStrings.bestCase(5)), findsOneWidget);
    expect(find.text(ProfileStrings.recentForm(2, 1)), findsOneWidget);
    // Win-rate table: 45 % cannot be estimated (E = 0), 60 % → 16.
    expect(find.text('45%'), findsOneWidget);
    expect(find.text(CompetitiveStrings.noValue), findsOneWidget);
    expect(find.text(ProfileStrings.aboutMatches(16)), findsOneWidget);
    expect(find.text(ProfileStrings.rankUpFootnote), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a higher target recomputes', (tester) async {
    await pump(tester);

    // Targets go up to Bất Tử 1 (tier 24 of the current table).
    expect(find.text('Bất Tử 1'), findsOneWidget);
    await tester.tap(find.text('Kim Cương 3'));
    await settle(tester);
    // (20 − 18) × 100 − 6 = 194 RR; 194 / (⅔·22 − ⅓·18) → 23 matches.
    expect(find.text(ProfileStrings.rrLeft('194')), findsOneWidget);
    expect(find.text(ProfileStrings.aboutMatches(23)), findsOneWidget);
    expect(find.text(ProfileStrings.bestCase(9)), findsOneWidget);
  });

  testWidgets('placements: explains instead of calculating', (tester) async {
    env.mmr = {
      'Subject': me,
      'QueueSkills': {
        'competitive': {
          'CurrentSeasonGamesNeededForRating': 3,
          'SeasonalInfoBySeasonID': <String, Object>{},
        },
      },
    };
    await pump(tester);
    expect(find.text(ProfileStrings.rankUpUnranked), findsOneWidget);
  });

  testWidgets('without recent matches the form is unknown', (tester) async {
    env.updates = {'Subject': me, 'Matches': <Object>[]};
    await pump(tester);
    expect(find.text(ProfileStrings.rankUpNoForm), findsOneWidget);
    expect(find.text(ProfileStrings.rrLeft('94')), findsOneWidget);
  });

  testWidgets('MMR error shows "Thử lại"', (tester) async {
    when(() => env.api.mmr(any(), subject: any(named: 'subject')))
        .thenThrow(const MaintenanceException());
    await pump(tester);
    expect(find.text(CommonStrings.errorMaintenance), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsOneWidget);
  });
}
