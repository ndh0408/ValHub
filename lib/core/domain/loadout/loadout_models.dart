/// Typed, read-only view of a P-8 v3 player loadout (EP §7.1, SUMMARY §8.3).
///
/// The raw map is the source of truth (it is what gets PUT back); these
/// classes only read it. Every field is nullable-safe, ids are lowercased and
/// numbers are read as `num` — a malformed payload yields empty values, never
/// an exception.
library;

import 'package:flutter/foundation.dart';

import '../../riot/riot_ids.dart';
import '../../util/json.dart';

/// Number of slots of the Expressions wheel (top, right, bottom, left).
const kExpressionSlots = 4;

/// Raw keys of the v3 loadout (EP §7.1).
abstract final class LoadoutKeys {
  static const subject = 'Subject';
  static const version = 'Version';
  static const guns = 'Guns';
  static const activeExpressions = 'ActiveExpressions';
  static const identity = 'Identity';
  static const incognito = 'Incognito';

  // Guns[]
  static const gunId = 'ID';
  static const skinId = 'SkinID';
  static const skinLevelId = 'SkinLevelID';
  static const chromaId = 'ChromaID';
  static const charmInstanceId = 'CharmInstanceID';
  static const charmId = 'CharmID';
  static const charmLevelId = 'CharmLevelID';

  /// The three buddy keys (removed together, EP §7.2).
  static const charmKeys = [charmInstanceId, charmId, charmLevelId];

  // ActiveExpressions[]
  static const typeId = 'TypeID';
  static const assetId = 'AssetID';

  // Identity
  static const playerCardId = 'PlayerCardID';
  static const playerTitleId = 'PlayerTitleID';
  static const accountLevel = 'AccountLevel';
  static const preferredLevelBorderId = 'PreferredLevelBorderID';
  static const hideAccountLevel = 'HideAccountLevel';
}

/// One weapon of `Guns[]`.
@immutable
class GunLoadout {
  const GunLoadout({
    required this.weaponId,
    this.skinId,
    this.skinLevelId,
    this.chromaId,
    this.charmInstanceId,
    this.charmId,
    this.charmLevelId,
  });

  /// Parses one `Guns[]` entry; `null` without a weapon id.
  static GunLoadout? fromJson(Object? json) {
    final m = asMap(json);
    final weapon = lowerUuid(m?[LoadoutKeys.gunId]);
    if (m == null || weapon == null) return null;
    return GunLoadout(
      weaponId: weapon,
      skinId: _id(m[LoadoutKeys.skinId]),
      skinLevelId: _id(m[LoadoutKeys.skinLevelId]),
      chromaId: _id(m[LoadoutKeys.chromaId]),
      charmInstanceId: _id(m[LoadoutKeys.charmInstanceId]),
      charmId: _id(m[LoadoutKeys.charmId]),
      charmLevelId: _id(m[LoadoutKeys.charmLevelId]),
    );
  }

  /// Weapon uuid (`/v1/weapons`).
  final String weaponId;

  /// Equipped skin uuid.
  final String? skinId;

  /// Equipped skin level uuid.
  final String? skinLevelId;

  /// Equipped chroma uuid.
  final String? chromaId;

  /// Buddy copy (entitlement `InstanceID`).
  final String? charmInstanceId;

  /// Buddy uuid (`/v1/buddies`).
  final String? charmId;

  /// Buddy LEVEL uuid (entitlement `ItemID`).
  final String? charmLevelId;

  bool get hasBuddy => charmInstanceId != null || charmLevelId != null;

  bool get isMelee => weaponId == SpecialIds.melee;

  @override
  bool operator ==(Object other) =>
      other is GunLoadout &&
      other.weaponId == weaponId &&
      other.skinId == skinId &&
      other.skinLevelId == skinLevelId &&
      other.chromaId == chromaId &&
      other.charmInstanceId == charmInstanceId &&
      other.charmId == charmId &&
      other.charmLevelId == charmLevelId;

  @override
  int get hashCode => Object.hash(
    weaponId,
    skinId,
    skinLevelId,
    chromaId,
    charmInstanceId,
    charmId,
    charmLevelId,
  );

  @override
  String toString() => 'GunLoadout($weaponId, skin: $skinId)';
}

/// What an Expressions-wheel slot holds.
enum ExpressionType {
  spray(ItemTypeIds.spray),
  flex(ItemTypeIds.flex),
  unknown('');

  const ExpressionType(this.typeId);

  /// `ActiveExpressions[].TypeID`.
  final String typeId;

  static ExpressionType parse(String? typeId) => switch (typeId) {
    ItemTypeIds.spray => spray,
    ItemTypeIds.flex => flex,
    _ => unknown,
  };
}

/// One Expressions-wheel entry (`{TypeID, AssetID}`, U7).
@immutable
class Expression {
  const Expression({required this.typeId, required this.assetId});

  const Expression.spray(this.assetId) : typeId = ItemTypeIds.spray;

  const Expression.flex(this.assetId) : typeId = ItemTypeIds.flex;

  /// Parses `{TypeID, AssetID}` (also the match-loadout
  /// `AESSelections[]` / `SpraySelections[]` shapes); `null` without an
  /// asset.
  static Expression? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final asset = _id(m[LoadoutKeys.assetId]) ?? _id(m['SprayID']);
    if (asset == null) return null;
    final type =
        _id(m[LoadoutKeys.typeId]) ??
        (m.containsKey('SprayID') ? ItemTypeIds.spray : null);
    return Expression(typeId: type ?? ItemTypeIds.spray, assetId: asset);
  }

  final String typeId;

  /// Spray or flex uuid.
  final String assetId;

  ExpressionType get type => ExpressionType.parse(typeId);
  bool get isSpray => type == ExpressionType.spray;
  bool get isFlex => type == ExpressionType.flex;

  /// The null spray ("Không có").
  bool get isEmpty => isSpray && assetId == SpecialIds.nullSpray;

  JsonMap toJson() => {
    LoadoutKeys.typeId: typeId,
    LoadoutKeys.assetId: assetId,
  };

  @override
  bool operator ==(Object other) =>
      other is Expression && other.typeId == typeId && other.assetId == assetId;

  @override
  int get hashCode => Object.hash(typeId, assetId);

  @override
  String toString() => 'Expression(${type.name}, $assetId)';
}

/// `Identity` of the loadout (also `PlayerIdentity` in live-game payloads).
@immutable
class LoadoutIdentity {
  const LoadoutIdentity({
    this.playerCardId,
    this.playerTitleId,
    this.preferredLevelBorderId,
    this.hideAccountLevel = false,
    this.accountLevel,
  });

  static LoadoutIdentity fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    return LoadoutIdentity(
      playerCardId: _id(m[LoadoutKeys.playerCardId]),
      playerTitleId: _id(m[LoadoutKeys.playerTitleId]),
      preferredLevelBorderId: _id(m[LoadoutKeys.preferredLevelBorderId]),
      hideAccountLevel: asBool(m[LoadoutKeys.hideAccountLevel]) ?? false,
      accountLevel: asInt(m[LoadoutKeys.accountLevel]),
    );
  }

  final String? playerCardId;
  final String? playerTitleId;

  /// `null` or the all-zero uuid = automatic border.
  final String? preferredLevelBorderId;
  final bool hideAccountLevel;

  /// NOT reliable in P-8 (0 in real responses): use account-xp (P-9).
  final int? accountLevel;

  /// Whether the level border follows the account level.
  bool get isAutoLevelBorder =>
      preferredLevelBorderId == null ||
      preferredLevelBorderId == SpecialIds.autoLevelBorder;

  /// Title uuid with the "no title" fallback.
  String get titleOrNone => playerTitleId ?? SpecialIds.noTitle;

  @override
  bool operator ==(Object other) =>
      other is LoadoutIdentity &&
      other.playerCardId == playerCardId &&
      other.playerTitleId == playerTitleId &&
      other.preferredLevelBorderId == preferredLevelBorderId &&
      other.hideAccountLevel == hideAccountLevel &&
      other.accountLevel == accountLevel;

  @override
  int get hashCode => Object.hash(
    playerCardId,
    playerTitleId,
    preferredLevelBorderId,
    hideAccountLevel,
    accountLevel,
  );
}

/// Read-only view of the whole P-8 v3 loadout.
@immutable
class Loadout {
  const Loadout({
    this.subject,
    this.version,
    this.guns = const [],
    this.expressions = const [],
    this.identity = const LoadoutIdentity(),
    this.incognito = false,
  });

  /// Parses a P-8 body. Never throws; unknown keys are ignored here (they
  /// stay in the raw map, see `LoadoutSnapshot.raw`).
  factory Loadout.fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final guns = <GunLoadout>[];
    final seen = <String>{};
    for (final raw in asList(m[LoadoutKeys.guns])) {
      final gun = GunLoadout.fromJson(raw);
      if (gun != null && seen.add(gun.weaponId)) guns.add(gun);
    }
    return Loadout(
      subject: lowerUuid(m[LoadoutKeys.subject]),
      version: asInt(m[LoadoutKeys.version]),
      guns: List.unmodifiable(guns),
      expressions: List.unmodifiable([
        for (final raw in asList(m[LoadoutKeys.activeExpressions]))
          Expression.fromJson(raw),
      ]),
      identity: LoadoutIdentity.fromJson(m[LoadoutKeys.identity]),
      incognito: asBool(m[LoadoutKeys.incognito]) ?? false,
    );
  }

  final String? subject;

  /// Optimistic-concurrency counter; bumps on every accepted change.
  final int? version;

  /// Every weapon Riot returned, in Riot's order (never hard-code the count).
  final List<GunLoadout> guns;

  /// `ActiveExpressions` in slot order (index = slot). Malformed entries
  /// keep their position as `null`.
  final List<Expression?> expressions;

  final LoadoutIdentity identity;

  /// "Hide my name" (streamer mode).
  final bool incognito;

  /// The gun entry of [weaponId] (any case).
  GunLoadout? gun(String weaponId) {
    final id = weaponId.trim().toLowerCase();
    for (final g in guns) {
      if (g.weaponId == id) return g;
    }
    return null;
  }

  /// Wheel slot [slot] (0 = top, 1 = right, 2 = bottom, 3 = left).
  Expression? expression(int slot) =>
      slot >= 0 && slot < expressions.length ? expressions[slot] : null;

  /// The weapon a buddy copy is attached to.
  String? weaponWithBuddyInstance(String instanceId) {
    final id = instanceId.trim().toLowerCase();
    for (final g in guns) {
      if (g.charmInstanceId == id) return g.weaponId;
    }
    return null;
  }

  /// Buddy copies attached to any gun.
  Set<String> get usedBuddyInstances => {
    for (final g in guns) ?g.charmInstanceId,
  };

  @override
  bool operator ==(Object other) =>
      other is Loadout &&
      other.subject == subject &&
      other.version == version &&
      listEquals(other.guns, guns) &&
      listEquals(other.expressions, expressions) &&
      other.identity == identity &&
      other.incognito == incognito;

  @override
  int get hashCode => Object.hash(
    subject,
    version,
    Object.hashAll(guns),
    Object.hashAll(expressions),
    identity,
    incognito,
  );
}

/// A fetched loadout: the RAW map (round-tripped on PUT, unknown keys
/// included) plus its typed view.
@immutable
class LoadoutSnapshot {
  const LoadoutSnapshot._({
    required this.raw,
    required this.loadout,
    required this.receivedAt,
    this.isFromCache = false,
    this.isPending = false,
  });

  /// Wraps a P-8 body. [json] is deep-copied, so later edits of the caller's
  /// map cannot leak in.
  factory LoadoutSnapshot.fromJson(
    Object? json, {
    required DateTime receivedAt,
    bool isFromCache = false,
    bool isPending = false,
  }) {
    final raw = deepCopyJsonMap(asMap(json) ?? const <String, dynamic>{});
    return LoadoutSnapshot._(
      raw: raw,
      loadout: Loadout.fromJson(raw),
      receivedAt: receivedAt,
      isFromCache: isFromCache,
      isPending: isPending,
    );
  }

  /// The body exactly as Riot sent it. Treat as read-only: edits go through
  /// `LoadoutChange` on a deep copy.
  final JsonMap raw;
  final Loadout loadout;
  final DateTime receivedAt;

  /// Served from the offline copy after a transient failure (X4). Never PUT
  /// from it (the repository always re-GETs first).
  final bool isFromCache;

  /// An optimistic value while a save is in flight.
  final bool isPending;

  /// Whether the payload looked like a loadout at all.
  bool get isValid => raw[LoadoutKeys.guns] is List;

  LoadoutSnapshot copyWith({bool? isFromCache, bool? isPending}) =>
      LoadoutSnapshot._(
        raw: raw,
        loadout: loadout,
        receivedAt: receivedAt,
        isFromCache: isFromCache ?? this.isFromCache,
        isPending: isPending ?? this.isPending,
      );
}

/// Deep copy of a decoded JSON map (maps and lists copied, leaves shared).
JsonMap deepCopyJsonMap(Map<dynamic, dynamic> source) => {
  for (final e in source.entries)
    if (e.key is String) e.key as String: _deepCopy(e.value),
};

Object? _deepCopy(Object? value) => switch (value) {
  final Map<dynamic, dynamic> m => deepCopyJsonMap(m),
  final List<dynamic> l => [for (final v in l) _deepCopy(v)],
  _ => value,
};

/// Lowercase id; `null` for missing / empty values.
String? _id(Object? value) {
  final id = lowerUuid(value);
  return id == null || id.isEmpty ? null : id;
}
