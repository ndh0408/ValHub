import '../../../helpers/l10n.dart';

import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_live.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/ui/cards/battlepass_home_card.dart';
import 'package:valvn/features/home/ui/cards/community_home_card.dart';
import 'package:valvn/features/home/ui/cards/friends_home_card.dart';
import 'package:valvn/features/home/ui/cards/live_home_card.dart';
import 'package:valvn/features/home/ui/cards/other_accounts_home_card.dart';
import 'package:valvn/features/home/ui/cards/rank_home_card.dart';
import 'package:valvn/features/home/ui/cards/server_status_home_card.dart';
import 'package:valvn/features/home/ui/cards/store_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';
import 'package:valvn/features/home/ui/home_columns.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';

import '../home_test_env.dart';

const _live = HomeLiveSnapshot(
  phase: LivePhase.ingame,
  queueId: 'competitive',
  mapName: 'Ascent',
);

/// Every card at its busiest: a match, wishlist hits and an unseen Night
/// Market, rank with a streak, an event pass, friends, LFG and hot skins,
/// other accounts and a maintenance.
List<Override> _busy() => vmFull(
  live: _live,
  storeOverride: vmStore(
    AsyncData(
      homeStoreSummary(
        wishlist: {Fx.aresPrism, Fx.daoReaver, Fx.odinNeoFrontier},
      ),
    ),
  ),
  status: homeServerStatus(
    other: {
      'eu': homeStatusPayload(kind: 'incident', status: 'warning'),
      'na': homeStatusPayload(kind: 'incident', status: 'info'),
    },
  ),
);

Future<void> _pump(
  WidgetTester tester,
  HomeTestEnv env, {
  required Size size,
  double textScale = 1,
  ThemeData? theme,
  List<DisplayFeature> features = const [],
  TextDirection? direction,
  bool reduce = false,
  bool full = true,
}) async {
  await pumpHomeScreen(
    tester,
    env,
    overrides: full ? _busy() : vmEmpty(),
    size: size,
    textScale: textScale,
    theme: theme,
    displayFeatures: features,
    direction: direction,
    disableAnimations: reduce,
  );
  await homePastGate(tester);
}

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create(
      accounts: [homeMe, homeAlt1, homeAlt2.copyWith(needsLogin: true)],
    );
  });

  group('no overflow', () {
    Future<void> check(
      WidgetTester tester, {
      required Size size,
      double textScale = 1,
      ThemeData? theme,
      List<DisplayFeature> features = const [],
      TextDirection? direction,
    }) async {
      await _pump(
        tester,
        env,
        size: size,
        textScale: textScale,
        theme: theme,
        features: features,
        direction: direction,
      );
      homeExpectNoException(tester);
      // Scroll to the end so nothing below the fold is skipped.
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, Offset(0, -size.height * 3));
      await homeSettle(tester);
      homeExpectNoException(tester);
      await homeUnmount(tester);
    }

    testWidgets('320 x 640 at 200 % text, dark', (tester) async {
      await check(tester, size: const Size(320, 640), textScale: 2);
    });

    testWidgets('320 x 640 at 200 % text, light', (tester) async {
      await check(
        tester,
        size: const Size(320, 640),
        textScale: 2,
        theme: buildLightTheme(),
      );
    });

    testWidgets('360 x 740, dark and light', (tester) async {
      await check(tester, size: const Size(360, 740));
      await check(tester, size: const Size(360, 740), theme: buildLightTheme());
    });

    testWidgets('360 x 740 at 200 % text, dark and light', (tester) async {
      await check(tester, size: const Size(360, 740), textScale: 2);
      await check(
        tester,
        size: const Size(360, 740),
        textScale: 2,
        theme: buildLightTheme(),
      );
    });

    testWidgets('landscape phone 740 x 360', (tester) async {
      await check(tester, size: const Size(740, 360));
    });

    testWidgets('tablet 800 x 1280 (two columns)', (tester) async {
      await check(tester, size: const Size(800, 1280));
    });

    testWidgets('tablet 1024 x 768 (two columns)', (tester) async {
      await check(tester, size: const Size(1024, 768));
    });

    testWidgets('desktop 1366 x 1024 (three columns)', (tester) async {
      await check(tester, size: const Size(1366, 1024));
    });

    testWidgets('wide screens at large text stay readable', (tester) async {
      await check(tester, size: const Size(1024, 768), textScale: 2);
    });

    testWidgets('a foldable with a vertical hinge', (tester) async {
      await check(
        tester,
        size: const Size(1200, 800),
        features: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(590, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );
    });

    testWidgets('right-to-left languages', (tester) async {
      await check(
        tester,
        size: const Size(360, 740),
        direction: TextDirection.rtl,
      );
    });
  });

  group('columns', () {
    test('by width and text size', () {
      int n(double w, [double scale = 1]) =>
          homeColumnCount(contentWidth: w, textScale: scale);
      expect(n(328), 1);
      expect(n(567), 1);
      // >= 568 dp allows two columns, but each keeps 300 dp: from 600 dp.
      expect(n(599), 1);
      expect(n(600), 2);
      expect(n(999), 2);
      expect(n(1000), 3);
      expect(n(1280), 3);
      // Large text: each column keeps 300 × scale dp.
      expect(n(700, 2), 1);
      expect(n(1000, 2), 1);
      expect(n(1300, 2), 2);
      expect(n(1000, 1.3), 2);
    });

    testWidgets('a phone has one column, a tablet two, a desktop three', (
      tester,
    ) async {
      double left(HomeCardId id) =>
          tester.getTopLeft(find.byType(_type(id))).dx;
      await _pump(tester, env, size: const Size(360, 740));
      expect(left(HomeCardId.store), left(HomeCardId.rank));
      await homeUnmount(tester);

      await _pump(tester, env, size: const Size(1024, 768));
      expect(left(HomeCardId.store), isNot(left(HomeCardId.rank)));
      expect(left(HomeCardId.store), left(HomeCardId.battlePass));
      await homeUnmount(tester);

      await _pump(tester, env, size: const Size(1366, 1024));
      final xs = {
        left(HomeCardId.store),
        left(HomeCardId.rank),
        left(HomeCardId.battlePass),
      };
      expect(xs, hasLength(3));
      await homeUnmount(tester);
    });

    testWidgets('pinned cards span the full width above the columns', (
      tester,
    ) async {
      await _pump(tester, env, size: const Size(1024, 768));
      final live = tester.getRect(find.byType(LiveHomeCard));
      final store = tester.getRect(find.byType(StoreHomeCard));
      expect(live.width, greaterThan(store.width * 1.8));
      expect(live.bottom, lessThanOrEqualTo(store.top));
      await homeUnmount(tester);
    });

    testWidgets('content is centered and capped on very wide screens', (
      tester,
    ) async {
      await _pump(tester, env, size: const Size(1800, 900));
      final live = tester.getRect(find.byType(LiveHomeCard));
      expect(live.width, lessThanOrEqualTo(1280));
      expect(live.left, closeTo(1800 - live.right, 1));
      await homeUnmount(tester);
    });

    testWidgets('a hinge gives two panes, one column each', (tester) async {
      await _pump(
        tester,
        env,
        size: const Size(1400, 800),
        features: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(690, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );
      final store = tester.getRect(find.byType(StoreHomeCard));
      final rank = tester.getRect(find.byType(RankHomeCard));
      // Neither card crosses the hinge (x 690–710).
      for (final r in [store, rank]) {
        expect(r.left >= 710 || r.right <= 690, isTrue, reason: '$r');
      }
      expect(store.left, lessThan(690));
      expect(rank.left, greaterThan(700));
      await homeUnmount(tester);
    });
  });

  group('accessibility', () {
    testWidgets('screen-reader order follows the user order in columns', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, env, size: const Size(1024, 768));

      // Cards of the flow, in the user's order (the live match and the
      // blocking maintenance are pinned above the columns).
      const flow = [
        (StoreHomeCard, 0),
        (RankHomeCard, 1),
        (BattlePassHomeCard, 2),
        (FriendsHomeCard, 3),
        (CommunityHomeCard, 4),
        (OtherAccountsHomeCard, 5),
      ];
      for (final (type, index) in flow) {
        final wrapper = find
            .ancestor(
              of: find.byType(type),
              matching: find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.sortKey != null,
              ),
            )
            .first;
        final key = tester.getSemantics(wrapper).sortKey;
        expect(key, isA<OrdinalSortKey>(), reason: '$type');
        expect((key! as OrdinalSortKey).order, index.toDouble());
      }
      // Two columns place the cards 0,2,4... then 1,3,5...: the keys still
      // say 0,1,2,... (the user's order), whatever the visual columns are.
      final left = flow
          .map((f) => tester.getTopLeft(find.byType(f.$1)).dx)
          .toList();
      expect(left[0], isNot(left[1]));
      expect(left[0], left[2]);
      handle.dispose();
      await homeUnmount(tester);
    });

    testWidgets('cards are containers with a heading and labelled buttons', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, env, size: const Size(360, 780));
      for (final id in [
        HomeCardId.store,
        HomeCardId.rank,
        HomeCardId.battlePass,
      ]) {
        expect(
          find.bySemanticsLabel(RegExp(RegExp.escape(id.title(tl)))),
          findsWidgets,
          reason: id.name,
        );
      }
      // The ⋯ menu of each card names its card.
      expect(
        find.byTooltip(HomeStrings.moreActions(HomeCardId.store.title(tl))),
        findsOneWidget,
      );
      handle.dispose();
      await homeUnmount(tester);
    });

    testWidgets('touch targets are at least 48 dp (Android) and 44 pt (iOS)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, env, size: const Size(360, 780));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
      await homeUnmount(tester);
    });

    testWidgets('text contrast meets the guideline in both themes', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, env, size: const Size(360, 780));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await homeUnmount(tester);
      await _pump(
        tester,
        env,
        size: const Size(360, 780),
        theme: buildLightTheme(),
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
      await homeUnmount(tester);
    });

    testWidgets('signals never rely on colour alone', (tester) async {
      await _pump(tester, env, size: const Size(360, 780));
      // RR: the arrow and the sign; streak: flame and text; wishlist: heart
      // and text; live: the pill text; activity: the label.
      expect(find.byIcon(Icons.arrow_drop_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
      expect(find.text(HomeStrings.storeWishlistHits(3)), findsOneWidget);
      expect(find.text(HomeStrings.winStreak(2)), findsOneWidget);
      expect(find.text(HomeStrings.otherWishlistHit), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  group('reduced motion', () {
    testWidgets('skeletons are static and no focus pulse runs', (tester) async {
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmWith(
          store: const AsyncLoading(),
          rank: const AsyncLoading(),
          bp: const AsyncLoading(),
        ),
        disableAnimations: true,
        focus: HomeCardId.battlePass,
      );
      await homeSettle(tester);
      expect(find.byType(HomeCardSkeleton), findsNWidgets(3));
      // No shimmer controller is ticking: frames are only scheduled by
      // things that carry information (countdowns).
      expect(tester.binding.transientCallbackCount, 0);
      await homeUnmount(tester);
    });

    testWidgets('skeletons shimmer when motion is allowed', (tester) async {
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmWith(
          store: const AsyncLoading(),
          rank: const AsyncLoading(),
          bp: const AsyncLoading(),
        ),
      );
      await homeSettle(tester);
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await homeUnmount(tester);
    });
  });
}

Type _type(HomeCardId id) => switch (id) {
  HomeCardId.live => LiveHomeCard,
  HomeCardId.store => StoreHomeCard,
  HomeCardId.rank => RankHomeCard,
  HomeCardId.battlePass => BattlePassHomeCard,
  HomeCardId.friends => FriendsHomeCard,
  HomeCardId.community => CommunityHomeCard,
  HomeCardId.otherAccounts => OtherAccountsHomeCard,
  HomeCardId.serverStatus => ServerStatusHomeCard,
};
