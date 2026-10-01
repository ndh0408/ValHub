import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/segmented_tabs.dart';

const _tabs = [
  SegmentedTab(value: 0, label: 'Việt Nam'),
  SegmentedTab(value: 1, label: 'Khu vực'),
  SegmentedTab(value: 2, label: 'Quốc tế'),
];

void main() {
  testWidgets('primary tabs expose a usable accessibility tap action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: SegmentedTabs<int>(
            tabs: _tabs,
            selected: 0,
            expand: true,
            onChanged: (v) => picked = v,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.bySemanticsLabel('Khu vực'));
    expect(
      node,
      matchesSemantics(
        label: 'Khu vực',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('Khu vực'));
    expect(picked, 1);
    semantics.dispose();
  });

  for (final direction in TextDirection.values) {
    testWidgets(
      'secondary filters wrap readable labels at 320 dp / 200% ($direction)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        int? picked;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildDarkTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: Directionality(textDirection: direction, child: child!),
            ),
            home: Scaffold(
              body: SegmentedTabs<int>(
                tabs: _tabs,
                selected: 0,
                secondary: true,
                onChanged: (v) => picked = v,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final tab in _tabs) {
          final button = find.widgetWithText(TextButton, tab.label);
          final rect = tester.getRect(button);
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(320));
          expect(rect.height, greaterThanOrEqualTo(48));
          await tester.tap(button);
        }
        expect(picked, 2);
      },
    );
  }
}
