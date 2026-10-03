import 'package:flutter/foundation.dart';

import '../../riot/riot_ids.dart';
import '../../util/format.dart';
import '../../util/json.dart';
import 'weapon_models.dart' show cleanText, enumSuffix;

/// `/v1/bundles` (Riot `FeaturedBundle.Bundles[].DataAssetID` = [uuid]).
@immutable
class Bundle {
  const Bundle({
    required this.uuid,
    required this.displayName,
    this.displayNameSubText,
    this.description,
    this.extraDescription,
    this.promoDescription,
    this.displayIcon,
    this.displayIcon2,
    this.verticalPromoImage,
    this.logoIcon,
    this.contentEditionUuid,
  });

  static Bundle? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    String? text(String key) {
      final t = cleanText(m[key]);
      return isRawLocKey(t) ? null : t;
    }

    return Bundle(
      uuid: uuid,
      displayName: text('displayName') ?? '',
      displayNameSubText: text('displayNameSubText'),
      description: text('description'),
      extraDescription: text('extraDescription'),
      promoDescription: text('promoDescription'),
      displayIcon: asNonEmptyString(m['displayIcon']),
      displayIcon2: asNonEmptyString(m['displayIcon2']),
      verticalPromoImage: asNonEmptyString(m['verticalPromoImage']),
      logoIcon: asNonEmptyString(m['logoIcon']),
      contentEditionUuid: lowerUuid(m['contentEditionUuid']),
    );
  }

  final String uuid;
  final String displayName;
  final String? displayNameSubText;
  final String? description;
  final String? extraDescription;
  final String? promoDescription;

  /// Wide banner (large PNG).
  final String? displayIcon;
  final String? displayIcon2;
  final String? verticalPromoImage;
  final String? logoIcon;
  final String? contentEditionUuid;

  /// Best card image: `displayIcon2` → `displayIcon` → vertical promo.
  String? get cardImage => displayIcon2 ?? displayIcon ?? verticalPromoImage;
}

/// One buddy level (Riot uses the LEVEL uuid for store / entitlements).
@immutable
class BuddyLevel {
  const BuddyLevel({
    required this.uuid,
    required this.charmLevel,
    this.displayIcon,
  });

  final String uuid;
  final int charmLevel;
  final String? displayIcon;
}

/// `/v1/buddies`. Always show the parent [displayName] (level names are
/// internal dev names).
@immutable
class Buddy {
  const Buddy({
    required this.uuid,
    required this.displayName,
    required this.levels,
    this.isHiddenIfNotOwned = false,
    this.themeUuid,
    this.displayIcon,
  });

  static Buddy? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return Buddy(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      levels: [
        for (final l in asMapList(m['levels']))
          if (lowerUuid(l['uuid']) case final id?)
            BuddyLevel(
              uuid: id,
              charmLevel: asInt(l['charmLevel']) ?? 1,
              displayIcon: asNonEmptyString(l['displayIcon']),
            ),
      ],
      isHiddenIfNotOwned: asBool(m['isHiddenIfNotOwned']) ?? false,
      themeUuid: lowerUuid(m['themeUuid']),
      displayIcon: asNonEmptyString(m['displayIcon']),
    );
  }

  final String uuid;
  final String displayName;
  final List<BuddyLevel> levels;
  final bool isHiddenIfNotOwned;
  final String? themeUuid;
  final String? displayIcon;

  String? get image => displayIcon ?? levels.firstOrNull?.displayIcon;
}

/// `/v1/sprays` (Riot uses the SPRAY uuid).
@immutable
class Spray {
  const Spray({
    required this.uuid,
    required this.displayName,
    required this.levelUuids,
    this.category,
    this.themeUuid,
    this.isNullSpray = false,
    this.hideIfNotOwned = false,
    this.displayIcon,
    this.fullIcon,
    this.fullTransparentIcon,
    this.animationGif,
    this.animationPng,
  });

  static Spray? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return Spray(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      levelUuids: [
        for (final l in asMapList(m['levels'])) ?lowerUuid(l['uuid']),
      ],
      category: enumSuffix(m['category']),
      themeUuid: lowerUuid(m['themeUuid']),
      isNullSpray: asBool(m['isNullSpray']) ?? false,
      hideIfNotOwned: asBool(m['hideIfNotOwned']) ?? false,
      displayIcon: asNonEmptyString(m['displayIcon']),
      fullIcon: asNonEmptyString(m['fullIcon']),
      fullTransparentIcon: asNonEmptyString(m['fullTransparentIcon']),
      animationGif: asNonEmptyString(m['animationGif']),
      animationPng: asNonEmptyString(m['animationPng']),
    );
  }

  final String uuid;
  final String displayName;
  final List<String> levelUuids;
  final String? category;
  final String? themeUuid;
  final bool isNullSpray;
  final bool hideIfNotOwned;
  final String? displayIcon;
  final String? fullIcon;
  final String? fullTransparentIcon;
  final String? animationGif;
  final String? animationPng;

  /// Best static image.
  String? get image => fullTransparentIcon ?? fullIcon ?? displayIcon;

  /// Animated image when available, else [image].
  String? get animatedImage => animationGif ?? image;
}

/// `/v1/playercards`.
@immutable
class PlayerCard {
  const PlayerCard({
    required this.uuid,
    required this.displayName,
    this.isHiddenIfNotOwned = false,
    this.themeUuid,
    this.displayIcon,
    this.smallArt,
    this.wideArt,
    this.largeArt,
  });

  static PlayerCard? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final name = cleanText(m['displayName']);
    return PlayerCard(
      uuid: uuid,
      displayName: isRawLocKey(name) ? '' : (name ?? ''),
      isHiddenIfNotOwned: asBool(m['isHiddenIfNotOwned']) ?? false,
      themeUuid: lowerUuid(m['themeUuid']),
      displayIcon: asNonEmptyString(m['displayIcon']),
      smallArt: asNonEmptyString(m['smallArt']),
      wideArt: asNonEmptyString(m['wideArt']),
      largeArt: asNonEmptyString(m['largeArt']),
    );
  }

  final String uuid;
  final String displayName;
  final bool isHiddenIfNotOwned;
  final String? themeUuid;
  final String? displayIcon;

  /// List avatar.
  final String? smallArt;

  /// Profile header banner.
  final String? wideArt;

  /// Full card.
  final String? largeArt;
}

/// `/v1/playertitles`. Display [titleText].
@immutable
class PlayerTitle {
  const PlayerTitle({
    required this.uuid,
    required this.displayName,
    this.titleText,
    this.isHiddenIfNotOwned = false,
  });

  static PlayerTitle? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return PlayerTitle(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      titleText: cleanText(m['titleText']),
      isHiddenIfNotOwned: asBool(m['isHiddenIfNotOwned']) ?? false,
    );
  }

  final String uuid;
  final String displayName;
  final String? titleText;
  final bool isHiddenIfNotOwned;

  bool get isNoTitle => uuid == SpecialIds.noTitle;

  /// Raw API title candidate; the UI supplies any empty-title fallback.
  String get text => isNoTitle ? '' : (titleText ?? displayName);
}

/// `/v1/flex` (Riot "Totem"). Named `FlexItem` to avoid clashing with
/// Flutter's `Flex` widget.
@immutable
class FlexItem {
  const FlexItem({
    required this.uuid,
    required this.displayName,
    this.displayNameAllCaps,
    this.displayIcon,
  });

  static FlexItem? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return FlexItem(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      displayNameAllCaps: cleanText(m['displayNameAllCaps']),
      displayIcon: asNonEmptyString(m['displayIcon']),
    );
  }

  final String uuid;
  final String displayName;
  final String? displayNameAllCaps;
  final String? displayIcon;
}

/// `/v1/levelborders`.
@immutable
class LevelBorder {
  const LevelBorder({
    required this.uuid,
    required this.displayName,
    required this.startingLevel,
    this.levelNumberAppearance,
    this.smallPlayerCardAppearance,
  });

  static LevelBorder? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return LevelBorder(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      startingLevel: asInt(m['startingLevel']) ?? 1,
      levelNumberAppearance: asNonEmptyString(m['levelNumberAppearance']),
      smallPlayerCardAppearance: asNonEmptyString(
        m['smallPlayerCardAppearance'],
      ),
    );
  }

  final String uuid;
  final String displayName;
  final int startingLevel;

  /// Badge behind the level number.
  final String? levelNumberAppearance;
  final String? smallPlayerCardAppearance;
}

/// `/v1/contenttiers` (rarity). Colors are `RRGGBBAA`.
@immutable
class ContentTier {
  const ContentTier({
    required this.uuid,
    required this.devName,
    required this.rank,
    required this.displayName,
    this.highlightColor,
    this.displayIcon,
  });

  static ContentTier? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return ContentTier(
      uuid: uuid,
      devName: asString(m['devName']) ?? '',
      rank: asInt(m['rank']) ?? 0,
      displayName: cleanText(m['displayName']) ?? '',
      highlightColor: asNonEmptyString(m['highlightColor']),
      displayIcon: asNonEmptyString(m['displayIcon']),
    );
  }

  final String uuid;

  /// `Select` / `Deluxe` / `Premium` / `Exclusive` / `Ultra` (use for logic).
  final String devName;

  /// 0 (Select) … 4 (Ultra) (use for sorting).
  final int rank;

  /// Full vi name from valorant-api ("Phiên Bản Độc Quyền").
  final String displayName;

  /// `RRGGBBAA` (alpha 0x33 = card tint).
  final String? highlightColor;
  final String? displayIcon;

  /// Official / community fallback VP price for a skin of this tier
  /// (SUMMARY §7.3; Exclusive / Ultra are estimates).
  int? get fallbackPrice => switch (devName) {
    'Select' => 875,
    'Deluxe' => 1275,
    'Premium' => 1775,
    'Exclusive' => 2175,
    'Ultra' => 2475,
    _ => null,
  };

  /// Whether [fallbackPrice] is only an estimate (label with "≈").
  bool get fallbackPriceIsEstimate =>
      devName == 'Exclusive' || devName == 'Ultra';
}

/// `/v1/currencies`. The vi API names are re-cased English, so labels come
/// from render-time resources.
@immutable
class Currency {
  const Currency({
    required this.uuid,
    required this.displayName,
    this.displayIcon,
    this.largeIcon,
  });

  static Currency? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return Currency(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      displayIcon: asNonEmptyString(m['displayIcon']),
      largeIcon: asNonEmptyString(m['largeIcon']),
    );
  }

  final String uuid;
  final String displayName;
  final String? displayIcon;
  final String? largeIcon;
}
