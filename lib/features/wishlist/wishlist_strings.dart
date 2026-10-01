/// Vietnamese strings of the wishlist feature (VF §6.4 S3A/S3B, §6.9, §8.4,
/// §8.5, §8.6).
abstract final class WishlistStrings {
  // ---------------------------------------------------------------- titles
  static const title = 'Wishlist';
  static const subtitle = 'Skin bạn đang săn';
  static const catalogTitle = 'Tất cả skin';
  static const catalogSubtitle = 'Chạm ♡ để thêm skin vào wishlist';

  /// "Wishlist của Tên#TAG" (VF §8.5 wishlistOfAccount).
  static String ofAccount(String riotId) => 'Wishlist của $riotId';

  // --------------------------------------------------------- S3A wishlist
  static const addSkins = 'Thêm skin';
  static const emptyTitle = 'Chưa có skin nào';
  static const empty = 'Wishlist trống. Chạm ♡ ở bất kỳ skin nào để thêm.';
  static const browseCatalog = 'Xem tất cả skin';
  static const totalValue = 'Tổng giá trị wishlist';
  static const excludedRewards = 'Không tính skin phần thưởng';
  static const hasEstimates = 'Có giá ước tính (≈)';

  /// "12 skin".
  static String skinCount(String count) => '$count skin';

  /// "Đang lọc: 3 skin · 5.325 VP" (VF §8.6 filteredValue).
  static String filtered(String count, String value) =>
      'Đang lọc: $count skin · $value';

  /// Banner above the list when wishlisted skins are on sale.
  static String onSaleBanner(int count) => count == 1
      ? 'Một skin trong wishlist đang được bán!'
      : '$count skin trong wishlist đang được bán!';
  static const onSaleBannerHint = 'Chạm vào dòng được đánh dấu để xem ưu đãi.';

  static const removeAction = 'Xóa khỏi wishlist';
  static String removed(String name) => 'Đã xóa $name khỏi wishlist';
  static const undo = 'Hoàn tác';
  static const owned = 'Đã sở hữu';

  /// "Kết thúc sau 11:54:37".
  static String endsIn(String time) => 'Kết thúc sau $time';
  static const viewInStore = 'Xem trong cửa hàng';
  static const storeCheckTitle = 'Chưa kiểm tra được cửa hàng';

  // Notification toggle (VF §6.4 S3A, §8.5 notifWishlistBg).
  static const notifToggle = 'Thông báo wishlist';
  static const notifToggleSubtitle =
      'Cho tài khoản này, kể cả khi bạn không mở ứng dụng';
  static const notifPermissionMissing = 'Ứng dụng chưa có quyền gửi thông báo.';
  static const openSettings = 'Mở cài đặt';

  // ------------------------------------------------ search, filter, sort
  static const searchHint = 'Tìm skin…';
  static const clearSearch = 'Xóa tìm kiếm';
  static const sortBy = 'Sắp xếp';
  static String sortLabel(String sort) => 'Sắp xếp: $sort';
  static const sortRarity = 'Độ hiếm';
  static const sortName = 'Tên';
  static const sortWeapon = 'Vũ khí';
  static const sortPrice = 'Giá';
  static const filterTiers = 'Phiên bản';
  static const weapon = 'Vũ khí';
  static const allWeapons = 'Tất cả vũ khí';
  static const chooseWeapon = 'Chọn vũ khí';
  static const noMatchTitle = 'Không tìm thấy skin';
  static const noMatch = 'Không có skin phù hợp. Bỏ lọc để xem thêm.';
  static const clearFilters = 'Bỏ lọc';

  // ------------------------------------------------------------ S3B catalog
  static const catalogEmptyTitle = 'Chưa có skin';
  static const catalogEmpty =
      'Chưa tải được danh sách skin. Hãy làm mới để thử lại.';
  static String catalogCount(String count) => '$count skin';
  static String catalogInWishlist(String count) => '$count trong wishlist';
  static const addToWishlist = 'Thêm vào wishlist';
  static const removeFromWishlist = 'Xóa khỏi wishlist';
  static const inWishlist = 'Đã có trong wishlist';

  /// Screen-reader label of a catalog tile.
  static String tileSemantics(String name, String price, bool inWishlist) =>
      inWishlist ? '$name, $price, $inWishlistLabel' : '$name, $price';
  static const inWishlistLabel = 'đã có trong wishlist';

  // ------------------------------------------------ notifications (VF §6.9)
  static const notifDailyTitle = 'Skin trong wishlist đã xuất hiện!';

  /// "{skin} đang có trong cửa hàng của {account} — còn {h} giờ."
  static String notifDailyBody(String skin, String account, String? left) =>
      left == null
      ? '$skin đang có trong cửa hàng của $account.'
      : '$skin đang có trong cửa hàng của $account — còn $left.';

  static const notifNightMarketTitle = 'Chợ Đêm có skin bạn thích!';

  /// "{skin} giảm {pct}% còn {price} VP ({account})."
  static String notifNightMarketBody(
    String skin,
    int? percent,
    String? price,
    String account,
  ) {
    if (percent != null && percent > 0 && price != null) {
      return '$skin giảm $percent% còn $price ($account).';
    }
    if (price != null) return '$skin chỉ còn $price ($account).';
    return '$skin đang có trong Chợ Đêm của $account.';
  }

  static const notifBundleTitle = 'Bundle mới có skin trong wishlist';

  /// "{skin} nằm trong bundle {bundle} ({account})."
  static String notifBundleBody(String skin, String? bundle, String account) =>
      bundle == null
      ? '$skin nằm trong một bundle đang bán ($account).'
      : '$skin nằm trong bundle $bundle ($account).';

  /// Several hits for one account at once.
  static String notifSummaryTitle(int count) =>
      '$count skin trong wishlist đang được bán!';

  static String notifSummaryBody(List<String> names, int more, String account) {
    final list = names.join(', ');
    return more > 0
        ? '$list và $more skin khác đang có trong cửa hàng của $account.'
        : '$list đang có trong cửa hàng của $account.';
  }
}
