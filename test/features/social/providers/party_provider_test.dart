import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
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
    container = ProviderContainer.test(overrides: env.overrides);
  });

  Future<PartyView> read() {
    container.listen(partyProvider(me), (_, _) {});
    return container.read(partyProvider(me).future);
  }

  test('404 on G-12 means the game is not running', () async {
    when(() => env.api.partyPlayer(any()))
        .thenAnswer((_) async => throw const NotFoundException());
    final v = await read();
    expect(v.gameRunning, isFalse);
    expect(v.party, isNull);
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
}
