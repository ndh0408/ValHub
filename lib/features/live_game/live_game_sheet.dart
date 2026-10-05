import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/ui/adaptive.dart';
import '../../core/ui/empty_view.dart';
import '../../core/ui/error_view.dart';
import '../../core/ui/segmented_tabs.dart';
import '../../core/ui/skeleton.dart';
import '../../core/ui/sub_page.dart';
import 'data/live_game_logic.dart';
import 'data/live_game_models.dart';
import 'providers/live_game_providers.dart';
import 'ui/agent_select_view.dart';
import 'ui/live_ended_view.dart';
import 'ui/live_game_header.dart';
import 'ui/live_idle_view.dart';
import 'ui/live_roster.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
      clipBehavior: Clip.antiAlias,
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
  const LiveGameSheet({super.key, this.fullPage = false, this.onOpenParty});

  final bool fullPage;
  final VoidCallback? onOpenParty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = fullPage ? null : MediaQuery.sizeOf(context).height * 0.92;
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return SizedBox(
        height: height,
        child: Column(
          children: [
            SheetHeader(
              title: context.l10n.liveGameSheetTitle,
              padding: EdgeInsets.fromLTRB(20, 0, 12, 10),
            ),
            Expanded(
              child: EmptyView(
                message: context.l10n.commonErrorNoAccount,
                icon: Icons.person_off_outlined,
              ),
            ),
          ],
        ),
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
          : const _LiveSkeleton();
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

    return ColoredBox(
      // ValBuddy: a plain sheet background under a large map splash.
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        height: height,
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                LiveSheetHeader(
                  puuid: puuid,
                  state: state,
                  onOpenParty: onOpenParty,
                ),
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
    return LiveTabs(
      labels: [
        context.l10n.liveGameTabAgents,
        context.l10n.liveGameTabYourTeam,
      ],
      children: [
        AgentSelectView(puuid: puuid, match: match),
        LiveRosterList(
          puuid: puuid,
          match: match,
          players: teams.ally,
          header: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.liveGameEnemyHiddenInAgentSelect,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      return LiveRosterList(
        puuid: puuid,
        match: match,
        players: teams.ally,
        header: const _LiveStatsNotice(),
      );
    }
    return LiveTabs(
      labels: [
        context.l10n.liveGameTabYourTeam,
        context.l10n.liveGameTabEnemyTeam,
      ],
      children: [
        LiveRosterList(
          puuid: puuid,
          match: match,
          players: teams.ally,
          header: const _LiveStatsNotice(),
        ),
        LiveRosterList(
          puuid: puuid,
          match: match,
          players: teams.enemy,
          header: const _LiveStatsNotice(),
        ),
      ],
    );
  }
}

/// Reuses the match presentation as a full page at the combined party route.
/// Fast polling is balanced on mount/unmount; account switching replaces this
/// page before displaying the next account's match.
class LiveGamePage extends ConsumerStatefulWidget {
  const LiveGamePage({super.key, this.onOpenParty});
  final VoidCallback? onOpenParty;

  @override
  ConsumerState<LiveGamePage> createState() => _LiveGamePageState();
}

class _LiveGamePageState extends ConsumerState<LiveGamePage> {
  LiveGameSheetOpenNotifier? _open;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final open = ref.read(liveGameSheetOpenProvider.notifier);
      open.open();
      _open = open;
    });
  }

  @override
  void dispose() {
    final open = _open;
    if (open != null) {
      // Avoid a provider mutation while the old route is being torn down.
      scheduleMicrotask(() {
        try {
          open.close();
        } on StateError {
          /* Provider scope disposed. */
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LiveGameSheet(fullPage: true, onOpenParty: widget.onOpenParty),
  );
}

class _LiveStatsNotice extends StatelessWidget {
  const _LiveStatsNotice();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
    child: Text(
      context.l10n.liveGameLiveStatsUnavailable,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
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
    final messages = context.l10n;
    final confirmed = await showQuitMatchDialog(context, pregame: pregame);
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(liveGameProvider(widget.puuid).notifier)
          .quitMatch(matchId: matchId, pregame: pregame);
      if (mounted) showAppSnackBar(context, messages.liveGameQuitDone);
    } on MatchChangedException {
      if (mounted) showAppSnackBar(context, messages.liveGameQuitMatchChanged);
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          '${messages.liveGameQuitFailed} ${describeError(messages, e).message}',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    // ValBuddy: a red outlined "Quit Match" at the very bottom. It only
    // ever asks; the penalty dialog decides.
    return SubPageBottomBar(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: error,
          backgroundColor: error.withValues(alpha: 0.10),
          side: BorderSide(color: error.withValues(alpha: 0.8)),
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
        ),
        onPressed: _busy ? null : () => unawaited(_confirmAndQuit()),
        icon: _busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(context.l10n.liveGameQuitMatch),
      ),
    );
  }
}

/// "Rời trận đấu?" confirmation (G10). `true` only when the user tapped
/// "Rời trận". Cupertino alert on iOS, Material alert elsewhere.
Future<bool> showQuitMatchDialog(
  BuildContext context, {
  required bool pregame,
}) => showConfirmDialog(
  context,
  title: context.l10n.liveGameQuitConfirmTitle,
  message: pregame
      ? context.l10n.liveGameQuitConfirmBodyPregame
      : context.l10n.liveGameQuitConfirmBodyInGame,
  confirmLabel: context.l10n.liveGameQuitMatch,
  destructive: true,
  icon: Icons.warning_amber_rounded,
);

/// Glass segmented control ("Đội của bạn · Đội địch") over swipeable pages.
class LiveTabs extends StatefulWidget {
  const LiveTabs({super.key, required this.labels, required this.children})
    : assert(labels.length == children.length);

  final List<String> labels;
  final List<Widget> children;

  @override
  State<LiveTabs> createState() => _LiveTabsState();
}

class _LiveTabsState extends State<LiveTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: widget.labels.length,
    vsync: this,
  )..addListener(_onChange);
  int _index = 0;

  void _onChange() {
    if (_tabs.index != _index && mounted) {
      setState(() => _index = _tabs.index);
    }
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedTabs<int>(
          expand: true,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          tabs: [
            for (var i = 0; i < widget.labels.length; i++)
              SegmentedTab(value: i, label: widget.labels[i]),
          ],
          selected: _index,
          onChanged: (i) {
            setState(() => _index = i);
            _tabs.animateTo(i);
          },
        ),
        Expanded(
          child: TabBarView(controller: _tabs, children: widget.children),
        ),
      ],
    );
  }
}

/// Loading state that mirrors the final layout: team toggle, then rows.
class _LiveSkeleton extends StatelessWidget {
  const _LiveSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            Skeleton(height: 48, radius: 999, shimmer: false),
            SizedBox(height: 14),
            _SkeletonRow(),
            _SkeletonRow(),
            _SkeletonRow(),
            _SkeletonRow(),
            _SkeletonRow(),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Skeleton(width: 46, height: 46, radius: 999, shimmer: false),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 140, height: 14, shimmer: false),
              SizedBox(height: 6),
              Skeleton(width: 96, height: 11, shimmer: false),
            ],
          ),
        ),
        SizedBox(width: 12),
        Skeleton(width: 56, height: 32, shimmer: false),
      ],
    ),
  );
}
