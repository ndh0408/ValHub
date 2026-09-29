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
  await pumpCommunity(tester, env, const _Host(), size: const Size(360, 900));
  await tester.tap(find.text('tạo'));
  await settle(tester);
}

Map<String, Object?> _party({String code = ''}) => {
  'ID': 'aaaaaaaa-0000-0000-0000-000000000001',
  'Members': [
    {'Subject': mePuuid, 'IsOwner': true},
  ],
  'State': 'DEFAULT',
  'InviteCode': code,
};

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  test('party code validation', () {
    expect(validatePartyCode(''), CommunityStrings.codeRequired);
    expect(validatePartyCode('abc12'), CommunityStrings.codeInvalid);
    expect(validatePartyCode('ab-123'), CommunityStrings.codeInvalid);
    expect(validatePartyCode('abc123'), isNull);
  });

  testWidgets('invalid code blocks posting; valid code posts', (tester) async {
    env.server.json('POST /v1/lfg', lfgJson('new', code: 'Q1W2E3'));
    await _open(tester, env);
    expect(find.text(CommunityStrings.createLfg), findsOneWidget);

    await tester.ensureVisible(find.text(CommunityStrings.postLfg));
    await tester.tap(find.text(CommunityStrings.postLfg));
    await settle(tester);
    expect(find.text(CommunityStrings.codeRequired), findsOneWidget);
    expect(env.server.calls('POST /v1/lfg'), isEmpty);

    await tester.enterText(find.byKey(const ValueKey('lfg-code')), 'q1w2');
    await tester.ensureVisible(find.text(CommunityStrings.postLfg));
    await tester.tap(find.text(CommunityStrings.postLfg));
    await settle(tester);
    expect(find.text(CommunityStrings.codeInvalid), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('lfg-code')), 'q1w2e3');
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Đấu thường'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Đấu thường'));
    await tester.pump();
    await tester.ensureVisible(find.byTooltip(CommunityStrings.increase));
    await tester.tap(find.byTooltip(CommunityStrings.increase));
    await tester.pump();
    await tester.tap(find.byTooltip(CommunityStrings.increase));
    await tester.enterText(
      find.widgetWithText(TextField, CommunityStrings.noteHint),
      'Vui vẻ thôi',
    );
    await tester.pump();
    expect(find.text('Cần 3 người'), findsOneWidget);
    await tester.ensureVisible(find.text(CommunityStrings.postLfg));
    await tester.tap(find.text(CommunityStrings.postLfg));
    await settle(tester);

    expect(env.server.calls('POST /v1/lfg').single.json, {
      'region': 'ap',
      'mode': 'unrated',
      'partyCode': 'Q1W2E3',
      'slots': 3,
      'rankTier': 18,
      'note': 'Vui vẻ thôi',
    });
    expect(find.text('created:new'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('"Tạo mã tổ đội" generates a code from the current party', (
    tester,
  ) async {
    when(() => env.pvp.partyPlayer(any())).thenAnswer(
      (_) async => {
        'Subject': mePuuid,
        'CurrentPartyID': 'aaaaaaaa-0000-0000-0000-000000000001',
      },
    );
    when(() => env.pvp.party(any(), any())).thenAnswer((_) async => _party());
    when(() => env.pvp.gameSession(any()))
        .thenAnswer((_) async => {'loopState': 'MENUS'});
    when(() => env.pvp.partyGenerateInviteCode(any(), any()))
        .thenAnswer((_) async => _party(code: 'ZX9Y8W'));
    await _open(tester, env);

    await tester.ensureVisible(find.text(CommunityStrings.generateCode));
    await tester.tap(find.text(CommunityStrings.generateCode));
    await settle(tester);

    verify(() => env.pvp.partyGenerateInviteCode(mePuuid, any())).called(1);
    expect(find.text('ZX9Y8W'), findsOneWidget);
    expect(find.text(CommunityStrings.codeGenerated), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no running game: explains and allows manual entry', (
    tester,
  ) async {
    when(() => env.pvp.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    await _open(tester, env);

    await tester.ensureVisible(find.text(CommunityStrings.generateCode));
    await tester.tap(find.text(CommunityStrings.generateCode));
    await settle(tester);

    expect(find.text(CommunityStrings.noParty), findsOneWidget);
    verifyNever(() => env.pvp.partyGenerateInviteCode(any(), any()));
    await unmount(tester);
  });
}
