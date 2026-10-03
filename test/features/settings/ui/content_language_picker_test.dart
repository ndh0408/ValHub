import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/ui/sections/preferences_sections.dart';
import 'package:valvn/features/settings/ui/widgets/settings_widgets.dart';

import '../../../helpers/l10n.dart';
import '../../../helpers/test_prefs.dart';

void main() {
  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'all content options selectable at $width dp / 200% / $direction',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final prefs = await createTestPrefs();
          final container = ProviderContainer(
            overrides: [prefsProvider.overrideWithValue(prefs)],
          );
          addTearDown(container.dispose);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: buildDarkTheme(),
                locale: testUiLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: appLocalizationsDelegates,
                builder: (context, child) => Directionality(
                  textDirection: direction,
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(2)),
                    child: child!,
                  ),
                ),
                home: const Scaffold(
                  body: SingleChildScrollView(
                    child: SettingsAppearanceSection(),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(tl.settingsItemLanguageLabel));
          await tester.tap(find.text(tl.settingsItemLanguageLabel));
          await tester.pumpAndSettle();
          final choices = tester.widget<SettingsChoiceList<String>>(
            find.byType(SettingsChoiceList<String>),
          );
          expect(choices.options, hasLength(AppLocale.values.length + 1));
          expect(choices.options.map((o) => o.value).toSet(), {
            'app',
            ...AppLocale.values.map((l) => l.tag),
          });
          await tester.ensureVisible(find.text(AppLocale.ja.nativeName));
          await tester.tap(find.text(AppLocale.ja.nativeName));
          await tester.pumpAndSettle();
          expect(container.read(appSettingsProvider).contentLocale, 'ja-JP');
          expect(readAppSettings(prefs).contentLocale, 'ja-JP');
          expect(find.text(AppLocale.ja.nativeName), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
