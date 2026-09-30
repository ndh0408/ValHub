import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/l10n.dart';

/// V2 (docs/design/I18N.md 18.4, Risk #2): `appLocalizationsDelegates` under
/// the app's `MaterialUiCompatibilityBridge` localizes `material_ui` widgets
/// (date picker, back button) in Arabic and Japanese, i.e. `material_ui`'s
/// delegates are in effect and not the legacy `flutter_localizations` ones.
///
/// Expected strings are `material_ui`'s own translations
/// (`lib/src/l10n/material_<locale>.arb`).

/// The app's tree: `lib/app/app.dart` builds `MaterialApp.router` with the
/// same delegates and the same bridge.
Widget _app(
  Locale locale,
  Widget home, {
  List<LocalizationsDelegate<dynamic>> delegates = appLocalizationsDelegates,
}) => MaterialApp(
  locale: locale,
  supportedLocales: [locale],
  localizationsDelegates: delegates,
  // ignore: deprecated_member_use
  builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
  home: home,
);

/// Pumps [widget]. Until W1 scaffolds every locale, `WidgetsApp` warns (as a
/// debug error) that `AppLocalizations` does not support ar, ja, ...: expected
/// and harmless here, since this test is about `material_ui`. Exactly that
/// warning is consumed; anything else fails the test. Once every locale is
/// generated there is nothing to consume.
Future<void> _pump(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  final error = tester.takeException();
  if (error == null) return;
  // WidgetsApp reports a plain String, the delegate list is only in its
  // information collector.
  expect(
    error.toString(),
    allOf(
      startsWith('Warning: This application'),
      contains('is not supported by all of its localization delegates'),
    ),
  );
}

/// A home with a button that opens the date picker and one that pushes a
/// route whose AppBar shows the automatic back button.
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        TextButton(
          onPressed: () => showDatePicker(
            context: context,
            initialDate: DateTime(2026, 9, 22),
            firstDate: DateTime(2026),
            lastDate: DateTime(2027),
          ),
          child: const Text('open-date'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  Scaffold(appBar: AppBar(title: const Text('pushed'))),
            ),
          ),
          child: const Text('open-page'),
        ),
      ],
    ),
  );
}

class _Expected {
  const _Expected({
    required this.locale,
    required this.back,
    required this.cancel,
    required this.ok,
    required this.datePickerHelp,
  });
  final Locale locale;
  final String back;
  final String cancel;
  final String ok;
  final String datePickerHelp;
}

const _ar = _Expected(
  locale: Locale('ar'),
  back: 'رجوع',
  cancel: 'الإلغاء',
  ok: 'حسنًا',
  datePickerHelp: 'اختيار التاريخ',
);

const _ja = _Expected(
  locale: Locale('ja'),
  back: '戻る',
  cancel: 'キャンセル',
  ok: 'OK',
  datePickerHelp: '日付の選択',
);

void main() {
  for (final e in [_ar, _ja]) {
    group('${e.locale} under the compatibility bridge', () {
      testWidgets('the back button tooltip is localized', (tester) async {
        await _pump(tester, _app(e.locale, const _Home()));
        await tester.tap(find.text('open-page'));
        await tester.pumpAndSettle();
        expect(find.byTooltip(e.back), findsOneWidget);
        // And it works: the tooltip belongs to the button that pops the route.
        await tester.tap(find.byTooltip(e.back));
        await tester.pumpAndSettle();
        expect(find.text('open-page'), findsOneWidget);
      });

      testWidgets('showDatePicker is localized', (tester) async {
        await _pump(tester, _app(e.locale, const _Home()));
        await tester.tap(find.text('open-date'));
        await tester.pumpAndSettle();
        expect(find.text(e.datePickerHelp), findsOneWidget);
        expect(find.text(e.cancel), findsOneWidget);
        expect(find.text(e.ok), findsOneWidget);
      });

      testWidgets(
        'legacy-Material widgets under the bridge are localized too',
        (tester) async {
          late legacy.MaterialLocalizations legacyLoc;
          late MaterialLocalizations modernLoc;
          await _pump(
            tester,
            _app(
              e.locale,
              Builder(
                builder: (context) {
                  legacyLoc = legacy.MaterialLocalizations.of(context);
                  modernLoc = MaterialLocalizations.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          expect(legacyLoc.backButtonTooltip, e.back);
          expect(legacyLoc.cancelButtonLabel, e.cancel);
          expect(modernLoc.backButtonTooltip, e.back);
          expect(modernLoc.cancelButtonLabel, e.cancel);
          expect(modernLoc.okButtonLabel, e.ok);
          expect(modernLoc.datePickerHelpText, e.datePickerHelp);
        },
      );
    });
  }

  testWidgets('Arabic lays out right-to-left, Japanese left-to-right', (
    tester,
  ) async {
    late TextDirection arabic;
    late TextDirection japanese;
    await _pump(
      tester,
      _app(
        _ar.locale,
        Builder(
          builder: (context) {
            arabic = Directionality.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await _pump(
      tester,
      _app(
        _ja.locale,
        Builder(
          builder: (context) {
            japanese = Directionality.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(arabic, TextDirection.rtl);
    expect(japanese, TextDirection.ltr);
  });

  testWidgets('AppLocalizations stays resolvable under the bridge', (
    tester,
  ) async {
    // The bridge merges the parent delegates instead of replacing them.
    late AppLocalizations got;
    await _pump(
      tester,
      _app(
        AppLocale.vi.flutter,
        Builder(
          builder: (context) {
            got = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(got.localeName, 'vi');
  });

  testWidgets(
    'CONTROL: the generated delegate list does NOT localize material_ui',
    (tester) async {
      // AppLocalizations.localizationsDelegates names the legacy Material
      // delegate, which provides the legacy MaterialLocalizations type only:
      // material_ui's own type is missing for any language but English (its
      // default delegate is English-only), so material_ui widgets would throw
      // "No MaterialLocalizations found". That is why the list must never be
      // used.
      Object? modernLoc = 'unset';
      Object? legacyLoc = 'unset';
      await _pump(
        tester,
        _app(
          _ar.locale,
          Builder(
            builder: (context) {
              modernLoc = Localizations.of<MaterialLocalizations>(
                context,
                MaterialLocalizations,
              );
              legacyLoc = Localizations.of<legacy.MaterialLocalizations>(
                context,
                legacy.MaterialLocalizations,
              );
              return const SizedBox.shrink();
            },
          ),
          delegates: AppLocalizations.localizationsDelegates,
        ),
      );
      expect(modernLoc, isNull);
      // The legacy type is there (hence the bridge test above is meaningful).
      expect(legacyLoc, isA<legacy.MaterialLocalizations>());
    },
  );

  group('every language gets material_ui translations', () {
    for (final l in AppLocale.values) {
      testWidgets('${l.name} (${l.flutter})', (tester) async {
        late MaterialLocalizations loc;
        late Locale seen;
        late TextDirection direction;
        late legacy.MaterialLocalizations legacyLoc;
        await _pump(
          tester,
          _app(
            l.flutter,
            Builder(
              builder: (context) {
                loc = MaterialLocalizations.of(context);
                legacyLoc = legacy.MaterialLocalizations.of(context);
                seen = Localizations.localeOf(context);
                direction = Directionality.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(seen, l.flutter);
        expect(direction, l.textDirection);
        if (l != AppLocale.en) {
          expect(loc.backButtonTooltip, isNot('Back'), reason: l.name);
          expect(legacyLoc.backButtonTooltip, loc.backButtonTooltip);
        }
      });
    }

    testWidgets('Simplified and Traditional Chinese differ', (tester) async {
      late MaterialLocalizations simplified;
      late MaterialLocalizations traditional;
      await _pump(
        tester,
        _app(
          AppLocale.zh.flutter,
          Builder(
            builder: (context) {
              simplified = MaterialLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await _pump(
        tester,
        _app(
          AppLocale.zhHant.flutter,
          Builder(
            builder: (context) {
              traditional = MaterialLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(simplified.okButtonLabel, '确定');
      expect(traditional.okButtonLabel, '確定');
    });
  });
}
