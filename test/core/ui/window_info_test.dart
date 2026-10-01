import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/ui/window_info.dart';

void main() {
  test('breakpoints are based on usable width and content is capped', () {
    for (final (width, expected) in [
      (599.0, WindowSizeClass.compact),
      (600.0, WindowSizeClass.medium),
      (839.0, WindowSizeClass.medium),
      (840.0, WindowSizeClass.expanded),
    ]) {
      expect(
        WindowInfo(Rect.fromLTWH(0, 0, width, 800), 1).sizeClass,
        expected,
      );
    }
    expect(
      WindowInfo(const Rect.fromLTWH(0, 0, 1400, 900), 2).contentWidth,
      960,
    );
    expect(WindowInfo(const Rect.fromLTWH(0, 0, 800, 360), 2).short, true);
  });
  testWidgets(
    'fold hinge chooses an unobstructed pane and preserves child identity',
    (tester) async {
      late WindowInfo info;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1200, 900),
            displayFeatures: [
              DisplayFeature(
                bounds: Rect.fromLTWH(500, 0, 20, 900),
                type: DisplayFeatureType.hinge,
                state: DisplayFeatureState.postureFlat,
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: UsableWindow(
              child: Builder(
                builder: (context) {
                  info = WindowInfo.of(context);
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );
      expect(info.pane.size, const Size(680, 900));
      expect(info.sizeClass, WindowSizeClass.medium);
      expect(tester.takeException(), isNull);
    },
  );
}
