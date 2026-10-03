/// "Cửa hàng hôm nay" (docs/design/HOME.md §5.2): the four daily skins, a
/// countdown to the reset, wishlist matches, the wallet and the Night Market.
/// A core card: it shows a skeleton while loading.
library;

import '../../../../core/l10n/labels/economy_labels.dart';

import 'package:valvn/core/l10n/labels/view_labels.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/countdown_ring.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../../store/store_routes.dart';
import '../../../store/ui/store_screen.dart' show StoreSegment;
import '../../data/home_card.dart';
import '../../data/home_store.dart';
import '../../providers/home_card_providers.dart';
import '../home_card_frame.dart';

import 'package:valvn/core/l10n/l10n.dart';

class StoreHomeCard extends ConsumerStatefulWidget {
  const StoreHomeCard({super.key, required this.puuid});

  final String puuid;

  @override
  ConsumerState<StoreHomeCard> createState() => _StoreHomeCardState();
}

class _StoreHomeCardState extends ConsumerState<StoreHomeCard> {
  /// Storefront (by receive time) already checked for content misses.
  DateTime? _missChecked;

  void _reportMiss(HomeStoreSummary summary) {
    if (!summary.hasContentMiss || _missChecked == summary.receivedAt) return;
    _missChecked = summary.receivedAt;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(contentMissReporterProvider).report());
    });
  }

  @override
  Widget build(BuildContext context) {
    final puuid = widget.puuid;
    final async = ref.watch(homeStoreSummaryProvider(puuid));
    if (async.hasValue) {
      final summary = async.value;
      if (summary == null) return const SizedBox.shrink();
      _reportMiss(summary);
      return _StoreBody(summary: summary, puuid: puuid);
    }
    if (async.hasError) {
      return HomeCardFrame(
        card: HomeCardId.store,
        child: HomeCardError(
          error: async.error!,
          puuid: puuid,
          onRetry: () {
            ref
              ..retryContentIfFailed()
              ..invalidate(storefrontProvider(puuid));
          },
        ),
      );
    }
    return const HomeCardSkeleton(kind: HomeSkeletonKind.store);
  }
}

({Color color, String? name}) _tierOf(
  AppLocalizations l10n,
  ContentDb db,
  String? uuid,
  Color fallback,
) {
  if (uuid == null) return (color: fallback, name: null);
  final tier = db.contentTier(uuid) ?? ContentFallbacks.contentTier(uuid);
  if (tier == null) return (color: fallback, name: null);
  return (
    color: opaqueRgba(tier.highlightColor, fallback: fallback),
    name: tier.shortName(l10n, contentLanguage: db.language),
  );
}

class _StoreBody extends ConsumerWidget {
  const _StoreBody({required this.summary, required this.puuid});

  final HomeStoreSummary summary;
  final String puuid;

  void _openStore(BuildContext context, StoreSegment segment) =>
      context.go(StoreRoutes.segment(segment));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final muted = theme.colorScheme.onSurfaceVariant;
    final footer = <String>[
      if (summary.totalVp > 0)
        context.l10n.homeStoreTotal(context.fmt.vp(summary.totalVp)),
      if (summary.walletVp != null)
        summary.affordableTogether > 0
            ? context.l10n.homeStoreWalletCanBuy(
                context.fmt.vp(summary.walletVp!),
                summary.affordableTogether,
              )
            : context.l10n.homeStoreWallet(context.fmt.vp(summary.walletVp!)),
    ];
    return HomeCardFrame(
      card: HomeCardId.store,
      onTap: () => _openStore(context, StoreSegment.daily),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (summary.resetsAt != null && summary.daily.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _ResetPill(
                key: ValueKey(summary.resetsAt),
                expiresAt: summary.resetsAt!,
              ),
            ),
          if (summary.hits.isNotEmpty) ...[
            const SizedBox(height: 12),
            _WishlistBanner(
              hits: summary.hits,
              db: db,
              onOpen: (hit) => _openHit(context, hit),
            ),
          ],
          if (summary.daily.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Tiles(offers: summary.daily, db: db),
          ],
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              footer.join(context.l10n.homeDot),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
          if (summary.nightMarket != null) ...[
            const SizedBox(height: 12),
            _NightMarketRow(
              market: summary.nightMarket!,
              db: db,
              onTap: () => _openStore(context, StoreSegment.nightMarket),
            ),
          ],
          if (summary.isFromCache)
            HomeCardFootnote(
              context.l10n.commonUpdatedAt(formatTime(summary.receivedAt)),
            ),
        ],
      ),
    );
  }

  void _openHit(BuildContext context, WishlistHit hit) {
    switch (hit.place) {
      case WishlistPlace.daily:
        _openStore(context, StoreSegment.daily);
      case WishlistPlace.nightMarket:
        _openStore(context, StoreSegment.nightMarket);
      case WishlistPlace.bundle:
        final id = hit.bundleId;
        if (id == null) {
          _openStore(context, StoreSegment.bundles);
        } else {
          unawaited(context.push<Object?>(StoreRoutes.bundle(id)));
        }
    }
  }
}

/// "Làm mới sau 11:54:37", then "Đang làm mới…" until the new storefront
/// arrives (the provider refetches by itself at the deadline).
class _ResetPill extends StatefulWidget {
  const _ResetPill({super.key, required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_ResetPill> createState() => _ResetPillState();
}

class _ResetPillState extends State<_ResetPill> {
  bool _expired = false;

  @override
  Widget build(BuildContext context) {
    if (_expired) {
      final theme = Theme.of(context);
      return Text(
        context.l10n.homeStoreRefreshing,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return ExcludeSemantics(
      child: CountdownPill(
        expiresAt: widget.expiresAt,
        period: const Duration(days: 1),
        builder: context.l10n.homeStoreResetsIn,
        dense: true,
        onExpired: () {
          if (mounted) setState(() => _expired = true);
        },
      ),
    );
  }
}

class _WishlistBanner extends StatelessWidget {
  const _WishlistBanner({
    required this.hits,
    required this.db,
    required this.onOpen,
  });

  final List<WishlistHit> hits;
  final ContentDb db;
  final ValueChanged<WishlistHit> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final red = theme.colorScheme.primary;
    final first = hits.first;
    final title = hits.length == 1
        ? context.l10n.homeStoreWishlistHit
        : context.l10n.homeStoreWishlistHits(hits.length);
    final place = first.placeLabel(db, context.l10n);
    return Material(
      color: red.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(ValRadius.small),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpen(first),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: legibleAccent(context, red, min: 4.0),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Four skins in a row; at large text or a narrow card a 2×2 grid, so
/// nothing is squeezed.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.offers, required this.db});

  final List<HomeSkinOffer> offers;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final grid = scale >= 1.3 || constraints.maxWidth < 340;
        const gap = 8.0;
        if (!grid) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < offers.length; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(
                  child: HomeSkinTile(
                    offer: offers[i],
                    db: db,
                    showName: false,
                  ),
                ),
              ],
            ],
          );
        }
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final o in offers)
              SizedBox(
                width: width,
                child: HomeSkinTile(offer: o, db: db, showName: true),
              ),
          ],
        );
      },
    );
  }
}

/// One daily skin: render on a rarity-tinted tile with a colored edge, the
/// VP price and a ♥ when wishlisted. Tap opens the skin sheet.
class HomeSkinTile extends ConsumerWidget {
  const HomeSkinTile({
    super.key,
    required this.offer,
    required this.db,
    this.showName = false,
  });

  final HomeSkinOffer offer;
  final ContentDb db;
  final bool showName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tier = _tierOf(
      context.l10n,
      db,
      offer.tierUuid,
      valColorsOf(context).muted,
    );
    final name = offer.skin?.displayName ?? context.l10n.commonUnknownItem;
    final price = offer.vp;
    final priceText = price == null
        ? context.l10n.commonDash
        : context.fmt.vp(price);
    void onTap() => unawaited(
      showSkinDetailSheet(
        context,
        skinOrLevelUuid: offer.levelUuid,
        mode: SkinDetailMode.store,
      ),
    );
    return Semantics(
      button: true,
      label: context.l10n.homeOfferLabel(
        name,
        priceText,
        tier.name ?? '',
        offer.inWishlist,
      ),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: tier.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(ValRadius.small),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: tier.color, width: 3)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: showName ? 2.2 : 1.2,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.65,
                              colors: [
                                tier.color.withValues(alpha: 0.28),
                                tier.color.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                        NetImage(offer.skin?.image, showSkeleton: false),
                        PositionedDirectional(
                          top: 0,
                          start: 0,
                          child: DiamondPip(size: 10, color: tier.color),
                        ),
                        if (offer.inWishlist)
                          PositionedDirectional(
                            top: 0,
                            end: 0,
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: legibleAccent(
                                context,
                                theme.colorScheme.primary,
                                min: 4.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (showName) ...[
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: price == null
                          ? Text(
                              context.l10n.commonDash,
                              style: theme.textTheme.labelMedium,
                            )
                          : CurrencyAmount.vp(
                              price,
                              iconSize: 12,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
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

/// "Chợ Đêm · còn 4 ngày …" and, until the user opened it in ValHub, "n ưu
/// đãi đang chờ bạn lật" (the best deal stays hidden to keep the surprise);
/// afterwards the best deal.
class _NightMarketRow extends ConsumerWidget {
  const _NightMarketRow({
    required this.market,
    required this.db,
    required this.onTap,
  });

  final HomeNightMarket market;
  final ContentDb db;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final best = market.best;
    final Widget detail;
    if (market.unseen || best == null) {
      detail = Text(
        context.l10n.homeNightMarketWaiting(market.count),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      );
    } else {
      final skin = db.skinByLevelUuid(best.skinLevelUuid);
      final name = skin?.displayName ?? context.l10n.commonUnknownItem;
      final price = best.discountedPrice;
      final base = best.basePrice;
      detail = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: context.l10n.homeNightMarketBest(
                formatDiscountPercent(best.discountPercent),
                name,
                price == null ? context.l10n.commonDash : context.fmt.vp(price),
              ),
            ),
            if (base != null && price != null && base > price)
              TextSpan(
                text: ' ${context.fmt.vp(base)}',
                style: TextStyle(
                  color: muted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      );
    }
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(ValRadius.small),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.nightlight_round, size: 20, color: muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.l10n.homeNightMarketTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (market.expiresAt != null)
                            ExcludeSemantics(
                              child: CountdownText(
                                expiresAt: market.expiresAt!,
                                builder: context.l10n.homeNightMarketEndsIn,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      detail,
                    ],
                  ),
                ),
                if (market.unseen) ...[
                  const SizedBox(width: 8),
                  ValBadge(
                    context.l10n.homeNightMarketNew,
                    color: theme.colorScheme.primary,
                  ),
                ],
                Icon(Icons.chevron_right, color: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
