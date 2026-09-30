import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/auth/auth_routes.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/settings/legal/legal_documents.dart';
import 'package:valvn/features/settings/settings_routes.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/legal_document_screen.dart';

import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

/// A 360dp-wide (small phone), very tall surface so every section renders
/// without scrolling; overflows fail the test.
void _smallPhoneTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 3800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Lets snackbar timers run out so nothing is pending when the test ends.
Future<void> _drainSnackBars(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 5));

void main() {
  late Prefs prefs;
  late SettingsTestEnv env;
  late ProviderContainer container;

  setUp(() async {
    prefs = await createTestPrefs();
    env = SettingsTestEnv(prefs);
  });

  GoRouter buildRouter() => GoRouter(
    initialLocation: SettingsRoutes.root,
    routes: [
      ...settingsBranchRoutes,
      ...settingsTopLevelRoutes,
      GoRoute(
        path: AuthRoutes.login,
        builder: (c, s) => Scaffold(
          body: Text('LOGIN:${s.uri.queryParameters['reauth'] ?? ''}'),
        ),
      ),
    ],
  );

  Future<void> pumpSettings(
    WidgetTester tester, {
    List<Account> accounts = const [],
  }) async {
    _smallPhoneTallSurface(tester);
    await seedAccounts(prefs, accounts);
    container = ProviderContainer.test(overrides: env.overrides);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: buildRouter(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('TÀI KHOẢN', () {
    testWidgets('renders every section, the accounts and the app info', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);

      expect(find.text(AccountStrings.accountsHeader(2, 10)), findsOneWidget);
      for (final header in const [
        SettingsStrings.optionsHeader,
        SettingsStrings.notificationsHeader,
        SettingsStrings.appearanceHeader,
        SettingsStrings.appHeader,
        SettingsStrings.aboutHeader,
      ]) {
        expect(find.text(header), findsOneWidget);
      }
      expect(find.text('Player1#VN'), findsOneWidget);
      expect(find.text('Player2#VN'), findsOneWidget);
      // Exactly one active marker (the first account is active by default).
      expect(find.byIcon(Icons.check), findsOneWidget);
      // The version and build live on the About screen only.
      expect(find.text(SettingsStrings.version('1.2.3')), findsNothing);
      expect(find.text(SettingsStrings.buildNumber('42')), findsNothing);
      expect(find.text('5,0 MB'), findsOneWidget);
      // The Riot disclaimer lives in the "Giới thiệu & pháp lý" hub now.
      expect(find.text(CommonStrings.riotDisclaimer), findsNothing);
      expect(find.text(AccountStrings.signOutAll), findsOneWidget);
    });

    testWidgets('+ Thêm tài khoản opens /login', (tester) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(AccountStrings.addAccount(1, 10)));
      await tester.pumpAndSettle();
      expect(find.text('LOGIN:'), findsOneWidget);
    });

    testWidgets('at 10/10 accounts adding is blocked with a message', (
      tester,
    ) async {
      await pumpSettings(
        tester,
        accounts: [for (var i = 1; i <= 10; i++) testAccount(i)],
      );

      expect(find.text(AccountStrings.maxAccounts(10)), findsOneWidget);
      await tester.tap(find.text(AccountStrings.addAccount(10, 10)));
      await tester.pumpAndSettle();
      expect(find.textContaining('LOGIN:'), findsNothing);
    });

    testWidgets('tapping another account switches to it', (tester) async {
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);
      expect(container.read(activePuuidProvider), testPuuid(1));

      await tester.tap(find.text('Player2#VN'));
      await tester.pumpAndSettle();

      expect(container.read(activePuuidProvider), testPuuid(2));
      expect(
        find.text(SettingsStrings.switchedTo('Player2#VN')),
        findsOneWidget,
      );
      await _drainSnackBars(tester);
    });

    testWidgets('an expired account opens /login?reauth=<puuid>', (
      tester,
    ) async {
      await pumpSettings(
        tester,
        accounts: [testAccount(1), testAccount(2, needsLogin: true)],
      );

      expect(find.text(AccountStrings.needsLogin), findsOneWidget);
      await tester.tap(find.byTooltip(CommonStrings.signInAgain));
      await tester.pumpAndSettle();
      expect(find.text('LOGIN:${testPuuid(2)}'), findsOneWidget);
    });

    testWidgets('deleting asks for confirmation, then removes the account', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);

      await tester.tap(find.byTooltip(AccountStrings.removeAccount).first);
      await tester.pumpAndSettle();
      expect(
        find.text(AccountStrings.removeAccountConfirm('Player1#VN')),
        findsOneWidget,
      );

      await tester.tap(find.text(CommonStrings.cancel));
      await tester.pumpAndSettle();
      expect(find.text('Player1#VN'), findsOneWidget);

      await tester.tap(find.byTooltip(AccountStrings.removeAccount).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(CommonStrings.delete));
      await tester.pumpAndSettle();

      expect(find.text('Player1#VN'), findsNothing);
      expect(find.text('Player2#VN'), findsOneWidget);
      expect(find.text(AccountStrings.accountsHeader(1, 10)), findsOneWidget);
      expect(
        find.text(SettingsStrings.removedAccount('Player1#VN')),
        findsOneWidget,
      );
      await _drainSnackBars(tester);
    });

    testWidgets('sign out all asks first, then removes every account', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);

      await tester.tap(find.text(AccountStrings.signOutAll));
      await tester.pumpAndSettle();
      expect(find.text(AccountStrings.signOutAllConfirm), findsOneWidget);
      // The dialog's confirm button carries the same label.
      await tester.tap(find.text(AccountStrings.signOutAll).last);
      await tester.pumpAndSettle();

      expect(container.read(accountsProvider), isEmpty);
      expect(find.text(CommonStrings.errorNoAccount), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('an empty account list shows the empty row', (tester) async {
      await pumpSettings(tester);

      expect(find.text(AccountStrings.accountsHeader(0, 10)), findsOneWidget);
      expect(find.text(CommonStrings.errorNoAccount), findsOneWidget);
      expect(find.text(AccountStrings.signOutAll), findsNothing);
    });
  });

  group('DỮ LIỆU CỘNG ĐỒNG', () {
    final header = CommunityStrings.dataTitle.toUpperCase();

    testWidgets('hidden until the active account joined the Community', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);

      expect(find.text(header), findsNothing);
      expect(find.text(CommunityStrings.deleteDataTitle), findsNothing);
    });

    testWidgets('shown under the accounts, for the active account only', (
      tester,
    ) async {
      await prefs.setString(communityConsentKey(testPuuid(1)), 'granted');
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);

      expect(find.text(header), findsOneWidget);
      expect(find.text(CommunityStrings.exportTitle), findsOneWidget);
      expect(find.text(CommunityStrings.deleteDataTitle), findsOneWidget);
      expect(find.text(CommunityStrings.withdrawTitle), findsOneWidget);
      expect(
        find.text(CommunityStrings.dataFooter('Player1#VN')),
        findsOneWidget,
      );
      // Between "TÀI KHOẢN" and "TÙY CHỌN".
      final accounts = tester.getTopLeft(
        find.text(AccountStrings.accountsHeader(2, 10)),
      );
      final data = tester.getTopLeft(find.text(header));
      final options = tester.getTopLeft(
        find.text(SettingsStrings.optionsHeader),
      );
      expect(accounts.dy, lessThan(data.dy));
      expect(data.dy, lessThan(options.dy));

      // Account 2 never joined: switching to it hides the group.
      await tester.tap(find.text('Player2#VN'));
      await tester.pumpAndSettle();
      expect(find.text(header), findsNothing);
      await tester.tap(find.text('Player1#VN'));
      await tester.pumpAndSettle();
      expect(find.text(header), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('signing the account out takes the group (and consent) away', (
      tester,
    ) async {
      await prefs.setString(communityConsentKey(testPuuid(1)), 'granted');
      await pumpSettings(tester, accounts: [testAccount(1)]);
      expect(find.text(header), findsOneWidget);

      await tester.tap(find.byTooltip(AccountStrings.removeAccount).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(CommonStrings.delete));
      await tester.pumpAndSettle();

      expect(find.text(header), findsNothing);
      expect(prefs.getString(communityConsentKey(testPuuid(1))), isNull);
      await _drainSnackBars(tester);
    });
  });

  group('TÙY CHỌN and GIAO DIỆN', () {
    testWidgets('an option switch persists to appSettingsProvider', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      expect(container.read(appSettingsProvider).autoOpenLiveGame, isTrue);
      await tester.tap(find.text(SettingsStrings.optionAutoOpenLiveGame));
      await tester.pumpAndSettle();
      expect(container.read(appSettingsProvider).autoOpenLiveGame, isFalse);
      expect(readAppSettings(prefs).autoOpenLiveGame, isFalse);

      await tester.tap(find.text(SettingsStrings.optionShowLiveScore));
      await tester.pumpAndSettle();
      expect(container.read(appSettingsProvider).showLiveScore, isFalse);
    });

    testWidgets('the platform picker updates the active account', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.optionPlatform));
      await tester.pumpAndSettle();
      expect(find.text(SettingsStrings.platformPickerTitle), findsOneWidget);
      await tester.tap(find.text(AccountStrings.platformXbox));
      await tester.pumpAndSettle();

      expect(
        container.read(accountProvider(testPuuid(1)))?.platform,
        GamePlatform.xbox,
      );
      expect(find.text(AccountStrings.platformXbox), findsOneWidget);
    });

    testWidgets('picking a theme persists it and updates the value', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      expect(find.text(SettingsStrings.themeDark), findsOneWidget);
      await tester.tap(find.text(SettingsStrings.themeLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(SettingsStrings.themeSystem).last);
      await tester.pumpAndSettle();

      expect(container.read(appSettingsProvider).themeMode, ThemeMode.system);
      expect(find.text(SettingsStrings.themeSystem), findsOneWidget);
    });

    testWidgets('picking the item language persists it', (tester) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      expect(find.text(SettingsStrings.itemLanguageVi), findsOneWidget);
      await tester.tap(find.text(SettingsStrings.itemLanguageLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(SettingsStrings.itemLanguageEn).last);
      await tester.pumpAndSettle();

      expect(container.read(appSettingsProvider).itemLanguage, ItemLanguage.en);
      expect(find.text(SettingsStrings.itemLanguageEn), findsOneWidget);
    });
  });

  group('THÔNG BÁO', () {
    testWidgets('"Để sau" in the priming sheet keeps the switch off', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.notifStoreReset));
      await tester.pumpAndSettle();
      expect(find.text(SettingsStrings.primingBody), findsOneWidget);
      await tester.tap(find.text(SettingsStrings.primingLater));
      await tester.pumpAndSettle();

      expect(env.notifications.permissionRequests, 0);
      expect(
        container.read(appSettingsProvider).storeResetNotifications,
        isFalse,
      );
    });

    testWidgets('allowing notifications turns the switch on', (tester) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.notifWishlist));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, SettingsStrings.primingEnable),
      );
      await tester.pumpAndSettle();

      expect(env.notifications.permissionRequests, 1);
      expect(
        container
            .read(appSettingsProvider)
            .wishlistNotificationsFor(testAccount(1).puuid),
        isTrue,
      );
      expect(find.text(SettingsStrings.notifPermissionMissing), findsNothing);
    });

    testWidgets('an OS refusal keeps the choice and shows the warning row', (
      tester,
    ) async {
      env.notifications.grantOnRequest = false;
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.notifNightMarket));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, SettingsStrings.primingEnable),
      );
      await tester.pumpAndSettle();

      expect(
        container.read(appSettingsProvider).nightMarketNotifications,
        isTrue,
      );
      expect(find.text(SettingsStrings.notifPermissionMissing), findsOneWidget);
      await tester.tap(find.text(CommonStrings.openSettings));
      await tester.pumpAndSettle();
      expect(env.notifications.openedSystemSettings, 1);
    });

    testWidgets('with permission already granted no sheet is shown', (
      tester,
    ) async {
      env.notifications.enabled = true;
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.notifStoreReset));
      await tester.pumpAndSettle();

      expect(find.text(SettingsStrings.primingBody), findsNothing);
      expect(
        container.read(appSettingsProvider).storeResetNotifications,
        isTrue,
      );
    });

    testWidgets('turning store reset off cancels reminders of all accounts', (
      tester,
    ) async {
      env.notifications.enabled = true;
      await prefs.setJson(
        PrefKeys.appSettings,
        const AppSettings(storeResetNotifications: true).toJson(),
      );
      await pumpSettings(tester, accounts: [testAccount(1), testAccount(2)]);

      await tester.tap(find.text(SettingsStrings.notifStoreReset));
      await tester.pumpAndSettle();

      expect(
        container.read(appSettingsProvider).storeResetNotifications,
        isFalse,
      );
      expect(
        env.notifications.cancelled,
        unorderedEquals([
          NotificationIds.storeReset(testPuuid(1)),
          NotificationIds.storeReset(testPuuid(2)),
        ]),
      );
    });
  });

  group('NÂNG CAO and THÔNG TIN', () {
    testWidgets('clearing the cache reports the freed size', (tester) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.clearCache));
      await tester.pumpAndSettle();

      expect(env.cacheService.clears, 1);
      expect(find.text(SettingsStrings.cacheCleared('5,0 MB')), findsOneWidget);
      expect(find.text('0 B'), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('a failed clear shows an error snackbar', (tester) async {
      env.cacheService.fail = true;
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.clearCache));
      await tester.pumpAndSettle();

      expect(find.text(SettingsStrings.clearCacheFailed), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('"Nâng cao" holds exactly the report and the temp data', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      expect(find.text(SettingsStrings.exportLog), findsOneWidget);
      expect(find.text(SettingsStrings.exportLogSubtitle), findsOneWidget);
      expect(find.text(SettingsStrings.clearCache), findsOneWidget);
      // No log viewer, no HTTP filter, no raw ids on screen.
      expect(find.text('HTTP'), findsNothing);
    });

    testWidgets('sending a bug report shares a file, not text on screen', (
      tester,
    ) async {
      env.log = SessionLog(clock: FixedClock(DateTime(2026, 9, 28, 14, 5, 9)))
        ..add('http.get', status: 200);
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.exportLog));
      await tester.pumpAndSettle();

      expect(env.reports, hasLength(1));
      final file = env.reports.single;
      expect(
        file.fileName,
        matches(RegExp(r'^valvn-bao-loi-\d{4}-\d{2}-\d{2}\.txt$')),
      );
      expect(
        file.text,
        startsWith(
          SettingsStrings.logFileHeader(CommonStrings.appName, '1.2.3'),
        ),
      );
      expect(file.text, contains('http.get'));
      expect(env.shared, isEmpty);
      // Nothing that looks like a log line is shown in the app.
      expect(find.textContaining('http.get'), findsNothing);
    });

    testWidgets('with nothing recorded the report is not shared', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.exportLog));
      await tester.pumpAndSettle();

      expect(env.reports, isEmpty);
      expect(find.text(SettingsStrings.exportLogEmpty), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('a failing share sheet shows a plain message', (tester) async {
      env.log = SessionLog()..add('http.get', status: 200);
      env.reportShareFails = true;
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.exportLog));
      await tester.pumpAndSettle();

      expect(find.text(SettingsStrings.logShareFailed), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('clearing temporary data also clears the recorded report', (
      tester,
    ) async {
      env.log = SessionLog()..add('http.get', status: 200);
      await pumpSettings(tester, accounts: [testAccount(1)]);
      expect(env.log.entries, isNotEmpty);

      await tester.tap(find.text(SettingsStrings.clearCache));
      await tester.pumpAndSettle();

      expect(env.log.entries, isEmpty);
      await _drainSnackBars(tester);
    });

    testWidgets('an old /settings/log link goes to Settings, not an error', (
      tester,
    ) async {
      _smallPhoneTallSurface(tester);
      await seedAccounts(prefs, [testAccount(1)]);
      final router = GoRouter(
        initialLocation: SettingsRoutes.log,
        routes: [...settingsBranchRoutes, ...settingsTopLevelRoutes],
      );
      container = ProviderContainer.test(overrides: env.overrides);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: buildDarkTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        SettingsRoutes.root,
      );
      expect(find.text(SettingsStrings.title), findsWidgets);
    });

    testWidgets('feedback opens the GitHub page; failures are reported', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.feedback));
      await tester.pumpAndSettle();
      expect(env.openedUrls, [SettingsLinks.feedback]);

      env.urlOpens = false;
      await tester.tap(find.text(SettingsStrings.feedback));
      await tester.pumpAndSettle();
      expect(find.text(SettingsStrings.linkOpenFailed), findsOneWidget);
      await _drainSnackBars(tester);
    });

    testWidgets('privacy policy and terms open from the About hub', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.aboutTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LegalDocuments.privacy.title));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LegalDocumentScreen>(find.byType(LegalDocumentScreen))
            .document,
        same(LegalDocuments.privacy),
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text(LegalDocuments.terms.title));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LegalDocumentScreen>(find.byType(LegalDocumentScreen))
            .document,
        same(LegalDocuments.terms),
      );
    });

    testWidgets('"Giới thiệu & pháp lý" opens the About screen', (
      tester,
    ) async {
      await pumpSettings(tester, accounts: [testAccount(1)]);

      await tester.tap(find.text(SettingsStrings.aboutTitle));
      await tester.pumpAndSettle();
      expect(find.text(SettingsStrings.aboutCreditContent), findsOneWidget);
    });
  });
}
