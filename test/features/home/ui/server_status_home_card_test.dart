import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/ui/maintenance_banner.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/providers/home_refresh.dart';
import 'package:valvn/features/home/ui/cards/community_home_card.dart';
import 'package:valvn/features/home/ui/cards/server_status_home_card.dart';
import 'package:valvn/features/home/ui/cards/store_home_card.dart';

import '../home_test_env.dart';

Widget _card() => const ServerStatusHomeCard();

double _top(WidgetTester tester, Type type) =>
    tester.getTopLeft(find.byType(type)).dy;

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create();
  });

  testWidgets('maintenance in progress: title, message, "Chi tiết"', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStatus(homeServerStatus())],
    );
    expect(find.text(HomeStrings.statusMaintenanceNow('AP')), findsOneWidget);
    expect(find.text('Bảo trì để cập nhật phiên bản mới.'), findsOneWidget);
    expect(find.byIcon(Icons.construction_outlined), findsOneWidget);
    expect(find.text(HomeStrings.statusDetails), findsOneWidget);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('scheduled maintenance and incidents have their own title', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStatus(homeServerStatus(status: 'scheduled'))],
    );
    expect(
      find.text(HomeStrings.statusMaintenanceScheduled('AP')),
      findsOneWidget,
    );
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmStatus(homeServerStatus(kind: 'incident', status: 'warning')),
      ],
    );
    expect(find.text(HomeStrings.statusIncident('AP')), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('several regions: the others are counted', (tester) async {
    final status = homeServerStatus(
      other: {
        'eu': homeStatusPayload(kind: 'incident', status: 'warning'),
        'na': homeStatusPayload(kind: 'incident', status: 'info'),
      },
    );
    await pumpHomeCard(tester, env, _card(), overrides: [vmStatus(status)]);
    expect(find.text(HomeStrings.statusMore(2)), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('a tap opens the "Trạng thái máy chủ" page', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStatus(homeServerStatus())],
    );
    await tester.tap(find.text(HomeStrings.statusDetails));
    await homeSettle(tester);
    expect(find.text('route /settings/status'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('nothing to report: no card', (tester) async {
    await pumpHomeCard(tester, env, _card(), overrides: [vmStatus(null)]);
    expect(find.byType(ServerStatusHomeCard), findsOneWidget);
    expect(find.text(HomeStrings.statusDetails), findsNothing);
    await homeUnmount(tester);
  });

  group('on Home', () {
    testWidgets('a scheduled maintenance keeps the position the user gave it', (
      tester,
    ) async {
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmFull(status: homeServerStatus(status: 'scheduled')),
      );
      await homePastGate(tester);
      expect(
        _top(tester, ServerStatusHomeCard),
        greaterThan(_top(tester, CommunityHomeCard)),
      );
      await homeUnmount(tester);
    });

    testWidgets('an in-progress maintenance is pinned to the top', (
      tester,
    ) async {
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmFull(status: homeServerStatus()),
      );
      await homePastGate(tester);
      expect(
        _top(tester, ServerStatusHomeCard),
        lessThan(_top(tester, StoreHomeCard)),
      );
      // The card replaces the banner: no duplicate notice.
      expect(find.byType(MaintenanceBanner), findsNothing);
      await homeUnmount(tester);
    });

    testWidgets('an incident in another region does not pin the card', (
      tester,
    ) async {
      final status = homeServerStatus(
        kind: 'incident',
        status: 'info',
        other: {'eu': homeStatusPayload()},
      );
      await pumpHomeScreen(tester, env, overrides: vmFull(status: status));
      await homePastGate(tester);
      expect(
        _top(tester, ServerStatusHomeCard),
        greaterThan(_top(tester, StoreHomeCard)),
      );
      await homeUnmount(tester);
    });

    testWidgets('a user-hidden status card stays hidden even if blocking', (
      tester,
    ) async {
      final hiddenEnv = await HomeTestEnv.create(
        layout: {
          'v': 1,
          'order': [for (final c in HomeCardId.values) c.storageId],
          'hidden': ['status'],
        },
      );
      await pumpHomeScreen(
        tester,
        hiddenEnv,
        overrides: vmFull(status: homeServerStatus()),
      );
      await homePastGate(tester);
      expect(find.byType(ServerStatusHomeCard), findsNothing);
      await homeUnmount(tester);
    });
  });

  group('the 5 minute poller (real X-1 provider)', () {
    List<Override> onlyStatusReal() => [
      vmLive(null),
      vmStore(const AsyncData(null)),
      vmRank(const AsyncData(null)),
      vmBp(const AsyncData(null)),
      ...vmFriends(const AsyncData(null)),
      vmCommunity(const AsyncData(null)),
      vmOthers(null),
    ];

    testWidgets('refetches every five minutes while Home is visible', (
      tester,
    ) async {
      await pumpHomeScreen(tester, env, overrides: onlyStatusReal());
      verify(() => env.api.platformStatus('ap')).called(1);

      await tester.pump(kHomeStatusRefresh);
      await homeSettle(tester);
      verify(() => env.api.platformStatus('ap')).called(1);
      await homeUnmount(tester);
    });

    testWidgets('coming back after five minutes refetches at once', (
      tester,
    ) async {
      await pumpHomeScreen(tester, env, overrides: onlyStatusReal());
      clearInteractions(env.api);

      env.foreground.foreground = false;
      await homeSettle(tester);
      env.clock.advance(const Duration(minutes: 6));
      env.foreground.foreground = true;
      await homeSettle(tester);
      verify(() => env.api.platformStatus('ap')).called(1);
      await homeUnmount(tester);
    });

    testWidgets('a short trip to the background does not refetch', (
      tester,
    ) async {
      await pumpHomeScreen(tester, env, overrides: onlyStatusReal());
      clearInteractions(env.api);

      env.foreground.foreground = false;
      await homeSettle(tester);
      env.clock.advance(const Duration(minutes: 1));
      env.foreground.foreground = true;
      await homeSettle(tester);
      verifyNever(() => env.api.platformStatus(any()));
      await homeUnmount(tester);
    });
  });
}
