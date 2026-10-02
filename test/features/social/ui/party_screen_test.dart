import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/social/social_strings.dart';
import 'package:valvn/features/social/ui/party_screen.dart';

import '../social_test_env.dart';

Future<void> _pump(WidgetTester tester, SocialTestEnv env) async {
  await pumpSocial(tester, env, const PartyScreen(), height: 2400);
  await settle(tester);
}

void main() {
  setUpAll(registerSocialFallbacks);

  late SocialTestEnv env;
  setUp(() async {
    env = await SocialTestEnv.create();
    addTearDown(env.xmpp.dispose);
    env.xmpp.seed(
      roster: [
        rosterEntry(friendOnline, 'Bạn Online', tag: 'VN2'),
        rosterEntry(friendOffline, 'Ngủ Rồi'),
      ],
      presences: [
        valorantPresence(
          friendOnline,
          const PresenceSnapshot(loopState: LoopState.menus),
        ),
      ],
    );
  });

  testWidgets('game not running (G-12 404)', (tester) async {
    when(() => env.api.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    await _pump(tester, env);
    expect(find.text(SocialStrings.gameNotRunningTitle), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('error with "Thử lại"', (tester) async {
    when(() => env.api.partyPlayer(any()))
        .thenThrow(const TransientException(reason: 'network'));
    await _pump(tester, env);
    expect(find.text('Thử lại'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('owner party: members, queue chips, start matchmaking', (
    tester,
  ) async {
    env.serveParty(
      partyJson(
        members: [
          memberJson(me, owner: true, ready: true, tier: 18),
          memberJson(mate, tier: 12, level: 45),
        ],
        queue: 'competitive',
      ),
    );
    await _pump(tester, env);

    expect(find.text('Tổ đội & hàng chờ'), findsOneWidget);
    expect(find.text('THÀNH VIÊN (2/5)'), findsOneWidget);
    expect(find.textContaining('Tôi'), findsWidgets);
    expect(find.textContaining('Đồng Đội Có Cái Tên'), findsOneWidget);
    expect(find.text('Trưởng nhóm'), findsOneWidget);
    expect(find.text(SocialStrings.you.toUpperCase()), findsOneWidget);
    expect(find.text('Cấp 45'), findsOneWidget);
    // The queue is a row that opens the picker sheet.
    expect(find.text(SocialStrings.queueLabel.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Bắt đầu tìm trận'));
    await settle(tester);
    verify(() => env.api.partyJoinMatchmaking(me, partyId)).called(1);

    await tester.tap(find.byTooltip(SocialStrings.changeQueue));
    await settle(tester);
    expect(find.text(SocialStrings.pickQueueTitle), findsOneWidget);
    expect(find.text('Siêu Tốc'), findsOneWidget);
    await tester.tap(find.text('Đấu thường'));
    await settle(tester);
    verify(() => env.api.partyChangeQueue(me, partyId, 'unrated')).called(1);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('matchmaking timer and cancel', (tester) async {
    env.serveParty(
      partyJson(
        state: 'MATCHMAKING',
        entry: now.subtract(const Duration(seconds: 92)).toIso8601String(),
      ),
    );
    await _pump(tester, env);
    expect(find.text('Hủy tìm trận · 01:32'), findsOneWidget);
    expect(find.text('Đang tìm trận · 01:32'), findsOneWidget);
    await tester.tap(find.text('Hủy tìm trận · 01:32'));
    await settle(tester);
    verify(() => env.api.partyLeaveMatchmaking(me, partyId)).called(1);
    await unmount(tester);
  });

  testWidgets('blocked competitive explains why; non-owner cannot queue', (
    tester,
  ) async {
    env.serveParty(
      partyJson(
        members: [
          memberJson(mate, owner: true, tier: 24),
          memberJson(me, tier: 6),
        ],
        eligible: ['unrated'],
        queue: 'competitive',
      ),
    );
    await _pump(tester, env);
    expect(
      find.text(
        'Tổ đội chưa thể vào Thi đấu xếp hạng: chênh lệch rank quá lớn '
        'để đấu xếp hạng',
      ),
      findsOneWidget,
    );
    expect(find.text(SocialStrings.onlyLeader), findsOneWidget);
    final start = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Bắt đầu tìm trận'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(start.onPressed, isNull);

    // Ready toggle is still mine.
    await tester.tap(find.text('Sẵn sàng'));
    await settle(tester);
    verify(() => env.api.partySetReady(me, partyId, ready: true)).called(1);
    await unmount(tester);
  });

  testWidgets('in a match: queue locked', (tester) async {
    env.serveParty(partyJson(), loopState: 'INGAME');
    await _pump(tester, env);
    expect(
      find.text('Bạn đang trong trận. Hàng chờ sẽ mở lại khi trận kết thúc.'),
      findsOneWidget,
    );
    expect(
      find.text('Không thể đổi hàng chờ khi đang trong trận.'),
      findsOneWidget,
    );
    await unmount(tester);
  });

  testWidgets('remove a member asks first', (tester) async {
    env.serveParty(
      partyJson(members: [memberJson(me, owner: true), memberJson(mate)]),
    );
    await _pump(tester, env);
    await tester.tap(find.byTooltip('Xóa khỏi tổ đội'));
    await settle(tester);
    expect(find.text('Xóa khỏi tổ đội?'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await settle(tester);
    verifyNever(
      () => env.api.partyRemovePlayer(any(), subject: any(named: 'subject')),
    );

    await tester.tap(find.byTooltip('Xóa khỏi tổ đội'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa khỏi tổ đội'));
    await settle(tester);
    verify(() => env.api.partyRemovePlayer(me, subject: mate)).called(1);
    await unmount(tester);
  });

  testWidgets('invite an online friend in one tap', (tester) async {
    env.serveParty(partyJson());
    await _pump(tester, env);
    expect(find.text('MỜI BẠN BÈ'), findsOneWidget);
    await tester.tap(find.text('Bạn Online'));
    await settle(tester);
    verify(
      () => env.api.partyInviteByRiotId(
        me,
        partyId,
        gameName: 'Bạn Online',
        tagLine: 'VN2',
      ),
    ).called(1);
    expect(find.text('Đã gửi lời mời tới Bạn Online#VN2.'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('party code: create, then copy / disable', (tester) async {
    env.serveParty(partyJson());
    await _pump(tester, env);
    await tester.tap(find.text('Tạo mã'));
    await settle(tester);
    verify(() => env.api.partyGenerateInviteCode(me, partyId)).called(1);
    expect(find.text('NEW123'), findsOneWidget);
    expect(find.bySemanticsLabel('Mã tổ đội: NEW123'), findsOneWidget);
    expect(find.text('Sao chép'), findsOneWidget);
    await tester.tap(find.text('Chia sẻ'));
    await settle(tester);
    expect(env.shared, ['Vào tổ đội VALORANT của mình bằng mã: NEW123']);
    await tester.tap(find.text('Tắt mã'));
    await settle(tester);
    verify(() => env.api.partyDisableInviteCode(me, partyId)).called(1);
    await unmount(tester);
  });

  testWidgets('join by code validates the code', (tester) async {
    env.serveParty(partyJson());
    await _pump(tester, env);
    final field = find.widgetWithText(TextField, 'Nhập mã để tham gia');
    await tester.enterText(field, 'ab');
    await tester.tap(find.text('Tham gia'));
    await settle(tester);
    expect(find.text('Mã tổ đội chỉ gồm chữ cái và chữ số.'), findsOneWidget);
    verifyNever(() => env.api.partyJoinByCode(any(), any()));

    await tester.enterText(field, 'xyz789');
    await tester.tap(find.text('Tham gia'));
    await settle(tester);
    verify(() => env.api.partyJoinByCode(me, 'XYZ789')).called(1);
    await unmount(tester);
  });

  testWidgets('joining completes safely after the screen is closed', (
    tester,
  ) async {
    env.serveParty(partyJson());
    final response = Completer<JsonMap>();
    when(() => env.api.partyJoinByCode(any(), any()))
        .thenAnswer((_) => response.future);
    await _pump(tester, env);
    await tester.enterText(
      find.widgetWithText(TextField, 'Nhập mã để tham gia'),
      'xyz789',
    );
    await tester.tap(find.text('Tham gia'));
    await tester.pump();
    verify(() => env.api.partyJoinByCode(me, 'XYZ789')).called(1);
    await unmount(tester);
    response.complete(partyJson());
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'old account join cannot clear the next account code or show success',
    (tester) async {
      final account = Account.fromJson({
        ...myAccount.toJson(),
        'puuid': mate,
        'gameName': 'Second',
      })!;
      await env.prefs.setJson(PrefKeys.accounts, [
        myAccount.toJson(),
        account.toJson(),
      ]);
      env.serveParty(partyJson());
      final response = Completer<JsonMap>();
      when(() => env.api.partyJoinByCode(any(), any()))
          .thenAnswer((_) => response.future);
      await _pump(tester, env);
      final field = find.widgetWithText(TextField, 'Nhập mã để tham gia');
      await tester.enterText(field, 'OLD123');
      await tester.tap(find.text('Tham gia'));
      await tester.pump();
      verify(() => env.api.partyJoinByCode(me, 'OLD123')).called(1);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PartyScreen)),
      );
      container.read(activePuuidProvider.notifier).select(mate);
      await settle(tester);
      await tester.enterText(field, 'NEW789');
      response.complete(partyJson());
      await settle(tester);
      expect(tester.widget<TextField>(field).controller!.text, 'NEW789');
      expect(find.text(SocialStrings.joined), findsNothing);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('incoming invite: accept needs the flag', (tester) async {
    env.serveParty(
      partyJson(),
      invites: [
        {'PartyID': otherPartyId, 'InvitedBySubject': stranger},
      ],
    );
    await _pump(tester, env);
    expect(find.text('Lời mời từ Người Lạ#1234'), findsOneWidget);
    await tester.tap(find.text('Chấp nhận'));
    await settle(tester);
    expect(find.text('Hãy chấp nhận lời mời này trong game.'), findsOneWidget);
    verifyNever(() => env.api.partyAcceptInvite(any(), any()));

    await tester.tap(find.text('Từ chối'));
    await settle(tester);
    expect(find.text('Lời mời từ Người Lạ#1234'), findsNothing);
    await unmount(tester);
  });

  testWidgets('incoming invite accepted when the flag is on', (tester) async {
    env = await SocialTestEnv.create(
      remoteConfig: const RemoteConfig(
        flags: {RemoteFlags.partyAcceptInvite: true},
      ),
    );
    addTearDown(env.xmpp.dispose);
    env.xmpp.seed();
    env.serveParty(
      partyJson(),
      invites: [
        {'PartyID': otherPartyId},
      ],
    );
    await _pump(tester, env);
    expect(find.text('Lời mời vào tổ đội'), findsOneWidget);
    await tester.tap(find.text('Chấp nhận'));
    await settle(tester);
    verify(() => env.api.partyAcceptInvite(me, otherPartyId)).called(1);
    await unmount(tester);
  });

  testWidgets('polls the party periodically', (tester) async {
    env.serveParty(partyJson());
    await pumpSocial(
      tester,
      env,
      const PartyScreen(pollInterval: Duration(seconds: 1)),
      height: 2400,
    );
    await settle(tester);
    clearInteractions(env.api);
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    verify(() => env.api.partyPlayer(me)).called(greaterThanOrEqualTo(1));
    await unmount(tester);
  });
}
