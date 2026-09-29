/// Vietnamese strings of the skin-detail sheet (VF §6.2 S15–S16, §8.4).
abstract final class SkinDetailStrings {
  static const title = 'Chi tiết skin';
  static const variants = 'Biến thể';
  static const upgrades = 'Nâng cấp';
  static const playVideo = 'Xem video';
  static const addToWishlist = 'Thêm vào wishlist';
  static const removeFromWishlist = 'Xóa khỏi wishlist';
  static const inWishlist = 'Đã có trong wishlist';
  static const owned = 'Đã sở hữu';
  static const locked = 'Chưa mở khóa';
  static const mute = 'Tắt tiếng';
  static const unmute = 'Bật tiếng';
  static const play = 'Phát';
  static const pause = 'Tạm dừng';
  static const notFound = 'Không tìm thấy skin này.';
  static const videoError = 'Không phát được video. Kiểm tra mạng rồi thử lại.';

  /// "Cấp 4 · Đòn kết liễu".
  static String levelCaption(String level, String item) => '$level · $item';

  /// "Mùa 2026 // Phần V · Cấp 25".
  static String rewardDetail(String contract, String? level) =>
      level == null ? contract : '$contract · $level';

  /// "Có trong cửa hàng của: Tài khoản 2".
  static String availableInStoreOf(String accounts) =>
      'Có trong cửa hàng của: $accounts';
}
