import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../config/remote_config.dart';
import '../../network/riot_exception.dart';

/// Signed-in account whose session is used to look at [subject]'s data.
///
/// - [subject] is itself a signed-in account → that account (its own
///   tokens, shard and `needsLogin` state apply).
/// - Anyone else (friend, live-game player, match participant) → the active
///   account. MMR, competitive updates, match history, match details and
///   name-service are "any player" endpoints (SUMMARY §6.2).
///
/// Throws [NeedsLoginException] when nobody is signed in. Also watches the
/// viewer's `needsLogin` flag so callers refetch after a re-login.
String watchViewer(Ref ref, String subject) {
  final id = subject.trim().toLowerCase();
  final isOwn = ref.watch(accountProvider(id).select((a) => a != null));
  final viewer = isOwn ? id : ref.watch(activePuuidProvider);
  if (viewer == null) {
    throw const NeedsLoginException(reason: 'no_account');
  }
  ref.watch(accountProvider(viewer).select((a) => (a?.needsLogin, a?.region)));
  return viewer;
}

/// Whether console queue keys apply to [viewer] (SUMMARY U12): the account
/// is set to a console platform and the `console_support` flag is on.
bool watchIsConsole(Ref ref, String viewer) {
  final enabled = ref.watch(
    remoteConfigProvider.select((c) => c.flag(RemoteFlags.consoleSupport)),
  );
  if (!enabled) return false;
  return ref.watch(
    accountProvider(viewer).select((a) => a?.platform.isConsole ?? false),
  );
}

/// Keeps an auto-dispose provider's value for [duration] after it was
/// built, so re-opening a screen within that window does not refetch
/// (SUMMARY §10 cache TTLs).
///
/// Call it **after** the fetch succeeded (AR-029): a provider that failed
/// must not stay cached for minutes, the next visit retries at once. It is a
/// no-op when the provider was disposed while the fetch was running.
void cacheFor(Ref ref, Duration duration) {
  if (!ref.mounted) return;
  final link = ref.keepAlive();
  final timer = Timer(duration, link.close);
  ref.onDispose(timer.cancel);
}

/// Riot queue id for a platform: `competitive` → `console_competitive` on
/// console (SUMMARY §7.5). `null` / `""` (all queues) stay as they are.
String? queueForPlatform(String? queue, {required bool console}) {
  final q = queue?.trim().toLowerCase();
  if (q == null || q.isEmpty || !console || q.startsWith('console_')) {
    return q;
  }
  return 'console_$q';
}

/// PC queue id of a (possibly console) queue id.
String baseQueueId(String? queue) {
  final q = (queue ?? '').trim().toLowerCase();
  return q.startsWith('console_') ? q.substring('console_'.length) : q;
}
