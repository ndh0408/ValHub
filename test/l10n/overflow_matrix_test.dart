import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/app/shell.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/features/settings/settings_routes.dart';

import '../helpers/offline_app.dart';

/// Every route a first-time user reaches without Riot data (Riot and the
/// community server are offline, so screens show their real error/empty
/// states): the five tabs, Settings, About and every legal document.
final List<String> matrixRoutes = [
  for (final tab in AppTab.values) tab.root,
  SettingsRoutes.root,
  SettingsRoutes.about,
  for (final doc in const ['privacy', 'terms', 'community', 'notice'])
    '${SettingsRoutes.about}/$doc',
];

/// Overflow matrix (docs/design/I18N.md 12.3): every shipped language at the
/// narrowest supported phone (360 dp) with normal and large text. A
/// `RenderFlex overflowed` or any other framework error fails the test.
void main() {
  for (final locale in kShippedLocales) {
    for (final scale in const [1.0, 1.3]) {
      testWidgets('${locale.tag} at 360 dp, text x$scale: no overflow', (
        tester,
      ) async {
        final reports = recordFlutterErrors();
        final router = await pumpOfflineApp(
          tester,
          locale: locale.flutter,
          textScale: scale,
        );
        for (final route in matrixRoutes) {
          router.go(route);
          await settleFrames(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: '$route\n${reports.join('\n')}',
          );
        }
        await unmountOfflineApp(tester);
      });
    }
  }
}
