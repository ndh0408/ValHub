import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/currency_amount.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/price_estimate.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../store_routes.dart';
import '../store_strings.dart';
import 'store_screen.dart' show StoreSegment;
import 'widgets/bundle_banner.dart' show bundleArtHeroTag;
import 'widgets/store_ui_bits.dart';

/// S14 "Chi tiết bundle". Route `/store/bundle/:id` where `id` is the
/// storefront bundle `ID` (the valorant-api `DataAssetID` also works).
///
/// Collapsing hero with the bundle art (it flies in from the store banner),
/// the name in big type, description, countdown with the local end time,
/// "Giá bundle · Mua lẻ · Tiết kiệm" summary with VND estimates, then the
/// items grid with individual (and discounted) prices. Tap a skin → S15.
/// Pull-to-refresh reloads the storefront.
class BundleDetailScreen extends ConsumerWidget {
  const BundleDetailScreen({super.key, required this.bundleId});

  final String bundleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const SubPageScaffold(
        title: StoreStrings.bundleDetailTitle,
        body: EmptyView(
          message: CommonStrings.errorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    final puuid = account.puuid;
    final storeAsync = ref.watch(storefrontProvider(puuid));
    final store = storeAsync.value;
    final bundle = store?.bundleById(bundleId);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final content = bundle == null ? null : db.bundleByUuid(bundle.dataAssetId);
    final failed = storeAsync.hasError && !storeAsync.isLoading;
    void retry() => ref.invalidate(storefrontProvider(puuid));
    Future<void> refresh() async {
      try {
        ref.invalidate(storefrontProvider(puuid));
        await ref.read(storefrontProvider(puuid).future);
      } on Object {
        // Rendered with "Thử lại".
      }
    }

    final heroHeight = (MediaQuery.sizeOf(context).width * 9 / 16).clamp(
      180.0,
      320.0,
    );

    if (bundle == null) {
      if (failed) {
        return SubPageScaffold(
          title: StoreStrings.bundleDetailTitle,
          onRefresh: refresh,
          body: ErrorView(
            error: storeAsync.error!,
            onRetry: retry,
            puuid: puuid,
          ),
        );
      }
      if (store != null) {
        return SubPageScaffold(
          title: StoreStrings.bundleDetailTitle,
          onRefresh: refresh,
          body: EmptyView(
            title: StoreStrings.bundleNotFoundTitle,
            message: StoreStrings.bundleNotFound,
            icon: Icons.inventory_2_outlined,
            action: FilledButton.tonal(
              onPressed: () => _backToBundles(context),
              child: const Text(StoreStrings.backToBundles),
            ),
          ),
        );
      }
      // Loading: the skeleton mirrors the final page (hero, title, summary,
      // grid).
      return SubPageScaffold(
        title: StoreStrings.bundleDetailTitle,
        showLargeTitle: false,
        heroHeight: heroHeight,
        hero: const SkeletonShimmer(
          child: Skeleton(height: null, radius: 0, shimmer: false),
        ),
        slivers: const [SliverToBoxAdapter(child: _BundleSkeleton())],
      );
    }

    final name = content?.displayName ?? StoreStrings.bundleDetailTitle;
    final art = content?.displayIcon ?? content?.cardImage;
    return SubPageScaffold(
      title: name,
      showLargeTitle: false,
      heroHeight: heroHeight,
      hero: art == null
          ? null
          : Hero(
              tag: bundleArtHeroTag(bundle.id),
              child: HeroBackdrop(imageUrl: art),
            ),
      onRefresh: refresh,
      slivers: [
        if (failed)
          SliverToBoxAdapter(
            child: ErrorView(
              error: storeAsync.error!,
              onRetry: retry,
              puuid: puuid,
              compact: true,
            ),
          ),
        if (store != null && store.isFromCache)
          SliverToBoxAdapter(
            child: OfflineNotice(receivedAt: store.receivedAt),
          ),
        SliverToBoxAdapter(
          child: _BundleBody(
            bundle: bundle,
            puuid: puuid,
            name: name,
            description: _description(content, name),
          ),
        ),
      ],
    );
  }

  /// valorant-api often repeats the name as the description.
  static String _description(Bundle? content, String name) => {
    for (final d in [content?.description, content?.extraDescription])
      if (d != null &&
          d.trim().isNotEmpty &&
          d.trim().toLowerCase() != name.trim().toLowerCase())
        d.trim(),
  }.join('\n');

  static void _backToBundles(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(StoreRoutes.segment(StoreSegment.bundles));
    } else {
      unawaited(Navigator.of(context).maybePop());
    }
  }
}

class _BundleBody extends ConsumerWidget {
  const _BundleBody({
    required this.bundle,
    required this.puuid,
    required this.name,
    required this.description,
  });

  final StoreBundle bundle;
  final String puuid;
  final String name;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final owned = ref.watch(ownedItemsProvider(puuid)).value;
    final ownedCount = owned == null
        ? 0
        : bundle.items
              .where((i) => owned.owns(i.item.itemTypeId, i.item.itemId))
              .length;
    final expiresAt = bundle.expiresAt;
    final now = ref.watch(clockProvider).now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: muted,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        CountdownRow(
          expiresAt: expiresAt,
          builder: StoreStrings.bundleEndsIn,
          note: expiresAt == null
              ? null
              : StoreStrings.bundleEndsAt(formatWallTime(expiresAt, now)),
          period: const Duration(days: 14),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          trailing: ownedCount > 0
              ? StoreStatChip(
                  icon: Icons.check_circle_outline,
                  label: StoreStrings.bundleOwnedCount(
                    ownedCount,
                    bundle.items.length,
                  ),
                  color: valColorsOf(context).win,
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _PriceSummary(bundle: bundle),
        ),
        if (bundle.wholesaleOnly)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    StoreStrings.bundleWholesaleOnly,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  StoreStrings.bundleItemsTitle,
                  style: ValText.sectionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                StoreStrings.bundleItemCount(bundle.items.length),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        TwoColumnGrid(
          children: [
            for (final item in bundle.items)
              _BundleItemTile(
                key: ValueKey('${item.item.itemTypeId}/${item.item.itemId}'),
                item: item,
                puuid: puuid,
              ),
          ],
        ),
      ],
    );
  }
}

/// "Giá bundle · Mua lẻ · Tiết kiệm" (SUMMARY §9.2), with VND estimates of
/// the price and the savings.
class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.bundle});

  final StoreBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final win = valColorsOf(context).win;
    final isVp = bundle.currencyId == CurrencyIds.vp;
    Widget cell(
      String label,
      int amount, {
      Color? color,
      bool strike = false,
      bool vnd = false,
    }) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: CurrencyAmount(
                currencyId: bundle.currencyId,
                amount: amount,
                strikethrough: strike,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            if (vnd && isVp && amount > 0) PriceEstimate(amount),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
        border: Border.all(
          color: bundle.savings > 0
              ? win.withValues(alpha: 0.35)
              : valColorsOf(context).hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(StoreStrings.bundlePriceLabel, bundle.price, vnd: true),
          const SizedBox(width: 12),
          cell(
            StoreStrings.bundleBuySeparateLabel,
            bundle.itemsTotal,
            strike: bundle.savings > 0,
          ),
          const SizedBox(width: 12),
          cell(
            StoreStrings.bundleSavingsLabel,
            bundle.savings,
            color: win,
            vnd: true,
          ),
        ],
      ),
    );
  }
}

class _BundleItemTile extends ConsumerWidget {
  const _BundleItemTile({super.key, required this.item, required this.puuid});

  final BundleItem item;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final itemRef = db.item(item.item.itemTypeId, item.item.itemId);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final win = valColorsOf(context).win;
    final tint = contentTierTint(
      ref,
      itemRef?.contentTierUuid,
      fallback: valColorsOf(context).muted,
    );
    final owned =
        ref
            .watch(ownedItemsProvider(puuid))
            .value
            ?.owns(item.item.itemTypeId, item.item.itemId) ??
        false;
    final name = itemRef?.name ?? CommonStrings.unknownItem;
    final isSkin = item.item.isSkinLevel;
    final showVnd =
        item.currencyId == CurrencyIds.vp &&
        !item.isFree &&
        item.discountedPrice > 0;

    return TierCard(
      tint: tint,
      semanticsLabel: name,
      onTap: isSkin
          ? () => unawaited(
              showSkinDetailSheet(
                context,
                skinOrLevelUuid: item.item.itemId,
                mode: SkinDetailMode.store,
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: itemRef?.image == null && itemRef != null
                  ? Icon(Icons.text_fields, color: muted, size: 32)
                  : SkinGlowArt(
                      imageUrl: itemRef?.image,
                      tint: tint,
                      padding: const EdgeInsets.all(6),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              [
                ?itemRef?.typeLabel,
                if (item.item.quantity > 1)
                  StoreStrings.quantity(item.item.quantity),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            if (owned) ...[const SizedBox(height: 4), const OwnedBadge()],
            const Spacer(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (item.isDiscounted)
                  CurrencyAmount(
                    currencyId: item.currencyId,
                    amount: item.basePrice,
                    iconSize: 12,
                    strikethrough: true,
                    style: theme.textTheme.bodySmall,
                  ),
                if (item.isFree)
                  Text(
                    StoreStrings.bundleItemFree,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: legibleAccent(context, win),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  CurrencyAmount(
                    currencyId: item.currencyId,
                    amount: item.discountedPrice,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.isDiscounted ? win : null,
                    ),
                  ),
                if (item.isDiscounted && !item.isFree)
                  Text(
                    formatDiscountPercent(item.discountPercent),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: legibleAccent(context, ValColors.red),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            if (showVnd)
              PriceEstimate(
                item.discountedPrice,
                interactive: false,
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the loaded page under the hero: name, description, countdown,
/// the price summary and two rows of item tiles.
class _BundleSkeleton extends StatelessWidget {
  const _BundleSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget tile() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Skeleton(height: null, radius: 12, shimmer: false),
        ),
        SizedBox(height: 10),
        Skeleton(width: 110, height: 14, shimmer: false),
        SizedBox(height: 6),
        Skeleton(width: 70, height: 12, shimmer: false),
        SizedBox(height: 14),
        Skeleton(width: 80, height: 16, shimmer: false),
      ],
    );
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(width: 220, height: 30, shimmer: false),
            const SizedBox(height: 10),
            const Skeleton(height: 12, shimmer: false),
            const SizedBox(height: 6),
            const Skeleton(width: 240, height: 12, shimmer: false),
            const SizedBox(height: 16),
            const Skeleton(width: 170, height: 14, shimmer: false),
            const SizedBox(height: 14),
            const Skeleton(height: 72, radius: 16, shimmer: false),
            const SizedBox(height: 24),
            const Skeleton(width: 180, height: 18, shimmer: false),
            const SizedBox(height: 14),
            for (var r = 0; r < 2; r++) ...[
              if (r > 0) const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: tile()),
                  const SizedBox(width: 12),
                  Expanded(child: tile()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
