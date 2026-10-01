/// Local loadout presets per account (SUMMARY §8.3 U6: Riot has no preset
/// API). A preset is a snapshot of `Guns` / `ActiveExpressions` / identity;
/// applying it is ONE PUT built from a fresh GET.
library;

import 'package:flutter/foundation.dart';

import '../../riot/riot_ids.dart';
import '../../storage/prefs.dart';
import '../../util/json.dart';
import '../economy/owned_items.dart';
import 'loadout_changes.dart';
import 'loadout_models.dart';

/// Maximum number of presets per account.
const kMaxLoadoutPresets = 50;

/// Maximum preset name length (characters).
const kPresetNameMaxLength = 40;

/// One weapon of a preset.
@immutable
class PresetGun {
  const PresetGun({
    required this.weaponId,
    this.skinId,
    this.skinLevelId,
    this.chromaId,
    this.buddyId,
    this.buddyLevelId,
    this.buddyInstanceId,
  });

  factory PresetGun.fromGun(GunLoadout gun) => PresetGun(
    weaponId: gun.weaponId,
    skinId: gun.skinId,
    skinLevelId: gun.skinLevelId,
    chromaId: gun.chromaId,
    buddyId: gun.charmId,
    buddyLevelId: gun.charmLevelId,
    buddyInstanceId: gun.charmInstanceId,
  );

  static PresetGun? fromJson(Object? json) {
    final m = asMap(json);
    final weapon = lowerUuid(m?['w']);
    if (m == null || weapon == null || weapon.isEmpty) return null;
    return PresetGun(
      weaponId: weapon,
      skinId: _id(m['s']),
      skinLevelId: _id(m['l']),
      chromaId: _id(m['c']),
      buddyId: _id(m['b']),
      buddyLevelId: _id(m['bl']),
      buddyInstanceId: _id(m['bi']),
    );
  }

  final String weaponId;
  final String? skinId;
  final String? skinLevelId;
  final String? chromaId;
  final String? buddyId;
  final String? buddyLevelId;
  final String? buddyInstanceId;

  bool get hasSkin => skinId != null && skinLevelId != null && chromaId != null;

  bool get hasBuddy =>
      buddyId != null && buddyLevelId != null && buddyInstanceId != null;

  JsonMap toJson() => {
    'w': weaponId,
    'l': ?skinLevelId,
    's': ?skinId,
    'c': ?chromaId,
    'b': ?buddyId,
    'bl': ?buddyLevelId,
    'bi': ?buddyInstanceId,
  };

  @override
  bool operator ==(Object other) =>
      other is PresetGun &&
      other.weaponId == weaponId &&
      other.skinId == skinId &&
      other.skinLevelId == skinLevelId &&
      other.chromaId == chromaId &&
      other.buddyId == buddyId &&
      other.buddyLevelId == buddyLevelId &&
      other.buddyInstanceId == buddyInstanceId;

  @override
  int get hashCode => Object.hash(
    weaponId,
    skinId,
    skinLevelId,
    chromaId,
    buddyId,
    buddyLevelId,
    buddyInstanceId,
  );
}

/// The change that applies a preset, and how many saved items were left out
/// because the account no longer owns them.
@immutable
class PresetApplication {
  const PresetApplication(this.change, {this.skipped = 0});

  final LoadoutChange change;
  final int skipped;
}

/// A saved loadout.
@immutable
class LoadoutPreset {
  const LoadoutPreset({
    required this.id,
    required this.name,
    required this.createdAt,
    this.guns = const [],
    this.expressions = const [],
    this.cardId,
    this.titleId,
    this.levelBorderId,
    this.defaultNumber,
  });

  /// Snapshot of [loadout]. [defaultNumber] is the N of an automatic name
  /// ("Bộ trang bị N"), `null` for a name the user typed.
  factory LoadoutPreset.fromLoadout(
    Loadout loadout, {
    required String id,
    required String name,
    required DateTime createdAt,
    int? defaultNumber,
  }) => LoadoutPreset(
    id: id,
    name: name,
    createdAt: createdAt,
    defaultNumber: defaultNumber,
    guns: List.unmodifiable(loadout.guns.map(PresetGun.fromGun)),
    expressions: List.unmodifiable(loadout.expressions),
    cardId: loadout.identity.playerCardId,
    titleId: loadout.identity.playerTitleId,
    levelBorderId: loadout.identity.preferredLevelBorderId,
  );

  /// Parses a stored preset; `null` when unusable.
  static LoadoutPreset? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    if (m == null || id == null) return null;
    return LoadoutPreset(
      id: id,
      name: asNonEmptyString(m['name']) ?? '',
      createdAt:
          asDateTime(m['createdAt'])?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      guns: List.unmodifiable([
        for (final g in asList(m['guns'])) ?PresetGun.fromJson(g),
      ]),
      expressions: List.unmodifiable([
        for (final e in asList(m['expressions'])) Expression.fromJson(e),
      ]),
      cardId: _id(m['card']),
      titleId: _id(m['title']),
      levelBorderId: _id(m['border']),
      defaultNumber: switch (asInt(m['dn'])) {
        final n? when n > 0 => n,
        _ => null,
      },
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final List<PresetGun> guns;

  /// Wheel slots in order (`null` = slot left as is).
  final List<Expression?> expressions;
  final String? cardId;
  final String? titleId;
  final String? levelBorderId;

  /// N of an automatic name ("Bộ trang bị 3"), `null` when the user typed
  /// the name. The name itself is user data and keeps the language it was
  /// created in; the number is what keeps automatic names unique in every
  /// language (GL-24, GL-38).
  final int? defaultNumber;

  PresetGun? gun(String weaponId) {
    final id = weaponId.trim().toLowerCase();
    for (final g in guns) {
      if (g.weaponId == id) return g;
    }
    return null;
  }

  /// A copy with a new [name]: a name the user typed has no default number.
  LoadoutPreset copyWith({String? name}) => LoadoutPreset(
    id: id,
    name: name ?? this.name,
    createdAt: createdAt,
    guns: guns,
    expressions: expressions,
    cardId: cardId,
    titleId: titleId,
    levelBorderId: levelBorderId,
    defaultNumber: name == null ? defaultNumber : null,
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    'guns': [for (final g in guns) g.toJson()],
    'expressions': [for (final e in expressions) e?.toJson()],
    'card': ?cardId,
    'title': ?titleId,
    'border': ?levelBorderId,
    'dn': ?defaultNumber,
  };

  /// The single composite change that applies this preset.
  ///
  /// With [owned], items the account no longer owns are left out (Riot
  /// rejects the whole PUT otherwise) and counted in
  /// [PresetApplication.skipped]. Weapons missing from the fresh loadout are
  /// skipped silently.
  PresetApplication toChange({OwnedItems? owned}) {
    final changes = <LoadoutChange>[];
    var skipped = 0;
    for (final g in guns) {
      if (g.hasSkin) {
        final ok =
            owned == null ||
            (owned.isSkinOwned(g.skinId!) &&
                owned.isSkinLevelOwned(g.skinLevelId!) &&
                owned.isChromaOwned(g.chromaId!));
        if (ok) {
          changes.add(
            EquipSkin(
              weaponId: g.weaponId,
              skinId: g.skinId!,
              skinLevelId: g.skinLevelId!,
              chromaId: g.chromaId!,
            ),
          );
        } else {
          skipped++;
        }
      }
    }
    // Buddies after skins: removals first, so a copy moved between guns in
    // the preset is never detached from its new gun by a later removal.
    for (final g in guns) {
      if (g.weaponId == SpecialIds.melee || g.hasBuddy) continue;
      changes.add(RemoveBuddy(weaponId: g.weaponId));
    }
    for (final g in guns) {
      if (g.weaponId == SpecialIds.melee || !g.hasBuddy) continue;
      final ok =
          owned == null ||
          owned.buddyInstances(g.buddyLevelId!).contains(g.buddyInstanceId);
      if (!ok) {
        skipped++;
        continue;
      }
      changes.add(
        EquipBuddy(
          weaponId: g.weaponId,
          buddyId: g.buddyId!,
          buddyLevelId: g.buddyLevelId!,
          instanceId: g.buddyInstanceId!,
        ),
      );
    }
    for (var slot = 0; slot < expressions.length; slot++) {
      final e = expressions[slot];
      if (e == null) continue;
      final ok =
          owned == null ||
          switch (e.type) {
            ExpressionType.spray => owned.isSprayOwned(e.assetId),
            ExpressionType.flex => owned.isFlexOwned(e.assetId),
            ExpressionType.unknown => true,
          };
      if (!ok) {
        skipped++;
        continue;
      }
      changes.add(SetExpression(slot: slot, expression: e));
    }
    if (cardId case final card?) {
      if (owned == null || owned.isPlayerCardOwned(card)) {
        changes.add(SetPlayerCard(card));
      } else {
        skipped++;
      }
    }
    final title = titleId ?? SpecialIds.noTitle;
    if (owned == null || owned.isTitleOwned(title)) {
      changes.add(SetPlayerTitle(title));
    } else {
      skipped++;
    }
    changes.add(SetLevelBorder(levelBorderId));
    return PresetApplication(
      LoadoutChange.all(changes, skipInapplicable: true),
      skipped: skipped,
    );
  }
}

/// Stores presets under `keep.<puuid>.loadoutPresets` (they survive
/// sign-out like the wishlist, so a re-login finds them again).
class LoadoutPresetStore {
  LoadoutPresetStore(this._prefs);

  final Prefs _prefs;

  static String key(String puuid) =>
      PrefKeys.accountKept(puuid.trim().toLowerCase(), 'loadoutPresets');

  /// Stored presets in stored order (newest first); corrupt entries dropped.
  List<LoadoutPreset> read(String puuid) {
    final seen = <String>{};
    return List.unmodifiable([
      for (final raw in asList(_prefs.getJson(key(puuid))))
        if (LoadoutPreset.fromJson(raw) case final p? when seen.add(p.id)) p,
    ]);
  }

  Future<void> write(String puuid, List<LoadoutPreset> presets) =>
      _prefs.setJson(key(puuid), [for (final p in presets) p.toJson()]);
}

/// The N of the next automatic preset name: the smallest number from
/// `presets.length + 1` up that no preset already uses.
///
/// Compared by NUMBER ([LoadoutPreset.defaultNumber]), never by the text of
/// a name, so "Bộ trang bị 2" and "Preset 2" cannot both exist after a
/// language switch. Presets saved before numbers were stored have none: for
/// them only, [legacyName] (the current language's default text for a
/// number) is compared with their name.
int nextDefaultPresetNumber(
  List<LoadoutPreset> presets, {
  String Function(int n)? legacyName,
}) {
  final taken = {
    for (final p in presets)
      if (p.defaultNumber != null) p.defaultNumber!,
  };
  final legacyNames = {
    for (final p in presets)
      if (p.defaultNumber == null) p.name,
  };
  var n = presets.length + 1;
  while (taken.contains(n) ||
      (legacyName != null && legacyNames.contains(legacyName(n)))) {
    n++;
  }
  return n;
}

/// Normalises a user-typed preset name (trimmed, single spaces, capped);
/// `null` when empty.
String? normalizePresetName(String? input) {
  final cleaned = (input ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  if (cleaned.isEmpty) return null;
  final chars = cleaned.runes.toList();
  return chars.length <= kPresetNameMaxLength
      ? cleaned
      : String.fromCharCodes(chars.take(kPresetNameMaxLength)).trim();
}

String? _id(Object? value) {
  final id = lowerUuid(value);
  return id == null || id.isEmpty ? null : id;
}
