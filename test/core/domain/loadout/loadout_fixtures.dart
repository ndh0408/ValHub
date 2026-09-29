import 'dart:convert';

import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/util/json.dart';

import '../economy/economy_fixtures.dart';

/// Well-known ids used by the loadout tests (skins from the economy
/// fixtures, see `Fx`).
abstract final class Lx {
  static const puuid = Fx.puuid;
  static const vandal = SpecialIds.vandal;
  static const phantom = SpecialIds.phantom;
  static const melee = SpecialIds.melee;
  static const ghost = '1baa85b4-4c70-1284-64bb-6481dfc3bb4e';

  static const vandalStandardLevel = '1ab72e66-4da3-33a0-164f-908113e075a4';
  static const vandalStandardChroma = '19629ae1-4996-ae98-7742-24a240d41f99';
  static const phantomStandard = '337cb216-4a6e-d85d-88c2-f29ab317784c';
  static const phantomStandardLevel = '871e73ed-452d-eb5a-3d6b-1d87060f35ce';
  static const phantomStandardChroma = '52221ba2-4e4c-ec76-8c81-3483506d5242';
  static const ghostStandard = '1c63b43b-43c4-04e4-01c9-7aa1bffa5ac1';
  static const ghostStandardLevel = '0a7e786c-444e-6a80-8bda-e2b714d68332';
  static const ghostStandardChroma = '947a28b6-4e0f-61fb-e795-bc9a5e7b7129';
  static const meleeStandard = '12cc9ed2-4430-d2fe-3064-f7a19b1ba7c7';
  static const meleeStandardLevel = '854938f3-4532-b300-d9a2-379d987d7469';
  static const meleeStandardChroma = 'cac83e5c-47a1-3519-5420-1db1fdbc4892';

  static const buddyInstanceA = '90431b40-a439-410f-8c51-765452353200';
  static const buddyInstanceB = 'a1b2c3d4-0000-4000-8000-000000000002';

  static const sprayA = Fx.sprayTinhNguyen;
  static const sprayB = Fx.sprayCypher;
  static const cardDefault = '9fb348bc-41a0-91ad-8a3e-818035c4e561';
}

/// A realistic P-8 v3 body (EP §7.1) with an unknown 13.06 key that must
/// round-trip. Ids are partly uppercase like some Riot payloads.
JsonMap loadoutJson({int version = 25, bool incognito = false}) => asMap(
  jsonDecode(
    jsonEncode({
      'Subject': Lx.puuid.toUpperCase(),
      'Version': version,
      'Guns': [
        {
          'ID': Lx.vandal.toUpperCase(),
          'SkinID': Fx.vandalStandard,
          'SkinLevelID': Lx.vandalStandardLevel,
          'ChromaID': Lx.vandalStandardChroma,
          'CharmInstanceID': Lx.buddyInstanceA,
          'CharmID': Fx.neoFrontierBuddy,
          'CharmLevelID': Fx.neoFrontierBuddyL1,
          'Attachments': <Object?>[],
        },
        {
          'ID': Lx.phantom,
          'SkinID': Lx.phantomStandard,
          'SkinLevelID': Lx.phantomStandardLevel,
          'ChromaID': Lx.phantomStandardChroma,
          'Attachments': <Object?>[],
        },
        {
          'ID': Lx.ghost,
          'SkinID': Lx.ghostStandard,
          'SkinLevelID': Lx.ghostStandardLevel,
          'ChromaID': Lx.ghostStandardChroma,
          'Attachments': <Object?>[],
        },
        {
          'ID': Lx.melee,
          'SkinID': Lx.meleeStandard,
          'SkinLevelID': Lx.meleeStandardLevel,
          'ChromaID': Lx.meleeStandardChroma,
          'Attachments': <Object?>[],
        },
      ],
      'ActiveExpressions': [
        {'TypeID': ItemTypeIds.flex, 'AssetID': Fx.flexOra},
        {'TypeID': ItemTypeIds.spray, 'AssetID': Lx.sprayA},
        {'TypeID': ItemTypeIds.spray, 'AssetID': SpecialIds.nullSpray},
        {'TypeID': ItemTypeIds.spray, 'AssetID': Lx.sprayB},
      ],
      'DynamicOptions': <String, Object?>{},
      'Identity': {
        'PlayerCardID': Fx.cardNgoiSang,
        'PlayerTitleID': Fx.titleTaiLoc,
        'AccountLevel': 0,
        'PreferredLevelBorderID': SpecialIds.autoLevelBorder,
        'HideAccountLevel': false,
      },
      'Incognito': incognito,
      'AgentMasteryCosmetics': {
        'Unknown': [1, 2, 3],
      },
    }),
  ),
)!;

/// Entitlements of the economy fixtures for one requested type: skin levels
/// from `entitlements_skin_levels.json`, the rest from the matching group of
/// `entitlements_all.json` (`null` = none → the caller answers 404).
JsonMap? entitlementsFor(String itemTypeId) {
  if (itemTypeId == ItemTypeIds.skinLevel) {
    return economyFixture('entitlements_skin_levels.json');
  }
  for (final group in asMapList(
    economyFixture('entitlements_all.json')['EntitlementsByTypes'],
  )) {
    if (lowerUuid(group['ItemTypeID']) == itemTypeId) return group;
  }
  return null;
}
