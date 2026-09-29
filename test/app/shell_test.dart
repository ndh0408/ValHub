import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/app/shell.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/floating_nav_bar.dart';
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

    final nav = tester.widget<FloatingNavBar>(find.byType(FloatingNavBar));
    expect(nav.destinations, hasLength(6));
    expect(nav.compact, isTrue);
    // "Cộng đồng" is the middle tab (index 2).
    expect(nav.destinations[2].label, CommonStrings.tabCommunity);
    expect(tester.takeException(), isNull);

    final bar = tester.getRect(find.byType(FloatingNavBar));
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.bySemanticsLabel(labels[i]));
      await tester.pumpAndSettle();
      expect(find.text('trang $i'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: labels[i]);
      // Compact: only the selected tab shows its label, on one line.
      final shown = find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.text(labels[i]),
      );
      expect(shown, findsOneWidget, reason: labels[i]);
      final label = tester.getRect(shown);
      expect(label.bottom, lessThanOrEqualTo(bar.bottom));
      expect(label.height, lessThan(24));
      for (var j = 0; j < 6; j++) {
        if (j == i) continue;
        expect(
          find.descendant(
            of: find.byType(FloatingNavBar),
            matching: find.text(labels[j]),
          ),
          findsNothing,
        );
      }
    }
  });

  testWidgets('wide screens show every label', (tester) async {
    await _pumpShell(tester, size: const Size(600, 900));
    final nav = tester.widget<FloatingNavBar>(find.byType(FloatingNavBar));
    expect(nav.compact, isFalse);
    for (final label in labels) {
      expect(
        find.descendant(
          of: find.byType(FloatingNavBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
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
    final bar = tester.widget<FloatingNavBar>(find.byType(FloatingNavBar));
    expect(bar.selectedIndex, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
