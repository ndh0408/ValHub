/// Strings for account management (VF §6.1 S05, §8.12).
abstract final class AccountStrings {
  static const switcherTitle = 'Tài khoản';
  static String addAccount(int count, int max) =>
      'Thêm tài khoản ($count/$max)';
  static String accountsHeader(int count, int max) => 'TÀI KHOẢN ($count/$max)';
  static String maxAccounts(int max) => 'Đã đạt tối đa $max tài khoản.';
  static const switchFailed = 'Không thể chuyển tài khoản. Thử lại?';
  static String switchTo(String account) => 'Chuyển sang $account';
  static const needsLogin = 'Cần đăng nhập lại';
  static const active = 'Đang dùng';
  static const removeAccount = 'Xóa tài khoản';
  static String removeAccountConfirm(String account) =>
      'Xóa $account khỏi thiết bị này? Wishlist của tài khoản vẫn được giữ lại.';
  static const signOutAll = 'Đăng xuất tất cả tài khoản';
  static const signOutAllConfirm =
      'Đăng xuất và xóa mọi tài khoản khỏi thiết bị này? Wishlist vẫn được giữ lại.';
  static String levelShort(int level) => 'Cấp $level';
  static const unknownPlayer = 'Người chơi';

  // Platforms (A8)
  static const platformPc = 'PC';
  static const platformPlayStation = 'PlayStation';
  static const platformXbox = 'Xbox';

  // Regions (VF §8.12)
  static const regionAp = 'Châu Á - Thái Bình Dương';
  static const regionNa = 'Bắc Mỹ';
  static const regionEu = 'Châu Âu';
  static const regionKr = 'Hàn Quốc';
  static const regionLatam = 'Mỹ Latinh';
  static const regionBr = 'Brazil';
}
