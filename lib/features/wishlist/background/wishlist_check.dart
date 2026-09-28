/// Background wishlist check (W2/W4) — owned by the wishlist feature.
///
/// Runs inside the workmanager isolate (no ProviderScope). Build services
/// with `BackgroundContext.instance()` (lib/core/background/background_context.dart):
/// for each account (not `needsLogin`, at most once per UTC day), fetch the
/// storefront, intersect daily offers / Night Market / bundle items with
/// `ctx.wishlist.read(puuid)` and notify with `ctx.notifications.showNow`.
/// Return `true` on success, `false` to let Android retry with backoff.
library;

/// Stub: implemented by the wishlist feature agent.
Future<bool> runWishlistCheck() async => true;
