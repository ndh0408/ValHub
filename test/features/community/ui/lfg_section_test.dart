import 'dart:async';

import '../../../helpers/l10n.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart';
import 'package:valvn/features/community/ui/lfg/lfg_section.dart';

import '../community_test_env.dart';

Future<void> _open(WidgetTester tester, CommunityTestEnv env) async {
  await pumpCommunityRouter(
    tester,
    env,
    routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
    initialLocation: '/community?section=lfg',
  );
  await settle(tester);
}

Map<String, Object?> _partyJson(List<String> members, {String code = ''}) => {
  'ID': 'aaaaaaaa-0000-0000-0000-000000000001',
  'Members': [
    for (final m in members) {'Subject': m, 'IsOwner': m == mePuuid},
  ],
  'State': 'DEFAULT',
  'InviteCode': code,
};

void _serveParty(CommunityTestEnv env, List<String> members) {
  when(() => env.pvp.partyPlayer(any())).thenAnswer(
    (_) async => {
      'Subject': mePuuid,
      'CurrentPartyID': 'aaaaaaaa-0000-0000-0000-000000000001',
    },
  );
  when(() => env.pvp.party(any(), any()))
      .thenAnswer((_) async => _partyJson(members));
  when(() => env.pvp.gameSession(any()))
      .thenAnswer((_) async => {'loopState': 'MENUS'});
}

Future<void> _scrollChip(WidgetTester tester, Finder chip, String list) async {
  await tester.scrollUntilVisible(
    chip,
    120,
    scrollable: find.descendant(
      of: find.byKey(ValueKey(list)),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.ensureVisible(chip);
  await tester.pump();
}

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  testWidgets('cards show rank range, roles, mic, language, party dots', (
    tester,
  ) async {
    env.server.json(
      'GET /v1/lfg',
      page([
        {
          ...lfgJson('l1', note: 'Cần 1 Controller, có mic'),
          'rankMin': 12,
          'rankMax': 21,
          'roles': ['controller', 'flex'],
          'mic': true,
          'language': 'vi',
          'partySize': 3,
        },
      ]),
    );
    await _open(tester, env);

    // "Phù hợp rank của bạn" is on by default: the viewer's rank is sent.
    expect(env.server.calls('GET /v1/lfg').first.query['rank'], '18');
    expect(
      find.byKey(const ValueKey('lfg-match-rank'), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Cần 1 Controller, có mic'), findsOneWidget);
    expect(find.text('Kiểm soát'), findsOneWidget);
    expect(find.text(CommunityStrings.roleFlex), findsOneWidget);
    expect(find.byTooltip(CommunityStrings.mic), findsOneWidget);
    expect(find.text('VI'), findsOneWidget);
    expect(
      find.bySemanticsLabel(CommunityStrings.partySizeValue(3)),
      findsOneWidget,
    );
    expect(find.text('Còn 24:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('turning the rank filter off dims out-of-range posts', (
    tester,
  ) async {
    env.server.json(
      'GET /v1/lfg',
      page([
        {...lfgJson('low'), 'rankMin': 3, 'rankMax': 8},
      ]),
    );
    await _open(tester, env);
    expect(find.text(CommunityStrings.outOfRange), findsNothing);

    final toggle = find.byKey(const ValueKey('lfg-match-rank'));
    await _scrollChip(tester, toggle, 'lfg-filters');
    await tester.tap(toggle);
    await settle(tester);

    expect(
      env.server.calls('GET /v1/lfg').last.query.containsKey('rank'),
      isFalse,
    );
    expect(find.text(CommunityStrings.outOfRange), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'join: confirm → server authorizes and returns code → G-19 → hint',
    (tester) async {
      env.server
        ..json('GET /v1/lfg', page([lfgJson('l1')]))
        ..json('POST /v1/lfg/l1/join', {'joins': 3, 'partyCode': 'DEF456'});
      when(() => env.pvp.partyJoinByCode(any(), any()))
          .thenAnswer((_) async => {});
      await _open(tester, env);

      await tester.tap(find.text(CommunityStrings.joinParty));
      await settle(tester);
      expect(find.text(CommunityStrings.joinConfirmTitle), findsOneWidget);
      verifyNever(() => env.pvp.partyJoinByCode(any(), any()));

      await tester.tap(find.text(CommunityStrings.join));
      await settle(tester);

      verify(() => env.pvp.partyJoinByCode(mePuuid, 'DEF456')).called(1);
      expect(env.server.calls('POST /v1/lfg/l1/join'), hasLength(1));
      expect(find.text(CommunityStrings.joinedHint), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('join errors are explained and offer a refresh', (tester) async {
    env.server.json('GET /v1/lfg', page([lfgJson('l1')]));
    env.server.json('POST /v1/lfg/l1/join', {
      'partyCode': 'ABC123',
      'joins': 1,
    });
    when(() => env.pvp.partyJoinByCode(any(), any()))
        .thenThrow(const RiotApiException(400, errorCode: 'PARTY_FULL'));
    await _open(tester, env);
    final before = env.server.calls('GET /v1/lfg').length;

    await tester.tap(find.text(CommunityStrings.joinParty));
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.join));
    await settle(tester);

    expect(find.text(CommunityStrings.joinPartyFull), findsOneWidget);
    expect(env.server.calls('POST /v1/lfg/l1/join'), hasLength(1));
    await tester.tap(find.text(CommunityStrings.refreshList));
    await settle(tester);
    expect(env.server.calls('GET /v1/lfg').length, greaterThan(before));
    await unmount(tester);
  });

  testWidgets('only one party join can be pending across different posts', (
    tester,
  ) async {
    final gate = Completer<void>();
    env.server
      ..json('GET /v1/lfg', page([lfgJson('l1'), lfgJson('l2')]))
      ..json('POST /v1/lfg/l1/join', {'joins': 1, 'partyCode': 'ABC123'})
      ..json('POST /v1/lfg/l2/join', {'joins': 1, 'partyCode': 'DEF456'})
      ..hold('POST /v1/lfg/l1/join', gate);
    when(() => env.pvp.partyJoinByCode(any(), any()))
        .thenAnswer((_) async => {});
    await _open(tester, env);
    await tester.ensureVisible(find.text(CommunityStrings.joinParty).first);
    await tester.tap(find.text(CommunityStrings.joinParty).first);
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.join));
    await settle(tester);
    expect(env.server.calls('POST /v1/lfg/l1/join'), hasLength(1));

    final otherJoin = find.text(CommunityStrings.joinParty).last;
    await tester.ensureVisible(otherJoin);
    await tester.tap(otherJoin);
    await settle(tester);
    expect(find.text(CommunityStrings.joinConfirmTitle), findsNothing);
    expect(env.server.calls('POST /v1/lfg/l2/join'), isEmpty);

    gate.complete();
    await settle(tester);
    verify(() => env.pvp.partyJoinByCode(mePuuid, 'ABC123')).called(1);
    verifyNever(() => env.pvp.partyJoinByCode(mePuuid, 'DEF456'));
    await tester.ensureVisible(otherJoin);
    await tester.tap(otherJoin);
    await settle(tester);
    expect(find.text(CommunityStrings.joinConfirmTitle), findsOneWidget);
    await tester.tap(find.text(CommunityStrings.join));
    await settle(tester);
    verify(() => env.pvp.partyJoinByCode(mePuuid, 'DEF456')).called(1);
    await unmount(tester);
  });

  testWidgets('cancelling confirmation releases the party join controls', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/lfg', page([lfgJson('l1')]))
      ..json('POST /v1/lfg/l1/join', {'joins': 1, 'partyCode': 'ABC123'});
    when(() => env.pvp.partyJoinByCode(any(), any()))
        .thenAnswer((_) async => {});
    await _open(tester, env);
    await tester.tap(find.text(CommunityStrings.joinParty));
    await settle(tester);
    await tester.tap(find.text(tl.commonCancel));
    await settle(tester);
    expect(env.server.calls('POST /v1/lfg/l1/join'), isEmpty);
    verifyNever(() => env.pvp.partyJoinByCode(any(), any()));
    await tester.tap(find.text(CommunityStrings.joinParty));
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.join));
    await settle(tester);
    verify(() => env.pvp.partyJoinByCode(mePuuid, 'ABC123')).called(1);
    expect(find.text(CommunityStrings.joinedHint), findsOneWidget);
    await unmount(tester);
  });

  test('join error mapping', () {
    expect(
      joinErrorMessage(
        tl,
        const RiotApiException(400, errorCode: 'PARTY_FULL'),
      ),
      CommunityStrings.joinPartyFull,
    );
    expect(
      joinErrorMessage(tl, const RiotApiException(409)),
      CommunityStrings.joinPartyFull,
    );
    expect(
      joinErrorMessage(
        tl,
        const NotFoundException(errorCode: 'PARTY_NOT_FOUND'),
      ),
      CommunityStrings.joinCodeExpired,
    );
    expect(
      joinErrorMessage(tl, const RiotApiException(404, errorCode: 'X')),
      CommunityStrings.joinCodeExpired,
    );
    expect(
      joinErrorMessage(tl, const NotFoundException()),
      CommunityStrings.joinGameNotRunning,
    );
  });

  testWidgets('own post: pinned with status, joins, Gia hạn and Gỡ tin', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/lfg', page([lfgJson('l1')]))
      ..json('GET /v1/lfg/mine', {
        ...lfgJson(
          'mine',
          author: authorJson(id: meId),
          code: 'MINE12',
        ),
        'joins': 2,
      })
      ..on(
        'PATCH /v1/lfg/mine',
        (_) => FakeResponse(200, {
          ...lfgJson(
            'mine',
            author: authorJson(id: meId),
            code: 'MINE12',
            left: const Duration(minutes: 30),
          ),
          'joins': 2,
        }),
      )
      ..json('DELETE /v1/lfg/mine', null, status: 204);
    await _open(tester, env);

    expect(find.text(CommunityStrings.statusOpen), findsOneWidget);
    expect(find.textContaining('MINE12'), findsOneWidget);
    expect(
      find.textContaining(CommunityStrings.joinsCount('2')),
      findsOneWidget,
    );

    await tester.tap(find.text(CommunityStrings.extend));
    await settle(tester);
    expect(env.server.calls('PATCH /v1/lfg/mine'), hasLength(1));
    expect(find.text(CommunityStrings.extended), findsOneWidget);

    await tester.tap(find.text(CommunityStrings.removeLfg));
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.removeLfg).last);
    await settle(tester);
    expect(env.server.calls('DELETE /v1/lfg/mine'), hasLength(1));
    expect(find.text(CommunityStrings.extend), findsNothing);
    await unmount(tester);
  });

  testWidgets('poster sync: PATCHes party changes and notifies new members', (
    tester,
  ) async {
    const mate = 'bbbbbbbb-0000-0000-0000-00000000000b';
    env.server
      ..json('GET /v1/lfg', page([]))
      ..json('GET /v1/lfg/mine', {
        ...lfgJson('mine', author: authorJson(id: meId), slots: 3),
        'partySize': 2,
      })
      ..on('PATCH /v1/lfg/mine', (r) {
        final body = r.json! as Map;
        return FakeResponse(200, {
          ...lfgJson('mine', author: authorJson(id: meId), slots: 3),
          'partySize': body['partySize'] ?? 2,
          'slots': body['slots'] ?? 3,
        });
      });
    _serveParty(env, [mePuuid, mate]);
    when(() => env.pvp.names(any(), any())).thenAnswer(
      (_) async => [
        {
          'Subject': 'cccccccc-0000-0000-0000-00000000000c',
          'GameName': 'Bạn Mới',
          'TagLine': 'VN3',
        },
      ],
    );
    await _open(tester, env);

    // First tick: baseline + heartbeat (nobody new).
    await tester.pump(const Duration(seconds: 21));
    await settle(tester);
    expect(env.server.calls('PATCH /v1/lfg/mine'), hasLength(1));
    expect(env.notifications.shown, isEmpty);

    // A third member joins.
    _serveParty(env, [mePuuid, mate, 'cccccccc-0000-0000-0000-00000000000c']);
    await tester.pump(const Duration(seconds: 21));
    await settle(tester);

    final patches = env.server.calls('PATCH /v1/lfg/mine');
    expect(patches, hasLength(2));
    expect(patches.last.json, containsPair('partySize', 3));
    expect(patches.last.json, containsPair('slots', 2));
    expect(
      env.notifications.shown.single.title,
      CommunityStrings.memberJoined('Bạn Mới#VN3'),
    );
    await unmount(tester);
  });

  testWidgets('mode chips refetch and the list refreshes every 20 s', (
    tester,
  ) async {
    env.server.json('GET /v1/lfg', page([lfgJson('l1')]));
    await _open(tester, env);

    final chip = find.widgetWithText(FilterChip, 'Đấu thường');
    await _scrollChip(tester, chip, 'lfg-modes');
    await tester.tap(chip);
    await settle(tester);
    final calls = env.server.calls('GET /v1/lfg');
    expect(calls.last.query['mode'], 'unrated');
    final before = calls.length;

    await tester.pump(const Duration(seconds: 21));
    await settle(tester);
    expect(env.server.calls('GET /v1/lfg').length, greaterThan(before));
    await unmount(tester);
  });

  testWidgets('empty list: names the rank filter and offers every rank', (
    tester,
  ) async {
    env.server.json('GET /v1/lfg', page([]));
    await _open(tester, env);
    expect(env.server.calls('GET /v1/lfg').last.query['rank'], '18');
    expect(find.text(tl.communityLfgEmptyRankTitle), findsOneWidget);
    expect(find.text(tl.communityLfgEmptyRankBody), findsOneWidget);
    expect(find.text(CommunityStrings.lfgEmptyTitle), findsNothing);

    await tester.tap(find.byKey(const ValueKey('lfg-show-all-ranks')));
    await settle(tester);

    expect(
      env.server.calls('GET /v1/lfg').last.query.containsKey('rank'),
      isFalse,
    );
    expect(find.text(CommunityStrings.lfgEmptyTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('lfg-show-all-ranks')), findsNothing);
    expect(find.text(CommunityStrings.createLfgShort), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('another server: join is off and says why; posts go home', (
    tester,
  ) async {
    await env.prefs.setString(PrefKeys.ui(LfgMemoryKeys.region), 'na');
    env.server
      ..json(
        'GET /v1/lfg',
        page([
          {...lfgJson('n1'), 'region': 'na'},
        ]),
      )
      ..json('POST /v1/lfg', lfgJson('new', code: 'Q1W2E3'));
    when(() => env.pvp.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    await _open(tester, env);
    expect(env.server.calls('GET /v1/lfg').last.query['region'], 'na');

    expect(find.text(CommunityStrings.joinParty), findsNothing);
    final join = find.widgetWithText(FilledButton, tl.communityLfgOtherServer);
    expect(tester.widget<FilledButton>(join).onPressed, isNull);
    await tester.tap(join, warnIfMissed: false);
    await settle(tester);
    expect(find.text(CommunityStrings.joinConfirmTitle), findsNothing);
    expect(env.server.calls('POST /v1/lfg/n1/join'), isEmpty);

    // "Tạo tin" posts to the account's own server, not the one being viewed.
    await tester.tap(find.text(CommunityStrings.createLfgShort));
    await settle(tester);
    expect(
      find.text(tl.communityLfgSheetSubtitle(tl.communityRegionName('ap'))),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const ValueKey('lfg-code')), 'q1w2e3');
    final post = find.text(CommunityStrings.postLfg);
    await tester.ensureVisible(post);
    await tester.pump();
    await tester.tap(post);
    await settle(tester);
    expect(
      (env.server.calls('POST /v1/lfg').single.json! as Map)['region'],
      'ap',
    );
    await unmount(tester);
  });

  testWidgets('extending an expired post (404) drops it and says so', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/lfg', page([]))
      ..json('GET /v1/lfg/mine', lfgJson('mine', author: authorJson(id: meId)))
      ..json('PATCH /v1/lfg/mine', {
        'error': {'code': 'not_found'},
      }, status: 404);
    await _open(tester, env);
    expect(find.text(CommunityStrings.extend), findsOneWidget);

    await tester.tap(find.text(CommunityStrings.extend));
    await settle(tester);

    expect(find.text(CommunityStrings.lfgExpiredRepost), findsOneWidget);
    expect(find.text(CommunityStrings.extend), findsNothing);
    await unmount(tester);
  });

  testWidgets('poster sync: a 404 PATCH (expired) removes the pinned post', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/lfg', page([]))
      ..json('GET /v1/lfg/mine', lfgJson('mine', author: authorJson(id: meId)))
      ..json('PATCH /v1/lfg/mine', {
        'error': {'code': 'not_found'},
      }, status: 404);
    _serveParty(env, [mePuuid]);
    await _open(tester, env);
    expect(find.text(CommunityStrings.extend), findsOneWidget);

    await tester.pump(const Duration(seconds: 21));
    await settle(tester);

    expect(env.server.calls('PATCH /v1/lfg/mine'), hasLength(1));
    expect(find.text(CommunityStrings.extend), findsNothing);
    await unmount(tester);
  });

  for (final light in [false, true]) {
    testWidgets('no overflow at 360 dp × 2.0 (${light ? 'light' : 'dark'})', (
      tester,
    ) async {
      env.server
        ..json(
          'GET /v1/lfg',
          page([
            {
              ...lfgJson('l1', note: 'Cần 1 Controller, có mic, vui vẻ'),
              'rankMin': 12,
              'rankMax': 21,
              'roles': ['controller', 'initiator', 'flex'],
              'mic': true,
              'partySize': 3,
            },
            {...lfgJson('l2', note: 'Khác máy chủ'), 'region': 'na'},
          ]),
        )
        ..json('GET /v1/lfg/mine', {
          ...lfgJson('mine', author: authorJson(id: meId)),
          'joins': 12,
        });
      await pumpCommunityRouter(
        tester,
        env,
        routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
        initialLocation: '/community?section=lfg',
        size: const Size(360, 3600),
        textScale: 2,
        theme: light ? buildLightTheme() : buildDarkTheme(),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Cần 1 Controller, có mic, vui vẻ'), findsOneWidget);
      expect(find.text(tl.communityLfgOtherServer), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('lfg-region'))).height,
        greaterThanOrEqualTo(48),
      );
      await unmount(tester);
    });
  }
}
