/// Vietnamese strings of the settings / onboarding feature (VF §6.1, §6.8,
/// §8.5, §8.12).
abstract final class SettingsStrings {
  static const title = 'Cài đặt';
  static const sessionLogTitle = 'Nhật ký phiên';
  static const aboutTitle = 'Giới thiệu & pháp lý';

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
  static const primingTitle = 'Bật thông báo';
  static const primingBody =
      'Bật thông báo để biết khi cửa hàng làm mới và khi skin trong wishlist xuất hiện.';
  static const primingPointStore = 'Nhắc khi cửa hàng hằng ngày làm mới';
  static const primingPointWishlist = 'Báo ngay khi skin bạn săn xuất hiện';
  static const primingPointNightMarket = 'Biết khi Chợ Đêm mở';
  static const primingEnable = 'Bật thông báo';
  static const primingLater = 'Để sau';

  // Section headers (S70)
  static const optionsHeader = 'TÙY CHỌN';
  static const notificationsHeader = 'THÔNG BÁO';
  static const appearanceHeader = 'GIAO DIỆN';
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

  // THÔNG BÁO
  static const notifStoreReset = 'Khi cửa hàng làm mới';

  /// [time] = local time of the daily reset (00:00 UTC), e.g. `07:00`.
  static String notifStoreResetSubtitle(String time) => '$time hằng ngày';
  static const notifWishlist = 'Kiểm tra wishlist trong nền';
  static const notifWishlistSubtitle =
      'Báo khi skin trong wishlist xuất hiện, cho tất cả tài khoản';
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
  static const exportLog = 'Xuất nhật ký phiên';
  static const exportLogNote =
      'Nhật ký không chứa mật khẩu, token hay ID tài khoản.';
  static const exportLogEmpty = 'Chưa có nhật ký nào.';

  // THÔNG TIN
  static const privacyPolicy = 'Chính sách quyền riêng tư';
  static const privacyPolicyBody =
      'ValVN lưu token đăng nhập Riot và dữ liệu tài khoản chỉ trên thiết bị '
      'của bạn, trong vùng lưu trữ bảo mật của hệ điều hành. ValVN không có '
      'máy chủ riêng và không gửi dữ liệu của bạn cho bên thứ ba.\n\n'
      'Ứng dụng chỉ kết nối tới máy chủ của Riot Games (để đọc cửa hàng, bộ '
      'sưu tập, trận đấu của chính tài khoản bạn đăng nhập) và tới '
      'valorant-api.com (tên, hình ảnh vật phẩm công khai).\n\n'
      'Nhật ký phiên chỉ ghi tên yêu cầu, mã trạng thái và thời gian, không '
      'bao giờ chứa mật khẩu, token hay ID tài khoản. Nhật ký chỉ rời khỏi '
      'thiết bị khi bạn tự chia sẻ.\n\n'
      'Đăng xuất một tài khoản sẽ xóa token, cookie và dữ liệu đã lưu của '
      'tài khoản đó khỏi thiết bị (wishlist được giữ lại).';
  static const terms = 'Điều khoản sử dụng';
  static const termsBody =
      'ValVN là ứng dụng không chính thức của cộng đồng, không liên kết hay '
      'được Riot Games xác nhận, tài trợ hoặc giám sát.\n\n'
      'Bạn đăng nhập bằng tài khoản Riot của chính mình trên trang chính thức '
      'của Riot và cần tuân thủ Điều khoản dịch vụ của Riot Games. Mọi thao '
      'tác làm thay đổi tài khoản (trang bị, chọn đặc vụ, hàng chờ…) chỉ được '
      'thực hiện khi bạn tự bấm.\n\n'
      'Ứng dụng được cung cấp nguyên trạng, không kèm bảo hành dưới bất kỳ '
      'hình thức nào.';
  static const feedback = 'Góp ý & báo lỗi';
  static const feedbackSubtitle = 'Gửi góp ý trên GitHub';
  static const linkOpenFailed = 'Không mở được liên kết.';
  static const licenses = 'Giấy phép mã nguồn mở';

  // Sign out
  static const signedOutAll = 'Đã đăng xuất tất cả tài khoản';

  // Session log (S71)
  static String logEntryCount(int count) => '$count mục';
  static const clearLog = 'Xóa nhật ký';
  static const clearLogConfirm = 'Xóa toàn bộ nhật ký phiên trên thiết bị này?';
  static const logCleared = 'Đã xóa nhật ký';
  static const logShareFailed = 'Không thể chia sẻ nhật ký.';
  static String logFileHeader(String appName, String version) =>
      '$appName $version — Nhật ký phiên';

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
