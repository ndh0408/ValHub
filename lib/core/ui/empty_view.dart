import 'package:material_ui/material_ui.dart';

import '../l10n/common_strings.dart';

/// Centered empty state: the [icon] in a soft tinted disc, an optional bold
/// [title], the muted [message] and an optional [action] button
/// ("Không có dữ liệu" by default).
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message = CommonStrings.noData,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.padding = const EdgeInsets.all(32),
    this.title,
    this.color,
  });

  final String message;
  final IconData icon;

  /// Optional button below the message.
  final Widget? action;
  final EdgeInsets padding;

  /// Bold headline above [message] ("Chưa có skin nào").
  final String? title;

  /// Tint of the icon disc (defaults to the muted text color).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StateIcon(icon: icon, color: tint),
              const SizedBox(height: 16),
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// The icon of an empty / error state: [icon] centered in a disc tinted
/// with [color] (12%) and a faint ring (6%).
class StateIcon extends StatelessWidget {
  const StateIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 72,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.06), width: 6),
        ),
        child: Icon(icon, size: size * 0.42, color: color),
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
