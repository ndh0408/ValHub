import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/currency_amount.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../store_strings.dart';
import 'widgets/store_ui_bits.dart';

/// S14 "Chi tiết bundle". Route `/store/bundle/:id` where `id` is the
/// storefront bundle `ID` (the valorant-api `DataAssetID` also works).
///
/// Hero art, name + description, countdown, "Giá bundle · Mua lẻ ·
/// Tiết kiệm" summary and the items grid with individual (and discounted)
/// prices. Tap a skin → S15.
class BundleDetailScreen extends ConsumerWidget {
  const BundleDetailScreen({super.key, required this.bundleId});

  final String bundleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(StoreStrings.bundleDetailTitle)),
        body: const EmptyView(message: CommonStrings.errorNoAccount),
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

    return Scaffold(
      body: AdaptiveRefresh(
        onRefresh: () async {
          try {
            ref.invalidate(storefrontProvider(puuid));
            await ref.read(storefrontProvider(puuid).future);
          } on Object {
            // Rendered below with "Thử lại".
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(
                content?.displayName ?? StoreStrings.bundleDetailTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (bundle != null) ...[
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
                child: _BundleBody(bundle: bundle, puuid: puuid),
              ),
            ] else if (failed)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  error: storeAsync.error!,
                  onRetry: retry,
                  puuid: puuid,
                ),
              )
            else if (store != null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  title: StoreStrings.bundleNotFoundTitle,
                  message: StoreStrings.bundleNotFound,
                  icon: Icons.inventory_2_outlined,
                ),
              )
            else
              const SliverToBoxAdapter(child: _BundleSkeleton()),
          ],
        ),
      ),
    );
  }
}

class _BundleBody extends ConsumerWidget {
  const _BundleBody({required this.bundle, required this.puuid});

  final StoreBundle bundle;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final content = db.bundleByUuid(bundle.dataAssetId);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final name = content?.displayName ?? CommonStrings.unknownItem;
    final owned = ref.watch(ownedItemsProvider(puuid)).value;
    final ownedCount = owned == null
        ? 0
        : bundle.items
              .where((i) => owned.owns(i.item.itemTypeId, i.item.itemId))
              .length;
    // valorant-api often repeats the name as the description.
    final description = {
      for (final d in [content?.description, content?.extraDescription])
        if (d != null &&
            d.trim().isNotEmpty &&
            d.trim().toLowerCase() != name.trim().toLowerCase())
          d.trim(),
    }.join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.card),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: theme.colorScheme.surfaceContainer,
                    child: NetImage(content?.cardImage, fit: BoxFit.cover),
                  ),
                  // Soft bottom fade into the page.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.55, 1],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.toUpperCase(), style: theme.textTheme.headlineMedium),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ],
          ),
        ),
        CountdownRow(
          expiresAt: bundle.expiresAt,
          builder: StoreStrings.bundleEndsIn,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            children: [
              Expanded(
                child: Text(
                  StoreStrings.bundleItemsTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
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
        const SizedBox(height: 32),
      ],
    );
  }
}

/// "Giá bundle · Mua lẻ · Tiết kiệm" (SUMMARY §9.2).
class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.bundle});

  final StoreBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final win = valColorsOf(context).win;
    Widget cell(String label, int amount, {Color? color, bool strike = false}) {
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
          cell(StoreStrings.bundlePriceLabel, bundle.price),
          const SizedBox(width: 12),
          cell(
            StoreStrings.bundleBuySeparateLabel,
            bundle.itemsTotal,
            strike: bundle.savings > 0,
          ),
          const SizedBox(width: 12),
          cell(StoreStrings.bundleSavingsLabel, bundle.savings, color: win),
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
                      color: win,
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
                      color: ValColors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BundleSkeleton extends StatelessWidget {
  const _BundleSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Skeleton(height: null, shimmer: false),
            ),
            SizedBox(height: 16),
            Skeleton(width: 200, height: 28, shimmer: false),
            SizedBox(height: 12),
            Skeleton(width: 160, height: 14, shimmer: false),
            SizedBox(height: 16),
            Skeleton(height: 64, shimmer: false),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Skeleton(height: 180, shimmer: false)),
                SizedBox(width: 12),
                Expanded(child: Skeleton(height: 180, shimmer: false)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
