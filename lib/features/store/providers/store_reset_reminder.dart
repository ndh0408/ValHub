/// "Cửa hàng đã làm mới" local reminder (SUMMARY §8.2 B8, VF §6.9).
///
/// The store screen calls [scheduleStoreResetReminder] after every new
/// storefront while the setting is on; scheduling again replaces the pending
/// notification (same id per account), so it always matches the latest
/// reset time.
library;

import '../../../core/accounts/account.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/notifications/notification_service.dart';
import '../store_routes.dart';
import '../store_strings.dart';

/// Fire a little after the reset so the new offers are already live.
const kStoreResetReminderDelay = Duration(minutes: 1);

/// Everything needed to schedule one reset reminder.
class StoreResetReminder {
  const StoreResetReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    required this.accountPuuid,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Deep link opened from the notification (`/store?account=…`).
  final String payload;
  final String accountPuuid;
}

/// The reminder for [store]'s next daily reset, or `null` when the reset
/// time is unknown or already past at [now].
StoreResetReminder? storeResetReminderFor({
  required Account account,
  required Storefront store,
  required DateTime now,
}) {
  final resetAt = store.daily.expiresAt;
  if (resetAt == null) return null;
  final at = resetAt.add(kStoreResetReminderDelay);
  if (!at.isAfter(now)) return null;
  final puuid = account.puuid;
  final uri = Uri(path: StoreRoutes.root, queryParameters: {'account': puuid});
  return StoreResetReminder(
    id: NotificationIds.storeReset(puuid),
    at: at,
    title: StoreStrings.resetNotificationTitle,
    body: StoreStrings.resetNotificationBody(
      store.daily.offers.length,
      account.riotId,
    ),
    payload: uri.toString(),
    accountPuuid: puuid,
  );
}

/// Schedules (or re-schedules) the reset reminder for [store]. Best effort:
/// returns `false` when nothing was scheduled (no reset time, or the
/// platform refused).
Future<bool> scheduleStoreResetReminder(
  NotificationService notifications, {
  required Account account,
  required Storefront store,
  required DateTime now,
}) async {
  final reminder = storeResetReminderFor(
    account: account,
    store: store,
    now: now,
  );
  if (reminder == null) return false;
  try {
    await notifications.scheduleAt(
      id: reminder.id,
      at: reminder.at,
      title: reminder.title,
      body: reminder.body,
      channel: NotificationChannel.storeReset,
      payload: reminder.payload,
      accountPuuid: reminder.accountPuuid,
    );
    return true;
  } on Object {
    return false;
  }
}
