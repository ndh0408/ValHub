import 'package:material_ui/material_ui.dart';

import '../../../../core/config/local_price.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../providers/store_share.dart';
import '../../store_strings.dart';

/// The branded picture of the daily shop / Night Market that "Chia sẻ ảnh"
/// exports (RepaintBoundary → PNG, 3× → 1080 px wide).
///
/// Always drawn in the dark VanHub look at 100 % text size, whatever the
/// app theme or the accessibility text scale, so every shared picture looks
/// the same. Carries no account identifier unless [riotId] is given (the
/// user turned "Hiện Riot ID" on).
class StoreShareCard extends StatelessWidget {
  const StoreShareCard({
    super.key,
    required this.data,
    this.riotId,
    this.price,
    this.imageFor,
  });

  /// Logical width; exported at 3× (1080 px).
  static const width = 360.0;

  final StoreShareData data;

  /// Riot ID line ("Tên#TAG"); hidden when `null`.
  final String? riotId;

  /// Local-currency estimates next to the VP prices; hidden when `null`.
  final LocalPrice? price;

  /// Image provider per render URL (precached by the sheet).
  final ShareImageProviderFactory? imageFor;

  static final ThemeData _theme = buildDarkTheme();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context) ?? const MediaQueryData();
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.noScaling),
      child: Theme(
        data: _theme,
        child: DefaultTextStyle(
          style: _theme.textTheme.bodyMedium!.copyWith(color: _Ink.text),
          child: SizedBox(width: width, child: _body()),
        ),
      ),
    );
  }

  Widget _body() {
    final price = this.price;
    // A gradient replaces `BoxDecoration.color`, so the solid background is
    // its own layer (the picture must never be transparent).
    return ColoredBox(
      color: _Ink.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1, -1),
            radius: 1.3,
            colors: [Color(0x47FF4655), Color(0x00FF4655)],
          ),
        ),
        child: Stack(
          children: [
            // Faint watermark in the bottom-right corner.
            const Positioned(
              right: -6,
              bottom: 34,
              child: Text(
                StoreStrings.shareCardWatermark,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 88,
                  height: 1,
                  color: Color(0x0DFFFFFF),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(data: data, riotId: riotId),
                  const SizedBox(height: 14),
                  if (data.isNightMarket)
                    _NightMarketGrid(
                      items: data.items,
                      price: price,
                      imageFor: imageFor,
                    )
                  else
                    for (var i = 0; i < data.items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _DailyRow(
                        item: data.items[i],
                        price: price,
                        imageFor: imageFor,
                      ),
                    ],
                  const SizedBox(height: 12),
                  _Totals(data: data, price: price),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: _Ink.hairline),
                  const SizedBox(height: 10),
                  _Footer(showPriceNote: price != null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed colors of the picture (dark look on every theme).
abstract final class _Ink {
  static const background = Color(0xFF050506);
  static const surface = ValColors.surface;
  static const text = ValColors.bone;
  static const muted = Color(0xFFA1A1A8);
  static const hairline = Color(0x1FFFFFFF);
  static const green = ValColors.green;
}

/// `07:00 thứ Tư 08/10`: absolute, since the picture is read later.
String _absoluteWall(DateTime at) {
  final l = roundToMinute(at).toLocal();
  return '${formatTime(l)} ${formatWeekdayLower(l)} ${formatDayMonth(l)}';
}

class _Header extends StatelessWidget {
  const _Header({required this.data, required this.riotId});

  final StoreShareData data;
  final String? riotId;

  @override
  Widget build(BuildContext context) {
    final until = data.expiresAt;
    final id = riotId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const _Logo(size: 26),
            const SizedBox(width: 8),
            const Text(
              StoreStrings.shareCardBrand,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 20,
                height: 1.1,
                letterSpacing: 0.6,
                color: _Ink.text,
              ),
            ),
            const Spacer(),
            Text(
              formatWeekdayDate(data.createdAt),
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _Ink.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          (data.isNightMarket
                  ? StoreStrings.shareCardNightMarket
                  : StoreStrings.shareCardDaily)
              .toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 32,
            height: 1.05,
            letterSpacing: 0.6,
            color: _Ink.text,
          ),
        ),
        if (data.isNightMarket && until != null) ...[
          const SizedBox(height: 4),
          Text(
            StoreStrings.shareCardUntil(_absoluteWall(until)),
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _Ink.muted,
            ),
          ),
        ],
        if (id != null) ...[
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(ValRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 15, color: ValColors.red),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _Ink.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Red rounded square with a white "V" (the app mark).
class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ValColors.red,
      borderRadius: BorderRadius.circular(size * 0.28),
    ),
    child: Text(
      StoreStrings.shareCardMark,
      style: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size * 0.62,
        height: 1.1,
        color: Colors.white,
      ),
    ),
  );
}

/// Tier-tinted tile background (flat, like the in-app cards).
BoxDecoration _tile(Color tier) => BoxDecoration(
  color: Color.alphaBlend(tier.withValues(alpha: 0.2), _Ink.surface),
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tier.withValues(alpha: 0.22), tier.withValues(alpha: 0)],
  ),
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: tier.withValues(alpha: 0.4)),
);

Widget _render(ShareImageProviderFactory? imageFor, String? url) {
  final provider = url == null ? null : imageFor?.call(url);
  if (provider == null) {
    return const Center(
      child: Icon(Icons.image_outlined, size: 28, color: Color(0x33FFFFFF)),
    );
  }
  return Image(
    image: provider,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
  );
}

String? _priceText(LocalPrice? price, int? vp) =>
    vp == null ? null : price?.format(vp);

const _priceStyle = TextStyle(
  fontFamily: AppFonts.body,
  fontSize: 17,
  fontWeight: FontWeight.w800,
  height: 1.2,
  color: _Ink.text,
);

const _estimateStyle = TextStyle(
  fontFamily: AppFonts.body,
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.25,
  color: _Ink.muted,
);

/// "1.775 VP".
String _vp(int? amount) =>
    amount == null ? CommonStrings.dash : formatVp(amount);

class _DailyRow extends StatelessWidget {
  const _DailyRow({
    required this.item,
    required this.price,
    required this.imageFor,
  });

  final ShareOfferItem item;
  final LocalPrice? price;
  final ShareImageProviderFactory? imageFor;

  @override
  Widget build(BuildContext context) {
    final priceText = _priceText(price, item.price);
    return Container(
      height: 96,
      decoration: _tile(item.tierColor),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: DiamondPip(size: 11, color: item.tierColor),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: _Ink.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(_vp(item.price), maxLines: 1, style: _priceStyle),
                if (priceText != null)
                  Text(priceText, maxLines: 1, style: _estimateStyle),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(flex: 6, child: _render(imageFor, item.imageUrl)),
        ],
      ),
    );
  }
}

class _NightMarketGrid extends StatelessWidget {
  const _NightMarketGrid({
    required this.items,
    required this.price,
    required this.imageFor,
  });

  final List<ShareOfferItem> items;
  final LocalPrice? price;
  final ShareImageProviderFactory? imageFor;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 8));
      rows.add(
        Row(
          children: [
            Expanded(
              child: _NightMarketTile(
                item: items[i],
                price: price,
                imageFor: imageFor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: i + 1 < items.length
                  ? _NightMarketTile(
                      item: items[i + 1],
                      price: price,
                      imageFor: imageFor,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

class _NightMarketTile extends StatelessWidget {
  const _NightMarketTile({
    required this.item,
    required this.price,
    required this.imageFor,
  });

  final ShareOfferItem item;
  final LocalPrice? price;
  final ShareImageProviderFactory? imageFor;

  @override
  Widget build(BuildContext context) {
    final priceText = _priceText(price, item.price);
    final base = item.basePrice;
    return Container(
      height: 200,
      decoration: _tile(item.tierColor),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.discountPercent > 0)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: ValColors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      formatDiscountPercent(item.discountPercent),
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              DiamondPip(size: 11, color: item.tierColor),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(child: _render(imageFor, item.imageUrl)),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: _Ink.text,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  _vp(item.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _priceStyle.copyWith(fontSize: 15, color: _Ink.green),
                ),
              ),
              if (base != null && base != item.price) ...[
                const SizedBox(width: 6),
                Text(
                  formatNumber(base),
                  maxLines: 1,
                  style: _estimateStyle.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _Ink.muted,
                  ),
                ),
              ],
            ],
          ),
          if (priceText != null)
            Text(
              priceText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _estimateStyle.copyWith(fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.data, required this.price});

  final StoreShareData data;
  final LocalPrice? price;

  @override
  Widget build(BuildContext context) {
    final nm = data.isNightMarket;
    final amount = nm ? data.savingsVp : data.totalVp;
    if (amount <= 0) return const SizedBox.shrink();
    final priceText = _priceText(price, amount);
    final label = nm
        ? StoreStrings.shareCardSaved(formatVp(amount))
        : StoreStrings.shareCardTotal(formatVp(amount));
    return Row(
      children: [
        Icon(
          nm ? Icons.savings_outlined : Icons.shopping_bag_outlined,
          size: 18,
          color: nm ? _Ink.green : _Ink.muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _priceStyle.copyWith(
              fontSize: 15,
              color: nm ? _Ink.green : _Ink.text,
            ),
          ),
        ),
        if (priceText != null) ...[
          const SizedBox(width: 8),
          Text(
            priceText,
            maxLines: 1,
            style: _estimateStyle.copyWith(fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.showPriceNote});

  final bool showPriceNote;

  @override
  Widget build(BuildContext context) {
    const small = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: _Ink.muted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          children: [
            _Logo(size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                '${StoreStrings.shareCardBrand} · ${StoreStrings.shareCardTagline}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: small,
              ),
            ),
          ],
        ),
        if (showPriceNote) ...[
          const SizedBox(height: 4),
          const Text(StoreStrings.shareCardPriceNote, style: small),
        ],
      ],
    );
  }
}
