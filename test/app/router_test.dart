import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/settings/ui/welcome_screen.dart';
import 'package:valvn/features/store/ui/store_screen.dart';

import '../helpers/test_prefs.dart';

void main() {
  group('appRedirect', () {
    String? r(bool has, String location) =>
        appRedirect(hasAccounts: has, location: Uri.parse(location));

    test('signed out: only /welcome and /login are reachable', () {
      expect(r(false, '/store'), '/welcome');
      expect(r(false, '/profile/match/abc'), '/welcome');
      expect(r(false, '/settings/about'), '/welcome');
      expect(r(false, '/welcome'), isNull);
      expect(r(false, '/login'), isNull);
      expect(r(false, '/login?reauth=x'), isNull);
    });

    test('signed in: /welcome and / go to /store, everything else stays', () {
      expect(r(true, '/welcome'), '/store');
      expect(r(true, '/'), '/store');
      expect(r(true, '/store'), isNull);
      expect(r(true, '/collection/weapons/w/skin/s'), isNull);
      expect(r(true, '/login?reauth=x'), isNull);
      expect(r(true, '/player/abc'), isNull);
    });
  });

  testWidgets('router follows the account state', (tester) async {
    final prefs = await createTestPrefs();
    final hasAccounts = ValueNotifier(false);
    final router = createAppRouter(
      hasAccounts: hasAccounts,
      navigatorKey: GlobalKey<NavigatorState>(),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);

    hasAccounts.value = true;
    await tester.pumpAndSettle();
    expect(find.byType(StoreScreen), findsOneWidget);
    expect(find.text('Cửa hàng'), findsWidgets);

    router.go('/collection/weapons/w1/skin/s1');
    await tester.pumpAndSettle();
    expect(router.state.pathParameters['skinId'], 's1');

    hasAccounts.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
