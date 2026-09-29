import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import '../economy/economy_fixtures.dart';
import 'loadout_fixtures.dart';

class MockPvpApi extends Mock implements PvpApi {}

const equipReaver = EquipSkin(
  weaponId: Lx.vandal,
  skinId: Fx.reaverVandal,
  skinLevelId: Fx.reaverL3,
  chromaId: Fx.reaverBaseChroma,
);

void main() {
  late MockPvpApi api;
  late LoadoutRepository repo;
  late List<JsonMap> gets;
  JsonMap? putBody;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    api = MockPvpApi();
    repo = LoadoutRepository(api, clock: FixedClock(DateTime(2026, 9, 29)));
    gets = [];
    putBody = null;
    when(() => api.playerLoadout(any())).thenAnswer((_) async {
      if (gets.isEmpty) throw StateError('unexpected GET');
      return gets.length == 1 ? gets.single : gets.removeAt(0);
    });
    when(() => api.putPlayerLoadout(any(), any())).thenAnswer((inv) async {
      putBody = inv.positionalArguments[1] as JsonMap;
      return {...putBody!, 'Version': (asInt(putBody!['Version']) ?? 0) + 1};
    });
  });

  JsonMap persisted(JsonMap before) {
    final after = equipReaver.appliedTo(before);
    after['Version'] = (before['Version'] as int) + 1;
    return after;
  }

  test('fetch parses the loadout', () async {
    gets = [loadoutJson()];
    final s = await repo.fetch(Lx.puuid);
    expect(s.loadout.version, 25);
    expect(s.receivedAt, DateTime(2026, 9, 29));
  });

  test('fresh GET → PUT whole raw object → re-GET with a newer Version', () async {
    final fresh = loadoutJson(version: 30);
    gets = [fresh, persisted(fresh)];
    final saved = await repo.save(Lx.puuid, equipReaver);

    verifyInOrder([
      () => api.playerLoadout(Lx.puuid),
      () => api.putPlayerLoadout(Lx.puuid, any()),
      () => api.playerLoadout(Lx.puuid),
    ]);
    // The PUT is built from the FRESH GET (version 30), unknown keys included.
    expect(putBody!['Version'], 30);
    expect(putBody!['AgentMasteryCosmetics'], fresh['AgentMasteryCosmetics']);
    expect(putBody!['DynamicOptions'], <String, dynamic>{});
    expect(asList(putBody!['Guns']), hasLength(4));
    expect(asList(putBody!['ActiveExpressions']), hasLength(4));
    expect(saved.loadout.version, 31);
    expect(saved.loadout.gun(Lx.vandal)!.skinId, Fx.reaverVandal);
  });

  test('no-op change skips the PUT', () async {
    gets = [loadoutJson()];
    const change = SetPlayerCard(Fx.cardNgoiSang);
    final saved = await repo.save(Lx.puuid, change);
    verifyNever(() => api.putPlayerLoadout(any(), any()));
    expect(saved.loadout.identity.playerCardId, Fx.cardNgoiSang);
  });

  test('same Version after the PUT = not persisted (U8)', () async {
    gets = [loadoutJson(), loadoutJson()];
    await expectLater(
      repo.save(Lx.puuid, equipReaver),
      throwsA(
        isA<LoadoutSaveException>()
            .having(
              (e) => e.failure,
              'failure',
              LoadoutSaveFailure.notPersisted,
            )
            .having((e) => e.message, 'message', 'Không thể lưu trang bị'),
      ),
    );
  });

  test('without versions the change must be visible', () async {
    final fresh = loadoutJson()..remove('Version');
    final after = equipReaver.appliedTo(fresh);
    gets = [fresh, after];
    final saved = await repo.save(Lx.puuid, equipReaver);
    expect(saved.loadout.gun(Lx.vandal)!.skinLevelId, Fx.reaverL3);

    gets = [fresh, fresh];
    await expectLater(
      repo.save(Lx.puuid, equipReaver),
      throwsA(isA<LoadoutSaveException>()),
    );
  });

  test('PUT failure → request error with the Riot cause', () async {
    gets = [loadoutJson()];
    when(() => api.putPlayerLoadout(any(), any()))
        .thenThrow(const RiotApiException(400, errorCode: 'INVALID_LOADOUT'));
    await expectLater(
      repo.save(Lx.puuid, equipReaver),
      throwsA(
        isA<LoadoutSaveException>()
            .having((e) => e.failure, 'failure', LoadoutSaveFailure.request)
            .having((e) => e.riotError, 'cause', isA<RiotApiException>()),
      ),
    );
  });

  test('dead session before the PUT → needsLogin, nothing sent', () async {
    when(() => api.playerLoadout(any()))
        .thenThrow(const NeedsLoginException(puuid: Lx.puuid));
    await expectLater(
      repo.save(Lx.puuid, equipReaver),
      throwsA(
        isA<LoadoutSaveException>().having((e) => e.needsLogin, 'login', true),
      ),
    );
    verifyNever(() => api.putPlayerLoadout(any(), any()));
  });

  test('re-GET failure falls back to the PUT response', () async {
    final fresh = loadoutJson();
    var calls = 0;
    when(() => api.playerLoadout(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) return fresh;
      throw const TransientException(status: 503);
    });
    final saved = await repo.save(Lx.puuid, equipReaver);
    expect(saved.loadout.version, 26);
    expect(saved.loadout.gun(Lx.vandal)!.skinId, Fx.reaverVandal);
  });

  test('HTML / non-loadout GET body is never PUT back', () async {
    gets = [
      <String, dynamic>{'message': 'Just a moment'},
    ];
    await expectLater(
      repo.save(Lx.puuid, equipReaver),
      throwsA(
        isA<LoadoutSaveException>().having(
          (e) => e.failure,
          'failure',
          LoadoutSaveFailure.invalidLoadout,
        ),
      ),
    );
    verifyNever(() => api.putPlayerLoadout(any(), any()));
  });

  test('invalid change → invalidChange, nothing sent', () async {
    gets = [loadoutJson()];
    await expectLater(
      repo.save(
        Lx.puuid,
        const EquipBuddy(
          weaponId: Lx.melee,
          buddyId: 'b',
          buddyLevelId: 'l',
          instanceId: 'i',
        ),
      ),
      throwsA(
        isA<LoadoutSaveException>()
            .having(
              (e) => e.failure,
              'failure',
              LoadoutSaveFailure.invalidChange,
            )
            .having((e) => e.detail, 'detail', isNotNull),
      ),
    );
    verifyNever(() => api.putPlayerLoadout(any(), any()));
  });
}
