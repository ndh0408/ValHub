import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/settings/app_settings.dart';
import 'data/live_game_models.dart';
import 'live_game_sheet.dart';
import 'providers/live_game_providers.dart';

/// Global hook mounted by the app shell around the tab content. While the
/// app is in the foreground it keeps the active account's live game polled
/// (every 15–30 s, faster while the sheet is open) and auto-opens the
/// "Chi tiết trận" sheet when a match is found (G2: MENUS → PREGAME, when
/// "Tự động mở chi tiết trận" is on). Opening the sheet is the only thing
/// it does on its own — it never changes anything on the account.
class LiveGameOverlayHost extends ConsumerStatefulWidget {
  const LiveGameOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LiveGameOverlayHost> createState() =>
      _LiveGameOverlayHostState();
}

class _LiveGameOverlayHostState extends ConsumerState<LiveGameOverlayHost> {
  /// Match the sheet was auto-opened for (once per match).
  String? _autoOpenedFor;

  void _onChange(LiveGameState? previous, LiveGameState? next) {
    if (!shouldAutoOpenLiveGame(previous, next)) return;
    final matchId = next!.matchId;
    if (matchId == null || matchId == _autoOpenedFor) return;
    if (!ref.read(appSettingsProvider).autoOpenLiveGame) return;
    if (ref.read(liveGameSheetOpenProvider) > 0) return;
    _autoOpenedFor = matchId;
    // Outside the provider notification: open on the next event-loop turn.
    Timer.run(() {
      if (!mounted || ref.read(liveGameSheetOpenProvider) > 0) return;
      unawaited(showLiveGameSheet(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final puuid = ref.watch(
      activeAccountProvider.select(
        (a) => a == null || a.needsLogin ? null : a.puuid,
      ),
    );
    if (puuid != null) {
      ref.listen<AsyncValue<LiveGameState>>(
        liveGameProvider(puuid),
        (previous, next) => _onChange(previous?.value, next.value),
      );
    }
    return widget.child;
  }
}

/// G2: a match was just found — the menus (lobby or queue) turned into agent
/// select. The first detection after launch is not a transition.
bool shouldAutoOpenLiveGame(LiveGameState? previous, LiveGameState? next) {
  if (previous == null || next == null) return false;
  if (next.phase != LivePhase.pregame) return false;
  return previous.phase == LivePhase.lobby ||
      previous.phase == LivePhase.queueing;
}
