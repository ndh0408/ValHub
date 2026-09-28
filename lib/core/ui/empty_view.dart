import 'package:material_ui/material_ui.dart';

import '../l10n/common_strings.dart';

/// Centered empty state ("Không có dữ liệu" by default).
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = CommonStrings.noData,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.padding = const EdgeInsets.all(32),
  });

  final String message;
  final IconData icon;

  /// Optional button below the message.
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Placeholder body for screens that are not implemented yet.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    this.message = CommonStrings.featureInProgress,
  });

  final String message;

  @override
  Widget build(BuildContext context) =>
      EmptyView(message: message, icon: Icons.construction_outlined);
}
