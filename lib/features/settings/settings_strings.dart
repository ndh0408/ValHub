/// Vietnamese strings of the settings / onboarding feature (VF §6.1, §6.8,
/// §8.5, §8.12).
abstract final class SettingsStrings {
  static const title = 'Cài đặt';
  static const sessionLogTitle = 'Nhật ký phiên';
  static const aboutTitle = 'Giới thiệu & pháp lý';
  static const aboutRowSubtitle =
      'Quyền riêng tư, điều khoản, bản quyền và liên hệ';

  // Welcome (S01)
  static const logoPrefix = 'Val';
  static const logoSuffix = 'VN';
  static const welcomeBulletStore = 'Cửa hàng, Chợ Đêm, Bundle mỗi ngày';
  static const welcomeBulletProfile = 'Rank, lịch sử đấu, trận đang diễn ra';
  static const welcomeBulletWishlist = 'Wishlist & thông báo';
  static const welcomeFootnote =
      'Bạn đăng nhập trên trang chính thức của Riot. ValVN không bao giờ thấy mật khẩu của bạn.';
  static const legalNotice = 'Thông báo pháp lý';

  // Notification priming (S04)
  static const primingTitle = 'Đừng bỏ lỡ skin bạn săn';
  static const primingBody =
      'Bật thông báo để biết khi cửa hàng làm mới và khi skin trong wishlist '
      'xuất hiện.';
  static const primingPointStore = 'Nhắc khi cửa hàng hằng ngày làm mới';
  static const primingPointStoreDetail = 'Mỗi ngày lúc 07:00 giờ Việt Nam';
  static const primingPointWishlist = 'Báo ngay khi skin bạn săn xuất hiện';
  static const primingPointWishlistDetail =
      'Kiểm tra cửa hàng của mọi tài khoản trong nền';
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
  static const appHeader = 'ỨNG DỤNG';
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
      'Người chơi console chọn đúng nền tảng để xem lịch sử đấu chính xác.';
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
  static const notifWishlist = 'Kiểm tra wishlist trong nền';
  static const notifWishlistSubtitle = 'Báo khi skin trong wishlist xuất hiện';
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
      'Tên skin, đặc vụ, bản đồ… lấy từ valorant-api.com theo ngôn ngữ này.';
  static const itemLanguageVi = 'Tiếng Việt';
  static const itemLanguageEn = 'Tiếng Anh';

  // ỨNG DỤNG
  static String version(String version) => 'Phiên bản $version';
  static String buildNumber(String build) => 'Bản dựng $build';
  static const clearCache = 'Xóa bộ nhớ đệm';
  static const clearCacheSubtitle = 'Ảnh và dữ liệu ngoại tuyến đã lưu';
  static String cacheCleared(String size) => 'Đã xóa $size';
  static const clearCacheFailed = 'Không thể xóa bộ nhớ đệm. Vui lòng thử lại.';
  static const exportLog = 'Nhật ký phiên';
  static const exportLogSubtitle = 'Xem, sao chép hoặc gửi khi báo lỗi';
  static const exportLogNote =
      'Nhật ký không chứa mật khẩu, token hay ID tài khoản.';
  static const exportLogEmptyTitle = 'Chưa có nhật ký';
  static const exportLogEmpty =
      'Các yêu cầu tới máy chủ Riot sẽ hiện ở đây khi bạn dùng ứng dụng.';

  // HỖ TRỢ
  static const feedback = 'Góp ý & báo lỗi';
  static const feedbackSubtitle = 'Gửi góp ý trên GitHub';
  static const linkOpenFailed = 'Không mở được liên kết.';
  static const serverStatus = 'Trạng thái máy chủ';
  static const serverStatusSubtitle = 'Bảo trì và sự cố VALORANT theo khu vực';
  static const serverStatusMaintenance = 'Đang bảo trì';
  static String serverStatusNotices(int n) => '$n thông báo';

  // Server status screen (ValVN extra, X-1)
  static const statusSourceNote =
      'Nguồn: trang trạng thái chính thức của Riot Games. Giờ hiển thị theo '
      'múi giờ của điện thoại.';
  static const statusAllGood = 'Máy chủ hoạt động bình thường';
  static String statusAllGoodBody(String region) =>
      'Không có sự cố hay bảo trì nào ở khu vực $region.';
  static const statusMaintenanceNow = 'Máy chủ đang bảo trì';
  static const statusMaintenanceNowBody =
      'Bạn có thể chưa vào được game hoặc ứng dụng tạm thời không tải được '
      'dữ liệu.';
  static const statusIssues = 'Riot đang xử lý sự cố';
  static String statusIssuesBody(int n) =>
      '$n thông báo đang mở ở khu vực này.';
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
  static const statusRegionPicker = 'Khu vực';

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
    _ => id,
  };

  // Sign out
  static const signedOutAll = 'Đã đăng xuất tất cả tài khoản';

  // Session log (S71)
  static String logEntryCount(int count) => '$count mục';
  static String logEntryShown(int shown, int total) => '$shown / $total mục';
  static const logSearchHint = 'Tìm theo sự kiện, địa chỉ, mã lỗi…';
  static const logSearchEmpty = 'Không có mục nào khớp tìm kiếm.';
  static const logMore = 'Thao tác khác';
  static const clearLog = 'Xóa nhật ký';
  static const clearLogConfirm = 'Xóa toàn bộ nhật ký phiên trên thiết bị này?';
  static const logCleared = 'Đã xóa nhật ký';
  static const logShareFailed = 'Không thể chia sẻ nhật ký.';
  static String logFileHeader(String appName, String version) =>
      '$appName $version — Nhật ký phiên';

  // Session log filter (remembered per device)
  static const logFilterAll = 'Tất cả';
  static const logFilterErrors = 'Lỗi';
  static const logFilterHttp = 'HTTP';
  static const logFilterAuth = 'Đăng nhập';
  static const logFilterEmpty = 'Không có mục nào khớp bộ lọc này.';

  // Welcome hero (S01)
  static const welcomeKicker = 'TRỢ THỦ VALORANT TIẾNG VIỆT';
  static const welcomeBulletStoreDetail = 'Xem giá, độ hiếm, đếm ngược làm mới';
  static const welcomeBulletProfileDetail = 'RR từng trận, rank đối thủ';
  static const welcomeBulletWishlistDetail = 'Báo ngay khi skin bạn săn lên kệ';

  // About screen (S72)
  static const aboutCreditsHeader = 'NGUỒN DỮ LIỆU';
  static const aboutCreditContent = 'valorant-api.com';
  static const aboutCreditContentBody =
      'Tên, hình ảnh và dữ liệu vật phẩm, đặc vụ, bản đồ, rank (tiếng Việt).';
  static const aboutCreditRiot = 'Riot Games';
  static const aboutCreditRiotBody =
      'Cửa hàng, ví, bộ sưu tập, trận đấu và xếp hạng lấy trực tiếp từ tài '
      'khoản Riot bạn đăng nhập.';
  static const aboutCreditDocs = 'Tài liệu API cộng đồng';
  static const aboutCreditDocsBody =
      'techchrism/valorant-api-docs và cộng đồng nhà phát triển Valorant.';
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
