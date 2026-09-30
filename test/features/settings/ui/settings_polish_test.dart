import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoActionSheet, CupertinoAlertDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/auth/auth_routes.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/settings_routes.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/widgets/settings_widgets.dart';

import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

/// 360 dp phone at 200 % text.
Widget _bigText(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: const TextScaler.linear(2)),
    child: child,
  ),
);

void _phone(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('confirmSettingsAction', () {
    Future<bool?> run(WidgetTester tester, TargetPlatform platform) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme().copyWith(platform: platform),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await confirmSettingsAction(
                  context,
                  title: AccountStrings.signOutAll,
                  message: AccountStrings.signOutAllConfirm,
                  confirmLabel: CommonStrings.delete,
                  destructive: true,
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('is a Cupertino alert on iOS', (tester) async {
      await run(tester, TargetPlatform.iOS);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(find.text(CommonStrings.delete));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });

    testWidgets('is a Material alert on Android', (tester) async {
      await run(tester, TargetPlatform.android);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });
  });

  testWidgets('the choice picker is a native action sheet on iOS', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme().copyWith(platform: TargetPlatform.iOS),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  picked = await showSettingsChoiceSheet<String>(
                    context: context,
                    title: SettingsStrings.themePickerTitle,
                    selected: 'a',
                    options: const [('a', 'Tối'), ('b', 'Sáng')],
                  ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoActionSheet), findsOneWidget);
    expect(find.text('✓ Tối'), findsOneWidget);
    await tester.tap(find.text('Sáng'));
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });

  group('no overflow at 360 dp and 200 % text', () {
    for (final (name, theme) in [
      ('dark', buildDarkTheme()),
      ('light', buildLightTheme()),
    ]) {
      testWidgets('welcome ($name)', (tester) async {
        _phone(tester, height: 640);
        final router = GoRouter(
          initialLocation: SettingsRoutes.welcome,
          routes: [
            ...settingsTopLevelRoutes,
            GoRoute(
              path: AuthRoutes.login,
              builder: (c, s) => const Scaffold(),
            ),
          ],
        );
        await tester.pumpWidget(
          _bigText(MaterialApp.router(theme: theme, routerConfig: router)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text(CommonStrings.riotDisclaimer),
          300,
          scrollable: find.byType(Scrollable),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('settings ($name)', (tester) async {
        _phone(tester, height: 7000);
        final prefs = await createTestPrefs();
        final env = SettingsTestEnv(prefs);
        await seedAccounts(prefs, [testAccount(1), testAccount(2)]);
        final router = GoRouter(
          initialLocation: SettingsRoutes.root,
          routes: [...settingsBranchRoutes, ...settingsTopLevelRoutes],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: env.overrides,
            child: _bigText(
              MaterialApp.router(theme: theme, routerConfig: router),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Player2#VN'), findsOneWidget);
      });
    }
  });
}
