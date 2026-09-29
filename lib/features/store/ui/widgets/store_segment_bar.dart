import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/segmented_tabs.dart';

/// The store's "glass capsule" segmented control: equal-width segments
/// ("Hằng ngày · Chợ Đêm · Phụ kiện · Bundle") with a red highlight that
/// slides between them, so every segment stays visible on a 320–360 dp
/// phone (labels scale down instead of scrolling off screen).
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
  Widget build(BuildContext context) => SegmentedTabs<T>(
    tabs: tabs,
    selected: selected,
    onChanged: onChanged,
    expand: true,
  );
}
