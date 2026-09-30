import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/l10n.dart';

import '../helpers/l10n.dart';

/// SMOKE test of the W0 foundation (docs/design/I18N.md 18.4 V1, V2).
///
/// It exercises the three `smoke*` keys of the placeholder `app_vi.arb`, which
/// exist only to prove that generation, the delegate list and `context.l10n`
/// work. DELETE this file in W1, when `app_vi.arb` becomes the real template
/// (`arb_structure_test` and `vi_parity_test` take over).
void main() {
  group('gen-l10n output', () {
    test('plain, placeholder and plural messages are generated', () {
      final l10n = lookupAppLocalizations(const Locale('vi'));
      expect(l10n.localeName, 'vi');
      expect(l10n.smokePlain, 'Kiểm tra sinh mã');
      expect(l10n.smokeGreeting('Nguyễn Văn A'), 'Xin chào, Nguyễn Văn A!');
      expect(l10n.smokeCount(0), '0 mục');
      expect(l10n.smokeCount(5), '5 mục');
    });

    test('a locale that has no ARB is rejected loudly', () {
      expect(
        () => lookupAppLocalizations(const Locale('xx')),
        throwsFlutterError,
      );
    });

    test('tl is the generated vi messages while only vi exists', () {
      expect(tl.localeName, 'vi');
      expect(
        tl.smokePlain,
        lookupAppLocalizations(const Locale('vi')).smokePlain,
      );
    });
  });

  group('appLocalizationsDelegates', () {
    test(
      'starts with ours and never contains the legacy Material delegate',
      () {
        expect(appLocalizationsDelegates.first, AppLocalizations.delegate);
        // The generated list names the legacy flutter_localizations Material
        // delegate at index 1; it must not leak into ours (Risk #2).
        final legacyMaterial = AppLocalizations.localizationsDelegates[1];
        expect(appLocalizationsDelegates, isNot(contains(legacyMaterial)));
        expect(
          appLocalizationsDelegates.map((d) => d.type),
          isNot(contains(legacyMaterial.type)),
        );
      },
    );

    test('has one delegate per localizations type (no duplicates)', () {
      final types = appLocalizationsDelegates.map((d) => d.type).toList();
      expect(types.toSet().length, types.length);
    });
  });

  group('context.l10n', () {
    testWidgets('resolves the messages of the ambient locale', (tester) async {
      late AppLocalizations got;
      await tester.pumpWidget(
        testL10nApp(
          Builder(
            builder: (context) {
              got = context.l10n;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(got.localeName, 'vi');
      expect(got.smokeGreeting('X'), 'Xin chào, X!');
    });

    testWidgets('throws a clear error without the delegate', (tester) async {
      await tester.pumpWidget(
        Localizations(
          locale: const Locale('vi'),
          delegates: const [DefaultWidgetsLocalizations.delegate],
          child: Builder(
            builder: (context) {
              context.l10n;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(
        (error! as FlutterError).message,
        contains('appLocalizationsDelegates'),
      );
    });
  });
}
