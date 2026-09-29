import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/config/remote_config.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/network/riot_exception.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/json.dart';
import '../../../core/xmpp/xmpp.dart';
import '../data/live_game_models.dart';
import '../data/live_game_poller.dart';

/// Poll cadence (SUMMARY §10): every 3–5 s while the live sheet is open,
/// 15–30 s otherwise, never in the background.
const kLivePollFast = Duration(seconds: 4);
const kLivePollSlow = Duration(seconds: 20);

/// Slowest cadence while the servers are in maintenance.
const kLivePollMaintenance = Duration(seconds: 60);

/// Number of open "Chi tiết trận" sheets (> 0 switches to the fast cadence).
final liveGameSheetOpenProvider =
    NotifierProvider<LiveGameSheetOpenNotifier, int>(
      LiveGameSheetOpenNotifier.new,
    );

class LiveGameSheetOpenNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void open() => state = state + 1;

  void close() {
    if (state > 0) state = state - 1;
  }
}

/// Live game of a signed-in account (G1): polls G-1 → G-2/G-3 or G-8/G-9
/// (and the party in the menus) while something watches it and the app is
/// in the foreground. Errors keep the previous state visible.
final liveGameProvider = AsyncNotifierProvider.autoDispose
    .family<LiveGameController, LiveGameState, String>(LiveGameController.new);

class LiveGameController extends AsyncNotifier<LiveGameState> {
  LiveGameController(String puuid) : puuid = puuid.trim().toLowerCase();

  final String puuid;

  /// When the next automatic poll runs; `null` while paused (background,
  /// nobody watching, needs login). Drives the refresh ring.
  final nextPollAt = ValueNotifier<DateTime?>(null);

  /// Current cadence.
  Duration get interval => _fast ? kLivePollFast : kLivePollSlow;

  PvpApi? _api;
  LiveGamePoller? _poller;
  Clock _clock = const Clock();
  LiveGameState? _last;
  Object? _lastError;
  Timer? _timer;
  Future<void>? _inFlight;
  bool _again = false;
  bool _fast = false;
  bool _foreground = true;
  bool _paused = false;
  int _generation = 0;

  @override
  Future<LiveGameState> build() async {
    final generation = ++_generation;
    ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    final api = ref.watch(pvpApiProvider);
    final clock = ref.watch(clockProvider);
    _api = api;
    _clock = clock;
    final poller = _poller = LiveGamePoller(
      api: api,
      puuid: puuid,
      clock: clock,
    );
    _fast = ref.read(liveGameSheetOpenProvider) > 0;
    _foreground = ref.read(appForegroundProvider);
    _paused = false;

    ref
      ..listen<bool>(liveGameSheetOpenProvider.select((n) => n > 0), (_, fast) {
        _fast = fast;
        if (fast) {
          unawaited(refresh());
        } else {
          _schedule();
        }
      })
      ..listen<bool>(appForegroundProvider, (_, foreground) {
        _foreground = foreground;
        if (foreground) {
          unawaited(refresh());
        } else {
          _cancelTimer();
        }
      })
      ..onCancel(() {
        _paused = true;
        _cancelTimer();
      })
      ..onResume(() {
        _paused = false;
        _resumeIfDue();
      })
      ..onDispose(() {
        _generation++;
        _cancelTimer();
        _inFlight = null;
        _again = false;
      });

    final done = Completer<void>();
    _inFlight = done.future;
    try {
      final result = await poller.poll(previous: _last);
      if (generation == _generation) {
        _last = result;
        _lastError = null;
      }
      return result;
    } on Object catch (e) {
      if (generation == _generation) _lastError = e;
      rethrow;
    } finally {
      done.complete();
      if (generation == _generation) {
        _inFlight = null;
        _schedule(delay: _takeAgain() ? Duration.zero : null);
      }
    }
  }

  /// Polls now (refresh button, pull-to-refresh, after an action). Joins a
  /// poll that is already running and runs one more right after it.
  Future<void> refresh() {
    final running = _inFlight;
    if (running != null) {
      _again = true;
      return running;
    }
    _cancelTimer();
    late final Future<void> future;
    future = _tick().whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    _inFlight = future;
    return future;
  }

  Future<void> _tick() async {
    final generation = _generation;
    final poller = _poller;
    if (poller == null) return;
    try {
      final previous = _last;
      final next = await poller.poll(previous: previous);
      if (generation != _generation || !ref.mounted) return;
      _last = next;
      _lastError = null;
      state = AsyncData(next);
      _afterPoll(previous, next);
    } on Object catch (e, st) {
      if (generation != _generation || !ref.mounted) return;
      _lastError = e;
      state = AsyncError(e, st);
    } finally {
      if (generation == _generation && ref.mounted) {
        _schedule(delay: _takeAgain() ? Duration.zero : null);
      }
    }
  }

  bool _takeAgain() {
    final again = _again;
    _again = false;
    return again;
  }

  void _schedule({Duration? delay}) {
    _cancelTimer();
    final error = _lastError;
    if (!_foreground || _paused || error is NeedsLoginException) {
      nextPollAt.value = null;
      return;
    }
    var d = delay ?? interval;
    if (delay == null) {
      if (error is MaintenanceException && d < kLivePollMaintenance) {
        d = kLivePollMaintenance;
      }
      if (error is TransientException) {
        final retryAfter = error.retryAfter;
        if (retryAfter != null && retryAfter > d) d = retryAfter;
      }
    }
    nextPollAt.value = _clock.now().add(d);
    _timer = Timer(d, () {
      _timer = null;
      unawaited(refresh());
    });
  }

  void _resumeIfDue() {
    if (_inFlight != null) return;
    final at = nextPollAt.value;
    final now = _clock.now();
    if (at == null || !at.isAfter(now)) {
      unawaited(refresh());
    } else {
      _schedule(delay: at.difference(now));
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    nextPollAt.value = null;
  }

  /// A match just finished: the profile picks up the new RR and match (G11).
  void _afterPoll(LiveGameState? previous, LiveGameState next) {
    final ended = next.ended;
    if (ended == null || ended.matchId == previous?.ended?.matchId) return;
    ref
      ..invalidate(mmrProvider(puuid))
      ..invalidate(rankSummaryProvider(puuid))
      ..invalidate(competitiveUpdatesProvider(puuid))
      ..invalidate(accountXpProvider(puuid))
      ..invalidate(matchHistoryProvider);
  }

  // ------------------------------------------------ user actions (G4–G6/G11)

  /// Hovers [agentId] in agent select (G-4). Only call from a tap.
  Future<void> hoverAgent(String agentId) =>
      _selectAgent(agentId, AgentSelection.selected);

  /// Locks [agentId] in agent select (G-5). Only call from a long press.
  Future<void> lockAgent(String agentId) =>
      _selectAgent(agentId, AgentSelection.locked);

  Future<void> _selectAgent(String agentId, AgentSelection selection) async {
    final api = _api;
    final current = _last;
    final match = current?.match;
    if (api == null || current == null || match == null || !match.isPregame) {
      throw const NotFoundException(errorCode: 'no_pregame');
    }
    final json = selection == AgentSelection.locked
        ? await api.pregameLockAgent(puuid, match.matchId, agentId)
        : await api.pregameSelectAgent(puuid, match.matchId, agentId);
    if (!ref.mounted) return;
    final latest = _last;
    if (latest?.match?.matchId != match.matchId) return;
    final parsed = asMap(json)?['AllyTeam'] == null
        ? null
        : LiveMatch.fromPregame(
            json,
            fallbackMatchId: match.matchId,
            receivedAt: _clock.now(),
          );
    final me = parsed?.player(puuid);
    final updated =
        (me != null && me.characterId == agentId.toLowerCase()
            ? parsed
            : null) ??
        match.withSelection(puuid, agentId, selection);
    final next = latest!.copyWith(match: updated);
    _last = next;
    state = AsyncData(next);
  }

  /// Leaves the current match: dodge in agent select (G-6) or disassociate
  /// from a running match (G-11). **Penalty** — only call after the user
  /// confirmed the warning dialog.
  Future<void> quitMatch() async {
    final api = _api;
    final match = _last?.match;
    if (api == null || match == null) {
      throw const NotFoundException(errorCode: 'no_match');
    }
    if (match.isPregame) {
      await api.pregameQuit(puuid, match.matchId);
    } else {
      await api.coreGameDisassociate(puuid, match.matchId);
    }
    if (ref.mounted) unawaited(refresh());
  }
}

/// Key of per-match providers.
typedef LiveMatchKey = ({String puuid, String matchId});

/// The signed-in player's party during a match (G-12 / G-13), best effort:
/// `null` on any failure.
final liveOwnPartyProvider = FutureProvider.autoDispose
    .family<LiveParty?, LiveMatchKey>((ref, key) async {
      final api = ref.watch(pvpApiProvider);
      try {
        return await fetchLiveParty(api, key.puuid);
      } on RiotException {
        return null;
      }
    });

/// PUUID → party id of the players we know about during a match: our own
/// party (G-13) plus friends' presences (XMPP). Used for party badges.
final livePartyOfProvider = Provider.autoDispose
    .family<Map<String, String>, LiveMatchKey>((ref, key) {
      final out = <String, String>{};
      final presences = ref.watch(
        xmppSnapshotProvider.select((s) => s.value?.presences),
      );
      for (final entry in (presences ?? const {}).entries) {
        final party = lowerUuid(entry.value.valorant?.partyId);
        if (party != null) out[entry.key.toLowerCase()] = party;
      }
      final own = ref.watch(liveOwnPartyProvider(key)).value;
      if (own != null) {
        for (final member in own.members) {
          out[member] = own.partyId;
        }
      }
      return out;
    });

/// Whether the live score may be shown (settings toggle + remote flag).
final liveScoreEnabledProvider = Provider.autoDispose<bool>(
  (ref) =>
      ref.watch(appSettingsProvider.select((s) => s.showLiveScore)) &&
      ref
          .watch(remoteConfigProvider)
          .flag(RemoteFlags.liveScore, fallback: true),
);
