import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/util/format.dart';
import '../../social/social_routes.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';
import '../providers/live_game_providers.dart';
import 'live_widgets.dart';

/// Sheet body outside a match: not running / lobby / queueing (with the
/// "Đang tìm trận · 01:32" timer). Pull to refresh polls at once.
class LiveIdleView extends ConsumerWidget {
  const LiveIdleView({super.key, required this.puuid, required this.state});

  final String puuid;
  final LiveGameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final (icon, hint) = switch (state.phase) {
      LivePhase.queueing => (Icons.radar, LiveGameStrings.queueHint),
      LivePhase.lobby => (Icons.weekend_outlined, LiveGameStrings.lobbyHint),
      _ => (Icons.sports_esports_outlined, LiveGameStrings.notInGameHint),
    };
    final queueEntry = state.queueEntryTime;
    final queueId = state.party?.queueId;

    Widget title(String text) => Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.titleMedium,
    );

    final queueing = state.phase == LivePhase.queueing;
    final tint = queueing ? colors.warning : theme.colorScheme.onSurfaceVariant;
    return AdaptiveRefresh(
      onRefresh: () => ref.read(liveGameProvider(puuid).notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        children: [
          Center(
            child: SizedBox.square(
              dimension: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Searching: a spinning ring around the radar icon.
                  if (queueing)
                    SizedBox.square(
                      dimension: 88,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tint,
                        backgroundColor: tint.withValues(alpha: 0.12),
                      ),
                    ),
                  StateIcon(icon: icon, color: tint, size: 76),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          switch (state.phase) {
            LivePhase.queueing when queueEntry != null => TickingBuilder(
              builder: (context, now) => title(
                LiveGameStrings.inQueueFor(
                  formatMinutesSeconds(
                    now.toUtc().difference(queueEntry.toUtc()),
                  ),
                ),
              ),
            ),
            LivePhase.queueing => title(LiveGameStrings.inQueue),
            LivePhase.lobby => title(LiveGameStrings.inLobby),
            _ => title(LiveGameStrings.notInGameTitle),
          },
          if (state.phase == LivePhase.queueing &&
              queueId != null &&
              queueId.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              db.queueName(queueId),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.warning,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // Real actions only: poll now, or jump to the party / queue
          // screen when the player is in the menus.
          if (state.phase == LivePhase.lobby || queueing)
            FilledButton.icon(
              onPressed: () => _openParty(context),
              icon: const Icon(Icons.groups_2_outlined),
              label: const Text(LiveGameStrings.openParty),
            ),
          if (state.phase == LivePhase.lobby || queueing)
            const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                unawaited(ref.read(liveGameProvider(puuid).notifier).refresh()),
            icon: const Icon(Icons.refresh),
            label: const Text(LiveGameStrings.refreshNow),
          ),
          const SizedBox(height: 12),
          Text(
            LiveGameStrings.autoRefreshNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Closes the sheet, then opens "Tổ đội & hàng chờ" in the profile tab.
  void _openParty(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    unawaited(Navigator.of(context).maybePop());
    router?.go(SocialRoutes.party);
  }
}
