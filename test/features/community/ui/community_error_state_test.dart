import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/auth/auth_routes.dart';
import 'package:valvn/features/community/data/community_exception.dart';
import 'package:valvn/features/community/ui/widgets/community_widgets.dart';

import '../../../helpers/l10n.dart';
import '../community_test_env.dart';

const _rejected = CommunityException(CommunityException.riotRejected);

/// `/` shows [home]; `/login` records the re-login it was opened for.
Future<List<String?>> _pump(
  WidgetTester tester,
  CommunityTestEnv env,
  Widget home,
) async {
  final reauth = <String?>[];
  await pumpCommunityRouter(
    tester,
    env,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => Scaffold(body: home)),
      GoRoute(
        path: AuthRoutes.login,
        builder: (context, state) {
          reauth.add(state.uri.queryParameters['reauth']);
          return const Scaffold(body: Text('login'));
        },
      ),
    ],
  );
  await settle(tester);
  return reauth;
}

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  for (final compact in [false, true]) {
    testWidgets('Riot refusal offers "Đăng nhập lại" (compact: $compact)', (
      tester,
    ) async {
      var retried = 0;
      final reauth = await _pump(
        tester,
        env,
        CommunityErrorState(
          error: _rejected,
          compact: compact,
          onRetry: () => retried++,
        ),
      );
      expect(find.text(tl.communityErrorRiotRejected), findsOneWidget);
      expect(find.text(tl.commonRetry), findsNothing);

      // No puuid given: the active account signs in again.
      await tester.tap(find.text(tl.commonSignInAgain));
      await settle(tester);
      expect(find.text('login'), findsOneWidget);
      expect(reauth, [mePuuid]);
      expect(retried, 0);
      await unmount(tester);
    });
  }

  testWidgets('a failed action with a Riot refusal: snackbar → sign in', (
    tester,
  ) async {
    final reauth = await _pump(
      tester,
      env,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showCommunityError(context, _rejected),
          child: const Text('act'),
        ),
      ),
    );
    await tester.tap(find.text('act'));
    await settle(tester);
    expect(find.text(tl.communityErrorRiotRejected), findsOneWidget);

    await tester.tap(find.text(tl.commonSignInAgain));
    await settle(tester);
    expect(reauth, [mePuuid]);
    await unmount(tester);
  });

  testWidgets('other failures keep "Thử lại" and a plain snackbar', (
    tester,
  ) async {
    const network = CommunityException(CommunityException.network);
    await _pump(
      tester,
      env,
      Column(
        children: [
          CommunityErrorState(error: network, compact: true, onRetry: () {}),
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showCommunityError(context, network),
              child: const Text('act'),
            ),
          ),
        ],
      ),
    );
    expect(find.text(tl.commonRetry), findsOneWidget);
    await tester.tap(find.text('act'));
    await settle(tester);
    expect(find.byType(SnackBarAction), findsNothing);
    expect(find.text(tl.commonSignInAgain), findsNothing);
    await unmount(tester);
  });
}
