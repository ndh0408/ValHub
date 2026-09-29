import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/theme/tier_colors.dart';

void main() {
  test('RRGGBBAA → ARGB', () {
    expect(parseRgba('ffffaaff'), const Color(0xFFFFFFAA));
    expect(parseRgba('5a9fe233'), const Color(0x335A9FE2));
    expect(parseRgba('#ff4655'), const Color(0xFFFF4655));
    expect(opaqueRgba('d1548d33'), const Color(0xFFD1548D));
  });

  test('invalid input falls back', () {
    expect(parseRgba(null), ValColors.muted);
    expect(parseRgba('zzzzzz'), ValColors.muted);
    expect(parseRgba('123'), ValColors.muted);
    expect(parseRgba('xx', fallback: ValColors.red), ValColors.red);
  });

  test('themes build with the Valorant accent', () {
    expect(buildDarkTheme().colorScheme.primary, ValColors.red);
    expect(buildDarkTheme().scaffoldBackgroundColor, ValColors.navy);
    expect(buildLightTheme().brightness, Brightness.light);
    expect(buildDarkTheme().extension<ValThemeColors>(), isNotNull);
  });

  test('dark theme follows the true-black tokens', () {
    final t = buildDarkTheme();
    expect(t.scaffoldBackgroundColor, const Color(0xFF000000));
    expect(t.colorScheme.surfaceContainer, const Color(0xFF141416));
    expect(t.colorScheme.surfaceContainerHigh, const Color(0xFF1F1F23));
    expect(t.colorScheme.onSurface, const Color(0xFFF2F1EE));
    expect(t.colorScheme.onSurfaceVariant, const Color(0xFF8E8E93));
    expect(t.navigationBarTheme.backgroundColor, const Color(0xFF1C1C1F));
    final extras = t.extension<ValThemeColors>()!;
    expect(extras.win, const Color(0xFF3DDC97));
    expect(extras.track, const Color(0xFF2C2C31));
    expect(
      t.switchTheme.trackColor?.resolve({WidgetState.selected}),
      ValColors.red,
    );
  });
}
