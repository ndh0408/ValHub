import 'package:valvn/core/l10n/l10n.dart';

import 'dart:async';

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
import '../helpers/l10n.dart';

/// The tab shell with five placeholder branches.
Future<GoRouter> _pumpShell(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
  ThemeData? theme,
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
          for (var i = 0; i < AppTab.values.length; i++)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/t$i',
                  builder: (context, state) => Center(child: Text('trang $i')),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) =>
                          Center(child: Text('chi tiết $i')),
                    ),
                  ],
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
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: const [Locale('vi')],
        theme: theme ?? buildDarkTheme(),
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
    CommonStrings.tabHome,
    CommonStrings.tabStore,
    CommonStrings.tabCommunity,
    CommonStrings.tabCollection,
    CommonStrings.tabProfile,
  ];

  test('AppTab lists the five tabs in bar order, without magic indexes', () {
    expect(AppTab.values.map((t) => t.label(tl)), labels);
    expect(AppTab.home.index, 0);
    expect(AppTab.community.index, 2);
    expect(AppTab.profile.root, '/profile');
    expect(AppTab.home.root, '/home');
  });

  for (final width in [320.0, 360.0]) {
    for (final scale in [1.3, 2.0]) {
      testWidgets('five tabs fit ${width.round()} dp at text scale $scale', (
        tester,
      ) async {
        await _pumpShell(tester, size: Size(width, 740), textScale: scale);

        final nav = tester.widget<FloatingNavBar>(find.byType(FloatingNavBar));
        expect(nav.destinations, hasLength(5));
        // Below 360 dp only the selected tab shows its label.
        expect(nav.compact, width < 360);
        // "Cộng đồng" is the middle, emphasized tab.
        expect(nav.destinations[2].label, CommonStrings.tabCommunity);
        expect(nav.emphasizedIndex, AppTab.community.index);
        expect(tester.takeException(), isNull);

        final bar = tester.getRect(find.byType(FloatingNavBar));
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.bySemanticsLabel(labels[i]));
          await tester.pumpAndSettle();
          expect(find.text('trang $i'), findsOneWidget);
          expect(tester.takeException(), isNull, reason: labels[i]);
          final shown = find.descendant(
            of: find.byType(FloatingNavBar),
            matching: find.text(labels[i]),
          );
          expect(shown, findsOneWidget, reason: labels[i]);
          final label = tester.getRect(shown);
          expect(label.bottom, lessThanOrEqualTo(bar.bottom));
          expect(label.height, lessThan(24));
          if (width < 360) {
            // Compact: the other labels are hidden.
            for (var j = 0; j < 5; j++) {
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
        }
      });
    }
  }

  testWidgets('the light theme fits too', (tester) async {
    await _pumpShell(
      tester,
      size: const Size(360, 740),
      textScale: 2,
      theme: buildLightTheme(),
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.bySemanticsLabel(labels[i]));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: labels[i]);
    }
  });

  testWidgets('wide screens show a rail and preserve the branch on resize', (
    tester,
  ) async {
    final router = await _pumpShell(tester, size: const Size(600, 900));
    expect(find.byType(FloatingNavBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    for (final label in labels) {
      expect(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
    router.go('/t1/detail');
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsOneWidget);
    expect(find.text('chi tiết 1'), findsOneWidget);
    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('chi tiết 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('re-tapping the active tab pops its branch to the root', (
    tester,
  ) async {
    final router = await _pumpShell(tester, size: const Size(390, 800));
    await tester.tap(find.bySemanticsLabel(CommonStrings.tabStore));
    await tester.pumpAndSettle();
    unawaited(router.push('/t1/detail'));
    await tester.pumpAndSettle();
    expect(find.text('chi tiết 1'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(CommonStrings.tabStore));
    await tester.pumpAndSettle();
    expect(find.text('trang 1'), findsOneWidget);
    expect(find.text('chi tiết 1'), findsNothing);
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
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: const [Locale('vi')],
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
    expect(bar.selectedIndex, AppTab.community.index);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
