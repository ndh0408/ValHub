import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

enum WindowSizeClass { compact, medium, expanded }

/// Measures the usable pane, so a fold or a landscape cutout never becomes
/// part of the layout width. No device-model or orientation assumptions.
class WindowInfo {
  const WindowInfo(this.pane, this.textScale);
  final Rect pane;
  final double textScale;
  WindowSizeClass get sizeClass => pane.width < 600
      ? WindowSizeClass.compact
      : pane.width < 840
      ? WindowSizeClass.medium
      : WindowSizeClass.expanded;
  bool get short => pane.height < 480;
  bool get useRail => pane.width >= 600;
  double get contentWidth => math.min(pane.width, 960);
  double get toolbarHeight => short ? 56 : math.max(72, 40 * textScale);

  factory WindowInfo.of(BuildContext context) {
    final media = MediaQuery.of(context);
    var pane = Rect.fromLTWH(0, 0, media.size.width, media.size.height);
    for (final feature in media.displayFeatures) {
      final hinge = feature.bounds;
      if (hinge.width == 0 && hinge.height == 0) continue;
      if (!hinge.overlaps(pane)) continue;
      final vertical = hinge.height >= pane.height * 0.8;
      final horizontal = hinge.width >= pane.width * 0.8;
      if (vertical) {
        final a = Rect.fromLTRB(pane.left, pane.top, hinge.left, pane.bottom);
        final b = Rect.fromLTRB(hinge.right, pane.top, pane.right, pane.bottom);
        pane = a.width >= b.width ? a : b;
      } else if (horizontal) {
        final a = Rect.fromLTRB(pane.left, pane.top, pane.right, hinge.top);
        final b = Rect.fromLTRB(
          pane.left,
          hinge.bottom,
          pane.right,
          pane.bottom,
        );
        pane = a.height >= b.height ? a : b;
      }
    }
    return WindowInfo(pane, media.textScaler.scale(16) / 16);
  }
}

/// A stable parent for branch navigators through bar/rail and fold changes.
class UsableWindow extends StatelessWidget {
  const UsableWindow({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final pane = WindowInfo.of(context).pane;
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        pane.left,
        pane.top,
        math.max(0, media.size.width - pane.right),
        math.max(0, media.size.height - pane.bottom),
      ),
      child: MediaQuery(
        data: media.copyWith(size: pane.size, displayFeatures: const []),
        child: child,
      ),
    );
  }
}
