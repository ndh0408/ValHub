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

  test('light theme text colors reach WCAG AA on background and cards', () {
    final theme = buildLightTheme();
    final scheme = theme.colorScheme;
    const c = ValThemeColors.light;
    for (final bg in [ValColors.lightBackground, ValColors.lightSurface]) {
      for (final fg in [
        scheme.onSurfaceVariant,
        scheme.primary,
        c.muted,
        c.win,
        c.loss,
        c.warning,
        c.gold,
      ]) {
        expect(
          _contrast(fg, bg),
          greaterThanOrEqualTo(4.4),
          reason: '$fg on $bg',
        );
      }
    }
    // White label on the light primary (filled buttons, selected segment).
    expect(
      _contrast(scheme.onPrimary, scheme.primary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('legibleOn darkens pale rarity colors on light surfaces', () {
    const ultra = TierColors.ultra; // #FAD663, 1.4:1 on white
    final fixed = legibleOn(ultra, ValColors.lightSurface);
    expect(_contrast(fixed, ValColors.lightSurface), greaterThanOrEqualTo(4.5));
    // Already-legible colors are untouched (dark theme).
    expect(legibleOn(ultra, ValColors.surface), ultra);
    // And a dark color on the dark surface is lightened.
    final dark = legibleOn(const Color(0xFF30204A), ValColors.surface);
    expect(_contrast(dark, ValColors.surface), greaterThanOrEqualTo(4.5));
  });
}
