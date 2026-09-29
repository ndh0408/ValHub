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
import '../theme/app_theme.dart';

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
      final theme = Theme.of(dialogContext);
      final scheme = theme.colorScheme;
      final tint = destructive ? scheme.error : scheme.primary;
      final disc =
          icon ??
          (destructive
              ? Icons.warning_amber_rounded
              : Icons.help_outline_rounded);
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        icon: _IconDisc(
          icon: disc,
          color: tint,
          size: 56,
          iconSize: 28,
          strong: true,
        ),
        iconPadding: const EdgeInsets.only(top: 24),
        title: Text(title, textAlign: TextAlign.center),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        actionsAlignment: MainAxisAlignment.end,
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              minimumSize: const Size(64, 44),
            ),
            onPressed: () => close(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(64, 44),
              backgroundColor: destructive ? scheme.error : null,
              foregroundColor: destructive ? scheme.onError : null,
            ),
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
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final scheme = theme.colorScheme;
      final hairline = valColorsOf(sheetContext).hairline;
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.9;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ValText.sectionTitle.copyWith(
                            fontSize: 20,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Material(
                  color: scheme.surfaceContainer,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ValRadius.card),
                    side: theme.brightness == Brightness.light
                        ? BorderSide(color: hairline)
                        : BorderSide.none,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, thickness: 1, color: hairline),
                        _SheetActionRow<T>(
                          action: actions[i],
                          onTap: () =>
                              Navigator.of(sheetContext).pop(actions[i].value),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// One 52 dp row of the Material action sheet: tinted icon disc (when the
/// action has an icon), label, red for destructive actions.
class _SheetActionRow<T> extends StatelessWidget {
  const _SheetActionRow({required this.action, required this.onTap});

  final SheetAction<T> action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = action.destructive ? scheme.error : scheme.onSurface;
    final icon = action.icon;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                _IconDisc(
                  icon: icon,
                  color: action.destructive ? scheme.error : scheme.primary,
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  action.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon in a disc tinted 12 % of [color] (14 % when [strong]).
class _IconDisc extends StatelessWidget {
  const _IconDisc({
    required this.icon,
    required this.color,
    this.size = 36,
    this.iconSize = 20,
    this.strong = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final bool strong;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: strong ? 0.14 : 0.12),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: legibleAccent(context, color, min: 3),
      ),
    ),
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
