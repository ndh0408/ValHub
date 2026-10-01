import 'dart:async';

import '../../../../core/l10n/notification_strings.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/domain/economy/saved_storefront.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../providers/settings_providers.dart';
import '../../settings_strings.dart';
import '../notification_priming_sheet.dart';
import '../widgets/settings_widgets.dart';

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
    final accounts = ref.watch(accountsProvider);
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
    return SettingsGroup(
      title: SettingsStrings.notificationsHeader,
      children: [
        if (showWarning) const _PermissionWarning(),
        for (final (toggle, icon, title, subtitle) in [
          (
            NotificationToggle.storeReset,
            Icons.storefront_outlined,
            SettingsStrings.notifStoreReset,
            resetAt == null
                ? NotificationStrings.resetTimingUnknown
                : SettingsStrings.notifStoreResetSubtitle(formatTime(resetAt)),
          ),
          (
            NotificationToggle.nightMarket,
            Icons.nightlight_outlined,
            SettingsStrings.notifNightMarket,
            SettingsStrings.notifNightMarketSubtitle,
          ),
          (
            NotificationToggle.battlePass,
            Icons.notifications_outlined,
            NotificationStrings.channelBattlePassName,
            NotificationStrings.localOnlyHint,
          ),
          (
            NotificationToggle.rank,
            Icons.notifications_outlined,
            NotificationStrings.channelRankName,
            NotificationStrings.localOnlyHint,
          ),
          (
            NotificationToggle.community,
            Icons.notifications_outlined,
            NotificationStrings.channelCommunityName,
            NotificationStrings.localOnlyHint,
          ),
          (
            NotificationToggle.lfg,
            Icons.notifications_outlined,
            NotificationStrings.channelLfgName,
            NotificationStrings.localOnlyHint,
          ),
        ])
          SettingsSwitchTile(
            icon: icon,
            title: title,
            subtitle: subtitle,
            value: toggle.valueIn(settings),
            onChanged: (v) => unawaited(_toggle(toggle, v)),
          ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(NotificationStrings.backgroundTimingHint),
        ),
        for (final account in accounts)
          SettingsSwitchTile(
            icon: Icons.favorite_border,
            title: SettingsStrings.notifWishlist,
            subtitle:
                '${account.riotId} · ${SettingsStrings.notifWishlistSubtitle}',
            value: settings.wishlistNotificationsFor(account.puuid),
            onChanged: (v) => unawaited(_toggleWishlist(account.puuid, v)),
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
        border: Border(left: BorderSide(color: warning, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
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
                  SettingsStrings.notifPermissionMissing,
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
              child: const Text(CommonStrings.openSettings),
            ),
          ),
        ],
      ),
    );
  }
}
