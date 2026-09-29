import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/sub_page.dart';
import '../settings_strings.dart';

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
  return await showValSheet<NotificationPrimingResult>(
        context,
        title: SettingsStrings.primingTitle,
        builder: (_, _) => const NotificationPrimingSheet(),
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
    final hairline = valColorsOf(context).hairline;
    const points = [
      (
        Icons.storefront_outlined,
        ValColors.red,
        SettingsStrings.primingPointStore,
        SettingsStrings.primingPointStoreDetail,
      ),
      (
        Icons.favorite_border,
        TierColors.premium,
        SettingsStrings.primingPointWishlist,
        SettingsStrings.primingPointWishlistDetail,
      ),
      (
        Icons.nightlight_outlined,
        Color(0xFF9B7BFF),
        SettingsStrings.primingPointNightMarket,
        SettingsStrings.primingPointNightMarketDetail,
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _BellArt()),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              SettingsStrings.primingBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: scheme.surfaceContainer,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ValRadius.card),
              side: theme.brightness == Brightness.light
                  ? BorderSide(color: hairline)
                  : BorderSide.none,
            ),
            child: Column(
              children: [
                for (var i = 0; i < points.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: hairline),
                  _Benefit(
                    icon: points[i].$1,
                    color: points[i].$2,
                    title: points[i].$3,
                    detail: points[i].$4,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tune, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  SettingsStrings.primingFootnote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
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
                : () => Navigator.of(
                    context,
                  ).pop(NotificationPrimingResult.dismissed),
            child: const Text(SettingsStrings.primingLater),
          ),
        ],
      ),
    );
  }
}

/// The bell in two concentric tinted rings (illustration of the sheet).
class _BellArt extends StatelessWidget {
  const _BellArt();

  @override
  Widget build(BuildContext context) {
    final accent = legibleAccent(context, ValColors.red, min: 3);
    return ExcludeSemantics(
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.08),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.16),
          ),
          child: Icon(
            Icons.notifications_active_rounded,
            size: 36,
            color: accent,
          ),
        ),
      ),
    );
  }
}

/// One benefit: tinted icon tile, bold title, muted detail.
class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = legibleAccent(context, color, min: 3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
