import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accounts/account_providers.dart';
import '../config/client_version.dart';
import '../config/remote_config.dart';
import '../logging/session_log.dart';
import '../storage/secure_store.dart';
import '../util/clock.dart';
import 'account_lock.dart';
import 'bootstrap_client.dart';
import 'reauth_client.dart';
import 'riot_session.dart';
import 'session_manager.dart';

/// Silent re-auth client (auth hosts, redirects not followed).
final reauthClientProvider = Provider<RiotReauthClient>((ref) {
  final versions = ref.watch(clientVersionRepositoryProvider);
  return RiotReauthClient(userAgent: () => versions.apiUserAgent);
});

/// Entitlements / userinfo / riot-geo client.
final bootstrapClientProvider = Provider<RiotBootstrapClient>((ref) {
  final versions = ref.watch(clientVersionRepositoryProvider);
  return RiotBootstrapClient(userAgent: () => versions.apiUserAgent);
});

/// Cross-isolate re-auth lock.
final accountLockProvider = Provider<AccountLock>((ref) => PrefsAccountLock());

/// The one [SessionManager] of the UI isolate.
final sessionManagerProvider = Provider<SessionManager>((ref) {
  final manager = SessionManager(
    secureStore: ref.watch(secureStoreProvider),
    accounts: ref.watch(accountRepositoryProvider),
    reauthClient: ref.watch(reauthClientProvider),
    bootstrapClient: ref.watch(bootstrapClientProvider),
    versions: ref.watch(clientVersionRepositoryProvider),
    remoteConfig: () => ref.read(remoteConfigProvider),
    lock: ref.watch(accountLockProvider),
    log: ref.watch(sessionLogProvider),
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

/// A valid [RiotSession] for one account. Rarely needed directly: [PvpApi]
/// attaches sessions itself. Throws `NeedsLoginException` /
/// `TransientException`.
final sessionProvider = FutureProvider.autoDispose.family<RiotSession, String>(
  (ref, puuid) => ref.watch(sessionManagerProvider).session(puuid),
);
