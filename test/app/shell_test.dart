import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/app/shell.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/ui/community_screen.dart';

import '../helpers/test_prefs.dart';

/// The tab shell with six placeholder branches.
Future<GoRouter> _pumpShell(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final prefs = await createTestPrefs();
  final router = GoRouter(
    initialLocation: '/t0',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          for (var i = 0; i < 6; i++)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/t$i',
                  builder: (context, state) => Center(child: Text('trang $i')),
                ),
              ],
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: MaterialApp.router(
        theme: buildDarkTheme(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  const labels = [
    CommonStrings.tabStore,
    CommonStrings.tabBattlePass,
    CommonStrings.tabCommunity,
    CommonStrings.tabCollection,
    CommonStrings.tabProfile,
    CommonStrings.tabSettings,
  ];

  testWidgets('six tabs fit a 360 dp phone at text scale 1.3', (tester) async {
    await _pumpShell(tester, size: const Size(360, 740), textScale: 1.3);

    final destinations = find.byType(NavigationDestination);
    expect(destinations, findsNWidgets(6));
    expect(tester.takeException(), isNull);
    // "Cộng đồng" is the middle tab (index 2).
    expect(
      find.descendant(
        of: destinations.at(2),
        matching: find.text(CommonStrings.tabCommunity),
      ),
      findsOneWidget,
    );

    for (var i = 0; i < 6; i++) {
      await tester.tap(destinations.at(i));
      await tester.pumpAndSettle();
      expect(find.text('trang $i'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: labels[i]);
      // The selected label stays on one line inside the bar.
      final label = tester.getRect(
        find.descendant(of: destinations.at(i), matching: find.text(labels[i])),
      );
      final bar = tester.getRect(find.byType(NavigationBar));
      expect(label.bottom, lessThanOrEqualTo(bar.bottom));
      expect(label.height, lessThan(24));
    }
  });

  testWidgets('wide screens show every label', (tester) async {
    await _pumpShell(tester, size: const Size(600, 900));
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('/community is the third branch of the app router', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final prefs = await createTestPrefs();
    final router = createAppRouter(
      hasAccounts: ValueNotifier(true),
      initialLocation: '/community?section=lfg',
      navigatorKey: GlobalKey<NavigatorState>(),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final screen = tester.widget<CommunityScreen>(find.byType(CommunityScreen));
    expect(screen.initialSection, CommunitySection.lfg);
    // No signed-in account: the friendly sign-in state, no network.
    expect(find.text(CommunityStrings.noAccountTitle), findsOneWidget);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
