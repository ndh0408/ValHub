import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'adaptive.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Search, filter-chip and sort building blocks shared by every list screen
/// (collection browser, wishlist catalog, weapon skins, expressions, match
/// history). Pair them with `UiMemory` to remember the choices per screen.

/// Pill-shaped search field ("Tìm kiếm…") with a leading search icon and a
/// clear button while text is present. Put it inside a [GlassBar] when it
/// is pinned over scrolling content.
class GlassSearchField extends StatefulWidget {
  const GlassSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<GlassSearchField> createState() => _GlassSearchFieldState();
}

class _GlassSearchFieldState extends State<GlassSearchField> {
  TextEditingController? _own;
  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(ValRadius.pill);
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c),
    );
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText ?? context.l10n.commonSearch,
          filled: true,
          fillColor: scheme.surfaceContainer.withValues(
            alpha: dark ? 0.78 : 0.95,
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.l10n.commonClearSearch,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _clear,
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: border(valColorsOf(context).hairline),
          enabledBorder: border(valColorsOf(context).hairline),
          focusedBorder: border(scheme.primary),
        ),
      ),
    );
  }
}

/// Valorant-styled [FilterChip]: pill shape, accent tint when selected,
/// optional colored leading dot (rarity color) or icon. Keeps the Material
/// 48 dp tap target.
class ValFilterChip extends StatelessWidget {
  const ValFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.dotColor,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  /// Small colored dot before the label (content-tier color).
  final Color? dotColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;
    final dot = dotColor;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (v) {
        Haptics.selection();
        onSelected(v);
      },
      avatar: dot != null
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            )
          : icon != null
          ? Icon(icon, size: 16, color: selected ? accent : null)
          : null,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? legibleAccent(context, accent) : scheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: scheme.surfaceContainer,
      selectedColor: accent.withValues(alpha: 0.14),
      side: BorderSide(
        color: selected
            ? accent.withValues(alpha: 0.7)
            : valColorsOf(context).hairline,
      ),
      shape: const StadiumBorder(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
  }
}

/// One sort option of [SortButton].
typedef SortOption<T> = ({T value, String label});

/// Pill "⇅ Độ hiếm" button: opens an adaptive action sheet with the
/// [options] (current one marked ✓) and reports the pick.
class SortButton<T> extends StatelessWidget {
  const SortButton({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<SortOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  String _currentLabel(AppLocalizations l10n) {
    for (final o in options) {
      if (o.value == selected) return o.label;
    }
    return l10n.commonSort;
  }

  Future<void> _open(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showActionSheet<T>(
      context,
      title: l10n.commonSort,
      actions: [
        for (final o in options)
          SheetAction(
            value: o.value,
            label: o.value == selected && isCupertino(context)
                ? '✓ ${o.label}'
                : o.label,
            icon: o.value == selected ? Icons.check : Icons.sort,
          ),
      ],
    );
    if (picked != null && picked != selected) {
      Haptics.selection();
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.commonSortBy(_currentLabel(context.l10n)),
      excludeSemantics: true,
      child: ActionChip(
        avatar: const Icon(Icons.swap_vert, size: 18),
        label: Text(_currentLabel(context.l10n)),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: theme.colorScheme.surfaceContainer,
        side: BorderSide(color: valColorsOf(context).hairline),
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
        onPressed: () => unawaited(_open(context)),
      ),
    );
  }
}

/// Horizontally scrolling row of filter controls (sort button, chips, a
/// "Bỏ lọc" chip when [onClear] is given), 16 dp gutters.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.children,
    this.onClear,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;

  /// Shows a trailing "Bỏ lọc" action when non-null.
  final VoidCallback? onClear;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...children,
      if (onClear != null)
        ActionChip(
          avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
          label: Text(context.l10n.commonClearFilters),
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            Haptics.selection();
            onClear!();
          },
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            items[i],
          ],
        ],
      ),
    );
  }
}
