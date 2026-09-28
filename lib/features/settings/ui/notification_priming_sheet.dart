import 'package:material_ui/material_ui.dart';

import '../settings_strings.dart';

/// Opens S04: a priming card shown BEFORE the OS permission prompt. Returns
/// `true` when the user tapped "Bật thông báo" (the caller then calls
/// `NotificationService.requestPermission()`).
Future<bool> showNotificationPrimingSheet(BuildContext context) async =>
    await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (_) => const NotificationPrimingSheet(),
    ) ??
    false;

/// S04 "Bật thông báo" / "Để sau".
class NotificationPrimingSheet extends StatelessWidget {
  const NotificationPrimingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            SettingsStrings.primingTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(SettingsStrings.primingBody, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(SettingsStrings.primingEnable),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(SettingsStrings.primingLater),
          ),
        ],
      ),
    );
  }
}
