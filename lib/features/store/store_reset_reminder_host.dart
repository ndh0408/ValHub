import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account.dart';
import '../../core/accounts/account_providers.dart';
import '../../core/domain/economy/economy.dart';
import '../../core/l10n/l10n.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/util/clock.dart';
import 'providers/store_reset_reminder.dart';

/// Keeps the "Cửa hàng đã làm mới" reminder scheduled whether or not the
/// Store tab was ever built (Home is the landing tab now, so nothing else
/// would fetch the storefront and the reminder would silently stop after
/// its first day).
///
/// While the setting is on:
/// - the **active** account's storefront is watched (it refetches by itself
///   at every reset), and every new storefront reschedules that account's
///   reminder (same notification id, so it replaces the pending one);
/// - the **other** accounts are scheduled from the storefront copy saved on
///   the device (no network) while its reset is still ahead.
///
/// Mounted once by the app shell, around the tab content.
class StoreResetReminderHost extends ConsumerStatefulWidget {
  const StoreResetReminderHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StoreResetReminderHost> createState() =>
      _StoreResetReminderHostState();
}

class _StoreResetReminderHostState
    extends ConsumerState<StoreResetReminderHost> {
  /// Last storefront a reminder was scheduled for, per account (one per
  /// fetch, so rebuilds do not reschedule).
  final Map<String, Storefront> _scheduled = {};
  AppLocalizations? _scheduledLocale;

  void _onStorefront(Account account, Storefront? store) {
    final puuid = account.puuid;
    if (store == null || identical(_scheduled[puuid], store)) return;
    _scheduled[puuid] = store;
    final l10n = _scheduledLocale!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_scheduledLocale, l10n)) return;
      if (!ref.read(appSettingsProvider).storeResetNotifications ||
          ref.read(accountProvider(puuid)) == null) {
        return;
      }
      unawaited(
        scheduleStoreResetReminder(
          ref.read(notificationServiceProvider),
          account: account,
          store: store,
          now: ref.read(clockProvider).now(),
          l10n: l10n,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    if (!identical(_scheduledLocale, l10n)) {
      _scheduled.clear();
      _scheduledLocale = l10n;
    }
    final on = ref.watch(
      appSettingsProvider.select((s) => s.storeResetNotifications),
    );
    if (!on) {
      _scheduled.clear();
      return widget.child;
    }
    final active = ref.watch(
      activeAccountProvider.select((a) => a == null || a.needsLogin ? null : a),
    );
    if (active != null) {
      _onStorefront(active, ref.watch(storefrontProvider(active.puuid)).value);
    }
    // Everyone else: their saved copy, no network.
    final others = ref.watch(
      accountsProvider.select(
        (list) => [
          for (final a in list)
            if (!a.needsLogin && a.puuid != active?.puuid) a,
        ],
      ),
    );
    for (final account in others) {
      _onStorefront(
        account,
        ref.watch(savedStorefrontProvider(account.puuid)).value,
      );
    }
    return widget.child;
  }
}
