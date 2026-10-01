/// Vietnamese strings of the settings / onboarding feature (VF §6.1, §6.8,
/// §8.5, §8.12).
abstract final class SettingsStrings {
  static const title = 'Cài đặt';

  /// Subject / title of the shared bug-report file ("Gửi báo lỗi cho ValVN").
  static const sessionLogTitle = 'Báo lỗi ValVN';
  static const aboutTitle = 'Giới thiệu & pháp lý';
  static const aboutRowSubtitle =
      'Quyền riêng tư, điều khoản, bản quyền và liên hệ';

  // Welcome (S01)
  static const logoPrefix = 'Val';
  static const logoSuffix = 'VN';
  static const welcomeBulletStore = 'Cửa hàng hằng ngày, Chợ Đêm và bundle';
  static const welcomeBulletProfile = 'Rank, lịch sử đấu, trận đang diễn ra';
  static const welcomeBulletWishlist = 'Wishlist & thông báo';
  static const welcomeFootnote =
      'Bạn đăng nhập trên trang chính thức của Riot. ValVN chỉ lưu mật khẩu khi bạn tự chọn lưu thông tin đăng nhập.';
  static const legalNotice = 'Thông báo pháp lý';

  // Notification priming (S04)
  static const primingTitle = 'Đừng bỏ lỡ skin bạn săn';
  static const primingBody =
      'Bật thông báo để biết khi cửa hàng làm mới và khi skin trong wishlist '
      'xuất hiện.';
  static const primingPointStore = 'Nhắc khi cửa hàng hằng ngày làm mới';
  static const primingPointStoreDetail =
      'Nhắc sau khi cửa hàng của tài khoản làm mới';
  static const primingPointWishlist = 'Báo khi skin bạn săn xuất hiện';
  static const primingPointWishlistDetail =
      'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng';
  static const primingPointNightMarket = 'Biết khi Chợ Đêm mở';
  static const primingPointNightMarketDetail =
      'Để kịp lật thẻ ưu đãi trước khi hết hạn';
  static const primingFootnote =
      'Bạn có thể bật hoặc tắt từng loại thông báo bất cứ lúc nào trong Cài '
      'đặt.';
  static const primingEnable = 'Bật thông báo';
  static const primingLater = 'Để sau';

  // Section headers (S70)
  static const optionsHeader = 'TÙY CHỌN';
  static const notificationsHeader = 'THÔNG BÁO';
  static const appearanceHeader = 'GIAO DIỆN';
  static const supportHeader = 'HỖ TRỢ';

  /// Header of the "Nâng cao" group (send a bug report, clear temporary
  /// data). The member keeps its historical name.
  static const appHeader = 'NÂNG CAO';
  static const aboutHeader = 'THÔNG TIN';

  // TÀI KHOẢN
  static String switchedTo(String account) => 'Đã chuyển sang $account';
  static String removedAccount(String account) => 'Đã xóa $account';

  // TÙY CHỌN
  static const optionAutoOpenLiveGame = 'Tự động mở chi tiết trận';
  static const optionAutoOpenLiveGameSubtitle =
      'Mở bảng trận hiện tại ngay khi tìm thấy trận';
  static const optionShowPeakRank = 'Hiện rank cao nhất trong chi tiết trận';
  static const optionShowLiveScore = 'Hiện tỉ số trực tiếp';
  static const optionPlatform = 'Nền tảng';
  static const platformPickerTitle = 'Chọn nền tảng';
  static const platformHint =
      'Chọn PC, PlayStation hoặc Xbox theo nơi bạn chơi để xem đúng lịch sử đấu.';
  static String platformAppliesTo(String account) => 'Áp dụng cho $account';
  static const optionShowPrice = 'Hiện giá quy đổi ước tính';
  static String optionShowPriceSubtitle(String vp, String price) =>
      'Cạnh giá VP, ví dụ $vp $price';
  static const optionShowPriceUnavailable =
      'Chưa có bảng giá đã xác minh cho khu vực của bạn — hãy nhập giá gói '
      'VP của bạn.';
  static const optionShowPriceInfo = 'Cách tính giá quy đổi';
  static const optionOwnPrice = 'Giá gói VP của bạn';
  static const optionOwnPriceEmpty =
      'Chưa nhập — dùng bảng giá của khu vực nếu có';
  static String optionOwnPriceValue(String vp, String price) => '$vp = $price';

  // THÔNG BÁO
  static const notifStoreReset = 'Khi cửa hàng làm mới';

  /// [time] = local time of the daily reset (00:00 UTC), e.g. `07:00`.
  static String notifStoreResetSubtitle(String time) => '$time hằng ngày';
  static const notifWishlist = 'Khi skin trong wishlist xuất hiện';
  static const notifWishlistSubtitle =
      'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng';
  static const notifNightMarket = 'Khi Chợ Đêm mở';
  static const notifNightMarketSubtitle = 'Nhắc bạn lật thẻ ưu đãi Chợ Đêm';
  static const notifPermissionMissing = 'Ứng dụng chưa có quyền gửi thông báo.';

  // GIAO DIỆN
  static const themeLabel = 'Chủ đề';
  static const themePickerTitle = 'Chọn chủ đề';
  static const themeDark = 'Tối';
  static const themeLight = 'Sáng';
  static const themeSystem = 'Theo hệ thống';
  static const itemLanguageLabel = 'Tên vật phẩm';
  static const itemLanguagePickerTitle = 'Ngôn ngữ tên vật phẩm';
  static const itemLanguageHint =
      'Tên skin, đặc vụ, bản đồ… hiển thị theo ngôn ngữ này.';
  static const itemLanguageVi = 'Tiếng Việt';
  static const itemLanguageEn = 'Tiếng Anh';

  // NÂNG CAO (the version lives on the About screen only)
  static String version(String version) => 'Phiên bản $version';
  static String buildNumber(String build) => 'Bản dựng $build';
  static const clearCache = 'Xóa dữ liệu tạm';
  static const clearCacheSubtitle =
      'Ảnh và dữ liệu đã tải về máy, kể cả báo lỗi đã ghi';
  static String cacheCleared(String size) => 'Đã xóa $size';
  static const clearCacheFailed = 'Chưa xóa được dữ liệu tạm. Hãy thử lại.';

  /// Row that builds the bug-report file and opens the share sheet.
  static const exportLog = 'Gửi báo lỗi cho ValVN';
  static const exportLogSubtitle =
      'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.';

  /// Snackbar when nothing has been recorded yet.
  static const exportLogEmpty =
      'Chưa có gì để gửi. Hãy dùng ứng dụng một lúc rồi thử lại.';

  // HỖ TRỢ
  static const feedback = 'Góp ý cho ValVN';
  static const feedbackSubtitle = 'Mở trang góp ý của ValVN';
  static const linkOpenFailed = 'Chưa mở được liên kết. Hãy thử lại.';
  static const serverStatus = 'Trạng thái máy chủ';
  static const serverStatusSubtitle = 'Bảo trì và sự cố VALORANT theo máy chủ';
  static const serverStatusMaintenance = 'Đang bảo trì';
  static String serverStatusNotices(int n) => '$n thông báo';

  // Server status screen (ValVN extra, X-1)
  static const statusSourceNote =
      'Nguồn: trang trạng thái chính thức của Riot Games. Giờ hiển thị theo '
      'múi giờ của thiết bị.';
  static const statusAllGood = 'Máy chủ hoạt động bình thường';
  static String statusAllGoodBody(String region) =>
      'Không có sự cố hay bảo trì nào ở máy chủ $region.';
  static const statusMaintenanceNow = 'Máy chủ đang bảo trì';
  static const statusMaintenanceNowBody =
      'Bạn có thể chưa vào được game, và ValVN có thể tạm thời chưa tải được '
      'thông tin.';
  static const statusIssues = 'Riot đang xử lý sự cố';
  static String statusIssuesBody(int n) => 'Máy chủ này có $n thông báo sự cố.';
  static const statusScheduled = 'Sắp có bảo trì';
  static String statusScheduledBody(int n) =>
      '$n lịch bảo trì đã được Riot thông báo.';
  static const statusKindMaintenance = 'Bảo trì';
  static const statusKindIncident = 'Sự cố';
  static const severityInfo = 'Thông tin';
  static const severityWarning = 'Cảnh báo';
  static const severityCritical = 'Nghiêm trọng';
  static const phaseScheduled = 'Đã lên lịch';
  static const phaseInProgress = 'Đang diễn ra';
  static const phaseComplete = 'Đã xong';
  static String statusStarted(String when) => 'Bắt đầu $when';
  static String statusUpdated(String when) => 'Cập nhật $when';
  static const statusUpdatesHeader = 'CẬP NHẬT TỪ RIOT';
  static String statusMoreUpdates(int n) => 'Xem thêm $n cập nhật';
  static const statusFewerUpdates = 'Thu gọn';
  static const statusRegionPicker = 'Máy chủ';

  /// Riot platform ids of the status page → Vietnamese labels.
  static String platformName(String id) => switch (id.toLowerCase()) {
    'windows' || 'pc' => 'PC',
    'macos' => 'Mac',
    'ps4' => 'PlayStation 4',
    'ps5' => 'PlayStation 5',
    'playstation' => 'PlayStation',
    'xbone' => 'Xbox One',
    'xbox' || 'xboxseries' || 'xbox_series' => 'Xbox',
    'android' => 'Android',
    'ios' => 'iOS',
    'mobile' => 'Di động',
    _ => 'Nền tảng khác',
  };

  // Sign out
  static const signedOutAll = 'Đã đăng xuất tất cả tài khoản';

  /// Failure of the share sheet of the bug report.
  static const logShareFailed = 'Chưa gửi được báo lỗi. Hãy thử lại.';

  /// First line of the bug-report file.
  static String logFileHeader(String appName, String version) =>
      '$appName $version — Báo lỗi';

  // Keep the historical members for the later mechanical ARB extraction.
  // They do not restore the retired log viewer or any route to it.
  static const exportLogNote =
      'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.';
  static const exportLogEmptyTitle = 'Chưa có gì để gửi';
  static String logEntryCount(int count) => '$count mục';
  static String logEntryShown(int shown, int total) => '$shown / $total mục';
  static const logSearchHint = 'Tìm trong báo lỗi…';
  static const logSearchEmpty = 'Không có mục phù hợp.';
  static const logMore = 'Tùy chọn khác';
  static const clearLog = 'Xóa báo lỗi đã ghi';
  static const clearLogConfirm = 'Xóa báo lỗi đã ghi trên thiết bị này?';
  static const logCleared = 'Đã xóa báo lỗi';
  static const logFilterAll = 'Tất cả';
  static const logFilterErrors = 'Sự cố';
  static const logFilterHttp = 'Kết nối';
  static const logFilterAuth = 'Đăng nhập';
  static const logFilterEmpty = 'Không có mục phù hợp. Hãy bỏ lọc để xem thêm.';

  // Welcome hero (S01)
  static const welcomeKicker = 'TRỢ THỦ VALORANT';
  static const welcomeBulletStoreDetail = 'Xem giá, độ hiếm, đếm ngược làm mới';
  static const welcomeBulletProfileDetail = 'RR từng trận, rank đối thủ';
  static const welcomeBulletWishlistDetail = 'Báo khi skin bạn săn lên kệ';

  // About screen (S72)
  static const aboutCreditsHeader = 'NGUỒN DỮ LIỆU';
  static const aboutCreditContent = 'valorant-api.com';
  static const aboutCreditContentBody =
      'Tên, hình ảnh và thông tin về skin, đặc vụ, bản đồ và rank.';
  static const aboutCreditRiot = 'Riot Games';
  static const aboutCreditRiotBody =
      'Cửa hàng, ví, bộ sưu tập, trận đấu và xếp hạng lấy trực tiếp từ tài '
      'khoản Riot bạn đăng nhập.';
  static const aboutCreditDocs = 'Tài liệu cộng đồng';
  static const aboutCreditDocsBody =
      'Dự án techchrism/valorant-api-docs và cộng đồng nhà phát triển '
      'VALORANT.';
  static const aboutLegalHeader = 'PHÁP LÝ';
}

/// External links of the settings feature (not user-visible text).
abstract final class SettingsLinks {
  static final feedback = Uri.parse('https://github.com/ndh0408/ValVN/issues');
  static final valorantApi = Uri.parse('https://valorant-api.com');
  static final apiDocs = Uri.parse(
    'https://github.com/techchrism/valorant-api-docs',
  );
}
