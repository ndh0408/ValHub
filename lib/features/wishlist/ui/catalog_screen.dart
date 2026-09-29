import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/format.dart';
import '../data/skin_query.dart';
import '../providers/wishlist_providers.dart';
import '../wishlist_strings.dart';
import 'widgets/catalog_tile.dart';
import 'widgets/skin_filter_bar.dart';

/// S3B "Tất cả skin": every weapon skin of the current content
/// (valorant-api, vi-VN) with search, weapon + edition filters, sort, and a
/// heart on each tile to add it to the active account's wishlist. The grid
/// is built lazily (only visible tiles, and their images, are created).
/// Route `/collection/catalog`.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  SkinQuery _query = const SkinQuery();

  // Memo: filtering ~2 000 skins only when the query or catalog changes,
  // not on every heart tap.
  List<SkinFacts>? _visible;
  SkinCatalog? _visibleCatalog;
  SkinQuery? _visibleQuery;

  List<SkinFacts> _filtered(SkinCatalog catalog) {
    final cached = _visible;
    if (cached != null &&
        identical(_visibleCatalog, catalog) &&
        _visibleQuery == _query) {
      return cached;
    }
    _visibleCatalog = catalog;
    _visibleQuery = _query;
    return _visible = applySkinQuery(catalog.skins, _query);
  }

  Future<void> _refresh(String? puuid) async {
    if (puuid == null) return;
    final pending = ref.refresh(entitlementsProvider(puuid).future);
    try {
      await pending;
    } on Object {
      // "Đã sở hữu" marks are best effort here.
    }
  }

  void _retry() {
    ref.invalidate(contentProvider);
    ref.invalidate(skinCatalogProvider);
  }

  @override
  Widget build(BuildContext context) {
    final puuid = ref.watch(activeAccountProvider)?.puuid;
    return Scaffold(
      appBar: AppBar(title: const Text(WishlistStrings.catalogTitle)),
      body: AsyncValueView<SkinCatalog>(
        value: ref.watch(skinCatalogProvider),
        onRetry: _retry,
        loading: const _CatalogSkeleton(),
        isEmpty: (c) => c.skins.isEmpty,
        empty: const EmptyView(
          message: WishlistStrings.catalogEmpty,
          icon: Icons.style_outlined,
        ),
        data: (catalog) => _body(context, catalog, puuid),
      ),
    );
  }

  Widget _body(BuildContext context, SkinCatalog catalog, String? puuid) {
    final visible = _filtered(catalog);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tileExtent = 118 + 58 * math.max<double>(1, textScale);
    return RefreshIndicator(
      onRefresh: () => _refresh(puuid),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SkinFilterBar(
              query: _query,
              onChanged: (q) => setState(() => _query = q),
              tiers: catalog.tiers,
              weapons: catalog.weapons,
            ),
          ),
          SliverToBoxAdapter(
            child: _CountLine(
              count: visible.length,
              puuid: puuid,
              filtering: _query.isFiltering,
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(
                message: WishlistStrings.noMatch,
                icon: Icons.search_off,
                action: TextButton(
                  onPressed: () => setState(() => _query = _query.cleared()),
                  child: const Text(WishlistStrings.clearFilters),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: tileExtent,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: visible.length,
                itemBuilder: (context, i) => CatalogSkinTile(
                  key: ValueKey(visible[i].uuid),
                  facts: visible[i],
                  db: catalog.db,
                  puuid: puuid,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "1.234 skin · 12 trong wishlist". Only this line listens to the whole
/// wishlist, so a heart tap does not rebuild the grid.
class _CountLine extends ConsumerWidget {
  const _CountLine({
    required this.count,
    required this.puuid,
    required this.filtering,
  });

  final int count;
  final String? puuid;
  final bool filtering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = valColorsOf(context).muted;
    final puuid = this.puuid;
    final inWishlist = puuid == null
        ? null
        : ref.watch(wishlistProvider(puuid).select((s) => s.length));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              WishlistStrings.catalogCount(formatNumber(count)),
              style: theme.textTheme.labelLarge?.copyWith(
                color: filtering ? theme.colorScheme.primary : muted,
              ),
            ),
          ),
          if (inWishlist != null && inWishlist > 0)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 14, color: ValColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      WishlistStrings.catalogInWishlist(
                        formatNumber(inWishlist),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Skeleton(height: 44, radius: 8),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Skeleton(height: 32, radius: 8),
        ),
        SkeletonGrid(itemCount: 6, childAspectRatio: 0.9),
      ],
    );
  }
}
