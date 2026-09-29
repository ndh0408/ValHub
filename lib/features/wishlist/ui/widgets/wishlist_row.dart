import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/currency_amount.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../data/wishlist_view.dart';
import '../../wishlist_strings.dart';
import 'skin_bits.dart';

/// One S3A row: render, name, edition + weapon, price, "Đã sở hữu", and a
/// red "Đang có trong Chợ Đêm!" bar per place the skin is on sale.
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
    final name = facts?.name ?? CommonStrings.unknownItem;
    final tint = contentTierTint(
      ref,
      facts?.skin.contentTierUuid,
      fallback: colors.muted,
    );
    return TierGradientCard(
      tint: tint,
      borderColor: entry.isOnSale ? ValColors.red : null,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 48,
                  child: facts == null
                      ? Icon(Icons.help_outline, color: colors.muted)
                      : NetImage(facts.skin.image, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ContentTierBadge(
                            contentTierUuid: facts?.skin.contentTierUuid,
                            size: 14,
                          ),
                          if (facts?.skin.contentTierUuid != null)
                            const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              facts?.weapon?.displayName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (owned) ...[
                        const SizedBox(height: 6),
                        SmallBadge(
                          WishlistStrings.owned,
                          color: colors.win,
                          icon: Icons.check_circle,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 104),
                  child: _PriceColumn(entry: entry),
                ),
              ],
            ),
            for (final hit in entry.hits.take(2)) ...[
              const SizedBox(height: 10),
              _HitBar(hit: hit, onTap: () => onOpenHit(hit)),
            ],
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
            alignment: Alignment.centerRight,
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
              alignment: Alignment.centerRight,
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
            SmallBadge(formatDiscountPercent(pct), color: ValColors.red),
          ],
        ],
      );
    }
    final quote = entry.facts?.quote;
    if (quote == null) {
      return Text(CommonStrings.dash, style: theme.textTheme.labelLarge);
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
    final text = EconomyStrings.availableNow(hit.placeLabel(db));
    return Semantics(
      button: true,
      label: '$text ${WishlistStrings.viewInStore}',
      excludeSemantics: true,
      child: Material(
        color: ValColors.red.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 18,
                  color: ValColors.red,
                ),
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
                          color: ValColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (expiresAt != null)
                        CountdownText(
                          expiresAt: expiresAt,
                          builder: WishlistStrings.endsIn,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: valColorsOf(context).muted,
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
