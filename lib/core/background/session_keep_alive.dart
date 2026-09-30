import 'dart:async';

import '../l10n/notification_strings.dart';
import '../network/riot_exception.dart';
import '../notifications/notification_service.dart';
import '../storage/prefs.dart';
import 'background_context.dart';

/// Re-auths dormant accounts so their rotated cookies keep sliding forward
/// (SUMMARY §3.4: "re-auth dormant accounts at least every ~7 days"). Runs at
/// most once every 3 days per account, within a ~20 s budget (iOS gives
/// ~30 s). Sends one "Cần đăng nhập lại" notification when an account's
/// cookies die.
Future<bool> runSessionKeepAlive({
  Duration budget = const Duration(seconds: 20),
}) async {
  final ctx = await BackgroundContext.instance();
  try {
    return await _keepAlive(ctx, budget);
  } finally {
    try {
      await ctx.finish();
    } on Object {
      // Flushing the session log is best effort.
    }
  }
}

Future<bool> _keepAlive(BackgroundContext ctx, Duration budget) async {
  final started = DateTime.now();
  var ok = true;
  for (final account in ctx.accounts.loadAll()) {
    if (DateTime.now().difference(started) > budget) break;
    final lastKey = PrefKeys.account(account.puuid, 'keepAliveAt');
    final notifiedKey = PrefKeys.account(account.puuid, 'needsLoginNotified');
    if (account.needsLogin) continue;
    final last = ctx.prefs.getDateTime(lastKey);
    if (last != null &&
        DateTime.now().difference(last) < const Duration(days: 3)) {
      continue;
    }
    try {
      final remaining = budget - DateTime.now().difference(started);
      if (remaining <= Duration.zero) break;
      await ctx.sessions.session(account.puuid).timeout(remaining);
      if (await ctx.accounts.findFresh(account.puuid) == null) continue;
      await ctx.prefs.setDateTime(lastKey, DateTime.now());
      await ctx.prefs.remove(notifiedKey);
    } on NeedsLoginException {
      if (ctx.prefs.getBool(notifiedKey) != true) {
        await ctx.notifications.showNow(
          id: NotificationIds.sessionExpired(account.puuid),
          title: NotificationStrings.sessionExpiredTitle,
          body: NotificationStrings.sessionExpiredBody(account.riotId),
          channel: NotificationChannel.account,
          payload: '/login?reauth=${account.puuid}',
          accountPuuid: account.puuid,
        );
        await ctx.prefs.setBool(notifiedKey, true);
      }
    } on RiotException {
      ok = false;
    } on Object catch (e) {
      // Keystore/keychain or plugin error for this account: skip it, keep
      // the others (and the wishlist check that follows) running.
      ctx.log.add('keepAlive.error', detail: e.runtimeType.toString());
      ok = false;
    }
  }
  return ok;
}
