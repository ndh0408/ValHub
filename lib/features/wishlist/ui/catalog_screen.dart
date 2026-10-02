import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/util/format.dart';
import '../data/skin_query.dart';
import '../data/skin_query_memory.dart';
import '../providers/wishlist_providers.dart';
import 'widgets/catalog_tile.dart';
import 'widgets/skin_filter_bar.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S3B "Tất cả skin": every weapon skin of the current content
/// (valorant-api, vi-VN) with search, weapon + edition filters, sort (the
/// sort and filters are remembered across launches), and a
/// heart on each tile to add it to the active account's wishlist. The grid
/// is built lazily (only visible tiles, and their images, are created).
/// Route `/collection/catalog`.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final _memory = SkinQueryMemory(
    ref.read(uiMemoryProvider),
    SkinQueryMemory.catalog,
  );
  late SkinQuery _query = _memory.load();

  void _setQuery(SkinQuery next) {
    final previous = _query;
    setState(() => _query = next);
    _memory.save(next, previous: previous);
  }

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
    final value = ref.watch(skinCatalogProvider);
    final catalog = value.value;
    final List<Widget> slivers;
    if (catalog != null && catalog.skins.isNotEmpty) {
      slivers = _slivers(context, catalog, puuid);
    } else if (catalog != null) {
      slivers = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            title: context.l10n.wishlistCatalogEmptyTitle,
            message: context.l10n.wishlistCatalogEmpty,
            icon: Icons.style_outlined,
          ),
        ),
      ];
    } else if (value.hasError && !value.isLoading) {
      slivers = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(error: value.error!, onRetry: _retry),
        ),
      ];
    } else {
      slivers = const [SliverToBoxAdapter(child: _CatalogSkeleton())];
    }
    return SubPageScaffold(
      title: context.l10n.wishlistCatalogTitle,
      subtitle: context.l10n.wishlistCatalogSubtitle,
      onRefresh: () => _refresh(puuid),
      header: SkinSearchField(query: _query, onChanged: _setQuery),
      headerHeight: skinSearchHeaderHeight(context),
      slivers: slivers,
    );
  }

  List<Widget> _slivers(
    BuildContext context,
    SkinCatalog catalog,
    String? puuid,
  ) {
    final visible = _filtered(catalog);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tileExtent = 118 + 58 * math.max<double>(1, textScale);
    return [
      SliverToBoxAdapter(
        child: SkinFilterChips(
          query: _query,
          onChanged: _setQuery,
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
            title: context.l10n.wishlistNoMatchTitle,
            message: context.l10n.wishlistNoMatch,
            icon: Icons.search_off,
            action: TextButton(
              onPressed: () => _setQuery(_query.cleared()),
              child: Text(context.l10n.wishlistClearFilters),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: tileExtent,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
    ];
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
              context.l10n.wishlistCatalogCount(formatNumber(count)),
              style: theme.textTheme.labelLarge?.copyWith(
                color: filtering
                    ? legibleAccent(context, theme.colorScheme.primary)
                    : muted,
              ),
            ),
          ),
          if (inWishlist != null && inWishlist > 0)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      context.l10n.wishlistCatalogInWishlist(
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Skeleton(width: 132, height: 36, radius: 18),
              SizedBox(width: 8),
              Skeleton(width: 110, height: 36, radius: 18),
              SizedBox(width: 8),
              Expanded(child: Skeleton(height: 36, radius: 18)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Skeleton(width: 96, height: 16, radius: 8),
        ),
        SkeletonGrid(itemCount: 6, childAspectRatio: 0.8),
      ],
    );
  }
}
