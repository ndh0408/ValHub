import 'package:material_ui/material_ui.dart';

/// Section title with an optional trailing widget / "›" tap target.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 8),
    this.uppercase = false,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  /// Settings-style "TÀI KHOẢN (3/10)" headers.
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = uppercase
        ? theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.titleMedium;
    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          ?trailing,
          if (onTap != null && trailing == null)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}
