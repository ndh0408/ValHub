import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/xmpp.dart';
import '../data/live_game_logic.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';
import '../providers/live_game_providers.dart';
import 'live_widgets.dart';

/// Header of the "Chi tiết trận" sheet (G3): title, refresh ring, close,
/// then the map banner (splash, map, mode, status pill) and the live score.
/// Screens shorter than this get the compact header (small phones, large
/// text): one-line banner and an inline live score.
const kCompactLiveHeaderHeight = 720.0;

class LiveSheetHeader extends ConsumerWidget {
  const LiveSheetHeader({super.key, required this.puuid, this.state});

  final String puuid;
  final LiveGameState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final compact =
        MediaQuery.sizeOf(context).height < kCompactLiveHeaderHeight;
    final match = state?.match;
    final ended = match == null ? state?.ended : null;
    final status = match != null
        ? (match.isPregame ? LiveStatus.agentSelect : LiveStatus.inProgress)
        : (ended != null ? LiveStatus.ended : null);
    final mapId = match?.mapId ?? ended?.mapId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LiveGameStrings.sheetTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              LiveRefreshRing(puuid: puuid),
              IconButton(
                tooltip: LiveGameStrings.close,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: LiveMapBanner(
              mapName: liveMapName(db, mapId),
              splash: db.mapByUrl(mapId)?.splash,
              mode: liveModeLabel(
                db,
                queueId: match?.queueId ?? ended?.queueId,
                modeId: match?.modeId ?? ended?.modeId,
              ),
              status: status,
              compact: compact,
            ),
          ),
        if (match != null && !match.isPregame)
          LiveScoreBanner(compact: compact),
      ],
    );
  }
}

/// Status pill, map name (Anton) and mode, centred on the sheet's teal
/// hero (Figma). [splash] is kept for callers; the Figma layout has no art.
class LiveMapBanner extends StatelessWidget {
  const LiveMapBanner({
    super.key,
    required this.mapName,
    required this.splash,
    required this.mode,
    required this.status,
    this.compact = false,
  });

  final String? mapName;
  final String? splash;
  final String mode;
  final LiveStatus status;

  /// One row (map + mode | pill) for short screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final name = Text(
      (mapName ?? LiveGameStrings.sheetTitle).toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: compact ? TextAlign.start : TextAlign.center,
      style: ValText.display(compact ? 26 : 40, color: onSurface),
    );
    final modeText = Text(
      mode,
      maxLines: compact ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      textAlign: compact ? TextAlign.start : TextAlign.center,
      style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
    // Figma: no card, the map sits centred on the sheet's teal hero.
    return compact
        ? Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [name, modeText],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(child: LiveStatusPill(status)),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LiveStatusPill(status),
                const SizedBox(height: 10),
                name,
                const SizedBox(height: 4),
                modeText,
              ],
            ),
          );
  }
}

/// Centred live round score (G7) from the player's own presence; hidden
/// when the setting / flag is off or the score is unknown or stale.
class LiveScoreBanner extends ConsumerWidget {
  const LiveScoreBanner({super.key, this.compact = false});

  /// Label and score on one line.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(liveScoreEnabledProvider)) return const SizedBox.shrink();
    final presence = ref.watch(ownPresenceProvider).value;
    final score = liveScoreOf(presence, now: ref.watch(clockProvider).now());
    if (score == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final style = ValText.display(compact ? 30 : 64)
        .copyWith(height: 1.05, color: theme.colorScheme.onSurface);
    final label = Text(
      LiveGameStrings.liveScore.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: colors.muted,
        letterSpacing: 1.2,
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Flex(
        direction: compact ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (compact) Flexible(child: label) else label,
          const SizedBox(width: 12, height: 4),
          Semantics(
            label: '${LiveGameStrings.liveScore} ${score.text}',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${score.ally}',
                    style: style.copyWith(color: colors.win),
                  ),
                  TextSpan(
                    text: '  –  ',
                    style: style.copyWith(
                      color: colors.muted,
                      fontSize: (style.fontSize ?? 64) * 0.5,
                    ),
                  ),
                  TextSpan(
                    text: '${score.enemy}',
                    style: style.copyWith(color: colors.loss),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
