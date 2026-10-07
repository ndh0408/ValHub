import '../../../../core/l10n/labels/economy_labels.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../data/wishlist_view.dart';
import '../../../skin_detail/community_skin_score.dart';
import 'skin_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// One S3A card (same family as the store cards): a tier-tinted card with
/// the render centered on top, then tier icon + name + weapon (left) and
/// the price (right), a "Đã sở hữu" badge, and a red "Đang có trong Chợ
/// Đêm!" bar per place the skin is on sale today.
class WishlistRow extends ConsumerWidget {
  const WishlistRow({
    super.key,
    required this.entry,
    required this.owned,
    required this.onTap,
    required this.onOpenHit,
  });

  final WishlistEntry entry;
  final bool owned;
  final VoidCallback onTap;

  /// Tap on an availability bar (opens the store place).
  final ValueChanged<WishlistHit> onOpenHit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final facts = entry.facts;
    final name = facts?.name ?? context.l10n.commonUnknownItem;
    final tint = contentTierTint(
      ref,
      facts?.skin.contentTierUuid,
      fallback: colors.muted,
    );
    return TierGradientCard(
      tint: tint,
      borderColor: entry.isOnSale ? theme.colorScheme.primary : null,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 76,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 4,
                      ),
                      child: facts == null
                          ? Icon(Icons.help_outline, color: colors.muted)
                          : NetImage(
                              facts.skin.image,
                              fit: BoxFit.contain,
                              showSkeleton: false,
                            ),
                    ),
                  ),
                  if (owned)
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      child: SmallBadge(
                        context.l10n.wishlistOwned,
                        color: colors.win,
                        icon: Icons.check_circle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (facts?.skin.contentTierUuid != null) ...[
                  ContentTierBadge(
                    contentTierUuid: facts?.skin.contentTierUuid,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((facts?.weapon?.displayName ?? '').isNotEmpty)
                        Text(
                          facts!.weapon!.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: _PriceColumn(entry: entry),
                ),
              ],
            ),
            for (final hit in entry.hits.take(2)) ...[
              const SizedBox(height: 10),
              _HitBar(hit: hit, onTap: () => onOpenHit(hit)),
            ],
            if (facts != null) CommunitySkinScore(skinUuid: facts.skin.uuid),
          ],
        ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({required this.entry});

  final WishlistEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hit = entry.hits.isEmpty ? null : entry.hits.first;
    final price = hit?.price;
    if (hit != null && price != null) {
      final base = hit.basePrice;
      final pct = hit.discountPercent;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: CurrencyAmount.vp(
              price,
              iconSize: 14,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (base != null && base > price) ...[
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: CurrencyAmount.vp(
                base,
                iconSize: 12,
                strikethrough: true,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
          if (pct != null && pct > 0) ...[
            const SizedBox(height: 4),
            SmallBadge(
              formatDiscountPercent(pct),
              color: theme.colorScheme.primary,
            ),
          ],
        ],
      );
    }
    final quote = entry.facts?.quote;
    if (quote == null) {
      return Text(context.l10n.commonDash, style: theme.textTheme.labelLarge);
    }
    return SkinPriceText(quote: quote);
  }
}

class _HitBar extends ConsumerWidget {
  const _HitBar({required this.hit, required this.onTap});

  final WishlistHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final expiresAt = hit.expiresAt;
    final accent = theme.colorScheme.primary;
    final text = context.l10n.economyAvailableNow(
      hit.placeLabel(db, context.l10n),
    );
    return Semantics(
      button: true,
      label: '$text ${context.l10n.wishlistViewInStore}',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(ValRadius.small),
        child: InkWell(
          borderRadius: BorderRadius.circular(ValRadius.small),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 6, 10),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: legibleAccent(context, accent),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (expiresAt != null)
                        CountdownText(
                          expiresAt: expiresAt,
                          builder: context.l10n.wishlistEndsIn,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
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
