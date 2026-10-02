import 'package:valvn/core/l10n/l10n.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/skeleton.dart';
import 'package:valvn/features/settings/legal/legal_documents.dart';
import 'package:valvn/features/settings/legal/legal_strings.dart';
import 'package:valvn/features/settings/settings_routes.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/legal_document_screen.dart';

import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

void main() {
  late SettingsTestEnv env;

  setUp(() async {
    env = SettingsTestEnv(await createTestPrefs());
  });

  Future<void> pumpAbout(
    WidgetTester tester, {
    Size size = const Size(360, 2600),
    double textScale = 1,
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: env.overrides,
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: const [Locale('vi')],
          theme: theme ?? buildDarkTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          routerConfig: GoRouter(
            initialLocation: SettingsRoutes.about,
            routes: settingsBranchRoutes,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'shows ValHub identity, version, documents and contact without a source card',
    (tester) async {
      await pumpAbout(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(CommonStrings.appName, findRichText: true),
        findsOneWidget,
      );
      expect(find.text(CommonStrings.tagline), findsOneWidget);
      expect(
        find.text(
          '${SettingsStrings.version('1.2.3')} · '
          '${SettingsStrings.buildNumber('42')}',
        ),
        findsOneWidget,
      );
      expect(find.text(LegalStrings.aboutIntro), findsOneWidget);
      for (final doc in LegalDocuments.all) {
        expect(find.text(doc.title), findsOneWidget);
        expect(find.text(doc.summary), findsOneWidget);
      }
      expect(find.text(SettingsStrings.aboutCreditContent), findsNothing);
      expect(find.text(SettingsStrings.aboutCreditRiot), findsNothing);
      expect(find.text(SettingsStrings.aboutCreditDocs), findsNothing);
      expect(find.text(LegalStrings.creditsHeader), findsNothing);
      expect(find.text(LegalStrings.thirdPartyLicenses), findsOneWidget);
      expect(find.text(LegalStrings.contact), findsOneWidget);
      expect(find.text(LegalInfo.copyrightNotice), findsOneWidget);
      expect(find.text(CommonStrings.riotDisclaimer), findsOneWidget);
    },
  );

  testWidgets('each document row opens its document at /settings/about/<id>', (
    tester,
  ) async {
    await pumpAbout(tester);
    await tester.pumpAndSettle();

    for (final doc in LegalDocuments.all) {
      await tester.tap(find.text(doc.summary));
      await tester.pumpAndSettle();
      final screen = tester.widget<LegalDocumentScreen>(
        find.byType(LegalDocumentScreen),
      );
      expect(screen.document, same(doc));
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('third-party licences open the Flutter licence page', (
    tester,
  ) async {
    await pumpAbout(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(LegalStrings.thirdPartyLicenses));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('feedback opens the ValHub issue page externally', (
    tester,
  ) async {
    await pumpAbout(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(SettingsStrings.feedback));
    await tester.pumpAndSettle();
    expect(env.openedUrls, [SettingsLinks.feedback]);
  });

  testWidgets('no overflow at 360dp with text scale 2.0 (light theme)', (
    tester,
  ) async {
    await pumpAbout(
      tester,
      size: const Size(360, 780),
      textScale: 2,
      theme: buildLightTheme(),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -20000),
      4000,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
