import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoAlertDialog,
        CupertinoDialogAction,
        showCupertinoModalPopup;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/common_strings.dart';

/// Platform-adaptive building blocks: iOS gets Cupertino dialogs and action
/// sheets, Android keeps Material 3. Every helper reads the platform from
/// `Theme.of(context).platform`, so widget tests can switch it with
/// `ThemeData(platform: TargetPlatform.iOS)` or
/// `debugDefaultTargetPlatformOverride`.

/// Whether [context] should render iOS-style widgets (iOS / macOS).
bool isCupertino(BuildContext context) => switch (Theme.of(context).platform) {
  TargetPlatform.iOS || TargetPlatform.macOS => true,
  _ => false,
};

/// Haptic feedback for key interactions. Fire-and-forget; a no-op on
/// platforms without a haptic engine.
abstract final class Haptics {
  /// Segment / filter / picker changes.
  static void selection() => unawaited(HapticFeedback.selectionClick());

  /// Toggles, "add to wishlist", equip.
  static void light() => unawaited(HapticFeedback.lightImpact());

  /// Confirmed account-changing actions (lock agent, apply preset).
  static void medium() => unawaited(HapticFeedback.mediumImpact());

  /// Destructive confirmations (quit match, remove account).
  static void heavy() => unawaited(HapticFeedback.heavyImpact());
}

/// "Hủy" / confirm dialog: `CupertinoAlertDialog` on iOS, Material
/// `AlertDialog` elsewhere. Resolves to `true` only when [confirmLabel] was
/// tapped (dismissal → `false`).
///
/// [destructive] paints the confirm action red (and on iOS marks it as a
/// destructive action); [icon] is shown above the title on Android.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = CommonStrings.cancel,
  bool destructive = false,
  IconData? icon,
}) async {
  final cupertino = isCupertino(context);
  final ok = await showAdaptiveDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      void close(bool v) => Navigator.of(dialogContext).pop(v);
      if (cupertino) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: destructive,
              onPressed: () => close(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDefaultAction: !destructive,
              isDestructiveAction: destructive,
              onPressed: () => close(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      }
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: icon == null
            ? null
            : Icon(icon, color: destructive ? scheme.error : scheme.primary),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => close(false), child: Text(cancelLabel)),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => close(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  if (ok == true) destructive ? Haptics.heavy() : Haptics.light();
  return ok ?? false;
}

/// One entry of [showActionSheet].
@immutable
class SheetAction<T> {
  const SheetAction({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;

  /// Leading icon (Material bottom sheet only; iOS action sheets are text).
  final IconData? icon;
  final bool destructive;
}

/// A list of actions: `CupertinoActionSheet` (with a separate "Hủy") on iOS,
/// a Material modal bottom sheet elsewhere. Returns the picked value, or
/// `null` when dismissed.
Future<T?> showActionSheet<T>(
  BuildContext context, {
  required List<SheetAction<T>> actions,
  String? title,
  String? message,
}) {
  if (isCupertino(context)) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: message == null ? null : Text(message),
        actions: [
          for (final a in actions)
            CupertinoActionSheetAction(
              isDestructiveAction: a.destructive,
              onPressed: () => Navigator.of(sheetContext).pop(a.value),
              child: Text(a.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text(CommonStrings.cancel),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final error = theme.colorScheme.error;
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final a in actions)
              ListTile(
                minTileHeight: 52,
                leading: a.icon == null
                    ? null
                    : Icon(a.icon, color: a.destructive ? error : null),
                title: Text(
                  a.label,
                  style: a.destructive ? TextStyle(color: error) : null,
                ),
                onTap: () => Navigator.of(sheetContext).pop(a.value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

/// Pull-to-refresh that looks native on each platform (Cupertino spinner on
/// iOS, Material ring elsewhere). Thin wrapper over
/// [RefreshIndicator.adaptive] with the app's accent color.
class AdaptiveRefresh extends StatelessWidget {
  const AdaptiveRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double edgeOffset;

  @override
  Widget build(BuildContext context) => RefreshIndicator.adaptive(
    onRefresh: () {
      Haptics.light();
      return onRefresh();
    },
    edgeOffset: edgeOffset,
    child: child,
  );
}
