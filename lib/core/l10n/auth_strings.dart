/// Strings for the Riot sign-in flow (VF §6.1, §8.12, riot-auth §1.5).
abstract final class AuthStrings {
  static const loginTitle = 'Đăng nhập Riot';
  static const signInCta = 'Đăng nhập bằng tài khoản Riot';
  static const signInNote =
      'Bạn đăng nhập trên trang chính thức của Riot. ValVN chỉ lưu mật khẩu khi '
      'bạn tự thêm ghi chú đăng nhập; token và ghi chú chỉ nằm trên thiết bị '
      'của bạn.';
  static const rememberMeHint =
      'Hãy tick "Duy trì đăng nhập" để không phải đăng nhập lại.';
  static const socialLoginHint =
      'Nếu đăng nhập Google/Facebook không hoạt động, hãy dùng Riot ID.';
  static const loadingAccount = 'Đang tải tài khoản…';
  static const preparing = 'Đang chuẩn bị trang đăng nhập…';
  static const loginFailed = 'Không thể hoàn tất đăng nhập';
  static const loginFailedBody =
      'Riot không trả về phiên đăng nhập hợp lệ. Vui lòng thử lại.';
  static const loginCancelledByRiot = 'Riot đã từ chối yêu cầu đăng nhập.';
  static const stateMismatch =
      'Phiên đăng nhập không khớp. Vui lòng đăng nhập lại từ đầu.';
  static const missingCookies =
      'Không lưu được phiên đăng nhập. Bạn sẽ phải đăng nhập lại khi token hết hạn.';
  static const pageLoadFailed =
      'Không tải được trang đăng nhập của Riot. Kiểm tra mạng rồi thử lại.';
  static const differentAccountTitle = 'Tài khoản khác';
  static const differentAccountBody =
      'Bạn vừa đăng nhập một tài khoản khác với tài khoản cần đăng nhập lại. '
      'Thêm tài khoản này như một tài khoản mới?';
  static const addAsNew = 'Thêm tài khoản mới';
  static const accountAlreadyAdded = 'Tài khoản này đã được thêm';
  static const reloginDone = 'Đã đăng nhập lại';
  static const openedInBrowser = 'Đã mở liên kết trong trình duyệt.';
  static const officialHost = 'Trang chính thức · auth.riotgames.com';
}
