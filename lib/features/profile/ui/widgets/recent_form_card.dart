import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../data/recent_form.dart';
import '../../profile_strings.dart';
import '../../providers/profile_providers.dart';
import 'profile_widgets.dart';

/// "Phong độ gần đây": win-rate ring, W/L strip of the last
/// [kRecentFormMatches] matches of the current history filter, the running
/// streak and the per-round stats (K/D · ACS · ADR · HS%).
///
/// - Results (record, win rate, streak) count every decided match of the
///   window; the per-round stats count round-based matches only, so a
///   Deathmatch never turns "ACS" into thousands (PR-02). The scope (queue,
///   map) is written on the card.
/// - It reuses the match summaries the history list already loads (same
///   providers, disk-cached), so it costs no extra request. With a **map
///   filter** it never fetches anything (PR-26): it reads the on-device
///   ledger of your own account, and stays hidden on other players' profiles.
/// - Hidden until at least one match is available.
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
    final FormWindow window;
    if (filter.hasMap) {
      final own = ref.watch(accountProvider(puuid).select((a) => a != null));
      final ledger = own ? ref.watch(matchLedgerProvider(puuid)).value : null;
      if (ledger == null) return const SizedBox.shrink();
      window = selectFormWindow(
        history.items,
        resolve: (e) => ledger.byMatch(e.matchId),
        filter: filter,
      );
    } else {
      // The newest matches are the top of the list: their summaries load
      // anyway, and nothing beyond them is watched.
      window = selectFormWindow(
        history.items.take(kRecentFormMatches),
        resolve: (e) {
          final s = ref
              .watch(matchSummaryProvider((matchId: e.matchId, puuid: puuid)))
              .value;
          return s == null ? null : MatchStatLine.fromSummary(s);
        },
      );
    }
    final form = RecentForm.fromLines(window.lines);
    if (form.isEmpty) return const SizedBox.shrink();
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final queue = filter.queue == null
        ? null
        : db.queueShortName(filter.queue!);
    final map = filter.mapUrl == null
        ? null
        : db.mapByUrl(filter.mapUrl)?.displayName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FormBody(
        form: form,
        scope: ProfileStrings.formScope(queue: queue, map: map),
        pending: filter.hasMap ? window.unresolved : 0,
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({required this.form, required this.scope, this.pending = 0});

  final RecentForm form;

  /// "Mọi chế độ" / "Xếp hạng · Ascent": which matches the card counts.
  final String scope;

  /// Listed matches not looked at yet under a map filter.
  final int pending;

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
                    Text(
                      scope,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
          if (form.hasRoundStats) ...[
            StatGrid(
              columns: form.adr == null ? 3 : 4,
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
                if (form.adr != null)
                  StatTile(label: ProfileStrings.adr, value: fmt(form.adr)),
                StatTile(
                  label: ProfileStrings.hs,
                  value: form.headshotRate == null
                      ? CompetitiveStrings.noValue
                      : formatPercent(form.headshotRate!),
                ),
              ],
            ),
            if (form.roundStatsArePartial) ...[
              const SizedBox(height: 8),
              _FormNote(
                ProfileStrings.formRoundStatsNote(form.roundGames, form.games),
              ),
            ],
          ] else
            const _FormNote(ProfileStrings.formNoRoundStats),
          if (pending > 0) ...[
            const SizedBox(height: 8),
            _FormNote(ProfileStrings.formPending(pending)),
          ],
        ],
      ),
    );
  }
}

/// A muted note under the stat tiles.
class _FormNote extends StatelessWidget {
  const _FormNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Newest-first row of small result squares (green win, red loss, grey
/// draw). Each square also carries a glyph (check, cross, dash), so the
/// result never depends on colour alone (PR-16).
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
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: outcomeColor(context, o),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                outcomeGlyph(o),
                size: 14,
                color: readableOn(outcomeColor(context, o)),
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
