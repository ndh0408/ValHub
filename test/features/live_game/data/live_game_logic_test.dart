import '../../../helpers/l10n.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/xmpp/xmpp.dart';
import 'package:valvn/features/live_game/data/live_game_logic.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';
import 'package:valvn/features/live_game/live_game_overlay_host.dart';

import '../live_game_test_env.dart';

void main() {
  final at = DateTime.utc(2026, 9, 28, 12);
  final db = liveTestContent();
  LiveMatch pregame({String myAgent = '', String myState = ''}) =>
      LiveMatch.fromPregame(
        pregameMatchJson(myAgent: myAgent, myState: myState),
        receivedAt: at,
      )!;
  final core = LiveMatch.fromCoreGame(
    coreMatchJson(),
    selfPuuid: me,
    receivedAt: at,
  )!;

  group('splitTeams', () {
    test('ally team first with self on top, enemies apart', () {
      final t = splitTeams(core, mate);
      expect(t.isFreeForAll, isFalse);
      expect(t.ally.map((p) => p.subject), [mate, me]);
      expect(t.enemy.map((p) => p.subject), [enemy1, enemy2]);
    });

    test('free-for-all when every player has their own team', () {
      final json = coreMatchJson();
      for (final p in json['Players']! as List<Object?>) {
        final m = p! as Map<String, Object?>;
        m['TeamID'] = m['Subject'];
      }
      final ffa = LiveMatch.fromCoreGame(json, selfPuuid: me, receivedAt: at)!;
      final t = splitTeams(ffa, me);
      expect(t.isFreeForAll, isTrue);
      expect(t.ally, hasLength(4));
      expect(t.ally.first.subject, me);
      expect(t.enemy, isEmpty);
    });
  });

  test('partyGroups only badges parties with two players in the match', () {
    final groups = partyGroups(
      subjects: [me, mate, enemy1, enemy2, 'x'],
      partyOf: {me: 'p1', mate: 'p1', enemy1: 'p2', enemy2: 'p3', 'x': 'p3'},
    );
    expect(groups, {me: 0, mate: 0, enemy2: 1, 'x': 1});
    expect(partyGroups(subjects: [me], partyOf: {me: 'p1'}), isEmpty);
  });

  group('liveScoreOf', () {
    test('fresh in-match presence', () {
      expect(liveScoreOf(scorePresence(at), now: at), const LiveScore(8, 4));
      expect(liveScoreOf(scorePresence(at), now: at)!.text(tl), '8 – 4');
    });

    test('hidden when stale, 0 – 0, outside a match or absent', () {
      expect(
        liveScoreOf(scorePresence(at), now: at.add(const Duration(minutes: 3))),
        isNull,
      );
      expect(
        liveScoreOf(scorePresence(at, ally: 0, enemy: 0), now: at),
        isNull,
      );
      expect(
        liveScoreOf(scorePresence(at, loop: LoopState.menus), now: at),
        isNull,
      );
      expect(liveScoreOf(null, now: at), isNull);
    });
  });

  group('labels', () {
    test('mode label: queue, custom mode, fallback', () {
      expect(liveModeLabel(db, queueId: 'competitive'), 'Thi đấu xếp hạng');
      expect(
        liveModeLabel(
          db,
          queueId: '',
          modeId: '/Game/GameModes/Bomb/BombGameMode.BombGameMode_C',
        ),
        'Thông thường',
      );
      expect(liveModeLabel(db), db.queueName(''));
      expect(liveMapName(db, ascent), 'Ascent');
      expect(liveMapName(db, '/Game/Maps/Nope'), isNull);
    });

    test('current game status lines (SUMMARY §9.9)', () {
      String text(LiveGameState s, {LiveScore? score}) =>
          currentGameStatusText(tl, s, db, now: at, score: score);
      expect(
        text(LiveGameState(phase: LivePhase.notRunning, receivedAt: at)),
        'Không trong trận',
      );
      expect(
        text(LiveGameState(phase: LivePhase.lobby, receivedAt: at)),
        'Đang ở sảnh chờ',
      );
      expect(
        text(
          LiveGameState(
            phase: LivePhase.queueing,
            receivedAt: at,
            party: LiveParty.fromJson(partyJson()),
          ),
        ),
        'Đang tìm trận · 01:32',
      );
      expect(
        text(LiveGameState(phase: LivePhase.queueing, receivedAt: at)),
        'Đang tìm trận',
      );
      expect(
        text(
          LiveGameState(
            phase: LivePhase.pregame,
            receivedAt: at,
            match: pregame(),
          ),
        ),
        'Đang chọn đặc vụ · Ascent',
      );
      final ingame = LiveGameState(
        phase: LivePhase.ingame,
        receivedAt: at,
        match: core,
      );
      expect(text(ingame), 'Đang đấu · Ascent');
      expect(
        text(ingame, score: const LiveScore(8, 4)),
        'Đang đấu · Ascent · 8 – 4',
      );
      // Unknown map (content missing): no dangling separator.
      expect(
        currentGameStatusText(tl, ingame, ContentDb.empty(), now: at),
        'Đang đấu',
      );
    });
  });

  group('agentTileState', () {
    const owned = {jett, sova, sage, reyna};

    test('available, taken by a teammate, not owned', () {
      final m = pregame();
      AgentTileState s(String id) =>
          agentTileState(agentId: id, match: m, self: me, owned: owned);
      expect(s(jett), AgentTileState.available);
      expect(s(sova), AgentTileState.taken); // mate locked Sova
      expect(s(sage), AgentTileState.available); // only hovered by a mate
      expect(s(omen), AgentTileState.notOwned);
      expect(s(reyna), AgentTileState.available);
    });

    test('unknown ownership allows everything not taken', () {
      final m = pregame();
      expect(
        agentTileState(agentId: omen, match: m, self: me),
        AgentTileState.available,
      );
    });

    test('hovered, then locked (everything else disabled)', () {
      final hovering = pregame(myAgent: reyna, myState: 'selected');
      expect(
        agentTileState(
          agentId: reyna.toUpperCase(),
          match: hovering,
          self: me,
          owned: owned,
        ),
        AgentTileState.hovered,
      );
      final locked = pregame(myAgent: reyna, myState: 'locked');
      expect(
        agentTileState(agentId: reyna, match: locked, self: me, owned: owned),
        AgentTileState.locked,
      );
      final other = agentTileState(
        agentId: jett,
        match: locked,
        self: me,
        owned: owned,
      );
      expect(other, AgentTileState.disabled);
      expect(other.isEnabled, isFalse);
      expect(other.isDimmed, isTrue);
    });
  });

  test('selectableAgents: playable agents by name', () {
    expect(selectableAgents(db).map((a) => a.displayName), [
      'Jett',
      'Omen',
      'Raze',
      'Reyna',
      'Sage',
      'Sova',
    ]);
    expect(selectableAgents(ContentDb.empty()), isEmpty);
  });

  test('auto-open only on menus → agent select', () {
    LiveGameState s(LivePhase p) => LiveGameState(
      phase: p,
      receivedAt: at,
      match: p == LivePhase.pregame ? pregame() : null,
    );
    expect(
      shouldAutoOpenLiveGame(s(LivePhase.lobby), s(LivePhase.pregame)),
      isTrue,
    );
    expect(
      shouldAutoOpenLiveGame(s(LivePhase.queueing), s(LivePhase.pregame)),
      isTrue,
    );
    expect(shouldAutoOpenLiveGame(null, s(LivePhase.pregame)), isFalse);
    expect(
      shouldAutoOpenLiveGame(s(LivePhase.pregame), s(LivePhase.pregame)),
      isFalse,
    );
    expect(
      shouldAutoOpenLiveGame(s(LivePhase.notRunning), s(LivePhase.pregame)),
      isFalse,
    );
    expect(
      shouldAutoOpenLiveGame(s(LivePhase.lobby), s(LivePhase.ingame)),
      isFalse,
    );
  });
}
