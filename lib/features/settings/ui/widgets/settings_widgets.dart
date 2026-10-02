import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/sub_page.dart';

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
///
/// With [onInfo] an (i) button sits before the switch (e.g. "Cách tính giá
/// VND"); tapping the row still flips the switch.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.showIcon = false,
    this.onInfo,
    this.infoTooltip,
  });

  /// Leading icon, drawn only when [showIcon] (preference rows are plain
  /// title + switch by default).
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showIcon;

  /// Opens an explanation of the option.
  final VoidCallback? onInfo;
  final String? infoTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changed = onChanged;
    final titleText = Text(
      title,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    );
    final subtitleText = subtitle == null
        ? null
        : Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
    void flip(bool v) {
      Haptics.light();
      changed!(v);
    }

    final info = onInfo;
    if (info == null) {
      return SwitchListTile.adaptive(
        secondary: showIcon ? SettingsIcon(icon) : null,
        title: titleText,
        subtitle: subtitleText,
        value: value,
        activeTrackColor: theme.colorScheme.primary,
        onChanged: changed == null ? null : flip,
      );
    }
    return ListTile(
      leading: showIcon ? SettingsIcon(icon) : null,
      title: titleText,
      subtitle: subtitleText,
      enabled: changed != null,
      onTap: changed == null ? null : () => flip(!value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: infoTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: info,
          ),
          Semantics(
            label: title,
            child: Switch.adaptive(
              value: value,
              activeTrackColor: theme.colorScheme.primary,
              onChanged: changed == null ? null : flip,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple choice picker (theme, item language, platform). Returns the
/// picked value, or `null` when dismissed.
///
/// iOS: a native action sheet (current option marked with a check, [hint]
/// as the message). Elsewhere: a ValHub sheet ([showValSheet]: title, close
/// button) with the options on one grouped card and a red check on the
/// current one.
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
  final picked = await showValSheet<T>(
    context,
    title: title,
    builder: (sheetContext, _) => SettingsChoiceList<T>(
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

/// Body of the Material choice sheet (under its [SheetHeader]): optional
/// hint, an optional [header] (theme previews), then the options on one
/// grouped card with a red check on the current one (52 dp rows).
class SettingsChoiceList<T> extends StatelessWidget {
  const SettingsChoiceList({
    super.key,
    required this.options,
    required this.selected,
    required this.onPicked,
    this.hint,
    this.header,
  });

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
    final hairline = valColorsOf(context).hairline;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          if (header != null) ...[header!, const SizedBox(height: 12)],
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: hairline),
                  _ChoiceRow<T>(
                    option: options[i],
                    selected: options[i].value == selected,
                    onTap: () => onPicked(options[i].value),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SettingsChoice<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      child: ListTile(
        minTileHeight: 52,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: option.leading,
        title: Text(
          option.label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: ValMotion.fast,
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  key: const ValueKey('on'),
                  color: legibleAccent(context, scheme.primary, min: 3),
                )
              : const SizedBox(key: ValueKey('off'), width: 24),
        ),
        onTap: onTap,
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
  IconData? icon,
}) => showConfirmDialog(
  context,
  title: title,
  message: message,
  confirmLabel: confirmLabel,
  destructive: destructive,
  icon: icon,
);
