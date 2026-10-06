import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/app/shell.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/features/settings/settings_routes.dart';

import '../helpers/offline_app.dart';

/// Accessibility guidelines (Flutter release checklist): tap targets of at
/// least 48 dp on Android / 44 pt on iOS and a label on every tappable
/// element, on the main screens, in every shipped language.
void main() {
  final routes = [
    for (final tab in AppTab.values) tab.root,
    SettingsRoutes.root,
    SettingsRoutes.about,
  ];
  for (final locale in kShippedLocales) {
    testWidgets('${locale.tag}: tap targets are large and labelled', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final router = await pumpOfflineApp(tester, locale: locale.flutter);
      for (final route in routes) {
        router.go(route);
        await settleFrames(tester);
        await expectLater(
          tester,
          meetsGuideline(androidTapTargetGuideline),
          reason: route,
        );
        await expectLater(
          tester,
          meetsGuideline(iOSTapTargetGuideline),
          reason: route,
        );
        await expectLater(
          tester,
          meetsGuideline(labeledTapTargetGuideline),
          reason: route,
        );
      }
      await unmountOfflineApp(tester);
      handle.dispose();
    });
  }
}
