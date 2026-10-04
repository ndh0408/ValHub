import 'package:valvn/core/l10n/l10n.dart';
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
import '../../../helpers/l10n.dart';
import '../data/skin_review_test.dart' show summaryJson;

Future<void> _open(
  WidgetTester tester,
  CommunityTestEnv env, {
  Size size = const Size(360, 1600),
  double textScale = 1,
  bool light = false,
  bool rtl = false,
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
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: light ? buildLightTheme() : buildDarkTheme(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        ),
      ),
    ),
  );
  await settle(tester);
}

Future<void> _options(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('skins-filter-selector')));
  await settle(tester);
}

Future<void> _apply(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('skins-apply-filters'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await settle(tester);
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

    expect(find.textContaining(CommunityStrings.periodAllTime), findsOneWidget);
    final q = env.server.calls('GET /v1/skins/top').single.query;
    expect((q['period'], q['sort']), ('all', 'votes'));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey(reaverSkin)),
        matching: find.text('Vandal Reaver'),
      ),
      findsOneWidget,
    );
    expect(find.text('4,6'), findsOneWidget);
    expect(find.text(CommunityStrings.ratingCount('128')), findsOneWidget);
    expect(find.text(CommunityStrings.noRatings), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('confirmed sort, period and weapon refetch and are remembered', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/top', {'items': <Object>[]});
    await _open(tester, env);

    await _options(tester);
    await tester.tap(find.byKey(const ValueKey('skins-sort-rating')));
    await _apply(tester);
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['sort'], 'rating');
    await _options(tester);
    await tester.tap(find.byKey(const ValueKey('skins-sort-reviews')));
    await _apply(tester);
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['sort'], 'reviews');
    expect(env.server.calls('GET /v1/skins/top').last.query['period'], 'all');
    expect(find.byKey(const ValueKey('skins-period-week')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('skins-weapon-selector')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('weapon-$vandal')));
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').last.query['weapon'], vandal);
    expect(find.text(tl.communityRankingEmptyTitle), findsOneWidget);
    expect(find.text(tl.communityRankingEmptyReviews), findsOneWidget);

    expect(env.prefs.getString(PrefKeys.ui('community.skins.sort')), 'reviews');
    expect(env.prefs.getString(PrefKeys.ui('community.skins.period')), 'all');
    expect(env.prefs.getString(PrefKeys.ui('community.skins.weapon')), vandal);
    await unmount(tester);
  });

  testWidgets('dismissed filter draft makes no request or preference change', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/top', {'items': <Object>[]});
    await _open(tester, env);
    final count = env.server.calls('GET /v1/skins/top').length;
    await _options(tester);
    await tester.tap(find.byKey(const ValueKey('skins-sort-rating')));
    expect(find.byKey(const ValueKey('skins-period-week')), findsNothing);
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').length, count);
    Navigator.of(
      tester.element(find.byKey(const ValueKey('skins-apply-filters'))),
    ).pop();
    await settle(tester);
    expect(env.server.calls('GET /v1/skins/top').length, count);
    expect(env.prefs.getString(PrefKeys.ui('community.skins.sort')), isNull);
    expect(env.prefs.getString(PrefKeys.ui('community.skins.period')), isNull);
    expect(find.text(tl.communityRankingEmptyVotes), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('empty reset widens weapon/time but retains sort and scope', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/top', {'items': <Object>[]});
    await env.prefs.setString(PrefKeys.ui('community.skins.weapon'), vandal);
    await env.prefs.setString(PrefKeys.ui('community.skins.period'), 'week');
    await env.prefs.setString(PrefKeys.ui('community.skins.sort'), 'rating');
    await _open(tester, env);
    final before = env.server.calls('GET /v1/skins/top').last.query;
    expect(find.text(tl.communityRankingEmptyRatings), findsOneWidget);
    expect(find.text(CommunityStrings.skinsEmptyBody), findsNothing);
    await tester.tap(find.byKey(const ValueKey('skins-clear-filters')));
    await settle(tester);
    final after = env.server.calls('GET /v1/skins/top').last.query;
    expect(after['weapon'], isNull);
    expect(after['period'], 'all');
    expect(after['sort'], 'rating');
    expect(after['scope'], before['scope']);
    expect(after['region'], before['region']);
    expect(after['country'], before['country']);
    expect(find.byKey(const ValueKey('skins-clear-filters')), findsNothing);
    await unmount(tester);
  });

  testWidgets('catalog search finds accents and opens reviews without voting', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/skins/top', {'items': <Object>[]})
      ..json('GET /v1/skins/*/summary', summaryJson())
      ..json('GET /v1/skins/*/reviews', page([]));
    await _open(tester, env);
    await tester.tap(find.byKey(const ValueKey('skins-explore')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('skins-catalog-search')),
      'dao dac nhiem',
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('catalog-$knifeSkin')), findsOneWidget);
    expect(find.byKey(const ValueKey('catalog-$reaverSkin')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('catalog-$knifeSkin')));
    await settle(tester, frames: 30);
    expect(find.byType(SkinReviewScreen), findsOneWidget);
    expect(
      env.server.calls('GET /v1/skins/*/summary').single.path,
      '/v1/skins/$knifeSkin/summary',
    );
    expect(env.server.calls('POST /v1/skins/*/vote'), isEmpty);
    await unmount(tester);
  });

  testWidgets(
    'anonymous discovery keeps read-only access and an explicit consent action',
    (tester) async {
      env = await CommunityTestEnv.create(consent: false);
      env.server
        ..json('GET /v1/skins/top', {'items': <Object>[]})
        ..json('GET /v1/skins/*/summary', summaryJson())
        ..json('GET /v1/skins/*/reviews', page([]));
      await _open(tester, env);
      expect(find.byKey(const ValueKey('consent-gate-action')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('skins-explore')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('skins-catalog-search')),
        'reaver',
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('catalog-$reaverSkin')));
      await settle(tester, frames: 30);
      expect(find.byType(SkinReviewScreen), findsOneWidget);
      expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
      expect(env.server.calls('POST /v1/skins/*/vote'), isEmpty);
      await unmount(tester);
    },
  );

  testWidgets('catalog may widen weapon locally without changing leaderboard', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/top', {'items': <Object>[]});
    await env.prefs.setString(PrefKeys.ui('community.skins.weapon'), vandal);
    await _open(tester, env);
    final count = env.server.calls('GET /v1/skins/top').length;
    await tester.tap(find.byKey(const ValueKey('skins-explore')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('skins-catalog-search')),
      'dao dac nhiem',
    );
    await settle(tester);
    expect(find.text(tl.communityRankingNoSearch), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skins-catalog-all-weapons')));
    await settle(tester);
    expect(find.byKey(const ValueKey('catalog-$knifeSkin')), findsOneWidget);
    expect(env.server.calls('GET /v1/skins/top').length, count);
    expect(env.prefs.getString(PrefKeys.ui('community.skins.weapon')), vandal);
    await unmount(tester);
  });

  testWidgets('tapping a skin opens its review page', (tester) async {
    env.server
      ..json('GET /v1/skins/top', _rows)
      ..json('GET /v1/skins/*/summary', summaryJson())
      ..json('GET /v1/skins/*/reviews', page([]));
    await _open(tester, env);

    await tester.tap(find.byKey(const ValueKey(knifeSkin)));
    await settle(tester, frames: 30);

    expect(find.byType(SkinReviewScreen), findsOneWidget);
    expect(
      env.server.calls('GET /v1/skins/*/summary').single.path,
      '/v1/skins/$knifeSkin/summary',
    );
    await unmount(tester);
  });

  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('ranking pickers at $width dp, text $scale, RTL/light', (
        tester,
      ) async {
        env.server.json('GET /v1/skins/top', {'items': <Object>[]});
        await _open(
          tester,
          env,
          size: Size(width, 1000),
          textScale: scale,
          light: true,
          rtl: true,
        );
        expect(tester.takeException(), isNull);
        final options = find.byKey(const ValueKey('skins-filter-selector'));
        await tester.ensureVisible(options);
        expect(tester.getSize(options).height, greaterThanOrEqualTo(48));
        await _options(tester);
        await tester.ensureVisible(
          find.byKey(const ValueKey('skins-sort-rating')),
        );
        await tester.tap(find.byKey(const ValueKey('skins-sort-rating')));
        await _apply(tester);
        expect(
          env.server.calls('GET /v1/skins/top').last.query['sort'],
          'rating',
        );
        final explore = find.byKey(const ValueKey('skins-explore'));
        await tester.ensureVisible(explore);
        await tester.tap(explore);
        await settle(tester);
        await tester.enterText(
          find.byKey(const ValueKey('skins-catalog-search')),
          'reaver',
        );
        await settle(tester);
        expect(
          find.byKey(const ValueKey('catalog-$reaverSkin')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await unmount(tester);
      });
    }
  }

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
      expect(
        find.descendant(
          of: find.byKey(const ValueKey(reaverSkin)),
          matching: find.text('Vandal Reaver'),
        ),
        findsOneWidget,
      );
      await unmount(tester);
    });
  }
}
