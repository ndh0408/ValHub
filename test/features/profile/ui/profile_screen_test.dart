import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/core/ui/error_view.dart';
import 'package:valvn/core/ui/segmented_tabs.dart';
import 'package:valvn/features/live_game/current_game_card.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/ui/profile_screen.dart';
import 'package:valvn/features/profile/ui/widgets/match_card.dart';
import 'package:valvn/features/profile/ui/widgets/profile_widgets.dart';
import 'package:valvn/features/profile/ui/widgets/rr_trend_chart.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
    when(() => env.api.gameSession(any()))
        .thenAnswer((_) async => throw const NotFoundException());
  });

  const screen = ProfileScreen();

  List<RouteBase> routes() => [
    GoRoute(
      path: '/profile',
      builder: (_, _) => screen,
      routes: [
        GoRoute(path: 'rankup', builder: (_, _) => const Text('rankup-page')),
        GoRoute(
          path: 'daily-rr',
          builder: (_, _) => const Text('daily-rr-page'),
        ),
        GoRoute(
          path: 'match/:id',
          builder: (_, s) => Text('match-page ${s.pathParameters['id']}'),
        ),
        GoRoute(path: 'party', builder: (_, _) => const Text('party-page')),
        GoRoute(path: 'friends', builder: (_, _) => const Text('friends-page')),
      ],
    ),
  ];

  testWidgets('shows header, rank card, daily RR and match cards', (
    tester,
  ) async {
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);

    // Header: Riot ID, level and XP from P-9.
    expect(find.textContaining('Tôi'), findsWidgets);
    expect(find.text(ProfileStrings.level(222)), findsOneWidget);
    expect(
      find.text(ProfileStrings.xpProgress('184', '5.000')),
      findsOneWidget,
    );

    // Rank card: current Diamond 1 (tier 18, 6 RR) and a peak column.
    expect(find.text(ProfileStrings.currentRank.toUpperCase()), findsOneWidget);
    expect(find.text('6 RR'), findsOneWidget);
    expect(
      find.textContaining(ProfileStrings.peakRank.toUpperCase()),
      findsOneWidget,
    );
    expect(find.byType(RrTrendChart), findsOneWidget);

    // Today's net RR (+24 from the competitive fixture match).
    expect(find.text(ProfileStrings.dailyRrTitle), findsOneWidget);
    expect(find.text('+24 RR'), findsWidgets);

    // A single combined match/party entry, plus the friends row.
    expect(find.byType(CurrentGameCard), findsOneWidget);
    expect(find.text('TRẬN ĐẤU & TỔ ĐỘI'), findsOneWidget);
    expect(find.text(ProfileStrings.partyRow), findsNothing);
    expect(find.text(ProfileStrings.friendsRow), findsOneWidget);

    // Match history: filter chips and three resolved cards.
    expect(find.text(ProfileStrings.matchHistory), findsOneWidget);
    expect(find.byType(SegmentedTabs<String?>), findsOneWidget);
    expect(find.byType(MatchCard), findsNWidgets(3));
    expect(find.text(ProfileStrings.kda(3, 1, 0)), findsOneWidget);
    expect(find.text(ProfileStrings.score(2, 1)), findsWidgets);
    expect(find.text(CommonStrings.dash), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('queue chip refetches the history with that queue', (
    tester,
  ) async {
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);

    // The mode chip (match cards also show their mode).
    final chip = find.descendant(
      of: find.byType(SegmentedTabs<String?>),
      matching: find.text('Sinh Tử'),
    );
    await tester.ensureVisible(chip);
    await tester.tap(chip);
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

  testWidgets('history error shows "Thử lại" and recovers', (tester) async {
    var fail = true;
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async {
      if (fail) throw const TransientException(reason: 'network');
      return competitiveFixtureMap('match_history');
    });
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text(CommonStrings.errorNetwork), findsOneWidget);

    fail = false;
    await tester.ensureVisible(find.text(CommonStrings.retry));
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.byType(MatchCard), findsNWidgets(3));
  });

  testWidgets('empty history shows the empty state', (tester) async {
    env.historyByQueue[null] = {
      'Subject': me,
      'Total': 0,
      'History': <Object>[],
    };
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);
    expect(find.text(ProfileStrings.noMatches), findsOneWidget);
  });

  testWidgets('shows skeleton cards while the history loads', (tester) async {
    final pending = Completer<JsonMap>();
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) => pending.future);
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);
    expect(find.byType(MatchCard), findsNothing);
    expect(find.byType(MatchCardSkeleton), findsNWidgets(4));

    pending.complete(competitiveFixtureMap('match_history'));
    await settle(tester);
    expect(find.byType(MatchCard), findsNWidgets(3));
  });

  testWidgets('navigates to match detail, daily RR, rank-up and social', (
    tester,
  ) async {
    final router = await pumpProfileRouter(
      tester,
      env,
      routes: routes(),
      initialLocation: '/profile',
      height: 2600,
    );
    await settle(tester);

    await tester.tap(find.text(ProfileStrings.dailyRrTitle));
    await settle(tester);
    expect(find.text('daily-rr-page'), findsOneWidget);
    router.pop();
    await settle(tester, frames: 20);

    await tester.tap(find.text('TRẬN ĐẤU & TỔ ĐỘI'));
    await settle(tester);
    expect(find.text('party-page'), findsOneWidget);
    router.pop();
    await settle(tester, frames: 20);

    await tester.tap(find.byType(MatchCard).first);
    await settle(tester);
    expect(find.text('match-page $compMatch'), findsOneWidget);
  });

  testWidgets('map filter hides other maps and offers "Tải thêm"', (
    tester,
  ) async {
    // Endless history of Ascent matches, 3 per page.
    var pages = 0;
    String id(int i) =>
        'a${i.toString().padLeft(7, '0')}-0000-4000-8000-000000000000';
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((inv) async {
      pages++;
      final start = inv.namedArguments[#startIndex] as int;
      for (var i = start; i < start + 3; i++) {
        env.matches[id(i)] = competitiveMatchWithId(id(i));
      }
      return {
        'Subject': me,
        'Total': 1000,
        'History': [
          for (var i = start; i < start + 3; i++)
            {'MatchID': id(i), 'QueueID': 'competitive'},
        ],
      };
    });
    await pumpProfile(tester, env, screen, height: 900);
    await settle(tester);

    // The profile header (card art, rank, form) is taller than one screen.
    final mapChip = find.text(
      ProfileStrings.mapFilter(ProfileStrings.filterAll),
    );
    await tester.scrollUntilVisible(
      mapChip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.tap(mapChip);
    await settle(tester, frames: 12);
    expect(find.text(ProfileStrings.chooseMap), findsOneWidget);
    await tester.tap(find.text('District'));
    await settle(tester, frames: 12);

    // Every loaded match was on Ascent: nothing shown, no automatic paging.
    expect(find.text(ProfileStrings.mapFilter('District')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(ProfileStrings.noMatchesMap),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    expect(find.text(ProfileStrings.noMatchesMap), findsOneWidget);
    expect(find.text(ProfileStrings.kda(3, 1, 0)), findsNothing);
    final before = pages;
    await settle(tester);
    expect(pages, before);

    await tester.scrollUntilVisible(
      find.text(CommonStrings.loadMore),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(CommonStrings.loadMore));
    await settle(tester);
    expect(pages, before + 1);
    expect(find.text(ProfileStrings.kda(3, 1, 0)), findsNothing);
  });

  testWidgets('scrolling to the end loads the next page of 20', (tester) async {
    String id(int i) =>
        'c${i.toString().padLeft(7, '0')}-0000-4000-8000-000000000000';
    for (var i = 0; i < 25; i++) {
      env.matches[id(i)] = competitiveMatchWithId(id(i));
    }
    JsonMap page(int start, int count) => {
      'Subject': me,
      'Total': 25,
      'History': [
        for (var i = start; i < start + count; i++)
          {
            'MatchID': id(i),
            'GameStartTime': 1790568000000 - i * 3600000,
            'QueueID': 'competitive',
          },
      ],
    };
    when(
      () => env.api.matchHistory(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((inv) async {
      final start = inv.namedArguments[#startIndex] as int;
      return start == 0 ? page(0, 20) : page(20, 5);
    });
    await pumpProfile(tester, env, screen, height: 900);
    await settle(tester);

    await tester.scrollUntilVisible(
      find.byKey(ValueKey(id(19))),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await settle(tester);

    verify(
      () => env.api.matchHistory(
        any(),
        subject: me,
        startIndex: 20,
        endIndex: 40,
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
    await tester.scrollUntilVisible(
      find.text(ProfileStrings.endOfHistory),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(ValueKey(id(24))), findsOneWidget);
  });

  testWidgets('daily RR makes no "none today" claim when Riot did not answer', (
    tester,
  ) async {
    when(
      () => env.api.competitiveUpdates(
        any(),
        subject: any(named: 'subject'),
        startIndex: any(named: 'startIndex'),
        endIndex: any(named: 'endIndex'),
        queue: any(named: 'queue'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => throw const TransientException(reason: 'network'),
    );
    when(
      () => env.api.mmr(
        any(),
        subject: any(named: 'subject'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => throw const TransientException(reason: 'network'),
    );
    await pumpProfile(tester, env, screen, height: 2600);
    await settle(tester);

    expect(find.text(ProfileStrings.dailyRrTitle), findsOneWidget);
    expect(find.text(ProfileStrings.todayNone), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no account shows the signed-out message', (tester) async {
    env = await ProfileTestEnv.create(accounts: const []);
    await pumpProfile(tester, env, screen);
    await settle(tester);
    expect(find.text(CommonStrings.errorNoAccount), findsOneWidget);
  });
}
