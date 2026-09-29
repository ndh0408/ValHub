import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/auth/auth_routes.dart';
import 'package:valvn/core/l10n/auth_strings.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/settings_routes.dart';
import 'package:valvn/features/settings/settings_strings.dart';

void main() {
  Future<void> pumpWelcome(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: SettingsRoutes.welcome,
      routes: [
        ...settingsTopLevelRoutes,
        GoRoute(
          path: AuthRoutes.login,
          builder: (c, s) => const Scaffold(body: Text('LOGIN_STUB')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: buildDarkTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows logo, tagline, bullets, footnote and disclaimer', (
    tester,
  ) async {
    await pumpWelcome(tester, const Size(360, 800));

    expect(find.bySemanticsLabel(CommonStrings.appName), findsOneWidget);
    expect(find.text(CommonStrings.tagline), findsOneWidget);
    expect(find.text(SettingsStrings.welcomeBulletStore), findsOneWidget);
    expect(find.text(SettingsStrings.welcomeBulletProfile), findsOneWidget);
    expect(find.text(SettingsStrings.welcomeBulletWishlist), findsOneWidget);
    expect(find.text(AuthStrings.signInCta), findsOneWidget);
    expect(find.text(SettingsStrings.welcomeFootnote), findsOneWidget);
    expect(find.text(CommonStrings.riotDisclaimer), findsOneWidget);
  });

  testWidgets('the sign-in button opens /login', (tester) async {
    await pumpWelcome(tester, const Size(360, 800));

    await tester.tap(find.text(AuthStrings.signInCta));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });

  testWidgets('scrolls without overflow on a short 320x480 screen', (
    tester,
  ) async {
    await pumpWelcome(tester, const Size(320, 480));

    await tester.scrollUntilVisible(
      find.text(CommonStrings.riotDisclaimer),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(CommonStrings.riotDisclaimer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
