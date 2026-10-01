import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/account_labels.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/sections/preferences_sections.dart';
import 'package:valvn/features/settings/ui/settings_gear_button.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

import '../helpers/l10n.dart';

class _Resources extends AppLocalizationsVi {
  _Resources(this.marker);
  final String marker;
  @override
  String get commonTabSettings => 'gear-$marker';
  @override
  String get settingsThemeDark => 'theme-$marker';
  @override
  String get settingsItemLanguageEn => 'items-$marker';
  @override
  String get accountRegionAp => 'region-$marker';
  @override
  String get settingsPlatformMobile => 'platform-$marker';
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate(this.marker);
  final String marker;
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'vi';
  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_Resources(marker));
  @override
  bool shouldReload(_Delegate old) => marker != old.marker;
}

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SettingsGearButton(),
      Text(themeModeLabel(ThemeMode.dark, context.l10n)),
      Text(itemLanguageLabel(ItemLanguage.en, context.l10n)),
      Text(context.l10n.riotRegionName('ap')),
      Text(context.l10n.statusPlatformName('mobile')),
    ],
  );
}

void main() {
  test('metadata renderer preserves Vietnamese region/platform parity', () {
    for (final region in [
      'ap',
      'AP',
      'eu',
      'na',
      'br',
      'kr',
      'latam',
      '',
      'new',
    ]) {
      expect(tl.riotRegionName(region), AccountStrings.regionName(region));
    }
    for (final platform in [
      'windows',
      'pc',
      'macos',
      'ps4',
      'ps5',
      'playstation',
      'xbone',
      'xbox',
      'xboxseries',
      'xbox_series',
      'android',
      'ios',
      'mobile',
      'new',
    ]) {
      expect(
        tl.statusPlatformName(platform),
        SettingsStrings.platformName(platform),
      );
    }
  });

  testWidgets('resource replacement updates an existing constant subtree', (
    tester,
  ) async {
    Widget app(String marker) => MaterialApp(
      theme: buildDarkTheme(),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: [
        _Delegate(marker),
        ...appLocalizationsDelegates.skip(1),
      ],
      home: const Scaffold(body: _Probe()),
    );
    await tester.pumpWidget(app('first'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('gear-first'), findsOneWidget);
    expect(find.text('theme-first'), findsOneWidget);
    final before = tester.element(find.byType(_Probe));
    await tester.pumpWidget(app('second'));
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(_Probe)), same(before));
    expect(find.byTooltip('gear-first'), findsNothing);
    expect(find.byTooltip('gear-second'), findsOneWidget);
    for (final kind in ['theme', 'items', 'region', 'platform']) {
      expect(find.text('$kind-first'), findsNothing);
      expect(find.text('$kind-second'), findsOneWidget);
    }
  });
}
