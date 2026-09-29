import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
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

/// "Diễn biến vòng đấu" (S43): a strip of round results, then one card per
/// round (end type, ceremony, side, running score, your kills). Tapping a
/// round opens its kill feed: who killed whom, with what, and when in the
/// round.
class RoundTimelineSliver extends StatelessWidget {
  const RoundTimelineSliver({
    super.key,
    required this.details,
    required this.perspective,
    this.hidden = const {},
  });

  final MatchDetails details;
  final String? perspective;

  /// PUUIDs shown as "Người chơi ẩn danh" in the kill feed.
  final Set<String> hidden;

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
      items.add(
        _RoundLine(
          key: ValueKey('round-${row.number}'),
          row: row,
          details: details,
          perspective: perspective,
          hidden: hidden,
        ),
      );
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ValCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 4,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: items,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ProfileStrings.roundsHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
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

/// One round: result strip, number, end type (+ ceremony), your side /
/// plant / kills, the running score and a chevron; expands to the kill
/// feed of the round.
class _RoundLine extends ConsumerStatefulWidget {
  const _RoundLine({
    super.key,
    required this.row,
    required this.details,
    required this.perspective,
    required this.hidden,
  });

  final RoundRow row;
  final MatchDetails details;
  final String? perspective;
  final Set<String> hidden;

  @override
  ConsumerState<_RoundLine> createState() => _RoundLineState();
}

class _RoundLineState extends ConsumerState<_RoundLine> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = widget.row;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final ceremony = db.ceremony(row.round.ceremony)?.displayName;
    final color = _roundColor(context, row.won);
    final muted = theme.colorScheme.onSurfaceVariant;
    final site = row.round.plantSite;
    final facts = [
      ?row.mySide?.label,
      if (site != null && site.isNotEmpty) ProfileStrings.plantedAt(site),
      if (row.myKills > 0) ProfileStrings.roundKills(row.myKills),
      if (row.firstBloodByMe) ProfileStrings.firstBloods,
    ];
    final gold = valColorsOf(context).gold;
    final header = Row(
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
              Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    row.endType.label ?? ProfileStrings.round(row.number),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (ceremony != null && ceremony.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ceremony,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (facts.isNotEmpty)
                Text(
                  ProfileStrings.joined(facts),
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
        const SizedBox(width: 2),
        AnimatedRotation(
          turns: _expanded ? 0.5 : 0,
          duration: ValMotion.fast,
          child: Icon(Icons.expand_more_rounded, size: 20, color: muted),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.small),
          side: theme.brightness == Brightness.light
              ? BorderSide(color: valColorsOf(context).hairline)
              : BorderSide.none,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                button: true,
                expanded: _expanded,
                hint: _expanded
                    ? ProfileStrings.hideKills
                    : ProfileStrings.showKills,
                child: InkWell(
                  onTap: () {
                    Haptics.selection();
                    setState(() => _expanded = !_expanded);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                    child: header,
                  ),
                ),
              ),
              AnimatedSize(
                duration: ValMotion.medium,
                curve: ValMotion.curve,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? _KillFeed(
                        details: widget.details,
                        roundNum: row.round.roundNum,
                        perspective: widget.perspective,
                        hidden: widget.hidden,
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kills of one round in order: time in round, killer (agent + name),
/// the weapon / ability, and the victim. Your team is green, theirs red.
class _KillFeed extends ConsumerWidget {
  const _KillFeed({
    required this.details,
    required this.roundNum,
    required this.perspective,
    required this.hidden,
  });

  final MatchDetails details;
  final int roundNum;
  final String? perspective;
  final Set<String> hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final kills = details.killsInRound(roundNum);
    final hairline = valColorsOf(context).hairline;
    if (kills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(
          ProfileStrings.noKillsInRound,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    final me = details.player(perspective);
    final myTeam = me == null || me.isObserver
        ? (details.sideIds.isEmpty ? null : details.sideIds.first)
        : me.teamId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: hairline),
        const SizedBox(height: 4),
        for (final k in kills)
          _KillRow(
            kill: k,
            details: details,
            db: db,
            myTeam: myTeam,
            perspective: perspective,
            hidden: hidden,
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _KillRow extends StatelessWidget {
  const _KillRow({
    required this.kill,
    required this.details,
    required this.db,
    required this.myTeam,
    required this.perspective,
    required this.hidden,
  });

  final Kill kill;
  final MatchDetails details;
  final ContentDb db;
  final String? myTeam;
  final String? perspective;
  final Set<String> hidden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final killer = details.player(kill.killer);
    final victim = details.player(kill.victim);
    final killerAgent = killer?.characterId == null
        ? null
        : db.agent(killer!.characterId!);
    final victimAgent = victim?.characterId == null
        ? null
        : db.agent(victim!.characterId!);
    String nameOf(MatchPlayer? p, Agent? agent, String subject) =>
        playerDisplayName(
          p?.name,
          hidden: hidden.contains(subject),
          withTag: false,
          fallback: agent?.displayName,
        );
    Color sideColor(MatchPlayer? p) => myTeam == null || p?.teamId == null
        ? theme.colorScheme.onSurface
        : p!.teamId == myTeam
        ? colors.win
        : colors.loss;

    // Weapon (kill-feed icon), ability icon, spike or fall damage.
    final weapon = kill.weaponId == null
        ? null
        : db.weaponOrEquippable(kill.weaponId!);
    final slot = kill.abilitySlot;
    final ability = slot == null ? null : killerAgent?.ability(slot);
    final type = (kill.damageType ?? '').toLowerCase();
    final String? how;
    final Widget howIcon;
    if (weapon != null) {
      how = weapon.displayName;
      howIcon = NetImage(
        weapon.killStreamIcon ?? weapon.displayIcon,
        width: 44,
        height: 16,
        color: muted,
        showSkeleton: false,
        error: Icon(Icons.gps_fixed_rounded, size: 16, color: muted),
      );
    } else if (ability != null) {
      how = ability.displayName;
      howIcon = NetImage(
        ability.displayIcon,
        width: 18,
        height: 18,
        color: muted,
        showSkeleton: false,
        error: Icon(Icons.auto_awesome, size: 16, color: muted),
      );
    } else if (type == 'bomb') {
      how = ProfileStrings.spike;
      howIcon = Icon(
        Icons.local_fire_department_rounded,
        size: 18,
        color: muted,
      );
    } else if (type == 'fall') {
      how = ProfileStrings.fallDamage;
      howIcon = Icon(Icons.south_rounded, size: 18, color: muted);
    } else {
      how = slot == null ? null : ProfileStrings.ability;
      howIcon = Icon(Icons.gps_fixed_rounded, size: 16, color: muted);
    }
    final time = formatMinutesSeconds(
      Duration(milliseconds: kill.roundTime),
      padMinutes: false,
    );
    final killerName = nameOf(killer, killerAgent, kill.killer);
    final victimName = nameOf(victim, victimAgent, kill.victim);
    final isMine =
        perspective != null &&
        (kill.killer == perspective || kill.victim == perspective);
    final nameStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    Widget side(Agent? agent, String name, Color color) => Expanded(
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 24,
              height: 24,
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHigh,
                child: NetImage(
                  agent?.displayIconSmall ?? agent?.displayIcon,
                  width: 24,
                  height: 24,
                  showSkeleton: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: nameStyle?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label: ProfileStrings.killSemantics(killerName, victimName, how, time),
      excludeSemantics: true,
      child: Container(
        color: isMine
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : null,
        padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  time,
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            side(killerAgent, killerName, sideColor(killer)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                width: 44,
                height: 18,
                child: how == null
                    ? Center(child: howIcon)
                    : Tooltip(message: how, child: Center(child: howIcon)),
              ),
            ),
            side(victimAgent, victimName, sideColor(victim)),
          ],
        ),
      ),
    );
  }
}
