import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/segmented_tabs.dart';

/// Valorant-style segmented control whose segments share the width equally,
/// so "Hằng ngày · Chợ Đêm · Phụ kiện · Bundle" all stay visible on a
/// 320–360 dp phone (labels scale down instead of scrolling off screen).
class StoreSegmentBar<T> extends StatelessWidget {
  const StoreSegmentBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _Segment(
                label: tabs[i].label,
                selected: tabs[i].value == selected,
                showDot: tabs[i].showDot,
                onTap: () => onChanged(tabs[i].value),
              ),
            ),
          ],
        ],
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
  });

  final String label;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primary : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(2),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: fg),
                      ),
                      if (showDot) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: selected ? scheme.onPrimary : scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
