import 'dart:ui' show DisplayFeature;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/l10n/locale.dart';
import 'package:valvn/core/theme/app_theme.dart';

import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/ui/home_screen.dart';

import 'home_test_env.dart';

/// Routes the cards navigate to, as placeholders that print their
/// location. A pushed page shows a back arrow, a `go` page does not.
List<GoRoute> homeProbeRoutes() => [
  for (final path in const [
    '/store',
    '/store/bundle/:id',
    '/profile',
    '/profile/rankup',
    '/profile/daily-rr',
    '/profile/friends',
    '/profile/friends/:puuid/chat',
    '/battlepass',
    '/battlepass/rewards',
    '/community',
    '/settings/status',
    '/login',
  ])
    GoRoute(
      path: path,
      builder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('route ${state.uri}')),
      ),
    ),
];

/// Pumps [child] (a card) on a scrolling page in a router that knows the
/// destinations of [homeProbeRoutes].
Future<GoRouter> pumpHomeCard(
  WidgetTester tester,
  HomeTestEnv env,
  Widget child, {
  List<Override> overrides = const [],
  Size size = const Size(360, 900),
  double textScale = 1,
  ThemeData? theme,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
      ...homeProbeRoutes(),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...env.overrides, ...overrides],
      retry: (_, _) => null,
      child: MaterialApp.router(
        theme: theme ?? buildDarkTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
        builder: disableAnimations
            ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              )
            : null,
      ),
    ),
  );
  await homeSettle(tester);
  return router;
}

/// Pumps [HomeScreen] alone (no tab shell) with the probe destinations, so
/// navigation from the header and the cards can be observed.
Future<GoRouter> pumpHomeScreen(
  WidgetTester tester,
  HomeTestEnv env, {
  List<Override> overrides = const [],
  Size size = const Size(360, 780),
  double textScale = 1,
  ThemeData? theme,
  HomeCardId? focus,
  bool disableAnimations = false,
  TextDirection? direction,
  List<DisplayFeature> displayFeatures = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final router = GoRouter(
    initialLocation: focus == null ? '/home' : '/home?focus=${focus.storageId}',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
          focus: HomeCardId.tryParse(state.uri.queryParameters['focus']),
          linkNonce: state.uri.queryParameters['nav'],
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('route ${state.uri}')),
        ),
      ),
      ...homeProbeRoutes(),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...env.overrides, ...overrides],
      retry: (_, _) => null,
      child: MaterialApp.router(
        theme: theme ?? buildDarkTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
        builder: (context, child) {
          var data = MediaQuery.of(context);
          if (disableAnimations || displayFeatures.isNotEmpty) {
            data = data.copyWith(
              disableAnimations: disableAnimations,
              displayFeatures: displayFeatures.isEmpty
                  ? data.displayFeatures
                  : displayFeatures,
            );
          }
          final page = MediaQuery(data: data, child: child!);
          return direction == null
              ? page
              : Directionality(textDirection: direction, child: page);
        },
      ),
    ),
  );
  await homeSettle(tester);
  return router;
}

/// Pumps the real app router (the five-tab shell) starting at [initial].
Future<GoRouter> pumpHomeApp(
  WidgetTester tester,
  HomeTestEnv env, {
  List<Override> overrides = const [],
  Size size = const Size(360, 780),
  double textScale = 1,
  ThemeData? theme,
  String initial = '/home',
  bool disableAnimations = false,
  List<DisplayFeature> displayFeatures = const [],
  TextDirection? direction,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final router = createAppRouter(
    hasAccounts: ValueNotifier(true),
    initialLocation: initial,
    navigatorKey: GlobalKey<NavigatorState>(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...env.overrides, ...overrides],
      retry: (_, _) => null,
      child: MaterialApp.router(
        theme: theme ?? buildDarkTheme(),
        locale: appLocale,
        supportedLocales: const [appLocale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
        builder: (context, child) {
          var data = MediaQuery.of(context);
          if (disableAnimations || displayFeatures.isNotEmpty) {
            data = data.copyWith(
              disableAnimations: disableAnimations,
              displayFeatures: displayFeatures.isEmpty
                  ? data.displayFeatures
                  : displayFeatures,
            );
          }
          final page = MediaQuery(data: data, child: child!);
          return direction == null
              ? page
              : Directionality(textDirection: direction, child: page);
        },
      ),
    ),
  );
  await homeSettle(tester);
  return router;
}

/// Lets futures and frames run (shimmers and countdowns never settle).
Future<void> homeSettle(WidgetTester tester, {int frames = 10}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Opens the startup gate (the deferred cards read their data).
Future<void> homePastGate(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1600));
  await homeSettle(tester);
}

/// Unmounts the tree so timers and tickers are disposed.
Future<void> homeUnmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(minutes: 11));
}

/// Fails with the full render-tree description when a frame threw (an
/// overflow, for instance), so the culprit widget is named.
void homeExpectNoException(WidgetTester tester) {
  final e = tester.takeException();
  if (e == null) return;
  fail(e is FlutterError ? e.toStringDeep() : '$e');
}
