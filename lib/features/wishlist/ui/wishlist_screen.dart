import 'dart:async';

import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/currency_amount.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/ui/price_estimate.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../../store/store_routes.dart';
import '../../store/ui/store_screen.dart' show StoreSegment;
import '../data/skin_query.dart';
import '../data/skin_query_memory.dart';
import '../data/wishlist_view.dart';
import '../providers/wishlist_providers.dart';
import '../wishlist_routes.dart';
import 'widgets/skin_filter_bar.dart';
import 'widgets/wishlist_notification_toggle.dart';
import 'widgets/wishlist_row.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S3A "Wishlist" of the active account. Route `/collection/wishlist`
/// (`?skin=<uuid>` opens that skin's detail sheet: notification deep link).
///
/// Search / edition filter / sort, total value (W7), rows with price and a
/// red "Đang có trong Chợ Đêm!" bar when the skin is in the current
/// storefront (W2), swipe → "Xóa khỏi wishlist" with undo, "+" → S3B, and
/// the "Thông báo wishlist" switch. Pull-to-refresh reloads the storefront.
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key, this.initialSkinUuid, this.linkNonce});

  /// Skin (any skin / level / chroma uuid) whose sheet opens on arrival.
  final String? initialSkinUuid;

  /// Changes on every notification tap: the same skin's sheet reopens.
  final String? linkNonce;

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  late final _memory = SkinQueryMemory(
    ref.read(uiMemoryProvider),
    SkinQueryMemory.wishlist,
  );

  /// Sort + edition filter are remembered (no weapon filter here).
  late SkinQuery _query = _memory.load(rememberWeapon: false);
  String? _openedSkin;
  bool _missReported = false;

  // Memo of the last view (rebuilds are frequent: countdowns, hearts).
  WishlistView? _view;
  Set<String>? _viewWishlist;
  SkinCatalog? _viewCatalog;
  List<WishlistHit>? _viewHits;

  @override
  void initState() {
    super.initState();
    _openInitialSkin();
  }

  @override
  void didUpdateWidget(WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTap =
        widget.linkNonce != null && widget.linkNonce != oldWidget.linkNonce;
    if (widget.initialSkinUuid != oldWidget.initialSkinUuid || newTap) {
      if (newTap) _openedSkin = null;
      _openInitialSkin();
    }
  }

  void _openInitialSkin() {
    final uuid = widget.initialSkinUuid?.trim();
    if (uuid == null || uuid.isEmpty || uuid == _openedSkin) return;
    _openedSkin = uuid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        showSkinDetailSheet(
          context,
          skinOrLevelUuid: uuid,
          mode: SkinDetailMode.catalog,
        ).whenComplete(() {
          // Closed: the same skin may be linked again later.
          if (_openedSkin == uuid) _openedSkin = null;
        }),
      );
    });
  }

  WishlistView _viewFor(
    Set<String> wishlist,
    SkinCatalog catalog,
    List<WishlistHit> hits,
  ) {
    final cached = _view;
    if (cached != null &&
        identical(_viewWishlist, wishlist) &&
        identical(_viewCatalog, catalog) &&
        identical(_viewHits, hits) &&
        cached.query == _query) {
      return cached;
    }
    _viewWishlist = wishlist;
    _viewCatalog = catalog;
    _viewHits = hits;
    return _view = buildWishlistView(
      wishlist: wishlist,
      catalog: catalog,
      hits: hits,
      query: _query,
    );
  }

  void _reportMisses(WishlistView view) {
    if (_missReported || !view.hasUnknown) return;
    _missReported = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(contentMissReporterProvider).report());
    });
  }

  Future<void> _refresh(String puuid) async {
    ref.invalidate(entitlementsProvider(puuid));
    final pending = ref.refresh(storefrontProvider(puuid).future);
    try {
      await pending;
    } on Object {
      // Shown by the compact error row above the list.
    }
  }

  void _retryContent() {
    ref.invalidate(contentProvider);
    ref.invalidate(skinCatalogProvider);
  }

  void _setQuery(SkinQuery next) {
    final previous = _query;
    setState(() => _query = next);
    _memory.save(next, previous: previous);
  }

  void _openCatalog() => unawaited(context.push(WishlistRoutes.catalog));

  void _openSkin(WishlistEntry entry) => unawaited(
    showSkinDetailSheet(
      context,
      skinOrLevelUuid: entry.key,
      mode: SkinDetailMode.catalog,
    ),
  );

  void _openHit(WishlistHit hit) {
    final location = switch (hit.place) {
      WishlistPlace.daily => StoreRoutes.segment(StoreSegment.daily),
      WishlistPlace.nightMarket => StoreRoutes.segment(
        StoreSegment.nightMarket,
      ),
      WishlistPlace.bundle =>
        hit.bundleId == null
            ? StoreRoutes.segment(StoreSegment.bundles)
            : StoreRoutes.bundle(hit.bundleId!),
    };
    context.go(location);
  }

  void _remove(String puuid, WishlistEntry entry, ContentDb db) {
    final notifier = ref.read(wishlistProvider(puuid).notifier);
    final name = entry.facts?.name ?? context.l10n.commonUnknownItem;
    Haptics.light();
    unawaited(notifier.removeSkin(entry.key, db));
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.wishlistRemoved(name)),
          action: SnackBarAction(
            label: context.l10n.wishlistUndo,
            onPressed: () => unawaited(notifier.addSkin(entry.key, db)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return SubPageScaffold(
        title: context.l10n.wishlistTitle,
        body: EmptyView(
          message: context.l10n.commonErrorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    final puuid = account.puuid;
    final catalogValue = ref.watch(skinCatalogProvider);
    final wishlist = ref.watch(wishlistProvider(puuid));
    final hitsValue = ref.watch(wishlistHitsProvider(puuid));
    final owned = ref.watch(ownedItemsProvider(puuid)).value;

    final slivers = <Widget>[
      const SliverToBoxAdapter(child: WishlistNotificationToggle()),
    ];

    final catalog = catalogValue.value;
    final showSearch = catalog != null && wishlist.isNotEmpty;
    if (catalog == null) {
      if (catalogValue.hasError && !catalogValue.isLoading) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              error: catalogValue.error!,
              onRetry: _retryContent,
            ),
          ),
        );
      } else {
        slivers.add(const SliverToBoxAdapter(child: _WishlistSkeleton()));
      }
    } else if (wishlist.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            title: context.l10n.wishlistEmptyTitle,
            message: context.l10n.wishlistEmpty,
            icon: Icons.favorite_border,
            action: FilledButton.icon(
              onPressed: _openCatalog,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.wishlistBrowseCatalog),
            ),
          ),
        ),
      );
    } else {
      final view = _viewFor(
        wishlist,
        catalog,
        hitsValue.value ?? const <WishlistHit>[],
      );
      _reportMisses(view);
      slivers.addAll([
        SliverToBoxAdapter(
          child: SkinFilterChips(
            query: _query,
            onChanged: _setQuery,
            tiers: catalog.tiers,
          ),
        ),
        SliverToBoxAdapter(child: _SummaryStrip(view: view)),
        if (hitsValue.hasError && !hitsValue.isLoading)
          SliverToBoxAdapter(
            child: ErrorView(
              error: hitsValue.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => ref.invalidate(storefrontProvider(puuid)),
            ),
          ),
        if (view.onSaleCount > 0)
          SliverToBoxAdapter(child: _OnSaleBanner(count: view.onSaleCount)),
        if (view.visible.isEmpty)
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
            sliver: SliverList.separated(
              itemCount: view.visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final entry = view.visible[i];
                return _DismissibleRow(
                  key: ValueKey('wishlist-${entry.key}'),
                  entry: entry,
                  owned: owned?.isSkinOwned(entry.key) ?? false,
                  onRemove: () => _remove(puuid, entry, catalog.db),
                  onTap: () => _openSkin(entry),
                  onOpenHit: _openHit,
                );
              },
            ),
          ),
      ]);
    }

    return SubPageScaffold(
      title: context.l10n.wishlistTitle,
      subtitle: context.l10n.wishlistOfAccount(account.riotId),
      actions: [
        IconButton(
          tooltip: context.l10n.wishlistAddSkins,
          icon: const Icon(Icons.add),
          onPressed: _openCatalog,
        ),
      ],
      onRefresh: () => _refresh(puuid),
      header: showSearch
          ? SkinSearchField(query: _query, onChanged: _setQuery)
          : null,
      headerHeight: skinSearchHeaderHeight(context),
      slivers: slivers,
    );
  }
}

class _DismissibleRow extends StatelessWidget {
  const _DismissibleRow({
    super.key,
    required this.entry,
    required this.owned,
    required this.onRemove,
    required this.onTap,
    required this.onOpenHit,
  });

  final WishlistEntry entry;
  final bool owned;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final ValueChanged<WishlistHit> onOpenHit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('dismiss-${entry.key}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(ValRadius.card),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                context.l10n.wishlistRemoveAction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: theme.colorScheme.onError),
          ],
        ),
      ),
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: context.l10n.wishlistRemoveAction):
              onRemove,
        },
        child: WishlistRow(
          entry: entry,
          owned: owned,
          onTap: onTap,
          onOpenHit: onOpenHit,
        ),
      ),
    );
  }
}

/// "Tổng giá trị wishlist" card (W7) with the filtered value when a filter
/// is active.
class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.view});

  final WishlistView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = valColorsOf(context).muted;
    final total = view.total;
    final filtered = view.visibleValue;
    final filteredText = filtered.isEstimate
        ? formatEstimatedVp(filtered.totalVp)
        : formatVp(filtered.totalVp);
    return ValCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.wishlistTotalValue,
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CurrencyAmount.vp(
                      total.totalVp,
                      estimate: total.isEstimate,
                      iconSize: 20,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.wishlistSkinCount(
                  formatNumber(view.entries.length),
                ),
                style: theme.textTheme.labelLarge?.copyWith(color: muted),
              ),
            ],
          ),
          PriceEstimate(total.totalVp),
          if (view.query.isFiltering) ...[
            const SizedBox(height: 6),
            Text(
              context.l10n.wishlistFiltered(
                formatNumber(view.visible.length),
                filteredText,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: legibleAccent(context, theme.colorScheme.primary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (total.rewardCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.wishlistExcludedRewards,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnSaleBanner extends StatelessWidget {
  const _OnSaleBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ValRadius.card),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_outlined, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.wishlistOnSaleBanner(count),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.wishlistOnSaleBannerHint,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistSkeleton extends StatelessWidget {
  const _WishlistSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Skeleton(height: 36, width: 220, radius: 18, shimmer: false),
            const SizedBox(height: 12),
            const Skeleton(height: 76, radius: 16, shimmer: false),
            const SizedBox(height: 12),
            for (var i = 0; i < 4; i++) ...const [
              Skeleton(height: 140, radius: 16, shimmer: false),
              SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
