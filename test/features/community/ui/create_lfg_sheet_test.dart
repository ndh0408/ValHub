import '../../../helpers/l10n.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/ui/lfg/create_lfg_sheet.dart';

import '../community_test_env.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  LfgPost? created;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              final p = await showCreateLfgSheet(
                context,
                account: meAccount,
                region: 'ap',
              );
              setState(() => created = p);
            },
            child: const Text('tạo'),
          ),
          if (created != null) Text('created:${created!.id}'),
        ],
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester, CommunityTestEnv env) async {
  await pumpCommunity(tester, env, const _Host(), size: const Size(360, 1000));
  await tester.tap(find.text('tạo'));
  await settle(tester);
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
}

Map<String, Object?> _party({List<String>? members, String code = ''}) => {
  'ID': 'aaaaaaaa-0000-0000-0000-000000000001',
  'Members': [
    for (final m in members ?? [mePuuid])
      {'Subject': m, 'IsOwner': m == mePuuid},
  ],
  'State': 'DEFAULT',
  'Accessibility': 'CLOSED',
  'InviteCode': code,
};

void _serveParty(CommunityTestEnv env, {List<String>? members}) {
  when(() => env.pvp.partyPlayer(any())).thenAnswer(
    (_) async => {
      'Subject': mePuuid,
      'CurrentPartyID': 'aaaaaaaa-0000-0000-0000-000000000001',
    },
  );
  when(() => env.pvp.party(any(), any()))
      .thenAnswer((_) async => _party(members: members));
  when(() => env.pvp.gameSession(any()))
      .thenAnswer((_) async => {'loopState': 'MENUS'});
  when(() => env.pvp.partyGenerateInviteCode(any(), any()))
      .thenAnswer((_) async => _party(members: members, code: 'ZX9Y8W'));
  when(
    () => env.pvp.partySetAccessibility(any(), any(), open: any(named: 'open')),
  ).thenAnswer((_) async => _party(members: members));
}

void main() {
  late CommunityTestEnv env;
  setUp(() async {
    env = await CommunityTestEnv.create();
    when(() => env.pvp.gameSession(any()))
        .thenAnswer((_) async => throw const NotFoundException());
  });

  test('typed party code validation', () {
    expect(validatePartyCode(tl, ''), CommunityStrings.codeRequired);
    expect(validatePartyCode(tl, 'abc12'), CommunityStrings.codeInvalid);
    expect(validatePartyCode(tl, 'abc123'), isNull);
  });

  testWidgets('empty code: generated from the party on "Đăng tin"', (
    tester,
  ) async {
    _serveParty(
      env,
      members: [mePuuid, 'bbbbbbbb-0000-0000-0000-00000000000b'],
    );
    env.server.json('POST /v1/lfg', lfgJson('new', code: 'ZX9Y8W'));
    await _open(tester, env);

    // Party size prefilled from the live party.
    expect(find.text(CommunityStrings.partySizeValue(2)), findsOneWidget);
    expect(find.text(CommunityStrings.partySizeFromGame), findsOneWidget);

    await _tap(tester, find.text(CommunityStrings.postLfg));
    await settle(tester);

    verify(() => env.pvp.partyGenerateInviteCode(mePuuid, any())).called(1);
    // Posting never opens the party: players join by code.
    verifyNever(
      () =>
          env.pvp.partySetAccessibility(any(), any(), open: any(named: 'open')),
    );
    final body = env.server.calls('POST /v1/lfg').single.json! as Map;
    expect(body['partyCode'], 'ZX9Y8W');
    expect(body['partySize'], 2);
    expect(body['language'], 'vi');
    expect(find.text('created:new'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no running game and no code: explains, nothing posted', (
    tester,
  ) async {
    when(() => env.pvp.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    await _open(tester, env);

    await _tap(tester, find.text(CommunityStrings.postLfg));
    await settle(tester);

    expect(find.text(CommunityStrings.codeAutoFailed), findsOneWidget);
    expect(env.server.calls('POST /v1/lfg'), isEmpty);
    await unmount(tester);
  });

  testWidgets('all fields: rank range, roles, mic, language, slots, note', (
    tester,
  ) async {
    when(() => env.pvp.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    env.server.json('POST /v1/lfg', lfgJson('new', code: 'Q1W2E3'));
    await _open(tester, env);

    await _tap(tester, find.widgetWithText(FilterChip, 'Đấu thường'));
    // Suggested range around the poster's rank (18 → 15..21).
    await _tap(tester, find.byKey(const ValueKey('rank-suggest')));
    await _tap(tester, find.widgetWithText(FilterChip, 'Kiểm soát'));
    await _tap(tester, find.widgetWithText(FilterChip, 'Đối đầu'));
    await _tap(tester, find.text(CommunityStrings.mic));
    await _tap(tester, find.byKey(const ValueKey('lfg-language')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('lang-ja')));
    await settle(tester);
    final slotsPlus = find.descendant(
      of: find.byKey(const ValueKey('slots')),
      matching: find.byTooltip(CommunityStrings.increase),
    );
    await _tap(tester, slotsPlus);
    await tester.enterText(find.byKey(const ValueKey('lfg-code')), 'q1w2e3');
    await tester.enterText(
      find.widgetWithText(TextField, CommunityStrings.noteHint),
      'Vui vẻ thôi',
    );
    await _tap(tester, find.text(CommunityStrings.postLfg));
    await settle(tester);

    expect(env.server.calls('POST /v1/lfg').single.json, {
      'region': 'ap',
      'mode': 'unrated',
      'partyCode': 'Q1W2E3',
      'slots': 2,
      'rankTier': 18,
      'note': 'Vui vẻ thôi',
      'rankMin': 15,
      'rankMax': 21,
      'roles': ['duelist', 'controller'],
      'mic': true,
      'language': 'ja',
      'partySize': 1,
    });
    await unmount(tester);
  });

  testWidgets('invalid typed code and too many players are blocked', (
    tester,
  ) async {
    when(() => env.pvp.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    await _open(tester, env);

    await tester.enterText(find.byKey(const ValueKey('lfg-code')), 'q1w2');
    await _tap(tester, find.text(CommunityStrings.postLfg));
    await settle(tester);
    expect(find.text(CommunityStrings.codeInvalid), findsOneWidget);
    expect(env.server.calls('POST /v1/lfg'), isEmpty);

    // Party of 4 leaves room for 1 slot only: the stepper stops there.
    final sizePlus = find.descendant(
      of: find.byKey(const ValueKey('party-size')),
      matching: find.byTooltip(CommunityStrings.increase),
    );
    for (var i = 0; i < 3; i++) {
      await _tap(tester, sizePlus);
    }
    expect(find.text(CommunityStrings.partySizeValue(4)), findsOneWidget);
    final slotsPlus = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey('slots')),
        matching: find.widgetWithIcon(IconButton, Icons.add_rounded),
      ),
    );
    expect(slotsPlus.onPressed, isNull);
    await unmount(tester);
  });
}
