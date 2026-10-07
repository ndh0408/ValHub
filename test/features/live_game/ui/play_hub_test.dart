import '../../../helpers/l10n.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/live_game/current_game_card.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';
import 'package:valvn/features/live_game/live_game_sheet.dart';
import 'package:valvn/features/live_game/providers/live_game_providers.dart';
import 'package:valvn/features/live_game/ui/live_ended_view.dart';
import 'package:valvn/features/social/ui/party_screen.dart';
import 'package:valvn/features/social/providers/party_providers.dart';

import '../live_game_test_env.dart';

void main() {
  setUpAll(registerLiveFallbacks);
  late LiveTestEnv env;
  setUp(() async => env = await LiveTestEnv.create());

  test(
    'polling lease closes safely after the app provider scope is disposed',
    () {
      final container = ProviderContainer();
      final open = container.read(liveGameSheetOpenProvider.notifier);
      open.open();
      expect(container.read(liveGameSheetOpenProvider), 1);
      container.dispose();
      expect(open.close, returnsNormally);
    },
  );

  const hub = PartyScreen(includeCurrentGame: true);

  Future<void> pumpHub(
    WidgetTester tester, {
    double width = 360,
    double scale = 1,
    bool rtl = false,
  }) async {
    await pumpLive(
      tester,
      env,
      Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: hub,
      ),
      width: width,
      height: 1400,
      textScale: scale,
    );
    await settle(tester);
  }

  testWidgets(
    'idle status stays informational while party controls are available',
    (tester) async {
      env
        ..loop = 'MENUS'
        ..party = partyJson(matchmaking: false);
      await pumpHub(tester);
      expect(find.text('Trận đấu & tổ đội'), findsOneWidget);
      expect(find.text('Đang ở sảnh chờ'), findsOneWidget);
      expect(find.textContaining('THÀNH VIÊN'), findsOneWidget);
      await tester.tap(find.byType(CurrentGameCard));
      await settle(tester);
      expect(find.byType(LiveGameSheet), findsNothing);
      verifyNever(() => env.api.partyJoinMatchmaking(any(), any()));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'party 404 preserves the verified lobby and offers a real retry',
    (tester) async {
      env
        ..loop = 'MENUS'
        ..party = null;
      await pumpHub(tester);
      expect(find.text('Đang ở sảnh chờ'), findsOneWidget);
      expect(
        find.text(tl.socialPartyUnavailable),
        findsOneWidget,
      );
      expect(
        find.text('Mở VALORANT trên máy tính hoặc máy chơi game'),
        findsNothing,
      );
      expect(find.text('Bắt đầu tìm trận'), findsNothing);
      expect(find.text('Sẵn sàng'), findsNothing);
      clearInteractions(env.api);
      await tester.tap(find.text('Thử lại'));
      await settle(tester);
      verify(() => env.api.partyPlayer(me)).called(1);
      verifyNever(() => env.api.partyJoinMatchmaking(any(), any()));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final phase in ['PREGAME', 'INGAME']) {
    testWidgets('$phase prioritises match details when party is unavailable', (
      tester,
    ) async {
      env
        ..loop = phase
        ..pregame = pregameMatchJson()
        ..core = coreMatchJson();
      when(() => env.api.partyPlayer(any()))
          .thenThrow(const TransientException(reason: 'network'));
      await pumpHub(tester);
      expect(find.byType(CurrentGameCard), findsNothing);
      expect(find.byType(LiveGameSheet), findsOneWidget);
      expect(find.text('Bắt đầu tìm trận'), findsNothing);
      expect(find.textContaining('Hủy tìm trận'), findsNothing);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PartyScreen)),
      );
      expect(container.read(liveGameSheetOpenProvider), 1);
      if (phase == 'INGAME') {
        expect(find.text('Đội địch'), findsOneWidget);
        expect(find.text(tl.liveGameLiveStatsUnavailable), findsWidgets);
      } else {
        // Agent select is information only (no pick grid).
        expect(find.text(tl.liveGamePickInGame), findsOneWidget);
        expect(find.text('Đội địch'), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'party utilities remain optional under the live-page menu without queue controls',
    (tester) async {
      env
        ..loop = 'INGAME'
        ..core = coreMatchJson()
        ..party = partyJson(matchmaking: false);
      await pumpHub(tester);
      await tester.tap(find.byType(PopupMenuButton<int>));
      await settle(tester);
      await tester.tap(find.text('Tổ đội & hàng chờ'));
      await settle(tester, frames: 16);
      expect(find.byType(PartyScreen, skipOffstage: false), findsNWidgets(2));
      expect(
        tester.widget<PartyScreen>(find.byType(PartyScreen)).includeCurrentGame,
        isFalse,
      );
      expect(find.textContaining('THÀNH VIÊN'), findsOneWidget);
      expect(find.text('Bắt đầu tìm trận'), findsNothing);
      expect(find.text('Sẵn sàng'), findsNothing);
      verifyNever(() => env.api.partyJoinMatchmaking(any(), any()));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('offline status and party retry remain available', (
    tester,
  ) async {
    env.sessionError = const TransientException(reason: 'network');
    when(() => env.api.partyPlayer(any()))
        .thenThrow(const TransientException(reason: 'network'));
    await pumpHub(tester);
    expect(find.text('Chưa cập nhật được trạng thái trận'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'switching account ignores a late previous-account match response',
    (tester) async {
      final second = Account.fromJson({...myAccount.toJson(), 'puuid': mate})!;
      await env.prefs.setJson(PrefKeys.accounts, [
        myAccount.toJson(),
        second.toJson(),
      ]);
      final pending = Completer<JsonMap>();
      env.core = coreMatchJson();
      when(() => env.api.gameSession(me)).thenAnswer((_) => pending.future);
      when(() => env.api.gameSession(mate))
          .thenAnswer((_) async => throw const NotFoundException());
      await pumpHub(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PartyScreen)),
      );
      container.read(activePuuidProvider.notifier).select(mate);
      await settle(tester);
      pending.complete({'loopState': 'INGAME'});
      await settle(tester);
      expect(find.text('Không trong trận'), findsOneWidget);
      expect(find.textContaining('Đang đấu'), findsNothing);
      // Live detection and the missing-party confirmation each read the new account.
      verify(() => env.api.gameSession(mate)).called(2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'lobby to agent select, in-game, final result and new queue adapts without navigation',
    (tester) async {
      env
        ..loop = 'MENUS'
        ..party = partyJson(matchmaking: false);
      await pumpHub(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PartyScreen)),
      );
      expect(find.textContaining('THÀNH VIÊN'), findsOneWidget);
      env
        ..loop = 'PREGAME'
        ..pregame = pregameMatchJson();
      await container.read(liveGameProvider(me).notifier).refresh();
      await settle(tester);
      expect(find.byType(LiveGamePage), findsOneWidget);
      expect(find.text(tl.liveGamePickInGame), findsOneWidget);
      expect(container.read(liveGameSheetOpenProvider), 1);
      env
        ..loop = 'INGAME'
        ..core = coreMatchJson();
      await container.read(liveGameProvider(me).notifier).refresh();
      await settle(tester);
      expect(find.text('Đội địch'), findsOneWidget);
      expect(find.textContaining('THÀNH VIÊN'), findsNothing);
      env.loop = 'MENUS';
      await container.read(liveGameProvider(me).notifier).refresh();
      await settle(tester);
      // Back in the lobby the party comes first again, with the match just
      // played as one row on top (it opens the match details).
      expect(find.byType(LiveEndedView), findsNothing);
      expect(find.textContaining('THÀNH VIÊN'), findsOneWidget);
      expect(find.text(tl.liveGameLastMatchTitle), findsOneWidget);
      // Starting another queue takes priority over a retained previous result.
      env.party = partyJson();
      await container.read(liveGameProvider(me).notifier).refresh();
      await settle(tester);
      expect(find.byType(LiveGamePage), findsNothing);
      expect(find.text('Đang tìm trận · 01:32'), findsWidgets);
      expect(container.read(liveGameSheetOpenProvider), 0);
      env.party = {...partyJson(), 'State': 'MATCHMADE_GAME_STARTING'};
      await container.read(partyProvider(me).notifier).refresh();
      await container.read(liveGameProvider(me).notifier).refresh();
      await settle(tester);
      expect(find.byType(LiveGamePage), findsNothing);
      expect(find.byType(LiveEndedView), findsNothing);
      expect(find.text('Đã tìm thấy trận!'), findsWidgets);
      expect(find.text('Bắt đầu tìm trận'), findsNothing);
      expect(find.text('Sẵn sàng'), findsNothing);
      expect(
        container.read(liveGameProvider(me)).requireValue.phase,
        LivePhase.queueing,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    testWidgets('active-match page fits $width dp at 200% in RTL', (
      tester,
    ) async {
      env
        ..loop = 'INGAME'
        ..core = coreMatchJson();
      await pumpHub(tester, width: width, scale: 2, rtl: true);
      expect(find.text('Đội địch'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    testWidgets('combined hub fits $width dp at 200% in RTL', (tester) async {
      env
        ..loop = 'MENUS'
        ..party = partyJson();
      await pumpHub(tester, width: width, scale: 2, rtl: true);
      expect(find.text('Đang tìm trận · 01:32'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
