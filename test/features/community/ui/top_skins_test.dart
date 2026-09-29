import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/ui/skins/skin_review_screen.dart';

import '../community_test_env.dart';
import '../data/skin_review_test.dart' show summaryJson;

Future<void> _open(
  WidgetTester tester,
  CommunityTestEnv env, {
  Size size = const Size(360, 1600),
  double textScale = 1,
  bool light = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/community?section=skins',
    routes: [...communityTopLevelRoutes, ...communityBranchRoutes],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
      ],
      retry: (_, _) => null,
      child: MaterialApp.router(
        theme: light ? buildLightTheme() : buildDarkTheme(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  await settle(tester);
}

Future<void> _chip(WidgetTester tester, String label, String list) async {
  final chip = find.widgetWithText(FilterChip, label);
  await tester.scrollUntilVisible(
    chip,
    120,
    scrollable: find.descendant(
      of: find.byKey(ValueKey(list)),
      matching: find.byType(Scrollable),
    ),
  );
  // Bring the whole chip on screen (Ahem test glyphs are wide).
  for (var i = 0; i < 10 && tester.getRect(chip).right > 350; i++) {
    await tester.drag(find.byKey(ValueKey(list)), const Offset(-80, 0));
    await tester.pump();
  }
  await tester.tap(chip);
}

final _rows = {
  'items': [
    {
      'rank': 1,
      'skinUuid': reaverSkin,
      'weaponUuid': vandal,
      'votes': 12,
      'ratingAvg': 4.56,
      'ratingCount': 128,
    },
    {'rank': 2, 'skinUuid': knifeSkin, 'votes': 4, 'voted': true},
  ],
};

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  testWidgets('rows show ★ average + count, hearts; default all time', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/top', _rows);
    await _open(tester, env);

    expect(find.text(CommunityStrings.periodAllTime), findsOneWidget);
    final q = env.server.calls('GET /v1/skins/top').single.query;
    expect((q['period'], q['sort']), ('all', 'votes'));
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text('4,6'), findsOneWidget);
    expect(find.text(CommunityStrings.ratingCount('128')), findsOneWidget);
    expect(find.text(CommunityStrings.noRatings), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('sort chips, period and weapon refetch and are remembered', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/top', {'items': <Object>[]});
    await _open(tester, env);

    await _chip(tester, CommunityStrings.sortRating, 'skins-sort');
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['sort'], 'rating');
    await _chip(tester, CommunityStrings.sortReviews, 'skins-sort');
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['sort'], 'reviews');
    await tester.tap(find.text(CommunityStrings.periodWeek));
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['period'], 'week');
    await _chip(tester, 'Vandal', 'skins-weapons');
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['weapon'], vandal);
    expect(find.text(CommunityStrings.skinsEmptyTitle), findsOneWidget);

    expect(env.prefs.getString(PrefKeys.ui('community.skins.sort')), 'reviews');
    expect(env.prefs.getString(PrefKeys.ui('community.skins.period')), 'week');
    expect(env.prefs.getString(PrefKeys.ui('community.skins.weapon')), vandal);
    await unmount(tester);
  });

  testWidgets('tapping a skin opens its review page', (tester) async {
    env.server
      ..json('GET /v1/skins/top', _rows)
      ..json('GET /v1/skins/*/summary', summaryJson())
      ..json('GET /v1/skins/*/reviews', page([]));
    await _open(tester, env);

    await tester.tap(find.text('Dao Đặc Nhiệm 809'));
    await settle(tester, frames: 30);

    expect(find.byType(SkinReviewScreen), findsOneWidget);
    expect(
      env.server.calls('GET /v1/skins/*/summary').single.path,
      '/v1/skins/$knifeSkin/summary',
    );
    await unmount(tester);
  });

  for (final light in [false, true]) {
    testWidgets('no overflow at 360 dp × 2.0 (${light ? 'light' : 'dark'})', (
      tester,
    ) async {
      env.server.json('GET /v1/skins/top', _rows);
      await _open(
        tester,
        env,
        size: const Size(360, 2400),
        textScale: 2,
        light: light,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Vandal Reaver'), findsOneWidget);
      await unmount(tester);
    });
  }
}
