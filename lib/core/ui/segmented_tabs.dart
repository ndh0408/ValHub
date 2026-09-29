import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// One segment of [SegmentedTabs].
class SegmentedTab<T> {
  const SegmentedTab({
    required this.value,
    required this.label,
    this.showDot = false,
  });

  final T value;
  final String label;

  /// Red dot (e.g. unseen Night Market).
  final bool showDot;
}

/// Horizontally scrollable, Valorant-style segmented control
/// ("Hằng ngày · Chợ Đêm · Phụ kiện · Bundle").
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final List<SegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(ValRadius.small),
        ),
        child: Row(
          children: [
            for (final tab in tabs)
              Padding(
                padding: EdgeInsets.only(right: tab == tabs.last ? 0 : 4),
                child: _Segment(
                  label: tab.label,
                  selected: tab.value == selected,
                  showDot: tab.showDot,
                  onTap: () => onChanged(tab.value),
                  scheme: scheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.showDot,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? ValColors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : scheme.onSurface,
                ),
              ),
              if (showDot) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : ValColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
