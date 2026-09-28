import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../settings/app_settings.dart';

/// Current [ThemeMode] ("Chủ đề: Tối / Sáng / Theo hệ thống"), persisted in
/// prefs through [appSettingsProvider]. Change it with
/// `ref.read(appSettingsProvider.notifier).setThemeMode(mode)`.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(appSettingsProvider.select((s) => s.themeMode)),
);
