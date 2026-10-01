/// Strings of the store feature (VF §6.2 S10–S14, §6.9, §8.2).
abstract final class StoreStrings {
  static const title = 'Cửa hàng';
  static const segmentDaily = 'Hằng ngày';
  static const segmentNightMarket = 'Chợ Đêm';
  static const segmentAccessories = 'Phụ kiện';
  static const segmentBundles = 'Bundle';
  static const bundleDetailTitle = 'Chi tiết bundle';

  // Wallet pill (common header).
  /// Screen-reader label of the wallet pill.
  static String walletSemantics(String vp, String kc, String rp) =>
      'Số dư: $vp VP, $kc KC, $rp RP';

  // Daily shop (S10).
  static String resetsIn(String t) => 'Làm mới sau $t';

  /// Local wall time of the daily reset (device time zone, 24 h):
  /// "Làm mới lúc 07:00 hằng ngày".
  static String dailyResetAt(String time) => 'Làm mới lúc $time hằng ngày';
  static const dailyTotalLabel = 'Tổng';
  static const dailyEmpty = 'Hôm nay cửa hàng không có skin nào.';
  static const dailyEmptyTitle = 'Cửa hàng trống';

  /// "Đã sở hữu 1/4" (daily summary chip).
  static String ownedCount(int owned, int total) => 'Đã sở hữu $owned/$total';

  /// "2 trong wishlist" (daily summary chip).
  static String wishlistCount(int n) => '$n trong wishlist';

  // Night Market (S11).
  static String nightMarketEndsIn(String t) => 'Kết thúc sau $t';

  /// "Kết thúc lúc 07:00 thứ Tư 08/10" (local wall time).
  static String nightMarketEndsAt(String wall) => 'Kết thúc lúc $wall';
  static String nightMarketTotalSavings(String amount) =>
      'Tiết kiệm tổng cộng $amount';
  static const nightMarketNote =
      'Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn và không thể làm mới.';
  static const nightMarketEmpty = 'Hiện chưa có Chợ Đêm.';
  static const nightMarketEmptyTitle = 'Chợ Đêm chưa mở';

  /// Offer not yet flipped in game.
  static const nightMarketUnrevealed = 'Chưa lật';

  // Accessories (S12).
  static String accessoryRefreshIn(String t) => 'Làm mới sau $t';

  /// "Làm mới lúc 07:00 thứ Năm 01/10" (local wall time).
  static String accessoryResetAt(String wall) => 'Làm mới lúc $wall';
  static String accessoryFrom(String contract) => 'Từ: $contract';
  static const accessoryEmpty = 'Cửa hàng phụ kiện hiện không có gì.';
  static const accessoryEmptyTitle = 'Chưa có phụ kiện';

  // Bundles (S13 / S14).
  static String bundleEndsIn(String t) => 'Còn $t';

  /// "Hết hạn lúc 07:00 thứ Tư 21/10" (local wall time).
  static String bundleEndsAt(String wall) => 'Hết hạn lúc $wall';
  static const bundlesEmpty = 'Hiện không có bundle nào đang mở bán.';
  static const bundlesEmptyTitle = 'Chưa có bundle';
  static const bundleNotFoundTitle = 'Bundle đã hết hạn';
  static const backToBundles = 'Xem các bundle đang bán';

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

  // "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  static const shareImage = 'Chia sẻ ảnh';
  static const shareDailyTitle = 'Chia sẻ cửa hàng hôm nay';
  static const shareNightMarketTitle = 'Chia sẻ Chợ Đêm';
  static const shareSubtitle =
      'Chia sẻ ảnh cửa hàng với bạn bè qua ứng dụng bạn chọn.';
  static const shareShowRiotId = 'Hiện Riot ID trên ảnh';
  static const shareShowRiotIdHint = 'Tắt sẵn để giữ riêng tư cho bạn.';
  static const shareShowPrice = 'Hiện giá quy đổi ước tính';
  static const shareShowPriceHint = 'Quy đổi theo gói VP có lợi nhất.';
  static const sharePreparing = 'Đang tải ảnh skin…';
  static const shareButton = 'Chia sẻ';
  static const shareFailed = 'Không tạo được ảnh. Hãy thử lại.';
  static const shareCardDaily = 'Cửa hàng hôm nay';
  static const shareCardNightMarket = 'Chợ Đêm';
  static const shareCardBrand = 'VanHub';
  static const shareCardMark = 'V';
  static const shareCardWatermark = 'VALVN';
  static const shareCardTagline = 'Trợ thủ VALORANT của bạn';
  static const shareCardPriceNote = 'Giá quy đổi chỉ là ước tính theo gói VP.';

  /// "Tổng 6.500 VP".
  static String shareCardTotal(String vp) => 'Tổng $vp';

  /// "Tiết kiệm 2.331 VP".
  static String shareCardSaved(String vp) => 'Tiết kiệm $vp';

  /// "Đến 07:00 thứ Tư 08/10" (Night Market end on the picture).
  static String shareCardUntil(String wall) => 'Đến $wall';

  /// Share-sheet subject / chooser title.
  static const shareSubjectDaily = 'Cửa hàng VALORANT hôm nay của mình';
  static const shareSubjectNightMarket = 'Chợ Đêm VALORANT của mình';

  /// ASCII file names ("valvn-cua-hang-2026-09-29.png").
  static String shareFileDaily(String stamp) => 'valvn-store-$stamp.png';
  static String shareFileNightMarket(String stamp) =>
      'valvn-night-market-$stamp.png';

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
