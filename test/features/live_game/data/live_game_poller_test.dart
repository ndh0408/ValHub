import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';
import 'package:valvn/features/live_game/data/live_game_poller.dart';

import '../live_game_test_env.dart';

void main() {
  late LiveTestEnv env;
  late LiveGamePoller poller;

  setUpAll(registerLiveFallbacks);

  setUp(() async {
    env = await LiveTestEnv.create();
    poller = LiveGamePoller(api: env.api, puuid: me, clock: env.clock);
  });

  test('G-1 404 → game not running, nothing else is called', () async {
    final s = await poller.poll();
    expect(s.phase, LivePhase.notRunning);
    expect(s.match, isNull);
    verify(() => env.api.gameSession(me)).called(1);
    verifyNever(() => env.api.pregamePlayer(any()));
    verifyNever(() => env.api.coreGamePlayer(any()));
    verifyNever(() => env.api.partyPlayer(any()));
  });

  test('MENUS + matchmaking party → queueing with the entry time', () async {
    env
      ..loop = 'MENUS'
      ..party = partyJson();
    final s = await poller.poll();
    expect(s.phase, LivePhase.queueing);
    expect(s.queueEntryTime, DateTime.utc(2026, 9, 28, 11, 58, 28));
    verifyNever(() => env.api.pregamePlayer(any()));
  });

  test('MENUS without a party / idle party → lobby', () async {
    env.loop = 'MENUS';
    expect((await poller.poll()).phase, LivePhase.lobby);
    env.party = partyJson(matchmaking: false);
    expect((await poller.poll()).phase, LivePhase.lobby);
  });

  test('a failing party lookup is ignored, needs-login is not', () async {
    env.loop = 'MENUS';
    when(() => env.api.partyPlayer(any()))
        .thenThrow(const TransientException(status: 503));
    expect((await poller.poll()).phase, LivePhase.lobby);
    when(() => env.api.partyPlayer(any()))
        .thenThrow(const NeedsLoginException());
    await expectLater(poller.poll(), throwsA(isA<NeedsLoginException>()));
  });

  test('PREGAME → agent select from G-2 / G-3', () async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    final s = await poller.poll();
    expect(s.phase, LivePhase.pregame);
    expect(s.matchId, pregameMatchId);
    expect(s.match!.players, hasLength(3));
    verifyNever(() => env.api.coreGamePlayer(any()));
  });

  test('INGAME → running match from G-8 / G-9', () async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson();
    final s = await poller.poll();
    expect(s.phase, LivePhase.ingame);
    expect(s.matchId, liveMatchId);
    verifyNever(() => env.api.pregamePlayer(any()));
  });

  test('PREGAME that already turned into a match → core game', () async {
    env
      ..loop = 'PREGAME'
      ..core = coreMatchJson();
    final s = await poller.poll();
    expect(s.phase, LivePhase.ingame);
  });

  test('a match that ends is remembered for the final scoreboard', () async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson();
    final inGame = await poller.poll();
    env
      ..loop = 'MENUS'
      ..core = null;
    final after = await poller.poll(previous: inGame);
    expect(after.phase, LivePhase.lobby);
    expect(after.ended?.matchId, liveMatchId);
    expect(after.ended?.mapId, ascent);

    // Kept on the next polls…
    env.clock.advance(const Duration(minutes: 30));
    final later = await poller.poll(previous: after);
    expect(later.ended, after.ended);

    // …for an hour.
    env.clock.advance(const Duration(minutes: 31));
    expect((await poller.poll(previous: later)).ended, isNull);
  });

  test('game closed right after the match also counts as ended', () async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson();
    final inGame = await poller.poll();
    env
      ..loop = null
      ..core = null;
    final after = await poller.poll(previous: inGame);
    expect(after.phase, LivePhase.notRunning);
    expect(after.ended?.matchId, liveMatchId);
  });

  test('a dodged agent select is not an ended match', () async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    final pregame = await poller.poll();
    env
      ..loop = 'MENUS'
      ..pregame = null;
    final after = await poller.poll(previous: pregame);
    expect(after.phase, LivePhase.lobby);
    expect(after.ended, isNull);
  });

  test('POST_GAME core game → ended, out of the match', () async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson(state: 'POST_GAME');
    final s = await poller.poll();
    expect(s.phase, LivePhase.lobby);
    expect(s.match, isNull);
    expect(s.ended?.matchId, liveMatchId);
    env.clock.advance(const Duration(seconds: 5));
    final again = await poller.poll(previous: s);
    expect(again.ended!.endedAt, s.ended!.endedAt);
  });

  test('a new match clears the ended one', () async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson();
    final inGame = await poller.poll();
    env
      ..loop = 'MENUS'
      ..core = null;
    final ended = await poller.poll(previous: inGame);
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    final next = await poller.poll(previous: ended);
    expect(next.phase, LivePhase.pregame);
    expect(next.ended, isNull);
  });

  test('session errors are rethrown', () async {
    env.sessionError = const TransientException(status: 503);
    await expectLater(poller.poll(), throwsA(isA<TransientException>()));
  });

  test('match calls answering 404 mid-way fall back to the lobby', () async {
    env.loop = 'PREGAME';
    when(() => env.api.pregamePlayer(any()))
        .thenAnswer((_) async => {'MatchID': pregameMatchId});
    // G-3 404 (match just dissolved), no core game either.
    final s = await poller.poll();
    expect(s.phase, LivePhase.lobby);
  });

  test('fetchLiveParty follows CurrentPartyID', () async {
    env.party = partyJson();
    final p = await fetchLiveParty(env.api, me);
    expect(p?.members, {me, mate});
    env.party = null;
    expect(await fetchLiveParty(env.api, me), isNull);
  });
}
