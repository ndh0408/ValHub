import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../data/live_game_logic.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';
import '../player_loadout_sheet.dart';
import '../providers/live_game_providers.dart';
import 'live_widgets.dart';

/// One roster tab (G5): your team, the enemy team or everyone (FFA).
class LiveRosterList extends ConsumerWidget {
  const LiveRosterList({
    super.key,
    required this.puuid,
    required this.match,
    required this.players,
    this.header,
    this.emptyMessage = LiveGameStrings.emptyTeam,
  });

  /// Signed-in account.
  final String puuid;
  final LiveMatch match;
  final List<LivePlayer> players;
  final Widget? header;
  final String emptyMessage;

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

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          ?header,
          if (players.isEmpty)
            EmptyView(message: emptyMessage, icon: Icons.group_outlined)
          else
            for (final p in players)
              LivePlayerRow(
                key: ValueKey(p.subject),
                player: p,
                match: match,
                isSelf: p.subject == puuid,
                isPartyMember:
                    ownParty != null && partyOf[p.subject] == ownParty,
                partyGroup: groups[p.subject],
                showPeak: showPeak,
                viewerPuuid: puuid,
              ),
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
        ? LiveGameStrings.anonymous
        : playerDisplayName(
            ref.watch(playerNameProvider(player.subject)).value,
            fallback: agent?.displayName,
          );
    final level = visibleAccountLevel(
      player.accountLevel,
      hideAccountLevel: player.hideAccountLevel,
      isSelf: isSelf,
      isPartyMember: isPartyMember,
    );
    final agentLabel = agent?.displayName ?? LiveGameStrings.noAgentYet;
    final subtitle = LiveGameStrings.joinParts([
      if (level != null) LiveGameStrings.level(level),
      agentLabel,
    ]);
    final locked = match.isPregame && player.isLocked;
    final group = partyGroup;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: isSelf
            ? BorderSide(color: theme.colorScheme.primary, width: 1.2)
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AgentPortrait(
                icon: agent?.displayIcon,
                size: 48,
                dimmed: match.isPregame && !locked,
                partyColor: group == null ? null : partyColor(group),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontStyle: hidden ? FontStyle.italic : null,
                      ),
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
                    if (isSelf || group != null || locked) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (isSelf)
                            LiveTag(
                              LiveGameStrings.you,
                              color: theme.colorScheme.primary,
                            ),
                          if (group != null)
                            LiveTag(
                              LiveGameStrings.party,
                              color: partyColor(group),
                              icon: Icons.group,
                            ),
                          if (locked)
                            LiveTag(
                              LiveGameStrings.lockedTag,
                              color: colors.win,
                              icon: Icons.lock,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    _RankLine(puuid: player.subject, showPeak: showPeak),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                semanticLabel: LiveGameStrings.openLoadoutOf(name),
              ),
            ],
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
        : NetImage(icon, width: size, height: size, fit: BoxFit.cover);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: partyColor == null
            ? null
            : Border(left: BorderSide(color: partyColor!, width: 3)),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: Opacity(opacity: dimmed ? 0.55 : 1, child: image),
    );
  }
}

/// Current rank (+ "Cao nhất: …" when [showPeak]) from P-11 (G5, G6).
class _RankLine extends ConsumerWidget {
  const _RankLine({required this.puuid, required this.showPeak});

  final String puuid;
  final bool showPeak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(rankSummaryProvider(puuid));
    final value = summary.value;
    if (value == null) {
      if (summary.hasError && !summary.isLoading) {
        return Text(
          LiveGameStrings.rankUnavailable,
          maxLines: 1,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }
      return const Skeleton(width: 110, height: 14);
    }
    final peak = value.peak?.rank;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _RankChip(rank: value.current),
        if (showPeak && peak != null && !peak.isUnranked)
          _RankChip(rank: peak, prefixPeak: true),
      ],
    );
  }
}

class _RankChip extends StatelessWidget {
  const _RankChip({required this.rank, this.prefixPeak = false});

  final RankInfo rank;
  final bool prefixPeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = prefixPeak
        ? LiveGameStrings.peak(rank.tierName)
        : rank.tierName;
    final color = rank.isUnranked
        ? theme.colorScheme.onSurfaceVariant
        : rank.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NetImage(rank.icon, width: 18, height: 18, showSkeleton: false),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
