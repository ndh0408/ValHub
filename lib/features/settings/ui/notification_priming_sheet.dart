import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/val_widgets.dart';
import '../settings_strings.dart';
import 'widgets/settings_widgets.dart';

/// Outcome of the notification priming flow (S04).
enum NotificationPrimingResult {
  /// Notifications are allowed (already, or after the OS prompt).
  granted,

  /// The user tapped "Bật thông báo" but the OS refused (denied now or
  /// earlier, so the prompt no longer appears).
  denied,

  /// The user tapped "Để sau" or dismissed the sheet.
  dismissed,
}

/// Opens S04, a priming card shown BEFORE the OS permission prompt.
///
/// Skips the sheet when notifications are already allowed. When the user
/// taps "Bật thông báo" the sheet itself calls
/// `NotificationService.requestPermission()`. Returns `true` when
/// notifications are allowed afterwards.
Future<bool> showNotificationPrimingSheet(BuildContext context) async =>
    await runNotificationPriming(context) == NotificationPrimingResult.granted;

/// Same as [showNotificationPrimingSheet] but tells "Để sau" apart from an
/// OS refusal.
Future<NotificationPrimingResult> runNotificationPriming(
  BuildContext context,
) async {
  final service = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(notificationServiceProvider);
  if (await service.areEnabled()) return NotificationPrimingResult.granted;
  if (!context.mounted) return NotificationPrimingResult.dismissed;
  return await showModalBottomSheet<NotificationPrimingResult>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => const NotificationPrimingSheet(),
      ) ??
      NotificationPrimingResult.dismissed;
}

/// S04 "Bật thông báo" / "Để sau". Pops a [NotificationPrimingResult].
class NotificationPrimingSheet extends ConsumerStatefulWidget {
  const NotificationPrimingSheet({super.key});

  @override
  ConsumerState<NotificationPrimingSheet> createState() =>
      _NotificationPrimingSheetState();
}

class _NotificationPrimingSheetState
    extends ConsumerState<NotificationPrimingSheet> {
  bool _requesting = false;

  Future<void> _enable() async {
    setState(() => _requesting = true);
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (!mounted) return;
    Navigator.of(context).pop(
      granted
          ? NotificationPrimingResult.granted
          : NotificationPrimingResult.denied,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: StateIcon(
              icon: Icons.notifications_active_outlined,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            SettingsStrings.primingTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            SettingsStrings.primingBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ValCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                for (final (icon, color, text) in const [
                  (
                    Icons.storefront_outlined,
                    ValColors.red,
                    SettingsStrings.primingPointStore,
                  ),
                  (
                    Icons.favorite_border,
                    TierColors.premium,
                    SettingsStrings.primingPointWishlist,
                  ),
                  (
                    Icons.nightlight_outlined,
                    Color(0xFF9B7BFF),
                    SettingsStrings.primingPointNightMarket,
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SettingsIcon(icon, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            onPressed: _requesting ? null : () => unawaited(_enable()),
            child: _requesting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(SettingsStrings.primingEnable),
          ),
          const SizedBox(height: 4),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: _requesting
                ? null
                : () =>
                      Navigator.of(context)
                          .pop(NotificationPrimingResult.dismissed),
            child: const Text(SettingsStrings.primingLater),
          ),
        ],
      ),
    );
  }
}
