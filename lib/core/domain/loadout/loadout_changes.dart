/// Targeted edits of the RAW v3 loadout (EP §7.2 recipes, SUMMARY U8).
///
/// Each change mutates only the keys it owns on a deep copy of a FRESH GET;
/// every other key (unknown 13.06 fields included) round-trips untouched.
library;

import 'package:flutter/foundation.dart';

import '../../riot/riot_ids.dart';
import '../../util/json.dart';
import 'loadout_models.dart';

/// Why a change cannot be applied to a loadout.
enum LoadoutEditError {
  /// The weapon is not in `Guns` (never add guns ourselves).
  unknownWeapon,

  /// Melee never carries a buddy.
  meleeBuddy,

  /// Wheel slot outside 0…3 (or the current length).
  invalidSlot,

  /// Missing / malformed id.
  invalidId,
}

/// Thrown by [LoadoutChange.applyTo] when the change does not fit the loadout.
class LoadoutEditException implements Exception {
  const LoadoutEditException(this.error, [this.detail]);

  final LoadoutEditError error;
  final String? detail;

  @override
  String toString() => 'LoadoutEditException(${error.name}, $detail)';
}

/// One user-initiated edit of the loadout.
///
/// ```dart
/// final change = LoadoutChange.all([
///   EquipSkin(weaponId: vandal, skinId: s, skinLevelId: l, chromaId: c),
///   EquipBuddy(weaponId: vandal, buddyId: b, buddyLevelId: bl, instanceId: i),
/// ]);
/// await ref.read(loadoutProvider(puuid).notifier).apply(change);
/// ```
@immutable
sealed class LoadoutChange {
  const LoadoutChange();

  /// Applies several changes in order. With [skipInapplicable] a change that
  /// throws [LoadoutEditException] is skipped instead of failing the batch
  /// (presets saved before a new weapon was added, …).
  const factory LoadoutChange.all(
    List<LoadoutChange> changes, {
    bool skipInapplicable,
  }) = CompositeChange;

  /// Mutates [raw] in place. Throws [LoadoutEditException].
  void applyTo(JsonMap raw);

  /// Whether [loadout] already shows this change (no-op detection and the
  /// verification fallback when Riot sends no `Version`).
  bool isReflectedIn(Loadout loadout);

  /// Returns a mutated deep copy of [raw]; [raw] is untouched.
  JsonMap appliedTo(JsonMap raw) {
    final copy = deepCopyJsonMap(raw);
    applyTo(copy);
    return copy;
  }
}

/// Sets `SkinID`, `SkinLevelID` and `ChromaID` of one gun (EP §7.2 "Weapon
/// skin"). Use it for a level-only or chroma-only change too.
final class EquipSkin extends LoadoutChange {
  const EquipSkin({
    required this.weaponId,
    required this.skinId,
    required this.skinLevelId,
    required this.chromaId,
  });

  final String weaponId;
  final String skinId;
  final String skinLevelId;
  final String chromaId;

  @override
  void applyTo(JsonMap raw) {
    final skin = _requireId(skinId);
    final level = _requireId(skinLevelId);
    final chroma = _requireId(chromaId);
    final gun = _gunOf(raw, weaponId);
    gun[LoadoutKeys.skinId] = skin;
    gun[LoadoutKeys.skinLevelId] = level;
    gun[LoadoutKeys.chromaId] = chroma;
  }

  @override
  bool isReflectedIn(Loadout loadout) {
    final gun = loadout.gun(weaponId);
    return gun != null &&
        gun.skinId == _k(skinId) &&
        gun.skinLevelId == _k(skinLevelId) &&
        gun.chromaId == _k(chromaId);
  }
}

/// Attaches a buddy copy to a gun. The same copy is removed from any other
/// gun first (one instance = one gun, EP §7.2 "Buddy").
final class EquipBuddy extends LoadoutChange {
  const EquipBuddy({
    required this.weaponId,
    required this.buddyId,
    required this.buddyLevelId,
    required this.instanceId,
  });

  final String weaponId;

  /// `CharmID` (buddy uuid).
  final String buddyId;

  /// `CharmLevelID` (entitlement `ItemID`).
  final String buddyLevelId;

  /// `CharmInstanceID` (entitlement `InstanceID`).
  final String instanceId;

  @override
  void applyTo(JsonMap raw) {
    if (_k(weaponId) == SpecialIds.melee) {
      throw const LoadoutEditException(LoadoutEditError.meleeBuddy);
    }
    final buddy = _requireId(buddyId);
    final level = _requireId(buddyLevelId);
    final instance = _requireId(instanceId);
    final target = _gunOf(raw, weaponId);
    for (final gun in _guns(raw)) {
      if (identical(gun, target)) continue;
      if (lowerUuid(gun[LoadoutKeys.charmInstanceId]) == instance) {
        LoadoutKeys.charmKeys.forEach(gun.remove);
      }
    }
    target[LoadoutKeys.charmInstanceId] = instance;
    target[LoadoutKeys.charmId] = buddy;
    target[LoadoutKeys.charmLevelId] = level;
  }

  @override
  bool isReflectedIn(Loadout loadout) {
    final gun = loadout.gun(weaponId);
    if (gun == null || gun.charmInstanceId != _k(instanceId)) return false;
    return loadout.guns
        .where((g) => g.charmInstanceId == _k(instanceId))
        .every((g) => g.weaponId == gun.weaponId);
  }
}

/// Removes the buddy of a gun (deletes the three `Charm*` keys).
final class RemoveBuddy extends LoadoutChange {
  const RemoveBuddy({required this.weaponId});

  final String weaponId;

  @override
  void applyTo(JsonMap raw) {
    final gun = _gunOf(raw, weaponId);
    LoadoutKeys.charmKeys.forEach(gun.remove);
  }

  @override
  bool isReflectedIn(Loadout loadout) =>
      !(loadout.gun(weaponId)?.hasBuddy ?? true);
}

/// `Identity.PlayerCardID`.
final class SetPlayerCard extends LoadoutChange {
  const SetPlayerCard(this.cardId);

  final String cardId;

  @override
  void applyTo(JsonMap raw) =>
      _identityOf(raw)[LoadoutKeys.playerCardId] = _requireId(cardId);

  @override
  bool isReflectedIn(Loadout loadout) =>
      loadout.identity.playerCardId == _k(cardId);
}

/// `Identity.PlayerTitleID` (`SpecialIds.noTitle` = "Không có danh hiệu").
final class SetPlayerTitle extends LoadoutChange {
  const SetPlayerTitle(this.titleId);

  const SetPlayerTitle.none() : titleId = SpecialIds.noTitle;

  final String titleId;

  @override
  void applyTo(JsonMap raw) =>
      _identityOf(raw)[LoadoutKeys.playerTitleId] = _requireId(titleId);

  @override
  bool isReflectedIn(Loadout loadout) =>
      loadout.identity.titleOrNone == _k(titleId);
}

/// `Identity.PreferredLevelBorderID`; `null` = automatic (all-zero uuid).
final class SetLevelBorder extends LoadoutChange {
  const SetLevelBorder(this.borderId);

  const SetLevelBorder.auto() : borderId = null;

  final String? borderId;

  String get _value {
    final id = borderId == null ? null : _k(borderId!);
    return id == null || id.isEmpty ? SpecialIds.autoLevelBorder : id;
  }

  @override
  void applyTo(JsonMap raw) =>
      _identityOf(raw)[LoadoutKeys.preferredLevelBorderId] = _value;

  @override
  bool isReflectedIn(Loadout loadout) {
    final current =
        loadout.identity.preferredLevelBorderId ?? SpecialIds.autoLevelBorder;
    return current == _value;
  }
}

/// `Identity.HideAccountLevel`.
final class SetHideAccountLevel extends LoadoutChange {
  const SetHideAccountLevel(this.hide);

  final bool hide;

  @override
  void applyTo(JsonMap raw) =>
      _identityOf(raw)[LoadoutKeys.hideAccountLevel] = hide;

  @override
  bool isReflectedIn(Loadout loadout) =>
      loadout.identity.hideAccountLevel == hide;
}

/// Top-level `Incognito`.
final class SetIncognito extends LoadoutChange {
  const SetIncognito(this.incognito);

  final bool incognito;

  @override
  void applyTo(JsonMap raw) => raw[LoadoutKeys.incognito] = incognito;

  @override
  bool isReflectedIn(Loadout loadout) => loadout.incognito == incognito;
}

/// `ActiveExpressions[slot] = {TypeID, AssetID}` (U7). Missing slots before
/// [slot] are filled with the null spray so the array keeps its order.
final class SetExpression extends LoadoutChange {
  const SetExpression({required this.slot, required this.expression});

  SetExpression.spray(this.slot, String sprayId)
    : expression = Expression.spray(sprayId);

  SetExpression.flex(this.slot, String flexId)
    : expression = Expression.flex(flexId);

  /// 0 = top, 1 = right, 2 = bottom, 3 = left.
  final int slot;
  final Expression expression;

  @override
  void applyTo(JsonMap raw) {
    final list = <Object?>[...asList(raw[LoadoutKeys.activeExpressions])];
    final slots = list.length > kExpressionSlots
        ? list.length
        : kExpressionSlots;
    if (slot < 0 || slot >= slots) {
      throw LoadoutEditException(LoadoutEditError.invalidSlot, '$slot');
    }
    final type = _requireId(expression.typeId);
    final asset = _requireId(expression.assetId);
    while (list.length <= slot) {
      list.add(const Expression.spray(SpecialIds.nullSpray).toJson());
    }
    // Keep unknown keys of the slot object.
    list[slot] = <String, dynamic>{
      ...?asMap(list[slot]),
      LoadoutKeys.typeId: type,
      LoadoutKeys.assetId: asset,
    };
    raw[LoadoutKeys.activeExpressions] = list;
  }

  @override
  bool isReflectedIn(Loadout loadout) =>
      loadout.expression(slot) ==
      Expression(
        typeId: _k(expression.typeId),
        assetId: _k(expression.assetId),
      );
}

/// Several changes applied in order (preset apply = one PUT).
final class CompositeChange extends LoadoutChange {
  const CompositeChange(this.changes, {this.skipInapplicable = false});

  final List<LoadoutChange> changes;
  final bool skipInapplicable;

  @override
  void applyTo(JsonMap raw) {
    for (final change in changes) {
      if (!skipInapplicable) {
        change.applyTo(raw);
        continue;
      }
      // Apply on a copy so a failing change leaves no half-applied keys.
      final JsonMap attempt;
      try {
        attempt = change.appliedTo(raw);
      } on LoadoutEditException {
        continue;
      }
      raw
        ..clear()
        ..addAll(attempt);
    }
  }

  @override
  bool isReflectedIn(Loadout loadout) {
    for (final change in changes) {
      if (change.isReflectedIn(loadout)) continue;
      if (skipInapplicable && !_fits(change, loadout)) continue;
      return false;
    }
    return true;
  }

  static bool _fits(LoadoutChange change, Loadout loadout) => switch (change) {
    EquipSkin(:final weaponId) ||
    RemoveBuddy(:final weaponId) => loadout.gun(weaponId) != null,
    EquipBuddy(:final weaponId) =>
      loadout.gun(weaponId) != null && _k(weaponId) != SpecialIds.melee,
    _ => true,
  };
}

// ------------------------------------------------------------------ helpers

String _k(String id) => id.trim().toLowerCase();

String _requireId(String id) {
  final k = _k(id);
  if (k.isEmpty) throw const LoadoutEditException(LoadoutEditError.invalidId);
  return k;
}

/// The mutable `Guns[]` entries of [raw].
Iterable<JsonMap> _guns(JsonMap raw) sync* {
  final guns = raw[LoadoutKeys.guns];
  if (guns is! List<dynamic>) return;
  for (final g in guns) {
    if (g is Map<String, dynamic>) yield g;
  }
}

JsonMap _gunOf(JsonMap raw, String weaponId) {
  final id = _k(weaponId);
  for (final gun in _guns(raw)) {
    if (lowerUuid(gun[LoadoutKeys.gunId]) == id) return gun;
  }
  throw LoadoutEditException(LoadoutEditError.unknownWeapon, id);
}

JsonMap _identityOf(JsonMap raw) {
  final identity = raw[LoadoutKeys.identity];
  if (identity is Map<String, dynamic>) return identity;
  final created = <String, dynamic>{...?asMap(identity)};
  raw[LoadoutKeys.identity] = created;
  return created;
}
