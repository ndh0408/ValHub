import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/shell.dart';
import 'package:valvn/core/l10n/app_locale.dart';

import '../helpers/offline_app.dart';
import 'overflow_matrix_test.dart' show matrixRoutes;

/// RTL smoke test (docs/design/I18N.md 8.1): Arabic lays the app out right
/// to left and every matrix route builds without a framework error.
void main() {
  testWidgets('Arabic runs right to left on every matrix route', (
    tester,
  ) async {
    expect(AppLocale.ar.isRtl, isTrue);
    final router = await pumpOfflineApp(tester, locale: AppLocale.ar.flutter);
    final shipped = kShippedLocales.contains(AppLocale.ar);
    final shell = find.byType(AppShell);
    expect(shell, findsOneWidget);
    expect(
      Directionality.of(tester.element(shell)),
      shipped ? TextDirection.rtl : TextDirection.ltr,
      reason: 'Arabic is RTL once it ships; before that the app falls back',
    );
    for (final route in matrixRoutes) {
      router.go(route);
      await settleFrames(tester);
      expect(tester.takeException(), isNull, reason: route);
    }
    await unmountOfflineApp(tester);
  });
}
