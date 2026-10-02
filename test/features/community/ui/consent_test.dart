import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/geo/countries.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/features/community/community_previews.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_exception.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/providers/scope_providers.dart';
import 'package:valvn/features/community/ui/consent/consent_sheet.dart';
import 'package:valvn/features/community/ui/skins/skin_review_screen.dart';
import 'package:valvn/features/community/ui/skins/skin_vote_button.dart';

import '../community_test_env.dart';
import '../data/skin_review_test.dart' show reviewJson, summaryJson;

Future<void> _openTab(
  WidgetTester tester,
  CommunityTestEnv env, {
  String location = CommunityRoutes.root,
  Size size = const Size(360, 1600),
  double textScale = 1,
}) async {
  await pumpCommunityRouter(
    tester,
    env,
    routes: [
      ...communityBranchRoutes,
      ...communityTopLevelRoutes,
      GoRoute(
        path: '/settings/about/:doc',
        builder: (context, state) => const Scaffold(body: Text('legal')),
      ),
    ],
    initialLocation: location,
    size: size,
    textScale: textScale,
  );
  await settle(tester);
}

void _servePublic(CommunityTestEnv env) {
  env.server
    ..json('POST /v1/auth/riot', sessionJson(country: 'VN'))
    ..json(
      'GET /v1/posts',
      page([postJson('p1', body: 'Bài công khai', likes: 3)]),
    )
    ..json('GET /v1/posts/p1', postJson('p1', body: 'Bài công khai'))
    ..json(
      'GET /v1/posts/p1/comments',
      page([commentJson('c1', body: 'Bình luận công khai')]),
    )
    ..json('GET /v1/skins/top', {
      'items': [
        {'rank': 1, 'skinUuid': reaverSkin, 'votes': 12},
      ],
    })
    ..json('GET /v1/skins/*/summary', summaryJson())
    ..json('GET /v1/skins/*/reviews', page([reviewJson('r1', body: 'Đẹp')]))
    ..json('GET /v1/skins/votes', {
      'items': [
        {'skinUuid': reaverSkin, 'votes': 4},
      ],
    })
    ..json('GET /v1/communities', {
      'items': [
        {'country': 'JP', 'posts': 3, 'authors': 2},
      ],
    });
}

/// No request carried a token, and Riot was never asked for one.
void _expectAnonymous(CommunityTestEnv env) {
  expect(env.server.requests, isNotEmpty);
  expect(
    env.server.requests.map((r) => r.authorization),
    everyElement(isNull),
    reason: 'no Authorization header',
  );
  expect(env.server.calls('POST /v1/auth/riot'), isEmpty);
  verifyNever(() => env.sessions.session(any()));
}

Future<void> _agree(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('consent-agree')));
  await settle(tester, frames: 30);
}

Future<void> _later(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('consent-later')));
  await settle(tester, frames: 20);
}

void main() {
  late CommunityTestEnv env;
  late Map<String, CountryInfo> countries;
  late CountryNames countryNames;
  setUpAll(() async {
    final assets = ProviderContainer();
    try {
      countries = await assets.read(countriesProvider.future);
      countryNames = await assets.read(countryNamesProvider.future);
    } finally {
      assets.dispose();
    }
  });
  setUp(() async {
    env = await CommunityTestEnv.create(consent: false);
    env.extraOverrides = [
      countriesProvider.overrideWith((ref) async => countries),
      countryNamesProvider.overrideWith((ref) async => countryNames),
    ];
    _servePublic(env);
  });

  test(
    'the consent pref lives under acct.<puuid>. (wiped with the account)',
    () {
      expect(
        communityConsentKey(mePuuid.toUpperCase()),
        startsWith(PrefKeys.accountPrefix(mePuuid)),
      );
    },
  );

  test('anonymous scope defaults follow the server', () {
    // Feed default = country; unauthenticated → global.
    expect(
      resolveScope(
        ScopeFilter.mineCountry,
        myCountry: null,
        myRegion: 'ap',
        anonymous: true,
      ),
      ScopeFilter.global,
    );
    // An explicit country / region stays.
    expect(
      resolveScope(
        const ScopeFilter(scope: CommunityScope.country, country: 'JP'),
        myCountry: null,
        myRegion: 'ap',
        anonymous: true,
      ).country,
      'JP',
    );
    expect(
      resolveScope(
        ScopeFilter.mineRegion,
        myCountry: null,
        myRegion: 'eu',
        anonymous: true,
      ).region,
      'eu',
    );
  });

  group('data layer', () {
    test('reads are anonymous even with a stored session but no consent', () async {
      env.secure.values[SecureKeys.community(mePuuid)] =
          '{"token":"stale","expiresAt":"${now.add(const Duration(days: 9)).toIso8601String()}","user":{"id":"$meId"}}';
      final container = env.container();
      final api = container.read(communityApiProvider);

      await api.posts(mePuuid);
      await api.skinSummary(reaverSkin, puuid: mePuuid);
      await api.communities(puuid: mePuuid);

      _expectAnonymous(env);
    });

    test(
      'writes and LFG lists throw consentRequired before any request',
      () async {
        final api = env.container().read(communityApiProvider);
        Matcher needsConsent() => throwsA(
          isA<CommunityException>().having(
            (e) => e.code,
            'code',
            CommunityException.consentRequired,
          ),
        );

        await expectLater(api.lfg(mePuuid, region: 'ap'), needsConsent());
        await expectLater(
          api.createPost(mePuuid, kind: PostKind.text, body: 'x'),
          needsConsent(),
        );
        await expectLater(
          api.setLiked(mePuuid, 'p1', liked: true),
          needsConsent(),
        );
        await expectLater(
          api.putReview(mePuuid, reaverSkin, rating: 5),
          needsConsent(),
        );
        expect(env.server.requests, isEmpty);
        verifyNever(() => env.sessions.session(any()));
      },
    );

    test('after the user agrees, the token is used', () async {
      final container = env.container();
      await container.read(communityConsentProvider(mePuuid).notifier).grant();

      await container.read(communityApiProvider).posts(mePuuid);

      expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
      expect(
        env.server.calls('GET /v1/posts').single.authorization,
        'Bearer community-1',
      );
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
    });

    test(
      'consent is wiped with the account and asked again after re-adding',
      () async {
        // Sign-out now verifies retained-history erasure as well. Keep this
        // consent test independent of the native application directory.
        final container = ProviderContainer.test(
          overrides: env.overrides,
          retry: (_, _) => null,
        );
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

  test(
    'consent to an older terms version never authorizes Riot-token sharing',
    () async {
      await env.prefs.setString(communityConsentKey(mePuuid), 'granted');
      await env.prefs.setString(communityConsentVersionKey(mePuuid), 'old');
      final container = env.container();
      expect(
        container.read(communityConsentProvider(mePuuid)),
        CommunityConsent.unknown,
      );
      expect(
        container.read(communityAuthProvider).hasConsent(mePuuid),
        isFalse,
      );
      await container.read(communityConsentProvider(mePuuid).notifier).grant();
      expect(
        env.prefs.getString(communityConsentVersionKey(mePuuid)),
        communityConsentVersion,
      );
      expect(
        DateTime.tryParse(env.prefs.getString(communityConsentAtKey(mePuuid))!),
        isNotNull,
      );
    },
  );

  group('browsing without joining', () {
    testWidgets('empty global feed stays anonymous with a compact join hint', (
      tester,
    ) async {
      env.server.json('GET /v1/posts', page([]));
      await _openTab(tester, env);
      expect(find.text(CommunityStrings.feedEmptyTitle), findsOneWidget);
      expect(find.text(CommunityStrings.feedEmptyGuestBody), findsOneWidget);
      expect(find.text(CommunityStrings.feedEmptyBody), findsNothing);
      expect(find.text(CommunityStrings.feedEmptyScopeBody), findsNothing);
      expect(find.text(CommunityStrings.privacyNote), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('anonymous-banner'))).height,
        lessThanOrEqualTo(90),
        reason:
            'Banner ${tester.getSize(find.byKey(const ValueKey("anonymous-banner")))}; scaler ${MediaQuery.textScalerOf(tester.element(find.byKey(const ValueKey("anonymous-banner")))).scale(14)}',
      );
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('the tab opens on the feed, anonymously, with the banner', (
      tester,
    ) async {
      await _openTab(tester, env);

      // No sheet by itself; the feed is there.
      expect(find.text(CommunityStrings.consentTitle), findsNothing);
      expect(find.text('Bài công khai'), findsOneWidget);
      expect(find.text(CommunityStrings.anonymousBanner), findsOneWidget);
      expect(find.text(CommunityStrings.consentGateAction), findsOneWidget);
      // Server default when unauthenticated: the whole world.
      final q = env.server.calls('GET /v1/posts').single.query;
      expect(q['scope'], 'global');
      expect(q.containsKey('country'), isFalse);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('Xếp hạng skin is anonymous too', (tester) async {
      await _openTab(tester, env, location: '/community?section=skins');
      expect(find.text('Vandal Reaver'), findsOneWidget);
      expect(
        env.server.calls('GET /v1/skins/top').single.query['scope'],
        'global',
      );
      expect(find.text(CommunityStrings.anonymousBanner), findsOneWidget);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('"Cộng đồng các nước" is anonymous', (tester) async {
      await _openTab(tester, env);
      await chooseCommunityScope(tester, 'countries');
      await settle(tester);
      expect(find.text('Nhật Bản'), findsOneWidget);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('a post and its comments are readable', (tester) async {
      await _openTab(tester, env, location: '/post/p1');
      expect(find.text('Bài công khai'), findsOneWidget);
      expect(find.text('Bình luận công khai'), findsOneWidget);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('a skin review page is readable', (tester) async {
      await pumpCommunity(
        tester,
        env,
        const SkinReviewScreen(skinUuid: reaverSkin),
        size: const Size(360, 2200),
      );
      await settle(tester);
      expect(find.text('Đẹp'), findsOneWidget);
      expect(find.text('4,6'), findsOneWidget);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('"Để sau" never hides browsing', (tester) async {
      await _openTab(tester, env);
      await tester.tap(find.text(CommunityStrings.consentGateAction));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      await _later(tester);

      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'declined');
      expect(find.text('Bài công khai'), findsOneWidget);
      expect(find.text(CommunityStrings.anonymousBanner), findsOneWidget);
      _expectAnonymous(env);
      await unmount(tester);

      // Next launch: still browsing, still no sheet by itself.
      await _openTab(tester, env);
      expect(find.text(CommunityStrings.consentTitle), findsNothing);
      expect(find.text('Bài công khai'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('the banner\'s button joins: token, country scope, no banner', (
      tester,
    ) async {
      await _openTab(tester, env);
      await tester.tap(find.text(CommunityStrings.consentGateAction));
      await settle(tester);
      // The sheet explains what is sent and what others see.
      expect(find.text(CommunityStrings.consentVerify), findsOneWidget);
      expect(find.text(CommunityStrings.consentPublic), findsOneWidget);
      await _agree(tester);

      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
      final last = env.server.calls('GET /v1/posts').last;
      expect(last.authorization, 'Bearer community-1');
      expect((last.query['scope'], last.query['country']), ('country', 'VN'));
      expect(find.text(CommunityStrings.anonymousBanner), findsNothing);
      expect(find.text('Bài công khai'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a remembered LFG section opens on the feed instead', (
      tester,
    ) async {
      await env.prefs.setString(PrefKeys.ui('community.section'), 'lfg');
      await _openTab(tester, env, location: '/community');
      expect(find.text('Bài công khai'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('joined users', () {
    testWidgets('the tab opens directly on the feed, with a token, no banner', (
      tester,
    ) async {
      final joined = await CommunityTestEnv.create();
      _servePublic(joined);
      await _openTab(tester, joined);

      expect(find.text(CommunityStrings.consentTitle), findsNothing);
      expect(find.text(CommunityStrings.anonymousBanner), findsNothing);
      expect(find.text('Bài công khai'), findsOneWidget);
      final q = joined.server.calls('GET /v1/posts').single;
      expect(q.authorization, 'Bearer community-1');
      expect((q.query['scope'], q.query['country']), ('country', 'VN'));
      await unmount(tester);
    });
  });

  group('writing asks first', () {
    testWidgets('like: sheet → declined = no request', (tester) async {
      env.server.json('PUT /v1/posts/p1/like', {'likes': 4, 'liked': true});
      await _openTab(tester, env);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.like));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      await _later(tester);

      expect(env.server.calls('PUT /v1/posts/p1/like'), isEmpty);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('like: agree → the like goes through with a token', (
      tester,
    ) async {
      env.server.json('PUT /v1/posts/p1/like', {'likes': 4, 'liked': true});
      await _openTab(tester, env);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.like));
      await settle(tester);
      await _agree(tester);

      final put = env.server.calls('PUT /v1/posts/p1/like');
      expect(put, hasLength(1));
      expect(put.single.authorization, 'Bearer community-1');
      await unmount(tester);
    });

    testWidgets('new post: the sheet comes before the composer', (
      tester,
    ) async {
      await _openTab(tester, env);

      await tester.tap(find.text(CommunityStrings.newPost));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      await _later(tester);
      expect(find.text(CommunityStrings.composerTitle), findsNothing);
      expect(env.server.calls('POST /v1/posts'), isEmpty);

      await tester.tap(find.text(CommunityStrings.newPost));
      await settle(tester);
      await _agree(tester);
      expect(find.text(CommunityStrings.composerTitle), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('report: the sheet comes before the reason picker', (
      tester,
    ) async {
      env.server.json('POST /v1/reports', null, status: 204);
      await _openTab(tester, env);

      await tester.tap(find.byTooltip(CommunityStrings.moreActions).first);
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.report));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      expect(find.text(CommunityStrings.reportTitle), findsNothing);
      await _later(tester);

      expect(find.text(CommunityStrings.reportTitle), findsNothing);
      expect(env.server.calls('POST /v1/reports'), isEmpty);
      await unmount(tester);
    });

    testWidgets('comment: sheet → agree → the comment is posted', (
      tester,
    ) async {
      env.server.json(
        'POST /v1/posts/p1/comments',
        commentJson('c9', body: 'Mới'),
      );
      await _openTab(tester, env, location: '/post/p1');

      await tester.enterText(find.byType(TextField), 'Mới');
      await tester.pump();
      await tester.tap(find.byTooltip(CommunityStrings.sendComment));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      expect(env.server.calls('POST /v1/posts/p1/comments'), isEmpty);

      await _agree(tester);
      final post = env.server.calls('POST /v1/posts/p1/comments');
      expect(post, hasLength(1));
      expect(post.single.authorization, 'Bearer community-1');
      await unmount(tester);
    });

    testWidgets('comment: declined = nothing is sent, the text stays', (
      tester,
    ) async {
      await _openTab(tester, env, location: '/post/p1');
      await tester.enterText(find.byType(TextField), 'Mới');
      await tester.pump();
      await tester.tap(find.byTooltip(CommunityStrings.sendComment));
      await settle(tester);
      await _later(tester);

      expect(env.server.calls('POST /v1/posts/p1/comments'), isEmpty);
      expect(find.text('Mới'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('skin vote: sheet first, declined = no vote', (tester) async {
      await pumpCommunity(
        tester,
        env,
        const Scaffold(body: SkinVoteButton(skinUuid: reaverSkin)),
      );
      await settle(tester);

      await tester.tap(find.bySemanticsLabel(CommunityStrings.vote));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      await _later(tester);

      expect(env.server.calls('PUT /v1/skins/*/vote'), isEmpty);
      expect(find.text('4'), findsOneWidget);
      _expectAnonymous(env);
      await unmount(tester);
    });

    testWidgets('review: tapping a star asks before the editor', (
      tester,
    ) async {
      await pumpCommunity(
        tester,
        env,
        const SkinReviewScreen(skinUuid: reaverSkin),
        size: const Size(360, 2200),
      );
      await settle(tester);

      await tester.tap(find.byKey(const ValueKey('star-4')).first);
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      await _later(tester);
      expect(find.text(CommunityStrings.saveReview), findsNothing);
      expect(env.server.calls('PUT /v1/skins/*/review'), isEmpty);
      await unmount(tester);
    });

    testWidgets('"Hữu ích" on a review asks first', (tester) async {
      await pumpCommunity(
        tester,
        env,
        const SkinReviewScreen(skinUuid: reaverSkin),
        size: const Size(360, 2200),
      );
      await settle(tester);

      await tester.tap(find.text(CommunityStrings.helpful));
      await settle(tester);
      expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
      await _later(tester);
      expect(env.server.calls('PUT /v1/reviews/*/like'), isEmpty);
      await unmount(tester);
    });
  });

  group('Tìm đồng đội needs a session', () {
    testWidgets('a join card instead of the lists; nothing is requested', (
      tester,
    ) async {
      env.server.json('GET /v1/lfg', page([lfgJson('l1')]));
      await _openTab(tester, env, location: '/community?section=lfg');

      expect(find.text(CommunityStrings.lfgGateTitle), findsOneWidget);
      expect(find.text(CommunityStrings.createLfgShort), findsNothing);
      expect(find.text(CommunityStrings.anonymousBanner), findsNothing);
      // Nothing at all is requested: no LFG list, no token, no auth call.
      expect(env.server.requests, isEmpty);
      verifyNever(() => env.sessions.session(any()));
      await unmount(tester);
    });

    testWidgets('joining from the card loads the lists', (tester) async {
      env.server.json(
        'GET /v1/lfg',
        page([lfgJson('l1', note: 'Cần 1 người')]),
      );
      await _openTab(tester, env, location: '/community?section=lfg');

      await tester.tap(find.byKey(const ValueKey('lfg-join-gate-action')));
      await settle(tester);
      await _agree(tester);

      expect(find.text('Cần 1 người'), findsOneWidget);
      final get = env.server.calls('GET /v1/lfg');
      expect(get, isNotEmpty);
      expect(get.last.authorization, 'Bearer community-1');
      expect(find.text(CommunityStrings.createLfgShort), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('declining keeps the card and sends nothing', (tester) async {
      env.server.json('GET /v1/lfg', page([lfgJson('l1')]));
      await _openTab(tester, env, location: '/community?section=lfg');
      await tester.tap(find.byKey(const ValueKey('lfg-join-gate-action')));
      await settle(tester);
      await _later(tester);
      expect(find.text(CommunityStrings.lfgGateTitle), findsOneWidget);
      expect(env.server.calls('GET /v1/lfg'), isEmpty);
      await unmount(tester);
    });
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

  testWidgets('no overflow at 360 dp × 2.0 (banner and sheet)', (tester) async {
    await _openTab(tester, env, size: const Size(360, 2400), textScale: 2);
    expect(find.text(CommunityStrings.anonymousBanner), findsOneWidget);
    await tester.tap(find.text(CommunityStrings.consentGateAction));
    await settle(tester);
    expect(find.text(CommunityStrings.consentTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  group('Trang chủ previews never ask and never sign in', () {
    testWidgets(
      'LFG preview is hidden without consent; trending is anonymous',
      (tester) async {
        env.server.json('GET /v1/lfg', page([lfgJson('a')]));
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
        _expectAnonymous(env);
        await unmount(tester);
      },
    );

    testWidgets('with consent and a session the LFG preview appears', (
      tester,
    ) async {
      final consented = await CommunityTestEnv.create();
      // The Cộng đồng tab signed in earlier: the preview only reuses it.
      consented.secure.values[SecureKeys.community(mePuuid)] = jsonEncode(
        sessionJson(),
      );
      consented.server.json('GET /v1/lfg', page([lfgJson('a')]));
      await pumpCommunity(
        tester,
        consented,
        const Scaffold(body: LfgPreviewCard(puuid: mePuuid)),
      );
      await settle(tester);
      expect(find.text(CommunityStrings.lfgPreviewTitle), findsOneWidget);
      expect(consented.server.calls('POST /v1/auth/riot'), isEmpty);
      await unmount(tester);
    });

    testWidgets('with consent but no session it stays hidden and silent', (
      tester,
    ) async {
      final consented = await CommunityTestEnv.create();
      consented.server.json('GET /v1/lfg', page([lfgJson('a')]));
      await pumpCommunity(
        tester,
        consented,
        const Scaffold(body: LfgPreviewCard(puuid: mePuuid)),
      );
      await settle(tester);
      expect(find.text(CommunityStrings.lfgPreviewTitle), findsNothing);
      // Never signs in: the Riot token stays on the device.
      expect(consented.server.requests, isEmpty);
      await unmount(tester);
    });
  });
}
