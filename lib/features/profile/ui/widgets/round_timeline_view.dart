import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/util/format.dart';
import '../../data/round_timeline.dart';
import '../../profile_strings.dart';

/// Icon of a round end type (VF §8.8).
IconData roundEndIcon(RoundEndType type) => switch (type) {
  RoundEndType.elimination => Icons.gps_fixed_rounded,
  RoundEndType.detonate => Icons.local_fire_department_rounded,
  RoundEndType.defuse => Icons.construction_rounded,
  RoundEndType.timeExpired => Icons.timer_off_outlined,
  RoundEndType.surrendered => Icons.flag_outlined,
  RoundEndType.unknown => Icons.help_outline_rounded,
};

/// "Diễn biến vòng đấu" (S43): a strip of round results, then one line
/// per round (end type, ceremony, side, running score, your kills).
class RoundTimelineSliver extends StatelessWidget {
  const RoundTimelineSliver({
    super.key,
    required this.details,
    required this.perspective,
  });

  final MatchDetails details;
  final String? perspective;

  @override
  Widget build(BuildContext context) {
    final rows = buildRoundRows(details, puuid: perspective);
    if (rows.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyView(message: ProfileStrings.noRounds),
      );
    }
    final showHalves = roundsPerHalf(details.info.queueId) != null;
    final items = <Widget>[];
    MatchHalf? half;
    for (final row in rows) {
      if (showHalves && row.half != half) {
        half = row.half;
        items.add(_HalfHeader(half: row.half));
      }
      items.add(_RoundLine(row: row));
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _RoundStrip(rows: rows, markHalves: showHalves),
        ),
        SliverList.list(children: items),
      ],
    );
  }
}

Color _roundColor(BuildContext context, bool? won) {
  final c = valColorsOf(context);
  return won == null
      ? c.draw
      : won
      ? c.win
      : c.loss;
}

class _RoundStrip extends StatelessWidget {
  const _RoundStrip({required this.rows, required this.markHalves});

  final List<RoundRow> rows;

  /// Draw a side-switch marker between halves / overtime.
  final bool markHalves;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (markHalves && i > 0 && rows[i - 1].half != r.half) {
        items.add(
          Tooltip(
            message: ProfileStrings.sideSwitch,
            child: Container(
              width: 3,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }
      final color = _roundColor(context, r.won);
      items.add(
        Tooltip(
          message: ProfileStrings.joined([
            ProfileStrings.round(r.number),
            if (r.won != null)
              r.won! ? ProfileStrings.roundWon : ProfileStrings.roundLost,
            r.endType.label ?? CompetitiveStrings.noValue,
          ]),
          child: Container(
            width: 26,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border(bottom: BorderSide(color: color, width: 2.5)),
            ),
            child: Icon(roundEndIcon(r.endType), size: 15, color: color),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }
}

class _HalfHeader extends StatelessWidget {
  const _HalfHeader({required this.half});

  final MatchHalf half;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            if (half != MatchHalf.first) ...[
              Icon(Icons.swap_horiz_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                switch (half) {
                  MatchHalf.first => ProfileStrings.firstHalf,
                  MatchHalf.second => ProfileStrings.secondHalf,
                  MatchHalf.overtime => ProfileStrings.overtime,
                },
                style: theme.textTheme.labelMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Divider(height: 1, color: valColorsOf(context).hairline),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundLine extends ConsumerWidget {
  const _RoundLine({required this.row});

  final RoundRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final ceremony = db.ceremony(row.round.ceremony)?.displayName;
    final color = _roundColor(context, row.won);
    final muted = theme.colorScheme.onSurfaceVariant;
    final site = row.round.plantSite;
    final details = [
      ?row.mySide?.label,
      if (site != null && site.isNotEmpty) ProfileStrings.plantedAt(site),
      if (row.myKills > 0) ProfileStrings.roundKills(row.myKills),
      if (row.firstBloodByMe) ProfileStrings.firstBloods,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(ValRadius.small),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: ColoredBox(color: color),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 8, 12, 8),
              child: _content(context, theme, color, muted, ceremony, details),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ThemeData theme,
    Color color,
    Color muted,
    String? ceremony,
    List<String> details,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            formatNumber(row.number),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(color: muted),
          ),
        ),
        const SizedBox(width: 6),
        Icon(roundEndIcon(row.endType), size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      row.endType.label ?? ProfileStrings.round(row.number),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (ceremony != null && ceremony.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: valColorsOf(context).gold
                              .withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ceremony,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: valColorsOf(context).gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (details.isNotEmpty)
                Text(
                  ProfileStrings.joined(details),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ProfileStrings.score(row.myScore, row.otherScore),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
