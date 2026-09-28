import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_callback.dart';
import '../auth/auth_providers.dart';
import '../auth/cookie_jar.dart';
import '../config/app_constants.dart';
import '../notifications/notification_service.dart';
import '../riot/riot_hosts.dart';
import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../storage/secure_store.dart';
import 'account.dart';
import 'account_repository.dart';

/// Account metadata persistence (prefs) + per-account data wipe.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(
    prefs: ref.watch(prefsProvider),
    secureStore: ref.watch(secureStoreProvider),
    fileCache: ref.watch(jsonFileCacheProvider),
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
    if (!ref.mounted) return account;
    state = _repo.loadAll();
    ref.read(activePuuidProvider.notifier).select(account.puuid);
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
  /// cookies, tokens, `acct.<puuid>.*` prefs and `acct/<puuid>/…` caches.
  /// The wishlist (`keep.<puuid>.*`) is kept (VF W6).
  Future<void> remove(String puuid) async {
    final id = puuid.toLowerCase();
    await ref.read(notificationServiceProvider).cancelForAccount(id);
    await ref.read(sessionManagerProvider).forget(id);
    await _repo.wipeAccountData(id);
    await _repo.removeMetadata(id);
    if (!ref.mounted) return;
    state = _repo.loadAll();
    final active = ref.read(activePuuidProvider);
    if (active == id) {
      ref.read(activePuuidProvider.notifier).select(state.firstOrNull?.puuid);
    }
  }

  /// "Đăng xuất tất cả tài khoản".
  Future<void> signOutAll() async {
    for (final account in List.of(state)) {
      await remove(account.puuid);
    }
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

/// Whether at least one account exists (drives the router redirect).
final hasAccountsProvider = Provider<bool>(
  (ref) => ref.watch(accountsProvider).isNotEmpty,
);
