import '../../content/content_db.dart';
import '../../riot/riot_ids.dart';
import '../app_locale.dart';
import '../l10n.dart';

/// App-owned categories and upgrade captions resolve when rendered.
extension ContentLabels on AppLocalizations {
  String weaponCategory(WeaponCategory category) => switch (category) {
    WeaponCategory.sidearm => contentCategorySidearm,
    WeaponCategory.smg => contentCategorySmg,
    WeaponCategory.shotgun => contentCategoryShotgun,
    WeaponCategory.rifle => contentCategoryRifle,
    WeaponCategory.sniper => contentCategorySniper,
    WeaponCategory.heavy => contentCategoryHeavy,
    WeaponCategory.melee => contentCategoryMelee,
    WeaponCategory.unknown => '',
  };

  String skinLevelItem(SkinLevel level) => switch (level.levelItem) {
    null => contentLevelBase,
    'VFX' => contentLevelItemLabelsVFX,
    'Animation' => contentLevelItemLabelsAnimation,
    'Finisher' => contentLevelItemLabelsFinisher,
    'KillCounter' => contentLevelItemLabelsKillCounter,
    'SoundEffects' => contentLevelItemLabelsSoundEffects,
    'Transformation' => contentLevelItemLabelsTransformation,
    'KillBanner' => contentLevelItemLabelsKillBanner,
    'KillEffect' => contentLevelItemLabelsKillEffect,
    'InspectAndKill' => contentLevelItemLabelsInspectAndKill,
    'Voiceover' => contentLevelItemLabelsVoiceover,
    'SongShuffle' => contentLevelItemLabelsSongShuffle,
    'Randomizer' => contentLevelItemLabelsRandomizer,
    'AttackerDefenderSwap' => contentLevelItemLabelsAttackerDefenderSwap,
    'TopFrag' => contentLevelItemLabelsTopFrag,
    'HeartbeatAndMapSensor' => contentLevelItemLabelsHeartbeatAndMapSensor,
    'FishAnimation' => contentLevelItemLabelsFishAnimation,
    final code => code,
  };

  String? agentRoleName(String? id) => switch (id) {
    'dbe8757e-9e92-4ed4-b39f-9dfc589691d4' =>
      contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4,
    '1b47567f-8f7b-444b-aae3-b0c634622d10' =>
      contentRoleNames1b47567f8f7b444bAae3B0c634622d10,
    '4ee40330-ecdd-4f2f-98a8-eb1243428373' =>
      contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373,
    '5fc02f99-4091-4486-a531-98459a3e95e9' =>
      contentRoleNames5fc02f9940914486A53198459a3e95e9,
    _ => null,
  };
}

/// These adapters take resources explicitly; parsed content and isolate caches
/// never retain app-owned translated text. API names keep their own language.
extension CurrencyDisplay on Currency {
  String label(AppLocalizations l10n) => switch (uuid) {
    CurrencyIds.vp => l10n.contentCurrencyVp,
    CurrencyIds.kc => l10n.contentCurrencyKc,
    CurrencyIds.rp => l10n.contentCurrencyRp,
    CurrencyIds.agentTokens => l10n.contentCurrencyAgentTokens,
    _ => displayName,
  };

  String fullLabel(AppLocalizations l10n, {String? contentLanguage}) {
    if (_matchingApiLanguage(l10n, contentLanguage) && displayName.isNotEmpty) {
      return displayName;
    }
    return switch (uuid) {
      CurrencyIds.vp => l10n.contentCurrencyVpFull,
      CurrencyIds.kc => l10n.contentCurrencyKcFull,
      CurrencyIds.rp => l10n.contentCurrencyRpFull,
      CurrencyIds.agentTokens => l10n.contentCurrencyAgentTokens,
      _ => displayName,
    };
  }
}

extension ContentTierDisplay on ContentTier {
  String shortName(AppLocalizations l10n, {String? contentLanguage}) {
    if (_matchingApiLanguage(l10n, contentLanguage) && displayName.isNotEmpty) {
      return displayName;
    }
    return switch (devName) {
      'Select' => l10n.contentTierSelect,
      'Deluxe' => l10n.contentTierDeluxe,
      'Premium' => l10n.contentTierPremium,
      'Exclusive' => l10n.contentTierExclusive,
      'Ultra' => l10n.contentTierUltra,
      _ => displayName,
    };
  }

  String fullName(AppLocalizations l10n, {String? contentLanguage}) {
    // Preserve the supplied VI full name as well as matching non-VI content.
    if (displayName.isNotEmpty &&
        (contentLanguage == 'vi-VN' && l10n.localeName == 'vi' ||
            _matchingApiLanguage(l10n, contentLanguage))) {
      return displayName;
    }
    final known = const {'Select', 'Deluxe', 'Premium', 'Exclusive', 'Ultra'};
    return known.contains(devName)
        ? l10n.contentTierFull(shortName(l10n))
        : displayName;
  }
}

extension PlayerTitleDisplay on PlayerTitle {
  String localizedText(AppLocalizations l10n) =>
      isNoTitle || text.isEmpty ? l10n.contentNoTitle : text;
}

extension AgentRoleDisplay on AgentRole {
  String label(AppLocalizations l10n, {String? contentLanguage}) {
    if (_matchingApiLanguage(l10n, contentLanguage) && displayName.isNotEmpty) {
      return displayName;
    }
    return l10n.agentRoleName(uuid) ?? displayName;
  }
}

extension ContractRewardDisplay on ContractRewardType {
  String label(AppLocalizations l10n) => l10n.itemTypeName(itemTypeId);
}

extension ContractRelationDisplay on ContractRelation {
  String? rewardSourceLabel(AppLocalizations l10n) => switch (this) {
    ContractRelation.season => l10n.contentRewardSourceBattlePass,
    ContractRelation.agent => l10n.contentRewardSourceAgent,
    ContractRelation.event => l10n.contentRewardSourceEvent,
    ContractRelation.other => null,
  };
}

extension RewardSourceDisplay on RewardSource {
  String? label(AppLocalizations l10n) => relation.rewardSourceLabel(l10n);
}

extension ContentItemDisplay on ContentItemRef {
  String typeLabel(AppLocalizations l10n) => l10n.itemTypeName(itemTypeId);

  String localizedName(AppLocalizations l10n, ContentDb db) =>
      switch (itemTypeId) {
        ItemTypeIds.currency => db.currency(uuid)?.label(l10n) ?? name,
        ItemTypeIds.playerTitle => db.title(uuid)?.localizedText(l10n) ?? name,
        _ => name,
      };
}

extension ContentTypeLabels on AppLocalizations {
  String itemTypeName(String id) => switch (id) {
    ItemTypeIds.skinLevel => contentItemSkin,
    ItemTypeIds.skinChroma => contentItemChroma,
    ItemTypeIds.buddyLevel => contentItemBuddy,
    ItemTypeIds.spray => contentItemSpray,
    ItemTypeIds.playerCard => contentItemCard,
    ItemTypeIds.playerTitle => contentItemTitle,
    ItemTypeIds.flex => contentItemFlex,
    ItemTypeIds.agent => contentItemAgent,
    ItemTypeIds.currency => contentItemCurrency,
    ItemTypeIds.premiumContract => contentItemContract,
    _ => '',
  };

  String? queueFallback(String id) => switch (id) {
    'competitive' => contentQueueNamesCompetitive,
    'unrated' => contentQueueNamesUnrated,
    'swiftplay' => contentQueueNamesSwiftplay,
    'spikerush' => contentQueueNamesSpikerush,
    'deathmatch' => contentQueueNamesDeathmatch,
    'hurm' => contentQueueNamesHurm,
    'ggteam' => contentQueueNamesGgteam,
    'onefa' => contentQueueNamesOnefa,
    'premier' => contentQueueNamesPremier,
    'custom' => contentQueueNamesCustom,
    '' => contentQueueNames,
    'dodgeball' => contentQueueNamesDodgeball,
    'fortcollins' => contentQueueNamesFortcollins,
    'skirmish2v2' => contentQueueNamesSkirmish2v2,
    'skirmishascension1v1' => contentQueueNamesSkirmishascension1v1,
    'skirmishascension2v2' => contentQueueNamesSkirmishascension2v2,
    'valaram' => contentQueueNamesValaram,
    'abilitydraftarena' => contentQueueNamesAbilitydraftarena,
    'snowball' => contentQueueNamesSnowball,
    'newmap' => contentQueueNamesNewmap,
    _ => null,
  };
}

extension ContentQueueDisplay on ContentDb {
  String queueName(AppLocalizations l10n, String? queueId) {
    final id = (queueId ?? '').trim().toLowerCase();
    final base = id.startsWith('console_') ? id.substring(8) : id;
    final api = queue(id) ?? queue(base);
    // Preserve real queue names when content and UI languages match.
    final sameLanguage = _sameLanguage(l10n, language);
    if (sameLanguage && api != null && api.label.isNotEmpty) return api.label;
    return l10n.queueFallback(base) ?? api?.label ?? queueId ?? '';
  }

  String queueShortName(AppLocalizations l10n, String? queueId) {
    final id = (queueId ?? '').trim().toLowerCase();
    final base = id.startsWith('console_') ? id.substring(8) : id;
    return switch (base) {
      'competitive' => l10n.contentQueueShortNamesCompetitive,
      'valaram' => l10n.contentQueueShortNamesValaram,
      _ => queueName(l10n, queueId),
    };
  }
}

bool _sameLanguage(AppLocalizations l10n, String? contentLanguage) =>
    contentLanguage != null &&
    contentLanguage.replaceAll('-', '_').toLowerCase() ==
        AppLocale.values
            .where((locale) => locale.arbCode == l10n.localeName)
            .firstOrNull
            ?.tag
            .replaceAll('-', '_')
            .toLowerCase();

bool _matchingApiLanguage(AppLocalizations l10n, String? contentLanguage) =>
    l10n.localeName != 'vi' && _sameLanguage(l10n, contentLanguage);
