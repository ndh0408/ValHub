import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart';

import '../community_test_env.dart';

const _partyId = 'aaaaaaaa-0000-0000-0000-000000000001';

JsonMap _party({String code = '', bool open = false}) => {
  'ID': _partyId,
  'Members': [
    {'Subject': mePuuid, 'IsOwner': true},
  ],
  'State': 'DEFAULT',
  'Accessibility': open ? 'OPEN' : 'CLOSED',
  'InviteCode': code,
};

void main() {
  late CommunityTestEnv env;
  setUp(() async {
    env = await CommunityTestEnv.create();
    when(() => env.pvp.gameSession(any()))
        .thenAnswer((_) async => {'loopState': 'MENUS'});
  });

  Future<void> runAction(
    WidgetTester tester,
    Future<Object?> Function(WidgetRef) action,
    Future<void> Function(Future<Object?>, ValueNotifier<bool>) check, {
    Future<void> Function(ProviderContainer)? prepare,
  }) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    late Future<Object?> pending;
    await pumpCommunity(
      tester,
      env,
      Scaffold(
        body: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (_, show, _) => show
              ? Consumer(
                  builder: (context, ref, _) => TextButton(
                    onPressed: () => pending = action(ref).then(
                      (value) => value,
                      onError: (Object error, StackTrace _) => error,
                    ),
                    child: const Text('action'),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
    if (prepare != null) {
      await prepare(
        ProviderScope.containerOf(tester.element(find.byType(Consumer))),
      );
    }
    await tester.tap(find.text('action'));
    await settle(tester);
    await check(pending, visible);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  }

  testWidgets('closed widget stops code generation after the party read', (
    tester,
  ) async {
    final response = Completer<JsonMap>();
    when(() => env.pvp.partyPlayer(any())).thenAnswer((_) => response.future);
    when(() => env.pvp.party(any(), any())).thenAnswer((_) async => _party());
    await runAction(tester, (ref) => currentPartyCode(ref, mePuuid), (
      pending,
      visible,
    ) async {
      visible.value = false;
      await settle(tester);
      response.complete({'Subject': mePuuid, 'CurrentPartyID': _partyId});
      await settle(tester);
      expect(await pending, isNull);
      verifyNever(
        () => env.pvp.partySetAccessibility(
          any(),
          any(),
          open: any(named: 'open'),
        ),
      );
      verifyNever(() => env.pvp.partyGenerateInviteCode(any(), any()));
    });
  });

  testWidgets('a closed party gets a code without being opened', (
    tester,
  ) async {
    when(
      () => env.pvp.partyPlayer(any()),
    ).thenAnswer((_) async => {'Subject': mePuuid, 'CurrentPartyID': _partyId});
    when(() => env.pvp.party(any(), any())).thenAnswer((_) async => _party());
    when(() => env.pvp.partyGenerateInviteCode(any(), any()))
        .thenAnswer((_) async => _party(code: 'AB12CD'));
    await runAction(tester, (ref) => currentPartyCode(ref, mePuuid), (
      pending,
      visible,
    ) async {
      expect(await pending, 'AB12CD');
      verify(() => env.pvp.partyGenerateInviteCode(mePuuid, _partyId))
          .called(1);
      verifyNever(
        () => env.pvp.partySetAccessibility(
          any(),
          any(),
          open: any(named: 'open'),
        ),
      );
    });
  });

  testWidgets(
    'created post response is returned safely after the widget closes',
    (tester) async {
      final response = Completer<void>();
      late ProviderContainer container;
      env.server
        ..json('GET /v1/lfg/mine', null)
        ..json('POST /v1/lfg', lfgJson('created'))
        ..hold('POST /v1/lfg', response);
      await runAction(
        tester,
        (ref) => createLfgPost(
          ref,
          puuid: mePuuid,
          region: 'ap',
          mode: 'competitive',
          partyCode: 'ABC123',
          slots: 2,
        ),
        (pending, visible) async {
          expect(env.server.calls('POST /v1/lfg'), hasLength(1));
          visible.value = false;
          await settle(tester);
          response.complete();
          await settle(tester);
          final result = await pending;
          expect(result, isA<LfgPost>());
          expect((result as LfgPost).id, 'created');
          expect(
            container.read(myLfgProvider(mePuuid)).requireValue?.id,
            'created',
          );
          expect(env.server.calls('GET /v1/lfg/mine'), hasLength(1));
        },
        prepare: (c) async {
          container = c;
          final load = c.read(myLfgProvider(mePuuid).future);
          await settle(tester);
          await load;
        },
      );
    },
  );

  testWidgets('delete response does not access a closed widget ref', (
    tester,
  ) async {
    final response = Completer<void>();
    late ProviderContainer container;
    env.server
      ..json('GET /v1/lfg/mine', lfgJson('mine'))
      ..json('DELETE /v1/lfg/mine', null, status: 204)
      ..hold('DELETE /v1/lfg/mine', response);
    await runAction(
      tester,
      (ref) => removeLfgPost(
        ref,
        puuid: mePuuid,
        post: LfgPost.fromJson(lfgJson('mine'))!,
      ),
      (pending, visible) async {
        expect(env.server.calls('DELETE /v1/lfg/mine'), hasLength(1));
        visible.value = false;
        await settle(tester);
        response.complete();
        await settle(tester);
        expect(await pending, isNull);
        expect(container.read(myLfgProvider(mePuuid)).requireValue, isNull);
        expect(env.server.calls('GET /v1/lfg/mine'), hasLength(1));
      },
      prepare: (c) async {
        container = c;
        final load = c.read(myLfgProvider(mePuuid).future);
        await settle(tester);
        await load;
      },
    );
  });
}
