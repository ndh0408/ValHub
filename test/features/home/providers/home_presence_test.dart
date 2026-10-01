import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/xmpp/xmpp_providers.dart';
import 'package:valvn/features/community/community_previews.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/providers/home_arrangement.dart';
import 'package:valvn/features/home/providers/home_card_providers.dart';
import 'package:valvn/features/home/providers/home_layout_provider.dart';

import '../../community/community_test_env.dart' as community;
import '../../profile/profile_test_env.dart'
    show competitiveFixtureMap, testContent;
import '../home_test_env.dart';

const _puuid = Fx.puuid;

/// A container over [env] that keeps [providers] alive.
ProviderContainer _container(
  HomeTestEnv env, [
  List<Override> extra = const [],
]) {
  final c = ProviderContainer.test(
    overrides: [...env.overrides, ...extra],
    retry: (_, _) => null,
  );
  return c;
}

/// Listens to [card]'s presence (the provider is auto-dispose) and lets the
/// futures behind it settle.
Future<HomeCardPresence> _settled(ProviderContainer c, HomeCardId card) async {
  final sub = c.listen(
    homeCardPresenceProvider((puuid: _puuid, card: card)),
    (_, _) {},
  );
  addTearDown(sub.close);
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  return sub.read();
}

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create();
  });

  group('store (core card)', () {
    void stubWallet() =>
        when(() => env.api.wallet(any()))
            .thenAnswer((_) async => economyFixture('wallet.json'));

    test('loading → skeleton, data → visible', () async {
      final gate = Completer<Map<String, dynamic>>();
      when(() => env.api.storefront(any())).thenAnswer((_) => gate.future);
      stubWallet();
      final c = _container(env);
      expect(await _settled(c, HomeCardId.store), HomeCardPresence.loading);

      gate.complete(economyFixture('storefront.json'));
      expect(await _settled(c, HomeCardId.store), HomeCardPresence.visible);
    });

    test('an error without data is still shown (a compact error)', () async {
      when(() => env.api.storefront(any()))
          .thenAnswer((_) async => throw const TransientException(reason: 'x'));
      stubWallet();
      expect(
        await _settled(_container(env), HomeCardId.store),
        HomeCardPresence.visible,
      );
    });

    test('a blocking maintenance hides it when it has no data', () async {
      when(() => env.api.storefront(any()))
          .thenAnswer((_) async => throw const TransientException(reason: 'x'));
      stubWallet();
      when(() => env.api.platformStatus(any())).thenAnswer(
        (_) async => {
          'maintenances': [
            {
              'id': 'm',
              'maintenance_status': 'in_progress',
              'titles': [
                {'locale': 'vi_VN', 'content': 'Bảo trì'},
              ],
            },
          ],
        },
      );
      final c = _container(env);
      // Keep the status alive so the error card can tell it is blocking.
      final status = c.listen(homeServerStatusProvider, (_, _) {});
      addTearDown(status.close);
      await Future<void>.delayed(Duration.zero);
      expect(await _settled(c, HomeCardId.store), HomeCardPresence.hidden);
    });

    test('nothing on sale and no Night Market: hidden', () async {
      when(() => env.api.storefront(any()))
          .thenAnswer((_) async => <String, dynamic>{});
      stubWallet();
      expect(
        await _settled(_container(env), HomeCardId.store),
        HomeCardPresence.hidden,
      );
    });
  });

  group('rank (core card)', () {
    final summary = buildRankSummary(
      testContent(),
      PlayerMmr.fromJson(competitiveFixtureMap('mmr')),
      now: homeNow,
    );

    test('loading, data, never ranked and error', () async {
      final gate = Completer<RankSummary>();
      final c = _container(env, [
        rankSummaryProvider.overrideWith((ref, puuid) => gate.future),
        rrHistoryProvider.overrideWith(
          (ref, puuid) async => RrHistory(puuid: puuid),
        ),
        rankUpEstimateProvider.overrideWith((ref, q) async => null),
      ]);
      expect(await _settled(c, HomeCardId.rank), HomeCardPresence.loading);
      gate.complete(summary);
      expect(await _settled(c, HomeCardId.rank), HomeCardPresence.visible);

      final never = _container(env, [
        rankSummaryProvider.overrideWith(
          (ref, puuid) async => buildRankSummary(
            testContent(),
            PlayerMmr.fromJson({
              'QueueSkills': {
                'competitive': {'SeasonalInfoBySeasonID': <String, dynamic>{}},
              },
            }),
            now: homeNow,
          ),
        ),
        rrHistoryProvider.overrideWith(
          (ref, puuid) async => RrHistory(puuid: puuid),
        ),
        rankUpEstimateProvider.overrideWith((ref, q) async => null),
      ]);
      expect(await _settled(never, HomeCardId.rank), HomeCardPresence.hidden);

      final failing = _container(env, [
        rankSummaryProvider.overrideWith(
          (ref, puuid) async => throw const TransientException(reason: 'x'),
        ),
        rrHistoryProvider.overrideWith(
          (ref, puuid) async => RrHistory(puuid: puuid),
        ),
        rankUpEstimateProvider.overrideWith((ref, q) async => null),
      ]);
      expect(
        await _settled(failing, HomeCardId.rank),
        HomeCardPresence.visible,
      );
    });
  });

  group('Battle Pass (core card)', () {
    setUp(() {
      env.content = bpContent();
      when(() => env.api.dailyTicket(any()))
          .thenAnswer((_) async => dailyTicketJson());
    });

    test('data → visible; finished with no event → hidden', () async {
      when(() => env.api.contracts(any()))
          .thenAnswer((_) async => contractsJson());
      expect(
        await _settled(_container(env), HomeCardId.battlePass),
        HomeCardPresence.visible,
      );

      env.content = bpContent(withEvent: false);
      when(() => env.api.contracts(any())).thenAnswer(
        (_) async => contractsJson(level: 55, inLevel: 0, total: 1162500),
      );
      expect(
        await _settled(_container(env), HomeCardId.battlePass),
        HomeCardPresence.hidden,
      );
    });

    test('an error without data still shows the card', () async {
      when(() => env.api.contracts(any()))
          .thenAnswer((_) async => throw const TransientException(reason: 'x'));
      expect(
        await _settled(_container(env), HomeCardId.battlePass),
        HomeCardPresence.visible,
      );
    });
  });

  group('arrangement', () {
    List<Override> vmData() => vmFull(friends: false);

    test('a session that must sign in again hides the Riot cards', () async {
      final signedOut = await HomeTestEnv.create(
        accounts: [homeMe.copyWith(needsLogin: true), homeAlt1],
      );
      final c = _container(signedOut, vmData());
      final sub = c.listen(homeArrangementProvider(_puuid), (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      c.read(homeStartupGateProvider.notifier).open();
      await Future<void>.delayed(Duration.zero);

      final a = sub.read();
      expect(a.all, isNot(contains(HomeCardId.live)));
      expect(a.all, contains(HomeCardId.store));
      expect(a.all, isNot(contains(HomeCardId.rank)));
      expect(a.all, contains(HomeCardId.battlePass));
      expect(a.all, isNot(contains(HomeCardId.friends)));
      // Community, other accounts and the status are not tied to the session.
      expect(a.all, contains(HomeCardId.community));
      expect(a.all, contains(HomeCardId.otherAccounts));
    });

    test('a hidden card never calls its API', () async {
      when(() => env.api.storefront(any()))
          .thenAnswer((_) async => economyFixture('storefront.json'));
      when(() => env.api.wallet(any()))
          .thenAnswer((_) async => economyFixture('wallet.json'));
      await env.prefs.setJson(kHomeLayoutPrefKey, {
        'v': 1,
        'order': [for (final c in HomeCardId.values) c.storageId],
        'hidden': ['store', 'battlepass', 'rank', 'live'],
      });
      final c = _container(env);
      final sub = c.listen(homeArrangementProvider(_puuid), (_, _) {});
      addTearDown(sub.close);
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      verifyNever(() => env.api.storefront(any()));
      verifyNever(() => env.api.wallet(any()));
      verifyNever(() => env.api.contracts(any()));
      verifyNever(() => env.api.mmr(any(), subject: any(named: 'subject')));
      verifyNever(() => env.api.gameSession(any()));
    });

    test('deferred cards are not read before the gate opens', () async {
      var previews = 0;
      final c = _container(env, [
        vmLive(null),
        // The store keeps loading, so the startup gate stays closed.
        vmStore(const AsyncLoading()),
        vmRank(const AsyncData(null)),
        vmBp(const AsyncData(null)),
        vmOthers(null),
        vmStatus(null),
        // The real community snapshot over counting previews.
        matchingLfgPreviewProvider.overrideWith((ref, puuid) async {
          previews++;
          return const <LfgPost>[];
        }),
        trendingSkinsProvider.overrideWith((ref, period) async {
          previews++;
          return const <TopSkin>[];
        }),
      ]);
      final sub = c.listen(homeArrangementProvider(_puuid), (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      expect(previews, 0);
      expect(env.xmppCreated, 0);

      c.read(homeStartupGateProvider.notifier).open();
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(previews, greaterThan(0));
    });

    test('with no consent the chat service is never created', () async {
      final c = _container(env, [
        vmLive(null),
        vmStore(const AsyncData(null)),
        vmRank(const AsyncData(null)),
        vmBp(const AsyncData(null)),
        vmCommunity(const AsyncData(null)),
        vmOthers(null),
        vmStatus(null),
      ]);
      final sub = c.listen(homeArrangementProvider(_puuid), (_, _) {});
      addTearDown(sub.close);
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      c.read(homeStartupGateProvider.notifier).open();
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      // The prompt is on offer, but nothing connected.
      expect(sub.read().flow, contains(HomeCardId.friends));
      expect(c.exists(xmppServiceProvider), isFalse);
      expect(env.xmppCreated, 0);
    });

    test('a declined chat is never created either', () async {
      final declined = await HomeTestEnv.create(friendsConsent: false);
      final c = _container(declined, [
        vmLive(null),
        vmStore(const AsyncData(null)),
        vmRank(const AsyncData(null)),
        vmBp(const AsyncData(null)),
        vmCommunity(const AsyncData(null)),
        vmOthers(null),
        vmStatus(null),
      ]);
      final sub = c.listen(homeArrangementProvider(_puuid), (_, _) {});
      addTearDown(sub.close);
      c.read(homeStartupGateProvider.notifier).open();
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(sub.read().all, isNot(contains(HomeCardId.friends)));
      expect(declined.xmppCreated, 0);
    });
  });

  group('community previews stay silent', () {
    late community.CommunityTestEnv cenv;

    Future<void> readSnapshot(ProviderContainer c) async {
      final sub = c.listen(
        homeCommunitySnapshotProvider(community.mePuuid),
        (_, _) {},
      );
      addTearDown(sub.close);
      for (var i = 0; i < 30; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('no consent: only the anonymous trending request', () async {
      cenv = await community.CommunityTestEnv.create(consent: false);
      cenv.server
        ..json('GET /v1/lfg', community.page([community.lfgJson('a')]))
        ..json('GET /v1/skins/top', {
          'items': [
            {'rank': 1, 'skinUuid': community.reaverSkin, 'votes': 3},
          ],
        });
      await readSnapshot(cenv.container());

      expect(cenv.server.calls('GET /v1/lfg'), isEmpty);
      expect(cenv.server.calls('POST /v1/auth/riot'), isEmpty);
      final top = cenv.server.calls('GET /v1/skins/top').single;
      expect(top.authorization, isNull);
      verifyNever(() => cenv.sessions.session(any()));
    });

    test('consent but no cached session: still no sign-in', () async {
      cenv = await community.CommunityTestEnv.create();
      cenv.server
        ..json('GET /v1/lfg', community.page([community.lfgJson('a')]))
        ..json('GET /v1/skins/top', {'items': <Object>[]});
      await readSnapshot(cenv.container());

      expect(cenv.server.calls('GET /v1/lfg'), isEmpty);
      expect(cenv.server.calls('POST /v1/auth/riot'), isEmpty);
      verifyNever(() => cenv.sessions.session(any()));
    });

    test('a session the Community tab created is used, not renewed', () async {
      cenv = await community.CommunityTestEnv.create();
      cenv.secure.values[SecureKeys.community(community.mePuuid)] = jsonEncode(
        community.sessionJson(),
      );
      cenv.server
        ..json('GET /v1/lfg', community.page([community.lfgJson('a')]))
        ..json('GET /v1/skins/top', {'items': <Object>[]});
      await readSnapshot(cenv.container());

      expect(cenv.server.calls('POST /v1/auth/riot'), isEmpty);
      final lfg = cenv.server.calls('GET /v1/lfg').single;
      expect(lfg.authorization, 'Bearer community-1');
    });
  });
}
