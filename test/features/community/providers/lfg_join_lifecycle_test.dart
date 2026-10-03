import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart';
import 'package:valvn/features/social/providers/party_providers.dart';

import '../community_test_env.dart';

void main() {
  late CommunityTestEnv env;
  Future<bool>? pending;
  late ProviderContainer container;
  final post = LfgPost.fromJson(lfgJson('l1'))!;

  setUp(() async {
    env = await CommunityTestEnv.create();
    pending = null;
    env.server.json('POST /v1/lfg/l1/join', {
      'joins': 1,
      'partyCode': 'ABC123',
    });
    when(() => env.pvp.partyJoinByCode(any(), any()))
        .thenAnswer((_) async => {});
  });

  Future<void> open(WidgetTester tester) async {
    await pumpCommunity(
      tester,
      env,
      Consumer(
        builder: (context, ref, child) => TextButton(
          onPressed: () => pending = joinLfgPost(ref, mePuuid, post),
          child: const Text('join test'),
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(Consumer)),
    );
  }

  Future<void> switchAccount() async {
    final second = Account.fromJson({
      ...meAccount.toJson(),
      'puuid': 'bbbbbbbb-0000-0000-0000-00000000000b',
      'gameName': 'Second',
    })!;
    await env.prefs.setJson(PrefKeys.accounts, [
      meAccount.toJson(),
      second.toJson(),
    ]);
    container.read(accountsProvider.notifier).reload();
    container.read(activePuuidProvider.notifier).select(second.puuid);
  }

  testWidgets('stale account cannot begin a join', (tester) async {
    await open(tester);
    await switchAccount();
    await tester.tap(find.text('join test'));
    await settle(tester);
    expect(await pending, isFalse);
    expect(env.server.calls('POST /v1/lfg/l1/join'), isEmpty);
    verifyNever(() => env.pvp.partyJoinByCode(any(), any()));
    await unmount(tester);
  });

  testWidgets('account switch while authorizing prevents Riot mutation', (
    tester,
  ) async {
    final gate = Completer<void>();
    env.server.hold('POST /v1/lfg/l1/join', gate);
    await open(tester);
    await tester.tap(find.text('join test'));
    await settle(tester);
    expect(env.server.calls('POST /v1/lfg/l1/join'), hasLength(1));
    await switchAccount();
    gate.complete();
    await settle(tester);
    expect(await pending, isFalse);
    verifyNever(() => env.pvp.partyJoinByCode(any(), any()));
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('disposed initiating view cannot begin Riot mutation', (
    tester,
  ) async {
    final gate = Completer<void>();
    env.server.hold('POST /v1/lfg/l1/join', gate);
    await open(tester);
    await tester.tap(find.text('join test'));
    await settle(tester);
    expect(env.server.calls('POST /v1/lfg/l1/join'), hasLength(1));
    await tester.pumpWidget(const SizedBox());
    gate.complete();
    await settle(tester);
    expect(await pending, isFalse);
    verifyNever(() => env.pvp.partyJoinByCode(any(), any()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Riot completion after switch does not report current success', (
    tester,
  ) async {
    final gate = Completer<Map<String, dynamic>>();
    when(() => env.pvp.partyJoinByCode(any(), any()))
        .thenAnswer((_) => gate.future);
    await open(tester);
    await tester.tap(find.text('join test'));
    await settle(tester);
    verify(() => env.pvp.partyJoinByCode(mePuuid, 'ABC123')).called(1);
    await switchAccount();
    gate.complete({});
    await settle(tester);
    expect(await pending, isFalse);
    verifyNever(() => env.pvp.partyPlayer(any()));
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('successful join refreshes an observed cached party', (
    tester,
  ) async {
    const beforeId = 'aaaaaaaa-0000-0000-0000-000000000001';
    const afterId = 'aaaaaaaa-0000-0000-0000-000000000002';
    var partyId = beforeId;
    when(
      () => env.pvp.partyPlayer(any()),
    ).thenAnswer((_) async => {'Subject': mePuuid, 'CurrentPartyID': partyId});
    when(() => env.pvp.party(any(), any())).thenAnswer(
      (_) async => {
        'ID': partyId,
        'Members': [
          {'Subject': mePuuid, 'IsOwner': true},
        ],
        'State': 'DEFAULT',
      },
    );
    when(() => env.pvp.gameSession(any()))
        .thenAnswer((_) async => {'loopState': 'MENUS'});
    when(() => env.pvp.partyJoinByCode(any(), any())).thenAnswer((_) async {
      partyId = afterId;
      return {};
    });
    await open(tester);
    final sub = container.listen(partyProvider(mePuuid), (_, _) {});
    expect(
      (await container.read(partyProvider(mePuuid).future)).party!.id,
      beforeId,
    );
    await tester.tap(find.text('join test'));
    await settle(tester);
    expect(await pending, isTrue);
    expect(
      (await container.read(partyProvider(mePuuid).future)).party!.id,
      afterId,
    );
    verify(() => env.pvp.partyJoinByCode(mePuuid, 'ABC123')).called(1);
    sub.close();
    await unmount(tester);
  });
}
