/// Android notification channel names and shared notification copy (VF §6.9).
abstract final class NotificationStrings {
  static const channelStoreResetName = 'Làm mới cửa hàng';
  static const channelStoreResetDescription =
      'Nhắc khi cửa hàng hằng ngày làm mới';
  static const channelWishlistName = 'Wishlist';
  static const channelWishlistDescription =
      'Báo khi skin trong wishlist xuất hiện trong cửa hàng';
  static const channelNightMarketName = 'Chợ Đêm';
  static const channelNightMarketDescription = 'Báo khi Chợ Đêm mở';
  static const channelAccountName = 'Tài khoản';
  static const channelAccountDescription =
      'Nhắc khi một tài khoản cần đăng nhập lại';

  static const nightMarketOpenTitle = 'Chợ Đêm đã mở!';
  static String nightMarketOpenBody(String cards, String account) =>
      'Lật $cards thẻ ưu đãi của $account ngay.';

  static const sessionExpiredTitle = 'Cần đăng nhập lại';
  static String sessionExpiredBody(String account) =>
      'Đăng nhập lại $account để tiếp tục nhận thông báo wishlist.';
}
