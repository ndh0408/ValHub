import 'package:flutter/foundation.dart';

import '../../riot/riot_ids.dart';
import '../../util/format.dart';
import '../../util/json.dart';

/// `EEquippableCategory::Rifle` → `Rifle`; `null` stays `null`.
String? enumSuffix(Object? value) {
  final s = asNonEmptyString(value);
  if (s == null) return null;
  final i = s.lastIndexOf('::');
  return i < 0 ? s : s.substring(i + 2);
}

/// Cleaned display text (CA §16): trimmed, `null` when empty.
String? cleanText(Object? value) => cleanDisplayText(asString(value));

/// Weapon category keyed by the `category` enum, never by `categoryText`
/// (the vi Shotgun text is broken; SUMMARY §1 #18).
enum WeaponCategory {
  sidearm('Sidearm'),
  smg('SMG'),
  shotgun('Shotgun'),
  rifle('Rifle'),
  sniper('Sniper'),
  heavy('Heavy'),
  melee('Melee'),
  unknown('');

  const WeaponCategory(this.apiName);

  final String apiName;

  static WeaponCategory parse(Object? value) {
    final suffix = enumSuffix(value);
    for (final c in values) {
      if (c.apiName == suffix && c != unknown) return c;
    }
    return unknown;
  }
}

/// One upgrade level of a skin (`skins[].levels[]`).
@immutable
class SkinLevel {
  const SkinLevel({
    required this.uuid,
    required this.index,
    required this.displayName,
    this.description,
    this.levelItem,
    this.displayIcon,
    this.streamedVideo,
  });

  static SkinLevel? fromJson(Object? json, int index) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final raw = asString(m['displayName']) ?? '';
    return SkinLevel(
      uuid: uuid,
      index: index,
      displayName: cleanDisplayText(firstLine(raw)) ?? '',
      description: restLines(raw),
      levelItem: enumSuffix(m['levelItem']),
      displayIcon: asNonEmptyString(m['displayIcon']),
      streamedVideo: asNonEmptyString(m['streamedVideo']),
    );
  }

  final String uuid;

  /// 0-based position (level 1 = index 0).
  final int index;
  final String displayName;

  /// Second+ lines of the vi name (upgrade description), if any.
  final String? description;

  /// `EEquippableSkinLevelItem` suffix (`VFX`, `Finisher`…), `null` for base.
  final String? levelItem;
  final String? displayIcon;

  /// Riot CDN mp4 (URL embeds the patch; do not persist beyond the cache).
  final String? streamedVideo;

  int get levelNumber => index + 1;
}

/// One color variant of a skin (`skins[].chromas[]`); index 0 is the base.
@immutable
class SkinChroma {
  const SkinChroma({
    required this.uuid,
    required this.index,
    required this.displayName,
    required this.label,
    this.displayIcon,
    this.fullRender,
    this.swatch,
    this.streamedVideo,
  });

  static SkinChroma? fromJson(Object? json, int index) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final raw = asString(m['displayName']) ?? '';
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    var label = lines.isEmpty ? '' : lines.last;
    if (label.startsWith('(') && label.endsWith(')')) {
      label = label.substring(1, label.length - 1).trim();
    }
    return SkinChroma(
      uuid: uuid,
      index: index,
      displayName: lines.isEmpty ? '' : lines.first,
      label: label,
      displayIcon: asNonEmptyString(m['displayIcon']),
      fullRender: asNonEmptyString(m['fullRender']),
      swatch: asNonEmptyString(m['swatch']),
      streamedVideo: asNonEmptyString(m['streamedVideo']),
    );
  }

  final String uuid;
  final int index;
  final String displayName;

  /// Variant label (`Dạng 1 Ánh Đỏ`), or the skin name for the base chroma.
  final String label;
  final String? displayIcon;
  final String? fullRender;
  final String? swatch;
  final String? streamedVideo;

  bool get isBase => index == 0;
}

/// A weapon skin with its levels and chromas (`/v1/weapons[].skins[]`).
@immutable
class WeaponSkin {
  const WeaponSkin({
    required this.uuid,
    required this.displayName,
    required this.weaponUuid,
    required this.levels,
    required this.chromas,
    this.themeUuid,
    this.contentTierUuid,
    this.contentEditionUuid,
    this.displayIcon,
    this.wallpaper,
  });

  static WeaponSkin? fromJson(Object? json, String weaponUuid) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final levels = <SkinLevel>[];
    for (final raw in asList(m['levels'])) {
      final level = SkinLevel.fromJson(raw, levels.length);
      if (level != null) levels.add(level);
    }
    final chromas = <SkinChroma>[];
    for (final raw in asList(m['chromas'])) {
      final chroma = SkinChroma.fromJson(raw, chromas.length);
      if (chroma != null) chromas.add(chroma);
    }
    return WeaponSkin(
      uuid: uuid,
      displayName:
          cleanDisplayText(firstLine(asString(m['displayName']) ?? '')) ?? '',
      weaponUuid: weaponUuid,
      levels: levels,
      chromas: chromas,
      themeUuid: lowerUuid(m['themeUuid']),
      contentTierUuid: lowerUuid(m['contentTierUuid']),
      contentEditionUuid: lowerUuid(m['contentEditionUuid']),
      displayIcon: asNonEmptyString(m['displayIcon']),
      wallpaper: asNonEmptyString(m['wallpaper']),
    );
  }

  final String uuid;
  final String displayName;
  final String weaponUuid;
  final List<SkinLevel> levels;
  final List<SkinChroma> chromas;
  final String? themeUuid;
  final String? contentTierUuid;
  final String? contentEditionUuid;
  final String? displayIcon;
  final String? wallpaper;

  /// Level-1 uuid = the id used by the store, night market and bundles.
  String? get level1Uuid => levels.isEmpty ? null : levels.first.uuid;

  /// Default "Standard" skin (always owned; never in entitlements).
  bool get isStandard => themeUuid == SpecialIds.standardSkinTheme;

  /// "Random favorite skin" pseudo-skin (filter out everywhere).
  bool get isRandomFavorite => themeUuid == SpecialIds.randomFavoriteSkinTheme;

  /// Real collectible skin (not Standard / Random favorite).
  bool get isCollectible => !isStandard && !isRandomFavorite;

  bool get isLimitedEdition =>
      contentEditionUuid == ContentTierIds.limitedEdition;

  /// Best image for cards: skin icon → first level icon → base chroma render
  /// (CA §3.2 icon fallback).
  String? get image =>
      displayIcon ??
      levels.firstOrNull?.displayIcon ??
      chromas.firstOrNull?.fullRender ??
      chromas.firstOrNull?.displayIcon;

  /// Large render (base chroma full render → [image]).
  String? get render => chromas.firstOrNull?.fullRender ?? image;

  /// First available preview video (levels, then chromas).
  String? get previewVideo {
    for (final l in levels.reversed) {
      if (l.streamedVideo != null) return l.streamedVideo;
    }
    for (final c in chromas) {
      if (c.streamedVideo != null) return c.streamedVideo;
    }
    return null;
  }
}

/// A weapon (`/v1/weapons`).
@immutable
class Weapon {
  const Weapon({
    required this.uuid,
    required this.displayName,
    required this.category,
    required this.skins,
    this.defaultSkinUuid,
    this.displayIcon,
    this.killStreamIcon,
    this.shopCost,
  });

  static Weapon? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return Weapon(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      category: WeaponCategory.parse(m['category']),
      skins: [
        for (final raw in asList(m['skins'])) ?WeaponSkin.fromJson(raw, uuid),
      ],
      defaultSkinUuid: lowerUuid(m['defaultSkinUuid']),
      displayIcon: asNonEmptyString(m['displayIcon']),
      killStreamIcon: asNonEmptyString(m['killStreamIcon']),
      shopCost: asInt(pick(m, ['shopData', 'cost'])),
    );
  }

  final String uuid;
  final String displayName;
  final WeaponCategory category;
  final List<WeaponSkin> skins;
  final String? defaultSkinUuid;
  final String? displayIcon;
  final String? killStreamIcon;

  /// In-match credits cost (`null` for melee).
  final int? shopCost;

  bool get isMelee => category == WeaponCategory.melee;
}
