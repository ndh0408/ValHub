import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../data/live_game_logic.dart';
import '../data/live_game_models.dart';
import '../player_loadout_sheet.dart';
import '../providers/live_game_providers.dart';
import 'live_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// One roster tab (G5): your team, the enemy team or everyone (FFA).
class LiveRosterList extends ConsumerWidget {
  const LiveRosterList({
    super.key,
    required this.puuid,
    required this.match,
    required this.players,
    this.header,
    this.emptyMessage,
  });

  /// Signed-in account.
  final String puuid;
  final LiveMatch match;
  final List<LivePlayer> players;
  final Widget? header;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (puuid: puuid, matchId: match.matchId);
    final partyOf = ref.watch(livePartyOfProvider(key));
    final groups = partyGroups(
      subjects: match.players.map((p) => p.subject),
      partyOf: partyOf,
    );
    final ownParty = partyOf[puuid];
    final showPeak = ref.watch(
      appSettingsProvider.select((s) => s.showPeakRankInGame),
    );
    Future<void> refresh() =>
        ref.read(liveGameProvider(puuid).notifier).refresh();

    return AdaptiveRefresh(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          12,
          4,
          12,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          ?header,
          if (players.isEmpty)
            EmptyView(
              message: emptyMessage ?? context.l10n.liveGameEmptyTeam,
              icon: Icons.group_outlined,
            )
          else
            for (var i = 0; i < players.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 66,
                  color: valColorsOf(context).hairline,
                ),
              LivePlayerRow(
                key: ValueKey(players[i].subject),
                player: players[i],
                match: match,
                isSelf: players[i].subject == puuid,
                isPartyMember:
                    ownParty != null && partyOf[players[i].subject] == ownParty,
                partyGroup: groups[players[i].subject],
                showPeak: showPeak,
                viewerPuuid: puuid,
              ),
            ],
        ],
      ),
    );
  }
}

/// A roster row: agent, name ("Ẩn danh"), "Cấp 120 · Jett", rank (+ peak),
/// party badge, "BẠN"; tap → S51 loadout.
class LivePlayerRow extends ConsumerWidget {
  const LivePlayerRow({
    super.key,
    required this.player,
    required this.match,
    required this.isSelf,
    required this.viewerPuuid,
    this.isPartyMember = false,
    this.partyGroup,
    this.showPeak = false,
  });

  final LivePlayer player;
  final LiveMatch match;
  final bool isSelf;
  final bool isPartyMember;
  final String viewerPuuid;

  /// Party badge group (null = solo / unknown).
  final int? partyGroup;
  final bool showPeak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final agent = player.characterId == null
        ? null
        : db.agent(player.characterId!);
    final hidden = isIdentityHidden(
      incognito: player.incognito,
      isSelf: isSelf,
      isPartyMember: isPartyMember,
    );
    final name = hidden
        ? context.l10n.liveGameAnonymous
        : playerDisplayName(
            context.l10n,
            ref.watch(playerNameProvider(player.subject)).value,
            fallback: agent?.displayName,
          );
    final level = visibleAccountLevel(
      player.accountLevel,
      hideAccountLevel: player.hideAccountLevel,
      isSelf: isSelf,
      isPartyMember: isPartyMember,
    );
    final agentLabel = agent?.displayName ?? context.l10n.liveGameNoAgentYet;
    final subtitle = context.fmt.nonEmptyFacts([
      if (level != null) context.l10n.liveGameLevel(level),
      agentLabel,
    ]);
    final locked = match.isPregame && player.isLocked;
    final group = partyGroup;

    final strip = group == null ? null : partyColor(group);
    // ValBuddy: flat rows on the sheet; your own row is a tinted card with
    // an accent outline.
    return Material(
      type: isSelf ? MaterialType.canvas : MaterialType.transparency,
      color: isSelf ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ValRadius.small),
        side: isSelf
            ? BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => unawaited(
          showPlayerLoadoutSheet(
            context,
            matchId: match.matchId,
            playerPuuid: player.subject,
            pregame: match.isPregame,
            viewerPuuid: viewerPuuid,
            playerName: name,
          ),
        ),
        child: DecoratedBox(
          // Party grouping: a colored strip on the leading edge, shared by
          // everyone queued together.
          decoration: BoxDecoration(
            border: strip == null
                ? null
                : BorderDirectional(start: BorderSide(color: strip, width: 3)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(strip == null ? 8 : 6, 10, 0, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AgentPortrait(
                  icon: agent?.displayIcon,
                  size: 46,
                  dimmed: match.isPregame && !locked,
                  partyColor: group == null ? null : partyColor(group),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: hidden
                                    ? theme.colorScheme.onSurfaceVariant
                                    : null,
                              ),
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 8),
                            ValBadge(
                              context.l10n.liveGameYou,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (group != null || locked) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (group != null)
                              LiveTag(
                                context.l10n.liveGameParty,
                                color: partyColor(group),
                                icon: Icons.group,
                              ),
                            if (locked)
                              LiveTag(
                                context.l10n.liveGameLockedTag,
                                color: colors.win,
                                icon: Icons.lock,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RankColumn(puuid: player.subject, showPeak: showPeak),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                  semanticLabel: context.l10n.liveGameOpenLoadoutOf(name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgentPortrait extends StatelessWidget {
  const _AgentPortrait({
    required this.icon,
    required this.size,
    this.dimmed = false,
    this.partyColor,
  });

  final String? icon;
  final double size;
  final bool dimmed;
  final Color? partyColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = icon == null
        ? Icon(
            Icons.help_outline,
            size: size * 0.5,
            color: theme.colorScheme.onSurfaceVariant,
          )
        : NetImage(
            icon,
            width: size,
            height: size,
            fit: BoxFit.cover,
            opacity: dimmed ? 0.5 : null,
          );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: partyColor == null
            ? null
            : Border.all(color: partyColor!, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: image,
    );
  }
}

/// Right-hand rank block (ValBuddy): current rank icon with its name
/// under it, and "Cao nhất: …" when [showPeak] (P-11, G5, G6).
class _RankColumn extends ConsumerWidget {
  const _RankColumn({required this.puuid, required this.showPeak});

  final String puuid;
  final bool showPeak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final summary = ref.watch(rankSummaryProvider(puuid));
    final value = summary.value;
    final Widget child;
    if (value == null) {
      child = summary.hasError && !summary.isLoading
          ? Text(
              context.l10n.liveGameRankUnavailable,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            )
          : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Skeleton(width: 30, height: 30, radius: 8),
                SizedBox(height: 4),
                Skeleton(width: 56, height: 10),
              ],
            );
    } else {
      final rank = value.current;
      final peak = value.peak?.rank;
      final color = rank.isUnranked
          ? muted
          : legibleAccent(context, rank.color, min: 3.5);
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NetImage(rank.icon, width: 30, height: 30, showSkeleton: false),
          const SizedBox(height: 2),
          Text(
            rank.tierName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showPeak && peak != null && !peak.isUnranked)
            Text(
              context.l10n.liveGamePeak(peak.tierName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontSize: 10,
              ),
            ),
        ],
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 64, maxWidth: 96),
      child: child,
    );
  }
}
