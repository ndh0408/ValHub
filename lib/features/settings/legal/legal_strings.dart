import 'legal_info.dart';

/// Vietnamese UI strings of the legal document screen, the About hub
/// ("Giới thiệu & pháp lý") and the sign-in consent line.
abstract final class LegalStrings {
  // Document screen
  static const kicker = 'VĂN BẢN PHÁP LÝ';
  static const tocTitle = 'MỤC LỤC';
  static String version(String version) => 'Phiên bản $version';
  static String effectiveFrom(String date) => 'Hiệu lực từ: $date';
  static const backToTop = 'Về đầu trang';

  // About hub
  static const aboutIntro =
      'ValVN là trợ thủ VALORANT bằng tiếng Việt: xem cửa hàng mỗi ngày, săn '
      'skin trong wishlist, theo dõi rank và trận đấu, quản lý nhiều tài khoản '
      'và kết nối với cộng đồng người chơi, ngay trên điện thoại.';
  static const featuresHeader = 'TÍNH NĂNG CHÍNH';
  static const featureStore = 'Cửa hàng, Chợ Đêm & bundle';
  static const featureStoreBody =
      'Xem cửa hàng hằng ngày và giá VP của mọi tài khoản';
  static const featureWishlist = 'Wishlist & thông báo';
  static const featureWishlistBody = 'Báo ngay khi skin bạn săn xuất hiện';
  static const featureProfile = 'Hồ sơ, rank & trận đấu';
  static const featureProfileBody =
      'Lịch sử đấu, K/D/A, ACS, HS% và trận hiện tại';
  static const featureCollection = 'Bộ sưu tập & Battle Pass';
  static const featureCollectionBody =
      'Trang bị skin, theo dõi tiến độ Battle Pass';
  static const featureSocial = 'Bạn bè & Cộng đồng';
  static const featureSocialBody =
      'Trò chuyện, tổ đội, tìm đồng đội, bình chọn skin';
  static const legalHeader = 'TÀI LIỆU PHÁP LÝ';
  static const creditsHeader = 'NGUỒN DỮ LIỆU & GHI CÔNG';
  static const thirdPartyLicenses = 'Giấy phép thư viện bên thứ ba';
  static const thirdPartyLicensesBody =
      'Thư viện mã nguồn mở được dùng trong ValVN';
  static const supportHeader = 'HỖ TRỢ';
  static const contact = 'Liên hệ';
  static const contactBody = LegalInfo.contactEmail;

  /// Legalese shown on Flutter's licence page.
  static const licensePageLegalese = LegalInfo.copyrightNotice;

  // Consent line (welcome screen)
  static const consentPrefix = 'Bằng việc tiếp tục, bạn đồng ý với ';
  static const consentTerms = 'Điều khoản sử dụng';
  static const consentAnd = ' và ';
  static const consentPrivacy = 'Chính sách quyền riêng tư';
  static const consentSuffix = ' của ValVN.';
}
