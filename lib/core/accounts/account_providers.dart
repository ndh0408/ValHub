import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/community/providers/community_providers.dart'
    show communityAuthProvider;
import '../auth/auth_callback.dart';
import '../auth/auth_providers.dart';
import '../auth/cookie_jar.dart';
import '../config/app_constants.dart';
import '../domain/competitive/names.dart' show nameResolverProvider;
import '../domain/competitive/rr_history.dart' show rrHistoryStoreProvider;
import '../domain/loadout/loadout_providers.dart' show loadoutPresetsProvider;
import '../notifications/notification_service.dart';
import '../riot/riot_hosts.dart';
import '../settings/app_settings.dart';
import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../storage/secure_store.dart';
import 'account.dart';
import 'account_repository.dart';
import 'local_data.dart';

/// Account metadata persistence (prefs) + per-account data wipe.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(
    prefs: ref.watch(prefsProvider),
    secureStore: ref.watch(secureStoreProvider),
    fileCache: ref.watch(jsonFileCacheProvider),
  ),
);

/// Erases the local data ValVN keeps beyond the session (RR history, presets,
/// names, matches; see [LocalDataEraser]).
final localDataEraserProvider = Provider<LocalDataEraser>(
  (ref) => LocalDataEraser(
    prefs: ref.watch(prefsProvider),
    cache: ref.watch(jsonFileCacheProvider),
    history: ref.watch(rrHistoryStoreProvider),
  ),
);

/// Every signed-in account (max [AppConstants.maxAccounts]), in list order.
///
/// ```dart
/// final accounts = ref.watch(accountsProvider);
/// await ref.read(accountsProvider.notifier).remove(puuid);
/// ```
final accountsProvider = NotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

/// Account list + actions (add / update / remove / sign out all).
class AccountsNotifier extends Notifier<List<Account>> {
  AccountRepository get _repo => ref.read(accountRepositoryProvider);

  @override
  List<Account> build() {
    final repo = ref.watch(accountRepositoryProvider);
    final sub = ref.watch(sessionManagerProvider).events.listen((_) {
      if (ref.mounted) state = repo.loadAll();
    });
    ref.onDispose(sub.cancel);
    return repo.loadAll();
  }

  bool get isFull => state.length >= AppConstants.maxAccounts;

  /// Re-reads metadata from prefs (e.g. after a background task ran).
  void reload() => state = _repo.loadAll();

  /// Finishes a WebView login (SUMMARY §3.2 steps 6–7): enforces the
  /// 10-account limit, stores cookies, bootstraps and adds / updates the
  /// account, then makes it active.
  ///
  /// Throws [MaxAccountsException] or a `RiotException`.
  Future<Account> completeLogin({
    required AuthTokens tokens,
    required RiotCookieJar cookies,
  }) async {
    final existing = _repo.find(tokens.puuid);
    if (existing == null && isFull) {
      throw const MaxAccountsException(AppConstants.maxAccounts);
    }
    final established = await ref
        .read(sessionManagerProvider)
        .establishFromLogin(tokens: tokens, cookies: cookies);
    final info = established.userInfo;
    final region = established.session.region;
    final account =
        (existing ??
                Account(
                  puuid: tokens.puuid,
                  gameName: '',
                  tagLine: '',
                  region: region,
                  shard: shardForRegion(region),
                  addedAt: DateTime.now(),
                ))
            .copyWith(
              gameName: info.gameName ?? existing?.gameName ?? '',
              tagLine: info.tagLine ?? existing?.tagLine ?? '',
              region: region,
              shard: shardForRegion(region),
              needsLogin: false,
            );
    await _repo.upsert(account);
    // Written before the state change so activePuuidProvider (which watches
    // this provider) picks it up when it rebuilds.
    await _repo.setActivePuuid(account.puuid);
    if (ref.mounted) state = _repo.loadAll();
    return account;
  }

  /// Updates cached metadata (level, card, rank, platform…).
  Future<void> updateAccount(
    String puuid,
    Account Function(Account) update,
  ) async {
    await _repo.patch(puuid, update);
    if (ref.mounted) state = _repo.loadAll();
  }

  /// Signs one account out (A11): cancels its notifications, deletes its
  /// cookies, tokens, login note, community session, `acct.<puuid>.*` prefs
  /// and `acct/<puuid>/…` caches.
  ///
  /// With [keepLocalData] (the default, VF W6) the wishlist, loadout presets
  /// and RR history of the account stay on the device for a later login;
  /// without it they are erased too (decision D3).
  ///
  /// The sign-out is written down first (`app.pendingWipe`) and cleared last:
  /// if the app is killed half-way the next start finishes it.
  Future<void> remove(String puuid, {bool keepLocalData = true}) async {
    final id = puuid.toLowerCase();
    await _repo.markPendingWipe(id, keepLocalData: keepLocalData);
    await ref.read(notificationServiceProvider).cancelForAccount(id);
    // Metadata first: a re-auth still running (here or in the background
    // isolate) re-checks the account list before persisting anything.
    await _repo.removeMetadata(id);
    // Waits for an in-flight re-auth and deletes under the account lock.
    await ref.read(sessionManagerProvider).forget(id);
    // The community session is also held in memory (AR-018).
    try {
      await ref.read(communityAuthProvider).forget(id);
    } on Object {
      // Best effort: its secure-storage key is wiped below anyway.
    }
    // Backstop: deletes the secrets again, plus prefs and file caches, and
    // blocks late writes from in-flight fetches.
    await _repo.wipeAccountData(id, keepLocalData: keepLocalData);
    if (!keepLocalData) {
      await ref.read(localDataEraserProvider).eraseAccount(id);
      ref.invalidate(loadoutPresetsProvider(id));
    }
    await ref.read(appSettingsProvider.notifier).update((settings) {
      if (!settings.wishlistNotificationsByAccount.containsKey(id)) {
        return settings;
      }
      final choices = {...settings.wishlistNotificationsByAccount}..remove(id);
      return settings.copyWith(wishlistNotificationsByAccount: choices);
    });
    final remaining = _repo.loadAll();
    if (_repo.activePuuid == id) {
      await _repo.setActivePuuid(remaining.firstOrNull?.puuid);
    }
    await _repo.clearPendingWipe(id);
    if (ref.mounted) state = remaining;
  }

  /// "Đăng xuất tất cả tài khoản". Other players' data (names, matches) always
  /// goes; the accounts' own local data goes unless [keepLocalData].
  Future<void> signOutAll({bool keepLocalData = true}) async {
    for (final account in List.of(state)) {
      await remove(account.puuid, keepLocalData: keepLocalData);
    }
    final eraser = ref.read(localDataEraserProvider);
    if (keepLocalData) {
      await eraser.eraseSharedCaches();
    } else {
      await eraser.eraseAll(signedIn: const {});
    }
    ref.invalidate(nameResolverProvider);
  }

  /// "Xóa dữ liệu cục bộ" (Settings): RR history, loadout presets, looked-up
  /// names, opened matches, and what is still kept for accounts that were
  /// signed out. Signed-in accounts and their wishlists stay.
  Future<void> clearLocalData() async {
    await ref
        .read(localDataEraserProvider)
        .eraseAll(signedIn: {for (final a in state) a.puuid});
    ref
      ..invalidate(nameResolverProvider)
      ..invalidate(loadoutPresetsProvider);
  }
}

/// PUUID of the account shown in the UI (persisted). Falls back to the first
/// account when the stored one no longer exists.
final activePuuidProvider = NotifierProvider<ActivePuuidNotifier, String?>(
  ActivePuuidNotifier.new,
);

class ActivePuuidNotifier extends Notifier<String?> {
  @override
  String? build() {
    final accounts = ref.watch(accountsProvider);
    final stored = ref.read(accountRepositoryProvider).activePuuid;
    if (stored != null && accounts.any((a) => a.puuid == stored)) return stored;
    return accounts.firstOrNull?.puuid;
  }

  /// Switches the active account (A3/A6). Data providers are families keyed
  /// by PUUID, so no global invalidation is needed.
  void select(String? puuid) {
    final id = puuid?.toLowerCase();
    unawaited(ref.read(accountRepositoryProvider).setActivePuuid(id));
    state = id;
  }
}

/// The active [Account], or `null` when signed out.
///
/// ```dart
/// final account = ref.watch(activeAccountProvider);
/// if (account == null) return const EmptyView(...);
/// final store = ref.watch(myStorefrontProvider(account.puuid));
/// ```
final activeAccountProvider = Provider<Account?>((ref) {
  final puuid = ref.watch(activePuuidProvider);
  if (puuid == null) return null;
  for (final a in ref.watch(accountsProvider)) {
    if (a.puuid == puuid) return a;
  }
  return null;
});

/// One account by PUUID (`null` when signed out). Data providers watch
/// its `needsLogin` flag so they refetch automatically after a re-login:
///
/// ```dart
/// ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
/// ```
final accountProvider = Provider.family<Account?, String>((ref, puuid) {
  final id = puuid.toLowerCase();
  for (final a in ref.watch(accountsProvider)) {
    if (a.puuid == id) return a;
  }
  return null;
});

/// Whether at least one account exists (drives the router redirect).
final hasAccountsProvider = Provider<bool>(
  (ref) => ref.watch(accountsProvider).isNotEmpty,
);
