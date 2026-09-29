/// Strings for account management (VF §6.1 S05, §8.12).
abstract final class AccountStrings {
  static const switcherTitle = 'Tài khoản';

  /// "Tài khoản (3/10)" (sheet title).
  static String switcherTitleCount(int count, int max) =>
      '$switcherTitle ($count/$max)';
  static const switcherSubtitle = 'Chạm để chuyển tài khoản';
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

  // Live activity of each account in the lists (VF §8: online / offline)
  static const statusOnline = 'Trực tuyến';
  static const statusOffline = 'Ngoại tuyến';
  static const statusAgentSelect = 'Đang chọn đặc vụ';
  static const statusInMatch = 'Đang đấu';
  static const statusUnknown = 'Chưa rõ trạng thái';
  static String onlineCount(int count) => '$count đang trực tuyến';

  // Login note: the user's own Riot username / password per account
  static const loginNote = 'Ghi chú đăng nhập';
  static const loginNoteEmpty = 'Chưa có ghi chú đăng nhập';
  static const loginNoteHint =
      'Chỉ lưu trên thiết bị này, trong bộ nhớ bảo mật. Dùng để xem lại hoặc '
      'điền nhanh khi đăng nhập lại.';
  static const loginNoteUsername = 'Tên đăng nhập Riot';
  static const loginNotePassword = 'Mật khẩu';
  static const showPassword = 'Hiện mật khẩu';
  static const hidePassword = 'Ẩn mật khẩu';
  static const copyUsername = 'Sao chép tên đăng nhập';
  static const copyPassword = 'Sao chép mật khẩu';
  static const loginNoteSaved = 'Đã lưu ghi chú đăng nhập';
  static const loginNoteDeleted = 'Đã xóa ghi chú đăng nhập';
  static const deleteLoginNote = 'Xóa ghi chú';
  static const deleteLoginNoteConfirm =
      'Xóa tên đăng nhập và mật khẩu đã lưu của tài khoản này?';

  // Quick fill on the Riot login page
  static const quickFill = 'Điền nhanh';
  static const quickFillTitle = 'Điền tài khoản đã lưu';
  static const quickFillSubtitle =
      'Chọn ghi chú đăng nhập để điền vào trang Riot';
  static const quickFillDone = 'Đã điền, hãy bấm Đăng nhập.';
  static const quickFillNotReady =
      'Chưa thấy ô đăng nhập. Đợi trang tải xong rồi thử lại.';
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

  /// Vietnamese name of a Riot region id (`ap` → "Châu Á - Thái Bình
  /// Dương"); unknown ids are shown upper-cased.
  static String regionName(String region) => switch (region.toLowerCase()) {
    'ap' => regionAp,
    'na' => regionNa,
    'eu' => regionEu,
    'kr' => regionKr,
    'latam' => regionLatam,
    'br' => regionBr,
    _ => region.toUpperCase(),
  };

  // Switcher sheet (S05)
  static String accountCount(int count, int max) => '$count/$max tài khoản';
  static const manageHint =
      'Xóa tài khoản hoặc sửa ghi chú đăng nhập trong Cài đặt.';
}
