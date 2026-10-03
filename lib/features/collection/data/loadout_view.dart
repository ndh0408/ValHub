/// Content lookups for what a gun has equipped (S33–S35).
library;

import '../../../core/content/content_db.dart';
import '../../../core/domain/loadout/loadout.dart';

/// The skin equipped on [gun] (by skin, level or chroma uuid).
WeaponSkin? equippedSkin(GunLoadout? gun, ContentDb db) {
  if (gun == null) return null;
  for (final id in [gun.skinId, gun.skinLevelId, gun.chromaId]) {
    if (id == null) continue;
    final skin = db.skinByAnyUuid(id);
    if (skin != null) return skin;
  }
  return null;
}

/// Best render of what [gun] shows in game: the equipped chroma's render,
/// then the level icon, the skin image and finally the weapon icon.
String? gunRender(GunLoadout? gun, ContentDb db, {Weapon? weapon}) {
  if (gun != null) {
    final chroma = gun.chromaId == null ? null : db.skinChroma(gun.chromaId!);
    final level = gun.skinLevelId == null
        ? null
        : db.skinLevel(gun.skinLevelId!);
    final render =
        chroma?.fullRender ??
        chroma?.displayIcon ??
        level?.displayIcon ??
        equippedSkin(gun, db)?.image;
    if (render != null) return render;
  }
  return weapon?.displayIcon;
}

/// Buddy attached to [gun].
Buddy? equippedBuddy(GunLoadout? gun, ContentDb db) {
  if (gun == null) return null;
  if (gun.charmLevelId case final level?) {
    final buddy = db.buddyByLevelUuid(level);
    if (buddy != null) return buddy;
  }
  return gun.charmId == null ? null : db.buddy(gun.charmId!);
}
