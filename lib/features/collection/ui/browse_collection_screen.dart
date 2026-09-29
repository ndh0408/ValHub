import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/l10n/content_strings.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/currency_amount.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../collection_strings.dart';
import '../data/buddy_options.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../data/skin_query.dart';
import '../providers/collection_providers.dart';
import 'player_card_picker_screen.dart';
import 'widgets/collection_widgets.dart';

/// `:type` of `/collection/browse/:type` (S39).
enum CollectionBrowseType {
  skin('skin', CollectionStrings.browseSkins),
  buddy('buddy', CollectionStrings.browseBuddies),
  spray('spray', CollectionStrings.browseSprays),
  card('card', CollectionStrings.browseCards),
  title('title', CollectionStrings.browseTitles),
  flex('flex', CollectionStrings.browseFlex);

  const CollectionBrowseType(this.path, this.label);

  /// Path segment.
  final String path;
  final String label;

  static CollectionBrowseType parse(String? value) =>
      values.firstWhere((t) => t.path == value, orElse: () => skin);
}

/// S39 "Duyệt bộ sưu tập". Route `/collection/browse/:type`.
class BrowseCollectionScreen extends ConsumerStatefulWidget {
  const BrowseCollectionScreen({super.key, required this.type});

  final CollectionBrowseType type;

  @override
  ConsumerState<BrowseCollectionScreen> createState() =>
      _BrowseCollectionScreenState();
}

class _BrowseCollectionScreenState
    extends ConsumerState<BrowseCollectionScreen> {
  SkinQuery _query = const SkinQuery();

  CollectionBrowseType get _type => widget.type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_type.label)),
      body: CollectionAccountGate(
        builder: (context, account) {
          final puuid = account.puuid;
          return Column(
            children: [
              CollectionSearchField(
                hint: _type == CollectionBrowseType.skin
                    ? CollectionStrings.searchSkins
                    : CollectionStrings.searchItems,
                onChanged: (v) =>
                    setState(() => _query = _query.copyWith(search: v)),
              ),
              if (_type == CollectionBrowseType.skin)
                SkinFilterBar(
                  query: _query,
                  onChanged: (q) => setState(() => _query = q),
                ),
              Expanded(
                child: AsyncValueView(
                  value: ref.watch(ownedItemsProvider(puuid)),
                  puuid: puuid,
                  onRetry: () => ref.invalidate(entitlementsProvider(puuid)),
                  loading: _type == CollectionBrowseType.title
                      ? const SkeletonList(itemHeight: 48)
                      : const CollectionGridSkeleton(),
                  data: (owned) => RefreshIndicator(
                    onRefresh: () => refreshCollection(ref, puuid),
                    child: _buildContent(
                      context,
                      puuid,
                      owned,
                      ref.watch(contentProvider).value ?? ContentDb.empty(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String puuid,
    OwnedItems owned,
    ContentDb db,
  ) {
    switch (_type) {
      case CollectionBrowseType.skin:
        return _skins(context, owned, db);
      case CollectionBrowseType.title:
        final all = ownedTitles(owned, db);
        final titles = [
          for (final t in all)
            if (matchesSearch(_query.search, [t.text, t.displayName])) t,
        ];
        return _scroll(
          summary: _itemsSummary(titles.length, all.length),
          empty: all.isEmpty,
          sliver: SliverList.builder(
            itemCount: titles.length,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.military_tech_outlined),
              title: Text(titles[i].text),
            ),
          ),
          noMatches: titles.isEmpty,
        );
      case CollectionBrowseType.card:
        final all = ownedCards(owned, db);
        final cards = [
          for (final c in all)
            if (matchesSearch(_query.search, [c.displayName])) c,
        ];
        return _scroll(
          summary: _itemsSummary(cards.length, all.length),
          empty: all.isEmpty,
          noMatches: cards.isEmpty,
          sliver: _grid(
            context,
            maxExtent: 130,
            image: 200,
            count: cards.length,
            builder: (context, i) => ArtTile(
              image: cards[i].largeArt ?? cards[i].smallArt,
              label: cards[i].displayName,
              imageFit: BoxFit.cover,
              imagePadding: EdgeInsets.zero,
              onTap: () => unawaited(
                showCardPreview(context, puuid: puuid, card: cards[i]),
              ),
            ),
          ),
        );
      case CollectionBrowseType.spray:
        final all = ownedSprays(owned, db);
        final sprays = [
          for (final s in all)
            if (matchesSearch(_query.search, [s.displayName])) s,
        ];
        return _scroll(
          summary: _itemsSummary(sprays.length, all.length),
          empty: all.isEmpty,
          noMatches: sprays.isEmpty,
          sliver: _grid(
            context,
            maxExtent: 120,
            image: 80,
            count: sprays.length,
            builder: (context, i) => ArtTile(
              image: sprays[i].image,
              label: sprays[i].displayName,
              onTap: () => unawaited(
                _showItemPreview(
                  context,
                  image: sprays[i].animatedImage,
                  name: sprays[i].displayName,
                  type: ContentStrings.itemSpray,
                ),
              ),
            ),
          ),
        );
      case CollectionBrowseType.flex:
        final all = ownedFlex(owned, db);
        final items = [
          for (final f in all)
            if (matchesSearch(_query.search, [f.displayName])) f,
        ];
        return _scroll(
          summary: _itemsSummary(items.length, all.length),
          empty: all.isEmpty,
          noMatches: items.isEmpty,
          sliver: _grid(
            context,
            maxExtent: 120,
            image: 80,
            count: items.length,
            builder: (context, i) => ArtTile(
              image: items[i].displayIcon,
              label: items[i].displayName,
              onTap: () => unawaited(
                _showItemPreview(
                  context,
                  image: items[i].displayIcon,
                  name: items[i].displayName,
                  type: ContentStrings.itemFlex,
                ),
              ),
            ),
          ),
        );
      case CollectionBrowseType.buddy:
        final all = buddyOptions(owned, db, null);
        final items = [
          for (final b in all)
            if (matchesSearch(_query.search, [b.buddy.displayName])) b,
        ];
        return _scroll(
          summary: _itemsSummary(items.length, all.length),
          empty: all.isEmpty,
          noMatches: items.isEmpty,
          sliver: _grid(
            context,
            maxExtent: 120,
            image: 72,
            footer: true,
            count: items.length,
            builder: (context, i) => ArtTile(
              image: items[i].buddy.image,
              label: items[i].buddy.displayName,
              footer: items[i].total > 1
                  ? Text(
                      CollectionStrings.copies(items[i].total),
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  : null,
              onTap: () => unawaited(
                _showItemPreview(
                  context,
                  image: items[i].buddy.image,
                  name: items[i].buddy.displayName,
                  type: ContentStrings.itemBuddy,
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _skins(BuildContext context, OwnedItems owned, ContentDb db) {
    final prices = ref.watch(priceServiceProvider);
    final all = owned.ownedCollectibleSkins;
    final skins = querySkins(all, _query, db: db, prices: prices);
    final value = valueOf(skins, prices);
    final amount = value.isEstimate
        ? formatEstimatedVp(value.totalVp)
        : formatVp(value.totalVp);
    return _scroll(
      summary: SummaryStrip(
        text: _query.isFiltering
            ? CollectionStrings.summaryFiltered(skins.length, amount)
            : CollectionStrings.summarySkins(skins.length, amount),
        caption: value.rewardCount > 0
            ? CollectionStrings.excludedRewards
            : null,
        highlighted: _query.isFiltering,
      ),
      empty: all.isEmpty,
      noMatches: skins.isEmpty,
      sliver: _grid(
        context,
        maxExtent: 200,
        image: 72,
        footer: true,
        count: skins.length,
        builder: (context, i) => SkinGridTile(skin: skins[i], prices: prices),
      ),
    );
  }

  Widget _itemsSummary(int shown, int total) => SummaryStrip(
    text: _query.search.trim().isEmpty
        ? CollectionStrings.summaryItems(total)
        : CollectionStrings.summaryFilteredItems(shown, total),
    highlighted: _query.search.trim().isNotEmpty,
  );

  Widget _scroll({
    required Widget summary,
    required Widget sliver,
    required bool empty,
    required bool noMatches,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: summary),
        if (empty || noMatches)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              message: empty
                  ? CollectionStrings.browseEmpty
                  : CollectionStrings.noResults,
              icon: empty ? Icons.inventory_2_outlined : Icons.search_off,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: sliver,
          ),
      ],
    );
  }

  Widget _grid(
    BuildContext context, {
    required double maxExtent,
    required double image,
    required int count,
    required NullableIndexedWidgetBuilder builder,
    bool footer = false,
  }) => SliverGrid(
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxExtent,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      mainAxisExtent: tileExtent(context, image: image, footer: footer),
    ),
    delegate: SliverChildBuilderDelegate(builder, childCount: count),
  );
}

/// Skin tile of S39: tier tint, image, name and price or reward source.
class SkinGridTile extends ConsumerWidget {
  const SkinGridTile({super.key, required this.skin, required this.prices});

  final WeaponSkin skin;
  final PriceService prices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quote = prices.priceForSkin(skin.uuid);
    final tint = contentTierTint(ref, skin.contentTierUuid);
    final caption = quote.caption;
    final Widget footer;
    if (quote.vp case final vp?) {
      footer = CurrencyAmount.vp(
        vp,
        estimate: quote.isEstimate,
        iconSize: 12,
        style: theme.textTheme.labelSmall,
      );
    } else {
      footer = Text(
        caption ?? CommonStrings.dash,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return ArtTile(
      image: skin.image,
      label: skin.displayName,
      tint: tint == Colors.transparent ? null : tint,
      footer: footer,
      semanticsLabel:
          '${skin.displayName}, '
          '${quote.vp == null ? (caption ?? CommonStrings.dash) : formatVp(quote.vp!)}',
      onTap: () => unawaited(
        showSkinDetailSheet(
          context,
          skinOrLevelUuid: skin.uuid,
          mode: SkinDetailMode.owned,
        ),
      ),
    );
  }
}

/// Large preview of a spray / Flex / buddy.
Future<void> _showItemPreview(
  BuildContext context, {
  required String? image,
  required String name,
  required String type,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  builder: (context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 200, child: NetImage(image, fit: BoxFit.contain)),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              type,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  },
);
