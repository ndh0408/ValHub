import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/xmpp.dart';
import '../data/live_game_logic.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';
import '../providers/live_game_providers.dart';
import 'live_widgets.dart';

/// Header of the "Chi tiết trận" sheet (G3, ValBuddy "Game Details"):
/// bold title + round close button, a large rounded map splash, then map
/// name / mode with the refresh ring and the status chip, and the live
/// score. Screens shorter than this get the compact header (small phones,
/// large text): a slimmer splash and an inline live score.
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
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LiveGameStrings.sheetTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Outside a match there is no status row: keep the ring here.
              if (status == null) LiveRefreshRing(puuid: puuid),
              IconButton.filledTonal(
                tooltip: LiveGameStrings.close,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
              trailing: LiveRefreshRing(puuid: puuid, size: 36),
            ),
          ),
        if (match != null && !match.isPregame)
          LiveScoreBanner(compact: compact),
      ],
    );
  }
}

/// Large rounded map splash, then the map name (bold) and mode (muted)
/// with an optional [trailing] (refresh ring) and the status chip.
class LiveMapBanner extends StatelessWidget {
  const LiveMapBanner({
    super.key,
    required this.mapName,
    required this.splash,
    required this.mode,
    required this.status,
    this.compact = false,
    this.trailing,
  });

  final String? mapName;
  final String? splash;
  final String mode;
  final LiveStatus status;

  /// Slimmer splash for short screens.
  final bool compact;

  /// Shown before the status chip (the refresh ring).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final art = splash;
    final hasArt = art != null && art.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasArt) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.card),
            child: AspectRatio(
              aspectRatio: compact ? 3.6 : 2.5,
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHigh,
                child: NetImage(
                  art,
                  fit: BoxFit.cover,
                  error: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mapName ?? LiveGameStrings.sheetTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    mode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            const SizedBox(width: 4),
            Flexible(child: LiveStatusPill(status)),
          ],
        ),
      ],
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
    final style = TextStyle(
      fontSize: compact ? 28 : 52,
      height: 1.05,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurface,
    );
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
