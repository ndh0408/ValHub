import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/l10n/content_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../data/rr_trend.dart';
import '../../profile_strings.dart';
import 'profile_widgets.dart';
import 'rr_trend_chart.dart';

/// Rank card (S40.2, R2/R3): current rank | peak with true-peak RR, act
/// record, RR trend of the last 20 ranked matches and the rank-up hint.
class RankCard extends ConsumerWidget {
  const RankCard({
    super.key,
    required this.puuid,
    this.onOpenRankUp,
    this.showTrend = true,
  });

  final String puuid;

  /// Shows the "≈ n trận để lên …" hint (S41 link) when set.
  final VoidCallback? onOpenRankUp;
  final bool showTrend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(rankSummaryProvider(puuid));
    final value = summary.value;
    if (value == null) {
      if (summary.hasError && !summary.isLoading) {
        return ValCard(
          padding: EdgeInsets.zero,
          child: ErrorView(
            error: summary.error!,
            puuid: puuid,
            compact: true,
            onRetry: () => ref.invalidate(mmrProvider(puuid)),
          ),
        );
      }
      return const Skeleton(height: 168, radius: ValRadius.card);
    }
    return _RankCardBody(
      puuid: puuid,
      summary: value,
      onOpenRankUp: onOpenRankUp,
      showTrend: showTrend,
    );
  }
}

class _RankCardBody extends ConsumerWidget {
  const _RankCardBody({
    required this.puuid,
    required this.summary,
    required this.onOpenRankUp,
    required this.showTrend,
  });

  final String puuid;
  final RankSummary summary;
  final VoidCallback? onOpenRankUp;
  final bool showTrend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final current = summary.current;
    final peak = summary.peak;
    final peakAct = peak?.actUuid == null ? null : db.season(peak!.actUuid!);
    final peakLabel = peakAct == null
        ? ProfileStrings.peakRank
        : ProfileStrings.peakRankOf(viTitleCase(db.actTitle(peakAct)));
    final updates = showTrend
        ? ref.watch(competitiveUpdatesProvider(puuid)).value?.items
        : null;
    final changes = updates == null ? const <int>[] : recentRrChanges(updates);

    return ValCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _RankColumn(
                      label: ProfileStrings.currentRank,
                      rank: current,
                      detail: current.isPlacement
                          ? current.placementText
                          : current.isUnranked
                          ? null
                          : formatRr(current.rr),
                      progress: rankProgress(current)?.fraction,
                    ),
                  ),
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: valColorsOf(context).hairline,
                  ),
                  Expanded(
                    child: peak == null
                        ? _RankColumn(
                            label: ProfileStrings.peakRank,
                            rank: null,
                            detail: ProfileStrings.neverRanked,
                          )
                        : _RankColumn(
                            label: peakLabel,
                            rank: peak.rank,
                            detail: peak.truePeakRr == null
                                ? null
                                : formatRr(peak.truePeakRr!),
                            caption: peak.truePeakFromLocalHistory
                                ? ProfileStrings.truePeakLocal
                                : null,
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (summary.games > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                ProfileStrings.joined([
                  ProfileStrings.actRecord(
                    summary.wins,
                    summary.games,
                    formatPercent(summary.winRate ?? 0),
                  ),
                  if (summary.leaderboardRank case final r?)
                    ProfileStrings.leaderboard(formatNumber(r)),
                ]),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (changes.length >= 2) _TrendRow(changes: changes),
          if (onOpenRankUp != null &&
              !current.isUnranked &&
              current.normalizedTier < kRankUpMaxTier)
            _RankUpHint(puuid: puuid, current: current, onTap: onOpenRankUp!),
        ],
      ),
    );
  }
}

/// "6 RR".
String formatRr(int rr) => ProfileStrings.rrValue(formatNumber(rr));

class _RankColumn extends StatelessWidget {
  const _RankColumn({
    required this.label,
    required this.rank,
    this.detail,
    this.caption,
    this.progress,
  });

  final String label;
  final RankInfo? rank;
  final String? detail;
  final String? caption;

  /// RR progress (0–1) to the next tier.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final r = rank;
    final ranked = r != null && !r.isUnranked;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: ValText.label.copyWith(color: muted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ranked
                  ? RadialGradient(
                      colors: [
                        r.color.withValues(alpha: 0.35),
                        r.color.withValues(alpha: 0),
                      ],
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: r?.largeIcon == null
                ? Icon(Icons.shield_outlined, size: 44, color: muted)
                : NetImage(r!.largeIcon, width: 56, height: 56),
          ),
          const SizedBox(height: 8),
          Text(
            r?.tierName ?? ContentStrings.unranked,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: ranked ? legibleAccent(context, r.color, min: 3.5) : null,
            ),
          ),
          if (detail != null)
            Text(
              detail!,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: ValProgressBar(
                value: progress!,
                height: 4,
                semanticsLabel: ProfileStrings.rrToNext(r?.rr ?? 0),
              ),
            ),
          ],
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.changes});

  final List<int> changes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = changes.fold<int>(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ProfileStrings.joined([
                    ProfileStrings.rrTrendTitle,
                    ProfileStrings.lastMatches(changes.length),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SignedRrText(net, style: theme.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 4),
          RrTrendChart(changes: changes, height: 56),
        ],
      ),
    );
  }
}

class _RankUpHint extends ConsumerWidget {
  const _RankUpHint({
    required this.puuid,
    required this.current,
    required this.onTap,
  });

  final String puuid;
  final RankInfo current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final estimate = ref
        .watch(rankUpEstimateProvider((puuid: puuid, targetTier: null)))
        .value;
    final matches = estimate?.matchesAtCurrentForm;
    final target = RankInfo.resolve(
      db,
      tier: current.normalizedTier + 1,
      actUuid: current.actUuid,
    );
    final text = estimate != null && matches != null && matches > 0
        ? ProfileStrings.rankUpHint(matches, target.tierName)
        : ProfileStrings.rankUpTitle;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
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
                color: theme.colorScheme.primary,
                semanticLabel: ProfileStrings.rankUpOpen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
