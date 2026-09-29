import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/live_game/live_game_sheet.dart';
import 'package:valvn/features/live_game/player_loadout_sheet.dart';

import '../live_game_test_env.dart';

void main() {
  late LiveTestEnv env;

  setUpAll(registerLiveFallbacks);

  setUp(() async {
    env = await LiveTestEnv.create();
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    double width = 360,
    double height = 780,
    double textScale = 1,
  }) async {
    await pumpLive(
      tester,
      env,
      const LiveGameSheet(),
      width: width,
      height: height,
      textScale: textScale,
    );
    await settle(tester, frames: 10);
  }

  group('outside a match', () {
    testWidgets('not running', (tester) async {
      await pumpSheet(tester);
      expect(find.text('Chi tiết trận'), findsOneWidget);
      expect(find.text('Bạn không ở trong trận nào'), findsOneWidget);
      expect(find.text('Rời trận'), findsNothing);
    });

    testWidgets('queueing: timer and queue name', (tester) async {
      env
        ..loop = 'MENUS'
        ..party = partyJson();
      await pumpSheet(tester);
      expect(find.text('Đang tìm trận · 01:32'), findsOneWidget);
      expect(find.text('Thi đấu xếp hạng'), findsOneWidget);
    });

    testWidgets('error without data → "Thử lại" polls again', (tester) async {
      env.sessionError = const TransientException(status: 503);
      await pumpSheet(tester);
      expect(find.text('Thử lại'), findsOneWidget);
      env.sessionError = null;
      await tester.tap(find.text('Thử lại'));
      await settle(tester);
      expect(find.text('Bạn không ở trong trận nào'), findsOneWidget);
    });
  });

  group('agent select', () {
    setUp(() {
      env
        ..loop = 'PREGAME'
        ..pregame = pregameMatchJson()
        ..party = partyJson(matchmaking: false);
    });

    testWidgets('header, hint, timer and grid', (tester) async {
      await pumpSheet(tester);
      expect(find.text('Đang chọn đặc vụ'), findsOneWidget);
      expect(find.text('ASCENT'), findsOneWidget);
      expect(find.text('Thi đấu xếp hạng'), findsOneWidget);
      expect(find.text('Chạm để chọn, giữ để khóa đặc vụ.'), findsOneWidget);
      expect(find.text('Còn 0:42'), findsOneWidget);
      expect(find.text('Đội địch đã khóa 4/5'), findsOneWidget);
      for (final name in ['Jett', 'Omen', 'Raze', 'Reyna', 'Sage', 'Sova']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Rời trận'), findsOneWidget);
    });

    testWidgets('tap hovers (G-4), hold locks (G-5) with a toast', (
      tester,
    ) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Reyna'));
      await settle(tester);
      verify(() => env.api.pregameSelectAgent(me, pregameMatchId, reyna))
          .called(1);
      verifyNever(() => env.api.pregameLockAgent(any(), any(), any()));
      expect(find.text('Bạn đang chọn Reyna'), findsOneWidget);

      await tester.longPress(find.text('Reyna'));
      await settle(tester);
      verify(() => env.api.pregameLockAgent(me, pregameMatchId, reyna))
          .called(1);
      expect(find.text('Đã khóa Reyna'), findsOneWidget);
      expect(find.text('Bạn đã khóa Reyna'), findsOneWidget);
    });

    testWidgets('unowned and taken agents explain instead of calling Riot', (
      tester,
    ) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Omen'));
      await settle(tester);
      expect(find.text('Bạn chưa sở hữu đặc vụ này.'), findsOneWidget);
      await tester.longPress(find.text('Sova'));
      await tester.tap(find.text('Sova'));
      await settle(tester);
      expect(find.text('Đồng đội đã khóa đặc vụ này.'), findsOneWidget);
      verifyNever(() => env.api.pregameSelectAgent(any(), any(), any()));
      verifyNever(() => env.api.pregameLockAgent(any(), any(), any()));
    });

    testWidgets('a refused lock shows an error', (tester) async {
      when(() => env.api.pregameLockAgent(any(), any(), any()))
          .thenThrow(const RiotApiException(409));
      await pumpSheet(tester);
      await tester.longPress(find.text('Jett'));
      await settle(tester);
      expect(find.text('Không thể khóa đặc vụ này.'), findsOneWidget);
    });

    testWidgets('your team: names, "Ẩn danh", BẠN, party, levels', (
      tester,
    ) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Đội của bạn'));
      await settle(tester, frames: 12);
      expect(find.text('Tôi#VN1'), findsOneWidget);
      expect(find.text('Đồng Đội#VN1'), findsOneWidget);
      expect(find.text('Ẩn danh'), findsOneWidget);
      expect(find.text('Bí Mật#KIN'), findsNothing);
      expect(find.text('BẠN'), findsOneWidget);
      expect(find.text('Tổ đội'), findsNWidgets(2));
      expect(find.text('Cấp 200 · Chưa chọn đặc vụ'), findsOneWidget);
      expect(find.text('Cấp 87 · Sova'), findsOneWidget);
      // HideAccountLevel: no level for the incognito teammate.
      expect(find.text('Sage'), findsOneWidget);
      expect(find.text('Đã khóa'), findsOneWidget);
      expect(
        find.text('Đội địch sẽ hiện khi trận đấu bắt đầu.'),
        findsOneWidget,
      );
    });

    testWidgets('dodge asks first and uses G-6', (tester) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Rời trận'));
      await settle(tester);
      expect(find.text('Rời trận đấu?'), findsOneWidget);
      expect(find.textContaining('Né trận'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await settle(tester);
      verifyNever(() => env.api.pregameQuit(any(), any()));

      await tester.tap(find.text('Rời trận'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Rời trận'));
      await settle(tester);
      verify(() => env.api.pregameQuit(me, pregameMatchId)).called(1);
      expect(find.text('Đã rời trận.'), findsOneWidget);
    });

    testWidgets('no overflow at 320 dp with 130 % text', (tester) async {
      await pumpSheet(tester, width: 320, height: 640, textScale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Đội của bạn'));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('in a match', () {
    setUp(() {
      env
        ..loop = 'INGAME'
        ..core = coreMatchJson()
        ..presence = scorePresence(DateTime.utc(2026, 9, 28, 12));
    });

    testWidgets('header, live score and both teams', (tester) async {
      await pumpSheet(tester);
      expect(find.text('Đang diễn ra'), findsOneWidget);
      expect(find.text('TỈ SỐ TRỰC TIẾP'), findsOneWidget);
      expect(find.text('8  –  4'), findsOneWidget);
      expect(find.text('Tôi#VN1'), findsOneWidget);
      expect(find.text('Cấp 200 · Jett'), findsOneWidget);

      await tester.tap(find.text('Đội địch'));
      await settle(tester, frames: 12);
      expect(find.text('Đối Thủ#0001'), findsOneWidget);
      expect(find.text('Cấp 30 · Reyna'), findsOneWidget);
      expect(find.text('Ẩn danh'), findsOneWidget);
      expect(find.text('Kẻ Thù#EN2'), findsNothing);
      expect(find.text('Omen'), findsOneWidget);
    });

    testWidgets('tapping a player opens their loadout (S51)', (tester) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Tôi#VN1'));
      await settle(tester, frames: 12);
      expect(find.byType(PlayerLoadoutSheet), findsOneWidget);
      expect(find.text('Trang bị của Tôi#VN1'), findsOneWidget);
      verify(() => env.api.coreGameLoadouts(me, liveMatchId)).called(1);
    });

    testWidgets('leaving asks first and uses G-11', (tester) async {
      await pumpSheet(tester);
      await tester.tap(find.text('Rời trận'));
      await settle(tester);
      expect(find.textContaining('mất RR, khóa hàng chờ'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Rời trận'));
      await settle(tester);
      verify(() => env.api.coreGameDisassociate(me, liveMatchId)).called(1);
      verifyNever(() => env.api.pregameQuit(any(), any()));
    });

    testWidgets('a failed leave says so', (tester) async {
      when(() => env.api.coreGameDisassociate(any(), any()))
          .thenThrow(const TransientException(reason: 'network'));
      await pumpSheet(tester);
      await tester.tap(find.text('Rời trận'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Rời trận'));
      await settle(tester);
      expect(find.textContaining('Không thể rời trận.'), findsOneWidget);
    });

    testWidgets('no overflow at 320 dp with 130 % text', (tester) async {
      await pumpSheet(tester, width: 320, height: 640, textScale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Đội địch'));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('ended', () {
    setUp(() {
      env
        ..loop = 'INGAME'
        ..core = (coreMatchJson(state: 'POST_GAME')
          ..['MatchID'] = finishedMatchId);
    });

    testWidgets('final scoreboard and link to the match', (tester) async {
      await pumpSheet(tester);
      expect(find.text('Đã kết thúc'), findsOneWidget);
      expect(find.text('BẢNG ĐIỂM CUỐI TRẬN'), findsOneWidget);
      expect(find.text('K/D/A'), findsOneWidget);
      expect(find.text('Xem chi tiết trận'), findsOneWidget);
      expect(find.text('Rời trận'), findsNothing);
    });

    testWidgets('Riot still processing → message, then retries', (
      tester,
    ) async {
      final match = env.matches.remove(finishedMatchId);
      await pumpSheet(tester);
      expect(find.textContaining('Riot đang xử lý trận đấu'), findsOneWidget);
      env.matches[finishedMatchId] = match;
      await tester.pump(const Duration(seconds: 21));
      await settle(tester, frames: 12);
      expect(find.text('BẢNG ĐIỂM CUỐI TRẬN'), findsOneWidget);
    });

    testWidgets('no overflow at 320 dp with 130 % text', (tester) async {
      await pumpSheet(tester, width: 320, height: 640, textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  });
}
