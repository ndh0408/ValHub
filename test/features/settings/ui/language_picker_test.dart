import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/locale_boot.dart';
import 'package:valvn/core/l10n/locale_controller.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/settings/ui/widgets/language_picker.dart';

import '../../../helpers/test_prefs.dart';

void main() {
  Future<Prefs> pumpPicker(
    WidgetTester tester, {
    double? width,
    bool fail = false,
  }) async {
    final prefs = await createTestPrefs();
    if (width != null) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          if (fail)
            localeControllerProvider.overrideWith(_FailingController.new),
        ],
        child: MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(width == null ? 1 : 2)),
            child: child!,
          ),
          home: const Scaffold(body: AppLanguageButton()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
  }

  testWidgets(
    'picker saves fixed and follow-device choices, offers only shipped locales',
    (tester) async {
      final prefs = await pumpPicker(tester);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text('Theo thiết bị'), findsOneWidget);
      expect(find.text(AppLocale.vi.nativeName), findsOneWidget);
      expect(find.text(AppLocale.en.nativeName), findsNothing);
      await tester.tap(find.text(AppLocale.vi.nativeName));
      await tester.pumpAndSettle();
      expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theo thiết bị'));
      await tester.pumpAndSettle();
      expect(prefs.getString(PrefKeys.appLocale), 'system');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('canceling the picker leaves the preference unchanged', (
    tester,
  ) async {
    final prefs = await pumpPicker(tester);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text(AppLocale.vi.nativeName))).pop();
    await tester.pumpAndSettle();
    expect(prefs.getString(PrefKeys.appLocale), isNull);
  });

  testWidgets('failed save shows a message and keeps the preference', (
    tester,
  ) async {
    final prefs = await pumpPicker(tester, fail: true);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocale.vi.nativeName));
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa lưu được ngôn ngữ. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(prefs.getString(PrefKeys.appLocale), isNull);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    testWidgets('language picker fits ${width.toInt()}dp at text 200%', (
      tester,
    ) async {
      await pumpPicker(tester, width: width);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text(AppLocale.vi.nativeName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _FailingController extends LocaleController {
  @override
  Future<void> set(LocaleChoice choice) async =>
      throw StateError('synthetic save failure');
}
