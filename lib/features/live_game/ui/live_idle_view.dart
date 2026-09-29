import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/format.dart';
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

    return RefreshIndicator(
      onRefresh: () => ref.read(liveGameProvider(puuid).notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34,
                color: state.phase == LivePhase.queueing
                    ? colors.warning
                    : theme.colorScheme.onSurfaceVariant,
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
            ),
          ),
        ],
      ),
    );
  }
}
