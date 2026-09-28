/// App-owned Vietnamese labels for game content that valorant-api does not
/// localise (or localises badly). Keyed by enums / ids, never by API text
/// (CA §16, VF §8.2–§8.9).
abstract final class ContentStrings {
  // Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  static const currencyVp = 'VP';
  static const currencyKc = 'KC';
  static const currencyRp = 'RP';
  static const currencyVpFull = 'VALORANT Point';
  static const currencyKcFull = 'Kingdom Credit';
  static const currencyRpFull = 'Radianite';
  static const currencyAgentTokens = 'Huy hiệu đặc vụ';

  // Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  static const tierSelect = 'Tuyển Chọn';
  static const tierDeluxe = 'Sang Chảnh';
  static const tierPremium = 'Cao Cấp';
  static const tierExclusive = 'Độc Quyền';
  static const tierUltra = 'Siêu Cấp';
  static String tierFull(String shortName) => 'Phiên bản $shortName';
  static const limitedEdition = 'Phiên bản giới hạn';

  // Item types (VF §8.2)
  static const itemSkin = 'Skin';
  static const itemChroma = 'Biến thể';
  static const itemBuddy = 'Phụ kiện súng';
  static const itemSpray = 'Hình phun sơn';
  static const itemCard = 'Thẻ người chơi';
  static const itemTitle = 'Danh hiệu';
  static const itemFlex = 'Flex';
  static const itemLevelBorder = 'Khung cấp';
  static const itemAgent = 'Đặc vụ';
  static const itemContract = 'Hợp đồng';
  static const itemCurrency = 'Tiền tệ';

  // Reward sources (C9, VF §8.3)
  static const rewardSourceBattlePass = 'Phần thưởng Battle Pass';
  static const rewardSourceAgent = 'Hợp đồng đặc vụ';
  static const rewardSourceEvent = 'Vé sự kiện';
  static const notForSale = 'Không bán';

  // Defaults / placeholders
  static const noTitle = 'Không có danh hiệu';
  static const defaultSkin = 'Mặc định';
  static const unranked = 'Chưa xếp hạng';
  static const noSpray = 'Không có';
  static const levelBase = 'Cơ bản';
  static String level(int n) => 'Cấp $n';

  // Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  static const categorySidearm = 'Súng phụ';
  static const categorySmg = 'SMG';
  static const categoryShotgun = 'Shotgun';
  static const categoryRifle = 'Súng trường';
  static const categorySniper = 'Súng bắn tỉa';
  static const categoryHeavy = 'Vũ khí hạng nặng';
  static const categoryMelee = 'Cận chiến';

  // Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  static const levelItemLabels = <String, String>{
    'VFX': 'Hiệu ứng hình ảnh',
    'Animation': 'Hoạt ảnh',
    'Finisher': 'Đòn kết liễu',
    'KillCounter': 'Bộ đếm hạ gục',
    'SoundEffects': 'Hiệu ứng âm thanh',
    'Transformation': 'Biến hình',
    'KillBanner': 'Biểu ngữ hạ gục',
    'KillEffect': 'Hiệu ứng hạ gục',
    'InspectAndKill': 'Hiệu ứng ngắm súng & hạ gục',
    'Voiceover': 'Lồng tiếng',
    'SongShuffle': 'Đổi bài nhạc',
    'Randomizer': 'Ngẫu nhiên hóa',
    'AttackerDefenderSwap': 'Đổi theo phe công/thủ',
    'TopFrag': 'Hiệu ứng top frag',
    'HeartbeatAndMapSensor': 'Cảm biến nhịp tim & bản đồ',
    'FishAnimation': 'Hoạt ảnh cá',
  };

  // Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  static const queueNames = <String, String>{
    'competitive': 'Thi đấu xếp hạng',
    'unrated': 'Đấu thường',
    'swiftplay': 'Siêu Tốc',
    'spikerush': 'Đặt Spike Nhanh',
    'deathmatch': 'Sinh Tử',
    'hurm': 'Sinh Tử Đội',
    'ggteam': 'Tăng Tiến',
    'onefa': 'Nhân bản',
    'premier': 'Premier',
    'custom': 'Chơi tự do',
    '': 'Chơi tự do',
    'dodgeball': 'Knockout',
    'fortcollins': 'Retake',
    'skirmish2v2': 'Skirmish: 2v2',
    'skirmishascension1v1': 'Skirmish: Thăng Hoa 1v1',
    'skirmishascension2v2': 'Skirmish: Thăng Hoa 2v2',
    'valaram': 'Tất Cả Ngẫu Nhiên Một Khu Đặt Spike',
    'abilitydraftarena': 'Gauntlet: Glitched',
    'snowball': 'Trận Chiến Cầu Tuyết',
    'newmap': 'Summit',
  };

  /// Short chip labels where the full queue name is too long (VF §8.9).
  static const queueShortNames = <String, String>{
    'competitive': 'Xếp hạng',
    'valaram': 'Ngẫu nhiên 1 khu',
  };

  // Agent roles keyed by role uuid (SUMMARY §7.7)
  static const roleNames = <String, String>{
    'dbe8757e-9e92-4ed4-b39f-9dfc589691d4': 'Đối đầu',
    '1b47567f-8f7b-444b-aae3-b0c634622d10': 'Khởi tranh',
    '4ee40330-ecdd-4f2f-98a8-eb1243428373': 'Kiểm soát',
    '5fc02f99-4091-4486-a531-98459a3e95e9': 'Hộ vệ',
  };

  // Item-name language setting (VF §6.8)
  static const itemLanguageTitle = 'Tên vật phẩm';
  static const itemLanguageVi = 'Tiếng Việt';
  static const itemLanguageEn = 'Tiếng Anh';
}
