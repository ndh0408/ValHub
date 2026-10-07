import 'package:valvn/core/l10n/account_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/domain/economy/saved_storefront.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../providers/settings_providers.dart';
import '../notification_priming_sheet.dart';
import '../widgets/settings_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// "THÔNG BÁO" (S70, B8/W2/W4): store reset, background wishlist check,
/// Night Market. Turning a switch on primes the OS permission first (S04);
/// a warning row appears while a switch is on but the OS blocks
/// notifications (VF §8.5 notifPermissionMissing).
/// Advances the last reset returned by Riot along its daily cadence.
/// Without a known expiry, the reset time remains unknown.
DateTime? nextDailyStoreReset(DateTime now, {DateTime? expiresAt}) {
  if (expiresAt == null) return null;
  if (expiresAt.isAfter(now)) return expiresAt;
  return expiresAt.add(
    Duration(
      days:
          now.difference(expiresAt).inMicroseconds ~/
              const Duration(days: 1).inMicroseconds +
          1,
    ),
  );
}

class SettingsNotificationsSection extends ConsumerStatefulWidget {
  const SettingsNotificationsSection({super.key});

  @override
  ConsumerState<SettingsNotificationsSection> createState() =>
      _SettingsNotificationsSectionState();
}

class _SettingsNotificationsSectionState
    extends ConsumerState<SettingsNotificationsSection> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The user may flip the permission in the system settings and come back.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsAllowedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _toggle(NotificationToggle toggle, bool on) async {
    final controller = ref.read(settingsControllerProvider);
    if (!on) {
      await controller.setNotification(toggle, false);
      return;
    }
    final result = await runNotificationPriming(context);
    if (result == NotificationPrimingResult.dismissed) return;
    await controller.setNotification(toggle, true);
    if (mounted) ref.invalidate(notificationsAllowedProvider);
  }

  Future<void> _toggleWishlist(String puuid, bool on) async {
    final controller = ref.read(settingsControllerProvider);
    if (!on) {
      await controller.setWishlistNotification(puuid, false);
      return;
    }
    final result = await runNotificationPriming(context);
    if (result == NotificationPrimingResult.dismissed) return;
    await controller.setWishlistNotification(puuid, true);
    if (mounted) ref.invalidate(notificationsAllowedProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final allowed = ref.watch(notificationsAllowedProvider).value;
    final active = ref.watch(activeAccountProvider);
    final savedStore = active == null
        ? null
        : ref.watch(savedStorefrontProvider(active.puuid)).value;
    final resetAt = nextDailyStoreReset(
      ref.watch(clockProvider).now(),
      expiresAt: savedStore?.daily.expiresAt,
    );
    final showWarning =
        allowed == false &&
        (settings.storeResetNotifications ||
            settings.nightMarketNotifications ||
            anyNotificationEnabled(settings));
    // Wishlist alerts belong to an account: only the active one's is here
    // (switch accounts to change another's), named so it is clear whose.
    return SettingsGroup(
      title: context.l10n.settingsNotificationsHeader,
      footer: Text(context.l10n.notificationBackgroundTimingHint),
      children: [
        if (showWarning) const _PermissionWarning(),
        for (final (toggle, icon, title, subtitle) in [
          (
            NotificationToggle.storeReset,
            Icons.storefront_outlined,
            context.l10n.settingsNotifStoreReset,
            resetAt == null
                ? context.l10n.notificationResetTimingUnknown
                : context.l10n.settingsNotifStoreResetSubtitle(
                    formatTime(roundToMinute(resetAt)),
                  ),
          ),
          (
            NotificationToggle.nightMarket,
            Icons.nightlight_outlined,
            context.l10n.settingsNotifNightMarket,
            context.l10n.settingsNotifNightMarketSubtitle,
          ),
        ])
          SettingsSwitchTile(
            icon: icon,
            title: title,
            subtitle: subtitle,
            value: toggle.valueIn(settings),
            onChanged: (v) => unawaited(_toggle(toggle, v)),
          ),
        if (active != null)
          SettingsSwitchTile(
            icon: Icons.favorite_border,
            title: context.l10n.settingsNotifWishlist,
            subtitle: active.displayRiotId(context.l10n),
            value: settings.wishlistNotificationsFor(active.puuid),
            onChanged: (v) => unawaited(_toggleWishlist(active.puuid, v)),
          ),
        for (final (toggle, icon, title, subtitle) in [
          (
            NotificationToggle.battlePass,
            Icons.military_tech_outlined,
            context.l10n.notificationChannelBattlePassName,
            context.l10n.notificationChannelBattlePassDescription,
          ),
          (
            NotificationToggle.rank,
            Icons.trending_up_rounded,
            context.l10n.notificationChannelRankName,
            context.l10n.notificationChannelRankDescription,
          ),
          (
            NotificationToggle.lfg,
            Icons.group_add_outlined,
            context.l10n.notificationChannelLfgName,
            context.l10n.notificationChannelLfgDescription,
          ),
        ])
          SettingsSwitchTile(
            icon: icon,
            title: title,
            subtitle: subtitle,
            value: toggle.valueIn(settings),
            onChanged: (v) => unawaited(_toggle(toggle, v)),
          ),
      ],
    );
  }
}

class _PermissionWarning extends ConsumerWidget {
  const _PermissionWarning();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final warning = valColorsOf(context).warning;
    return Container(
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.10),
        border: BorderDirectional(start: BorderSide(color: warning, width: 4)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_off_outlined, color: warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.settingsNotifPermissionMissing,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => unawaited(
                ref.read(notificationServiceProvider).openSystemSettings(),
              ),
              child: Text(context.l10n.commonOpenSettings),
            ),
          ),
        ],
      ),
    );
  }
}
