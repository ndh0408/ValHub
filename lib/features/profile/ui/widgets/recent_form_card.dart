import 'package:valvn/core/l10n/labels/content_labels.dart';

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
import '../../providers/profile_providers.dart';
import 'profile_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
        : db.queueShortName(context.l10n, filter.queue!);
    final map = filter.mapUrl == null
        ? null
        : db.mapByUrl(filter.mapUrl)?.displayName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FormBody(
        form: form,
        scope: context.fmt.inlineFacts([
          queue ?? context.l10n.profileAllModes,
          ?map,
        ]),
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
              WinRateRing(rate: rate),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileRecentFormTitle.toUpperCase(),
                      style: ValText.label.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.fmt.inlineFacts([
                        context.l10n.profileLastMatches(form.games),
                        context.l10n.profileRecordShort(
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
                            ? context.l10n.profileWinStreak(form.streak)
                            : context.l10n.profileLossStreak(form.streak),
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
                if (form.adr != null)
                  StatTile(
                    label: context.l10n.profileAdr,
                    value: fmt(form.adr),
                  ),
                StatTile(
                  label: context.l10n.profileHs,
                  value: form.headshotRate == null
                      ? context.l10n.competitiveNoValue
                      : formatPercent(form.headshotRate!),
                ),
              ],
            ),
            if (form.roundStatsArePartial) ...[
              const SizedBox(height: 8),
              _FormNote(
                context.l10n.profileFormRoundStatsNote(
                  form.roundGames,
                  form.games,
                ),
              ),
            ],
          ] else
            _FormNote(context.l10n.profileFormNoRoundStats),
          if (pending > 0) ...[
            const SizedBox(height: 8),
            _FormNote(context.l10n.profileFormPending(pending)),
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
      label: context.l10n.profileFormSemantics(
        form.wins,
        form.losses,
        form.games,
      ),
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
