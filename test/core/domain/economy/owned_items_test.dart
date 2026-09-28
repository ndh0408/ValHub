import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/owned_items.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';

import 'economy_fixtures.dart';

class MockPvpApi extends Mock implements PvpApi {}

final _t0 = DateTime(2026, 9, 28, 12);

/// Per-type P-3 answers built from the fixtures (single-type shape, the
/// buddy type in the by-types shape to exercise both).
Map<String, JsonMap> _perTypeResponses() {
  final all = economyFixture('entitlements_all.json');
  final out = <String, JsonMap>{
    ItemTypeIds.skinLevel: economyFixture('entitlements_skin_levels.json'),
  };
  for (final group in all.maps('EntitlementsByTypes')) {
    final type = group.uuid('ItemTypeID')!;
    if (type == ItemTypeIds.skinLevel) continue;
    out[type] = type == ItemTypeIds.buddyLevel
        ? {
            'EntitlementsByTypes': [group],
          }
        : {'ItemTypeID': type, 'Entitlements': group['Entitlements']};
  }
  return out;
}

OwnedItems _owned([ContentDb? db]) => OwnedItems.resolve(
  Entitlements.fromTypeResponses(_perTypeResponses(), receivedAt: _t0),
  db ?? economyContent(),
);

void main() {
  group('Entitlements.parseRows', () {
    test('single-type shape', () {
      final rows = Entitlements.parseRows(
        economyFixture('entitlements_skin_levels.json'),
      );
      expect(rows, hasLength(7), reason: 'null ItemID and junk skipped');
      expect(rows.every((r) => r.itemTypeId == ItemTypeIds.skinLevel), isTrue);
      expect(rows[1].itemId, Fx.reaverL3, reason: 'lowercased');
    });

    test('by-types shape; null Entitlements; InstanceID lowercased', () {
      final rows = Entitlements.parseRows(
        economyFixture('entitlements_all.json'),
      );
      expect(rows, hasLength(10));
      final buddies = rows.where((r) => r.itemTypeId == ItemTypeIds.buddyLevel);
      expect(buddies.map((r) => r.instanceId), [
        '90431b40-a439-410f-8c51-765452353200',
        'a1b2c3d4-0000-4000-8000-000000000002',
        null,
      ]);
    });

    test('missing ItemTypeID falls back to the requested type', () {
      final rows = Entitlements.parseRows({
        'Entitlements': [
          {'ItemID': 'ABC'},
        ],
      }, requestedItemTypeId: ItemTypeIds.spray.toUpperCase());
      expect(
        rows.single,
        const EntitlementRow(itemTypeId: ItemTypeIds.spray, itemId: 'abc'),
      );
      expect(
        Entitlements.parseRows({
          'Entitlements': [
            {'ItemID': 'x'},
          ],
        }),
        isEmpty,
      );
    });

    test('junk bodies yield nothing', () {
      for (final junk in <Object?>[
        null,
        '<html>Just a moment...</html>',
        3,
        [],
        {'EntitlementsByTypes': 'x'},
      ]) {
        expect(Entitlements.parseRows(junk), isEmpty);
      }
    });
  });

  group('Entitlements', () {
    test('buddy instances are deduplicated; copies count every row', () {
      final e = Entitlements.fromRows([
        const EntitlementRow(
          itemTypeId: ItemTypeIds.buddyLevel,
          itemId: 'b1',
          instanceId: 'i1',
        ),
        const EntitlementRow(
          itemTypeId: ItemTypeIds.buddyLevel,
          itemId: 'b1',
          instanceId: 'i1',
        ),
        const EntitlementRow(
          itemTypeId: ItemTypeIds.buddyLevel,
          itemId: 'b1',
          instanceId: 'i2',
        ),
        const EntitlementRow(itemTypeId: ItemTypeIds.buddyLevel, itemId: 'b2'),
      ], receivedAt: _t0);
      expect(e.buddyInstanceIds('B1'), ['i1', 'i2']);
      expect(e.buddyCopies('b1'), 2);
      expect(e.buddyCopies('b2'), 1);
      expect(e.buddyInstanceIds('b2'), isEmpty);
      expect(e.length, 2);
      expect(e.contains(ItemTypeIds.buddyLevel.toUpperCase(), 'B2'), isTrue);
    });

    test('from per-type responses', () {
      final e = Entitlements.fromTypeResponses(
        _perTypeResponses(),
        receivedAt: _t0,
      );
      expect(e.itemsOfType(ItemTypeIds.skinLevel), hasLength(7));
      expect(e.itemsOfType(ItemTypeIds.premiumContract), {Fx.battlePass});
      expect(e.receivedAt, _t0);
      expect(Entitlements.empty().length, 0);
    });
  });

  group('OwnedItems', () {
    late ContentDb db;
    late OwnedItems owned;
    setUp(() {
      db = economyContent();
      owned = _owned(db);
    });

    test('skins are owned via any level / chroma / skin uuid', () {
      expect(owned.isSkinOwned(Fx.reaverVandal), isTrue);
      expect(owned.isSkinOwned(Fx.reaverL4.toUpperCase()), isTrue);
      expect(owned.isSkinOwned(Fx.reaverChroma3), isTrue);
      expect(owned.isSkinOwned(Fx.aresPrism), isFalse);
      expect(owned.isSkinOwned(Fx.aresPrismL1), isFalse);
      expect(
        owned.isSkinOwned(Fx.unknownLevel),
        isTrue,
        reason: 'raw fallback',
      );
      expect(owned.isSkinOwned('not-a-uuid'), isFalse);
    });

    test('owning level N implies 1..N', () {
      expect(owned.isSkinLevelOwned(Fx.reaverL1), isTrue);
      expect(owned.isSkinLevelOwned(Fx.reaverL2), isTrue);
      expect(owned.isSkinLevelOwned(Fx.reaverL3), isTrue);
      expect(owned.isSkinLevelOwned(Fx.reaverL4), isFalse);
      final skin = db.skin(Fx.reaverVandal)!;
      expect(owned.ownedLevels(skin).map((l) => l.levelNumber), [1, 2, 3]);
    });

    test('base chroma plus entitled chromas', () {
      final skin = db.skin(Fx.reaverVandal)!;
      expect(owned.ownedChromas(skin).map((c) => c.uuid), [
        Fx.reaverBaseChroma,
        Fx.reaverChroma2,
      ]);
      expect(owned.isChromaOwned(Fx.reaverChroma3), isFalse);
      expect(owned.ownedChromas(db.skin(Fx.aresPrism)!), isEmpty);
      expect(owned.ownedLevels(db.skin(Fx.aresPrism)!), isEmpty);
    });

    test('Standard and Random-favorite skins are always owned', () {
      expect(owned.isSkinOwned(Fx.vandalStandard), isTrue);
      expect(owned.isSkinOwned(Fx.randomFavorite), isTrue);
      final standard = db.skin(Fx.vandalStandard)!;
      expect(owned.ownedLevels(standard), hasLength(1));
      expect(owned.ownedChromas(standard), hasLength(1));
      final empty = OwnedItems.resolve(Entitlements.empty(), db);
      expect(empty.isSkinOwned(Fx.vandalStandard), isTrue);
      expect(empty.ownedCollectibleSkins, isEmpty);
    });

    test('collectible skins and per-weapon picker lists', () {
      expect(owned.ownedCollectibleSkins.map((s) => s.uuid).toSet(), {
        Fx.reaverVandal,
        Fx.vandalCafe,
        Fx.bulldogVoCuc,
        Fx.daoReaver,
        Fx.ghostThinhLang,
      });
      expect(owned.ownedSkinsForWeapon(Fx.vandal).map((s) => s.uuid), [
        Fx.vandalStandard,
        Fx.vandalCafe,
        Fx.reaverVandal,
      ]);
      expect(owned.ownedSkinsForWeapon('nope'), isEmpty);
      expect(owned.ownedSkinUuids, contains(Fx.randomFavorite));
      expect(owned.unknownSkinLevels, {Fx.unknownLevel});
    });

    test('buddies by level or buddy uuid', () {
      expect(owned.buddyInstances(Fx.neoFrontierBuddyL1), hasLength(2));
      expect(owned.buddyInstances(Fx.neoFrontierBuddy), hasLength(2));
      expect(owned.buddyCount(Fx.neoFrontierBuddy.toUpperCase()), 2);
      expect(owned.buddyCount(Fx.gourmandBuddyL1), 1);
      expect(owned.buddyInstances(Fx.gourmandBuddyL1), isEmpty);
      expect(owned.isBuddyOwned('nope'), isFalse);
      expect(owned.buddyLevelUuids, {
        Fx.neoFrontierBuddyL1,
        Fx.gourmandBuddyL1,
      });
    });

    test('cosmetics include the defaults every account has', () {
      expect(owned.isSprayOwned(DefaultItemIds.spray), isTrue);
      expect(owned.isSprayOwned(SpecialIds.nullSpray), isTrue);
      expect(owned.isSprayOwned(Fx.sprayTinhNguyen.toUpperCase()), isTrue);
      expect(owned.isSprayOwned(Fx.sprayCypher), isFalse);
      expect(owned.isPlayerCardOwned(DefaultItemIds.playerCard), isTrue);
      expect(owned.isPlayerCardOwned(Fx.cardNgoiSang), isTrue);
      expect(owned.isPlayerCardOwned(Fx.eventCard), isFalse);
      expect(owned.isTitleOwned(SpecialIds.noTitle), isTrue);
      expect(owned.isTitleOwned(Fx.titleTaiLoc), isTrue);
      expect(owned.isFlexOwned(DefaultItemIds.flex), isTrue);
      expect(owned.isFlexOwned(Fx.flexOra), isTrue);
      expect(
        owned.sprayUuids,
        containsAll([DefaultItemIds.spray, Fx.sprayTinhNguyen]),
      );
      expect(owned.playerCardUuids, hasLength(2));
      expect(owned.titleUuids, hasLength(2));
      expect(owned.flexUuids, hasLength(2));
    });

    test('agents: starters always, others from entitlements', () {
      expect(owned.isAgentOwned(Fx.jett), isTrue);
      expect(owned.isAgentOwned(SpecialIds.starterAgents.last), isTrue);
      expect(owned.isAgentOwned(Fx.gekko), isTrue);
      expect(owned.isAgentOwned(Fx.cypher), isFalse);
      expect(owned.agentUuids, containsAll([Fx.jett, Fx.gekko]));
      expect(owned.agentUuids, hasLength(6));
    });

    test('premium contracts', () {
      expect(owned.hasPremiumContract(Fx.battlePass.toUpperCase()), isTrue);
      expect(owned.hasPremiumContract(Fx.eventPass), isFalse);
      expect(owned.premiumContracts, {Fx.battlePass});
    });

    test('owns() dispatches on ItemTypeID', () {
      expect(owned.owns(ItemTypeIds.skinLevel, Fx.reaverL2), isTrue);
      expect(owned.owns(ItemTypeIds.skinChroma, Fx.reaverChroma2), isTrue);
      expect(owned.owns(ItemTypeIds.buddyLevel, Fx.neoFrontierBuddyL1), isTrue);
      expect(owned.owns(ItemTypeIds.spray, Fx.sprayTinhNguyen), isTrue);
      expect(owned.owns(ItemTypeIds.playerCard, Fx.eventCard), isFalse);
      expect(
        owned.owns(ItemTypeIds.playerTitle.toUpperCase(), Fx.titleTaiLoc),
        isTrue,
      );
      expect(owned.owns(ItemTypeIds.flex, Fx.flexOra), isTrue);
      expect(owned.owns(ItemTypeIds.agent, Fx.gekko), isTrue);
      expect(owned.owns(ItemTypeIds.premiumContract, Fx.battlePass), isTrue);
      expect(owned.owns(ItemTypeIds.currency, CurrencyIds.vp), isFalse);
      expect(owned.owns('junk', 'x'), isFalse);
    });

    test('works with empty content (fallbacks only)', () {
      final bare = _owned(ContentDb.empty());
      expect(bare.isSkinOwned(Fx.reaverL1), isTrue);
      expect(bare.isSkinOwned(Fx.reaverVandal), isFalse);
      expect(bare.isSkinLevelOwned(Fx.reaverL3), isTrue);
      expect(bare.ownedCollectibleSkins, isEmpty);
      expect(bare.isAgentOwned(Fx.jett), isTrue);
    });
  });

  group('entitlementsProvider / ownedItemsProvider', () {
    late MockPvpApi api;
    late Directory tmp;
    late ContentDb db;

    setUp(() async {
      api = MockPvpApi();
      tmp = await Directory.systemTemp.createTemp('valvn_economy');
      db = economyContent();
    });
    tearDown(() => tmp.delete(recursive: true));

    ProviderContainer container() => ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        pvpApiProvider.overrideWithValue(api),
        accountProvider.overrideWith((ref, puuid) => null),
        jsonFileCacheProvider.overrideWithValue(JsonFileCache(() async => tmp)),
        clockProvider.overrideWithValue(FixedClock(_t0)),
        contentProvider.overrideWith((ref) async => db),
      ],
    );

    test('fetches every type with at most 3 in flight; 404 = empty', () async {
      final responses = _perTypeResponses();
      var inFlight = 0;
      var maxInFlight = 0;
      final calls = <String>[];
      when(() => api.entitlements(any(), any())).thenAnswer((inv) async {
        final type = inv.positionalArguments[1] as String;
        calls.add(type);
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        inFlight--;
        if (type == ItemTypeIds.flex) throw const NotFoundException();
        return responses[type] ?? <String, dynamic>{};
      });

      final c = container();
      final owned = await readListened(c, ownedItemsProvider(Fx.puuid).future);
      expect(calls.toSet(), ItemTypeIds.collectionTypes.toSet());
      expect(calls, hasLength(ItemTypeIds.collectionTypes.length));
      expect(maxInFlight, 3);
      expect(owned.isSkinOwned(Fx.reaverVandal), isTrue);
      expect(owned.isFlexOwned(Fx.flexOra), isFalse, reason: '404 → empty');
      expect(owned.isFlexOwned(DefaultItemIds.flex), isTrue);
      expect(owned.isFromCache, isFalse);
      expect(owned.receivedAt, _t0);
    });

    test('needs-login wins over other failures and stops new calls', () async {
      var calls = 0;
      when(() => api.entitlements(any(), any())).thenAnswer((inv) async {
        calls++;
        final type = inv.positionalArguments[1] as String;
        if (type == ItemTypeIds.skinLevel) {
          throw const TransientException(status: 503);
        }
        if (type == ItemTypeIds.skinChroma) {
          throw const NeedsLoginException(reason: 'test');
        }
        return <String, dynamic>{};
      });
      final c = container();
      await expectLater(
        readListened(c, entitlementsProvider(Fx.puuid).future),
        throwsA(isA<NeedsLoginException>()),
      );
      expect(calls, lessThan(ItemTypeIds.collectionTypes.length));
    });

    test('transient failure serves the offline copy', () async {
      final responses = _perTypeResponses();
      when(
        () => api.entitlements(any(), any()),
      ).thenAnswer((inv) async => responses[inv.positionalArguments[1]] ?? {});
      final c1 = container();
      await readListened(c1, entitlementsProvider(Fx.puuid).future);
      c1.dispose();

      when(() => api.entitlements(any(), any()))
          .thenThrow(const TransientException(status: 429));
      final c2 = container();
      final cached = await readListened(
        c2,
        entitlementsProvider(Fx.puuid).future,
      );
      expect(cached.isFromCache, isTrue);
      expect(cached.contains(ItemTypeIds.skinLevel, Fx.reaverL1), isTrue);
      expect(cached.receivedAt, _t0);
    });

    test('transient failure without a copy propagates', () async {
      when(() => api.entitlements(any(), any()))
          .thenThrow(const TransientException(status: 429));
      final c = container();
      await expectLater(
        readListened(c, entitlementsProvider(Fx.puuid).future),
        throwsA(isA<TransientException>()),
      );
    });

    test('content failure surfaces unwrapped', () async {
      when(() => api.entitlements(any(), any())).thenAnswer((_) async => {});
      final c = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: [
          pvpApiProvider.overrideWithValue(api),
          accountProvider.overrideWith((ref, puuid) => null),
          jsonFileCacheProvider.overrideWithValue(
            JsonFileCache(() async => tmp),
          ),
          clockProvider.overrideWithValue(FixedClock(_t0)),
          contentProvider.overrideWith(
            (ref) => Future<ContentDb>.error(const TransientException()),
          ),
        ],
      );
      await expectLater(
        readListened(c, ownedItemsProvider(Fx.puuid).future),
        throwsA(isA<TransientException>()),
      );
    });
  });
}
