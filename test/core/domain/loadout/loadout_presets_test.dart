import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/domain/loadout/loadout.dart';
import 'package:valvn/core/riot/riot_ids.dart';

import '../economy/economy_fixtures.dart';
import 'loadout_fixtures.dart';

OwnedItems fixtureOwned() => OwnedItems.resolve(
  Entitlements.fromTypeResponses({
    for (final type in ItemTypeIds.collectionTypes) type: entitlementsFor(type),
  }, receivedAt: DateTime(2026)),
  economyContent(),
);

void main() {
  final createdAt = DateTime(2026, 9, 29, 8);

  test('snapshot round-trips through JSON', () {
    final loadout = Loadout.fromJson(loadoutJson());
    final preset = LoadoutPreset.fromLoadout(
      loadout,
      id: 'p1',
      name: 'Rank',
      createdAt: createdAt,
    );
    final back = LoadoutPreset.fromJson(preset.toJson())!;
    expect(back.id, 'p1');
    expect(back.name, 'Rank');
    expect(back.createdAt, createdAt);
    expect(back.guns, preset.guns);
    expect(back.expressions, loadout.expressions);
    expect(back.cardId, Fx.cardNgoiSang);
    expect(back.titleId, Fx.titleTaiLoc);
    expect(back.levelBorderId, SpecialIds.autoLevelBorder);
    expect(back.gun(Lx.vandal)!.hasBuddy, isTrue);
    expect(back.gun(Lx.melee)!.hasBuddy, isFalse);
    expect(back.copyWith(name: 'X').name, 'X');
  });

  test('toChange applies the preset exactly on another loadout', () {
    final original = Loadout.fromJson(loadoutJson());
    final preset = LoadoutPreset.fromLoadout(
      original,
      id: 'p1',
      name: 'Rank',
      createdAt: createdAt,
    );
    final other = LoadoutChange.all([
      const EquipBuddy(
        weaponId: Lx.phantom,
        buddyId: Fx.neoFrontierBuddy,
        buddyLevelId: Fx.neoFrontierBuddyL1,
        instanceId: Lx.buddyInstanceB,
      ),
      const RemoveBuddy(weaponId: Lx.vandal),
      const SetPlayerTitle.none(),
    ]).appliedTo(loadoutJson());
    final app = preset.toChange();
    expect(app.skipped, 0);
    final result = Loadout.fromJson(app.change.appliedTo(other));
    expect(result.guns, original.guns);
    expect(result.identity.playerTitleId, Fx.titleTaiLoc);
    expect(app.change.isReflectedIn(result), isTrue);
  });

  test('toChange(owned:) leaves out items the account lost', () {
    final raw = LoadoutChange.all(const [
      EquipSkin(
        weaponId: Lx.vandal,
        skinId: Fx.reaverVandal,
        skinLevelId: Fx.reaverL4, // only L1–L3 owned
        chromaId: Fx.reaverChroma3,
      ),
      EquipBuddy(
        weaponId: Lx.phantom,
        buddyId: Fx.neoFrontierBuddy,
        buddyLevelId: Fx.neoFrontierBuddyL1,
        instanceId: 'deadbeef-0000-4000-8000-000000000000',
      ),
    ]).appliedTo(loadoutJson());
    final preset = LoadoutPreset.fromLoadout(
      Loadout.fromJson(raw),
      id: 'p',
      name: 'n',
      createdAt: createdAt,
    );
    final app = preset.toChange(owned: fixtureOwned());
    // Reaver L4, the unknown buddy copy and the Cypher spray (not owned).
    expect(app.skipped, 3);

    final result = Loadout.fromJson(app.change.appliedTo(loadoutJson()));
    expect(result.gun(Lx.vandal)!.skinId, Fx.vandalStandard);
    expect(result.expression(3), const Expression.spray(Lx.sprayB));
  });

  test('normalizePresetName', () {
    expect(normalizePresetName(null), isNull);
    expect(normalizePresetName('   '), isNull);
    expect(normalizePresetName(' a \n b '), 'a b');
    expect(normalizePresetName('x' * 60), hasLength(kPresetNameMaxLength));
  });
}
