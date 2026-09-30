import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/floating_nav_bar.dart';

const _destinations = [
  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Một'),
  NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Hai'),
  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Ba'),
];

Future<void> _pump(
  WidgetTester tester, {
  required int selected,
  int? emphasized,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? buildDarkTheme(),
      home: Scaffold(
        bottomNavigationBar: FloatingNavBar(
          destinations: _destinations,
          selectedIndex: selected,
          emphasizedIndex: emphasized,
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The 32 dp circle behind the emphasized icon, if any.
Finder _circles() => find.byWidgetPredicate(
  (w) =>
      w is AnimatedContainer &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).shape == BoxShape.circle,
);

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('no emphasis by default', (tester) async {
    await _pump(tester, selected: 0);
    expect(_circles(), findsNothing);
  });

  testWidgets('the emphasized icon sits in a 32 dp circle', (tester) async {
    await _pump(tester, selected: 0, emphasized: 1);
    expect(_circles(), findsOneWidget);
    expect(tester.getSize(_circles()), const Size(32, 32));
    // Still exposed as an ordinary destination.
    expect(find.bySemanticsLabel('Hai'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unselected: tinted circle; selected: solid primary', (
    tester,
  ) async {
    await _pump(tester, selected: 0, emphasized: 1);
    final scheme = Theme.of(tester.element(_circles())).colorScheme;
    var color =
        ((tester.widget<AnimatedContainer>(_circles()).decoration!)
                as BoxDecoration)
            .color!;
    expect(color.a, closeTo(0.16, 0.01));
    expect(color.withValues(alpha: 1), scheme.primary);

    await _pump(tester, selected: 1, emphasized: 1);
    color =
        ((tester.widget<AnimatedContainer>(_circles()).decoration!)
                as BoxDecoration)
            .color!;
    expect(color, scheme.primary);
  });

  for (final (name, theme) in [
    ('dark', buildDarkTheme()),
    ('light', buildLightTheme()),
  ]) {
    test('the selected icon on the solid circle is a 3:1 graphic ($name)', () {
      final scheme = theme.colorScheme;
      expect(
        _contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(3),
      );
    });
  }

  testWidgets('tapping selects the destination, emphasized or not', (
    tester,
  ) async {
    var picked = -1;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          bottomNavigationBar: FloatingNavBar(
            destinations: _destinations,
            selectedIndex: 0,
            emphasizedIndex: 1,
            onDestinationSelected: (i) => picked = i,
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Hai'));
    expect(picked, 1);
    await tester.tap(find.bySemanticsLabel('Ba'));
    expect(picked, 2);
  });
}
