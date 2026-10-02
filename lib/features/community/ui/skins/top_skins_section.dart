import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/segmented_tabs.dart';
import '../../../../core/util/format.dart';
import '../../community_routes.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/scope_providers.dart';
import '../../providers/skin_vote_providers.dart';
import '../scope/scope_bar.dart';
import '../widgets/community_widgets.dart';
import 'skin_vote_button.dart';
import 'star_rating.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Weapons for the filter chips: by category (sidearms … melee), then name.
List<Weapon> leaderboardWeapons(ContentDb db) {
  final list = [...db.weapons]
    ..sort((a, b) {
      final c = a.category.index.compareTo(b.category.index);
      return c != 0 ? c : a.displayName.compareTo(b.displayName);
    });
  return list;
}

/// Label of a leaderboard sort.
String topSortLabel(TopSort sort) => switch (sort) {
  TopSort.votes => CommunityStrings.sortVotes,
  TopSort.rating => CommunityStrings.sortRating,
  TopSort.reviews => CommunityStrings.sortReviews,
};

/// "Xếp hạng skin": the most-loved / best-rated / most-reviewed skins
/// (all time or this week, per weapon), with a heart per skin and ★ ratings.
/// Tapping a skin opens its review page. Filters are remembered.
class TopSkinsSliver extends ConsumerWidget {
  const TopSkinsSliver({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(topSkinsFilterProvider);
    final scope = ref
        .watch(
          resolvedScopeProvider((puuid: puuid, section: ScopedSection.skins)),
        )
        .value;
    final overrides = ref.watch(skinVoteOverridesProvider(puuid));
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    Widget headerFor([AppliedScope? applied]) =>
        _Filters(filter: filter, db: db, puuid: puuid, applied: applied);
    var header = headerFor();
    if (scope == null) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            SkeletonColumn(
              item: (_) => const TopSkinSkeleton(),
              count: 5,
              spacing: 10,
            ),
          ],
        ),
      );
    }
    final query = (
      puuid: puuid,
      weapon: filter.weapon,
      period: filter.period,
      sort: filter.sort,
      scope: scope,
    );
    final async = ref.watch(topSkinsProvider(query));

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
    final result = async.requireValue;
    final rows = result.rows;
    // Highlight the scope the server really applied.
    header = headerFor(result.applied);
    if (rows.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            CommunityEmptyState(
              icon: Icons.favorite_border_rounded,
              title: context.l10n.communitySkinsEmptyTitle,
              message: context.l10n.communitySkinsEmptyBody,
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
                    : TopSkinRow(row: r, vote: vote, db: db, onVote: onVote),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({
    required this.filter,
    required this.db,
    required this.puuid,
    this.applied,
  });

  final TopSkinsFilter filter;
  final ContentDb db;
  final String puuid;
  final AppliedScope? applied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(topSkinsFilterProvider.notifier);
    final weapons = leaderboardWeapons(db);
    return Column(
      children: [
        ScopeBar(
          section: ScopedSection.skins,
          puuid: puuid,
          applied: applied,
          globalLabel: context.l10n.communityScopeWorldwide,
        ),
        SegmentedTabs<TopPeriod>(
          expand: true,
          tabs: [
            SegmentedTab(
              value: TopPeriod.all,
              label: context.l10n.communityPeriodAllTime,
            ),
            SegmentedTab(
              value: TopPeriod.week,
              label: context.l10n.communityPeriodWeek,
            ),
          ],
          selected: filter.period,
          onChanged: notifier.setPeriod,
        ),
        SizedBox(
          height: 52,
          child: ListView(
            key: const ValueKey('skins-sort'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            children: [
              for (final s in TopSort.values) ...[
                if (s != TopSort.values.first) const SizedBox(width: 8),
                CommunityChip(
                  label: topSortLabel(s),
                  icon: switch (s) {
                    TopSort.votes => Icons.favorite_rounded,
                    TopSort.rating => Icons.star_rounded,
                    TopSort.reviews => Icons.rate_review_rounded,
                  },
                  selected: filter.sort == s,
                  onSelected: () => notifier.setSort(s),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            key: const ValueKey('skins-weapons'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            children: [
              CommunityChip(
                label: context.l10n.communityAllWeapons,
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
  1 => valColorsOf(context).gold,
  2 => const Color(0xFFB8C2CC),
  3 => const Color(0xFFD08C5B),
  _ => Theme.of(context).colorScheme.onSurfaceVariant,
};

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
    final gold = valColorsOf(context).gold;
    final tint = opaqueRgba(tier?.highlightColor, fallback: gold);
    final weapon = db.weaponBySkin(row.skinUuid);
    final name = skin?.displayName ?? context.l10n.commonUnknownItem;
    return Semantics(
      container: true,
      label: context.l10n.communityRankSemantics(formatNumber(row.rank), name),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.card),
          side: BorderSide(color: tint.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => unawaited(openSkinReview(context, row.skinUuid)),
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
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: gold, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.communityRankNumber(formatNumber(1)),
                        style: ValText.display(26, color: gold),
                      ),
                      const Spacer(),
                      HeartButton(
                        active: vote.voted,
                        count: vote.votes,
                        size: 24,
                        semanticsOff: context.l10n.communityVote,
                        semanticsOn: context.l10n.communityUnvote,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: legibleAccent(context, tint),
                    ),
                  ),
                  const SizedBox(height: 6),
                  RatingBadge(rating: row.rating),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A leaderboard row: rank, skin art, name, weapon · tier, ★ rating and a
/// heart with the vote count. Tap → review page.
class TopSkinRow extends StatelessWidget {
  const TopSkinRow({
    super.key,
    required this.row,
    required this.vote,
    required this.db,
    required this.onVote,
  });

  final TopSkin row;
  final SkinVote vote;
  final ContentDb db;
  final VoidCallback? onVote;

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
    final name = skin?.displayName ?? context.l10n.commonUnknownItem;
    return Semantics(
      container: true,
      label: context.l10n.communityRankSemantics(formatNumber(row.rank), name),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => unawaited(openSkinReview(context, row.skinUuid)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                    width: 88,
                    height: 54,
                    padding: const EdgeInsets.all(6),
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
                        if (weapon != null || tier != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            CommunityStrings.dotJoin([
                              ?weapon?.displayName,
                              ?tier?.displayName,
                            ]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: legibleAccent(context, tint),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        RatingBadge(rating: row.rating),
                      ],
                    ),
                  ),
                  HeartButton(
                    active: vote.voted,
                    count: vote.votes,
                    dense: true,
                    semanticsOff: context.l10n.communityVote,
                    semanticsOn: context.l10n.communityUnvote,
                    onTap: onVote,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
