import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/profile/data/match_filter.dart';
import 'package:valvn/features/profile/providers/profile_providers.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
  });

  ProviderContainer container() =>
      ProviderContainer.test(overrides: env.overrides, retry: (_, _) => null);

  group('playerIdentityProvider', () {
    test('reads P-8 and caches the card on the account (A4)', () async {
      final c = container();
      c.listen(playerIdentityProvider(me), (_, _) {});
      final identity = await c.read(playerIdentityProvider(me).future);
      expect(identity.cardId, cardId);
      expect(identity.titleId, isNull);
      await pumpEventQueue();
      expect(c.read(accountProvider(me))?.cardId, cardId);
    });

    test('is only available for signed-in accounts', () async {
      final c = container();
      c.listen(playerIdentityProvider(stranger), (_, _) {});
      await expectLater(
        c.read(playerIdentityProvider(stranger).future),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => env.api.playerLoadout(any()));
    });

    test('Riot errors propagate', () async {
      when(() => env.api.playerLoadout(any()))
          .thenThrow(const NeedsLoginException(puuid: me));
      final c = container();
      c.listen(playerIdentityProvider(me), (_, _) {});
      await expectLater(
        c.read(playerIdentityProvider(me).future),
        throwsA(isA<NeedsLoginException>()),
      );
    });
  });

  group('matchFilterProvider', () {
    test('queue and map are independent and kept per player', () {
      final c = container();
      c.read(matchFilterProvider(me).notifier).setQueue('competitive');
      c
          .read(matchFilterProvider(me).notifier)
          .setMap('/Game/Maps/Ascent/Ascent');
      expect(
        c.read(matchFilterProvider(me)),
        const MatchFilter(
          queue: 'competitive',
          mapUrl: '/Game/Maps/Ascent/Ascent',
        ),
      );
      c.read(matchFilterProvider(me).notifier).setQueue(null);
      expect(c.read(matchFilterProvider(me)).mapUrl, isNotNull);
      expect(c.read(matchFilterProvider(enemy1)), const MatchFilter());
    });
  });

  group('playerSnapshotProvider', () {
    test('card, title and level from the latest match', () async {
      env.historyByQueue[null] = {
        'Subject': enemy1,
        'Total': 2,
        'History': [
          {'MatchID': 'ffffffff-0000-4000-8000-000000000000', 'QueueID': ''},
          {'MatchID': compMatch, 'QueueID': 'competitive'},
        ],
      };
      final c = container();
      c.listen(playerSnapshotProvider(enemy1), (_, _) {});
      final snap = await c.read(playerSnapshotProvider(enemy1).future);
      // The first match has no fixture (error) → the next one is used.
      expect(snap.lastMatchId, compMatch);
      expect(snap.cardId, '9fb348bc-41a0-91ad-8a3e-818035c4e561');
    });

    test('empty without public matches', () async {
      env.historyByQueue[null] = {'Subject': enemy1, 'History': <Object>[]};
      final c = container();
      c.listen(playerSnapshotProvider(enemy1), (_, _) {});
      final snap = await c.read(playerSnapshotProvider(enemy1).future);
      expect(snap.cardId, isNull);
      expect(snap.accountLevel, isNull);
    });
  });
}
