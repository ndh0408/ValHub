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
import '../../core/ui/val_widgets.dart';
import '../../core/util/clock.dart';
import '../../core/xmpp/xmpp.dart';
import 'data/live_game_logic.dart';
import 'data/live_game_models.dart';
import 'live_game_sheet.dart';
import 'providers/live_game_providers.dart';
import 'ui/live_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// R7 "Trận hiện tại" card shown on the profile tab: state line
/// ("Không trong trận", "Đang chọn đặc vụ · Ascent", "Đang đấu · Lotus · 8 – 4")
/// with a refresh ring. Tap opens [showLiveGameSheet].
class CurrentGameCard extends ConsumerWidget {
  const CurrentGameCard({
    super.key,
    this.title,
    this.onOpen,
    this.matchOnly = false,
    this.includeRecentResult = false,
  });

  /// Alternate entry label/action; the live state still comes from the same
  /// account-scoped provider. The default action opens the live sheet.
  final String? title;
  final VoidCallback? onOpen;

  /// Inside the party hub, an idle status is informational, not another
  /// entry into an empty match sheet. Refresh remains available.
  final bool matchOnly;

  /// Include the retained post-match status in the combined profile entry.
  /// Its [onOpen] route selects the main view from the current game phase.
  final bool includeRecentResult;

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
    if (includeRecentResult &&
        state?.ended != null &&
        state?.match == null &&
        state?.phase != LivePhase.queueing) {
      subtitle = Text(
        context.l10n.liveGameStatusEnded,
        style: theme.textTheme.bodyMedium,
      );
    } else if (state != null) {
      subtitle = _StatusLine(state: state, db: db);
    } else if (value.hasError && !value.isLoading) {
      subtitle = Text(
        describeError(context.l10n, value.error!).needsLogin
            ? describeError(context.l10n, value.error!).message
            : context.l10n.liveGameStatusUnavailable,
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

    final mapArt = match == null ? null : db.mapByUrl(match.mapId)?.splash;
    final chip = switch (state?.phase) {
      LivePhase.pregame => const LiveStatusPill(LiveStatus.agentSelect),
      LivePhase.ingame => const LiveStatusPill(LiveStatus.inProgress),
      _ => null,
    };
    final surface = theme.colorScheme.surfaceContainer;
    final canOpen = !matchOnly || (state?.phase.inMatch ?? false);
    return ValCard(
      padding: EdgeInsets.zero,
      onTap: canOpen
          ? onOpen ?? () => unawaited(showLiveGameSheet(context))
          : null,
      child: Stack(
        children: [
          // In a match the map splash shows through on the right; a surface
          // gradient over it keeps the text on the left readable (a
          // gradient, never an Opacity layer).
          if (mapArt != null && (state?.phase.inMatch ?? false)) ...[
            Positioned.fill(
              child: NetImage(
                mapArt,
                fit: BoxFit.cover,
                showSkeleton: false,
                error: const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: const [0, 0.5, 1],
                    colors: [
                      surface,
                      surface.withValues(alpha: 0.92),
                      surface.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                _Leading(
                  phase: state?.phase,
                  mapIcon: mapArt == null
                      ? db.mapByUrl(match?.mapId)?.listViewIcon
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            (title ?? context.l10n.liveGameCurrentGame)
                                .toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ValText.label.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          ?chip,
                        ],
                      ),
                      const SizedBox(height: 4),
                      subtitle,
                    ],
                  ),
                ),
                LiveRefreshRing(puuid: puuid, size: 36),
                if (canOpen)
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ],
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
              text(currentGameStatusText(context.l10n, state, db, now: now)),
        );
      case LivePhase.ingame when ref.watch(liveScoreEnabledProvider):
        final presence = ref.watch(ownPresenceProvider).value;
        final now = ref.watch(clockProvider).now();
        return text(
          currentGameStatusText(
            context.l10n,
            state,
            db,
            now: now,
            score: liveScoreOf(presence, now: now),
          ),
        );
      default:
        return text(
          currentGameStatusText(
            context.l10n,
            state,
            db,
            now: ref.watch(clockProvider).now(),
          ),
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
        borderRadius: BorderRadius.circular(12),
        border: BorderDirectional(start: BorderSide(color: accent, width: 3)),
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
