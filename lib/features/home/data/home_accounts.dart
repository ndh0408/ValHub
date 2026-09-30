/// "Tài khoản khác" card model (docs/design/HOME.md §5.7). Pure.
library;

import 'package:flutter/foundation.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_status.dart';
import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';

/// Rows on the card.
const kHomeMaxOtherAccounts = 3;

/// One other account on the card.
@immutable
class OtherAccountSummary {
  const OtherAccountSummary({
    required this.account,
    this.activity,
    this.liveHits = const [],
    this.storeKnown = false,
  });

  final Account account;

  /// What the account is doing (G-1); `null` until the slow poller answers.
  final AccountActivity? activity;

  /// Wishlisted skins its saved storefront still sells (no network).
  final List<WishlistHit> liveHits;

  /// The saved daily store has not expired yet, so [liveHits] is current.
  final bool storeKnown;

  bool get hasHits => liveHits.isNotEmpty;
}

/// The rows of the card plus how many accounts did not fit.
@immutable
class HomeOtherAccounts {
  const HomeOtherAccounts({required this.rows, this.more = 0});

  final List<OtherAccountSummary> rows;
  final int more;
}

/// The other accounts for the card; `null` with fewer than two accounts.
///
/// The order uses local signals only, so rows never jump when activity
/// arrives: accounts with a live wishlist hit, then accounts that need to
/// sign in again, then the rest in list order. At most [max] rows; the rest
/// is counted in [HomeOtherAccounts.more]. [activityOf] is called only for
/// the rows shown and never for accounts that need to sign in again (their
/// activity is known); it decorates a row but never reorders it.
HomeOtherAccounts? buildOtherAccountSummaries({
  required List<Account> accounts,
  required String? activePuuid,
  required Map<String, Storefront?> savedStores,
  required Map<String, Set<String>> wishlists,
  required ContentDb db,
  required DateTime now,
  AccountActivity? Function(String puuid)? activityOf,
  int max = kHomeMaxOtherAccounts,
}) {
  if (accounts.length < 2) return null;
  final others = [
    for (final a in accounts)
      if (a.puuid != activePuuid) a,
  ];
  if (others.isEmpty) return null;

  final base = <OtherAccountSummary>[];
  for (final a in others) {
    final store = savedStores[a.puuid];
    final wishlist = wishlists[a.puuid] ?? const <String>{};
    final expires = store?.daily.expiresAt;
    final known = store != null && expires != null && expires.isAfter(now);
    final hits = store == null || wishlist.isEmpty
        ? const <WishlistHit>[]
        : [
            for (final h in findWishlistHits(store, wishlist, db))
              if (h.expiresAt != null && h.expiresAt!.isAfter(now)) h,
          ];
    base.add(
      OtherAccountSummary(
        account: a,
        liveHits: List.unmodifiable(hits),
        storeKnown: known,
      ),
    );
  }

  int rank(OtherAccountSummary s) {
    if (s.hasHits) return 0;
    if (s.account.needsLogin) return 1;
    return 2;
  }

  final indexed = [for (var i = 0; i < base.length; i++) (i, base[i])]
    ..sort((a, b) {
      final c = rank(a.$2).compareTo(rank(b.$2));
      return c != 0 ? c : a.$1.compareTo(b.$1);
    });
  final shown = [for (final e in indexed.take(max)) e.$2];
  final rows = [
    for (final s in shown)
      OtherAccountSummary(
        account: s.account,
        liveHits: s.liveHits,
        storeKnown: s.storeKnown,
        activity: s.account.needsLogin
            ? AccountActivity.needsLogin
            : activityOf?.call(s.account.puuid),
      ),
  ];
  return HomeOtherAccounts(
    rows: List.unmodifiable(rows),
    more: base.length - shown.length,
  );
}
