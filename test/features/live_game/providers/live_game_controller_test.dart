import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';
import 'package:valvn/features/live_game/providers/live_game_providers.dart';

import '../live_game_test_env.dart';

void main() {
  late LiveTestEnv env;

  setUpAll(registerLiveFallbacks);

  setUp(() async {
    env = await LiveTestEnv.create();
  });

  /// Runs [body] with a container that is disposed before the test ends
  /// (its poll timers must not outlive the test).
  Future<void> withContainer(
    Future<void> Function(ProviderContainer c) body,
  ) async {
    final c = ProviderContainer(
      overrides: env.overrides,
      retry: (_, _) => null,
    );
    try {
      await body(c);
    } finally {
      c.dispose();
    }
  }

  Future<void> advance(WidgetTester tester, Duration d) async {
    await tester.pump(d);
    await tester.pump();
  }

  void verifyNoMutation() {
    verifyNever(() => env.api.pregameSelectAgent(any(), any(), any()));
    verifyNever(() => env.api.pregameLockAgent(any(), any(), any()));
    verifyNever(() => env.api.pregameQuit(any(), any()));
    verifyNever(() => env.api.coreGameDisassociate(any(), any()));
  }

  testWidgets('polls every 20 s, every 4 s while a sheet is open', (
    tester,
  ) async {
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      verify(() => env.api.gameSession(me)).called(1);
      final controller = c.read(liveGameProvider(me).notifier);
      expect(controller.interval, kLivePollSlow);
      expect(controller.nextPollAt.value, env.clock.now().add(kLivePollSlow));

      await advance(tester, const Duration(seconds: 19));
      verifyNever(() => env.api.gameSession(me));
      await advance(tester, const Duration(seconds: 2));
      verify(() => env.api.gameSession(me)).called(1);

      // Opening the sheet polls at once, then every 4 s.
      c.read(liveGameSheetOpenProvider.notifier).open();
      await tester.pump();
      verify(() => env.api.gameSession(me)).called(1);
      expect(controller.interval, kLivePollFast);
      await advance(tester, const Duration(seconds: 4));
      verify(() => env.api.gameSession(me)).called(1);
      await advance(tester, const Duration(seconds: 4));
      verify(() => env.api.gameSession(me)).called(1);

      // Closed again: back to the slow cadence.
      c.read(liveGameSheetOpenProvider.notifier).close();
      await tester.pump();
      await advance(tester, const Duration(seconds: 10));
      verifyNever(() => env.api.gameSession(me));
      await advance(tester, const Duration(seconds: 11));
      verify(() => env.api.gameSession(me)).called(1);
      verifyNoMutation();
    });
  });

  testWidgets('never polls in the background; polls on return', (tester) async {
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      verify(() => env.api.gameSession(me)).called(1);

      env.foreground.foreground = false;
      await tester.pump();
      expect(c.read(liveGameProvider(me).notifier).nextPollAt.value, isNull);
      await advance(tester, const Duration(minutes: 2));
      verifyNever(() => env.api.gameSession(me));

      env.foreground.foreground = true;
      await tester.pump();
      verify(() => env.api.gameSession(me)).called(1);
    });
  });

  testWidgets('a failed poll keeps the last state visible', (tester) async {
    env.loop = 'MENUS';
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      expect(c.read(liveGameProvider(me)).value?.phase, LivePhase.lobby);

      env.sessionError = const TransientException(status: 503);
      await advance(tester, kLivePollSlow);
      final value = c.read(liveGameProvider(me));
      expect(value.hasError, isTrue);
      expect(value.value?.phase, LivePhase.lobby);

      // Recovers on the next poll.
      env.sessionError = null;
      await advance(tester, kLivePollSlow);
      expect(c.read(liveGameProvider(me)).hasError, isFalse);
    });
  });

  testWidgets('needs-login stops polling', (tester) async {
    env.sessionError = const NeedsLoginException(puuid: me);
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      expect(c.read(liveGameProvider(me)).error, isA<NeedsLoginException>());
      expect(c.read(liveGameProvider(me).notifier).nextPollAt.value, isNull);
      clearInteractions(env.api);
      await advance(tester, const Duration(minutes: 5));
      verifyNever(() => env.api.gameSession(any()));
    });
  });

  testWidgets('refresh joins a running poll', (tester) async {
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      clearInteractions(env.api);
      final controller = c.read(liveGameProvider(me).notifier);
      final a = controller.refresh();
      final b = controller.refresh();
      await tester.pump();
      await Future.wait([a, b]);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      // One poll, then exactly one follow-up for the second request.
      verify(() => env.api.gameSession(me)).called(2);
    });
  });

  testWidgets('hover (G-4) and lock (G-5) update the match at once', (
    tester,
  ) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      final controller = c.read(liveGameProvider(me).notifier);

      await controller.hoverAgent(reyna);
      verify(() => env.api.pregameSelectAgent(me, pregameMatchId, reyna))
          .called(1);
      var self = c.read(liveGameProvider(me)).value!.match!.player(me)!;
      expect(self.characterId, reyna);
      expect(self.selection, AgentSelection.selected);

      // Riot answers the lock with the pregame match: it is used as is.
      when(() => env.api.pregameLockAgent(any(), any(), any())).thenAnswer(
        (_) async => pregameMatchJson(myAgent: reyna, myState: 'locked'),
      );
      await controller.lockAgent(reyna);
      verify(() => env.api.pregameLockAgent(me, pregameMatchId, reyna))
          .called(1);
      self = c.read(liveGameProvider(me)).value!.match!.player(me)!;
      expect(self.isLocked, isTrue);
      verifyNever(() => env.api.pregameQuit(any(), any()));
    });
  });

  testWidgets('agent actions outside agent select fail', (tester) async {
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      await expectLater(
        c.read(liveGameProvider(me).notifier).lockAgent(jett),
        throwsA(isA<NotFoundException>()),
      );
      verifyNoMutation();
    });
  });

  testWidgets('quit: G-6 in agent select, G-11 in a match', (tester) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      await c
          .read(liveGameProvider(me).notifier)
          .quitMatch(matchId: pregameMatchId, pregame: true);
      verify(() => env.api.pregameQuit(me, pregameMatchId)).called(1);
      verifyNever(() => env.api.coreGameDisassociate(any(), any()));

      env
        ..loop = 'INGAME'
        ..pregame = null
        ..core = coreMatchJson();
      await c.read(liveGameProvider(me).notifier).refresh();
      await tester.pump();
      expect(c.read(liveGameProvider(me)).value?.phase, LivePhase.ingame);
      await c
          .read(liveGameProvider(me).notifier)
          .quitMatch(matchId: liveMatchId, pregame: false);
      verify(() => env.api.coreGameDisassociate(me, liveMatchId)).called(1);
    });
  });

  testWidgets('quit confirmed for agent select never abandons the started '
      'match', (tester) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      // Agent select ends while the dodge warning is open.
      env
        ..loop = 'INGAME'
        ..pregame = null
        ..core = coreMatchJson();
      await c.read(liveGameProvider(me).notifier).refresh();
      await tester.pump();
      await expectLater(
        c
            .read(liveGameProvider(me).notifier)
            .quitMatch(matchId: pregameMatchId, pregame: true),
        throwsA(isA<MatchChangedException>()),
      );
      verifyNever(() => env.api.coreGameDisassociate(any(), any()));
      verifyNever(() => env.api.pregameQuit(any(), any()));
    });
  });

  testWidgets('polling through every phase never sends a mutation', (
    tester,
  ) async {
    await withContainer((c) async {
      c.listen(liveGameProvider(me), (_, _) {});
      await tester.pump();
      for (final step in <void Function()>[
        () => env
          ..loop = 'MENUS'
          ..party = partyJson(),
        () => env.pregame = pregameMatchJson(),
        () => env..loop = 'PREGAME',
        () => env
          ..loop = 'INGAME'
          ..pregame = null
          ..core = coreMatchJson(),
        () => env
          ..loop = 'MENUS'
          ..core = null,
      ]) {
        step();
        await advance(tester, kLivePollSlow);
      }
      expect(c.read(liveGameProvider(me)).value?.ended?.matchId, liveMatchId);
      verifyNoMutation();
    });
  });
}
