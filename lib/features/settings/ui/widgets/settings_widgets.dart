import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/section_header.dart';

/// One settings section: an uppercase header ("TÙY CHỌN") above a rounded
/// card holding the rows, separated by hairlines. [footer] is rendered
/// under the card (disclaimers, hints).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hairline = valColorsOf(context).hairline;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, thickness: 1, color: hairline));
      }
      rows.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title, uppercase: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: scheme.surfaceContainer,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ValRadius.card),
            ),
            // Tighter than the default so long Vietnamese labels keep room
            // next to switches on 360dp phones.
            child: ListTileTheme.merge(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              horizontalTitleGap: 12,
              minLeadingWidth: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: footer,
          ),
      ],
    );
  }
}

/// Leading icon of a settings row, in a small tinted square.
class SettingsIcon extends StatelessWidget {
  const SettingsIcon(this.icon, {super.key, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = color ?? scheme.onSurface;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 18, color: tint),
    );
  }
}

/// Trailing "Tối ›" value of a picker row. Shrinks (ellipsis) instead of
/// overflowing on narrow phones.
class SettingsValue extends StatelessWidget {
  const SettingsValue(this.text, {super.key, this.icon = Icons.chevron_right});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// Trailing "›" of a navigation row.
class SettingsChevron extends StatelessWidget {
  const SettingsChevron({super.key, this.icon = Icons.chevron_right});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: 20,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// A switch row with an icon, a title and an optional subtitle.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: SettingsIcon(icon),
    title: Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(fontWeight: FontWeight.w600),
    ),
    subtitle: subtitle == null ? null : Text(subtitle!),
    value: value,
    onChanged: onChanged,
  );
}

/// Simple modal choice sheet (theme, item language, platform). Returns the
/// picked value, or `null` when dismissed.
Future<T?> showSettingsChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<(T, String)> options,
  required T selected,
  String? hint,
}) => showModalBottomSheet<T>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (sheetContext) {
    final theme = Theme.of(sheetContext);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: RadioGroup<T>(
        groupValue: selected,
        onChanged: (v) {
          if (v != null) Navigator.of(sheetContext).pop(v);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text(title, style: theme.textTheme.titleLarge),
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  hint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final (value, label) in options)
              RadioListTile<T>(
                value: value,
                title: Text(label),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
          ],
        ),
      ),
    );
  },
);

/// "Hủy" / confirm dialog. Resolves to `false` on dismiss.
Future<bool> confirmSettingsAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(CommonStrings.cancel),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

/// Scrollable text sheet for the privacy policy / terms.
Future<void> showSettingsTextSheet(
  BuildContext context, {
  required String title,
  required String body,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (sheetContext) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    builder: (innerContext, controller) {
      final theme = Theme.of(innerContext);
      return ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      );
    },
  ),
);
