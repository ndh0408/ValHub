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
  static const switchFailed = 'Chưa chuyển được tài khoản. Hãy thử lại.';
  static String switchTo(String account) => 'Chuyển sang $account';
  static const needsLogin = 'Cần đăng nhập lại';
  static const active = 'Đang dùng';
  static const removeAccount = 'Xóa tài khoản';
  static String removeAccountConfirm(String account) =>
      'Xóa $account khỏi thiết bị này? Bạn có thể chọn giữ dữ liệu đã lưu.';
  static const signOutAll = 'Đăng xuất tất cả tài khoản';
  static const signOutAllConfirm =
      'Đăng xuất và xóa mọi tài khoản khỏi thiết bị này? Bạn có thể chọn giữ dữ liệu đã lưu.';
  static String levelShort(int level) => 'Cấp $level';

  // Live activity of each account in the lists (VF §8: online / offline)
  static const statusOnline = 'Trực tuyến';
  static const statusOffline = 'Ngoại tuyến';
  static const statusAgentSelect = 'Đang chọn đặc vụ';
  static const statusInMatch = 'Đang đấu';
  static const statusUnknown = 'Chưa rõ trạng thái';
  static String onlineCount(int count) => '$count đang trực tuyến';

  // Login note: the user's own Riot username / password per account
  static const unlockLoginNote = 'Xác thực để mở thông tin đăng nhập Riot';
  static const loginNoteLocked = 'Mở khóa thông tin đăng nhập';
  static const keepLocalData = 'Giữ dữ liệu cục bộ';
  static const keepLocalDataHint =
      'Giữ wishlist, bộ trang bị và lịch sử trên thiết bị này';
  static const clearLocalData = 'Xóa dữ liệu cục bộ';
  static const clearLocalDataConfirm =
      'Xóa lịch sử, bộ trang bị đã lưu và dữ liệu của tài khoản đã đăng xuất trên thiết bị này?';
  static const localDataCleared = 'Đã xóa dữ liệu cục bộ';
  static const loginNote = 'Thông tin đăng nhập';
  static const loginNoteEmpty = 'Chưa lưu thông tin đăng nhập';
  static const loginNoteHint =
      'Chỉ lưu trên thiết bị này, được khóa an toàn. Dùng để xem lại hoặc điền '
      'nhanh khi bạn đăng nhập lại.';
  static const loginNoteUsername = 'Tên đăng nhập Riot';
  static const loginNotePassword = 'Mật khẩu';
  static const showPassword = 'Hiện mật khẩu';
  static const hidePassword = 'Ẩn mật khẩu';
  static const copyUsername = 'Sao chép tên đăng nhập';
  static const copyPassword = 'Sao chép mật khẩu';
  static const loginNoteSaved = 'Đã lưu thông tin đăng nhập';
  static const loginNoteDeleted = 'Đã xóa thông tin đăng nhập';
  static const deleteLoginNote = 'Xóa thông tin';
  static const deleteLoginNoteConfirm =
      'Xóa tên đăng nhập và mật khẩu đã lưu của tài khoản này?';

  // Quick fill on the Riot login page
  static const quickFill = 'Điền tài khoản đã lưu';
  static const quickFillTitle = 'Điền tài khoản đã lưu';
  static const quickFillSubtitle =
      'Chọn tài khoản để điền vào trang đăng nhập Riot';
  static const quickFillDone = 'Đã điền xong. Hãy bấm Đăng nhập.';
  static const quickFillNotReady =
      'Trang đăng nhập chưa tải xong. Đợi một chút rồi thử lại.';
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
  /// Dương"); unknown ids use a friendly fallback.
  static String regionName(String region) => switch (region.toLowerCase()) {
    'ap' => regionAp,
    'na' => regionNa,
    'eu' => regionEu,
    'kr' => regionKr,
    'latam' => regionLatam,
    'br' => regionBr,
    _ => 'Chưa rõ máy chủ',
  };

  // Switcher sheet (S05)
  static String accountCount(int count, int max) => '$count/$max tài khoản';
  static const manageHint =
      'Xóa tài khoản hoặc sửa thông tin đăng nhập trong Cài đặt.';
}
