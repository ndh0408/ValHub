import '../../helpers/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_widgets.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/auth_routes.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';

import '../../helpers/test_prefs.dart';

class _MockPvpApi extends Mock implements PvpApi {}

class _MockSessions extends Mock implements SessionManager {}

String _puuid(int i) =>
    '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}';

Account _account(int i, {bool needsLogin = false}) => Account(
  puuid: _puuid(i),
  gameName: 'Người Chơi Có Tên Dài $i',
  tagLine: 'VN$i',
  region: 'ap',
  shard: 'ap',
  level: 100 + i,
  rankTier: 12,
  needsLogin: needsLogin,
);

void main() {
  late Prefs prefs;
  late _MockPvpApi api;
  late _MockSessions sessions;

  Future<void> seed(List<Account> accounts) async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
    await prefs.setString(PrefKeys.activePuuid, accounts.first.puuid);
    api = _MockPvpApi();
    sessions = _MockSessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => api.gameSession(any()))
        .thenAnswer((_) async => throw const NotFoundException());
  }

  List<Override> overrides() => [
    prefsProvider.overrideWithValue(prefs),
    pvpApiProvider.overrideWithValue(api),
    sessionManagerProvider.overrideWithValue(sessions),
  ];

  Future<void> pumpHost(
    WidgetTester tester, {
    double textScale = 1,
    ThemeData? theme,
    Size size = const Size(360, 740),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showAccountSwitcherSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AuthRoutes.login,
          builder: (context, state) => const Text('LOGIN'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme ?? buildDarkTheme(),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('sheet: title with the count, every account, add row', (
    tester,
  ) async {
    await seed([_account(1), _account(2, needsLogin: true), _account(3)]);
    await pumpHost(tester);

    expect(find.text(AccountStrings.switcherTitleCount(3, 10)), findsOneWidget);
    expect(find.byTooltip(CommonStrings.close), findsOneWidget);
    for (var i = 1; i <= 3; i++) {
      expect(find.text('Người Chơi Có Tên Dài $i#VN$i'), findsOneWidget);
    }
    // The dead session says so, with the re-login button.
    expect(find.text(AccountStrings.needsLogin), findsOneWidget);
    expect(find.byTooltip(CommonStrings.signInAgain), findsOneWidget);
    expect(find.text(AccountStrings.addAccount(3, 10)), findsOneWidget);
    // Every account has its own ⋮ menu here too.
    expect(
      find.byTooltip(tl.accountMoreActions('Người Chơi Có Tên Dài 1#VN1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('⋮ offers the account actions; re-login closes the sheet', (
    tester,
  ) async {
    await seed([_account(1), _account(2, needsLogin: true)]);
    await pumpHost(tester);

    await tester.tap(
      find.byTooltip(tl.accountMoreActions('Người Chơi Có Tên Dài 2#VN2')),
    );
    await tester.pumpAndSettle();
    for (final label in [
      tl.commonSignInAgain,
      tl.accountLoginNoteAdd,
      tl.settingsGeoConnection,
      tl.accountRemoveAccount,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tester.tap(find.text(tl.commonSignInAgain));
    await tester.pumpAndSettle();
    expect(find.text(AccountStrings.switcherSubtitle), findsNothing);
  });

  testWidgets('tapping another account switches to it and closes', (
    tester,
  ) async {
    await seed([_account(1), _account(2)]);
    await pumpHost(tester);

    await tester.tap(find.text('Người Chơi Có Tên Dài 2#VN2'));
    await tester.pumpAndSettle();
    expect(find.text(AccountStrings.switcherSubtitle), findsNothing);
    expect(prefs.getString(PrefKeys.activePuuid), _puuid(2));
  });

  testWidgets('"Thêm tài khoản" opens the login', (tester) async {
    await seed([_account(1)]);
    await pumpHost(tester);

    await tester.tap(find.text(AccountStrings.addAccount(1, 10)));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('at the limit adding is explained, not opened', (tester) async {
    await seed([for (var i = 1; i <= 10; i++) _account(i)]);
    await pumpHost(tester);

    final max = AccountStrings.maxAccounts(10);
    // Explained inside the row…
    expect(find.text(max), findsOneWidget);
    await tester.ensureVisible(find.text(AccountStrings.addAccount(10, 10)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AccountStrings.addAccount(10, 10)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // …and again in a snack bar, and the login is not opened.
    expect(find.text(max), findsNWidgets(2));
    expect(find.text('LOGIN'), findsNothing);
  });

  for (final (name, theme) in [
    ('dark', buildDarkTheme()),
    ('light', buildLightTheme()),
  ]) {
    testWidgets('10 accounts scroll: no overflow at 360 dp, 200 % text '
        '($name)', (tester) async {
      await seed([
        for (var i = 1; i <= 10; i++) _account(i, needsLogin: i == 4),
      ]);
      await pumpHost(tester, textScale: 2, theme: theme);
      expect(tester.takeException(), isNull);

      await tester.fling(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -3000),
        3000,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.text(AccountStrings.addAccount(10, 10), skipOffstage: false),
        findsOneWidget,
      );
    });
  }
}
