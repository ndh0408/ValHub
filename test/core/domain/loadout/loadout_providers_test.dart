import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import '../../../helpers/test_prefs.dart';
import '../economy/economy_fixtures.dart';
import 'loadout_fixtures.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MemoryJsonCache extends JsonFileCache {
  MemoryJsonCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime(2026));
}

final t0 = DateTime(2026, 9, 29, 10);

void main() {
  late MockPvpApi api;
  late Prefs prefs;
  late MemoryJsonCache cache;
  late JsonMap server;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() async {
    api = MockPvpApi();
    prefs = await createTestPrefs();
    cache = MemoryJsonCache();
    server = loadoutJson();
    when(() => api.playerLoadout(any())).thenAnswer((_) async => server);
    when(() => api.putPlayerLoadout(any(), any())).thenAnswer((inv) async {
      final body = inv.positionalArguments[1] as JsonMap;
      server = {...body, 'Version': (body['Version'] as int) + 1};
      return server;
    });
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      pvpApiProvider.overrideWithValue(api),
      prefsProvider.overrideWithValue(prefs),
      jsonFileCacheProvider.overrideWithValue(cache),
      clockProvider.overrideWithValue(FixedClock(t0)),
      accountProvider.overrideWith((ref, puuid) => null),
    ],
  );

  group('loadoutProvider', () {
    test('loads and keeps an offline copy', () async {
      final c = makeContainer();
      final s = await readListened(c, loadoutProvider(Lx.puuid).future);
      expect(s.loadout.version, 25);
      expect(s.isFromCache, isFalse);
      await pumpEventQueue();
      expect(cache.entries.keys, contains('acct/${Lx.puuid}/loadout'));
    });

    test('serves the offline copy on a transient error', () async {
      cache.entries['acct/${Lx.puuid}/loadout'] = CachedJson(
        loadoutJson(version: 3),
        DateTime(2026, 9, 28),
      );
      when(() => api.playerLoadout(any()))
          .thenThrow(const TransientException(status: 503));
      final c = makeContainer();
      final s = await readListened(c, loadoutProvider(Lx.puuid).future);
      expect(s.isFromCache, isTrue);
      expect(s.loadout.version, 3);
      expect(s.receivedAt, DateTime(2026, 9, 28));
    });

    test('needs-login errors propagate', () async {
      when(() => api.playerLoadout(any()))
          .thenThrow(const NeedsLoginException(puuid: Lx.puuid));
      final c = makeContainer();
      await expectLater(
        readListened(c, loadoutProvider(Lx.puuid).future),
        throwsA(isA<NeedsLoginException>()),
      );
    });

    test(
      'login and maintenance use the saved loadout, other errors propagate',
      () async {
        cache.entries['acct/${Lx.puuid}/loadout'] = CachedJson(
          loadoutJson(version: 3),
          DateTime(2026, 9, 28),
        );
        for (final error in <RiotException>[
          const NeedsLoginException(),
          const MaintenanceException(),
        ]) {
          when(() => api.playerLoadout(any())).thenThrow(error);
          final c = makeContainer();
          final saved = await readListened(c, loadoutProvider(Lx.puuid).future);
          expect(saved.isFromCache, isTrue);
          expect(saved.loadout.version, 3);
        }
        when(() => api.playerLoadout(any()))
            .thenThrow(const NotFoundException());
        await expectLater(
          readListened(makeContainer(), loadoutProvider(Lx.puuid).future),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test('apply: optimistic value, then the confirmed loadout', () async {
      final c = makeContainer();
      await readListened(c, loadoutProvider(Lx.puuid).future);
      final gate = Completer<void>();
      when(() => api.putPlayerLoadout(any(), any())).thenAnswer((inv) async {
        await gate.future;
        final body = inv.positionalArguments[1] as JsonMap;
        server = {...body, 'Version': (body['Version'] as int) + 1};
        return server;
      });

      final controller = c.read(loadoutProvider(Lx.puuid).notifier);
      final future = controller.apply(const SetPlayerCard(Lx.cardDefault));
      await pumpEventQueue();
      final pending = c.read(loadoutProvider(Lx.puuid)).value!;
      expect(pending.isPending, isTrue);
      expect(pending.loadout.identity.playerCardId, Lx.cardDefault);
      expect(controller.isSaving, isTrue);

      gate.complete();
      final saved = await future;
      expect(saved.loadout.version, 26);
      final state = c.read(loadoutProvider(Lx.puuid)).value!;
      expect(state.isPending, isFalse);
      expect(state.loadout.identity.playerCardId, Lx.cardDefault);
      expect(controller.isSaving, isFalse);
    });

    test('apply: rollback and "Không thể lưu trang bị" on failure', () async {
      final c = makeContainer();
      await readListened(c, loadoutProvider(Lx.puuid).future);
      when(() => api.putPlayerLoadout(any(), any()))
          .thenThrow(const RiotApiException(400));
      final controller = c.read(loadoutProvider(Lx.puuid).notifier);
      await expectLater(
        controller.apply(const SetPlayerCard(Lx.cardDefault)),
        throwsA(
          isA<LoadoutSaveException>().having(
            (e) => e.message,
            'message',
            'Không thể lưu trang bị',
          ),
        ),
      );
      final state = c.read(loadoutProvider(Lx.puuid)).value!;
      expect(state.isPending, isFalse);
      expect(state.loadout.identity.playerCardId, Fx.cardNgoiSang);
    });

    test(
      'saves are serialised (one PUT at a time, each from a fresh GET)',
      () async {
        final c = makeContainer();
        await readListened(c, loadoutProvider(Lx.puuid).future);
        final controller = c.read(loadoutProvider(Lx.puuid).notifier);
        final a = controller.apply(const SetPlayerCard(Lx.cardDefault));
        final b = controller.apply(const SetIncognito(true));
        await Future.wait([a, b]);
        final state = c.read(loadoutProvider(Lx.puuid)).value!.loadout;
        expect(state.identity.playerCardId, Lx.cardDefault);
        expect(state.incognito, isTrue);
        expect(state.version, 27);
      },
    );
  });

  group('presets', () {
    test('save / rename / delete / restore persist per account', () async {
      final c = makeContainer();
      final notifier = c.read(loadoutPresetsProvider(Lx.puuid).notifier);
      final loadout = Loadout.fromJson(loadoutJson());
      expect(notifier.suggestedName, 'Bộ trang bị 1');

      final first = await notifier.save(loadout);
      expect(first.name, 'Bộ trang bị 1');
      final second = await notifier.save(loadout, name: '  Leo   rank  ');
      expect(second.name, 'Leo rank');
      expect(c.read(loadoutPresetsProvider(Lx.puuid)).map((p) => p.id), [
        second.id,
        first.id,
      ]);
      expect(notifier.suggestedName, 'Bộ trang bị 3');

      await notifier.rename(first.id, 'Đấu thường');
      await notifier.rename(first.id, '   ');
      expect(c.read(loadoutPresetsProvider(Lx.puuid)).last.name, 'Đấu thường');

      await notifier.delete(second.id);
      expect(c.read(loadoutPresetsProvider(Lx.puuid)), hasLength(1));
      await notifier.restore(second);
      expect(c.read(loadoutPresetsProvider(Lx.puuid)).first.id, second.id);

      // Stored under keep.<puuid>.* (survives sign-out) and re-read.
      final stored = LoadoutPresetStore(prefs).read(Lx.puuid);
      expect(stored.map((p) => p.name), ['Leo rank', 'Đấu thường']);
      expect(prefs.keys, contains('keep.${Lx.puuid}.loadoutPresets'));
      expect(stored.first.gun(Lx.vandal)!.buddyInstanceId, Lx.buddyInstanceA);
      expect(stored.first.expressions, loadout.expressions);
      expect(stored.first.createdAt, t0);
    });

    test('automatic names remember their number (GL-38)', () async {
      final c = makeContainer();
      final notifier = c.read(loadoutPresetsProvider(Lx.puuid).notifier);
      final loadout = Loadout.fromJson(loadoutJson());
      // Keeping the proposed name = automatic; typing another = custom.
      final auto = await notifier.save(loadout, name: notifier.suggestedName);
      expect(auto.defaultNumber, 1);
      final custom = await notifier.save(loadout, name: 'Leo rank');
      expect(custom.defaultNumber, isNull);
      // A name that happens to look like a default one but was typed for
      // another number is a custom name.
      final typed = await notifier.save(loadout, name: 'Bộ trang bị 9');
      expect(typed.defaultNumber, isNull);
      expect(notifier.suggestedName, 'Bộ trang bị 4');
      // Stored with the preset and unique after a rename.
      final stored = LoadoutPresetStore(prefs).read(Lx.puuid);
      expect(stored.map((p) => p.defaultNumber), [null, null, 1]);
      await notifier.rename(auto.id, 'Đấu thường');
      expect(
        LoadoutPresetStore(prefs).read(Lx.puuid).last.defaultNumber,
        isNull,
      );
    });

    test('corrupt storage reads as empty', () async {
      await prefs.setString(LoadoutPresetStore.key(Lx.puuid), '{oops');
      expect(LoadoutPresetStore(prefs).read(Lx.puuid), isEmpty);
      await prefs.setJson(LoadoutPresetStore.key(Lx.puuid), [
        'x',
        {'name': 'no id'},
        {'id': 'a', 'guns': 'nope', 'expressions': null},
      ]);
      final read = LoadoutPresetStore(prefs).read(Lx.puuid);
      expect(read, hasLength(1));
      expect(read.single.guns, isEmpty);
    });

    test(
      'applyPreset = one PUT restoring skins, buddies and identity',
      () async {
        final c = makeContainer();
        final original = Loadout.fromJson(loadoutJson());
        final preset = LoadoutPreset.fromLoadout(
          original,
          id: 'p1',
          name: 'Gốc',
          createdAt: t0,
        );
        // The account changed a lot since the preset was saved.
        server = LoadoutChange.all([
          const EquipSkin(
            weaponId: Lx.vandal,
            skinId: Fx.reaverVandal,
            skinLevelId: Fx.reaverL1,
            chromaId: Fx.reaverBaseChroma,
          ),
          const EquipBuddy(
            weaponId: Lx.phantom,
            buddyId: Fx.neoFrontierBuddy,
            buddyLevelId: Fx.neoFrontierBuddyL1,
            instanceId: Lx.buddyInstanceA,
          ),
          SetExpression.spray(0, Lx.sprayA),
          const SetPlayerCard(Lx.cardDefault),
          const SetIncognito(true),
        ]).appliedTo(loadoutJson());
        await readListened(c, loadoutProvider(Lx.puuid).future);

        final skipped = await c
            .read(loadoutProvider(Lx.puuid).notifier)
            .applyPreset(preset);
        expect(skipped, 0);
        verify(() => api.putPlayerLoadout(any(), any())).called(1);
        final l = c.read(loadoutProvider(Lx.puuid)).value!.loadout;
        expect(l.gun(Lx.vandal), original.gun(Lx.vandal));
        expect(l.gun(Lx.phantom)!.hasBuddy, isFalse);
        expect(l.expressions, original.expressions);
        expect(l.identity.playerCardId, Fx.cardNgoiSang);
        expect(l.incognito, isTrue, reason: 'not part of a preset');
      },
    );
  });

  group('matchLoadoutsProvider', () {
    test('core-game loadouts merged with the match identities', () async {
      when(() => api.coreGameLoadouts(any(), any())).thenAnswer(
        (_) async => {
          'Loadouts': [
            {
              'CharacterID': 'AGENT',
              'Loadout': {'Subject': 'P1', 'Items': <String, dynamic>{}},
            },
          ],
        },
      );
      when(() => api.coreGameMatch(any(), any())).thenAnswer(
        (_) async => {
          'Players': [
            {
              'Subject': 'p1',
              'PlayerIdentity': {'PlayerCardID': 'CARD', 'Incognito': true},
            },
          ],
        },
      );
      final c = makeContainer();
      final m = await readListened(
        c,
        matchLoadoutsProvider((puuid: Lx.puuid, matchId: 'm1', pregame: false))
            .future,
      );
      expect(m.player('P1')!.playerCardId, 'card');
      expect(m.player('p1')!.incognito, isTrue);
      expect(m.player('p1')!.characterId, 'agent');
    });

    test('match lookup failure is ignored', () async {
      when(() => api.pregameLoadouts(any(), any())).thenAnswer(
        (_) async => {
          'Loadouts': [
            {'Subject': 'p2'},
          ],
        },
      );
      when(() => api.pregameMatch(any(), any()))
          .thenThrow(const TransientException());
      final c = makeContainer();
      final m = await readListened(
        c,
        matchLoadoutsProvider((puuid: Lx.puuid, matchId: 'm1', pregame: true))
            .future,
      );
      expect(m.player('p2'), isNotNull);
      expect(m.player('p2')!.identity, isNull);
    });
  });
}
