import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/segmented_tabs.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/providers/profile_providers.dart';
import 'package:valvn/features/profile/ui/match_detail_screen.dart';
import 'package:valvn/features/profile/ui/profile_screen.dart';
import 'package:valvn/features/profile/ui/widgets/match_card.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
  });

  const screen = ProfileScreen(currentGameCard: SizedBox(key: Key('game')));

  testWidgets('recent form card summarises the loaded matches', (tester) async {
    await pumpProfile(tester, env, screen, height: 2800);
    await settle(tester, frames: 12);
    expect(
      find.text(ProfileStrings.recentFormTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(ProfileStrings.kd), findsOneWidget);
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(ProfileStrings.winRate), findsOneWidget);
    handle.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the mode filter is remembered across launches', (tester) async {
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);

    final chip = find.descendant(
      of: find.byType(SegmentedTabs<String?>),
      matching: find.text('Sinh Tử'),
    );
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await settle(tester);
    expect(
      env.prefs.getString(PrefKeys.ui(MatchFilterNotifier.modeKey)),
      'deathmatch',
    );

    // A fresh app (new ProviderScope) opens on the remembered mode.
    await tester.pumpWidget(const SizedBox());
    clearInteractions(env.api);
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);
    verify(
      () => env.api.matchHistory(
        any(),
        subject: me,
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: 'deathmatch',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
    expect(find.byType(MatchCard), findsNothing);
    expect(find.text(ProfileStrings.noMatchesQueue), findsOneWidget);
  });

  testWidgets('a remembered map filter is restored with a clear chip', (
    tester,
  ) async {
    await env.prefs.setString(
      PrefKeys.ui(MatchFilterNotifier.mapKey),
      '/Game/Maps/HURM/HURM_Alley/HURM_Alley',
    );
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester, frames: 12);
    expect(find.text(ProfileStrings.mapFilter('District')), findsOneWidget);
    await tester.ensureVisible(find.text('Bỏ lọc'));
    await tester.tap(find.text('Bỏ lọc'));
    await settle(tester);
    expect(
      find.text(ProfileStrings.mapFilter(ProfileStrings.filterAll)),
      findsOneWidget,
    );
    expect(env.prefs.getString(PrefKeys.ui(MatchFilterNotifier.mapKey)), null);
  });

  for (final (name, theme) in [
    ('dark', buildDarkTheme()),
    ('light', buildLightTheme()),
  ]) {
    testWidgets('profile fits 360 dp at 200 % text ($name theme)', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpProfile(tester, env, screen, height: 5000, theme: theme);
      await settle(tester, frames: 12);
      expect(tester.takeException(), isNull);
      expect(find.byType(MatchCard), findsWidgets);
    });

    testWidgets('match detail fits 360 dp at 200 % text ($name theme)', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpProfile(
        tester,
        env,
        const MatchDetailScreen(matchId: compMatch),
        height: 4000,
        theme: theme,
      );
      await settle(tester, frames: 12);
      expect(tester.takeException(), isNull);
      expect(find.text('ASCENT'), findsWidgets);
      await tester.tap(find.text(ProfileStrings.roundTimeline));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
