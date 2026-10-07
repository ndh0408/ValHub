import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../data/scoreboard_order.dart';
import 'profile_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Column widths of the scoreboard (fit a 360 dp phone; values scale down).
const double _wAcs = 38;
const double _wKda = 26;
const double _wPm = 34;
const double _wHs = 40;
const double _wPlace = 22;

/// "Bảng điểm" (S43): both teams (your team first) with rank icons, ACS,
/// K, D, A, +/− and HS%; Deathmatch shows one list ranked by kills.
class ScoreboardSliver extends StatelessWidget {
  const ScoreboardSliver({
    super.key,
    required this.details,
    required this.perspective,
    required this.onOpenPlayer,
    this.hidden = const {},
  });

  final MatchDetails details;
  final String? perspective;
  final ValueChanged<String> onOpenPlayer;

  /// PUUIDs shown as "Người chơi ẩn danh" (Incognito, SUMMARY U16; see
  /// [MatchPrivacy.hiddenIn]).
  final Set<String> hidden;

  @override
  Widget build(BuildContext context) {
    final sides = scoreboardOrder(details, perspective);
    if (sides.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyView(message: context.l10n.profileNoPlayers),
      );
    }
    // ACS is a per-round average: Deathmatch, Team Deathmatch and Escalation
    // have no rounds, so the column would only repeat the total score.
    final showAcs = details.modeKind.isRoundBased;
    final slivers = <Widget>[];
    for (final side in sides) {
      if (side.freeForAll) {
        slivers
          ..add(
            SliverToBoxAdapter(
              child: _TeamHeader(title: context.l10n.profileAllPlayers),
            ),
          )
          ..add(
            SliverToBoxAdapter(
              child: _TeamCard(
                deathmatch: true,
                showAcs: showAcs,
                rows: [
                  for (var i = 0; i < side.players.length; i++)
                    _PlayerRow(
                      details: details,
                      player: side.players[i],
                      place: i + 1,
                      showAcs: showAcs,
                      hidden: hidden.contains(side.players[i].subject),
                      highlighted: side.players[i].subject == perspective,
                      onTap: () => onOpenPlayer(side.players[i].subject),
                    ),
                ],
              ),
            ),
          );
        continue;
      }
      final title = switch (side.relation) {
        SideRelation.yours => context.l10n.profileYourTeam,
        SideRelation.enemy => context.l10n.profileEnemyTeam,
        SideRelation.neutral => _teamName(context.l10n, side.teamId ?? ''),
      };
      slivers
        ..add(
          SliverToBoxAdapter(
            child: _TeamHeader(
              title: title,
              score: side.score,
              outcome: side.outcome,
              accent: switch (side.relation) {
                SideRelation.yours => _sideColor(context, win: true),
                SideRelation.enemy => _sideColor(context, win: false),
                SideRelation.neutral => null,
              },
            ),
          ),
        )
        ..add(
          SliverToBoxAdapter(
            child: _TeamCard(
              showAcs: showAcs,
              rows: [
                for (final p in side.players)
                  _PlayerRow(
                    details: details,
                    player: p,
                    showAcs: showAcs,
                    hidden: hidden.contains(p.subject),
                    highlighted: p.subject == perspective,
                    onTap: () => onOpenPlayer(p.subject),
                  ),
              ],
            ),
          ),
        );
    }
    return SliverMainAxisGroup(slivers: slivers);
  }

  static String _teamName(AppLocalizations l10n, String teamId) =>
      switch (teamId.toLowerCase()) {
        'blue' => l10n.profileTeamBlue,
        'red' => l10n.profileTeamRed,
        _ => teamId,
      };
}

/// Win / loss accent of a team header.
Color _sideColor(BuildContext context, {required bool win}) =>
    outcomeColor(context, win ? MatchOutcome.win : MatchOutcome.loss);

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({
    required this.title,
    this.score,
    this.outcome,
    this.accent,
  });

  final String title;
  final int? score;
  final MatchOutcome? outcome;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          if (accent != null) ...[
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ValText.sectionTitle.copyWith(
                  fontSize: 17,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (score != null) ...[
            // The score takes the team's result color (the strip on the
            // left is the side: yours green, theirs red).
            Text(
              formatNumber(score!),
              style: ValText.display(
                22,
                color: outcome == null
                    ? accent
                    : outcomeColor(context, outcome!),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (outcome != null) OutcomeTag(outcome!, dense: true),
        ],
      ),
    );
  }
}

/// One team (or the whole Deathmatch lobby) on a rounded card: the column
/// labels, then the player rows separated by hairlines.
class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.rows,
    this.deathmatch = false,
    this.showAcs = true,
  });

  final List<Widget> rows;
  final bool deathmatch;
  final bool showAcs;

  @override
  Widget build(BuildContext context) {
    final hairline = valColorsOf(context).hairline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ValCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: _ColumnHeader(deathmatch: deathmatch, showAcs: showAcs),
            ),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: hairline),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({this.deathmatch = false, this.showAcs = true});

  final bool deathmatch;
  final bool showAcs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.4,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (deathmatch)
            _Cell(context.l10n.profileColPlace, _wPlace, style: style),
          const SizedBox(width: 50),
          const Spacer(),
          if (showAcs)
            Tooltip(
              message: context.l10n.profileAcsHint,
              child: _Cell(context.l10n.profileAcs, _wAcs, style: style),
            ),
          _Cell(context.l10n.profileColK, _wKda, style: style),
          _Cell(context.l10n.profileColD, _wKda, style: style),
          _Cell(context.l10n.profileColA, _wKda, style: style),
          if (!deathmatch)
            _Cell(context.l10n.profileColPlusMinus, _wPm, style: style),
          _Cell(context.l10n.profileHs, _wHs, style: style),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, this.width, {this.style});

  final String text;
  final double width;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Text(text, maxLines: 1, style: style),
    ),
  );
}

class _PlayerRow extends ConsumerWidget {
  const _PlayerRow({
    required this.details,
    required this.player,
    required this.highlighted,
    required this.onTap,
    this.place,
    this.hidden = false,
    this.showAcs = true,
  });

  final MatchDetails details;
  final MatchPlayer player;
  final bool highlighted;
  final VoidCallback onTap;
  final bool hidden;
  final bool showAcs;

  /// Deathmatch position.
  final int? place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final agent = player.characterId == null
        ? null
        : db.agent(player.characterId!);
    final s =
        details.statsFor(player.subject) ??
        ScoreboardStats(subject: player.subject);
    final name = playerDisplayName(
      context.l10n,
      player.name,
      hidden: hidden,
      withTag: false,
      fallback: agent?.displayName,
    );
    final numStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final pm = s.plusMinus;
    return Material(
      color: highlighted
          ? theme.colorScheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: highlighted
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                )
              : null,
          padding: EdgeInsetsDirectional.fromSTEB(
            highlighted ? 9 : 12,
            6,
            12,
            6,
          ),
          child: Row(
            children: [
              if (place != null)
                _Cell(formatNumber(place!), _wPlace, style: numStyle),
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surfaceContainerHigh,
                        border: highlighted
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: ClipOval(
                        child: NetImage(
                          agent?.displayIconSmall ?? agent?.displayIcon,
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                    if (player.competitiveTier > 2)
                      PositionedDirectional(
                        end: 0,
                        bottom: 0,
                        child: RankBadge(
                          tier: player.competitiveTier,
                          seasonId: details.info.seasonId,
                          size: 18,
                          showName: false,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: highlighted ? FontWeight.w700 : null,
                      ),
                    ),
                    if (place == null && s.placement > 0)
                      Text(
                        context.l10n.profilePlacement(s.placement),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (s.isMatchMvp || s.isTeamMvp)
                      Text(
                        s.isMatchMvp
                            ? context.l10n.profileMvp
                            : context.l10n.profileTeamMvp,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: s.isMatchMvp
                              ? valColorsOf(context).gold
                              : theme.colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              if (showAcs)
                _Cell(
                  s.acs == null
                      ? context.l10n.competitiveNoValue
                      : formatNumber(s.acs!.round()),
                  _wAcs,
                  style: numStyle,
                ),
              _Cell(formatNumber(s.kills), _wKda, style: numStyle),
              _Cell(formatNumber(s.deaths), _wKda, style: numStyle),
              _Cell(formatNumber(s.assists), _wKda, style: numStyle),
              if (place == null)
                _Cell(
                  formatSigned(pm),
                  _wPm,
                  style: numStyle?.copyWith(
                    color: pm == 0 ? null : rrColor(context, pm),
                  ),
                ),
              _Cell(
                s.headshotRate == null
                    ? context.l10n.competitiveNoValue
                    : formatPercent(s.headshotRate!),
                _wHs,
                style: numStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
