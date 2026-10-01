import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/config/client_version.dart';
import 'package:valvn/core/l10n/account_strings.dart';

import '../features/settings/settings_fakes.dart';
import '../helpers/test_prefs.dart';

class _Versions extends Mock implements ClientVersionRepository {}

void main() {
  for (final unknownAccount in [false, true]) {
    testWidgets(
      unknownAccount
          ? 'native link waits for pushed login, then rejects a missing account'
          : 'native link preserves pushed login and opens only after it closes',
      (tester) async {
        final env = SettingsTestEnv(await createTestPrefs());
        final versions = _Versions();
        when(() => versions.refresh())
            .thenAnswer((_) async => ClientVersionInfo.fallback);
        final router = GoRouter(
          navigatorKey: GlobalKey<NavigatorState>(),
          initialLocation: '/welcome',
          routes: [
            for (final route in ['welcome', 'login', 'store'])
              GoRoute(
                path: '/$route',
                builder: (_, _) => Scaffold(body: Text('PAGE:$route')),
              ),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            ...env.overrides,
            routerProvider.overrideWithValue(router),
            clientVersionRepositoryProvider.overrideWithValue(versions),
          ],
        );
        addTearDown(() {
          container.dispose();
          router.dispose();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const ValVnApp(),
          ),
        );
        await tester.pumpAndSettle();
        unawaited(router.push<void>('/login'));
        await tester.pumpAndSettle();
        // GoRouter keeps the underlying URI for imperative pushes. The
        // navigation gate must use the top page, otherwise it destroys login.
        expect(router.routeInformationProvider.value.uri.path, '/welcome');
        expect(router.state.uri.path, '/login');
        await tester.binding.handlePushRoute(
          'valvn://store${unknownAccount ? '?account=missing' : ''}',
        );
        await tester.pumpAndSettle();
        expect(find.text('PAGE:login'), findsOneWidget);
        expect(router.state.uri.path, '/login');
        router.pop();
        await tester.pumpAndSettle();
        if (unknownAccount) {
          expect(router.state.uri.path, '/welcome');
          expect(find.text(AccountStrings.linkAccountMissing), findsOneWidget);
        } else {
          expect(router.state.uri.path, '/store');
          expect(find.text('PAGE:store'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
