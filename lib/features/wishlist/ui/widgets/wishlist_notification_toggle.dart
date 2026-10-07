import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../settings/ui/notification_priming_sheet.dart';
import '../../../settings/providers/settings_providers.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// "Thông báo wishlist" switch (S3A shortcut to the settings switch
/// "Kiểm tra wishlist trong nền", W2/W4). Turning it on primes the OS
/// permission first (S04).
class WishlistNotificationToggle extends ConsumerStatefulWidget {
  const WishlistNotificationToggle({super.key});

  @override
  ConsumerState<WishlistNotificationToggle> createState() =>
      _WishlistNotificationToggleState();
}

class _WishlistNotificationToggleState
    extends ConsumerState<WishlistNotificationToggle> {
  bool _busy = false;

  Future<void> _set(bool on) async {
    final messages = context.l10n;
    final account = ref.read(activeAccountProvider);
    if (account == null) return;
    final settings = ref.read(settingsControllerProvider);
    if (!on) {
      await settings.setWishlistNotification(account.puuid, false);
      return;
    }
    setState(() => _busy = true);
    try {
      final granted = await showNotificationPrimingSheet(context);
      if (!mounted) return;
      if (granted) {
        await settings.setWishlistNotification(account.puuid, true);
      } else {
        final messenger = ScaffoldMessenger.maybeOf(context);
        final service = ref.read(notificationServiceProvider);
        messenger?.showSnackBar(
          SnackBar(
            content: Text(messages.wishlistNotifPermissionMissing),
            action: SnackBarAction(
              label: messages.wishlistOpenSettings,
              onPressed: () => unawaited(service.openSystemSettings()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final account = ref.watch(activeAccountProvider);
    final on = ref.watch(
      appSettingsProvider.select(
        (s) => account != null && s.wishlistNotificationsFor(account.puuid),
      ),
    );
    return ValCard(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: EdgeInsets.zero,
      child: SwitchListTile.adaptive(
        value: on,
        onChanged: _busy
            ? null
            : (v) {
                Haptics.selection();
                unawaited(_set(v));
              },
        secondary: Icon(
          on ? Icons.notifications_active : Icons.notifications_none_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(context.l10n.wishlistNotifToggle),
        // The page already names the account.
        subtitle: Text(context.l10n.wishlistNotifToggleSubtitle),
      ),
    );
  }
}
