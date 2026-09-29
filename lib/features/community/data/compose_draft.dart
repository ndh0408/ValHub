import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import 'community_models.dart';

/// What the composer opens with (plain text, or a store / Night Market
/// "khoe" attachment built from the current storefront).
@immutable
class ComposeDraft {
  const ComposeDraft({this.kind = PostKind.text, this.payload, this.body = ''});

  final PostKind kind;
  final PostPayload? payload;
  final String body;

  bool get hasAttachment => kind.hasOffers && payload != null;

  /// The daily shop of today ([now] in UTC: the shop resets at 00:00 UTC).
  static ComposeDraft? fromDaily(
    DailyStore daily, {
    required ContentDb db,
    required DateTime now,
  }) {
    final offers = [
      for (final o in daily.offers)
        PayloadOffer(skinUuid: _skinUuid(db, o.skinLevelUuid), cost: o.vpCost),
    ];
    if (offers.isEmpty) return null;
    return ComposeDraft(
      kind: PostKind.store,
      payload: PostPayload(
        date: isoDate(now),
        offers: offers.take(PostPayload.maxOffers).toList(),
      ),
    );
  }

  /// The account's current Night Market.
  static ComposeDraft? fromNightMarket(
    NightMarket nightMarket, {
    required ContentDb db,
    required DateTime now,
  }) {
    final offers = [
      for (final o in nightMarket.offers)
        PayloadOffer(
          skinUuid: _skinUuid(db, o.skinLevelUuid),
          baseCost: o.basePrice,
          discountCost: o.discountedPrice,
          discountPercent: o.discountPercent,
        ),
    ];
    if (offers.isEmpty) return null;
    return ComposeDraft(
      kind: PostKind.nightmarket,
      payload: PostPayload(
        date: isoDate(now),
        offers: offers.take(PostPayload.maxOffers).toList(),
      ),
    );
  }

  /// Store offers are level uuids; posts carry the skin uuid when known.
  static String _skinUuid(ContentDb db, String levelUuid) =>
      db.skinByLevelUuid(levelUuid)?.uuid ?? levelUuid.toLowerCase();
}

/// `YYYY-MM-DD` of [at] in UTC.
String isoDate(DateTime at) {
  final u = at.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${u.year}-${two(u.month)}-${two(u.day)}';
}
