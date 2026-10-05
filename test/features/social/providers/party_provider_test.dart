import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/core/xmpp/xmpp_models.dart';
import 'package:valvn/features/social/data/party_models.dart';
import 'package:valvn/features/social/providers/party_providers.dart';

import '../social_test_env.dart';

void main() {
  setUpAll(registerSocialFallbacks);

  late SocialTestEnv env;
  late ProviderContainer container;

  setUp(() async {
    env = await SocialTestEnv.create();
    addTearDown(env.xmpp.dispose);
    container = ProviderContainer.test(
      overrides: env.overrides,
      retry: (_, _) => null, // Assert errors directly, without backoff retries.
    );
  });

  Future<PartyView> read() {
    container.listen(partyProvider(me), (_, _) {});
    return container.read(partyProvider(me).future);
  }

  test('404 on both party and session means the game is not running', () async {
    when(() => env.api.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    when(() => env.api.gameSession(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    final v = await read();
    expect(v.gameRunning, isFalse);
    expect(v.party, isNull);
    verifyNever(() => env.api.party(any(), any()));
  });

  test('missing party does not override a verified running session', () async {
    when(() => env.api.gameSession(any()))
        .thenAnswer((_) async => {'loopState': 'MENUS'});
    when(() => env.api.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    final v = await read();
    expect(v.gameRunning, isTrue);
    expect(v.loopState, LoopState.menus);
    expect(v.party, isNull);
    expect(v.invites, isEmpty);
    verifyNever(() => env.api.party(any(), any()));
  });

  test('missing party with failed session preserves the real error', () async {
    when(() => env.api.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    when(() => env.api.gameSession(any()))
        .thenAnswer((_) async => throw const TransientException());
    await expectLater(read(), throwsA(isA<TransientException>()));
    verifyNever(() => env.api.party(any(), any()));
  });

  test('combines player, party and session loop state', () async {
    env.serveParty(
      partyJson(),
      loopState: 'PREGAME',
      invites: [
        {'PartyID': otherPartyId, 'InvitedBySubject': stranger},
        {'PartyID': partyId}, // our own party is not an invite
        {'garbage': true},
      ],
    );
    final v = await read();
    expect(v.gameRunning, isTrue);
    expect(v.party!.id, partyId);
    expect(v.loopState, LoopState.pregame);
    expect(v.inMatch, isTrue);
    expect(v.invites.single.partyId, otherPartyId);
    expect(v.invites.single.invitedBy, stranger);
  });

  test('a failing session call is not an error', () async {
    env.serveParty(partyJson());
    when(() => env.api.gameSession(any()))
        .thenAnswer((_) async => throw const TransientException());
    final v = await read();
    expect(v.loopState, LoopState.unknown);
    expect(v.party, isNotNull);
  });

  test('mutations apply the returned party', () async {
    env.serveParty(partyJson());
    await read();
    final notifier = container.read(partyProvider(me).notifier);
    await notifier.generateCode();
    expect(
      container.read(partyProvider(me)).requireValue.party!.inviteCode,
      'NEW123',
    );
    await notifier.setReady(false);
    verify(() => env.api.partySetReady(me, partyId, ready: false)).called(1);
  });

  test('dismissed invites stay hidden across refreshes', () async {
    env.serveParty(
      partyJson(),
      invites: [
        {'PartyID': otherPartyId},
      ],
    );
    final v = await read();
    final notifier = container.read(partyProvider(me).notifier)
      ..dismissInvite(v.invites.single);
    expect(container.read(partyProvider(me)).requireValue.invites, isEmpty);
    await notifier.refresh();
    expect(container.read(partyProvider(me)).requireValue.invites, isEmpty);
  });

  test('mutation errors propagate to the caller', () async {
    env.serveParty(partyJson());
    when(() => env.api.partyJoinMatchmaking(any(), any())).thenAnswer(
      (_) async => throw const RiotApiException(400, errorCode: 'X'),
    );
    await read();
    await expectLater(
      container.read(partyProvider(me).notifier).startMatchmaking(),
      throwsA(isA<RiotApiException>()),
    );
  });

  for (final action in ['ready', 'join', 'accept', 'kick', 'leave']) {
    test(
      '$action completion after disposal does not read state or refetch',
      () async {
        env.serveParty(partyJson());
        await read();
        final notifier = container.read(partyProvider(me).notifier);
        final response = Completer<JsonMap>();
        when(
          () => env.api.partySetReady(any(), any(), ready: any(named: 'ready')),
        ).thenAnswer((_) => response.future);
        when(() => env.api.partyJoinByCode(any(), any()))
            .thenAnswer((_) => response.future);
        when(() => env.api.partyAcceptInvite(any(), any()))
            .thenAnswer((_) => response.future);
        when(
          () =>
              env.api.partyRemovePlayer(any(), subject: any(named: 'subject')),
        ).thenAnswer((_) => response.future);
        final pending = switch (action) {
          'ready' => notifier.setReady(true),
          'join' => notifier.joinByCode('XYZ789'),
          'accept' => notifier.acceptInvite(PartyInvite(partyId: otherPartyId)),
          'kick' => notifier.kick(mate),
          _ => notifier.leave(),
        };
        clearInteractions(env.api);
        container.dispose();
        response.complete(partyJson());
        await expectLater(pending, completes);
        verifyNever(() => env.api.partyPlayer(any()));
        verifyNever(() => env.api.party(any(), any()));
      },
    );
  }
}
