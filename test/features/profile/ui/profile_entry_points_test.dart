import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/battlepass/battlepass_strings.dart';
import 'package:valvn/features/battlepass/data/battlepass_models.dart';
import 'package:valvn/features/battlepass/data/player_contracts.dart';
import 'package:valvn/features/battlepass/providers/battlepass_providers.dart';
import 'package:valvn/features/profile/ui/profile_screen.dart';

import '../../battlepass/bp_fixtures.dart';
import '../profile_test_env.dart';

/// The Hồ sơ tab now hosts Battle Pass and Cài đặt: a "Battle Pass" row with
/// its progress and a ⚙ button in the header.
void main() {
  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
  });

  final overview = BattlePassOverview.build(
    db: bpContent(),
    contracts: PlayerContracts.fromJson(contractsJson(), receivedAt: t0),
    now: t0,
    premiumContracts: {Bp.bpId},
  );

  Future<void> pumpProfile(
    WidgetTester tester, {
    List<Override> extra = const [],
  }) async {
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const ProfileScreen(currentGameCard: SizedBox()),
        ),
        for (final path in const ['/settings', '/battlepass'])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: Center(child: Text('route ${state.uri}')),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...env.overrides, ...extra],
        retry: (_, _) => null,
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('⚙ pushes Cài đặt on top of Hồ sơ', (tester) async {
    await pumpProfile(tester);
    expect(find.byTooltip(CommonStrings.tabSettings), findsOneWidget);

    await tester.tap(find.byTooltip(CommonStrings.tabSettings));
    await settle(tester, frames: 16);
    expect(find.text('route /settings'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester, frames: 16);
    expect(find.byType(ProfileScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the Battle Pass row shows the level and opens the pass', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      extra: [
        battlePassOverviewProvider.overrideWith((ref, puuid) async => overview),
      ],
    );
    final row = find.text(CommonStrings.tabBattlePass);
    await tester.ensureVisible(row);
    expect(row, findsOneWidget);
    expect(
      find.textContaining(
        BattlePassStrings.levelOf(formatNumber(46), formatNumber(55)),
      ),
      findsOneWidget,
    );
    // Days left in the act.
    expect(find.textContaining('Còn '), findsWidgets);

    await tester.tap(row);
    await settle(tester, frames: 16);
    expect(find.text('route /battlepass'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the row is just its title while the pass is unknown', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      extra: [
        battlePassOverviewProvider.overrideWith(
          (ref, puuid) async => throw StateError('offline'),
        ),
      ],
    );
    final row = find.text(CommonStrings.tabBattlePass);
    await tester.ensureVisible(row);
    expect(row, findsOneWidget);
    expect(find.textContaining('Cấp 46'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
