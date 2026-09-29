import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/l10n/common_strings.dart';
import '../../core/ui/empty_view.dart';
import '../../core/ui/error_view.dart';
import '../../core/ui/skeleton.dart';
import 'data/live_game_logic.dart';
import 'data/live_game_models.dart';
import 'live_game_strings.dart';
import 'providers/live_game_providers.dart';
import 'ui/agent_select_view.dart';
import 'ui/live_ended_view.dart';
import 'ui/live_game_header.dart';
import 'ui/live_idle_view.dart';
import 'ui/live_roster.dart';

/// Opens S50 "Chi tiết trận" (full-height sheet) for the active account.
/// While it is open the live game is polled every few seconds (SUMMARY §10).
Future<void> showLiveGameSheet(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final open = container.read(liveGameSheetOpenProvider.notifier)..open();
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const LiveGameSheet(),
    );
  } finally {
    try {
      open.close();
    } on StateError {
      // The provider scope went away with the sheet (app shutdown).
    }
  }
}

/// S50 body: header, agent select / rosters, live score, "Rời trận", or the
/// final scoreboard / idle state outside a match.
class LiveGameSheet extends ConsumerWidget {
  const LiveGameSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.sizeOf(context).height * 0.92;
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return SizedBox(
        height: height,
        child: const EmptyView(message: CommonStrings.errorNoAccount),
      );
    }
    final puuid = account.puuid;
    final value = ref.watch(liveGameProvider(puuid));
    final state = value.value;
    final match = state?.match;

    final Widget body;
    if (state == null) {
      body = value.hasError && !value.isLoading
          ? ErrorView(
              error: value.error!,
              puuid: puuid,
              onRetry: () => unawaited(
                ref.read(liveGameProvider(puuid).notifier).refresh(),
              ),
            )
          : const SkeletonList(itemCount: 5, itemHeight: 76);
    } else {
      final content = switch (match) {
        final LiveMatch m when m.isPregame => _PregameTabs(
          key: ValueKey('pregame-${m.matchId}'),
          puuid: puuid,
          match: m,
        ),
        final LiveMatch m => _InGameTabs(
          key: ValueKey('ingame-${m.matchId}'),
          puuid: puuid,
          match: m,
        ),
        null when state.ended != null => LiveEndedView(
          puuid: puuid,
          ended: state.ended!,
        ),
        null => LiveIdleView(puuid: puuid, state: state),
      };
      body = value.hasError && !value.isLoading
          ? Column(
              children: [
                ErrorView(
                  error: value.error!,
                  puuid: puuid,
                  compact: true,
                  onRetry: () => unawaited(
                    ref.read(liveGameProvider(puuid).notifier).refresh(),
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content;
    }

    return SizedBox(
      height: height,
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              LiveSheetHeader(puuid: puuid, state: state),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: match == null
              ? null
              : _QuitBar(
                  key: ValueKey('quit-${match.matchId}'),
                  puuid: puuid,
                  match: match,
                ),
        ),
      ),
    );
  }
}

class _PregameTabs extends StatelessWidget {
  const _PregameTabs({super.key, required this.puuid, required this.match});

  final String puuid;
  final LiveMatch match;

  @override
  Widget build(BuildContext context) {
    final teams = splitTeams(match, puuid);
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: LiveGameStrings.tabAgents),
              Tab(text: LiveGameStrings.tabYourTeam),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AgentSelectView(puuid: puuid, match: match),
                LiveRosterList(
                  puuid: puuid,
                  match: match,
                  players: teams.ally,
                  header: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                    child: Text(
                      LiveGameStrings.enemyHiddenInAgentSelect,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InGameTabs extends StatelessWidget {
  const _InGameTabs({super.key, required this.puuid, required this.match});

  final String puuid;
  final LiveMatch match;

  @override
  Widget build(BuildContext context) {
    final teams = splitTeams(match, puuid);
    if (teams.isFreeForAll) {
      return LiveRosterList(puuid: puuid, match: match, players: teams.ally);
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: LiveGameStrings.tabYourTeam),
              Tab(text: LiveGameStrings.tabEnemyTeam),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                LiveRosterList(puuid: puuid, match: match, players: teams.ally),
                LiveRosterList(
                  puuid: puuid,
                  match: match,
                  players: teams.enemy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Red "Rời trận" button (G10) behind a penalty warning.
class _QuitBar extends ConsumerStatefulWidget {
  const _QuitBar({super.key, required this.puuid, required this.match});

  final String puuid;
  final LiveMatch match;

  @override
  ConsumerState<_QuitBar> createState() => _QuitBarState();
}

class _QuitBarState extends ConsumerState<_QuitBar> {
  bool _busy = false;

  Future<void> _confirmAndQuit() async {
    // What the user is warned about (dodge vs. abandon) is what gets sent.
    final matchId = widget.match.matchId;
    final pregame = widget.match.isPregame;
    final confirmed = await showQuitMatchDialog(context, pregame: pregame);
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(liveGameProvider(widget.puuid).notifier)
          .quitMatch(matchId: matchId, pregame: pregame);
      if (mounted) showAppSnackBar(context, LiveGameStrings.quitDone);
    } on MatchChangedException {
      if (mounted) showAppSnackBar(context, LiveGameStrings.quitMatchChanged);
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          '${LiveGameStrings.quitFailed} ${describeError(e).message}',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: error,
            side: BorderSide(color: error),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _busy ? null : () => unawaited(_confirmAndQuit()),
          icon: _busy
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: error,
                  ),
                )
              : const Icon(Icons.logout),
          label: const Text(LiveGameStrings.quitMatch),
        ),
      ),
    );
  }
}

/// "Rời trận đấu?" confirmation (G10). `true` only when the user tapped
/// "Rời trận".
Future<bool> showQuitMatchDialog(
  BuildContext context, {
  required bool pregame,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final error = Theme.of(context).colorScheme.error;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: error),
        title: const Text(LiveGameStrings.quitConfirmTitle),
        content: Text(
          pregame
              ? LiveGameStrings.quitConfirmBodyPregame
              : LiveGameStrings.quitConfirmBodyInGame,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CommonStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(LiveGameStrings.quitMatch),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
