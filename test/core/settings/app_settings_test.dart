import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/theme_mode_provider.dart';

import '../../helpers/test_prefs.dart';

void main() {
  test('defaults: dark theme, vi item names', () {
    const s = AppSettings();
    expect(s.themeMode, ThemeMode.dark);
    expect(s.itemLanguage.apiCode, 'vi-VN');
    expect(AppSettings.fromJson('junk'), s);
  });

  test('persisted through prefs and exposed as themeModeProvider', () async {
    final prefs = await createTestPrefs();
    final c = ProviderContainer.test(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    await c.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.light);
    await c.read(appSettingsProvider.notifier).setItemLanguage(ItemLanguage.en);
    expect(c.read(themeModeProvider), ThemeMode.light);
    final reread = readAppSettings(prefs);
    expect(reread.themeMode, ThemeMode.light);
    expect(reread.itemLanguage.apiCode, 'en-US');
  });
}
