import '../../../helpers/l10n.dart';

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_layout.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/providers/home_layout_provider.dart';
import 'package:valvn/features/home/ui/cards/friends_home_card.dart';
import 'package:valvn/features/home/ui/cards/rank_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';

import '../home_test_env.dart';

Future<ProviderContainer> _openSheet(
  WidgetTester tester,
  HomeTestEnv env, {
  List<Override>? overrides,
}) async {
  await pumpHomeScreen(tester, env, overrides: overrides ?? vmFull());
  await homePastGate(tester);
  // The button sits at the end of the page.
  await tester.ensureVisible(find.text(HomeStrings.customize));
  await homeSettle(tester);
  await tester.tap(find.text(HomeStrings.customize));
  await homeSettle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
}

Finder _row(HomeCardId id) => find.byKey(ValueKey(id));

void main() {
  testWidgets('lists every card, also those without data', (tester) async {
    final env = await HomeTestEnv.create();
    await _openSheet(tester, env, overrides: vmEmpty());
    // Nothing shows on Home, yet all eight cards can be arranged.
    expect(find.text(HomeStrings.customizeHint), findsOneWidget);
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    expect(list.itemCount, HomeCardId.values.length);
    // The first rows are on screen (the list is lazy); the rest scrolls.
    for (final id in HomeCardId.values.take(4)) {
      expect(_row(id), findsOneWidget, reason: id.name);
      expect(find.text(id.title(tl)), findsWidgets);
    }
    await tester.ensureVisible(find.text(HomeStrings.resetLayout));
    await homeSettle(tester);
    expect(_row(HomeCardId.serverStatus), findsOneWidget);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('a switch hides and shows a card, and it is saved', (
    tester,
  ) async {
    final env = await HomeTestEnv.create();
    final container = await _openSheet(tester, env);
    expect(find.byType(RankHomeCard), findsOneWidget);

    final rankSwitch = find.descendant(
      of: _row(HomeCardId.rank),
      matching: find.byType(Switch),
    );
    await tester.tap(rankSwitch);
    await homeSettle(tester);
    expect(
      container.read(homeLayoutProvider).isHidden(HomeCardId.rank),
      isTrue,
    );
    expect(find.byType(RankHomeCard), findsNothing);
    // Persisted in Prefs under f.home.layout.
    expect(
      HomeLayout.fromJson(env.prefs.getJson(kHomeLayoutPrefKey))
          .isHidden(HomeCardId.rank),
      isTrue,
    );

    await tester.tap(rankSwitch);
    await homeSettle(tester);
    expect(
      container.read(homeLayoutProvider).isHidden(HomeCardId.rank),
      isFalse,
    );
    expect(find.byType(RankHomeCard), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('dragging a handle reorders the cards', (tester) async {
    final env = await HomeTestEnv.create();
    final container = await _openSheet(tester, env);
    final before = container.read(homeLayoutProvider).order;
    expect(before.first, HomeCardId.live);

    final handle = find.descendant(
      of: _row(HomeCardId.rank),
      matching: find.byIcon(Icons.drag_indicator_rounded),
    );
    await tester.drag(handle, const Offset(0, -150));
    await homeSettle(tester);

    final after = container.read(homeLayoutProvider).order;
    expect(
      after.indexOf(HomeCardId.rank),
      lessThan(before.indexOf(HomeCardId.rank)),
    );
    expect(
      HomeLayout.fromJson(env.prefs.getJson(kHomeLayoutPrefKey)).order,
      after,
    );
    await homeUnmount(tester);
  });

  testWidgets('screen readers can move a card without dragging', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final env = await HomeTestEnv.create();
    final container = await _openSheet(tester, env);

    final node = tester.getSemantics(_row(HomeCardId.rank));
    final data = node.getSemanticsData();
    final labels = {
      for (final id in data.customSemanticsActionIds ?? const <int>[])
        id: CustomSemanticsAction.getAction(id)!.label,
    };
    // Material's reorder actions (localized): move up / down / start / end.
    expect(labels.values, hasLength(greaterThanOrEqualTo(2)));

    final up = labels.entries
        .firstWhere(
          (e) =>
              e.value ==
              WidgetsLocalizations.of(tester.element(_row(HomeCardId.rank)))
                  .reorderItemUp,
        )
        .key;
    final before = container
        .read(homeLayoutProvider)
        .order
        .indexOf(HomeCardId.rank);
    tester
        .renderObject(_row(HomeCardId.rank))
        .owner!
        .semanticsOwner!
        .performAction(node.id, SemanticsAction.customAction, up);
    await homeSettle(tester);
    expect(
      container.read(homeLayoutProvider).order.indexOf(HomeCardId.rank),
      before - 1,
    );
    handle.dispose();
    await homeUnmount(tester);
  });

  testWidgets('"Khôi phục mặc định" restores the IA order', (tester) async {
    final env = await HomeTestEnv.create(
      layout: {
        'v': 1,
        'order': [
          'status',
          'accounts',
          'community',
          'friends',
          'battlepass',
          'rank',
          'store',
          'live',
        ],
        'hidden': ['rank', 'store'],
      },
    );
    final container = await _openSheet(tester, env);
    expect(
      container.read(homeLayoutProvider).order.first,
      HomeCardId.serverStatus,
    );

    await tester.ensureVisible(find.text(HomeStrings.resetLayout));
    await homeSettle(tester);
    await tester.tap(find.text(HomeStrings.resetLayout));
    await homeSettle(tester);
    expect(container.read(homeLayoutProvider), HomeLayout.defaults);
    await homeUnmount(tester);
  });

  testWidgets('the layout is restored from Prefs on the next launch', (
    tester,
  ) async {
    final env = await HomeTestEnv.create();
    final container = await _openSheet(tester, env);
    await container
        .read(homeLayoutProvider.notifier)
        .setHidden(HomeCardId.community, hidden: true);
    await container.read(homeLayoutProvider.notifier).move(0, 8);
    await homeUnmount(tester);

    // A new app run over the same prefs.
    await pumpHomeScreen(tester, env, overrides: vmFull());
    await homePastGate(tester);
    final again = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final layout = again.read(homeLayoutProvider);
    expect(layout.isHidden(HomeCardId.community), isTrue);
    expect(layout.order.last, HomeCardId.live);
    await homeUnmount(tester);
  });

  group('friends switch asks for consent first', () {
    testWidgets('confirmed: consent saved and the card shown', (tester) async {
      final env = await HomeTestEnv.create(
        layout: {
          'v': 1,
          'order': [for (final c in HomeCardId.values) c.storageId],
          'hidden': ['friends'],
        },
      );
      final container = await _openSheet(tester, env, overrides: vmFull());
      expect(find.byType(FriendsHomeCard), findsNothing);

      await tester.tap(
        find.descendant(
          of: _row(HomeCardId.friends),
          matching: find.byType(Switch),
        ),
      );
      await homeSettle(tester);
      // The consent text, before anything is switched on.
      expect(find.text(HomeStrings.friendsConsentTitle), findsWidgets);
      expect(find.text(HomeStrings.friendsConsentBody), findsWidgets);
      expect(container.read(homeFriendsConsentProvider), isNull);

      await tester.tap(find.text(HomeStrings.friendsConsentAllow).last);
      await homeSettle(tester);
      expect(container.read(homeFriendsConsentProvider), isTrue);
      expect(
        env.prefs.getBool(PrefKeys.account(homeMe.puuid, 'home.friendsLive')),
        isTrue,
      );
      expect(
        container.read(homeLayoutProvider).isHidden(HomeCardId.friends),
        isFalse,
      );
      await homeUnmount(tester);
    });

    testWidgets('cancelled: the card stays off', (tester) async {
      final env = await HomeTestEnv.create(
        layout: {
          'v': 1,
          'order': [for (final c in HomeCardId.values) c.storageId],
          'hidden': ['friends'],
        },
      );
      final container = await _openSheet(tester, env, overrides: vmFull());
      await tester.tap(
        find.descendant(
          of: _row(HomeCardId.friends),
          matching: find.byType(Switch),
        ),
      );
      await homeSettle(tester);
      await tester.tap(find.text('Hủy'));
      await homeSettle(tester);
      expect(container.read(homeFriendsConsentProvider), isNull);
      expect(
        container.read(homeLayoutProvider).isHidden(HomeCardId.friends),
        isTrue,
      );
      await homeUnmount(tester);
    });

    testWidgets('turning it off keeps the consent', (tester) async {
      final env = await HomeTestEnv.create(friendsConsent: true);
      final container = await _openSheet(tester, env, overrides: vmFull());
      await tester.tap(
        find.descendant(
          of: _row(HomeCardId.friends),
          matching: find.byType(Switch),
        ),
      );
      await homeSettle(tester);
      expect(
        container.read(homeLayoutProvider).isHidden(HomeCardId.friends),
        isTrue,
      );
      expect(container.read(homeFriendsConsentProvider), isTrue);
      await homeUnmount(tester);
    });
  });

  testWidgets('the ⋯ menu of a card hides it with an undo', (tester) async {
    final env = await HomeTestEnv.create();
    await pumpHomeScreen(tester, env, overrides: vmFull());
    await homePastGate(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );

    await tester.tap(
      find.byTooltip(HomeStrings.moreActions(HomeCardId.rank.title(tl))),
    );
    await homeSettle(tester);
    expect(find.text(HomeStrings.hideCard), findsOneWidget);
    expect(find.text('${HomeStrings.customize}…'), findsOneWidget);

    await tester.tap(find.text(HomeStrings.hideCard));
    await homeSettle(tester);
    expect(
      container.read(homeLayoutProvider).isHidden(HomeCardId.rank),
      isTrue,
    );
    expect(find.byType(RankHomeCard), findsNothing);
    expect(
      find.text(HomeStrings.cardHidden(HomeCardId.rank.title(tl))),
      findsOneWidget,
    );

    await tester.tap(find.text(HomeStrings.undo));
    await homeSettle(tester);
    expect(
      container.read(homeLayoutProvider).isHidden(HomeCardId.rank),
      isFalse,
    );
    expect(find.byType(RankHomeCard), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('the ⋯ menu also opens the customize sheet', (tester) async {
    final env = await HomeTestEnv.create();
    await pumpHomeScreen(tester, env, overrides: vmFull());
    await homePastGate(tester);
    await tester.tap(
      find.byTooltip(HomeStrings.moreActions(HomeCardId.store.title(tl))),
    );
    await homeSettle(tester);
    await tester.tap(find.text('${HomeStrings.customize}…'));
    await homeSettle(tester);
    expect(find.text(HomeStrings.resetLayout), findsOneWidget);
    await homeUnmount(tester);
  });
}
