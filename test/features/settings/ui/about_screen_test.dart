import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/skeleton.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/about_screen.dart';

import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

void main() {
  late SettingsTestEnv env;

  setUp(() async {
    env = SettingsTestEnv(await createTestPrefs());
  });

  Future<void> pumpAbout(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: env.overrides,
        child: MaterialApp(theme: buildDarkTheme(), home: const AboutScreen()),
      ),
    );
  }

  testWidgets('shows the app name, version, credits and legal notice', (
    tester,
  ) async {
    await pumpAbout(tester);
    await tester.pumpAndSettle();

    expect(find.text('VALVN'), findsOneWidget);
    expect(
      find.text(
        '${SettingsStrings.version('1.2.3')} · '
        '${SettingsStrings.buildNumber('42')}',
      ),
      findsOneWidget,
    );
    expect(find.text(SettingsStrings.aboutCreditContent), findsOneWidget);
    expect(find.text(SettingsStrings.aboutCreditRiot), findsOneWidget);
    expect(find.text(SettingsStrings.aboutCreditDocs), findsOneWidget);
    expect(find.text(CommonStrings.riotDisclaimer), findsOneWidget);
  });

  testWidgets('credit links open externally', (tester) async {
    await pumpAbout(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(SettingsStrings.aboutCreditContent));
    await tester.pumpAndSettle();
    expect(env.openedUrls, [SettingsLinks.valorantApi]);
  });

  testWidgets('shows a skeleton while the version is loading', (tester) async {
    env.loadPackageInfo = () => Completer<PackageInfo>().future;
    await pumpAbout(tester);
    await tester.pump();

    expect(find.text(SettingsStrings.aboutTitle), findsOneWidget);
    expect(find.byType(Skeleton), findsOneWidget);
    expect(find.textContaining(SettingsStrings.version('')), findsNothing);
  });
}
