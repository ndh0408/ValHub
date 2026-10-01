import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_data_warmup.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/accounts/local_data.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/competitive/account_xp.dart';
import 'package:valvn/core/domain/competitive/rank.dart';
import 'package:valvn/core/domain/economy/storefront.dart';
import 'package:valvn/core/domain/loadout/loadout_providers.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/battlepass/providers/battlepass_providers.dart';

import '../../helpers/test_prefs.dart';
import '../domain/competitive/competitive_test_utils.dart';
import '../domain/economy/economy_fixtures.dart';
import '../domain/loadout/loadout_fixtures.dart';

class _Sessions extends Mock implements SessionManager {}

class _Cache extends JsonFileCache {
  _Cache() : super(() => throw UnimplementedError());
  final entries = <String, CachedJson>{};
  @override
  Future<CachedJson?> read(String key) async => entries[key];
  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async {
    entries[key] = CachedJson(data, savedAt ?? DateTime(2026));
  }

  @override
  Future<void> deletePrefix(String prefix) async {
    entries.removeWhere((key, _) => key.startsWith(prefix));
  }
}

/// Records every call: unexpected mutations and cross-account calls fail the
/// assertions rather than being silently accepted by a broad mock.
class _Api implements PvpApi {
  final calls = <(Symbol, String)>[];
  final gates = <Symbol, Completer<JsonMap>>{};
  final failures = <Symbol>{};
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    final id = invocation.positionalArguments.first as String;
    calls.add((name, id));
    if (gates[name] case final gate?) return gate.future;
    if (failures.contains(name)) {
      return Future<JsonMap>.error(const TransientException(reason: 'offline'));
    }
    return Future<JsonMap>.value(switch (name) {
      #accountXp => {
        'Progress': {'Level': id == me ? 474 : 100, 'XP': 12},
      },
      #playerLoadout => {...loadoutJson(), 'Subject': id},
      #mmr => competitiveFixtureMap('mmr'),
      #wallet => {'Balances': <String, int>{}},
      #storefront || #contracts || #entitlements => <String, Object?>{},
      _ => throw StateError('Unexpected call: $name'),
    });
  }
}

Account _account(String id) => Account(
  puuid: id,
  gameName: 'Test',
  tagLine: 'QA',
  region: 'ap',
  shard: 'ap',
);

void main() {
  late Prefs prefs;
  late _Api api;
  late _Cache cache;
  late FixedClock clock;
  late _Sessions sessions;

  setUp(() async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      _account(me).toJson(),
      _account(mate).toJson(),
    ]);
    await prefs.setString(PrefKeys.activePuuid, me);
    api = _Api();
    cache = _Cache();
    clock = FixedClock(DateTime.utc(2026, 9, 28, 12));
    sessions = _Sessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
  });

  ProviderContainer container() => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(MemorySecureStore()),
      sessionManagerProvider.overrideWithValue(sessions),
      pvpApiProvider.overrideWithValue(api),
      jsonFileCacheProvider.overrideWithValue(cache),
      retainedHistoryFilesProvider.overrideWithValue(cache),
      contentProvider.overrideWith((ref) async => testContent()),
      clockProvider.overrideWithValue(clock),
    ],
  );

  test(
    'identity persists card, real XP level and rank without visiting a screen',
    () async {
      final c = container();
      await c.read(accountDataWarmupProvider).identity(me);
      await pumpEventQueue();
      final account = c.read(accountProvider(me))!;
      expect(account.cardId, Fx.cardNgoiSang);
      expect(account.level, 474);
      expect(account.rankTier, 18);
      expect(account.rankSeasonId, actV);
      expect(c.read(accountRepositoryProvider).find(me)?.level, 474);
      expect(c.read(accountProvider(mate))!.level, isNull);
      expect(api.calls.map((v) => v.$1).toSet(), {
        #accountXp,
        #playerLoadout,
        #mmr,
      });
    },
  );

  test(
    'preload and screen requests share their in-flight requests and TTLs',
    () async {
      final c = container();
      final warm = c.read(accountDataWarmupProvider);
      await Future.wait([warm.identity(me), warm.pages(me), warm.pages(me)]);
      await Future.wait<Object?>([
        c.read(accountXpProvider(me).future),
        c.read(mmrProvider(me).future),
        c.read(loadoutProvider(me).future),
        c.read(walletProvider(me).future),
        c.read(storefrontProvider(me).future),
      ]);
      for (final endpoint in [
        #accountXp,
        #mmr,
        #playerLoadout,
        #wallet,
        #storefront,
        #contracts,
      ]) {
        expect(api.calls.where((v) => v == (endpoint, me)), hasLength(1));
      }
      expect(api.calls.every((v) => v.$2 == me), isTrue);
      expect(
        cache.entries.keys,
        contains(JsonFileCache.accountKey(me, 'economy_wallet')),
      );
    },
  );

  test(
    'one failed request preserves metadata and the other pages still load',
    () async {
      final c = container();
      await c
          .read(accountsProvider.notifier)
          .updateAccount(me, (a) => a.copyWith(level: 123));
      api.failures.add(#accountXp);
      await c.read(accountDataWarmupProvider).pages(me);
      await pumpEventQueue();
      final account = c.read(accountProvider(me))!;
      expect(account.level, 123);
      expect(account.cardId, Fx.cardNgoiSang);
      expect(api.calls, contains((#wallet, me)));
      expect(api.calls, contains((#entitlements, me)));
    },
  );

  test(
    'missing, expired and unresolved-region accounts make no requests',
    () async {
      final c = container();
      await c
          .read(accountsProvider.notifier)
          .updateAccount(me, (a) => a.copyWith(needsLogin: true));
      await c
          .read(accountsProvider.notifier)
          .updateAccount(mate, (a) => a.copyWith(region: ''));
      final warm = c.read(accountDataWarmupProvider);
      await Future.wait([
        warm.pages(me),
        warm.identity(mate),
        warm.pages(enemy1),
      ]);
      expect(api.calls, isEmpty);
    },
  );

  test('switching accounts preloads with each account own identity', () async {
    final c = container();
    final warm = c.read(accountDataWarmupProvider);
    await warm.pages(me);
    c.read(activePuuidProvider.notifier).select(mate);
    await warm.pages(mate);
    await pumpEventQueue();
    expect(c.read(accountProvider(mate))!.level, 100);
    expect(c.read(accountProvider(me))!.level, 474);
    expect(api.calls.where((v) => v == (#accountXp, mate)), hasLength(1));
    expect(api.calls.where((v) => v == (#accountXp, me)), hasLength(1));
  });

  test('reauthentication refreshes already healthy cached providers', () async {
    final c = container();
    final warm = c.read(accountDataWarmupProvider);
    await warm.pages(me);
    await warm.afterLogin(me);
    await warm.pages(me);
    expect(api.calls.where((v) => v == (#accountXp, me)), hasLength(2));
    expect(api.calls.where((v) => v == (#wallet, me)), hasLength(2));
  });

  test('failed XP is not pinned for five minutes after warmup', () async {
    final c = container();
    api.failures.add(#accountXp);
    await c.read(accountDataWarmupProvider).identity(me);
    await c.pump();
    api.failures.clear();
    expect((await c.read(accountXpProvider(me).future)).level, 474);
    expect(api.calls.where((v) => v == (#accountXp, me)), hasLength(2));
  });

  test(
    'loadout and missions recover on opening after an offline preload',
    () async {
      final c = container();
      api.failures.addAll([#playerLoadout, #contracts]);
      await c.read(accountDataWarmupProvider).pages(me);
      await c.pump();
      api.failures.clear();
      final loadout = await c.read(loadoutProvider(me).future);
      final missions = await c.read(playerContractsProvider(me).future);
      expect(loadout.loadout.version, 25);
      expect(missions.isFromCache, isFalse);
      expect(api.calls.where((v) => v == (#playerLoadout, me)), hasLength(2));
      expect(api.calls.where((v) => v == (#contracts, me)), hasLength(2));
    },
  );

  test('changing the connection region reloads the account caches', () async {
    final c = container();
    final warm = c.read(accountDataWarmupProvider);
    await warm.pages(me);
    await c
        .read(accountsProvider.notifier)
        .updateAccount(me, (a) => a.copyWith(region: 'eu'));
    await warm.pages(me);
    expect(api.calls.where((v) => v == (#accountXp, me)), hasLength(2));
    expect(api.calls.where((v) => v == (#wallet, me)), hasLength(2));
    expect(api.calls.where((v) => v == (#storefront, me)), hasLength(2));
  });

  test(
    'a new login reuses preloading already started by the root host',
    () async {
      final c = container();
      final warm = c.read(accountDataWarmupProvider);
      final rootLoading = warm.pages(me);
      await warm.afterLogin(me, refresh: false);
      await rootLoading;
      expect(api.calls.where((v) => v == (#accountXp, me)), hasLength(1));
      expect(api.calls.where((v) => v == (#wallet, me)), hasLength(1));
    },
  );

  testWidgets('root preloads active pages and staggered inactive identity', (
    tester,
  ) async {
    final c = container();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const AccountDataWarmupHost(child: SizedBox()),
      ),
    );
    await tester.pump();
    await c.read(accountDataWarmupProvider).pages(me);
    expect(api.calls.where((v) => v.$2 == mate), isEmpty);
    await tester.pump(const Duration(milliseconds: 500));
    await c.read(accountDataWarmupProvider).identity(mate);
    await tester.pump();
    expect(c.read(accountProvider(mate))!.level, 100);
    expect(api.calls, isNot(contains((#wallet, mate))));
    c.read(activePuuidProvider.notifier).select(mate);
    await tester.pump();
    await c.read(accountDataWarmupProvider).pages(mate);
    expect(api.calls, contains((#wallet, mate)));
    expect(api.calls.where((v) => v == (#accountXp, mate)), hasLength(1));
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });

  test('removing an account during loading cannot resurrect it or preload its pages', () async {
    final c = container();
    final gate = Completer<JsonMap>();
    api.gates[#accountXp] = gate;
    final loading = c.read(accountDataWarmupProvider).pages(me);
    await pumpEventQueue();
    await c.read(accountRepositoryProvider).removeMetadata(me);
    await c.read(accountRepositoryProvider).wipeAccountData(me);
    c.read(accountsProvider.notifier).reload();
    gate.complete({
      'Progress': {'Level': 999},
    });
    await loading;
    await pumpEventQueue();
    expect(c.read(accountProvider(me)), isNull);
    expect(c.read(accountRepositoryProvider).find(me), isNull);
    expect(api.calls, isNot(contains((#wallet, me))));
  });

  testWidgets('slow identity does not hold login longer than two seconds', (
    tester,
  ) async {
    final c = container();
    final gate = Completer<JsonMap>();
    api.gates[#accountXp] = gate;
    var returned = false;
    unawaited(
      c
          .read(accountDataWarmupProvider)
          .afterLogin(me)
          .then((_) => returned = true),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(returned, isTrue);
    gate.complete({
      'Progress': {'Level': 474},
    });
    await tester.pump();
    await c.read(accountDataWarmupProvider).pages(me);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
}
