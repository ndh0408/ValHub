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

  static const channelBattlePassName = 'Battle Pass';
  static const channelBattlePassDescription =
      'Nhắc tiến độ và ngày kết thúc Battle Pass';
  static const channelRankName = 'Xếp hạng';
  static const channelRankDescription =
      'Báo thay đổi xếp hạng khi bạn cập nhật hồ sơ';
  static const channelCommunityName = 'Cộng đồng';
  static const channelCommunityDescription =
      'Báo hoạt động cộng đồng khi bạn mở ValVN';
  static const channelLfgName = 'Tổ đội';
  static const channelLfgDescription =
      'Báo người chơi tham gia tổ đội khi bạn mở ValVN';
  static const privateAccount = 'tài khoản của bạn';
  static const lfgJoinedTitle = 'Có người chơi tham gia tổ đội';
  static const localOnlyHint =
      'Chỉ báo trên thiết bị này khi ValVN cập nhật dữ liệu';
  static const backgroundTimingHint =
      'Chế độ tiết kiệm pin của thiết bị có thể làm thông báo đến muộn.';
  static const storeResetBody = 'Skin mới đang chờ bạn trong cửa hàng.';
  static const resetTimingUnknown =
      'Mở cửa hàng để cập nhật giờ làm mới trên thiết bị của bạn.';
  static const nightMarketOpenTitle = 'Chợ Đêm đã mở!';
  static String nightMarketOpenBody(String cards, String account) =>
      'Lật $cards thẻ ưu đãi của $account ngay.';

  static const sessionExpiredTitle = 'Cần đăng nhập lại';
  static String sessionExpiredBody(String account) =>
      'Đăng nhập lại để tiếp tục nhận thông báo wishlist.';
  static const rankChangedTitle = 'Xếp hạng đã thay đổi';
  static String rankChangedBody(String rank) =>
      'Xếp hạng hiện tại: $rank. Dữ liệu vừa cập nhật từ Riot.';
  static const passEndingTitle = 'Battle Pass sắp kết thúc';
  static const passEndingBody =
      'Battle Pass còn khoảng một ngày. Mở ValVN để xem tiến độ mới nhất.';
  static const passProgressTitle = 'Tiến độ Battle Pass';
  static String passProgressBody(int level) =>
      'Bạn đã đạt cấp $level trong Battle Pass hiện tại.';
}
