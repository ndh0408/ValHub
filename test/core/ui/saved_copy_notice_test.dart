import '../../helpers/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/saved_copy_notice.dart';
import 'package:valvn/core/util/clock.dart';

import '../../helpers/test_prefs.dart';

const _me = 'aaaaaaaa-0000-4000-8000-0000000000aa';

void main() {
  final now = DateTime(2026, 10, 7, 9);

  Future<GoRouter> pump(
    WidgetTester tester, {
    required bool needsLogin,
    required DateTime receivedAt,
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      Account(
        puuid: _me,
        gameName: 'Tôi',
        tagLine: 'VN1',
        region: 'ap',
        shard: 'ap',
        needsLogin: needsLogin,
      ).toJson(),
    ]);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SavedCopyNotice(puuid: _me, receivedAt: receivedAt),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (_, s) => Text('login ${s.uri.queryParameters['reauth']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(FixedClock(now)),
        ],
        child: MaterialApp.router(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  testWidgets('offline: the save time only, when it is today', (tester) async {
    await pump(
      tester,
      needsLogin: false,
      receivedAt: DateTime(2026, 10, 7, 8, 5),
    );
    expect(
      find.text(tl.commonOfflineCached(tf.time(DateTime(2026, 10, 7, 8, 5)))),
      findsOneWidget,
    );
    expect(find.text(tl.commonSignInAgain), findsNothing);
  });

  testWidgets('an expired sign-in says so, with the day, and re-logs in', (
    tester,
  ) async {
    final at = DateTime(2026, 10, 5, 17, 2);
    await pump(tester, needsLogin: true, receivedAt: at);
    expect(
      find.text(
        tl.commonSavedCopyNeedsLogin('${tf.time(at)}, ${tf.dayMonth(at)}'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text(tl.commonSignInAgain));
    await tester.pumpAndSettle();
    expect(find.text('login $_me'), findsOneWidget);
  });
}
