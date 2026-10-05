import '../../../core/network/riot_exception.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/json.dart';
import '../../../core/xmpp/xmpp_models.dart' show LoopState;
import 'live_game_models.dart';

/// One detection pass (SUMMARY §8.6 G1, EP §15): G-1 session loop state,
/// then G-2/G-3 (agent select) or G-8/G-9 (running match), and the party
/// (G-12/G-13) in the menus for the queue timer. Read-only: never calls a
/// mutation.
///
/// 404s are states, not errors (SUMMARY §11.5). Any other failure of the
/// session / match calls is rethrown (the controller keeps the previous
/// state visible); the party lookup is best effort.
class LiveGamePoller {
  LiveGamePoller({
    required this._api,
    required String puuid,
    required this._clock,
  }) : puuid = puuid.trim().toLowerCase();

  final PvpApi _api;
  final Clock _clock;
  final String puuid;

  Future<LiveGameState> poll({LiveGameState? previous}) async {
    final session = await _api.gameSession(puuid).orNullIfNotFound();
    final now = _clock.now();
    if (session == null) {
      return _resolve(
        previous: previous,
        now: now,
        phase: LivePhase.notRunning,
      );
    }
    final loop = LoopState.parse(asString(session['loopState']));

    LiveMatch? match;
    if (loop != LoopState.menus) {
      if (loop != LoopState.ingame) match = await _pregame(now);
      // PREGAME → INGAME happens between polls; unknown states try both.
      match ??= await _coreGame(now);
    }
    if (match != null && !match.isFinished) {
      return LiveGameState(
        phase: match.isPregame ? LivePhase.pregame : LivePhase.ingame,
        receivedAt: now,
        match: match,
      );
    }

    final party = loop == LoopState.menus ? await _party() : null;
    return _resolve(
      previous: previous,
      now: now,
      phase: ((party?.isMatchmaking ?? false) || (party?.isMatchFound ?? false))
          ? LivePhase.queueing
          : LivePhase.lobby,
      party: party,
      finished: match,
    );
  }

  /// Out of a match: remember the match that just ended (G11).
  LiveGameState _resolve({
    required LiveGameState? previous,
    required DateTime now,
    required LivePhase phase,
    LiveParty? party,
    LiveMatch? finished,
  }) {
    LiveEndedMatch? ended;
    final last = previous?.match;
    if (finished != null) {
      ended = previous?.ended?.matchId == finished.matchId
          ? previous!.ended
          : LiveEndedMatch.of(finished, now);
    } else if (previous?.phase == LivePhase.ingame && last != null) {
      ended = LiveEndedMatch.of(last, now);
    } else {
      final kept = previous?.ended;
      if (kept != null && now.difference(kept.endedAt) < kEndedMatchRetention) {
        ended = kept;
      }
    }
    return LiveGameState(
      phase: phase,
      receivedAt: now,
      party: party,
      ended: ended,
    );
  }

  Future<LiveMatch?> _pregame(DateTime now) async {
    final player = await _api.pregamePlayer(puuid).orNullIfNotFound();
    final matchId = lowerUuid(player?['MatchID']);
    if (matchId == null) return null;
    final json = await _api.pregameMatch(puuid, matchId).orNullIfNotFound();
    if (json == null) return null;
    return LiveMatch.fromPregame(
      json,
      fallbackMatchId: matchId,
      receivedAt: now,
    );
  }

  Future<LiveMatch?> _coreGame(DateTime now) async {
    final player = await _api.coreGamePlayer(puuid).orNullIfNotFound();
    final matchId = lowerUuid(player?['MatchID']);
    if (matchId == null) return null;
    final json = await _api.coreGameMatch(puuid, matchId).orNullIfNotFound();
    if (json == null) return null;
    return LiveMatch.fromCoreGame(
      json,
      fallbackMatchId: matchId,
      selfPuuid: puuid,
      receivedAt: now,
    );
  }

  Future<LiveParty?> _party() async {
    try {
      return await fetchLiveParty(_api, puuid);
    } on NeedsLoginException {
      rethrow;
    } on RiotException {
      return null; // the queue timer is optional
    }
  }
}

/// The signed-in player's party (G-12 → G-13); `null` when not in one.
Future<LiveParty?> fetchLiveParty(PvpApi api, String puuid) async {
  final player = await api.partyPlayer(puuid).orNullIfNotFound();
  final partyId = lowerUuid(player?['CurrentPartyID']);
  if (partyId == null) return null;
  final json = await api.party(puuid, partyId).orNullIfNotFound();
  return LiveParty.fromJson(json);
}
