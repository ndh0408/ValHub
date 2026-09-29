/// Local-notification content for wishlist hits (VF §6.9, SUMMARY W2/W4/W5).
/// Pure: the background check decides WHEN to notify, this file decides
/// WHAT the notification says and where tapping it leads.
library;

import 'package:flutter/foundation.dart';

import '../../../core/accounts/account.dart';
import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/util/format.dart';
import '../../store/store_routes.dart';
import '../../store/ui/store_screen.dart' show StoreSegment;
import '../wishlist_routes.dart';
import '../wishlist_strings.dart';

/// Above this many new hits for one account, a single summary notification
/// is shown instead of one per skin.
const kMaxSeparateWishlistAlerts = 3;

/// One notification to show.
@immutable
class WishlistAlert {
  const WishlistAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  /// Stable id (`NotificationIds.wishlistHit` / summary id), so a newer
  /// alert for the same skin replaces the old one.
  final int id;
  final String title;
  final String body;

  /// Deep link (route location with `account=<puuid>`).
  final String payload;

  @override
  String toString() => 'WishlistAlert($id, $title)';
}

/// [location] with `account=<puuid>` added (read by `parseDeepLink`, which
/// switches to that account first, W5).
String withAccountParam(String location, String puuid) {
  final uri = Uri.parse(location);
  return uri
      .replace(queryParameters: {...uri.queryParameters, 'account': puuid})
      .toString();
}

/// Where tapping a hit's notification leads (VF §6.9): the skin sheet on
/// the wishlist for the daily shop, the Night Market segment, or the
/// bundle page.
String wishlistHitPayload(WishlistHit hit, String puuid) {
  final location = switch (hit.place) {
    WishlistPlace.daily => WishlistRoutes.skin(hit.skinUuid),
    WishlistPlace.nightMarket => StoreRoutes.segment(StoreSegment.nightMarket),
    WishlistPlace.bundle =>
      hit.bundleId == null
          ? StoreRoutes.segment(StoreSegment.bundles)
          : StoreRoutes.bundle(hit.bundleId!),
  };
  return withAccountParam(location, puuid);
}

String _skinName(WishlistHit hit, ContentDb db) {
  final name =
      hit.skin?.displayName ?? db.skinByAnyUuid(hit.levelUuid)?.displayName;
  return (name == null || name.isEmpty) ? CommonStrings.unknownItem : name;
}

/// "11 giờ" / "38 phút" left, or `null` when unknown or over.
String? _timeLeft(DateTime? expiresAt, DateTime now) {
  if (expiresAt == null) return null;
  final left = expiresAt.difference(now);
  if (left <= Duration.zero) return null;
  return formatDurationCoarse(left);
}

/// The VF §6.9 notification for one hit of [account].
WishlistAlert wishlistHitAlert(
  WishlistHit hit, {
  required Account account,
  required ContentDb db,
  required DateTime now,
}) {
  final name = _skinName(hit, db);
  final riotId = account.riotId;
  final (title, body) = switch (hit.place) {
    WishlistPlace.daily => (
      WishlistStrings.notifDailyTitle,
      WishlistStrings.notifDailyBody(
        name,
        riotId,
        _timeLeft(hit.expiresAt, now),
      ),
    ),
    WishlistPlace.nightMarket => (
      WishlistStrings.notifNightMarketTitle,
      WishlistStrings.notifNightMarketBody(
        name,
        hit.discountPercent,
        hit.price == null ? null : formatVp(hit.price!),
        riotId,
      ),
    ),
    WishlistPlace.bundle => (
      WishlistStrings.notifBundleTitle,
      WishlistStrings.notifBundleBody(name, _bundleName(hit, db), riotId),
    ),
  };
  return WishlistAlert(
    id: NotificationIds.wishlistHit(account.puuid, hit.skinUuid),
    title: title,
    body: body,
    payload: wishlistHitPayload(hit, account.puuid),
  );
}

String? _bundleName(WishlistHit hit, ContentDb db) {
  final name = db.bundleByUuid(hit.bundleDataAssetId ?? '')?.displayName;
  return (name == null || name.trim().isEmpty) ? null : name;
}

/// Id of the per-account summary notification.
int wishlistSummaryId(String puuid) =>
    NotificationIds.forKey('wishlist_summary:$puuid');

/// One notification for many hits of [account] (opens its wishlist).
WishlistAlert wishlistSummaryAlert(
  List<WishlistHit> hits, {
  required Account account,
  required ContentDb db,
}) {
  final names = <String>[];
  for (final h in hits) {
    final name = _skinName(h, db);
    if (!names.contains(name)) names.add(name);
    if (names.length == 2) break;
  }
  return WishlistAlert(
    id: wishlistSummaryId(account.puuid),
    title: WishlistStrings.notifSummaryTitle(hits.length),
    body: WishlistStrings.notifSummaryBody(
      names,
      hits.length - names.length,
      account.riotId,
    ),
    payload: withAccountParam(WishlistRoutes.wishlist, account.puuid),
  );
}

/// Notifications for [hits] (already deduplicated: one per skin): one per
/// hit up to [maxSeparate], else a single summary.
List<WishlistAlert> buildWishlistAlerts(
  List<WishlistHit> hits, {
  required Account account,
  required ContentDb db,
  required DateTime now,
  int maxSeparate = kMaxSeparateWishlistAlerts,
}) {
  if (hits.isEmpty) return const [];
  if (hits.length > maxSeparate) {
    return [wishlistSummaryAlert(hits, account: account, db: db)];
  }
  return [
    for (final h in hits)
      wishlistHitAlert(h, account: account, db: db, now: now),
  ];
}
