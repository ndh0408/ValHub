import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/features/battlepass/providers/battlepass_providers.dart';

import '../../../helpers/test_prefs.dart';
import '../bp_fixtures.dart';
import '../bp_test_harness.dart';

Future<T> _read<T>(ProviderContainer c, ProviderListenable<Future<T>> p) {
  c.listen(p, (_, _) {});
  return c.read(p);
}

void main() {
  late ProviderContainer container;

  Future<ProviderContainer> make(
    MockPvpApi api, {
    MemoryJsonCache? cache,
    List<int>? misses,
  }) async {
    final prefs = await createTestPrefs();
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: bpOverrides(
        api: api,
        prefs: prefs,
        cache: cache,
        misses: misses,
      ),
    );
    return container;
  }

  test('overview combines contracts, premium and content', () async {
    final api = bpApi();
    final c = await make(api);
    final o = await _read(c, battlePassOverviewProvider(Bp.puuid).future);
    expect(o.battlePass?.level, 46);
    expect(o.isPremium, isTrue);
    expect(o.weekly.missions, hasLength(3));
    expect(o.eventPasses, hasLength(1));
    verify(() => api.contracts(Bp.puuid)).called(1);
  });

  test('a failed premium lookup only hides the badge', () async {
    final c = await make(
      bpApi(premiumError: const TransientException(status: 503)),
    );
    final o = await _read(c, battlePassOverviewProvider(Bp.puuid).future);
    expect(o.battlePass, isNotNull);
    expect(o.isPremium, isNull);
  });

  test('premium 404 means a free account', () async {
    final c = await make(bpApi(premium: null));
    final o = await _read(c, battlePassOverviewProvider(Bp.puuid).future);
    expect(o.isPremium, isFalse);
  });

  test('needs-login errors propagate', () async {
    final c = await make(
      bpApi(contractsError: const NeedsLoginException(puuid: Bp.puuid)),
    );
    await expectLater(
      _read(c, battlePassOverviewProvider(Bp.puuid).future),
      throwsA(isA<NeedsLoginException>()),
    );
  });

  test('offline copy on a transient failure (X4)', () async {
    final cache = MemoryJsonCache();
    final savedAt = t0.subtract(const Duration(hours: 2));
    cache.entries[contractsCacheKey(Bp.puuid)] = CachedJson(
      contractsJson(level: 40),
      savedAt,
    );
    final c = await make(
      bpApi(contractsError: const TransientException(status: 503)),
      cache: cache,
    );
    final contracts = await _read(c, playerContractsProvider(Bp.puuid).future);
    expect(contracts.isFromCache, isTrue);
    expect(contracts.receivedAt, savedAt);
    expect(contracts.progressFor(Bp.bpId)?.levelReached, 40);
  });

  test('a transient failure without a copy is an error', () async {
    final c = await make(
      bpApi(contractsError: const TransientException(status: 503)),
    );
    await expectLater(
      _read(c, playerContractsProvider(Bp.puuid).future),
      throwsA(isA<TransientException>()),
    );
  });

  test('a successful fetch is stored for offline use', () async {
    final cache = MemoryJsonCache();
    final c = await make(bpApi(), cache: cache);
    await _read(c, playerContractsProvider(Bp.puuid).future);
    await Future<void>.delayed(Duration.zero);
    expect(cache.entries[contractsCacheKey(Bp.puuid)]?.savedAt, t0);
  });

  test('daily ticket 404 → null', () async {
    final c = await make(bpApi(ticketError: const NotFoundException()));
    expect(await _read(c, dailyTicketProvider(Bp.puuid).future), isNull);
  });

  test('unknown weekly missions trigger a content-miss report', () async {
    final misses = [0];
    final c = await make(
      bpApi(
        contracts: contractsJson(
          missions: [activeMission(Bp.missionUnknown, 'obj', 1)],
        ),
      ),
      misses: misses,
    );
    await _read(c, battlePassOverviewProvider(Bp.puuid).future);
    expect(misses[0], 1);
  });

  group('DailyTicketRenewer', () {
    test('renews once, then waits for the next day', () async {
      final api = bpApi(ticketError: const NotFoundException());
      final c = await make(api);
      final renewer = c.read(dailyTicketRenewerProvider);
      expect(renewer.canRenew(Bp.puuid, null), isTrue);
      await renewer.renew(Bp.puuid);
      verify(() => api.renewDailyTicket(Bp.puuid)).called(1);
      expect(renewer.lastRenewAt(Bp.puuid)?.isAtSameMomentAs(t0), isTrue);
      expect(renewer.canRenew(Bp.puuid, null), isFalse);
    });

    test('a failed renew can be retried', () async {
      final api = bpApi(ticketError: const NotFoundException());
      when(() => api.renewDailyTicket(any()))
          .thenThrow(const TransientException(status: 500));
      final c = await make(api);
      final renewer = c.read(dailyTicketRenewerProvider);
      await expectLater(
        renewer.renew(Bp.puuid),
        throwsA(isA<TransientException>()),
      );
      expect(renewer.canRenew(Bp.puuid, null), isTrue);
    });
  });
}
