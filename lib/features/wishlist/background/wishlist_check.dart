/// Background wishlist check (SUMMARY §8.2 W2/W4, VF §6.9) — owned by the
/// wishlist feature.
///
/// Runs inside the workmanager isolate (no ProviderScope) after the session
/// keep-alive. For every account with a non-empty wishlist that is not
/// `needsLogin`, at most once per UTC day: silent session (SUMMARY §3.4) →
/// storefront (P-1) → `findWishlistHits` → local notifications saying which
/// account the skin is waiting in, with a deep link that switches to it.
/// With "Khi Chợ Đêm mở" on, the same daily storefront read also sends
/// "Chợ Đêm đã mở!" once per Night Market (VF §6.9), for every account.
/// A re-auth failure marks the account `needsLogin` and sends "Cần đăng
/// nhập lại" once. Never throws.
library;

import '../../../core/accounts/account.dart';
import '../../../core/background/background_context.dart';
import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/notification_strings.dart';
import '../../../core/network/riot_exception.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/storage/prefs.dart';
import '../../../core/util/format.dart';
import '../../settings/settings_routes.dart';
import '../../store/store_routes.dart';
import '../../store/ui/store_screen.dart' show StoreSegment;
import 'wishlist_alerts.dart';
import 'wishlist_check_state.dart';

/// How long a Night Market without a remaining duration counts as
/// announced.
const kNightMarketFallbackLength = Duration(days: 14);

/// Entry point used by `core/background/background_tasks.dart`.
///
/// Returns `true` on success, `false` to let Android retry with backoff
/// (network trouble, or accounts left over when the time budget ran out).
Future<bool> runWishlistCheck({
  Duration budget = const Duration(seconds: 25),
}) async {
  try {
    final ctx = await BackgroundContext.instance();
    try {
      final report = await WishlistChecker(
        BackgroundWishlistCheckEnv(ctx),
        budget: budget,
      ).run();
      return report.ok;
    } finally {
      try {
        await ctx.finish();
      } on Object {
        // Flushing the session log is best effort.
      }
    }
  } on Object {
    return false;
  }
}

/// Everything the check needs from the outside world (fakes in tests).
abstract interface class WishlistCheckEnv {
  Prefs get prefs;

  DateTime now();

  /// Re-reads prefs written by the UI isolate.
  Future<void> reload();

  List<Account> accounts();

  /// Wishlist (skin uuids) of [puuid].
  Set<String> wishlist(String puuid);

  /// A valid session, re-authenticating silently when needed. Throws
  /// [NeedsLoginException] when the cookies are dead.
  Future<void> ensureSession(String puuid);

  /// Raw P-1 storefront JSON.
  Future<Object?> storefront(String puuid);

  Future<ContentDb> loadContent(String language);

  Future<void> notify({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    required String payload,
    required String accountPuuid,
  });

  Future<void> markNeedsLogin(String puuid);

  /// Scrubbed session-log line (never pass tokens or PUUIDs).
  void log(String event, {String? detail});
}

/// What one run did (for logs and tests).
class WishlistCheckReport {
  /// The "Kiểm tra wishlist trong nền" setting is off.
  bool disabled = false;

  /// Accounts whose storefront was checked.
  int checked = 0;

  /// Notifications shown for wishlist hits.
  int alerts = 0;

  /// "Chợ Đêm đã mở!" notifications shown.
  int nightMarkets = 0;

  /// Accounts whose re-auth failed.
  int needsLogin = 0;

  /// Accounts that failed for another reason (retried next run).
  int failed = 0;

  /// Ask the OS to run again soon.
  bool retry = false;

  bool get ok => !retry;

  @override
  String toString() =>
      'checked=$checked alerts=$alerts nightMarkets=$nightMarkets '
      'needsLogin=$needsLogin '
      'failed=$failed retry=$retry';
}

/// The check itself (pure logic over a [WishlistCheckEnv]).
class WishlistChecker {
  WishlistChecker(
    this.env, {
    this.budget = const Duration(seconds: 25),
    this.maxSeparateAlerts = kMaxSeparateWishlistAlerts,
  });

  final WishlistCheckEnv env;

  /// Stop starting new accounts after this long (iOS gives ~30 s).
  final Duration budget;
  final int maxSeparateAlerts;

  Future<WishlistCheckReport> run() async {
    final report = WishlistCheckReport();
    try {
      await _guard(env.reload);
      final settings = readAppSettings(env.prefs);
      final accounts = env.accounts();
      final nightMarketOn = settings.nightMarketNotifications;
      if (!nightMarketOn &&
          !accounts.any((a) => settings.wishlistNotificationsFor(a.puuid))) {
        report.disabled = true;
        return report;
      }
      bool wantsWishlist(Account a) =>
          settings.wishlistNotificationsFor(a.puuid) &&
          env.wishlist(a.puuid).isNotEmpty;

      final started = env.now();
      final state = WishlistCheckState(env.prefs);
      final due = [
        for (final a in accounts)
          if (!a.needsLogin &&
              !state.checkedToday(a.puuid, started) &&
              (nightMarketOn || wantsWishlist(a)))
            a,
      ];
      if (due.isEmpty) return report;

      // Skin names are only needed for wishlist alerts.
      ContentDb? db;
      if (due.any(wantsWishlist)) {
        try {
          db = await env.loadContent(settings.itemLanguage.apiCode);
        } on Object catch (e) {
          _log('wishlist.check.content_failed', e.runtimeType.toString());
          report.retry = true;
          return report;
        }
      }

      for (final (i, account) in due.indexed) {
        if (i > 0 && env.now().difference(started) > budget) {
          report.retry = true;
          break;
        }
        await _checkAccount(
          account,
          wantsWishlist(account) ? db : null,
          state,
          report,
          nightMarket: nightMarketOn,
        );
      }
    } on Object catch (e) {
      _log('wishlist.check.error', e.runtimeType.toString());
      report.retry = true;
    }
    _log('wishlist.check', report.toString());
    return report;
  }

  /// Reads [account]'s storefront once, then sends its wishlist alerts
  /// (when [db] is given) and the Night Market notice (when [nightMarket]).
  Future<void> _checkAccount(
    Account account,
    ContentDb? db,
    WishlistCheckState state,
    WishlistCheckReport report, {
    required bool nightMarket,
  }) async {
    final puuid = account.puuid;
    final now = env.now();
    try {
      await env.ensureSession(puuid);
      final json = await env.storefront(puuid);
      final store = Storefront.fromJson(json, receivedAt: now);
      await _guard(
        () => ObservedPriceStore(env.prefs).record(store.observedSkinPrices()),
      );
      if (nightMarket) {
        await _announceNightMarket(account, store, state, report, now);
      }
      if (db != null) {
        await _alertWishlist(account, store, db, state, report, now);
      }
      await state.markChecked(puuid, now);
      if (state.needsLoginNotified(puuid)) {
        await state.setNeedsLoginNotified(puuid, false);
      }
      report.checked++;
    } on NeedsLoginException {
      report.needsLogin++;
      await _guard(() => env.markNeedsLogin(puuid));
      if (!state.needsLoginNotified(puuid)) {
        final shown = await _guard(
          () => env.notify(
            id: NotificationIds.sessionExpired(puuid),
            title: NotificationStrings.sessionExpiredTitle,
            body: NotificationStrings.sessionExpiredBody(account.riotId),
            channel: NotificationChannel.account,
            payload: SettingsRoutes.root,
            accountPuuid: puuid,
          ),
        );
        if (shown) {
          await _guard(() => state.setNeedsLoginNotified(puuid, true));
        }
      }
    } on TransientException {
      report.failed++;
      report.retry = true;
    } on Object catch (e) {
      // Maintenance, 4xx or unexpected data: try again at the next run.
      report.failed++;
      _log('wishlist.check.account_failed', e.runtimeType.toString());
    }
  }

  /// "Chợ Đêm đã mở!" once per Night Market (remembered until it ends).
  Future<void> _announceNightMarket(
    Account account,
    Storefront store,
    WishlistCheckState state,
    WishlistCheckReport report,
    DateTime now,
  ) async {
    final market = store.nightMarket;
    final puuid = account.puuid;
    if (market == null || state.nightMarketNotified(puuid, now)) return;
    final shown = await _guard(
      () => env.notify(
        id: NotificationIds.nightMarket(puuid),
        title: NotificationStrings.nightMarketOpenTitle,
        body: NotificationStrings.nightMarketOpenBody(
          formatNumber(market.offers.length),
          account.riotId,
        ),
        channel: NotificationChannel.nightMarket,
        payload: withAccountParam(
          StoreRoutes.segment(StoreSegment.nightMarket),
          puuid,
        ),
        accountPuuid: puuid,
      ),
    );
    if (!shown) return;
    report.nightMarkets++;
    final end = market.expiresAt;
    await _guard(
      () => state.setNightMarketNotified(
        puuid,
        end != null && end.isAfter(now)
            ? end
            : now.add(kNightMarketFallbackLength),
      ),
    );
  }

  /// Wishlist hits of [store] not notified yet.
  Future<void> _alertWishlist(
    Account account,
    Storefront store,
    ContentDb db,
    WishlistCheckState state,
    WishlistCheckReport report,
    DateTime now,
  ) async {
    final puuid = account.puuid;
    final hits = findWishlistHits(store, env.wishlist(puuid), db);

    final notified = state.notified(puuid, now);
    final (fresh, covered) = _newHits(hits, notified);
    final alerts = buildWishlistAlerts(
      fresh,
      account: account,
      db: db,
      now: now,
      maxSeparate: maxSeparateAlerts,
    );
    for (final alert in alerts) {
      final shown = await _guard(
        () => env.notify(
          id: alert.id,
          title: alert.title,
          body: alert.body,
          channel: NotificationChannel.wishlist,
          payload: alert.payload,
          accountPuuid: puuid,
        ),
      );
      if (shown) report.alerts++;
    }

    await state.saveNotified(puuid, {
      ...notified,
      for (final h in covered) h.key: _liveUntil(h, now),
    });
  }

  /// One new hit per skin (store order: daily → Night Market → bundles)
  /// and every hit it covers. A hit already notified while its offer is
  /// still on sale is not notified again; the same skin showing up in a
  /// new place is.
  (List<WishlistHit>, List<WishlistHit>) _newHits(
    List<WishlistHit> hits,
    Map<String, DateTime> notified,
  ) {
    final bySkin = <String, List<WishlistHit>>{};
    for (final h in hits) {
      (bySkin[h.skinUuid] ??= []).add(h);
    }
    final fresh = <WishlistHit>[];
    final covered = <WishlistHit>[];
    for (final skinHits in bySkin.values) {
      final unseen = skinHits.where((h) => !notified.containsKey(h.key));
      if (unseen.isEmpty) continue;
      fresh.add(unseen.first);
      covered.addAll(skinHits);
    }
    return (fresh, covered);
  }

  /// Until when a notified hit counts as "already notified": its offer's
  /// end, else the next daily reset.
  DateTime _liveUntil(WishlistHit hit, DateTime now) {
    final end = hit.expiresAt;
    return end != null && end.isAfter(now)
        ? end
        : WishlistCheckState.nextUtcMidnight(now);
  }

  /// Runs [action], swallowing any error. Returns whether it succeeded.
  Future<bool> _guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on Object catch (e) {
      _log('wishlist.check.step_failed', e.runtimeType.toString());
      return false;
    }
  }

  void _log(String event, String detail) {
    try {
      env.log(event, detail: detail);
    } on Object {
      // Logging must never break the check.
    }
  }
}

/// [WishlistCheckEnv] backed by the background isolate's services.
class BackgroundWishlistCheckEnv implements WishlistCheckEnv {
  BackgroundWishlistCheckEnv(this._ctx);

  final BackgroundContext _ctx;

  @override
  Prefs get prefs => _ctx.prefs;

  @override
  DateTime now() => DateTime.now();

  @override
  Future<void> reload() => _ctx.prefs.reload();

  @override
  List<Account> accounts() => _ctx.accounts.loadAll();

  @override
  Set<String> wishlist(String puuid) => _ctx.wishlist.read(puuid);

  @override
  Future<void> ensureSession(String puuid) async {
    await _ctx.sessions.session(puuid);
  }

  @override
  Future<Object?> storefront(String puuid) => _ctx.pvp.storefront(puuid);

  @override
  Future<ContentDb> loadContent(String language) =>
      // Background budget: any complete cache beats a full re-download.
      _ctx.content.load(language: language, preferCache: true);

  @override
  Future<void> notify({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    required String payload,
    required String accountPuuid,
  }) => _ctx.notifications.showNow(
    id: id,
    title: title,
    body: body,
    channel: channel,
    payload: payload,
    accountPuuid: accountPuuid,
  );

  @override
  Future<void> markNeedsLogin(String puuid) async {
    await _ctx.accounts.patch(puuid, (a) => a.copyWith(needsLogin: true));
  }

  @override
  void log(String event, {String? detail}) =>
      _ctx.log.add(event, detail: detail);
}
