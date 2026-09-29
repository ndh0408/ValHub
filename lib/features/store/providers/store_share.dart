/// "Chia sẻ ảnh": what the branded store picture shows, and the two
/// platform hooks it needs (image loading, the OS share sheet), overridable
/// in tests.
library;

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_fallbacks.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/tier_colors.dart';
import '../../../core/ui/net_image.dart';

/// Which store rotation a picture shows.
enum StoreShareKind { daily, nightMarket }

/// One skin on the picture.
@immutable
class ShareOfferItem {
  const ShareOfferItem({
    required this.name,
    required this.tierColor,
    this.imageUrl,
    this.price,
    this.basePrice,
    this.discountPercent = 0,
  });

  final String name;
  final String? imageUrl;

  /// Opaque rarity color.
  final Color tierColor;

  /// VP price (discounted in the Night Market).
  final int? price;

  /// Struck-through Night Market base price.
  final int? basePrice;
  final int discountPercent;
}

/// Everything the picture needs; no account identifiers (the Riot ID is
/// added by the sheet only when the user turns it on).
@immutable
class StoreShareData {
  const StoreShareData({
    required this.kind,
    required this.items,
    required this.createdAt,
    this.expiresAt,
    this.totalVp = 0,
    this.savingsVp = 0,
  });

  final StoreShareKind kind;
  final List<ShareOfferItem> items;

  /// When the picture is made (its date line).
  final DateTime createdAt;

  /// End of the rotation (Night Market "Đến …").
  final DateTime? expiresAt;

  /// Daily: the four prices; Night Market: the discounted prices.
  final int totalVp;

  /// Night Market savings.
  final int savingsVp;

  bool get isNightMarket => kind == StoreShareKind.nightMarket;
}

ShareOfferItem _item(
  ContentDb db,
  String skinLevelUuid, {
  int? price,
  int? basePrice,
  int discountPercent = 0,
}) {
  final skin = db.skinByLevelUuid(skinLevelUuid);
  final tierId = skin?.contentTierUuid;
  final tier = tierId == null
      ? null
      : db.contentTier(tierId) ?? ContentFallbacks.contentTier(tierId);
  return ShareOfferItem(
    name: skin?.displayName ?? CommonStrings.unknownItem,
    imageUrl: skin?.image,
    tierColor: opaqueRgba(tier?.highlightColor),
    price: price,
    basePrice: basePrice,
    discountPercent: discountPercent,
  );
}

/// The daily shop as a picture.
StoreShareData shareDataForDaily(
  DailyStore daily,
  ContentDb db,
  DateTime now,
) => StoreShareData(
  kind: StoreShareKind.daily,
  createdAt: now,
  expiresAt: daily.expiresAt,
  totalVp: daily.totalVp,
  items: [
    for (final o in daily.offers) _item(db, o.skinLevelUuid, price: o.vpCost),
  ],
);

/// The Night Market as a picture (all six offers, even unflipped ones:
/// the player has seen them in the app anyway).
StoreShareData shareDataForNightMarket(
  NightMarket nm,
  ContentDb db,
  DateTime now,
) => StoreShareData(
  kind: StoreShareKind.nightMarket,
  createdAt: now,
  expiresAt: nm.expiresAt,
  totalVp: nm.offers.fold(0, (sum, o) => sum + (o.discountedPrice ?? 0)),
  savingsVp: nm.totalSavings,
  items: [
    for (final o in nm.offers)
      _item(
        db,
        o.skinLevelUuid,
        price: o.discountedPrice,
        basePrice: o.basePrice,
        discountPercent: o.discountPercent,
      ),
  ],
);

/// Image provider the picture draws a render URL with (precached before the
/// capture). Tests return an in-memory image or `null` (placeholder).
typedef ShareImageProviderFactory = ImageProvider? Function(String url);

final shareImageProviderFactoryProvider = Provider<ShareImageProviderFactory>(
  (ref) =>
      (url) => ResizeImage(
        CachedNetworkImageProvider(url, cacheManager: valMediaCache),
        width: 720,
        policy: ResizeImagePolicy.fit,
      ),
);

/// Sends a PNG to the platform's native share sheet.
/// [origin] anchors the iPad popover.
typedef StoreImageSharer = Future<void> Function(
  Uint8List png, {
  required String fileName,
  String? subject,
  Rect? origin,
});

final storeImageSharerProvider = Provider<StoreImageSharer>(
  (ref) => (png, {required fileName, subject, origin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png')],
        fileNameOverrides: [fileName],
        subject: subject,
        title: subject,
        sharePositionOrigin: origin,
      ),
    );
  },
);
