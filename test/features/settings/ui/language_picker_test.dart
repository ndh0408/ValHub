import 'package:flutter/services.dart';
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

/// A choice in the open sheet: the button behind it shows the current
/// language's name too, and the sheet is the later (top-most) match.
Finder option(String text) => find.text(text).last;

/// Scrolls the 19-row sheet to [text] and picks it.
Future<void> tapOption(WidgetTester tester, String text) async {
  await tester.ensureVisible(option(text));
  await tester.pumpAndSettle();
  await tester.tap(option(text));
}

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
    'picker saves fixed and follow-device choices, offers all 18 languages',
    (tester) async {
      final prefs = await pumpPicker(tester);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text('Theo thiết bị'), findsOneWidget);
      // The button and the sheet's option.
      expect(find.text(AppLocale.vi.nativeName), findsNWidgets(2));
      for (final locale in AppLocale.values) {
        if (locale == AppLocale.vi) continue;
        expect(
          find.text(locale.nativeName),
          findsOneWidget,
          reason: locale.tag,
        );
      }
      await tapOption(tester, AppLocale.vi.nativeName);
      await tester.pumpAndSettle();
      expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tapOption(tester, 'Theo thiết bị');
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
    Navigator.of(tester.element(option(AppLocale.vi.nativeName))).pop();
    await tester.pumpAndSettle();
    expect(prefs.getString(PrefKeys.appLocale), isNull);
  });

  testWidgets('failed save shows a message and keeps the preference', (
    tester,
  ) async {
    final prefs = await pumpPicker(tester, fail: true);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    await tapOption(tester, AppLocale.vi.nativeName);
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa lưu được ngôn ngữ. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(prefs.getString(PrefKeys.appLocale), isNull);
    expect(tester.takeException(), isNull);
  });

  List<Map<Object?, Object?>> spyAnnouncements(
    WidgetTester tester, {
    bool reject = false,
  }) {
    final sent = <Map<Object?, Object?>>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        final event = message as Map<Object?, Object?>;
        if (event['type'] == 'announce') {
          sent.add(event);
          if (reject) throw PlatformException(code: 'speech_unavailable');
        }
        return null;
      },
    );
    addTearDown(
      () => messenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        null,
      ),
    );
    return sent;
  }

  testWidgets(
    'saved choice announces effective language once; identical choice stays silent',
    (tester) async {
      final sent = spyAnnouncements(tester);
      final prefs = await pumpPicker(tester);
      Future<void> chooseVi() async {
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await tapOption(tester, AppLocale.vi.nativeName);
        await tester.pumpAndSettle();
      }

      await chooseVi();
      expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
      expect(sent, hasLength(1));
      final data = sent.single['data'] as Map<Object?, Object?>;
      expect(data['message'], 'Ngôn ngữ: Tiếng Việt.');
      expect(data['textDirection'], TextDirection.ltr.index);
      expect(data['viewId'], tester.view.viewId);
      await chooseVi();
      expect(sent, hasLength(1));
    },
  );
  testWidgets('cancel/failure never announce a successful choice', (
    tester,
  ) async {
    final sent = spyAnnouncements(tester);
    await pumpPicker(tester);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(option(AppLocale.vi.nativeName))).pop();
    await tester.pumpAndSettle();
    expect(sent, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpPicker(tester, fail: true);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    await tapOption(tester, AppLocale.vi.nativeName);
    await tester.pumpAndSettle();
    expect(sent, isEmpty);
    expect(
      find.text('Chưa lưu được ngôn ngữ. Vui lòng thử lại.'),
      findsOneWidget,
    );
  });
  testWidgets('speech channel failure preserves a successful saved choice', (
    tester,
  ) async {
    final sent = spyAnnouncements(tester, reject: true);
    final prefs = await pumpPicker(tester);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    await tapOption(tester, AppLocale.vi.nativeName);
    await tester.pumpAndSettle();
    expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
    expect(sent, hasLength(1));
    expect(
      find.text('Chưa lưu được ngôn ngữ. Vui lòng thử lại.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    testWidgets('language picker fits ${width.toInt()}dp at text 200%', (
      tester,
    ) async {
      await pumpPicker(tester, width: width);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text(AppLocale.vi.nativeName), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the button names the current language in that language', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpPicker(tester);
    expect(
      find.descendant(
        of: find.byType(TextButton),
        matching: find.text(AppLocale.vi.nativeName),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Ngôn ngữ giao diện: ${AppLocale.vi.nativeName}'),
      findsOneWidget,
    );
    handle.dispose();
  });
}

class _FailingController extends LocaleController {
  @override
  Future<void> set(LocaleChoice choice) async =>
      throw StateError('synthetic save failure');
}
