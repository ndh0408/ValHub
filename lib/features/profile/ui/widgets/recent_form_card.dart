import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../data/recent_form.dart';
import '../../profile_strings.dart';
import '../../providers/profile_providers.dart';
import 'profile_widgets.dart';

/// How many of the newest listed matches the form card summarises.
const kRecentFormMatches = 10;

/// "Phong độ gần đây": win-rate ring, W/L strip of the last
/// [kRecentFormMatches] matches of the current history filter, the running
/// streak and average K/D · ACS · HS%.
///
/// It reuses the match summaries the history list already loads (same
/// providers, disk-cached), so it costs no extra request. Hidden until at
/// least one summary is available.
class RecentFormCard extends ConsumerWidget {
  const RecentFormCard({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(matchFilterProvider(puuid));
    final history = ref
        .watch(matchHistoryProvider((puuid: puuid, queue: filter.queue)))
        .value;
    if (history == null || history.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final summaries = <MatchPlayerSummary>[];
    for (final e in history.items) {
      if (summaries.length >= kRecentFormMatches) break;
      final s = ref
          .watch(matchSummaryProvider((matchId: e.matchId, puuid: puuid)))
          .value;
      if (s != null && filter.acceptsMap(s.info.mapId)) summaries.add(s);
    }
    final form = RecentForm.from(summaries);
    if (form.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FormBody(form: form),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({required this.form});

  final RecentForm form;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final rate = form.winRate;
    final streak = form.streakKind;
    String fmt(double? v, {int decimals = 0}) => v == null
        ? CompetitiveStrings.noValue
        : decimals == 0
        ? formatNumber(v.round())
        : formatNumber(double.parse(v.toStringAsFixed(decimals)));
    return ValCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WinRateRing(rate: rate),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ProfileStrings.recentFormTitle.toUpperCase(),
                      style: ValText.label.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ProfileStrings.joined([
                        ProfileStrings.lastMatches(form.games),
                        ProfileStrings.recordShort(
                          form.wins,
                          form.losses,
                          form.draws,
                        ),
                      ]),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _OutcomeStrip(form: form),
                    if (streak != null && form.streak >= 2) ...[
                      const SizedBox(height: 10),
                      StatusPill(
                        label: streak == StreakKind.win
                            ? ProfileStrings.winStreak(form.streak)
                            : ProfileStrings.lossStreak(form.streak),
                        color: streak == StreakKind.win
                            ? colors.win
                            : colors.loss,
                        icon: streak == StreakKind.win
                            ? Icons.local_fire_department_rounded
                            : Icons.trending_down_rounded,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatGrid(
            tiles: [
              StatTile(
                label: ProfileStrings.kd,
                value: fmt(form.kd, decimals: 2),
                valueColor: form.kd == null
                    ? null
                    : form.kd! >= 1
                    ? colors.win
                    : colors.loss,
              ),
              StatTile(
                label: ProfileStrings.acs,
                value: fmt(form.acs),
                tooltip: ProfileStrings.acsHint,
              ),
              StatTile(
                label: ProfileStrings.hs,
                value: form.headshotRate == null
                    ? CompetitiveStrings.noValue
                    : formatPercent(form.headshotRate!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Newest-first row of small result squares (green win, red loss, grey
/// draw).
class _OutcomeStrip extends StatelessWidget {
  const _OutcomeStrip({required this.form});

  final RecentForm form;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: ProfileStrings.formSemantics(form.wins, form.losses, form.games),
      excludeSemantics: true,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final o in form.outcomes)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: outcomeColor(context, o),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circular win-rate gauge with the percentage in Anton.
class _WinRateRing extends StatelessWidget {
  const _WinRateRing({required this.rate});

  final double? rate;

  @override
  Widget build(BuildContext context) {
    final colors = valColorsOf(context);
    final r = rate;
    final color = r == null
        ? colors.draw
        : r >= 0.5
        ? colors.win
        : colors.loss;
    return Semantics(
      container: true,
      label: ProfileStrings.winRate,
      value: r == null ? CompetitiveStrings.noValue : formatPercent(r),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 72,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: r ?? 0),
          duration: ValMotion.slow,
          curve: ValMotion.curve,
          builder: (context, t, child) => CustomPaint(
            painter: _RingPainter(value: t, color: color, track: colors.track),
            child: child,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  r == null ? CompetitiveStrings.noValue : formatPercent(r),
                  maxLines: 1,
                  style: ValText.display(20, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    final v = value.clamp(0.0, 1.0);
    if (v <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * v,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
