import 'legal_info.dart';

/// Vietnamese UI strings of the legal document screen, the About hub
/// ("Giới thiệu & pháp lý") and the sign-in consent line.
abstract final class LegalStrings {
  // Document screen
  static const tocTitle = 'MỤC LỤC';
  static String version(String version) => 'Phiên bản $version';
  static String effectiveFrom(String date) => 'Hiệu lực từ $date';
  static const backToTop = 'Về đầu trang';

  // About hub
  static const aboutIntro =
      'Trợ thủ VALORANT bằng tiếng Việt: cửa hàng mỗi ngày, wishlist, rank, '
      'trận đấu, nhiều tài khoản và cộng đồng người chơi, ngay trên điện '
      'thoại.';
  static const legalHeader = 'PHÁP LÝ';
  static const thirdPartyLicenses = 'Thư viện bên thứ ba';
  static const thirdPartyLicensesBody =
      'Giấy phép mã nguồn mở của các thư viện dùng trong ValVN';
  static const contactHeader = 'LIÊN HỆ';
  static const contact = 'Liên hệ';
  static const contactBody = LegalInfo.contactEmail;
  static const creditsHeader = 'NGUỒN DỮ LIỆU & GHI CÔNG';

  /// Legalese shown on Flutter's licence page.
  static const licensePageLegalese = LegalInfo.copyrightNotice;

  // Consent line (welcome screen)
  static const consentPrefix = 'Bằng việc tiếp tục, bạn đồng ý với ';
  static const consentTerms = 'Điều khoản sử dụng';
  static const consentAnd = ' và ';
  static const consentPrivacy = 'Chính sách quyền riêng tư';
  static const consentSuffix = ' của ValVN.';
}
