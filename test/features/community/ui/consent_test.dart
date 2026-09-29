import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/community_previews.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_exception.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/ui/consent/consent_sheet.dart';
import 'package:valvn/features/community/ui/skins/skin_vote_button.dart';

import '../community_test_env.dart';

Future<void> _openTab(WidgetTester tester, CommunityTestEnv env) async {
  await pumpCommunityRouter(
    tester,
    env,
    routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
    initialLocation: CommunityRoutes.root,
  );
  await settle(tester);
}

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create(consent: false));

  test(
    'the consent pref lives under acct.<puuid>. (wiped with the account)',
    () {
      expect(
        communityConsentKey(mePuuid.toUpperCase()),
        startsWith(PrefKeys.accountPrefix(mePuuid)),
      );
    },
  );

  group('data layer', () {
    test(
      'no consent: no Riot token read, no request, consentRequired',
      () async {
        final container = env.container();
        final api = container.read(communityApiProvider);

        await expectLater(
          api.posts(mePuuid),
          throwsA(
            isA<CommunityException>().having(
              (e) => e.code,
              'code',
              CommunityException.consentRequired,
            ),
          ),
        );
        expect(env.server.requests, isEmpty);
        verifyNever(() => env.sessions.session(any()));
      },
    );

    test(
      'optional-auth reads fall back to anonymous (still no auth)',
      () async {
        env.server.json('GET /v1/skins/*/summary', {
          'skinUuid': reaverSkin,
          'ratingAvg': 4.0,
          'ratingCount': 3,
          'distribution': [0, 0, 1, 1, 1],
        });
        final container = env.container();

        final s = await container
            .read(communityApiProvider)
            .skinSummary(reaverSkin, puuid: mePuuid);

        expect(s.rating.count, 3);
        expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
        verifyNever(() => env.sessions.session(any()));
      },
    );

    test('after the user agrees, the auth call is made once', () async {
      env.server.json('GET /v1/posts', page([postJson('p1')]));
      final container = env.container();
      await container.read(communityConsentProvider(mePuuid).notifier).grant();

      final result = await container.read(communityApiProvider).posts(mePuuid);

      expect(result.items.single.id, 'p1');
      expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
    });

    test(
      'consent is wiped with the account and asked again after re-adding',
      () async {
        final container = env.container();
        final sub = container.listen(
          communityConsentProvider(mePuuid),
          (_, _) {},
        );
        addTearDown(sub.close);
        await container
            .read(communityConsentProvider(mePuuid).notifier)
            .grant();
        expect(
          container.read(communityConsentProvider(mePuuid)),
          CommunityConsent.granted,
        );

        await container.read(accountsProvider.notifier).remove(mePuuid);

        expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
        expect(
          container.read(communityConsentProvider(mePuuid)),
          CommunityConsent.unknown,
        );
      },
    );
  });

  testWidgets('first visit: the sheet explains and "Để sau" makes no request', (
    tester,
  ) async {
    await _openTab(tester, env);

    expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
    expect(find.text(CommunityStrings.consentVerify), findsOneWidget);
    expect(find.text(CommunityStrings.consentPublic), findsOneWidget);
    expect(find.text(CommunityStrings.consentLocal), findsOneWidget);
    expect(
      find.text(CommunityStrings.consentAccount('Tôi Là Ai#VN1')),
      findsOneWidget,
    );
    expect(env.server.requests, isEmpty);

    await tester.tap(find.byKey(const ValueKey('consent-later')));
    await settle(tester, frames: 20);

    expect(find.text(CommunityStrings.consentTitle), findsNothing);
    expect(find.text(CommunityStrings.consentGateTitle), findsOneWidget);
    expect(env.server.requests, isEmpty, reason: 'declined = no network call');
    verifyNever(() => env.sessions.session(any()));
    expect(env.prefs.getString(communityConsentKey(mePuuid)), 'declined');
    await unmount(tester);
  });

  testWidgets('shown once: a later launch does not reopen it by itself', (
    tester,
  ) async {
    await _openTab(tester, env);
    await tester.tap(find.byKey(const ValueKey('consent-later')));
    await settle(tester, frames: 20);
    await unmount(tester);

    // Next launch (same prefs, new providers).
    await _openTab(tester, env);
    expect(find.text(CommunityStrings.consentTitle), findsNothing);
    expect(find.text(CommunityStrings.consentGateTitle), findsOneWidget);
    expect(env.server.requests, isEmpty);

    // Explicit "Xem lại và tham gia" asks again.
    await tester.tap(find.byKey(const ValueKey('consent-gate-action')));
    await settle(tester);
    expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('"Đồng ý và tiếp tục": persisted, auth call, feed loads', (
    tester,
  ) async {
    env.server.json(
      'GET /v1/posts',
      page([postJson('p1', body: 'Chào cả nhà')]),
    );
    await _openTab(tester, env);
    expect(env.server.requests, isEmpty);

    await tester.tap(find.byKey(const ValueKey('consent-agree')));
    await settle(tester, frames: 30);

    expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
    expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
    expect(find.text('Chào cả nhà'), findsOneWidget);
    expect(find.text(CommunityStrings.consentGateTitle), findsNothing);
    await unmount(tester);
  });

  testWidgets('the links open the privacy policy and the guidelines', (
    tester,
  ) async {
    final opened = <String>[];
    await pumpCommunity(
      tester,
      env,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => ensureCommunityConsent(
                context,
                meAccount,
                onOpenDocument: (context, id) => opened.add(id),
              ),
              child: const Text('mở'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('consent-privacy')));
    await tester.tap(find.byKey(const ValueKey('consent-guidelines')));
    expect(opened, ['privacy', 'community']);
    await unmount(tester);
  });

  testWidgets('no overflow at 360 dp × 2.0', (tester) async {
    await pumpCommunityRouter(
      tester,
      env,
      routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
      initialLocation: CommunityRoutes.root,
      size: const Size(360, 800),
      textScale: 2,
    );
    await settle(tester);
    expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  group('actions ask first', () {
    testWidgets('voting for a skin asks before any network call', (
      tester,
    ) async {
      env.server
        ..json('GET /v1/skins/votes', {
          'items': [
            {'skinUuid': reaverSkin, 'votes': 4},
          ],
        })
        ..json('PUT /v1/skins/*/vote', {
          'skinUuid': reaverSkin,
          'votes': 5,
          'voted': true,
        });
      await pumpCommunity(
        tester,
        env,
        const Scaffold(body: SkinVoteButton(skinUuid: reaverSkin)),
      );
      await settle(tester);
      expect(find.text('4'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.vote));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      expect(env.server.calls('PUT /v1/skins/*/vote'), isEmpty);
      expect(env.server.calls('POST /v1/auth/riot'), isEmpty);

      await tester.tap(find.byKey(const ValueKey('consent-agree')));
      await settle(tester, frames: 30);
      expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
      expect(env.server.calls('PUT /v1/skins/*/vote'), hasLength(1));
      await unmount(tester);
    });

    testWidgets('declining a vote prompt does nothing', (tester) async {
      env.server.json('GET /v1/skins/votes', {
        'items': [
          {'skinUuid': reaverSkin, 'votes': 4},
        ],
      });
      await pumpCommunity(
        tester,
        env,
        const Scaffold(body: SkinVoteButton(skinUuid: reaverSkin)),
      );
      await settle(tester);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.vote));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('consent-later')));
      await settle(tester, frames: 20);

      expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
      expect(find.text('4'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('Trang chủ previews never ask and never sign in', () {
    testWidgets(
      'LFG preview is hidden without consent; trending is anonymous',
      (tester) async {
        env.server
          ..json('GET /v1/lfg', page([lfgJson('a')]))
          ..json('GET /v1/skins/top', {
            'items': [
              {'rank': 1, 'skinUuid': reaverSkin, 'votes': 9},
            ],
          });
        await pumpCommunityRouter(
          tester,
          env,
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                body: Column(
                  children: [
                    LfgPreviewCard(puuid: mePuuid),
                    TrendingSkinsCard(),
                  ],
                ),
              ),
            ),
          ],
        );
        await settle(tester);

        expect(find.text(CommunityStrings.lfgPreviewTitle), findsNothing);
        expect(find.text(CommunityStrings.trendingTitle), findsOneWidget);
        expect(find.text(CommunityStrings.consentTitle), findsNothing);
        expect(env.server.calls('GET /v1/lfg'), isEmpty);
        expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
        verifyNever(() => env.sessions.session(any()));
        await unmount(tester);
      },
    );

    testWidgets('with consent the LFG preview appears', (tester) async {
      final consented = await CommunityTestEnv.create();
      consented.server.json('GET /v1/lfg', page([lfgJson('a')]));
      await pumpCommunity(
        tester,
        consented,
        const Scaffold(body: LfgPreviewCard(puuid: mePuuid)),
      );
      await settle(tester);
      expect(find.text(CommunityStrings.lfgPreviewTitle), findsOneWidget);
      await unmount(tester);
    });
  });
}
