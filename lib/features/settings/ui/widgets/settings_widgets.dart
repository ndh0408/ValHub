import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
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
              // White cards need an edge on the pale light background.
              side: Theme.of(context).brightness == Brightness.light
                  ? BorderSide(color: hairline)
                  : BorderSide.none,
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

/// Leading icon of a settings row: a plain red outline icon (or [color])
/// in a 32 dp slot, matching core `GroupedRow(icon:)`.
class SettingsIcon extends StatelessWidget {
  const SettingsIcon(this.icon, {super.key, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return SizedBox.square(
      dimension: 32,
      child: Icon(
        icon,
        size: 22,
        color: c == null
            ? Theme.of(context).colorScheme.primary
            : legibleAccent(context, c, min: 3),
      ),
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

/// A switch row with an icon, a title and an optional subtitle. Adaptive:
/// an iOS switch (red when on) on iOS, the Material switch elsewhere, with a
/// light haptic on every flip.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.showIcon = false,
  });

  /// Leading icon, drawn only when [showIcon] (preference rows are plain
  /// title + switch by default).
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changed = onChanged;
    return SwitchListTile.adaptive(
      secondary: showIcon ? SettingsIcon(icon) : null,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      value: value,
      activeTrackColor: theme.colorScheme.primary,
      onChanged: changed == null
          ? null
          : (v) {
              Haptics.light();
              changed(v);
            },
    );
  }
}

/// Simple choice picker (theme, item language, platform). Returns the
/// picked value, or `null` when dismissed.
///
/// iOS: a native action sheet (current option marked ✓, [hint] as the
/// message). Elsewhere: a bottom sheet of rows with a check on the current
/// option.
Future<T?> showSettingsChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<(T, String)> options,
  required T selected,
  String? hint,
}) async {
  if (isCupertino(context)) {
    final picked = await showActionSheet<T>(
      context,
      title: title,
      message: hint,
      actions: [
        for (final (value, label) in options)
          SheetAction(
            value: value,
            label: value == selected ? '✓ $label' : label,
          ),
      ],
    );
    if (picked != null && picked != selected) Haptics.selection();
    return picked;
  }
  final picked = await showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) => SettingsChoiceList<T>(
      title: title,
      hint: hint,
      options: [
        for (final (value, label) in options)
          (value: value, label: label, leading: null),
      ],
      selected: selected,
      onPicked: (v) => Navigator.of(sheetContext).pop(v),
    ),
  );
  if (picked != null && picked != selected) Haptics.selection();
  return picked;
}

/// One option of [SettingsChoiceList].
typedef SettingsChoice<T> = ({T value, String label, Widget? leading});

/// Body of the Material choice sheet: title, optional hint, then one row
/// per option with a red check on the current one (48 dp+ rows).
class SettingsChoiceList<T> extends StatelessWidget {
  const SettingsChoiceList({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onPicked,
    this.hint,
    this.header,
  });

  final String title;
  final String? hint;
  final List<SettingsChoice<T>> options;
  final T selected;
  final ValueChanged<T> onPicked;

  /// Extra widget between the hint and the rows (e.g. theme previews).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
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
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ?header,
          const SizedBox(height: 4),
          for (final o in options)
            Semantics(
              selected: o.value == selected,
              child: ListTile(
                minTileHeight: 52,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: o.leading,
                title: Text(
                  o.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: o.value == selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                trailing: o.value == selected
                    ? Icon(Icons.check_rounded, color: scheme.primary)
                    : null,
                onTap: () => onPicked(o.value),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Hủy" / confirm dialog (adaptive: Cupertino on iOS). Resolves to
/// `false` on dismiss.
Future<bool> confirmSettingsAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) => showConfirmDialog(
  context,
  title: title,
  message: message,
  confirmLabel: confirmLabel,
  destructive: destructive,
);

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
