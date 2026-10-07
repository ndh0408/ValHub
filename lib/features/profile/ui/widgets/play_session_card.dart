import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/labels/competitive_labels.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../data/play_session.dart';
import '../../profile_routes.dart';
import 'profile_widgets.dart';

/// "Phiên vừa chơi": the matches the player just played in one sitting
/// (record, net RR of the ranked ones, K/D · ACS · HS%, time played, the
/// matches in order with their agent). Shown for [kSessionShownFor] after
/// the last match of a session of two matches or more; it reads the match
/// summaries the history list loads anyway, so it costs no extra request.
class PlaySessionCard extends ConsumerWidget {
  const PlaySessionCard({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now();
    final history = ref
        .watch(matchHistoryProvider((puuid: puuid, queue: null)))
        .value;
    if (history == null) return const SizedBox.shrink();
    final entries = latestSessionEntries(history.items);
    final newest = entries.firstOrNull?.startTime;
    // Cheap check before any summary is watched: a match lasts < 2 h.
    if (entries.length < 2 ||
        newest == null ||
        now.difference(newest) > kSessionShownFor + kSessionStartGap) {
      return const SizedBox.shrink();
    }
    final summaries = <MatchPlayerSummary?>[];
    for (final e in entries) {
      final s = ref.watch(
        matchSummaryProvider((matchId: e.matchId, puuid: puuid)),
      );
      // Appear once, complete, rather than growing match by match.
      if (s.isLoading && !s.hasValue) return const SizedBox.shrink();
      summaries.add(s.value);
    }
    final updates = ref.watch(competitiveUpdatesProvider(puuid)).value;
    final session = buildPlaySession(
      entries,
      summaries,
      rrByMatch: {
        for (final u in updates?.items ?? const <CompetitiveUpdate>[])
          u.matchId: u.rrEarned,
      },
    );
    if (session == null || !session.isFresh(now)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _SessionBody(session: session, now: now),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({required this.session, required this.now});

  final PlaySession session;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final form = session.form;
    final start = session.start.toLocal();
    final end = session.end.toLocal();
    final minutes = session.played.inMinutes;
    final top = session.topAgentId == null
        ? null
        : db.agent(session.topAgentId!)?.displayName;
    String fmt(double? v, {int decimals = 0}) => v == null
        ? context.l10n.competitiveNoValue
        : decimals == 0
        ? formatNumber(v.round())
        : formatDecimal(v, decimals);
    return ValCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileSessionTitle.toUpperCase(),
                      style: ValText.label.copyWith(color: muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.fmt.inlineFacts([
                        context.fmt.dayHeader(start, now),
                        '${context.fmt.time(start)}–${context.fmt.time(end)}',
                      ]),
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              if (session.rrNet != null) ...[
                const SizedBox(width: 8),
                RrPill(session.rrNet!),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.profileRecordShort(form.wins, form.losses, form.draws),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            context.fmt.inlineFacts([
              context.l10n.profileMatchCount(form.games),
              if (minutes > 0)
                minutes >= 60
                    ? context.l10n.profileSessionDuration(
                        minutes ~/ 60,
                        minutes % 60,
                      )
                    : context.l10n.commonMinutes(minutes),
              if (top != null)
                context.l10n.profileSessionTopAgent(top, session.topAgentGames),
            ]),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          if (form.hasRoundStats) ...[
            const SizedBox(height: 12),
            StatGrid(
              columns: 3,
              tiles: [
                StatTile(
                  label: context.l10n.profileKd,
                  value: fmt(form.kd, decimals: 2),
                  valueColor: form.kd == null
                      ? null
                      : form.kd! >= 1
                      ? colors.win
                      : colors.loss,
                ),
                StatTile(
                  label: context.l10n.profileAcs,
                  value: fmt(form.acs),
                  tooltip: context.l10n.profileAcsHint,
                ),
                StatTile(
                  label: context.l10n.profileHs,
                  value: form.headshotRate == null
                      ? context.l10n.competitiveNoValue
                      : formatPercent(form.headshotRate!),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in session.matches)
                _SessionMatchChip(match: m, db: db),
            ],
          ),
        ],
      ),
    );
  }
}

/// One match of the session: its agent on a result-coloured tile, with the
/// result glyph (never colour alone, PR-16); opens the match.
class _SessionMatchChip extends StatelessWidget {
  const _SessionMatchChip({required this.match, required this.db});

  final SessionMatch match;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    final color = outcomeColor(context, match.outcome);
    final agent = match.agentId == null ? null : db.agent(match.agentId!);
    final label = context.fmt.inlineFacts([
      context.l10n.matchOutcome(match.outcome),
      ?agent?.displayName,
      if (match.acs != null)
        '${context.l10n.profileAcs} ${formatNumber(match.acs!.round())}',
    ]);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(ValRadius.small),
          onTap: () =>
              unawaited(context.push(ProfileRoutes.match(match.matchId))),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(ValRadius.small),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: NetImage(
                      agent?.displayIconSmall ?? agent?.displayIcon,
                      borderRadius: BorderRadius.circular(4),
                      showSkeleton: false,
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(4),
                        bottomEnd: Radius.circular(ValRadius.small - 1),
                      ),
                    ),
                    child: Icon(
                      outcomeGlyph(match.outcome),
                      size: 12,
                      color: readableOn(color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
