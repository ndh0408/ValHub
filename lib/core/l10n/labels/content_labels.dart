import '../../content/models/weapon_models.dart';
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
