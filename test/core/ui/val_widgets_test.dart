import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/val_widgets.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? buildDarkTheme(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('SectionLabel renders uppercase', (tester) async {
    await tester.pumpWidget(_app(const SectionLabel('Trang bị')));
    expect(find.text('TRANG BỊ'), findsOneWidget);
  });

  testWidgets('GroupedSection separates rows with hairlines', (tester) async {
    await tester.pumpWidget(
      _app(
        GroupedSection(
          children: [
            GroupedRow(title: 'A', value: 'PC', onTap: () {}),
            const GroupedRow(title: 'B'),
            const GroupedRow(title: 'C', accentStrip: ValColors.red),
          ],
        ),
      ),
    );
    expect(find.byType(Divider), findsNWidgets(2));
    expect(find.text('PC'), findsOneWidget);
    // Only the tappable row shows a chevron.
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('ValProgressBar clamps and exposes a percentage', (tester) async {
    await tester.pumpWidget(
      _app(const SizedBox(width: 200, child: ValProgressBar(value: 1.7))),
    );
    final box = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(box.widthFactor, 1);
    await tester.pumpWidget(
      _app(
        const SizedBox(width: 200, child: ValProgressBar(value: double.nan)),
      ),
    );
    // The fill animates to the new value.
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .widthFactor,
      0,
    );
  });

  testWidgets('pills, badges and diamonds render in both themes', (
    tester,
  ) async {
    for (final theme in [buildDarkTheme(), buildLightTheme()]) {
      await tester.pumpWidget(
        _app(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusPill(label: 'Đang diễn ra', color: ValColors.green),
              ValBadge('BẠN', color: ValColors.red),
              ValBadge('Đăng nhập lại', color: ValColors.amber, soft: true),
              CurrencyPill(
                dotColor: CurrencyColors.vp,
                amount: '2.440',
                code: 'VP',
              ),
              DiamondPip(),
              DiamondPip(filled: false),
              ValCard(child: Text('Thẻ')),
            ],
          ),
          theme: theme,
        ),
      );
      expect(find.text('Đang diễn ra'), findsOneWidget);
      expect(find.text('2.440'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
