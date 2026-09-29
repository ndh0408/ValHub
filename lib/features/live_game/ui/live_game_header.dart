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

/// Header of the "Chi tiết trận" sheet (G3): title, refresh ring, close,
/// then the map banner (splash, map, mode, status pill) and the live score.
class LiveSheetHeader extends ConsumerWidget {
  const LiveSheetHeader({super.key, required this.puuid, this.state});

  final String puuid;
  final LiveGameState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
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
            ),
          ),
        if (match != null && !match.isPregame) const LiveScoreBanner(),
      ],
    );
  }
}

/// Map splash with the map name, mode and status pill.
class LiveMapBanner extends StatelessWidget {
  const LiveMapBanner({
    super.key,
    required this.mapName,
    required this.splash,
    required this.mode,
    required this.status,
  });

  final String? mapName;
  final String? splash;
  final String mode;
  final LiveStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        color: ValColors.surfaceHigh,
        child: Stack(
          children: [
            Positioned.fill(
              child: NetImage(splash, fit: BoxFit.cover, showSkeleton: false),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ValColors.nearBlack.withValues(alpha: 0.92),
                      ValColors.nearBlack.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiveStatusPill(status),
                  const SizedBox(height: 8),
                  Text(
                    (mapName ?? LiveGameStrings.sheetTitle).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: ValColors.bone,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ValColors.bone.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centred live round score (G7) from the player's own presence; hidden
/// when the setting / flag is off or the score is unknown or stale.
class LiveScoreBanner extends ConsumerWidget {
  const LiveScoreBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(liveScoreEnabledProvider)) return const SizedBox.shrink();
    final presence = ref.watch(ownPresenceProvider).value;
    final score = liveScoreOf(presence, now: ref.watch(clockProvider).now());
    if (score == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final style = theme.textTheme.displaySmall?.copyWith(height: 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Text(
            LiveGameStrings.liveScore.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            label: '${LiveGameStrings.liveScore} ${score.text}',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${score.ally}',
                    style: style?.copyWith(color: colors.win),
                  ),
                  TextSpan(text: '  –  ', style: style),
                  TextSpan(
                    text: '${score.enemy}',
                    style: style?.copyWith(color: colors.loss),
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
