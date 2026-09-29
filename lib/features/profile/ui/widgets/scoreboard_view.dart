import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/format.dart';
import '../../profile_strings.dart';
import 'profile_widgets.dart';

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
    final players = details.participants;
    if (players.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyView(message: ProfileStrings.noPlayers),
      );
    }
    if (details.modeKind == MatchModeKind.deathmatch) {
      final ranked = [...players]
        ..sort((a, b) {
          final ka = details.statsFor(a.subject)?.kills ?? 0;
          final kb = details.statsFor(b.subject)?.kills ?? 0;
          final c = kb.compareTo(ka);
          return c != 0
              ? c
              : (details.statsFor(b.subject)?.score ?? 0).compareTo(
                  details.statsFor(a.subject)?.score ?? 0,
                );
        });
      return SliverMainAxisGroup(
        slivers: [
          const SliverToBoxAdapter(
            child: _TeamHeader(title: ProfileStrings.allPlayers),
          ),
          const SliverToBoxAdapter(child: _ColumnHeader(deathmatch: true)),
          SliverList.builder(
            itemCount: ranked.length,
            itemBuilder: (context, i) => _PlayerRow(
              details: details,
              player: ranked[i],
              place: i + 1,
              hidden: hidden.contains(ranked[i].subject),
              highlighted: ranked[i].subject == perspective,
              onTap: () => onOpenPlayer(ranked[i].subject),
            ),
          ),
        ],
      );
    }

    final me = details.player(perspective);
    final myTeam = me == null || me.isObserver ? null : me.teamId;
    final sides = [...details.sideIds]
      ..sort((a, b) {
        if (a == myTeam) return -1;
        if (b == myTeam) return 1;
        return 0;
      });
    final slivers = <Widget>[];
    for (final side in sides) {
      final teamPlayers = details.playersOfTeam(side);
      if (teamPlayers.isEmpty) continue;
      final team = details.team(side);
      final title = myTeam == null
          ? _teamName(side)
          : side == myTeam
          ? ProfileStrings.yourTeam
          : ProfileStrings.enemyTeam;
      final outcome = team == null
          ? null
          : team.won
          ? MatchOutcome.win
          : details.teams.any((t) => t.won)
          ? MatchOutcome.loss
          : null;
      slivers
        ..add(
          SliverToBoxAdapter(
            child: _TeamHeader(
              title: title,
              score: team == null
                  ? null
                  : switch (details.modeKind) {
                      MatchModeKind.teamDeathmatch ||
                      MatchModeKind.escalation => team.numPoints,
                      _ => team.roundsWon,
                    },
              outcome: outcome,
              accent: side == myTeam
                  ? _sideColor(context, win: true)
                  : myTeam == null
                  ? null
                  : _sideColor(context, win: false),
            ),
          ),
        )
        ..add(const SliverToBoxAdapter(child: _ColumnHeader()))
        ..add(
          SliverList.builder(
            itemCount: teamPlayers.length,
            itemBuilder: (context, i) => _PlayerRow(
              details: details,
              player: teamPlayers[i],
              hidden: hidden.contains(teamPlayers[i].subject),
              highlighted: teamPlayers[i].subject == perspective,
              onTap: () => onOpenPlayer(teamPlayers[i].subject),
            ),
          ),
        );
    }
    return SliverMainAxisGroup(slivers: slivers);
  }

  static String _teamName(String teamId) => switch (teamId.toLowerCase()) {
    'blue' => ProfileStrings.teamBlue,
    'red' => ProfileStrings.teamRed,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
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
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
          ),
          if (score != null) ...[
            Text(
              formatNumber(score!),
              style: ValText.display(22, color: accent),
            ),
            const SizedBox(width: 8),
          ],
          if (outcome != null) OutcomeTag(outcome!, dense: true),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({this.deathmatch = false});

  final bool deathmatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.4,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (deathmatch) _Cell(ProfileStrings.colPlace, _wPlace, style: style),
          const SizedBox(width: 50),
          const Spacer(),
          Tooltip(
            message: ProfileStrings.acsHint,
            child: _Cell(ProfileStrings.acs, _wAcs, style: style),
          ),
          _Cell(ProfileStrings.colK, _wKda, style: style),
          _Cell(ProfileStrings.colD, _wKda, style: style),
          _Cell(ProfileStrings.colA, _wKda, style: style),
          if (!deathmatch)
            _Cell(ProfileStrings.colPlusMinus, _wPm, style: style),
          _Cell(ProfileStrings.hs, _wHs, style: style),
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
      alignment: Alignment.centerRight,
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
  });

  final MatchDetails details;
  final MatchPlayer player;
  final bool highlighted;
  final VoidCallback onTap;
  final bool hidden;

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
          padding: EdgeInsets.fromLTRB(highlighted ? 13 : 16, 6, 16, 6),
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
                      Positioned(
                        right: 0,
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
                    if (s.isMatchMvp || s.isTeamMvp)
                      Text(
                        s.isMatchMvp
                            ? ProfileStrings.mvp
                            : ProfileStrings.teamMvp,
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
              _Cell(
                s.acs == null
                    ? CompetitiveStrings.noValue
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
                    ? CompetitiveStrings.noValue
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
