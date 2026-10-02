/// Well-known Riot / valorant-api UUIDs (SUMMARY §7). All lowercase.
library;

/// `ItemTypeID` values used by entitlements, offers and rewards (SUMMARY §7.1).
abstract final class ItemTypeIds {
  static const skinLevel = 'e7c63390-eda7-46e0-bb7a-a6abdacd2433';
  static const skinChroma = '3ad1b2b2-acdb-4524-852f-954a76ddae0a';
  static const buddyLevel = 'dd3bf334-87f3-40bd-b043-682a57a8dc3a';
  static const spray = 'd5f120f8-ff8c-4aac-92ea-f2b5acbe9475';
  static const flex = '03a572de-4234-31ed-d344-ababa488f981';
  static const playerCard = '3f296c07-64c3-494c-923b-fe692a4fa1bd';
  static const playerTitle = 'de7caa6b-adf7-4588-bbd1-143831e786c6';
  static const agent = '01bb38e1-da47-4e6a-9b3d-945fe4655707';
  static const premiumContract = 'f85cb6f7-33e5-4dc8-b609-ec7212301948';
  static const currency = 'ea6fcd2e-8373-4137-b1c0-b458947aa86d';

  /// Value of each entitlement row's `TypeID` (not an item type).
  static const entitlementRowType = '4e60e748-bce6-4faa-9327-ebbe6089d5fe';

  /// Every type that can be fetched with P-3 for the collection.
  static const collectionTypes = [
    skinLevel,
    skinChroma,
    buddyLevel,
    spray,
    flex,
    playerCard,
    playerTitle,
    agent,
    premiumContract,
  ];
}

/// Match-loadout socket ids (SUMMARY §7.1).
abstract final class LoadoutSocketIds {
  static const skin = 'bcef87d6-209b-46c6-8b19-fbe40bd95abc';
  static const buddy = '77258665-71d1-4623-bc72-44db9bd5b3b3';
}

/// Currencies (SUMMARY §7.2).
abstract final class CurrencyIds {
  static const vp = '85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741';
  static const rp = 'e59aa87c-4cbf-517a-5983-6e81511be9b7';
  static const kc = '85ca954a-41f2-ce94-9b45-8ca3dd39a00d';
  static const agentTokens = 'f08d4ae3-939c-4576-ab26-09ce1f23bb37';
}

/// Content tiers (SUMMARY §7.3).
abstract final class ContentTierIds {
  static const select = '12683d76-48d7-84a3-4e09-6985794f0445';
  static const deluxe = '0cebb8be-46d7-c12a-d306-e9907bfc5a25';
  static const premium = '60bca009-4182-7998-dee7-b8a2558dc369';
  static const exclusive = 'e046854e-406c-37f4-6607-19a9ba8426fc';
  static const ultra = '411e4a55-4e59-7757-41f0-86a53f101bb5';

  /// LimitedEdition content edition.
  static const limitedEdition = '3d190ff8-49c2-2ae5-f8b1-a3b782fb4b79';
}

/// Special UUIDs (SUMMARY §7.6).
abstract final class SpecialIds {
  static const starterAgents = {
    'add6443a-41bd-e414-f6ad-e58d267f4e95', // Jett
    'eb93336a-449b-9c1b-0a54-a891f7921d69', // Phoenix
    '320b2a48-4d9b-a075-30f1-1f93a9b638fa', // Sova
    '9f0d8ba9-4140-b941-57d3-a7ad57c6b417', // Brimstone
    '569fdd95-4d10-43ab-ca70-79becc718b46', // Sage
  };
  static const melee = '2f59173c-4bed-b6c3-2191-dea9b58be9c7';
  static const vandal = '9c82e19d-4575-0200-1a81-3eacf00cf872';
  static const phantom = 'ee8e8d15-496b-07ac-e5f6-8fae5d4c7b1a';
  static const operator = 'a03b24d3-4319-996d-0f8c-94bbfba1dfc7';
  static const sheriff = 'e336c6b8-418d-9340-d77f-7a9e4cfe0702';
  static const ghost = '1baa85b4-4c70-1284-64bb-6481dfc3bb4e';
  static const spectre = '462080d1-4035-2937-7c09-27aa2a5c27a7';
  static const warden = '8db0a1bf-4a50-832a-4566-faaaa6d250ca';
  static const bandit = '410b2e0b-4ceb-1321-1727-20858f7f3477';
  static const standardSkinTheme = '5a629df4-4765-0214-bd40-fbb96542941f';
  static const randomFavoriteSkinTheme = '0d7a5bfb-4850-098e-1821-d989bbfd58a8';
  static const noTitle = 'd13e579c-435e-44d4-cec2-6eae5a3c5ed4';
  static const nullSpray = 'd7efbdd5-4a77-f858-a133-cfb8956ca1fe';
  static const autoLevelBorder = '00000000-0000-0000-0000-000000000000';

  /// Current Episode 5+ competitive tier table (fallback for unknown acts).
  static const currentTierTable = '03621f52-342b-cf4e-4f86-9350a49c6d04';
}

/// Agent role uuids (SUMMARY §7.7).
abstract final class AgentRoleIds {
  static const duelist = 'dbe8757e-9e92-4ed4-b39f-9dfc589691d4';
  static const initiator = '1b47567f-8f7b-444b-aae3-b0c634622d10';
  static const controller = '4ee40330-ecdd-4f2f-98a8-eb1243428373';
  static const sentinel = '5fc02f99-4091-4486-a531-98459a3e95e9';
}
