/// Owned buddies with their copies for S36 "Chọn phụ kiện súng" ("Còn 2/3",
/// one copy per gun; SUMMARY §8.3 C4).
library;

import 'package:flutter/foundation.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import 'collection_search.dart';

/// One owned copy of a buddy (entitlement `InstanceID`).
@immutable
class BuddyCopy {
  const BuddyCopy({
    required this.levelUuid,
    required this.instanceId,
    this.equippedOn,
  });

  final String levelUuid;
  final String instanceId;

  /// Weapon uuid the copy is attached to, `null` when free.
  final String? equippedOn;

  bool get isFree => equippedOn == null;
}

/// An owned buddy and its copies.
@immutable
class BuddyOption {
  const BuddyOption({
    required this.buddy,
    required this.copies,
    required this.ownedCount,
  });

  final Buddy buddy;

  /// Copies that can be equipped (with an `InstanceID`).
  final List<BuddyCopy> copies;

  /// Owned copies (entitlement rows); the "m" of "Còn n/m".
  final int ownedCount;

  /// Copies not attached to any gun; the "n" of "Còn n/m".
  int get free => copies.where((c) => c.isFree).length;

  /// Denominator shown to the user.
  int get total => copies.length > ownedCount ? copies.length : ownedCount;

  bool get canEquip => copies.isNotEmpty;

  bool isOn(String weaponId) => copies.any((c) => c.equippedOn == weaponId);

  /// The copy to attach to [weaponId]: the one already on it, else a free
  /// one, else one taken from another gun (the UI asks first); `null` when
  /// no copy can be equipped.
  BuddyCopy? copyFor(String weaponId) {
    for (final c in copies) {
      if (c.equippedOn == weaponId) return c;
    }
    for (final c in copies) {
      if (c.isFree) return c;
    }
    return copies.firstOrNull;
  }

  /// The change attaching [copy] to [weaponId].
  EquipBuddy equipOn(String weaponId, BuddyCopy copy) => EquipBuddy(
    weaponId: weaponId,
    buddyId: buddy.uuid,
    buddyLevelId: copy.levelUuid,
    instanceId: copy.instanceId,
  );
}

/// A buddy choice made in S36 and not saved yet: the customize page (S35)
/// keeps it with the variant and level and saves them together with
/// "Trang bị".
@immutable
sealed class BuddyPick {
  const BuddyPick();

  /// The change that saves this pick on [weaponId].
  LoadoutChange changeFor(String weaponId);

  /// Whether [gun] already shows this pick (nothing to save).
  bool isSavedOn(GunLoadout? gun);
}

/// Attach [copy] of [option]'s buddy.
final class BuddyPickEquip extends BuddyPick {
  const BuddyPickEquip(this.option, this.copy);

  final BuddyOption option;
  final BuddyCopy copy;

  @override
  LoadoutChange changeFor(String weaponId) => option.equipOn(weaponId, copy);

  @override
  bool isSavedOn(GunLoadout? gun) =>
      gun != null &&
      gun.charmInstanceId == copy.instanceId.trim().toLowerCase();
}

/// Take the buddy off the gun.
final class BuddyPickRemove extends BuddyPick {
  const BuddyPickRemove();

  @override
  LoadoutChange changeFor(String weaponId) => RemoveBuddy(weaponId: weaponId);

  @override
  bool isSavedOn(GunLoadout? gun) => !(gun?.hasBuddy ?? false);
}

/// Every owned buddy (content order unknown → sorted by name), with copies
/// marked by the gun they are on in [loadout]. Buddies missing from
/// [db] are skipped.
List<BuddyOption> buddyOptions(
  OwnedItems owned,
  ContentDb db,
  Loadout? loadout,
) {
  final byBuddy = <String, List<String>>{};
  for (final level in owned.buddyLevelUuids) {
    final buddy = db.buddyByLevelUuid(level);
    if (buddy == null) continue;
    byBuddy.putIfAbsent(buddy.uuid, () => []).add(level);
  }
  final out = <BuddyOption>[];
  for (final e in byBuddy.entries) {
    final buddy = db.buddy(e.key);
    if (buddy == null) continue;
    final copies = <BuddyCopy>[];
    var ownedCount = 0;
    for (final level in e.value) {
      ownedCount += owned.entitlements.buddyCopies(level);
      for (final instance in owned.entitlements.buddyInstanceIds(level)) {
        copies.add(
          BuddyCopy(
            levelUuid: level,
            instanceId: instance,
            equippedOn: loadout?.weaponWithBuddyInstance(instance),
          ),
        );
      }
    }
    out.add(
      BuddyOption(
        buddy: buddy,
        copies: List.unmodifiable(copies),
        ownedCount: ownedCount,
      ),
    );
  }
  out.sort((a, b) => compareNames(a.buddy.displayName, b.buddy.displayName));
  return out;
}
