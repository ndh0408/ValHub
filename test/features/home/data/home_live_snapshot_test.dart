import 'package:valvn/features/live_game/data/live_game_logic.dart';

import '../../../helpers/l10n.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/features/home/data/home_live.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';

import '../../live_game/live_game_test_env.dart';

final _now = DateTime.utc(2026, 9, 28, 12);

LiveGameState _state(LivePhase phase, {LiveMatch? match, LiveParty? party}) =>
    LiveGameState(phase: phase, receivedAt: _now, match: match, party: party);

LiveMatch _pregame({String agent = '', String state = '', num ns = 42e9}) =>
    LiveMatch.fromPregame(
      pregameMatchJson(myAgent: agent, myState: state, phaseNs: ns),
      receivedAt: _now,
    )!;

LiveMatch _core() =>
    LiveMatch.fromCoreGame(coreMatchJson(), selfPuuid: me, receivedAt: _now)!;

void main() {
  final db = liveTestContent();

  test('nothing to show when the game is not running or in the lobby', () {
    expect(
      homeLiveSnapshotOf(_state(LivePhase.notRunning), db, self: me),
      isNull,
    );
    expect(homeLiveSnapshotOf(_state(LivePhase.lobby), db, self: me), isNull);
  });

  test('the match just played stays 20 minutes, then the card goes', () {
    final ended = LiveGameState(
      phase: LivePhase.lobby,
      receivedAt: _now,
      ended: LiveEndedMatch(
        matchId: 'm1',
        endedAt: _now,
        mapId: '/Game/Maps/Ascent/Ascent',
        queueId: 'competitive',
      ),
    );
    final snap = homeLiveSnapshotOf(
      ended,
      db,
      self: me,
      now: _now.add(const Duration(minutes: 5)),
    )!;
    expect(snap.isEnded, isTrue);
    expect(snap.matchId, 'm1');
    expect(
      homeLiveSnapshotOf(
        ended,
        db,
        self: me,
        now: _now.add(kHomeEndedShownFor + const Duration(minutes: 1)),
      ),
      isNull,
    );
  });

  test('queueing carries the queue entry time and the mode', () {
    final party = LiveParty.fromJson(partyJson())!;
    final snap = homeLiveSnapshotOf(
      _state(LivePhase.queueing, party: party),
      db,
      self: me,
    )!;
    expect(snap.phase, LivePhase.queueing);
    expect(snap.queueEntryTime, DateTime.utc(2026, 9, 28, 11, 58, 28));
    expect(
      liveModeLabel(tl, db, queueId: snap.queueId, modeId: snap.modeId),
      db.queueName(tl, 'competitive'),
    );
    expect(snap.mapName, isNull);
    expect(snap.phaseEndsAt, isNull);
  });

  test('queueing without a party still shows the card', () {
    final snap = homeLiveSnapshotOf(_state(LivePhase.queueing), db, self: me)!;
    expect(snap.queueEntryTime, isNull);
  });

  test('pregame carries the timer, my agent and hover vs lock', () {
    final hover = homeLiveSnapshotOf(
      _state(
        LivePhase.pregame,
        match: _pregame(agent: jett, state: 'selected'),
      ),
      db,
      self: me,
    )!;
    expect(hover.phase, LivePhase.pregame);
    expect(hover.myAgentId, jett);
    expect(hover.myAgentLocked, isFalse);
    expect(hover.phaseEndsAt, _now.add(const Duration(seconds: 42)));
    expect(hover.mapName, db.mapByUrl(ascent)?.displayName);

    final locked = homeLiveSnapshotOf(
      _state(
        LivePhase.pregame,
        match: _pregame(agent: jett, state: 'locked'),
      ),
      db,
      self: me,
    )!;
    expect(locked.myAgentLocked, isTrue);

    final none = homeLiveSnapshotOf(
      _state(LivePhase.pregame, match: _pregame()),
      db,
      self: me,
    )!;
    expect(none.myAgentId, isNull);
    expect(none.myAgentLocked, isFalse);
  });

  test('ingame carries the map, the mode label and the match id', () {
    final snap = homeLiveSnapshotOf(
      _state(LivePhase.ingame, match: _core()),
      db,
      self: me,
    )!;
    expect(snap.phase, LivePhase.ingame);
    expect(snap.mapName, db.mapByUrl(ascent)?.displayName);
    expect(
      liveModeLabel(tl, db, queueId: snap.queueId, modeId: snap.modeId),
      db.queueName(tl, 'competitive'),
    );
    expect(snap.matchId, liveMatchId);
    expect(snap.phaseEndsAt, isNull);
    expect(snap.myAgentId, isNull);
  });

  test('a custom game shows its mode name', () {
    final core = LiveMatch.fromCoreGame(
      {
        ...coreMatchJson(),
        'ProvisioningFlow': 'CustomGame',
        'MatchmakingData': {'QueueID': ''},
      },
      selfPuuid: me,
      receivedAt: _now,
    )!;
    final snap = homeLiveSnapshotOf(
      _state(LivePhase.ingame, match: core),
      db,
      self: me,
    )!;
    expect(
      liveModeLabel(tl, db, queueId: snap.queueId, modeId: snap.modeId),
      isNotEmpty,
    );
  });

  test('an unknown map or agent does not crash', () {
    final core = LiveMatch.fromCoreGame(
      {...coreMatchJson(), 'MapID': '/Game/Maps/Future/Future'},
      selfPuuid: me,
      receivedAt: _now,
    )!;
    final a = homeLiveSnapshotOf(
      _state(LivePhase.ingame, match: core),
      ContentDb.empty(),
      self: me,
    )!;
    expect(a.mapName, isNull);
    expect(a.mapSplash, isNull);
    final b = homeLiveSnapshotOf(
      _state(
        LivePhase.pregame,
        match: _pregame(
          agent: 'ffffffff-0000-4000-8000-000000000000',
          state: 'selected',
        ),
      ),
      ContentDb.empty(),
      self: me,
    )!;
    expect(b.myAgentId, 'ffffffff-0000-4000-8000-000000000000');
  });

  test('a finished match is not shown', () {
    final done = LiveMatch.fromCoreGame(
      coreMatchJson(state: 'POST_GAME'),
      selfPuuid: me,
      receivedAt: _now,
    )!;
    expect(
      homeLiveSnapshotOf(_state(LivePhase.ingame, match: done), db, self: me),
      isNull,
    );
  });
}
