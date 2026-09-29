import '../../core/domain/economy/economy_strings.dart';
import '../../core/domain/loadout/loadout_strings.dart';
import '../../core/l10n/content_strings.dart';

/// Vietnamese strings of the collection feature (VF §6.4, §8.6).
abstract final class CollectionStrings {
  static const title = 'Bộ sưu tập';

  // ------------------------------------------------------------ S30 hub
  static const sectionLoadout = 'Trang bị';
  static const sectionIdentity = 'Hiển thị với người chơi khác';
  static const sectionBrowse = 'Duyệt bộ sưu tập';
  static const rowCard = 'Thẻ người chơi';
  static const rowTitle = 'Danh hiệu';
  static const rowWeapons = 'Trang bị vũ khí';
  static const rowExpressions = 'Tổ hợp cảm xúc';
  static const rowPresets = 'Bộ trang bị đã lưu';
  static const rowWishlist = 'Wishlist';
  static const rowLevelBorder = 'Khung cấp';
  static const levelBorderAuto = 'Tự động theo cấp';
  static const hideAccountLevel = 'Ẩn cấp tài khoản';
  static const hideAccountLevelHint =
      'Người chơi khác sẽ không thấy cấp tài khoản của bạn.';
  static const incognito = 'Chế độ ẩn danh';
  static const incognitoHint =
      'Ẩn tên của bạn với người chơi không cùng tổ đội trong trận.';
  static const equippedCard = 'Thẻ đang dùng';
  static const tapToChangeCard = 'Chạm để đổi thẻ';
  static String presetCount(int n) => n == 0 ? 'Chưa có' : '$n bộ';
  static String wishlistCount(int n) => n == 0 ? 'Trống' : '$n skin';

  /// Browse tile count ("142 món").
  static String itemsCount(String n) => '$n món';

  /// Prefix of the equipped title on the hub banner ("Danh hiệu: …").
  static const bannerTitlePrefix = '$rowTitle: ';
  static const collectionValue = EconomyStrings.collectionValue;
  static const excludedRewards = EconomyStrings.excludedRewards;
  static const valueHasEstimates = EconomyStrings.valueHasEstimates;
  static String valueSkinCount(int n) => 'Tính trên $n skin';
  static String valueRewardCount(int n) =>
      '$n skin phần thưởng không được tính';
  static const cachedLoadout =
      'Đang ngoại tuyến — trang bị hiển thị là bản đã lưu. Kéo để làm mới trước '
      'khi thay đổi.';

  // --------------------------------------------------- S31 / S32 pickers
  static const playerCardTitle = 'Đổi thẻ người chơi';
  static const playerTitleTitle = 'Đổi danh hiệu';
  static const playerCardSubtitle =
      'Hiện ở sảnh chờ, bảng điểm và khi bạn hạ gục đối thủ.';
  static const playerTitleSubtitle =
      'Hiện dưới tên của bạn ở sảnh chờ và trong trận.';
  static String equippedCardLabel(String name) => 'Thẻ đang dùng: $name';
  static const unknownCard = 'Thẻ không xác định';
  static String cardsCount(String n) => '$n thẻ đã sở hữu';
  static String titlesCount(String n) => '$n danh hiệu đã sở hữu';
  static const lobbyBanner = 'Ảnh ở sảnh chờ';
  static const preview = 'Xem trước';
  static const searchCards = 'Tìm thẻ người chơi…';
  static const searchTitles = 'Tìm danh hiệu…';
  static const noTitle = ContentStrings.noTitle;
  static const equip = 'Trang bị';
  static const equipped = 'Đang dùng';
  static String equippedItem(String name) => 'Đã trang bị $name';
  static const saving = 'Đang lưu…';
  static const noResults = 'Không tìm thấy kết quả phù hợp.';
  static const clearSearch = 'Xóa tìm kiếm';

  // ------------------------------------------------ S33 / S34 weapons
  static const weaponLoadoutTitle = 'Trang bị vũ khí';
  static const weaponSkinsTitle = 'Chọn skin';
  static String weaponLoadoutSubtitle(int custom, int total) =>
      '$custom/$total vũ khí đang dùng skin';
  static const searchWeapons = 'Tìm vũ khí, skin hoặc phụ kiện…';
  static String equippedLine(String skin) => 'Đang dùng: $skin';
  static String ownedForWeapon(int n) =>
      n == 0 ? 'Chưa có skin nào' : '$n skin đã sở hữu';
  static const defaultSkin = ContentStrings.defaultSkin;
  static const searchSkins = 'Tìm skin…';
  static const sortLabel = 'Sắp xếp';
  static const sortRarity = 'Độ hiếm';
  static const sortName = 'Tên';
  static const sortWeapon = 'Vũ khí';
  static const sortPrice = 'Giá';
  static const filterTiers = 'Phiên bản';
  static const clearFilters = 'Bỏ lọc';
  static String levelCount(int owned, int total) => 'Cấp $owned/$total';
  static String chromaCount(int owned, int total) => '$owned/$total biến thể';
  static const weaponNotFound = 'Không tìm thấy vũ khí này.';
  static const otherWeapons = 'Khác';
  static const noSkinsForWeapon = 'Bạn chưa có skin nào cho vũ khí này.';

  // --------------------------------------------------- S35 customize
  static const skinCustomizeTitle = 'Tùy chỉnh skin';
  static const variants = 'Biến thể';
  static const levels = 'Cấp độ';
  static const buddySlot = 'Phụ kiện súng';
  static const noBuddy = 'Chưa gắn phụ kiện';
  static const changeBuddy = 'Đổi';
  static const locked = 'Chưa mở khóa';
  static const playVideo = 'Xem video';
  static const playLevelVideo = 'Xem video cấp này';
  static const skinNotOwned = 'Bạn chưa sở hữu skin này.';
  static const skinNotFound = 'Không tìm thấy skin này.';
  static const meleeNoBuddy = 'Vũ khí cận chiến không gắn được phụ kiện.';
  static String levelLabel(int n, String type) => 'Cấp $n · $type';

  // ------------------------------------------------------ S36 buddies
  static const buddyPickerTitle = 'Chọn phụ kiện súng';
  static const removeBuddy = 'Gỡ phụ kiện';
  static const buddyRemoved = 'Đã gỡ phụ kiện';
  static String buddyAvailable(int free, int total) => 'Còn $free/$total';
  static const searchBuddies = 'Tìm phụ kiện…';
  static const moveBuddyTitle = 'Chuyển phụ kiện?';
  static String moveBuddyBody(String buddy, String from, String to) =>
      '$buddy đang gắn trên $from. Chuyển sang $to?';
  static const move = 'Chuyển';
  static const noBuddies = 'Bạn chưa có phụ kiện súng nào.';
  static const buddyUnavailable =
      'Không tìm thấy bản sao nào của phụ kiện này để gắn.';
  static String buddyFor(String weapon) => 'Cho $weapon';

  // ---------------------------------------------------- S37 expressions
  static const expressionsTitle = 'Tổ hợp cảm xúc';
  static const expressionsHint =
      'Chạm vào một ô để chọn hình phun sơn hoặc Flex.';
  static const slotNames = ['Trên', 'Phải', 'Dưới', 'Trái'];
  static String slotName(int slot) =>
      slot >= 0 && slot < slotNames.length ? slotNames[slot] : '${slot + 1}';
  static String slotTitle(int slot) => 'Ô ${slotName(slot).toLowerCase()}';
  static const expressionsSlots = 'Các ô trên vòng';
  static const tabSprays = 'Hình phun sơn';
  static const tabFlex = 'Flex';
  static const searchSprays = 'Tìm hình phun sơn…';
  static const searchFlex = 'Tìm Flex…';
  static const emptySlot = 'Trống';
  static const noSprays = 'Bạn chưa có hình phun sơn nào.';
  static const noFlex = 'Bạn chưa có Flex nào.';

  // ------------------------------------------------------ S38 presets
  static const presetsTitle = 'Bộ trang bị đã lưu';
  static const savePreset = 'Lưu trang bị hiện tại';
  static const presetNameTitle = 'Tên bộ trang bị';
  static const presetNameHint = 'Ví dụ: Leo rank';
  static const applyPreset = 'Áp dụng';
  static const renamePreset = 'Đổi tên';
  static const deletePreset = 'Xóa';
  static const presetActions = 'Tùy chọn';
  static String presetSavedAt(String date) => 'Lưu ngày $date';
  static String presetSaved(String name) => 'Đã lưu “$name”';
  static String presetApplied(String name) => 'Đã áp dụng “$name”';
  static String presetSkipped(int n) =>
      'Bỏ qua $n vật phẩm bạn không còn sở hữu.';
  static String presetDeleted(String name) => 'Đã xóa “$name”';
  static const undo = 'Hoàn tác';
  static String applyPresetTitle(String name) => 'Áp dụng “$name”?';
  static const applyPresetBody =
      'Skin, phụ kiện súng, tổ hợp cảm xúc, thẻ và danh hiệu đang dùng sẽ được '
      'thay bằng bộ này.';
  static const presetsEmpty =
      'Chưa có bộ trang bị nào.\nLưu trang bị hiện tại để đổi nhanh sau này.';
  static const presetsFull =
      'Đã đạt tối đa 50 bộ trang bị. Hãy xóa bớt để lưu thêm.';
  static const presetsNote =
      'Bộ trang bị chỉ được lưu trên thiết bị này, cho tài khoản đang chọn.';

  // --------------------------------------------------- level border
  static const levelBorderTitle = 'Chọn khung cấp';
  static String levelBorderFrom(int level) => 'Từ cấp $level';

  // ------------------------------------------------------- S39 browse
  static const browseTitle = 'Duyệt bộ sưu tập';
  static const browseSkins = 'Skin';
  static const browseBuddies = 'Phụ kiện súng';
  static const browseSprays = 'Hình phun sơn';
  static const browseCards = 'Thẻ người chơi';
  static const browseTitles = 'Danh hiệu';
  static const browseFlex = 'Flex';
  static const searchItems = 'Tìm kiếm…';

  /// One line under the large title of "Duyệt bộ sưu tập" by type path.
  static String browseSubtitle(String type) => switch (type) {
    'skin' => 'Mọi skin bạn sở hữu, tính giá trị theo giá cửa hàng',
    'buddy' => 'Phụ kiện súng đã sở hữu và số bản sao',
    'spray' => 'Hình phun sơn bạn có thể gắn vào tổ hợp cảm xúc',
    'card' => 'Thẻ người chơi đã mở khóa, chạm để xem và trang bị',
    'title' => 'Danh hiệu bạn có thể hiển thị dưới tên',
    'flex' => 'Flex đã sở hữu',
    _ => browseTitle,
  };
  static String summarySkins(int count, String value) => '$count skin · $value';
  static String summaryFiltered(int count, String value) =>
      'Đang lọc: $count skin · $value';
  static String summaryItems(int count) => '$count vật phẩm';
  static String summaryFilteredItems(int count, int total) =>
      'Đang lọc: $count/$total vật phẩm';
  static String copies(int n) => '×$n';
  static const browseEmpty = 'Bạn chưa có vật phẩm nào ở mục này.';
  static const browseEmptyTitle = 'Chưa có vật phẩm';
  static const noResultsTitle = 'Không tìm thấy';
  static const clearTiers = 'Bỏ lọc phiên bản';
  static const valueAtStorePrices = 'Tính theo giá cửa hàng';
  static const valueSeeSkins = 'Xem các skin';
  static String ownedSkinsStat(String n) => '$n skin đã sở hữu';
  static String levelsUnlocked(int owned, int total) =>
      'Đã mở $owned/$total cấp';
  static const previewing = 'Đang xem';

  // ---------------------------------------------------------- errors
  static const saveFailed = LoadoutStrings.saveFailed;
  static String saveFailedWith(String detail) =>
      '${LoadoutStrings.saveFailed}. $detail';
}
