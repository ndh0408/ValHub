import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/sub_page.dart';
import 'skin_catalog_sheet.dart';
import '../../../../core/util/format.dart';
import '../../community_routes.dart';
import '../../data/community_models.dart';
import '../../data/community_exception.dart';
import '../../providers/skin_vote_providers.dart';
import '../widgets/community_widgets.dart';
import 'skin_vote_button.dart';
import 'star_rating.dart';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/riot/riot_ids.dart';

/// Priority list of popular Valorant weapons shown first in the filter bar.
const _kPopularWeapons = [
  SpecialIds.vandal,
  SpecialIds.phantom,
  SpecialIds.operator,
  SpecialIds.melee,
  SpecialIds.sheriff,
  SpecialIds.ghost,
  SpecialIds.spectre,
];

/// Weapons for the filter chips: popular meta weapons first, then by category and name.
List<Weapon> leaderboardWeapons(ContentDb db) {
  final list = [...db.weapons]
    ..sort((a, b) {
      final aPop = _kPopularWeapons.indexOf(a.uuid);
      final bPop = _kPopularWeapons.indexOf(b.uuid);
      if (aPop != -1 && bPop != -1) return aPop.compareTo(bPop);
      if (aPop != -1) return -1;
      if (bPop != -1) return 1;
      final c = a.category.index.compareTo(b.category.index);
      return c != 0 ? c : a.displayName.compareTo(b.displayName);
    });
  return list;
}

/// Label of a leaderboard sort.
String topSortLabel(AppLocalizations l10n, TopSort sort) => switch (sort) {
  TopSort.votes => l10n.communitySortVotes,
  TopSort.rating => l10n.communitySortRating,
  TopSort.reviews => l10n.communitySortReviews,
};

/// "Xếp hạng skin": the most-loved / best-rated / most-reviewed skins
/// (global, all time, per weapon), with a heart per skin and ★ ratings.
/// Tapping a skin opens its review page. Filters are remembered.
class TopSkinsSliver extends ConsumerWidget {
  const TopSkinsSliver({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(topSkinsFilterProvider);
    final overrides = ref.watch(skinVoteOverridesProvider(puuid));
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    Widget headerFor([AppliedScope? applied]) =>
        _Filters(filter: filter, db: db, puuid: puuid, applied: applied);
    var header = headerFor();
    final query = (
      puuid: puuid,
      weapon: filter.weapon,
      period: TopPeriod.all,
      sort: filter.sort,
      scope: ScopeFilter.global,
    );
    final async = ref.watch(topSkinsProvider(query));

    if (!async.hasValue) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            if (async.hasError && !async.isLoading)
              CommunityErrorState(
                compact: true,
                error: async.error!,
                puuid: puuid,
                onRetry: () => ref.invalidate(topSkinsProvider(query)),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      );
    }
    final result = async.requireValue;
    if (result.applied != null &&
        result.applied!.scope != CommunityScope.global) {
      // Never label a regional result as a global ranking.
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            CommunityErrorState(
              compact: true,
              error: const CommunityException(CommunityException.badResponse),
              puuid: puuid,
              onRetry: () => ref.invalidate(topSkinsProvider(query)),
            ),
          ],
        ),
      );
    }
    final rows = result.rows;
    // Highlight the scope the server really applied.
    header = headerFor(result.applied);
    if (rows.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            header,
            Padding(
              key: const ValueKey('skins-ranking-empty-notice'),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.communityRankingEmptyTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(switch (filter.sort) {
                    TopSort.votes => context.l10n.communityRankingEmptyVotes,
                    TopSort.rating => context.l10n.communityRankingEmptyRatings,
                    TopSort.reviews =>
                      context.l10n.communityRankingEmptyReviews,
                  }, style: Theme.of(context).textTheme.bodySmall),
                  if (filter.weapon != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        key: const ValueKey('skins-clear-filters'),
                        onPressed: () => ref
                            .read(topSkinsFilterProvider.notifier)
                            .setWeapon(null),
                        child: Text(context.l10n.communityRankingClear),
                      ),
                    ),
                ],
              ),
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
    final weapon = filter.weapon == null ? null : db.weapon(filter.weapon!);
    Future<void> editFilters() async {
      final selected = await showValSheet<TopSkinsFilter>(
        context,
        title: context.l10n.communityFilters,
        useRootNavigator: true,
        builder: (_, _) => _RankingOptions(initial: filter),
      );
      if (!context.mounted || selected == null) return;
      ref.read(topSkinsFilterProvider.notifier).setFilters(selected);
    }

    Future<void> pickWeapon() async {
      final selected = await showValSheet<String>(
        context,
        title: context.l10n.communityRankingWeapon,
        scrollable: true,
        useRootNavigator: true,
        builder: (sheetContext, controller) => ListView(
          key: const ValueKey('skins-weapons'),
          controller: controller,
          children: [
            ListTile(
              key: const ValueKey('weapon-all'),
              title: Text(sheetContext.l10n.communityAllWeapons),
              selected: filter.weapon == null,
              trailing: filter.weapon == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            for (final w in leaderboardWeapons(db))
              ListTile(
                key: ValueKey('weapon-${w.uuid}'),
                title: Text(w.displayName),
                selected: filter.weapon == w.uuid,
                trailing: filter.weapon == w.uuid
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(sheetContext, w.uuid),
              ),
          ],
        ),
      );
      if (!context.mounted || selected == null) return;
      ref
          .read(topSkinsFilterProvider.notifier)
          .setWeapon(selected.isEmpty ? null : selected);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(context.l10n.communityRankingGlobalAllTime),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: LayoutBuilder(
            builder: (context, box) {
              final weaponButton = OutlinedButton.icon(
                key: const ValueKey('skins-weapon-selector'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () => unawaited(pickWeapon()),
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                label: Text(
                  filter.weapon == null
                      ? context.l10n.communityAllWeapons
                      : weapon?.displayName ?? context.l10n.commonUnknownItem,
                ),
              );
              final sortButton = OutlinedButton.icon(
                key: const ValueKey('skins-filter-selector'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () => unawaited(editFilters()),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(topSortLabel(context.l10n, filter.sort)),
              );
              if (box.maxWidth < 350 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    weaponButton,
                    const SizedBox(height: 4),
                    sortButton,
                  ],
                );
              }
              return Row(
                children: [
                  Flexible(child: weaponButton),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: sortButton),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextButton.icon(
            key: const ValueKey('skins-explore'),
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              alignment: AlignmentDirectional.centerStart,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerLow,
            ),
            onPressed: () =>
                unawaited(showSkinCatalog(context, weapon: filter.weapon)),
            icon: const Icon(Icons.search_rounded),
            label: Text(context.l10n.communityRankingExplore),
          ),
        ),
      ],
    );
  }
}

/// Edits a draft, with one explicit commit; backing out does not send queries.
class _RankingOptions extends StatefulWidget {
  const _RankingOptions({required this.initial});
  final TopSkinsFilter initial;
  @override
  State<_RankingOptions> createState() => _RankingOptionsState();
}

class _RankingOptionsState extends State<_RankingOptions> {
  late TopSkinsFilter _draft = widget.initial;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const ValueKey('skins-sort'),
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.communityRankingSort,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        for (final sort in TopSort.values)
          ListTile(
            key: ValueKey('skins-sort-${sort.name}'),
            selected: _draft.sort == sort,
            leading: Icon(switch (sort) {
              TopSort.votes => Icons.favorite_rounded,
              TopSort.rating => Icons.star_rounded,
              TopSort.reviews => Icons.rate_review_rounded,
            }),
            title: Text(topSortLabel(context.l10n, sort)),
            trailing: _draft.sort == sort ? const Icon(Icons.check) : null,
            onTap: () => setState(() => _draft = _draft.copyWith(sort: sort)),
          ),
        const SizedBox(height: 8),
        FilledButton(
          key: const ValueKey('skins-apply-filters'),
          onPressed: () => Navigator.pop(context, _draft),
          child: Text(context.l10n.communityApply),
        ),
      ],
    ),
  );
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
                    context.fmt.inlineFacts([
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
                            context.fmt.inlineFacts([
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
