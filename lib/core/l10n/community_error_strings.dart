/// Player copy for the stable moderation reasons returned by Community v3.
/// Request-field names and arbitrary server text are never interpolated.
abstract final class CommunityErrorStrings {
  static String? forReason(String? reason) => switch (reason) {
    'content_inappropriate' => 'Chưa đăng được vì có từ ngữ không phù hợp. Hãy sửa nội dung rồi thử lại.',
    'content_scam' => 'Cộng đồng không cho phép quảng cáo mua bán tài khoản, cày thuê hay để lại số điện thoại. Hãy bỏ những nội dung này rồi thử lại.',
    'content_too_complex' =>
      'Nội dung có quá nhiều ký tự rời rạc. Hãy viết gọn hơn rồi thử lại.',
    'account_banned' => 'Tài khoản này đã bị khóa quyền dùng Cộng đồng. Nếu cho rằng có nhầm lẫn, hãy liên hệ VanHub trong Giới thiệu & pháp lý.',
    'account_restricted' => 'Tài khoản này đang bị hạn chế đăng bài, bình luận, tìm đồng đội và bình chọn. Hãy thử lại sau hoặc liên hệ VanHub trong Giới thiệu & pháp lý.',
    _ => null,
  };
}
