/// "Rank & phong độ" (docs/design/HOME.md §5.3): rank and RR, RR today (or
/// the last day played), the ranked streak and how many games to the next
/// tier. A core card: it shows a skeleton while loading.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../../profile/data/recent_form.dart' show StreakKind;
import '../../../profile/profile_routes.dart';
import '../../../profile/ui/widgets/rank_card.dart' show formatRr;
import '../../data/home_card.dart';
import '../../data/home_rank.dart';
import '../../home_strings.dart';
import '../../providers/home_card_providers.dart';
import '../home_card_frame.dart';

class RankHomeCard extends ConsumerStatefulWidget {
  const RankHomeCard({super.key, required this.puuid});

  final String puuid;

  @override
  ConsumerState<RankHomeCard> createState() => _RankHomeCardState();
}

class _RankHomeCardState extends ConsumerState<RankHomeCard> {
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    _scheduleMidnight();
  }

  /// "Hôm nay" rolls over at the next local midnight: recompute then.
  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = ref.read(clockProvider).now().toLocal();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now) + const Duration(seconds: 1), () {
      if (!mounted) return;
      ref.invalidate(homeRankSnapshotProvider(widget.puuid));
      _scheduleMidnight();
    });
  }

  @override
  void dispose() {
    _midnight?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puuid = widget.puuid;
    final async = ref.watch(homeRankSnapshotProvider(puuid));
    if (async.hasValue) {
      final snap = async.value;
      if (snap == null) return const SizedBox.shrink();
      return HomeCardFrame(
        card: HomeCardId.rank,
        onTap: () => context.go(ProfileRoutes.root),
        child: _RankBody(snap: snap),
      );
    }
    if (async.hasError) {
      return HomeCardFrame(
        card: HomeCardId.rank,
        child: HomeCardError(
          error: async.error!,
          puuid: puuid,
          onRetry: () => ref.invalidate(rankSummaryProvider(puuid)),
        ),
      );
    }
    return const HomeCardSkeleton(kind: HomeSkeletonKind.rank);
  }
}

class _RankBody extends ConsumerWidget {
  const _RankBody({required this.snap});

  final HomeRankSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rank = snap.current;
    final tint = rank.isUnranked
        ? theme.colorScheme.onSurfaceVariant
        : legibleAccent(context, rank.color, min: 3.5);
    final now = ref.watch(clockProvider).now();
    final ranked = !rank.isUnranked;

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: NetImage(
            rank.icon,
            width: 56,
            height: 56,
            showSkeleton: false,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rank.tierName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (ranked)
                Text(
                  formatRr(rank.rr),
                  style: ValText.display(
                    22,
                    color: theme.colorScheme.onSurface,
                  ),
                )
              else if (rank.placementText != null)
                Text(
                  rank.placementText!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else if (snap.previousAct != null)
                Text(
                  HomeStrings.previousAct(snap.previousAct!.tierName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (snap.leaderboard != null)
                Text(
                  HomeStrings.leaderboard(formatNumber(snap.leaderboard!)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (snap.progress != null) ...[
                const SizedBox(height: 8),
                ValProgressBar(
                  value: snap.progress!,
                  height: 4,
                  semanticsLabel: HomeStrings.rankToNext(snap.rrToNext ?? 0),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final chips = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FormRow(snap: snap, now: now),
        if (snap.matchesToNext != null && snap.nextTierName != null)
          _EstimateRow(
            text: HomeStrings.matchesToRankUp(
              snap.matchesToNext!,
              snap.nextTierName!,
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A wide card (tablet) lays the rank and the form side by side.
          if (constraints.maxWidth >= 448) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: identity),
                const SizedBox(width: 20),
                Expanded(child: chips),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [identity, const SizedBox(height: 8), chips],
          );
        },
      ),
    );
  }
}

/// RR today (or the last day played) and the streak, as tappable chips.
class _FormRow extends StatelessWidget {
  const _FormRow({required this.snap, required this.now});

  final HomeRankSnapshot snap;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final day = snap.today ?? snap.lastDay;
    final streak = snap.streak;
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final children = <Widget>[];
    if (day != null) {
      final net = day.netRr;
      final color = net > 0
          ? colors.win
          : net < 0
          ? colors.loss
          : colors.draw;
      final record = HomeStrings.winsLosses(day.wins, day.losses, day.draws);
      final value = formatSignedRr(net);
      final label = snap.today != null
          ? HomeStrings.rrToday(value)
          : HomeStrings.rrOnDay(formatDayHeader(day.date, now), value);
      children.add(
        _ChipButton(
          color: color,
          icon: net > 0
              ? Icons.arrow_drop_up_rounded
              : net < 0
              ? Icons.arrow_drop_down_rounded
              : Icons.remove_rounded,
          label: '$label${HomeStrings.dot}$record',
          semanticsLabel: snap.today != null
              ? HomeStrings.rrTodaySemantics(net, day.wins, day.losses)
              : null,
          onTap: () => unawaited(context.push<Object?>(ProfileRoutes.dailyRr)),
        ),
      );
    } else {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            HomeStrings.noRankedToday,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    if (streak != null) {
      final win = streak.kind == StreakKind.win;
      children.add(
        StatusPill(
          label: win
              ? HomeStrings.winStreak(streak.count)
              : HomeStrings.lossStreak(streak.count),
          color: win ? colors.win : colors.loss,
          icon: win
              ? Icons.local_fire_department_rounded
              : Icons.trending_down_rounded,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// A pill-shaped button with a 48 dp touch target.
class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticsLabel,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String? semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = legibleAccent(context, color, min: 4.5);
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ValRadius.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            widthFactor: 1,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 12, 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(ValRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: fg),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "≈ 9 trận để lên Kim Cương 2 ›".
class _EstimateRow extends StatelessWidget {
  const _EstimateRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => unawaited(context.push<Object?>(ProfileRoutes.rankUp)),
      borderRadius: BorderRadius.circular(ValRadius.small),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 20,
              color: valColorsOf(context).win,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
