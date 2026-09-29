import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/content/content_db.dart';
import '../../core/content/content_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/error_view.dart';
import '../../core/ui/net_image.dart';
import '../../core/ui/skeleton.dart';
import '../../core/util/clock.dart';
import '../../core/xmpp/xmpp.dart';
import 'data/live_game_logic.dart';
import 'data/live_game_models.dart';
import 'live_game_sheet.dart';
import 'live_game_strings.dart';
import 'providers/live_game_providers.dart';
import 'ui/live_widgets.dart';

/// R7 "Trận hiện tại" card shown on the profile tab: state line
/// ("Không trong trận", "Đang chọn đặc vụ · Ascent", "Đang đấu · Lotus · 8 – 4")
/// with a refresh ring. Tap opens [showLiveGameSheet].
class CurrentGameCard extends ConsumerWidget {
  const CurrentGameCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) return const SizedBox.shrink();
    final puuid = account.puuid;
    final theme = Theme.of(context);
    final value = ref.watch(liveGameProvider(puuid));
    final state = value.value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final match = state?.match;

    final Widget subtitle;
    if (state != null) {
      subtitle = _StatusLine(state: state, db: db);
    } else if (value.hasError && !value.isLoading) {
      subtitle = Text(
        describeError(value.error!).needsLogin
            ? describeError(value.error!).message
            : LiveGameStrings.statusUnavailable,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else {
      subtitle = const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Skeleton(width: 150, height: 16),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => unawaited(showLiveGameSheet(context)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              _Leading(
                phase: state?.phase,
                mapIcon: db.mapByUrl(match?.mapId)?.listViewIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LiveGameStrings.currentGame.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    subtitle,
                  ],
                ),
              ),
              LiveRefreshRing(puuid: puuid, size: 36),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The status text; ticks every second while queueing, adds the live
/// score in a match when enabled.
class _StatusLine extends ConsumerWidget {
  const _StatusLine({required this.state, required this.db});

  final LiveGameState state;
  final ContentDb db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final color = switch (state.phase) {
      LivePhase.pregame || LivePhase.queueing => colors.warning,
      LivePhase.ingame => colors.win,
      _ => null,
    };
    final style = theme.textTheme.titleSmall?.copyWith(color: color);
    Text text(String s) =>
        Text(s, maxLines: 2, overflow: TextOverflow.ellipsis, style: style);

    switch (state.phase) {
      case LivePhase.queueing when state.queueEntryTime != null:
        return TickingBuilder(
          builder: (context, now) =>
              text(currentGameStatusText(state, db, now: now)),
        );
      case LivePhase.ingame when ref.watch(liveScoreEnabledProvider):
        final presence = ref.watch(ownPresenceProvider).value;
        final now = ref.watch(clockProvider).now();
        return text(
          currentGameStatusText(
            state,
            db,
            now: now,
            score: liveScoreOf(presence, now: now),
          ),
        );
      default:
        return text(
          currentGameStatusText(state, db, now: ref.watch(clockProvider).now()),
        );
    }
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.phase, required this.mapIcon});

  final LivePhase? phase;
  final String? mapIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final inMatch = phase?.inMatch ?? false;
    final accent = switch (phase) {
      LivePhase.pregame || LivePhase.queueing => colors.warning,
      LivePhase.ingame => colors.win,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: inMatch && mapIcon != null
          ? NetImage(mapIcon, fit: BoxFit.cover, showSkeleton: false)
          : Icon(
              phase == LivePhase.queueing
                  ? Icons.radar
                  : Icons.sports_esports_outlined,
              color: accent,
            ),
    );
  }
}
