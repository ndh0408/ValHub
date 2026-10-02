/// Strings for the Riot sign-in flow (VF §6.1, §8.12, riot-auth §1.5).
abstract final class AuthStrings {
  static const loginTitle = 'Đăng nhập Riot';
  static const signInCta = 'Đăng nhập bằng tài khoản Riot';
  static const signInNote =
      'Bạn đăng nhập trên trang chính thức của Riot. ValHub chỉ lưu mật khẩu khi '
      'bạn tự chọn lưu thông tin đăng nhập; dữ liệu đăng nhập và thông tin đã '
      'lưu chỉ nằm trên thiết bị của bạn.';
  static const rememberMeHint =
      'Hãy bật "Duy trì đăng nhập" để không phải đăng nhập lại.';
  static const socialLoginHint =
      'Nếu đăng nhập bằng Google hoặc Facebook không được, hãy dùng tên '
      'đăng nhập Riot.';
  static const loadingAccount = 'Đang tải tài khoản…';
  static const preparing = 'Đang chuẩn bị trang đăng nhập…';
  static const loginFailed = 'Không thể hoàn tất đăng nhập';
  static const loginFailedBody =
      'Riot chưa xác nhận đăng nhập của bạn. Hãy thử lại.';
  static const loginCancelledByRiot =
      'Riot đã từ chối lần đăng nhập này. Hãy thử lại.';
  static const stateMismatch =
      'Lần đăng nhập này không hợp lệ. Hãy đăng nhập lại từ đầu.';
  static const missingCookies =
      'Không lưu được đăng nhập trên thiết bị này, nên bạn sẽ phải đăng nhập '
      'lại khi hết hạn.';
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
