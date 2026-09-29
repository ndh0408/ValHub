import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('filled badge text is readable on teal / amber / red', () {
    for (final bg in [ValColors.teal, ValColors.amber]) {
      expect(
        _contrast(readableOn(bg), bg),
        greaterThanOrEqualTo(4.5),
        reason: '$bg',
      );
    }
    // Brand red keeps white text (bold label, ≥ 3:1).
    expect(readableOn(ValColors.red), Colors.white);
  });

  test(
    'light theme status / MVP colors are readable on the light background',
    () {
      const bg = ValColors.lightBackground;
      const c = ValThemeColors.light;
      for (final fg in [c.away, c.gold, c.win]) {
        expect(_contrast(fg, bg), greaterThanOrEqualTo(3.0), reason: '$fg');
      }
    },
  );
}
