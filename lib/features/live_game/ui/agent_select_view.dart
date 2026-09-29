import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/countdown_ring.dart';
import '../../../core/ui/countdown_text.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../data/live_game_logic.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';
import '../providers/live_game_providers.dart';

/// Typical length of agent select (competitive: 85 s), for the timer ring.
const kAgentSelectPeriod = Duration(seconds: 85);

/// "Đặc vụ" tab of agent select (G4): 5-column agent grid; tap = hover
/// (G-4), long press = lock (G-5). Every call is a user gesture.
class AgentSelectView extends ConsumerStatefulWidget {
  const AgentSelectView({super.key, required this.puuid, required this.match});

  final String puuid;
  final LiveMatch match;

  @override
  ConsumerState<AgentSelectView> createState() => _AgentSelectViewState();
}

class _AgentSelectViewState extends ConsumerState<AgentSelectView> {
  bool _busy = false;

  LiveGameController get _controller =>
      ref.read(liveGameProvider(widget.puuid).notifier);

  Future<void> _hover(Agent agent) async {
    if (_busy) return;
    Haptics.selection();
    setState(() => _busy = true);
    try {
      await _controller.hoverAgent(agent.uuid);
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(context, _failure(LiveGameStrings.selectFailed, e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _lock(Agent agent) async {
    if (_busy) return;
    setState(() => _busy = true);
    Haptics.medium();
    try {
      await _controller.lockAgent(agent.uuid);
      if (mounted) {
        showAppSnackBar(
          context,
          LiveGameStrings.lockedAgent(agent.displayName),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(context, _failure(LiveGameStrings.lockFailed, e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _failure(String base, Object error) {
    final detail = describeError(error);
    return detail.needsLogin ? '$base ${detail.message}' : base;
  }

  void _explain(AgentTileState state) {
    final message = switch (state) {
      AgentTileState.notOwned => LiveGameStrings.agentNotOwned,
      AgentTileState.taken => LiveGameStrings.agentTaken,
      _ => null,
    };
    if (message != null) showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final content = ref.watch(contentProvider);
    final db = content.value ?? ContentDb.empty();
    final agents = selectableAgents(db);
    final owned = ref.watch(ownedItemsProvider(widget.puuid)).value?.agentUuids;
    final me = match.player(widget.puuid);

    final loading = agents.isEmpty && content.isLoading;
    final Widget grid;
    if (agents.isEmpty && !loading) {
      grid = const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyView(
          message: LiveGameStrings.noAgents,
          icon: Icons.person_search_outlined,
        ),
      );
    } else {
      grid = SliverPadding(
        // Room under the last row so it can scroll clear of a snackbar.
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 72),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            const columns = 5;
            const gap = 8.0;
            final tile =
                (constraints.crossAxisExtent - gap * (columns - 1)) / columns;
            final label = MediaQuery.textScalerOf(context).scale(12) * 1.5;
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                mainAxisExtent: tile + 6 + label,
              ),
              delegate: SliverChildBuilderDelegate((context, i) {
                if (loading) return const _AgentTileSkeleton();
                final agent = agents[i];
                final state = agentTileState(
                  agentId: agent.uuid,
                  match: match,
                  self: widget.puuid,
                  owned: owned,
                );
                return AgentTile(
                  key: ValueKey(agent.uuid),
                  agent: agent,
                  state: state,
                  onTap: state.isEnabled && !_busy
                      ? () => unawaited(_hover(agent))
                      : () => _explain(state),
                  onLongPress: state.isEnabled && !_busy
                      ? () => unawaited(_lock(agent))
                      : null,
                );
              }, childCount: loading ? 15 : agents.length),
            );
          },
        ),
      );
    }

    return AdaptiveRefresh(
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _AgentSelectInfo(
              match: match,
              myAgent: me?.characterId == null
                  ? null
                  : db.agent(me!.characterId!),
              myLocked: me?.isLocked ?? false,
              onExpired: () => unawaited(_controller.refresh()),
            ),
          ),
          grid,
        ],
      ),
    );
  }
}

class _AgentSelectInfo extends StatelessWidget {
  const _AgentSelectInfo({
    required this.match,
    required this.myAgent,
    required this.myLocked,
    required this.onExpired,
  });

  final LiveMatch match;
  final Agent? myAgent;
  final bool myLocked;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final endsAt = match.phaseEndsAt;
    final enemySize = match.enemyTeamSize ?? 0;
    final agent = myAgent;
    final timer = endsAt == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountdownRing(
                expiresAt: endsAt,
                period: kAgentSelectPeriod,
                size: 18,
                color: colors.warning,
              ),
              const SizedBox(width: 6),
              CountdownText(
                expiresAt: endsAt,
                format: (d) => formatMinutesSeconds(d, padMinutes: false),
                builder: LiveGameStrings.timeLeft,
                onExpired: onExpired,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );
    return ValCard(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(LiveGameStrings.hoverLockHint, style: muted),
              ),
            ],
          ),
          if (timer != null || enemySize > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ?timer,
                if (enemySize > 0)
                  Text(
                    LiveGameStrings.enemyLocked(
                      (match.enemyTeamLockCount ?? 0).clamp(0, enemySize),
                      enemySize,
                    ),
                    style: muted,
                  ),
              ],
            ),
          ],
          if (agent != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  myLocked ? Icons.lock : Icons.radio_button_checked,
                  size: 16,
                  color: myLocked ? colors.win : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    myLocked
                        ? LiveGameStrings.youLocked(agent.displayName)
                        : LiveGameStrings.youHover(agent.displayName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: myLocked ? colors.win : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AgentTileSkeleton extends StatelessWidget {
  const _AgentTileSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      AspectRatio(aspectRatio: 1, child: Skeleton(radius: 999)),
      SizedBox(height: 6),
      Skeleton(height: 10, width: 36),
    ],
  );
}

/// Circular agent portrait + name. Dimmed when taken / not owned.
class AgentTile extends StatelessWidget {
  const AgentTile({
    super.key,
    required this.agent,
    required this.state,
    required this.onTap,
    this.onLongPress,
  });

  final Agent agent;
  final AgentTileState state;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final selected =
        state == AgentTileState.hovered || state == AgentTileState.locked;
    final borderColor = switch (state) {
      AgentTileState.locked => colors.win,
      AgentTileState.hovered => theme.colorScheme.primary,
      _ => theme.colorScheme.outlineVariant,
    };
    final badge = switch (state) {
      AgentTileState.locked || AgentTileState.taken => Icons.lock,
      AgentTileState.notOwned => Icons.block,
      _ => null,
    };
    return Semantics(
      button: true,
      selected: selected,
      enabled: state.isEnabled,
      label: agent.displayName,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: ValMotion.fast,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: borderColor,
                          width: selected ? 2.5 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: borderColor.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: NetImage(
                          agent.displayIcon,
                          fit: BoxFit.cover,
                          showSkeleton: false,
                          opacity: state.isDimmed ? 0.35 : null,
                        ),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: state == AgentTileState.locked
                              ? colors.win
                              : theme.colorScheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge,
                          size: 11,
                          color: state == AgentTileState.locked
                              ? ValColors.nearBlack
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              agent.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                color: state.isDimmed
                    ? theme.colorScheme.onSurfaceVariant
                    : (selected ? borderColor : null),
                fontWeight: selected ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
