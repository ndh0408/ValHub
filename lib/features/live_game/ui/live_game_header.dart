import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/xmpp.dart';
import '../data/live_game_logic.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';
import '../providers/live_game_providers.dart';
import 'live_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Header of the "Chi tiết trận" sheet (G3, ValBuddy "Game Details"): the
/// shared sheet header (bold title + round close button), a large rounded
/// map splash carrying the status chip, the refresh ring, the map name and
/// the mode, then the live score. Screens shorter than this get the compact
/// header (small phones, large text): a slimmer splash and an inline live
/// score.
const kCompactLiveHeaderHeight = 720.0;

class LiveSheetHeader extends ConsumerWidget {
  const LiveSheetHeader({super.key, required this.puuid, this.state});

  final String puuid;
  final LiveGameState? state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        SheetHeader(
          title: context.l10n.liveGameSheetTitle,
          // Outside a match there is no hero: keep the ring here.
          actions: [
            if (status == null) ...[
              LiveRefreshRing(puuid: puuid, size: 36),
              const SizedBox(width: 8),
            ],
          ],
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
        ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: LiveMapBanner(
              mapName: liveMapName(db, mapId),
              splash: db.mapByUrl(mapId)?.splash,
              mode: liveModeLabel(
                context.l10n,
                db,
                queueId: match?.queueId ?? ended?.queueId,
                modeId: match?.modeId ?? ended?.modeId,
              ),
              status: status,
              compact: compact,
              trailing: LiveRefreshRing(puuid: puuid, size: 36, onImage: true),
            ),
          ),
        if (match != null && !match.isPregame)
          LiveScoreBanner(compact: compact),
      ],
    );
  }
}

/// Large rounded map splash with the status chip (top start), the refresh
/// ring ([trailing], top end) and the map name + mode over a bottom scrim.
/// Without art (unknown map, offline) a teal gradient carries the same
/// text, so the header is never a blank box.
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

  /// Top-end widget (the refresh ring, built for use over images).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final art = splash;
    final hasArt = art != null && art.isNotEmpty;
    final name = (mapName ?? context.l10n.liveGameSheetTitle).toUpperCase();
    return Semantics(
      container: true,
      label: LiveGameStrings.joinParts([name, mode, status.label]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ValRadius.card + 4),
        child: AspectRatio(
          aspectRatio: compact ? 3.4 : 2.3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ValColors.liveTeal, ValColors.nearBlack],
                  ),
                ),
              ),
              if (hasArt)
                NetImage(
                  art,
                  fit: BoxFit.cover,
                  showSkeleton: false,
                  error: const SizedBox.shrink(),
                ),
              // Scrims over the image (a gradient, never an Opacity layer):
              // dark at the top for the chip / ring, at the bottom for text.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.3, 0.45, 1],
                    colors: [
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0x14000000),
                      Color(0xE6000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: Row(
                  children: [
                    Flexible(child: LiveStatusPill(status, onImage: true)),
                    const Spacer(),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          maxLines: 1,
                          style: ValText.display(
                            compact ? 26 : 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (mode.isNotEmpty)
                        Text(
                          mode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final style = ValText.display(
      compact ? 30 : 46,
      color: theme.colorScheme.onSurface,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final label = Text(
      context.l10n.liveGameLiveScore.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ValText.label.copyWith(color: colors.muted, fontSize: 11),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Flex(
        direction: compact ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (compact) Flexible(child: label) else label,
          const SizedBox(width: 12, height: 2),
          Semantics(
            label: '${context.l10n.liveGameLiveScore} ${score.text}',
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
