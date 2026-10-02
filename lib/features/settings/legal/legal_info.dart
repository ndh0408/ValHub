/// Publisher / contact details used by every legal document, the About hub
/// and the exported Markdown in `docs/legal/`.
///
/// **Chủ dự án điền MỘT LẦN tại đây** (thay các giá trị trong ngoặc vuông),
/// rồi chạy `dart run tool/export_legal_docs.dart` để cập nhật `docs/legal/`.
/// Pure Dart (no Flutter import) so the export tool can run it.
abstract final class LegalInfo {
  /// Tên cá nhân / tổ chức phát hành ValHub (bên kiểm soát dữ liệu).
  static const publisherName = 'Nguyễn Đức Huy';

  /// Email nhận liên hệ, yêu cầu về dữ liệu cá nhân và báo cáo vi phạm.
  static const contactEmail = 'ndh0408@gmail.com';

  /// Năm bản quyền.
  static const copyrightYear = '2026';

  /// Ngày hiệu lực chung của bộ văn bản (dd/MM/yyyy).
  static const effectiveDate = '29/09/2026';

  /// Tên sản phẩm dùng trong văn bản pháp lý.
  static const productName = 'ValHub';

  /// "© 2026 Nguyễn Đức Huy. Bảo lưu mọi quyền."
  static const copyrightNotice =
      '© $copyrightYear $publisherName. Bảo lưu mọi quyền.';

  /// `true` once [contactEmail] holds a real address (not a placeholder).
  static bool get hasContactEmail =>
      !contactEmail.startsWith('[') && contactEmail.contains('@');

  /// `mailto:` link of [contactEmail], or `null` while it is a placeholder.
  static Uri? get contactMailto =>
      hasContactEmail ? Uri(scheme: 'mailto', path: contactEmail) : null;
}
