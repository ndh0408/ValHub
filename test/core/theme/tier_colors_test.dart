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

  test('dark theme follows the Figma tokens', () {
    final t = buildDarkTheme();
    expect(t.scaffoldBackgroundColor, const Color(0xFF0F1923));
    expect(t.colorScheme.surfaceContainer, const Color(0xFF1A2733));
    expect(t.colorScheme.surfaceContainerHigh, const Color(0xFF243442));
    expect(t.colorScheme.onSurface, const Color(0xFFECE8E1));
    expect(t.colorScheme.onSurfaceVariant, const Color(0xFF8B9BA8));
    expect(t.navigationBarTheme.backgroundColor, const Color(0xFF131E29));
    final extras = t.extension<ValThemeColors>()!;
    expect(extras.win, const Color(0xFF3DDC97));
    expect(extras.track, const Color(0xFF2E3F4E));
    expect(
      t.switchTheme.trackColor?.resolve({WidgetState.selected}),
      ValColors.red,
    );
  });
}
