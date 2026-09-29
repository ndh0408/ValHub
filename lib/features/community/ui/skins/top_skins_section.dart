import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/skin_vote_providers.dart';
import '../widgets/community_widgets.dart';
import 'skin_vote_button.dart';

/// Weapons for the filter chips: by category (sidearms … melee), then name.
List<Weapon> leaderboardWeapons(ContentDb db) {
  final list = [...db.weapons]
    ..sort((a, b) {
      final c = a.category.index.compareTo(b.category.index);
      return c != 0 ? c : a.displayName.compareTo(b.displayName);
    });
  return list;
}

/// "Xếp hạng skin": most-loved skins (weapon filter, all time / this week),
/// with a heart per skin (one vote per account, optimistic).
class TopSkinsSliver extends ConsumerWidget {
  const TopSkinsSliver({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(topSkinsFilterProvider);
    final query = (puuid: puuid, weapon: filter.weapon, period: filter.period);
    final async = ref.watch(topSkinsProvider(query));
    final overrides = ref.watch(skinVoteOverridesProvider(puuid));
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();

    final header = _Filters(filter: filter, db: db);
    if (!async.hasValue) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            if (async.hasError && !async.isLoading)
              CommunityErrorState(
                error: async.error!,
                puuid: puuid,
                onRetry: () => ref.invalidate(topSkinsProvider(query)),
              )
            else
              SkeletonColumn(
                item: (_) => const TopSkinSkeleton(),
                count: 5,
                spacing: 10,
              ),
          ],
        ),
      );
    }
    final rows = async.requireValue;
    if (rows.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            const CommunityEmptyState(
              icon: Icons.favorite_border_rounded,
              title: CommunityStrings.skinsEmptyTitle,
              message: CommunityStrings.skinsEmptyBody,
            ),
          ],
        ),
      );
    }
    SkinVote voteOf(TopSkin r) => overrides[r.skinUuid] ?? r.vote;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: header),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverList.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final vote = voteOf(r);
              void onVote() => unawaited(
                toggleSkinVote(
                  context,
                  ref,
                  puuid: puuid,
                  vote: vote,
                  weaponUuid: r.weaponUuid ?? db.weaponBySkin(r.skinUuid)?.uuid,
                ),
              );
              return Padding(
                key: ValueKey(r.skinUuid),
                padding: const EdgeInsets.only(bottom: 10),
                child: i == 0 && r.rank == 1
                    ? _ChampionCard(row: r, vote: vote, db: db, onVote: onVote)
                    : _TopSkinRow(row: r, vote: vote, db: db, onVote: onVote),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.filter, required this.db});

  final TopSkinsFilter filter;
  final ContentDb db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(topSkinsFilterProvider.notifier);
    final weapons = leaderboardWeapons(db);
    return Column(
      children: [
        const SizedBox(height: 8),
        GlassSegmentedControl<TopPeriod>(
          height: 38,
          compact: true,
          margin: const EdgeInsets.symmetric(horizontal: 64),
          segments: const [
            GlassSegment(
              value: TopPeriod.all,
              label: CommunityStrings.periodAll,
            ),
            GlassSegment(
              value: TopPeriod.week,
              label: CommunityStrings.periodWeek,
            ),
          ],
          selected: filter.period,
          onChanged: notifier.setPeriod,
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            children: [
              CommunityChip(
                label: CommunityStrings.allWeapons,
                selected: filter.weapon == null,
                onSelected: () => notifier.setWeapon(null),
              ),
              for (final w in weapons) ...[
                const SizedBox(width: 8),
                CommunityChip(
                  key: ValueKey('weapon-${w.uuid}'),
                  label: w.displayName,
                  selected: filter.weapon == w.uuid,
                  onSelected: () => notifier.setWeapon(w.uuid),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Rank number colors of the podium.
Color _podiumColor(BuildContext context, int rank) => switch (rank) {
  1 => ValColors.gold,
  2 => const Color(0xFFC9D3DD),
  3 => const Color(0xFFD08C5B),
  _ => Theme.of(context).colorScheme.onSurfaceVariant,
};

void _openSkin(BuildContext context, String skinUuid) => unawaited(
  showSkinDetailSheet(
    context,
    skinOrLevelUuid: skinUuid,
    mode: SkinDetailMode.catalog,
  ),
);

/// #1 skin: large render on a tier-tinted hero card.
class _ChampionCard extends StatelessWidget {
  const _ChampionCard({
    required this.row,
    required this.vote,
    required this.db,
    required this.onVote,
  });

  final TopSkin row;
  final SkinVote vote;
  final ContentDb db;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skin = db.skinByAnyUuid(row.skinUuid);
    final tier = db.contentTier(skin?.contentTierUuid);
    final tint = opaqueRgba(tier?.highlightColor, fallback: ValColors.gold);
    final weapon = db.weaponBySkin(row.skinUuid);
    final name = skin?.displayName ?? CommonStrings.unknownItem;
    final radius = BorderRadius.circular(ValRadius.card);
    return Semantics(
      container: true,
      label: CommunityStrings.rankSemantics(formatNumber(row.rank), name),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: tint.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openSkin(context, row.skinUuid),
          child: Ink(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.4, -0.3),
                radius: 1.1,
                colors: [
                  tint.withValues(alpha: 0.42),
                  tint.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: ValColors.gold,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        CommunityStrings.rankNumber(formatNumber(1)),
                        style: ValText.display(26, color: ValColors.gold),
                      ),
                      const Spacer(),
                      HeartButton(
                        active: vote.voted,
                        count: vote.votes,
                        size: 24,
                        semanticsOff: CommunityStrings.vote,
                        semanticsOn: CommunityStrings.unvote,
                        onTap: onVote,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 120,
                    child: NetImage(
                      skin?.image,
                      fit: BoxFit.contain,
                      showSkeleton: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CommunityStrings.dotJoin([
                      ?weapon?.displayName,
                      ?tier?.displayName,
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: tint),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopSkinRow extends StatelessWidget {
  const _TopSkinRow({
    required this.row,
    required this.vote,
    required this.db,
    required this.onVote,
  });

  final TopSkin row;
  final SkinVote vote;
  final ContentDb db;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skin = db.skinByAnyUuid(row.skinUuid);
    final tier = db.contentTier(skin?.contentTierUuid);
    final tint = opaqueRgba(
      tier?.highlightColor,
      fallback: valColorsOf(context).muted,
    );
    final weapon = db.weaponBySkin(row.skinUuid);
    final name = skin?.displayName ?? CommonStrings.unknownItem;
    return Semantics(
      container: true,
      label: CommunityStrings.rankSemantics(formatNumber(row.rank), name),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openSkin(context, row.skinUuid),
          child: SizedBox(
            height: 84,
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      formatNumber(row.rank),
                      style: ValText.display(
                        20,
                        color: _podiumColor(context, row.rank),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 96,
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        tint.withValues(alpha: 0.35),
                        tint.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: NetImage(
                    skin?.image,
                    fit: BoxFit.contain,
                    showSkeleton: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (weapon != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          weapon.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                HeartButton(
                  active: vote.voted,
                  count: vote.votes,
                  dense: true,
                  semanticsOff: CommunityStrings.vote,
                  semanticsOn: CommunityStrings.unvote,
                  onTap: onVote,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
