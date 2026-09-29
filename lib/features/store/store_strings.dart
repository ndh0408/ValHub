/// Vietnamese strings of the store feature (VF §6.2 S10–S14, §6.9, §8.2).
abstract final class StoreStrings {
  static const title = 'Cửa hàng';
  static const segmentDaily = 'Hằng ngày';
  static const segmentNightMarket = 'Chợ Đêm';
  static const segmentAccessories = 'Phụ kiện';
  static const segmentBundles = 'Bundle';
  static const bundleDetailTitle = 'Chi tiết bundle';

  // Wallet pill (common header).
  static const walletTitle = 'Ví';

  /// Screen-reader label of the wallet pill.
  static String walletSemantics(String vp, String kc, String rp) =>
      'Số dư: $vp VP, $kc KC, $rp RP';

  // Daily shop (S10).
  static String resetsIn(String t) => 'Làm mới sau $t';
  static const dailyTotalLabel = 'Tổng';
  static const dailyEmpty = 'Hôm nay cửa hàng không có skin nào.';
  static const dailyEmptyTitle = 'Cửa hàng trống';

  /// "Đã sở hữu 1/4" (daily summary chip).
  static String ownedCount(int owned, int total) => 'Đã sở hữu $owned/$total';

  /// "2 trong wishlist" (daily summary chip).
  static String wishlistCount(int n) => '$n trong wishlist';

  // Night Market (S11).
  static String nightMarketEndsIn(String t) => 'Kết thúc sau $t';
  static String nightMarketTotalSavings(String amount) =>
      'Tiết kiệm tổng cộng $amount';
  static const nightMarketNote =
      'Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn và không thể làm mới.';
  static const nightMarketEmpty = 'Hiện chưa có Chợ Đêm.';
  static const nightMarketEmptyTitle = 'Chợ Đêm chưa mở';

  /// Offer not yet flipped in game.
  static const nightMarketUnrevealed = 'Chưa lật';
  static const priceOriginal = 'Giá gốc';
  static const priceDiscounted = 'Giá ưu đãi';

  // Accessories (S12).
  static String accessoryRefreshIn(String t) => 'Làm mới sau $t';
  static String accessoryFrom(String contract) => 'Từ: $contract';
  static const accessoryEmpty = 'Cửa hàng phụ kiện hiện không có gì.';
  static const accessoryEmptyTitle = 'Chưa có phụ kiện';

  // Bundles (S13 / S14).
  static String bundleEndsIn(String t) => 'Còn $t';
  static const bundlesEmpty = 'Hiện không có bundle nào đang mở bán.';
  static const bundlesEmptyTitle = 'Chưa có bundle';
  static const bundleNotFoundTitle = 'Bundle đã hết hạn';

  /// "Đã sở hữu 2/6 vật phẩm" (bundle detail).
  static String bundleOwnedCount(int owned, int total) =>
      'Đã sở hữu $owned/$total vật phẩm';
  static const bundlePriceLabel = 'Giá bundle';
  static const bundleBuySeparateLabel = 'Mua lẻ';
  static const bundleSavingsLabel = 'Tiết kiệm';
  static const bundleWholesaleOnly = 'Chỉ bán trọn bộ, không mua lẻ.';
  static const bundleNotFound =
      'Không tìm thấy bundle này. Có thể bundle đã hết hạn.';
  static const bundleItemFree = 'Miễn phí';
  static const bundleItemsTitle = 'Vật phẩm trong bundle';
  static String bundleItemCount(int n) => '$n vật phẩm';
  static String quantity(int n) => '×$n';

  // Shared badges and actions.
  static const ownedBadge = 'Đã sở hữu';
  static const addToWishlist = 'Thêm vào wishlist';
  static const removeFromWishlist = 'Xóa khỏi wishlist';

  /// Screen-reader label of a store card: "Vandal Reaver, 1.775 VP".
  static String offerSemantics(String name, String price) => '$name, $price';

  // Store-reset local notification (B8, VF §6.9).
  static const resetNotificationTitle = 'Cửa hàng đã làm mới';

  /// "Xem 4 skin mới hôm nay của Tên#TAG."
  static String resetNotificationBody(int skinCount, String account) =>
      skinCount > 0
      ? 'Xem $skinCount skin mới hôm nay của $account.'
      : 'Xem skin mới hôm nay của $account.';
}
