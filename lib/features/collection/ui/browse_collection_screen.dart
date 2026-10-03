import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:valvn/core/l10n/labels/economy_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/currency_amount.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/price_estimate.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/skin_art_card.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../data/buddy_options.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../data/query_memory.dart';
import '../data/skin_query.dart';
import '../providers/collection_providers.dart';
import 'player_card_picker_screen.dart';
import 'widgets/collection_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// `:type` of `/collection/browse/:type` (S39).
enum CollectionBrowseType {
  skin('skin'),
  buddy('buddy'),
  spray('spray'),
  card('card'),
  title('title'),
  flex('flex');

  const CollectionBrowseType(this.path);

  /// Path segment.
  final String path;
  String label(AppLocalizations l10n) => switch (this) {
    skin => l10n.collectionBrowseSkins,
    buddy => l10n.collectionBrowseBuddies,
    spray => l10n.collectionBrowseSprays,
    card => l10n.collectionBrowseCards,
    title => l10n.collectionBrowseTitles,
    flex => l10n.collectionBrowseFlex,
  };

  static CollectionBrowseType parse(String? value) =>
      values.firstWhere((t) => t.path == value, orElse: () => skin);
}

/// S39 "Duyệt bộ sưu tập". Route `/collection/browse/:type`.
///
/// Skins: glass search, sort + rarity chips (remembered per screen), a
/// value strip and an image-forward grid (rarity glow / edge, price or
/// reward source). Other types: search + art grid (titles: a list).
class BrowseCollectionScreen extends ConsumerStatefulWidget {
  const BrowseCollectionScreen({super.key, required this.type});

  final CollectionBrowseType type;

  @override
  ConsumerState<BrowseCollectionScreen> createState() =>
      _BrowseCollectionScreenState();
}

class _BrowseCollectionScreenState
    extends ConsumerState<BrowseCollectionScreen> {
  late SkinQuery _query = _type == CollectionBrowseType.skin
      ? readSkinQuery(
          ref.read(uiMemoryProvider),
          CollectionMemoryKeys.browseSkins,
        )
      : const SkinQuery();

  CollectionBrowseType get _type => widget.type;

  void _setQuery(SkinQuery q) {
    setState(() => _query = q);
    if (_type == CollectionBrowseType.skin) {
      writeSkinQuery(
        ref.read(uiMemoryProvider),
        CollectionMemoryKeys.browseSkins,
        q,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) return NoAccountPage(title: _type.label(context.l10n));
    final puuid = account.puuid;
    final isSkin = _type == CollectionBrowseType.skin;
    return SubPageScaffold(
      title: _type.label(context.l10n),
      subtitle: context.l10n.collectionBrowseDescription(_type.path),
      onRefresh: () => refreshCollection(ref, puuid),
      header: SearchStrip(
        search: CollectionSearchField(
          hint: isSkin
              ? context.l10n.collectionSearchSkins
              : context.l10n.collectionSearchItems,
          onChanged: (v) => setState(() => _query = _query.copyWith(search: v)),
        ),
        filters: isSkin
            ? SkinFilterBar(query: _query, onChanged: _setQuery)
            : null,
      ),
      headerHeight: searchStripHeight(context, filters: isSkin),
      slivers: ownedSlivers(
        ref,
        puuid: puuid,
        loading: _skeleton(context),
        data: (owned, db) => _slivers(context, puuid, owned, db),
      ),
    );
  }

  /// Loading state with the same tile size / count of columns as the grid.
  Widget _skeleton(BuildContext context) => switch (_type) {
    CollectionBrowseType.title => const SkeletonList(
      itemCount: 6,
      itemHeight: 58,
      spacing: 8,
    ),
    CollectionBrowseType.skin => SkeletonTileGrid(
      maxExtent: 220,
      tileHeight: skinCardExtent(context),
      spacing: 12,
      rows: 3,
    ),
    CollectionBrowseType.card => SkeletonTileGrid(
      maxExtent: 130,
      tileHeight: tileExtent(context, image: 200),
    ),
    CollectionBrowseType.buddy => SkeletonTileGrid(
      maxExtent: 120,
      tileHeight: tileExtent(context, image: 72, footer: true),
    ),
    _ => SkeletonTileGrid(
      maxExtent: 120,
      tileHeight: tileExtent(context, image: 80),
    ),
  };

  List<Widget> _slivers(
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
            if (matchesSearch(_query.search, [
              t.localizedText(context.l10n),
              t.displayName,
            ]))
              t,
        ];
        return _list(
          summary: _itemsSummary(titles.length, all.length),
          empty: all.isEmpty,
          noMatches: titles.isEmpty,
          sliver: SliverList.separated(
            itemCount: titles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _TitleRow(text: titles[i].localizedText(context.l10n)),
          ),
        );
      case CollectionBrowseType.card:
        final all = ownedCards(owned, db);
        final cards = [
          for (final c in all)
            if (matchesSearch(_query.search, [c.displayName])) c,
        ];
        return _list(
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
        return _list(
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
                  image: sprays[i].animatedImage ?? sprays[i].image,
                  name: sprays[i].displayName,
                  type: context.l10n.contentItemSpray,
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
        return _list(
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
                  type: context.l10n.contentItemFlex,
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
        return _list(
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
                      context.l10n.collectionCopies(items[i].total),
                      style: Theme.of(context).textTheme.labelSmall,
                    )
                  : null,
              onTap: () => unawaited(
                _showItemPreview(
                  context,
                  image: items[i].buddy.image,
                  name: items[i].buddy.displayName,
                  type: context.l10n.contentItemBuddy,
                ),
              ),
            ),
          ),
        );
    }
  }

  List<Widget> _skins(BuildContext context, OwnedItems owned, ContentDb db) {
    final prices = ref.watch(priceServiceProvider);
    final all = owned.ownedCollectibleSkins;
    final skins = querySkins(all, _query, db: db, prices: prices);
    final value = valueOf(skins, prices);
    final amount = value.isEstimate
        ? formatEstimatedVp(value.totalVp)
        : formatVp(value.totalVp);
    final imageFlex = skinCardImageFlex(context);
    return _list(
      summary: SummaryStrip(
        text: _query.isFiltering
            ? context.l10n.collectionSummaryFiltered(skins.length, amount)
            : context.l10n.collectionSummarySkins(skins.length, amount),
        caption: value.rewardCount > 0
            ? context.l10n.collectionExcludedRewards
            : null,
        highlighted: _query.isFiltering,
        trailing: value.totalVp > 0 ? PriceEstimate(value.totalVp) : null,
      ),
      empty: all.isEmpty,
      noMatches: skins.isEmpty,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: skinCardExtent(context),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => SkinGridTile(
            key: ValueKey(skins[i].uuid),
            skin: skins[i],
            prices: prices,
            imageFlex: imageFlex,
          ),
          childCount: skins.length,
        ),
      ),
    );
  }

  Widget _itemsSummary(int shown, int total) => SummaryStrip(
    text: _query.search.trim().isEmpty
        ? context.l10n.collectionSummaryItems(total)
        : context.l10n.collectionSummaryFilteredItems(shown, total),
    highlighted: _query.search.trim().isNotEmpty,
  );

  /// Summary line, then the items — or the empty / no-match state.
  List<Widget> _list({
    required Widget summary,
    required Widget sliver,
    required bool empty,
    required bool noMatches,
  }) => [
    SliverToBoxAdapter(child: summary),
    if (empty || noMatches)
      SliverFillRemaining(
        hasScrollBody: false,
        child: empty
            ? EmptyView(
                title: context.l10n.collectionBrowseEmptyTitle,
                message: context.l10n.collectionBrowseEmpty,
                icon: Icons.inventory_2_outlined,
              )
            : EmptyView(
                title: context.l10n.collectionNoResultsTitle,
                message: context.l10n.collectionNoResults,
                icon: Icons.search_off,
                action: _query.tiers.isEmpty
                    ? null
                    : OutlinedButton.icon(
                        onPressed: () => _setQuery(_query.copyWith(tiers: {})),
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: Text(context.l10n.collectionClearTiers),
                      ),
              ),
      )
    else
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        sliver: sliver,
      ),
  ];

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

/// One owned title: a rounded row with a gold medal tile.
class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ValCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconTile(
            icon: Icons.military_tech_outlined,
            color: valColorsOf(context).gold,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skin card of S39: large render on the rarity glow, rarity tag, name and
/// the price at store prices, or the reward source ("Phần thưởng Battle
/// Pass") for contract skins.
class SkinGridTile extends ConsumerWidget {
  const SkinGridTile({
    super.key,
    required this.skin,
    required this.prices,
    this.imageFlex = 5,
  });

  final WeaponSkin skin;
  final PriceService prices;
  final int imageFlex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quote = prices.priceForSkin(skin.uuid);
    final color = skinTierColor(ref, context, skin.contentTierUuid);
    final tierName = skinTierName(ref, context, skin.contentTierUuid);
    final caption = quote.caption(context.l10n);
    final Widget footer;
    if (quote.vp case final vp?) {
      footer = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: CurrencyAmount.vp(
          vp,
          estimate: quote.isEstimate,
          iconSize: 13,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      footer = Row(
        children: [
          Icon(
            quote.isReward ? Icons.card_giftcard : Icons.remove_circle_outline,
            size: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              caption ?? context.l10n.commonDash,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }
    return SkinArtCard(
      imageUrl: skin.image,
      name: skin.displayName,
      tierColor: color,
      imageFlex: imageFlex,
      topStart: tierName == null
          ? null
          : TierTag(label: tierName, color: color),
      footer: footer,
      semanticsLabel:
          '${skin.displayName}, '
          '${quote.vp == null ? (caption ?? context.l10n.commonDash) : formatVp(quote.vp!)}',
      onTap: () {
        Haptics.selection();
        unawaited(
          showSkinDetailSheet(
            context,
            skinOrLevelUuid: skin.uuid,
            mode: SkinDetailMode.owned,
          ),
        );
      },
    );
  }
}

/// Large preview of a spray / Flex / buddy on a soft glow, in the shared
/// sheet chrome (name + type, close button).
Future<void> _showItemPreview(
  BuildContext context, {
  required String? image,
  required String name,
  required String type,
}) => showValSheet<void>(
  context,
  title: name,
  subtitle: type,
  builder: (context, _) {
    final accent = Theme.of(context).colorScheme.primary;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ValRadius.card),
            gradient: RadialGradient(
              radius: 0.85,
              colors: [
                accent.withValues(alpha: 0.2),
                accent.withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: SizedBox(
            height: 240,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: NetImage(image, fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  },
);
